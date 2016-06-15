//
//  OptionOneCollection.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public struct OptionOneIterator<T> : IteratorProtocol, Sequence {
    
    private var value: T?
    
    public mutating func next() -> T? {
        let _value = value
        value = nil
        return _value
    }
}

public struct OptionOneCollection<T> : RandomAccessCollection {
    
    public typealias Indices = CountableRange<Int>
    public typealias Index = Int
    
    public typealias Iterator = OptionOneIterator<T>
    
    private let value: T?
    
    public init(_ value: T?) {
        self.value = value
    }
    
    public var startIndex : Int {
        return 0
    }
    public var endIndex : Int {
        return value == nil ? 0 : 1
    }
    public subscript(idx: Int) -> T {
        return value!
    }
    
    public func makeIterator() -> OptionOneIterator<T> {
        return OptionOneIterator(value: value)
    }
}
