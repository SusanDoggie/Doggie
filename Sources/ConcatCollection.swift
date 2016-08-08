//
//  ConcatCollection.swift
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

public struct ConcatIterator<G1: IteratorProtocol, G2: IteratorProtocol> : IteratorProtocol, Sequence where G1.Element == G2.Element {
    
    fileprivate var base1: G1
    fileprivate var base2: G2
    fileprivate var flag: Int
    
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

public struct ConcatSequence<S1 : Sequence, S2 : Sequence> : Sequence where S1.Iterator.Element == S2.Iterator.Element {
    
    fileprivate let base1: S1
    fileprivate let base2: S2
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: 0)
    }
}

public struct ConcatCollectionIndex<I1 : Comparable, I2 : Comparable> : Comparable {
    fileprivate let currect1: I1
    fileprivate let currect2: I2
}

public func == <I1, I2>(lhs: ConcatCollectionIndex<I1, I2>, rhs: ConcatCollectionIndex<I1, I2>) -> Bool {
    return lhs.currect1 == rhs.currect1 && lhs.currect2 == rhs.currect2
}
public func < <I1, I2>(lhs: ConcatCollectionIndex<I1, I2>, rhs: ConcatCollectionIndex<I1, I2>) -> Bool {
    return (lhs.currect1, lhs.currect2) < (rhs.currect1, rhs.currect2)
}

public struct ConcatCollection<S1 : Collection, S2 : Collection> : Collection where S1.Iterator.Element == S2.Iterator.Element {
    
    public typealias Iterator = ConcatIterator<S1.Iterator, S2.Iterator>
    
    public typealias Index = ConcatCollectionIndex<S1.Index, S2.Index>
    
    fileprivate let base1: S1
    fileprivate let base2: S2
    
    public var startIndex : Index {
        return ConcatCollectionIndex(currect1: base1.startIndex, currect2: base2.startIndex)
    }
    
    public var endIndex : Index {
        return ConcatCollectionIndex(currect1: base1.endIndex, currect2: base2.endIndex)
    }
    
    public func index(after i: Index) -> Index {
        if i.currect1 != base1.endIndex {
            return ConcatCollectionIndex(currect1: base1.index(after: i.currect1), currect2: i.currect2)
        }
        return ConcatCollectionIndex(currect1: i.currect1, currect2: base2.index(after: i.currect2))
    }
    
    public subscript(position: Index) -> S1.Iterator.Element {
        return position.currect1 != base1.endIndex ? base1[position.currect1] : base2[position.currect2]
    }
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: 0)
    }
}

public struct ConcatBidirectionalCollection<S1 : BidirectionalCollection, S2 : BidirectionalCollection> : BidirectionalCollection where S1.Iterator.Element == S2.Iterator.Element {
    
    public typealias Iterator = ConcatIterator<S1.Iterator, S2.Iterator>
    
    public typealias Index = ConcatCollectionIndex<S1.Index, S2.Index>
    
    fileprivate let base1: S1
    fileprivate let base2: S2
    
    public var startIndex : Index {
        return ConcatCollectionIndex(currect1: base1.startIndex, currect2: base2.startIndex)
    }
    
    public var endIndex : Index {
        return ConcatCollectionIndex(currect1: base1.endIndex, currect2: base2.endIndex)
    }
    
    public func index(after i: Index) -> Index {
        if i.currect1 != base1.endIndex {
            return ConcatCollectionIndex(currect1: base1.index(after: i.currect1), currect2: i.currect2)
        }
        return ConcatCollectionIndex(currect1: i.currect1, currect2: base2.index(after: i.currect2))
    }
    
    public func index(before i: Index) -> Index {
        if i.currect2 != base2.startIndex {
            return ConcatCollectionIndex(currect1: i.currect1, currect2: base2.index(before: i.currect2))
        }
        return ConcatCollectionIndex(currect1: base1.index(before: i.currect1), currect2: i.currect2)
    }
    
    public subscript(position: Index) -> S1.Iterator.Element {
        return position.currect1 != base1.endIndex ? base1[position.currect1] : base2[position.currect2]
    }
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: 0)
    }
}

public extension Sequence {
    
    func concat<S : Sequence>(_ with: S) -> ConcatSequence<Self, S> where Iterator.Element == S.Iterator.Element {
        return ConcatSequence(base1: self, base2: with)
    }
}

public extension Collection {
    
    func concat<S : Collection>(_ with: S) -> ConcatCollection<Self, S> where Iterator.Element == S.Iterator.Element {
        return ConcatCollection(base1: self, base2: with)
    }
}

public extension BidirectionalCollection {
    
    func concat<S : BidirectionalCollection>(_ with: S) -> ConcatBidirectionalCollection<Self, S> where Iterator.Element == S.Iterator.Element {
        return ConcatBidirectionalCollection(base1: self, base2: with)
    }
}

public extension LazySequenceProtocol {
    
    func concat<S : Sequence>(_ with: S) -> LazySequence<ConcatSequence<Elements, S>> where Elements.Iterator.Element == S.Iterator.Element {
        return ConcatSequence(base1: self.elements, base2: with).lazy
    }
}

public extension LazyCollectionProtocol {
    
    func concat<S : Collection>(_ with: S) -> LazyCollection<ConcatCollection<Elements, S>> where Elements.Iterator.Element == S.Iterator.Element {
        return ConcatCollection(base1: self.elements, base2: with).lazy
    }
}

public extension LazyCollectionProtocol where Elements : BidirectionalCollection {
    
    func concat<S : BidirectionalCollection>(_ with: S) -> LazyCollection<ConcatBidirectionalCollection<Elements, S>> where Elements.Iterator.Element == S.Iterator.Element {
        return ConcatBidirectionalCollection(base1: self.elements, base2: with).lazy
    }
}
