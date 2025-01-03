//
//  AppleCompression.swift
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

#if canImport(Compression)

public class AppleCompression: CompressionCodec {
    
    private var stream: compression_stream
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public convenience init(_ operation: Compression.FilterOperation, _ algorithm: Compression.Algorithm) throws {
        try self.init(operation.rawValue, algorithm.rawValue)
    }
    
    public init(_ operation: compression_stream_operation, _ algorithm: compression_algorithm) throws {
        
        self.stream = compression_stream(
            dst_ptr: UnsafeMutablePointer<UInt8>(bitPattern: -1)!,
            dst_size: 0,
            src_ptr: UnsafeMutablePointer<UInt8>(bitPattern: -1)!,
            src_size: 0,
            state: nil)
        
        guard compression_stream_init(&stream, operation, algorithm) == COMPRESSION_STATUS_OK else { throw Error() }
    }
    
    deinit {
        compression_stream_destroy(&stream)
    }
}

extension AppleCompression {
    
    @frozen
    public struct Error: Swift.Error {
        
    }
}

extension AppleCompression {
    
    private static let empty = [UInt8](repeating: 0, count: 4096)
    
    private func _process(_ flag: Int32, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        try buffer.withUnsafeMutableBufferPointer { buf in
            
            repeat {
                
                stream.dst_ptr = buf.baseAddress!
                stream.dst_size = 4096
                
                let status = compression_stream_process(&stream, flag)
                
                guard status == COMPRESSION_STATUS_OK || status == COMPRESSION_STATUS_END else { throw Error() }
                
                try callback(UnsafeBufferPointer(rebasing: buf.prefix(4096 - stream.dst_size)))
                
            } while stream.src_size != 0 || stream.dst_size == 0
        }
    }
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        guard let _source = source.baseAddress, source.count != 0 else { return }
        
        stream.src_ptr = _source
        stream.src_size = source.count
        
        try _process(0, callback)
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        try AppleCompression.empty.withUnsafeBufferPointer { empty in
            
            stream.src_ptr = empty.baseAddress!
            stream.src_size = 0
            
            try _process(Int32(COMPRESSION_STREAM_FINALIZE.rawValue), callback)
        }
    }
}

#endif
