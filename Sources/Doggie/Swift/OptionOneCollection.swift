//
//  OptionOneCollection.swift
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

@frozen
public struct OptionOneCollection<T> : RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public var value: T?
    
    @inlinable
    public init(_ value: T?) {
        self.value = value
    }
    
    @inlinable
    public var startIndex : Int {
        return 0
    }
    @inlinable
    public var endIndex : Int {
        return value == nil ? 0 : 1
    }
    @inlinable
    public var count : Int {
        return value == nil ? 0 : 1
    }
    
    @inlinable
    public subscript(position: Int) -> T {
        set {
            precondition(value != nil && position == 0, "Index out of range.")
            return value!
        }
        get {
            precondition(value != nil && position == 0, "Index out of range.")
            value = newValue
        }
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return value == nil ? 0 : 1
    }
}

extension OptionOneCollection: Equatable where T : Equatable {
    
}

extension OptionOneCollection: Hashable where T : Hashable {
    
}

extension OptionOneCollection : ContiguousBytes where Element == UInt8 {
    
    @inlinable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try value.map { try Swift.withUnsafeBytes(of: $0) { try body($0) } } ?? body(UnsafeRawBufferPointer(start: nil, count: 0))
    }
}

extension OptionOneCollection : DataProtocol where Element == UInt8 {
    
    @inlinable
    public var regions: CollectionOfOne<OptionOneCollection<UInt8>> {
        return CollectionOfOne(self)
    }
}
