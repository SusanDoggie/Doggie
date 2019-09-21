//
//  IndexedCollection.swift
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

@frozen
public struct IndexedIterator<C : Collection> : IteratorProtocol {
    
    public let base: C
    
    @usableFromInline
    var indices: C.Indices.Iterator
    
    @inlinable
    init(base: C, indices: C.Indices.Iterator) {
        self.base = base
        self.indices = indices
    }
    
    @inlinable
    public mutating func next() -> (index: C.Index, element: C.Element)? {
        if let index = indices.next() {
            return (index, base[index])
        }
        return nil
    }
}

@frozen
public struct IndexedCollection<C : Collection> : Collection {
    
    public let base: C
    
    @inlinable
    public init(base: C) {
        self.base = base
    }
    
    @inlinable
    public var startIndex: C.Index {
        return base.startIndex
    }
    @inlinable
    public var endIndex: C.Index {
        return base.endIndex
    }
    
    @inlinable
    public var count : Int {
        return base.count
    }
    
    @inlinable
    public func index(after i: C.Index) -> C.Index {
        return base.index(after: i)
    }
    
    @inlinable
    public func index(_ i: C.Index, offsetBy n: Int) -> C.Index {
        return base.index(i, offsetBy: n)
    }
    
    @inlinable
    public func index(_ i: C.Index, offsetBy n: Int, limitedBy limit: C.Index) -> C.Index? {
        return base.index(i, offsetBy: n, limitedBy: limit)
    }
    
    @inlinable
    public func distance(from start: C.Index, to end: C.Index) -> Int {
        return base.distance(from: start, to: end)
    }
    
    @inlinable
    public var indices: C.Indices {
        return base.indices
    }
    
    @inlinable
    public subscript(i: C.Index) -> (index: C.Index, element: C.Element) {
        return (i, base[i])
    }
    
    @inlinable
    public func makeIterator() -> IndexedIterator<C> {
        return IndexedIterator(base: base, indices: base.indices.makeIterator())
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return base.underestimatedCount
    }
}

extension IndexedCollection : BidirectionalCollection where C : BidirectionalCollection {
    
    @inlinable
    public func index(before i: C.Index) -> C.Index {
        return base.index(before: i)
    }
    
}

extension IndexedCollection : RandomAccessCollection where C : RandomAccessCollection {
    
}

extension Collection {
    
    @inlinable
    public func indexed() -> IndexedCollection<Self> {
        return IndexedCollection(base: self)
    }
}
