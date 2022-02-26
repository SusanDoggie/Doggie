//
//  BrotliDecoder.swift
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

public class BrotliDecoder: CompressionCodec {
    
    private let stream: OpaquePointer
    
    public init() throws {
        guard let stream = BrotliDecoderCreateInstance(nil, nil, nil) else { throw Error.unknown }
        self.stream = stream
    }
    
    deinit {
        BrotliDecoderDestroyInstance(stream)
    }
}

extension BrotliDecoder {
    
    public enum Error: Swift.Error {
        
        case unknown
        
        case message(code: BrotliDecoderErrorCode, message: String)
        
        init(code: BrotliDecoderErrorCode) {
            self = BrotliDecoderErrorString(code).map { .message(code: code, message: String(cString: $0)) } ?? .unknown
        }
    }
}

extension BrotliDecoder {
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        try buffer.withUnsafeMutableBufferPointer { buf in
            
            var next_in = source.baseAddress
            var avail_in = source.count
            
            repeat {
                
                var next_out = buf.baseAddress
                var avail_out = 4096
                
                let status = BrotliDecoderDecompressStream(stream, &avail_in, &next_in, &avail_out, &next_out, nil)
                
                guard status != BROTLI_DECODER_RESULT_ERROR else { throw Error(code: BrotliDecoderGetErrorCode(stream)) }
                
                try callback(UnsafeBufferPointer(rebasing: buf.prefix(4096 - avail_out)))
                
            } while avail_in != 0 || BrotliDecoderHasMoreOutput(stream) == BROTLI_TRUE
        }
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        try update(UnsafeBufferPointer(start: nil, count: 0), callback)
    }
}
