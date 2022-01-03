//
//  zlib.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public class _Z_STREAM: CompressionCodec {
    
    var stream: z_stream
    
    init() throws {
        self.stream = z_stream()
    }
    
    func _z_stream_process(_ flush: Int32) -> Int32 {
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
        
        init(code: Int32, msg: UnsafePointer<CChar>?) {
            
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
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        guard let _source = source.baseAddress, source.count != 0 else { return }
        
        stream.next_in = UnsafeMutablePointer<Bytef>(mutating: _source)
        stream.avail_in = uInt(source.count)
        
        try _process(Z_NO_FLUSH, callback)
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        stream.next_in = nil
        stream.avail_in = 0
        
        try _process(Z_FINISH, callback)
    }
}
