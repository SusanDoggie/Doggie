//
//  TypedData.swift
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

@_fixed_layout
public struct TypedData<T> : RandomAccessCollection {
    
    public var data: Data
    
    @inlinable
    @inline(__always)
    public init(data: Data) {
        self.data = data
    }
}

extension TypedData {
    
    @inlinable
    @inline(__always)
    public var startIndex: Int {
        return 0
    }
    
    @inlinable
    @inline(__always)
    public var endIndex: Int {
        return data.count / MemoryLayout<T>.stride
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Int) -> T {
        precondition(self.indices ~= position, "Index out of range.")
        return data.load(fromByteOffset: position * MemoryLayout<T>.stride, as: T.self)
    }
}

extension Data {
    
    @inlinable
    @inline(__always)
    public func typed<T>(as: T.Type) -> TypedData<T> {
        return TypedData(data: self)
    }
}
