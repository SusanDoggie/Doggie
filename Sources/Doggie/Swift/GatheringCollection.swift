//
//  GatheringCollection.swift
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

@_fixed_layout
public struct GatheringIterator<C: Collection, I: IteratorProtocol> : IteratorProtocol, Sequence where C.Index == I.Element {
    
    public let base : C
    
    @usableFromInline
    var indices: I
    
    @inlinable
    init(base: C, indices: I) {
        self.base = base
        self.indices = indices
    }
    
    public typealias Element = C.Element
    
    @inlinable
    public mutating func next() -> Element? {
        return indices.next().map { base[$0] }
    }
}

@_fixed_layout
public struct GatheringSequence<C : Collection, I : Sequence> : Sequence where C.Index == I.Element {
    
    public typealias Iterator = GatheringIterator<C, I.Iterator>
    
    public let base: C
    
    @usableFromInline
    let indices: I
    
    @inlinable
    init(base: C, indices: I) {
        self.base = base
        self.indices = indices
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return GatheringIterator(base: base, indices: indices.makeIterator())
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return indices.underestimatedCount
    }
}

@_fixed_layout
public struct GatheringCollection<C : Collection, I : Collection> : Collection where C.Index == I.Element {
    
    public typealias Iterator = GatheringIterator<C, I.Iterator>
    
    public let base: C
    
    @usableFromInline
    let _indices: I
    
    @inlinable
    init(base: C, indices: I) {
        self.base = base
        self._indices = indices
    }
    
    @inlinable
    public subscript(position: I.Index) -> C.Element {
        return base[_indices[position]]
    }
    
    @inlinable
    public var startIndex : I.Index {
        return _indices.startIndex
    }
    @inlinable
    public var endIndex : I.Index {
        return _indices.endIndex
    }
    
    @inlinable
    public var indices: I.Indices {
        return _indices.indices
    }
    
    @inlinable
    public func index(after i: I.Index) -> I.Index {
        return _indices.index(after: i)
    }
    
    @inlinable
    public func index(_ i: I.Index, offsetBy n: Int) -> I.Index {
        return _indices.index(i, offsetBy: n)
    }
    
    @inlinable
    public func index(_ i: I.Index, offsetBy n: Int, limitedBy limit: I.Index) -> I.Index? {
        return _indices.index(i, offsetBy: n, limitedBy: limit)
    }
    
    @inlinable
    public func distance(from start: I.Index, to end: I.Index) -> Int {
        return _indices.distance(from: start, to: end)
    }
    
    @inlinable
    public var count : Int {
        return _indices.count
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return GatheringIterator(base: base, indices: _indices.makeIterator())
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return _indices.underestimatedCount
    }
}

extension GatheringCollection : BidirectionalCollection where I : BidirectionalCollection {
    
    @inlinable
    public func index(before i: I.Index) -> I.Index {
        return _indices.index(before: i)
    }
    
}

extension GatheringCollection : RandomAccessCollection where I : RandomAccessCollection {
    
}

extension Collection {
    
    @inlinable
    public func collect<I>(_ indices: I) -> GatheringSequence<Self, I> {
        return GatheringSequence(base: self, indices: indices)
    }
    
    @inlinable
    public func collect<I>(_ indices: I) -> GatheringCollection<Self, I> {
        return GatheringCollection(base: self, indices: indices)
    }
}

extension LazyCollectionProtocol {
    
    @inlinable
    public func collect<I>(_ indices: I) -> LazySequence<GatheringSequence<Elements, I>> {
        return self.elements.collect(indices).lazy
    }
    
    @inlinable
    public func collect<I>(_ indices: I) -> LazyCollection<GatheringCollection<Elements, I>> {
        return self.elements.collect(indices).lazy
    }
}
