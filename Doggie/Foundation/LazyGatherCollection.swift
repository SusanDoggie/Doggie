//
//  LazyGatherCollection.swift
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

public extension Collection {
    
    func collect<Indices : Sequence where Index == Indices.Iterator.Element>(_ indices: Indices) -> [Iterator.Element] {
        return indices.map { self[$0] }
    }
}

public struct LazyGatherIterator<C: Collection, Indices: IteratorProtocol where C.Index == Indices.Element> : IteratorProtocol, Sequence {
    
    private var seq : C
    private var indices : Indices
    
    public typealias Element = C.Iterator.Element
    
    public mutating func next() -> Element? {
        return indices.next().map { seq[$0] }
    }
}

public struct LazyGatherSequence<C : Collection, Indices : Sequence where C.Index == Indices.Iterator.Element> : LazySequenceProtocol {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    private let _base: C
    private let _indices: Indices
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public struct LazyGatherCollection<C : Collection, Indices : Collection where C.Index == Indices.Iterator.Element> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Indices.Index) -> C.Iterator.Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Indices.Index {
        return _indices.startIndex
    }
    public var endIndex : Indices.Index {
        return _indices.endIndex
    }
    
    public func index(after i: Indices.Index) -> Indices.Index {
        return _indices.index(after: i)
    }
    
    public var count : Indices.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public struct LazyGatherBidirectionalCollection<C : Collection, Indices : BidirectionalCollection where C.Index == Indices.Iterator.Element> : LazyCollectionProtocol, BidirectionalCollection {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Indices.Index) -> C.Iterator.Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Indices.Index {
        return _indices.startIndex
    }
    public var endIndex : Indices.Index {
        return _indices.endIndex
    }
    
    public func index(after i: Indices.Index) -> Indices.Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: Indices.Index) -> Indices.Index {
        return _indices.index(before: i)
    }
    
    public var count : Indices.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public struct LazyGatherRandomAccessCollection<C : Collection, Indices : RandomAccessCollection where C.Index == Indices.Iterator.Element> : LazyCollectionProtocol, RandomAccessCollection {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Indices.Index) -> C.Iterator.Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Indices.Index {
        return _indices.startIndex
    }
    public var endIndex : Indices.Index {
        return _indices.endIndex
    }
    
    public func index(after i: Indices.Index) -> Indices.Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: Indices.Index) -> Indices.Index {
        return _indices.index(before: i)
    }
    
    public func index(_ i: Indices.Index, offsetBy n: Indices.IndexDistance) -> Indices.Index {
        return _indices.index(i, offsetBy: n)
    }
    
    public func distance(from start: Indices.Index, to end: Indices.Index) -> Indices.IndexDistance {
        return _indices.distance(from: start, to: end)
    }
    
    public var count : Indices.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public extension LazyCollectionProtocol {
    
    func collect<Indices : Sequence where Elements.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherSequence<Elements, Indices> {
        return LazyGatherSequence(_base: self.elements, _indices: indices)
    }
    
    func collect<Indices : Collection where Elements.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherCollection<Elements, Indices> {
        return LazyGatherCollection(_base: self.elements, _indices: indices)
    }
    
    func collect<Indices : BidirectionalCollection where Elements.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherBidirectionalCollection<Elements, Indices> {
        return LazyGatherBidirectionalCollection(_base: self.elements, _indices: indices)
    }
    
    func collect<Indices : RandomAccessCollection where Elements.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherRandomAccessCollection<Elements, Indices> {
        return LazyGatherRandomAccessCollection(_base: self.elements, _indices: indices)
    }
}
