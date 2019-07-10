//
//  zlib.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public class Deflate : _Z_STREAM {
    
    public init(level: Level = .default, windowBits: Int32 = MAX_WBITS, memLevel: Int32 = MAX_MEM_LEVEL, strategy: Strategy = .default) throws {
        try super.init()
        let status = deflateInit2_(&stream, level.rawValue, Z_DEFLATED, windowBits, memLevel, strategy.rawValue, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { throw Error(code: status, msg: stream.msg) }
    }
    
    deinit {
        deflateEnd(&stream)
    }
    
    fileprivate override func _z_stream_process(_ flush: Int32) -> Int32 {
        return deflate(&stream, flush)
    }
}

extension Deflate {
    
    public enum Strategy : CaseIterable {
        
        case `default`
        case filtered
        case huffmanOnly
        case rle
        case fixed
    }
    
    @_fixed_layout
    public struct Level: RawRepresentable {
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static var `default` = Level(rawValue: Z_DEFAULT_COMPRESSION)
        public static var speed = Level(rawValue: Z_BEST_SPEED)
        public static var compact = Level(rawValue: Z_BEST_COMPRESSION)
        public static var noCompression = Level(rawValue: Z_NO_COMPRESSION)
    }
}

extension Deflate.Strategy {
    
    var rawValue: Int32 {
        switch self {
        case .default: return Z_DEFAULT_STRATEGY
        case .filtered: return Z_FILTERED
        case .huffmanOnly: return Z_HUFFMAN_ONLY
        case .rle: return Z_RLE
        case .fixed: return Z_FIXED
        }
    }
}

public class Inflate : _Z_STREAM {
    
    public override init() throws {
        try super.init()
        let status = inflateInit2_(&stream, MAX_WBITS + 32 as Int32, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { throw Error(code: status, msg: stream.msg) }
    }
    
    deinit {
        inflateEnd(&stream)
    }
    
    fileprivate override func _z_stream_process(_ flush: Int32) -> Int32 {
        return inflate(&stream, flush)
    }
}

public class _Z_STREAM : CompressionCodec {
    
    fileprivate var stream: z_stream
    
    fileprivate init() throws {
        self.stream = z_stream()
    }
    
    fileprivate func _z_stream_process(_ flush: Int32) -> Int32 {
        return Z_BUF_ERROR
    }
}

extension _Z_STREAM {
    
    public enum Error: Swift.Error {
        
        case stream(message: String)
        case data(message: String)
        case memory(message: String)
        case buffer(message: String)
        case version(message: String)
        case unknown(message: String, code: Int)
        
        fileprivate init(code: Int32, msg: UnsafePointer<CChar>?) {
            
            let message: String = msg.flatMap { String(validatingUTF8: $0) } ?? "Unknown error."
            
            switch code {
            case Z_STREAM_ERROR: self = .stream(message: message)
            case Z_DATA_ERROR: self = .data(message: message)
            case Z_MEM_ERROR: self = .memory(message: message)
            case Z_BUF_ERROR: self = .buffer(message: message)
            case Z_VERSION_ERROR: self = .version(message: message)
            default: self = .unknown(message: message, code: Int(code))
            }
        }
    }
}

extension _Z_STREAM {
    
    private func _process(_ flag: Int32, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        try buffer.withUnsafeMutableBufferPointer { buf in
            
            repeat {
                
                stream.next_out = buf.baseAddress
                stream.avail_out = 4096
                
                let status = _z_stream_process(flag)
                
                guard status == Z_OK || status == Z_BUF_ERROR || status == Z_STREAM_END else { throw Error(code: status, msg: stream.msg) }
                
                callback(UnsafeBufferPointer(rebasing: buf.prefix(4096 - Int(stream.avail_out))))
                
            } while stream.avail_in != 0 || stream.avail_out == 0
        }
    }
    
    public func process(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        guard let _source = source.baseAddress, source.count != 0 else { return }
        
        stream.next_in = UnsafeMutablePointer<Bytef>(mutating: _source)
        stream.avail_in = uInt(source.count)
        
        try _process(Z_NO_FLUSH, callback)
    }
    
    public func final(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        stream.next_in = nil
        stream.avail_in = 0
        
        try _process(Z_FINISH, callback)
    }
}
