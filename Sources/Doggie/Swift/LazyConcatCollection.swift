//
//  LazyConcatCollection.swift
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
public struct ConcatIterator<G1: IteratorProtocol, G2: IteratorProtocol> : IteratorProtocol, Sequence where G1.Element == G2.Element {
    
    @usableFromInline
    var base1: G1
    
    @usableFromInline
    var base2: G2
    
    @usableFromInline
    var flag: Int
    
    @inlinable
    init(base1: G1, base2: G2, flag: Int) {
        self.base1 = base1
        self.base2 = base2
        self.flag = flag
    }
    
    @inlinable
    public mutating func next() -> G1.Element? {
        while true {
            switch flag {
            case 0:
                if let val = base1.next() {
                    return val
                }
                flag = 1
            case 1:
                if let val = base2.next() {
                    return val
                }
                flag = 2
            default: return nil
            }
        }
    }
}

@frozen
public struct LazyConcatSequence<S1 : Sequence, S2 : Sequence> : LazySequenceProtocol where S1.Element == S2.Element {
    
    @usableFromInline
    let base1: S1
    
    @usableFromInline
    let base2: S2
    
    @inlinable
    init(base1: S1, base2: S2) {
        self.base1 = base1
        self.base2 = base2
    }
    
    @inlinable
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: 0)
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return base1.underestimatedCount + base2.underestimatedCount
    }
    
    @inlinable
    public func _copyToContiguousArray() -> ContiguousArray<S1.Element> {
        var result = ContiguousArray<Element>()
        result.reserveCapacity(underestimatedCount)
        
        result.append(contentsOf: base1)
        result.append(contentsOf: base2)
        
        return result
    }
    
}

@frozen
public struct ConcatCollectionIndex<I1 : Comparable, I2 : Comparable> : Comparable {
    
    @usableFromInline
    let currect1: I1
    
    @usableFromInline
    let currect2: I2
    
    @inlinable
    init(currect1: I1, currect2: I2) {
        self.currect1 = currect1
        self.currect2 = currect2
    }
    
}

extension ConcatCollectionIndex : Hashable where I1 : Hashable, I2 : Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(currect1)
        hasher.combine(currect2)
    }
}

@inlinable
public func < <I1, I2>(lhs: ConcatCollectionIndex<I1, I2>, rhs: ConcatCollectionIndex<I1, I2>) -> Bool {
    return (lhs.currect1, lhs.currect2) < (rhs.currect1, rhs.currect2)
}

@frozen
public struct LazyConcatCollection<S1 : Collection, S2 : Collection> : LazyCollectionProtocol where S1.Element == S2.Element {
    
    public typealias Iterator = ConcatIterator<S1.Iterator, S2.Iterator>
    
    public typealias Index = ConcatCollectionIndex<S1.Index, S2.Index>
    
    @usableFromInline
    let base1: S1
    
    @usableFromInline
    let base2: S2
    
    @inlinable
    init(base1: S1, base2: S2) {
        self.base1 = base1
        self.base2 = base2
    }
    
    @inlinable
    public var startIndex : Index {
        return ConcatCollectionIndex(currect1: base1.startIndex, currect2: base2.startIndex)
    }
    
    @inlinable
    public var endIndex : Index {
        return ConcatCollectionIndex(currect1: base1.endIndex, currect2: base2.endIndex)
    }
    
    @inlinable
    public var count : Int {
        return base1.count + base2.count
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        if i.currect1 != base1.endIndex {
            return ConcatCollectionIndex(currect1: base1.index(after: i.currect1), currect2: i.currect2)
        }
        return ConcatCollectionIndex(currect1: i.currect1, currect2: base2.index(after: i.currect2))
    }
    
    @inlinable
    public subscript(position: Index) -> S1.Element {
        return position.currect1 != base1.endIndex ? base1[position.currect1] : base2[position.currect2]
    }
    
    @inlinable
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: 0)
    }
    
    @inlinable
    public func _copyToContiguousArray() -> ContiguousArray<S1.Element> {
        var result = ContiguousArray<Element>()
        result.reserveCapacity(underestimatedCount)
        
        result.append(contentsOf: base1)
        result.append(contentsOf: base2)
        
        return result
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return base1.underestimatedCount + base2.underestimatedCount
    }
}

extension LazyConcatCollection : BidirectionalCollection where S1 : BidirectionalCollection, S2 : BidirectionalCollection {
    
    @inlinable
    public func index(before i: Index) -> Index {
        if i.currect2 != base2.startIndex {
            return ConcatCollectionIndex(currect1: i.currect1, currect2: base2.index(before: i.currect2))
        }
        return ConcatCollectionIndex(currect1: base1.index(before: i.currect1), currect2: i.currect2)
    }
    
}

extension Sequence {
    
    @inlinable
    public func concat<S>(_ other: S) -> LazyConcatSequence<Self, S> {
        return LazyConcatSequence(base1: self, base2: other)
    }
}

extension Collection {
    
    @inlinable
    public func concat<S>(_ other: S) -> LazyConcatCollection<Self, S> {
        return LazyConcatCollection(base1: self, base2: other)
    }
}
