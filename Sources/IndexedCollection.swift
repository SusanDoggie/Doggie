//
//  IndexedCollection.swift
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

public struct IndexedIterator<C : Collection> : IteratorProtocol where C.Indices.Iterator.Element == C.Index {
    
    fileprivate let base: C
    fileprivate var indices: C.Indices.Iterator
    
    public mutating func next() -> (index: C.Index, element: C.Iterator.Element)? {
        if let index = indices.next() {
            return (index, base[index])
        }
        return nil
    }
}

public struct IndexedCollection<C : Collection> : Collection where C.Indices.Iterator.Element == C.Index {
    
    fileprivate let base: C
    
    public var startIndex: C.Index {
        return base.startIndex
    }
    public var endIndex: C.Index {
        return base.endIndex
    }
    
    public func index(after i: C.Index) -> C.Index {
        return base.index(after: i)
    }
    
    public var indices: C.Indices {
        return base.indices
    }
    
    public subscript(i: C.Index) -> (index: C.Index, element: C.Iterator.Element) {
        return (i, base[i])
    }
    
    public func makeIterator() -> IndexedIterator<C> {
        return IndexedIterator(base: base, indices: base.indices.makeIterator())
    }
}

public struct IndexedBidirectionalCollection<C : BidirectionalCollection> : BidirectionalCollection where C.Indices.Iterator.Element == C.Index {
    
    fileprivate let base: C
    
    public var startIndex: C.Index {
        return base.startIndex
    }
    public var endIndex: C.Index {
        return base.endIndex
    }
    
    public func index(after i: C.Index) -> C.Index {
        return base.index(after: i)
    }
    
    public func index(before i: C.Index) -> C.Index {
        return base.index(before: i)
    }
    
    public var indices: C.Indices {
        return base.indices
    }
    
    public subscript(i: C.Index) -> (index: C.Index, element: C.Iterator.Element) {
        return (i, base[i])
    }
    
    public func makeIterator() -> IndexedIterator<C> {
        return IndexedIterator(base: base, indices: base.indices.makeIterator())
    }
}

public struct IndexedRandomAccessCollection<C : RandomAccessCollection> : RandomAccessCollection where C.Indices.Iterator.Element == C.Index {
    
    fileprivate let base: C
    
    public var startIndex: C.Index {
        return base.startIndex
    }
    public var endIndex: C.Index {
        return base.endIndex
    }
    
    public func index(after i: C.Index) -> C.Index {
        return base.index(after: i)
    }
    
    public func index(before i: C.Index) -> C.Index {
        return base.index(before: i)
    }
    
    public func index(_ i: C.Index, offsetBy n: C.IndexDistance, limitedBy limit: C.Index) -> C.Index? {
        return base.index(i, offsetBy: n, limitedBy: limit)
    }
    
    public var indices: C.Indices {
        return base.indices
    }
    
    public subscript(i: C.Index) -> (index: C.Index, element: C.Iterator.Element) {
        return (i, base[i])
    }
    
    public func makeIterator() -> IndexedIterator<C> {
        return IndexedIterator(base: base, indices: base.indices.makeIterator())
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    public func indexed() -> IndexedCollection<Self> {
        return IndexedCollection(base: self)
    }
}
extension BidirectionalCollection where Indices.Iterator.Element == Index {
    
    public func indexed() -> IndexedBidirectionalCollection<Self> {
        return IndexedBidirectionalCollection(base: self)
    }
}
extension RandomAccessCollection where Indices.Iterator.Element == Index {
    
    public func indexed() -> IndexedRandomAccessCollection<Self> {
        return IndexedRandomAccessCollection(base: self)
    }
}
