//
//  ByteOutputStream.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

@_fixed_layout
public class ByteOutputStream {
    
    @_versioned
    let sink: (UnsafeRawBufferPointer) -> Void
    
    public private(set) var count: Int
    
    @_inlineable
    public init(_ sink: @escaping (UnsafeRawBufferPointer) -> Void) {
        self.sink = sink
        self.count = 0
    }
}

extension ByteOutputStream {
    
    @_inlineable
    public func write(_ bytes: UnsafeRawBufferPointer) {
        sink(bytes)
        count += bytes.count
    }
}

extension ByteOutputStream {
    
    @_inlineable
    public func write<T: ByteEncodable>(_ value: T) {
        value.encode(to: self)
    }
    
    @_inlineable
    public func write<Buffer: UnsafeBufferProtocol>(_ buffer: Buffer) where Buffer.Element == UInt8 {
        buffer.withUnsafeBufferPointer { self.write(UnsafeRawBufferPointer($0)) }
    }
    
    @_inlineable
    public func write<T: ByteEncodable>(_ first: T, _ second: T, _ remains: T...) {
        first.encode(to: self)
        second.encode(to: self)
        for value in remains {
            value.encode(to: self)
        }
    }
}
