//
//  BrotliEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

public class BrotliEncoder: CompressionCodec {
    
    private class Stream {
        
        let ptr: OpaquePointer
        
        init() throws {
            guard let stream = BrotliEncoderCreateInstance(nil, nil, nil) else { throw Error.unknown }
            self.ptr = stream
        }
        
        deinit {
            BrotliEncoderDestroyInstance(ptr)
        }
    }
    
    private let stream: Stream
    
    public init(quality: Quality = .default, windowBits: WindowBits = .default, mode: Mode = .generic) throws {
        self.stream = try Stream()
        guard BrotliEncoderSetParameter(stream.ptr, BROTLI_PARAM_QUALITY, quality.rawValue) == BROTLI_TRUE else { throw Error.invalidParameter }
        guard BrotliEncoderSetParameter(stream.ptr, BROTLI_PARAM_LGWIN, windowBits.rawValue) == BROTLI_TRUE else { throw Error.invalidParameter }
        guard BrotliEncoderSetParameter(stream.ptr, BROTLI_PARAM_MODE, mode.rawValue) == BROTLI_TRUE else { throw Error.invalidParameter }
    }
}

extension BrotliEncoder {
    
    public enum Error: Swift.Error {
        
        case unknown
        
        case invalidParameter
    }
}

extension BrotliEncoder {
    
    private func _process(_ op: BrotliEncoderOperation, _ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        try buffer.withUnsafeMutableBufferPointer { buf in
            
            var next_in = source.baseAddress
            var avail_in = source.count
            
            repeat {
                
                var next_out = buf.baseAddress
                var avail_out = 4096
                
                let status = BrotliEncoderCompressStream(stream.ptr, op, &avail_in, &next_in, &avail_out, &next_out, nil)
                
                guard status == BROTLI_TRUE else { throw Error.unknown }
                
                try callback(UnsafeBufferPointer(rebasing: buf.prefix(4096 - avail_out)))
                
            } while avail_in != 0 || BrotliEncoderHasMoreOutput(stream.ptr) == BROTLI_TRUE
        }
    }
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        try _process(BROTLI_OPERATION_PROCESS, source, callback)
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        try _process(BROTLI_OPERATION_FINISH, UnsafeBufferPointer(start: nil, count: 0), callback)
    }
}

extension BrotliEncoder {
    
    public struct Quality: RawRepresentable, Hashable {
        
        public let rawValue: UInt32
        
        public init?(rawValue: UInt32) {
            let _max = UInt32(bitPattern: BROTLI_MAX_QUALITY)
            let _min = UInt32(bitPattern: BROTLI_MIN_QUALITY)
            guard _min..._max ~= rawValue else { return nil }
            self.rawValue = rawValue
        }
        
        public static let `default` = Quality(rawValue: UInt32(bitPattern: BROTLI_DEFAULT_QUALITY))!
        
        public static let max = Quality(rawValue: UInt32(bitPattern: BROTLI_MAX_QUALITY))!
        
        public static let min = Quality(rawValue: UInt32(bitPattern: BROTLI_MIN_QUALITY))!
    }
    
    public struct WindowBits: RawRepresentable, Hashable {
        
        public let rawValue: UInt32
        
        public init?(rawValue: UInt32) {
            let _max = UInt32(bitPattern: BROTLI_MAX_WINDOW_BITS)
            let _min = UInt32(bitPattern: BROTLI_MIN_WINDOW_BITS)
            guard _min..._max ~= rawValue else { return nil }
            self.rawValue = rawValue
        }
        
        public static let `default` = WindowBits(rawValue: UInt32(bitPattern: BROTLI_DEFAULT_WINDOW))!
        
        public static let max = WindowBits(rawValue: UInt32(bitPattern: BROTLI_MAX_WINDOW_BITS))!
        
        public static let min = WindowBits(rawValue: UInt32(bitPattern: BROTLI_MIN_WINDOW_BITS))!
    }
    
    public enum Mode: CaseIterable {
        
        case generic
        
        case text
        
        case font
    }
}

extension BrotliEncoder.Mode {
    
    var rawValue: UInt32 {
        switch self {
        case .generic: return BROTLI_MODE_GENERIC.rawValue
        case .text: return BROTLI_MODE_TEXT.rawValue
        case .font: return BROTLI_MODE_FONT.rawValue
        }
    }
}
