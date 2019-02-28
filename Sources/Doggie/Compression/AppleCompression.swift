//
//  AppleCompression.swift
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

#if canImport(Compression)

import Compression

@available(OSX 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *)
public class AppleCompression : CompressionCodec {
    
    private var stream: UnsafeMutablePointer<compression_stream>
    
    public init(_ operation: compression_stream_operation, _ algorithm: compression_algorithm) throws {
        
        self.stream = UnsafeMutablePointer.allocate(capacity: 1)
        
        guard compression_stream_init(stream, operation, algorithm) == COMPRESSION_STATUS_OK else {
            self.stream.deallocate()
            throw Error()
        }
    }
    
    deinit {
        compression_stream_destroy(stream)
        self.stream.deallocate()
    }
}

@available(OSX 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *)
extension AppleCompression {
    
    @_fixed_layout
    public struct Error : Swift.Error {
        
    }
}

@available(OSX 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *)
extension AppleCompression {
    
    private static let empty = [UInt8](repeating: 0, count: 4096)
    
    private func _process(_ flag: Int32, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        try buffer.withUnsafeMutableBufferPointer { buf in
            
            repeat {
                
                stream.pointee.dst_ptr = buf.baseAddress!
                stream.pointee.dst_size = 4096
                
                let status = compression_stream_process(stream, flag)
                
                guard status == COMPRESSION_STATUS_OK || status == COMPRESSION_STATUS_END else { throw Error() }
                
                callback(UnsafeBufferPointer(rebasing: buf.prefix(4096 - stream.pointee.dst_size)))
                
            } while stream.pointee.src_size != 0 || stream.pointee.dst_size == 0
        }
    }
    
    public func process(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        guard let _source = source.baseAddress, source.count != 0 else { return }
        
        stream.pointee.src_ptr = _source
        stream.pointee.src_size = source.count
        
        try _process(0, callback)
    }
    
    public func final(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        try AppleCompression.empty.withUnsafeBufferPointer { empty in
            
            stream.pointee.src_ptr = empty.baseAddress!
            stream.pointee.src_size = 0
            
            try _process(Int32(COMPRESSION_STREAM_FINALIZE.rawValue), callback)
        }
    }
}

#endif
