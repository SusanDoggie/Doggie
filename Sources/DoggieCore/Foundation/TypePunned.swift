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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@inlinable
@inline(__always)
public func withUnsafeTypePunnedPointer<T, U, R>(of value: T, to: U.Type, do body: (UnsafePointer<U>) throws -> R) rethrows -> R {
    
    return try withUnsafePointer(to: value) {
        
        precondition(MemoryLayout<T>.stride % MemoryLayout<U>.stride == 0)
        
        let capacity = MemoryLayout<T>.stride / MemoryLayout<U>.stride
        
        return try $0.withMemoryRebound(to: U.self, capacity: capacity) { try body($0) }
    }
}

@inlinable
@inline(__always)
public func withUnsafeMutableTypePunnedPointer<T, U, R>(of value: inout T, to: U.Type, do body: (UnsafeMutablePointer<U>) throws -> R) rethrows -> R {
    
    return try withUnsafeMutablePointer(to: &value) {
        
        precondition(MemoryLayout<T>.stride % MemoryLayout<U>.stride == 0)
        
        let capacity = MemoryLayout<T>.stride / MemoryLayout<U>.stride
        
        return try $0.withMemoryRebound(to: U.self, capacity: capacity) { try body($0) }
    }
}

extension ContiguousBuffer {
    
    @inlinable
    @inline(__always)
    public func withUnsafeTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        
        return try withUnsafeBufferPointer {
            
            precondition(MemoryLayout<Element>.stride % MemoryLayout<T>.stride == 0)
            
            guard let baseAddress = $0.baseAddress else { return try body(UnsafeBufferPointer(start: nil, count: 0)) }
            
            let capacity = $0.count * MemoryLayout<Element>.stride / MemoryLayout<T>.stride
            
            return try baseAddress.withMemoryRebound(to: T.self, capacity: capacity) { try body(UnsafeBufferPointer(start: $0, count: capacity)) }
        }
    }
}

extension ContiguousMutableBuffer {
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableTypePunnedBufferPointer<T, R>(to: T.Type, _ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        
        return try withUnsafeMutableBufferPointer {
            
            precondition(MemoryLayout<Element>.stride % MemoryLayout<T>.stride == 0)
            
            guard let baseAddress = $0.baseAddress else {
                
                var buf = UnsafeMutableBufferPointer<T>(start: nil, count: 0)
                
                defer { precondition(buf.baseAddress == nil) }
                defer { precondition(buf.count == 0) }
                
                return try body(&buf)
            }
            
            let capacity = $0.count * MemoryLayout<Element>.stride / MemoryLayout<T>.stride
            
            return try baseAddress.withMemoryRebound(to: T.self, capacity: capacity) { baseAddress in
                
                var buf = UnsafeMutableBufferPointer(start: baseAddress, count: capacity)
                
                defer { precondition(buf.baseAddress == baseAddress) }
                defer { precondition(buf.count == capacity) }
                
                return try body(&buf)
            }
        }
    }
}
