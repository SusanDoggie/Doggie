//
//  TypePunned.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@inlinable
public func withUnsafeTypePunnedPointer<T, U, R>(of value: T, to: U.Type, do body: (UnsafePointer<U>) throws -> R) rethrows -> R {
    
    return try withUnsafePointer(to: value) {
        
        precondition(MemoryLayout<T>.stride % MemoryLayout<U>.stride == 0)
        
        let capacity = MemoryLayout<T>.stride / MemoryLayout<U>.stride
        
        return try $0.withMemoryRebound(to: U.self, capacity: capacity) { try body($0) }
    }
}

@inlinable
public func withUnsafeMutableTypePunnedPointer<T, U, R>(of value: inout T, to: U.Type, do body: (UnsafeMutablePointer<U>) throws -> R) rethrows -> R {
    
    return try withUnsafeMutablePointer(to: &value) {
        
        precondition(MemoryLayout<T>.stride % MemoryLayout<U>.stride == 0)
        
        let capacity = MemoryLayout<T>.stride / MemoryLayout<U>.stride
        
        return try $0.withMemoryRebound(to: U.self, capacity: capacity) { try body($0) }
    }
}

extension UnsafeBufferPointer {
    
    @inlinable
    public func withUnsafeTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        
        precondition(MemoryLayout<Element>.stride % MemoryLayout<T>.stride == 0)
        
        guard let baseAddress = self.baseAddress else { return try body(UnsafeBufferPointer<T>(start: nil, count: 0)) }
        
        let capacity = self.count * MemoryLayout<Element>.stride / MemoryLayout<T>.stride
        
        return try baseAddress.withMemoryRebound(to: T.self, capacity: capacity) { try body(UnsafeBufferPointer<T>(start: $0, count: capacity)) }
    }
}

extension UnsafeMutableBufferPointer {
    
    @inlinable
    public mutating func withUnsafeMutableTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        
        precondition(MemoryLayout<Element>.stride % MemoryLayout<T>.stride == 0)
        
        guard let baseAddress = self.baseAddress else {
            
            var buf = UnsafeMutableBufferPointer<T>(start: nil, count: 0)
            
            defer { precondition(buf.baseAddress == nil) }
            defer { precondition(buf.count == 0) }
            
            return try body(&buf)
        }
        
        let capacity = self.count * MemoryLayout<Element>.stride / MemoryLayout<T>.stride
        
        return try baseAddress.withMemoryRebound(to: T.self, capacity: capacity) { baseAddress in
            
            var buf = UnsafeMutableBufferPointer<T>(start: baseAddress, count: capacity)
            
            defer { precondition(buf.baseAddress == baseAddress) }
            defer { precondition(buf.count == capacity) }
            
            return try body(&buf)
        }
    }
}

extension ContiguousBuffer {
    
    @inlinable
    public func withUnsafeTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        return try withUnsafeBufferPointer { try $0.withUnsafeTypePunnedBufferPointer(to: T.self, body) }
    }
    
}

extension ContiguousMutableBuffer {
    
    @inlinable
    public mutating func withUnsafeMutableTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        return try withUnsafeMutableBufferPointer { try $0.withUnsafeMutableTypePunnedBufferPointer(to: T.self, body) }
    }
}
