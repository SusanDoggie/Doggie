//
//  UnsafeBufferProtocol.swift
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

public protocol UnsafeBufferProtocol: RandomAccessCollection {
    
    func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R
}

public protocol UnsafeMutableBufferProtocol: UnsafeBufferProtocol, MutableCollection {
    
    mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R
}

extension Array: UnsafeMutableBufferProtocol {
    
}

extension ArraySlice: UnsafeMutableBufferProtocol {
    
}

extension ContiguousArray: UnsafeMutableBufferProtocol {
    
}

extension MappedBuffer: UnsafeMutableBufferProtocol {
    
}

extension UnsafeBufferPointer: UnsafeBufferProtocol {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        return try body(self)
    }
}

extension UnsafeMutableBufferPointer: UnsafeMutableBufferProtocol {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        return try body(UnsafeBufferPointer(self))
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        var copy = self
        defer { precondition(copy.baseAddress == baseAddress) }
        defer { precondition(copy.count == count) }
        return try body(&copy)
    }
}

extension Data: UnsafeMutableBufferProtocol {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<UInt8>) throws -> R) rethrows -> R {
        let count = self.count
        return try self.withUnsafeBytes { try body(UnsafeBufferPointer(start: $0, count: count)) }
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<UInt8>) throws -> R) rethrows -> R {
        
        let count = self.count
        
        return try self.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in
            
            var buf = UnsafeMutableBufferPointer(start: bytes, count: count)
            
            defer { precondition(buf.baseAddress == bytes) }
            defer { precondition(buf.count == count) }
            
            return try body(&buf)
        }
    }
}
