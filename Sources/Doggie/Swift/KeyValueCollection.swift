//
//  KeyValueCollection.swift
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

public protocol KeyValueCollection : Collection where Element == (key: Key, value: Value) {
    
    associatedtype Key: Equatable
    
    associatedtype Value
    
    associatedtype Keys: Collection = DefaultKeysCollection<Self> where Keys.Element == Key
    
    associatedtype Values: Collection = DefaultValuesCollection<Self> where Values.Element == Value
    
    var keys: Keys { get }
    
    var values: Values { get }
    
    func index(forKey key: Key) -> Index?
    
    subscript(key: Key) -> Value? { get }
    
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get }
}

extension KeyValueCollection where Keys == DefaultKeysCollection<Self> {
    
    @inlinable
    public var keys: Keys {
        return DefaultKeysCollection(self)
    }
}

extension KeyValueCollection where Values == DefaultValuesCollection<Self> {
    
    @inlinable
    public var values: Values {
        return DefaultValuesCollection(self)
    }
}

extension KeyValueCollection {
    
    @inlinable
    public subscript(key: Key) -> Value? {
        guard let index = self.index(forKey: key) else { return nil }
        return self[index].value
    }
    
    @inlinable
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        return self[key] ?? defaultValue()
    }
}

extension Dictionary: KeyValueCollection {
    
}

@_fixed_layout
public struct DefaultKeysCollection<Base: KeyValueCollection> : Collection, Equatable {
    
    public typealias Index = Base.Index
    
    public typealias Element = Base.Key
    
    @usableFromInline
    internal var base: Base
    
    @inlinable
    internal init(_ base: Base) {
        self.base = base
    }
    
    @inlinable
    public var startIndex: Index {
        return base.startIndex
    }
    
    @inlinable
    public var endIndex: Index {
        return base.endIndex
    }
    
    @inlinable
    public var count: Int {
        return base.count
    }
    
    @inlinable
    public subscript(position: Index) -> Element {
        return base[position].key
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        return base.index(after: i)
    }
    
    @inlinable
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        return base.index(i, offsetBy: n)
    }
    
    @inlinable
    public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
        return base.index(i, offsetBy: n, limitedBy: limit)
    }
    
    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        return base.distance(from: start, to: end)
    }
    
    @inlinable
    public var indices: Base.Indices {
        return base.indices
    }
    
    @inlinable
    public func contains(_ element: Base.Key) -> Bool {
        return base.index(forKey: element) != nil
    }
    
    @inlinable
    public static func == (lhs: DefaultKeysCollection, rhs: DefaultKeysCollection) -> Bool {
        
        if lhs.count != rhs.count {
            return false
        }
        
        for (key, _) in lhs.base where !rhs.contains(key) {
            return false
        }
        
        return true
    }
}

extension DefaultKeysCollection : BidirectionalCollection where Base : BidirectionalCollection {
    
    @inlinable
    public func index(before i: Index) -> Index {
        return base.index(before: i)
    }
}

extension DefaultKeysCollection : RandomAccessCollection where Base : RandomAccessCollection {
    
}

@_fixed_layout
public struct DefaultValuesCollection<Base: KeyValueCollection> : Collection {
    
    public typealias Index = Base.Index
    
    public typealias Element = Base.Value
    
    @usableFromInline
    internal var base: Base
    
    @inlinable
    internal init(_ base: Base) {
        self.base = base
    }
    
    @inlinable
    public var startIndex: Index {
        return base.startIndex
    }
    
    @inlinable
    public var endIndex: Index {
        return base.endIndex
    }
    
    @inlinable
    public var count: Int {
        return base.count
    }
    
    @inlinable
    public subscript(position: Index) -> Element {
        return base[position].value
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        return base.index(after: i)
    }
    
    @inlinable
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        return base.index(i, offsetBy: n)
    }
    
    @inlinable
    public func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? {
        return base.index(i, offsetBy: n, limitedBy: limit)
    }
    
    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        return base.distance(from: start, to: end)
    }
    
    @inlinable
    public var indices: Base.Indices {
        return base.indices
    }
}

extension DefaultValuesCollection : BidirectionalCollection where Base : BidirectionalCollection {
    
    @inlinable
    public func index(before i: Index) -> Index {
        return base.index(before: i)
    }
}

extension DefaultValuesCollection : RandomAccessCollection where Base : RandomAccessCollection {
    
}
