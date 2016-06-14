//
//  Functional.swift
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

public extension Sequence {
    
    /// Returns the first element of `self`, or `nil` if `self` is empty.
    var first: Iterator.Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
}

public extension Array {
    
    var array: [Iterator.Element] {
        return self
    }
}

public extension Sequence {
    
    var array: [Iterator.Element] {
        return self as? [Iterator.Element] ?? Array(self)
    }
}

public extension Collection where Self == SubSequence {
    
    /// Returns sub-sequence of `self`.
    var slice: SubSequence {
        return self
    }
}

public extension Collection {
    
    /// Returns sub-sequence of `self`.
    var slice: SubSequence {
        return self as? SubSequence ?? self[startIndex..<endIndex]
    }
}

public extension AnyIterator {
    
    var any: AnyIterator<Element> {
        return self
    }
}

public extension AnySequence {
    
    var any: AnySequence<Element> {
        return self
    }
}

public extension AnyCollection {
    
    var any: AnyCollection<Element> {
        return self
    }
}

public extension AnyBidirectionalCollection {
    
    var any: AnyBidirectionalCollection<Element> {
        return self
    }
}

public extension AnyRandomAccessCollection {
    
    var any: AnyRandomAccessCollection<Element> {
        return self
    }
}

public extension IteratorProtocol {
    
    var any: AnyIterator<Element> {
        return self as? AnyIterator ?? AnyIterator(self)
    }
}

public extension Sequence {
    
    var any: AnySequence<Iterator.Element> {
        return self as? AnySequence ?? AnySequence(makeIterator)
    }
}

public extension Sequence where SubSequence : Sequence, SubSequence.Iterator.Element == Iterator.Element, SubSequence.SubSequence == SubSequence {
    
    var any: AnySequence<Iterator.Element> {
        return self as? AnySequence ?? AnySequence(self)
    }
}

public extension Collection where SubSequence : Collection, SubSequence.Iterator.Element == Iterator.Element, SubSequence.Index == Index, SubSequence.Indices : Collection, SubSequence.Indices.Iterator.Element == Index, SubSequence.Indices.Index == Index, SubSequence.Indices.SubSequence == SubSequence.Indices, SubSequence.SubSequence == SubSequence, Indices : Collection, Indices.Iterator.Element == Index, Indices.Index == Index, Indices.SubSequence == Indices {
    
    var any: AnyCollection<Iterator.Element> {
        return self as? AnyCollection ?? AnyCollection(self)
    }
}
public extension BidirectionalCollection where SubSequence : BidirectionalCollection, SubSequence.Iterator.Element == Iterator.Element, SubSequence.Index == Index, SubSequence.Indices : BidirectionalCollection, SubSequence.Indices.Iterator.Element == Index, SubSequence.Indices.Index == Index, SubSequence.Indices.SubSequence == SubSequence.Indices, SubSequence.SubSequence == SubSequence, Indices : BidirectionalCollection, Indices.Iterator.Element == Index, Indices.Index == Index, Indices.SubSequence == Indices {
    
    var any: AnyBidirectionalCollection<Iterator.Element> {
        return self as? AnyBidirectionalCollection ?? AnyBidirectionalCollection(self)
    }
}
public extension RandomAccessCollection where SubSequence : RandomAccessCollection, SubSequence.Iterator.Element == Iterator.Element, SubSequence.Index == Index, SubSequence.Indices : RandomAccessCollection, SubSequence.Indices.Iterator.Element == Index, SubSequence.Indices.Index == Index, SubSequence.Indices.SubSequence == SubSequence.Indices, SubSequence.SubSequence == SubSequence, Indices : RandomAccessCollection, Indices.Iterator.Element == Index, Indices.Index == Index, Indices.SubSequence == Indices {
    
    var any: AnyRandomAccessCollection<Iterator.Element> {
        return self as? AnyRandomAccessCollection ?? AnyRandomAccessCollection(self)
    }
}

public extension LazySequence {
    
    var any: LazySequence<AnySequence<Elements.Iterator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazySequence where Base.SubSequence : Sequence, Base.SubSequence.Iterator.Element == Base.Iterator.Element, Base.SubSequence.SubSequence == Base.SubSequence {
    
    var any: LazySequence<AnySequence<Base.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyCollection where Base.SubSequence : Collection, Base.SubSequence.Iterator.Element == Base.Iterator.Element, Base.SubSequence.Index == Base.Index, Base.SubSequence.Indices : Collection, Base.SubSequence.Indices.Iterator.Element == Base.Index, Base.SubSequence.Indices.Index == Base.Index, Base.SubSequence.Indices.SubSequence == Base.SubSequence.Indices, Base.SubSequence.SubSequence == Base.SubSequence, Base.Indices : Collection, Base.Indices.Iterator.Element == Base.Index, Base.Indices.Index == Base.Index, Base.Indices.SubSequence == Base.Indices {
    
    var any: LazyCollection<AnyCollection<Base.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyBidirectionalCollection where Base.SubSequence : BidirectionalCollection, Base.SubSequence.Iterator.Element == Base.Iterator.Element, Base.SubSequence.Index == Base.Index, Base.SubSequence.Indices : BidirectionalCollection, Base.SubSequence.Indices.Iterator.Element == Base.Index, Base.SubSequence.Indices.Index == Base.Index, Base.SubSequence.Indices.SubSequence == Base.SubSequence.Indices, Base.SubSequence.SubSequence == Base.SubSequence, Base.Indices : BidirectionalCollection, Base.Indices.Iterator.Element == Base.Index, Base.Indices.Index == Base.Index, Base.Indices.SubSequence == Base.Indices {
    
    var any: LazyCollection<AnyBidirectionalCollection<Base.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyRandomAccessCollection where Base.SubSequence : RandomAccessCollection, Base.SubSequence.Iterator.Element == Base.Iterator.Element, Base.SubSequence.Index == Base.Index, Base.SubSequence.Indices : RandomAccessCollection, Base.SubSequence.Indices.Iterator.Element == Base.Index, Base.SubSequence.Indices.Index == Base.Index, Base.SubSequence.Indices.SubSequence == Base.SubSequence.Indices, Base.SubSequence.SubSequence == Base.SubSequence, Base.Indices : RandomAccessCollection, Base.Indices.Iterator.Element == Base.Index, Base.Indices.Index == Base.Index, Base.Indices.SubSequence == Base.Indices {
    
    var any: LazyCollection<AnyRandomAccessCollection<Base.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension Sequence where Iterator.Element : Equatable {
    
    /// Return `true` if all of elements in `seq` is `x`.
    ///
    /// - Complexity: O(`self.count`).
    func all(_ x: Iterator.Element) -> Bool {
        
        for item in self where item != x {
            return false
        }
        return true
    }
}

public extension Sequence {
    
    /// Return `true` if all of elements in `seq` satisfies `predicate`.
    ///
    /// - Complexity: O(`self.count`).
    func all(where predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> Bool {
        
        for item in self where try !predicate(item) {
            return false
        }
        return true
    }
}

public extension Set {
    
    /// Return `true` if all of elements in `seq` is `x`.
    func all(_ x: Element) -> Bool {
        
        switch self.count {
        case 0:
            return true
        case 1:
            return self.first == x
        default:
            return false
        }
    }
}

public extension BidirectionalCollection {
    
    public func last(where predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        return try self.reversed().first(where: predicate)
    }
}

public extension Collection where Iterator.Element : Equatable {
    
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// initial elements.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    func prefixUntil(_ element: Iterator.Element) -> SubSequence {
        return self.prefix(upTo: self.index(of: element) ?? self.endIndex)
    }
}

public extension Collection {
    
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// initial elements.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    func prefixUntil(where predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
        return self.prefix(upTo: try self.index(where: predicate) ?? self.endIndex)
    }
}

public extension RandomAccessCollection where Iterator.Element : Equatable {
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// final elements of `self`.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    func suffixUntil(_ element: Iterator.Element) -> SubSequence {
        return self.suffix(from: self.reversed().index(of: element)?.base ?? self.startIndex)
    }
}

public extension RandomAccessCollection {
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// final elements of `self`.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    func suffixUntil(where predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
        return self.suffix(from: try self.reversed().index(where: predicate)?.base ?? self.startIndex)
    }
}

public extension RandomAccessCollection where Index : Strideable, Index.Stride : SignedInteger {
    
    func matchWith<C : BidirectionalCollection where C.Iterator.Element == Iterator.Element, C.IndexDistance == IndexDistance>(pattern: C, isEquivalent: @noescape (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> Index? {
        
        let pattern_count = pattern.count
        if count < pattern_count {
            return nil
        }
        let reverse_pattern = pattern.reversed()
        var cursor = self.index(startIndex, offsetBy: pattern_count - 1, limitedBy: endIndex) ?? endIndex
        while cursor < endIndex {
            let left = startIndex...cursor
            let pair = zip(left.reversed(), reverse_pattern)
            guard let not_match = try pair.first(where: { try !isEquivalent(self[$0], $1) }) else {
                return self.index(cursor, offsetBy: 1 - pattern_count)
            }
            if let pos = try reverse_pattern.dropFirst().index(of: { try isEquivalent(self[not_match.0], $0) }) {
                let offset = self.distance(from: reverse_pattern.startIndex, to: pos)
                cursor = self.index(not_match.0, offsetBy: offset, limit: endIndex)
            } else {
                cursor = self.index(not_match.0, offsetBy: pattern_count, limitedBy: endIndex) ?? endIndex
            }
        }
        if try self.reversed().starts(with: reverse_pattern, isEquivalent: isEquivalent) {
            return self.index(endIndex, offsetBy: -pattern_count)
        }
        return nil
    }
}

public extension RandomAccessCollection where Index : Strideable, Index.Stride : SignedInteger, Iterator.Element : Equatable {
    
    func matchWith<C : BidirectionalCollection where C.Iterator.Element == Iterator.Element, C.IndexDistance == IndexDistance>(pattern: C) -> Index? {
        return self.matchWith(pattern: pattern, isEquivalent: ==)
    }
}

public extension String {
    
    func hasPattern(pattern: String) -> Bool {
        return Array(characters).matchWith(pattern: Array(pattern.characters)) != nil
    }
}

public extension MutableCollection where Indices.Iterator.Element == Index {
    
    mutating func mutateEach(body: @noescape (inout Iterator.Element) throws -> ()) rethrows {
        for idx in self.indices {
            try body(&self[idx])
        }
    }
}

public struct OptionOneIterator<T> : IteratorProtocol, Sequence {
    
    private var value: T?
    
    public mutating func next() -> T? {
        let _value = value
        value = nil
        return _value
    }
}

public struct OptionOneCollection<T> : RandomAccessCollection {
    
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
    
    public func index(after i: Int) -> Int {
        precondition(i == startIndex)
        precondition(value != nil)
        return endIndex
    }
    
    public func index(before i: Int) -> Int {
        precondition(i != 0)
        precondition(i == endIndex)
        return startIndex
    }
    
    public func makeIterator() -> OptionOneIterator<T> {
        return OptionOneIterator(value: value)
    }
}

public extension Sequence {
    /// Returns an array containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     (1..<6).scan(0, combine: +) // [0, 1, 3, 6, 10, 15]
    ///
    /// - Complexity: O(N)
    func scan<R>(initial: R, combine: @noescape (R, Iterator.Element) throws -> R) rethrows -> [R] {
        var result = [initial]
        for x in self {
            result.append(try combine(result.last!, x))
        }
        return result
    }
}

public struct LazyScanIterator<Base: IteratorProtocol, Element> : IteratorProtocol, Sequence {
    
    private var nextElement: Element?
    private var base: Base
    private let combine: (Element, Base.Element) -> Element
    
    public mutating func next() -> Element? {
        return nextElement.map { result in
            nextElement = base.next().map { combine(result, $0) }
            return result
        }
    }
}

public struct LazyScanSequence<Base: Sequence, Element> : LazySequenceProtocol {
    
    private let initial: Element
    private let base: Base
    private let combine: (Element, Base.Iterator.Element) -> Element
    
    public func makeIterator() -> LazyScanIterator<Base.Iterator, Element> {
        return LazyScanIterator(nextElement: initial, base: base.makeIterator(), combine: combine)
    }
}

public extension LazySequence {
    /// Returns a sequence containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     Array((1..<6).lazy.scan(0, combine: +)) // [0, 1, 3, 6, 10, 15]
    ///
    /// - Complexity: O(1)
    func scan<R>(initial: R, combine: (R, Elements.Iterator.Element) -> R) -> LazyScanSequence<Elements, R> {
        return LazyScanSequence(initial: initial, base: self.elements, combine: combine)
    }
}

public struct ConcatIterator<G1: IteratorProtocol, G2: IteratorProtocol where G1.Element == G2.Element> : IteratorProtocol, Sequence {
    
    private var base1: G1
    private var base2: G2
    private var flag: Bool
    
    public mutating func next() -> G1.Element? {
        if flag {
            if let val = base1.next() {
                return val
            }
            flag = false
        }
        return base2.next()
    }
}

public struct ConcatSequence<S1 : Sequence, S2 : Sequence where S1.Iterator.Element == S2.Iterator.Element> : Sequence {
    
    private let base1: S1
    private let base2: S2
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: true)
    }
}

public struct ConcatCollectionIndex<I1 : Comparable, I2 : Comparable> : Comparable {
    private let currect1: I1
    private let currect2: I2
}

public func == <I1, I2>(lhs: ConcatCollectionIndex<I1, I2>, rhs: ConcatCollectionIndex<I1, I2>) -> Bool {
    return lhs.currect1 == rhs.currect1 && lhs.currect2 == rhs.currect2
}
public func < <I1, I2>(lhs: ConcatCollectionIndex<I1, I2>, rhs: ConcatCollectionIndex<I1, I2>) -> Bool {
    return (lhs.currect1, lhs.currect2) < (rhs.currect1, rhs.currect2)
}

public struct ConcatCollection<S1 : Collection, S2 : Collection where S1.Iterator.Element == S2.Iterator.Element> : Collection {
    
    public typealias Iterator = ConcatIterator<S1.Iterator, S2.Iterator>
    
    public typealias Index = ConcatCollectionIndex<S1.Index, S2.Index>
    
    private let base1: S1
    private let base2: S2
    
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
    
    public subscript(index: Index) -> S1.Iterator.Element {
        return index.currect1 != base1.endIndex ? base1[index.currect1] : base2[index.currect2]
    }
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: true)
    }
}

public struct ConcatBidirectionalCollection<S1 : BidirectionalCollection, S2 : BidirectionalCollection where S1.Iterator.Element == S2.Iterator.Element> : BidirectionalCollection {
    
    public typealias Iterator = ConcatIterator<S1.Iterator, S2.Iterator>
    
    public typealias Index = ConcatCollectionIndex<S1.Index, S2.Index>
    
    private let base1: S1
    private let base2: S2
    
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
    
    public subscript(index: Index) -> S1.Iterator.Element {
        return index.currect1 != base1.endIndex ? base1[index.currect1] : base2[index.currect2]
    }
    
    public func makeIterator() -> ConcatIterator<S1.Iterator, S2.Iterator> {
        return ConcatIterator(base1: base1.makeIterator(), base2: base2.makeIterator(), flag: true)
    }
}

public extension Sequence {
    
    func concat<S : Sequence where Iterator.Element == S.Iterator.Element>(with: S) -> ConcatSequence<Self, S> {
        return ConcatSequence(base1: self, base2: with)
    }
}

public extension Collection {
    
    func concat<S : Collection where Iterator.Element == S.Iterator.Element>(with: S) -> ConcatCollection<Self, S> {
        return ConcatCollection(base1: self, base2: with)
    }
}

public extension BidirectionalCollection {
    
    func concat<S : BidirectionalCollection where Iterator.Element == S.Iterator.Element>(with: S) -> ConcatBidirectionalCollection<Self, S> {
        return ConcatBidirectionalCollection(base1: self, base2: with)
    }
}

public extension LazySequence {
    
    func concat<S : Sequence where Base.Iterator.Element == S.Iterator.Element>(with: S) -> LazySequence<ConcatSequence<Base, S>> {
        return ConcatSequence(base1: self.elements, base2: with).lazy
    }
}

public extension LazyCollection {
    
    func concat<S : Collection where Base.Iterator.Element == S.Iterator.Element>(with: S) -> LazyCollection<ConcatCollection<Base, S>> {
        return ConcatCollection(base1: self.elements, base2: with).lazy
    }
}

public extension LazyBidirectionalCollection {
    
    func concat<S : BidirectionalCollection where Base.Iterator.Element == S.Iterator.Element>(with: S) -> LazyCollection<ConcatBidirectionalCollection<Base, S>> {
        return ConcatBidirectionalCollection(base1: self.elements, base2: with).lazy
    }
}

public extension LazySequence {
    
    func append(_ newElement: Base.Iterator.Element) -> LazySequence<ConcatSequence<Base, CollectionOfOne<Base.Iterator.Element>>> {
        return self.concat(with: CollectionOfOne(newElement))
    }
}

public extension LazyCollection {
    
    func append(_ newElement: Base.Iterator.Element) -> LazyCollection<ConcatCollection<Base, CollectionOfOne<Base.Iterator.Element>>> {
        return self.concat(with: CollectionOfOne(newElement))
    }
}

public extension LazyBidirectionalCollection {
    
    func append(_ newElement: Base.Iterator.Element) -> LazyCollection<ConcatBidirectionalCollection<Base, CollectionOfOne<Base.Iterator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

public extension Collection {
    
    func collect<Indices : Sequence where Index == Indices.Iterator.Element>(_ indices: Indices) -> [Iterator.Element] {
        return indices.map { self[$0] }
    }
}

public struct LazyGatherIterator<C: Collection, Indices: IteratorProtocol where C.Index == Indices.Element> : IteratorProtocol, Sequence {
    
    private var seq : C
    private var indices : Indices
    
    /// The type of element returned by `next()`.
    public typealias Element = C.Iterator.Element
    
    /// Advance to the next element and return it, or `nil` if no next
    /// element exists.
    ///
    /// - Requires: No preceding call to `self.next()` has returned `nil`.
    public mutating func next() -> Element? {
        return indices.next().map { seq[$0] }
    }
}

public struct LazyGatherSequence<C : Collection, Indices : Sequence where C.Index == Indices.Iterator.Element> : LazySequenceProtocol {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    public typealias Element = C.Iterator.Element
    
    private let _base: C
    private let _indices: Indices
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public struct LazyGatherCollection<C : Collection, Indices : Collection where C.Index == Indices.Iterator.Element> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyGatherIterator<C, Indices.Iterator>
    
    public typealias Index = Indices.Index
    public typealias Element = C.Iterator.Element
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Index) -> Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Index {
        return _indices.startIndex
    }
    public var endIndex : Index {
        return _indices.endIndex
    }
    
    public func index(after i: Index) -> Index {
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
    
    public typealias Index = Indices.Index
    public typealias Element = C.Iterator.Element
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Index) -> Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Index {
        return _indices.startIndex
    }
    public var endIndex : Index {
        return _indices.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
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
    
    public typealias Index = Indices.Index
    public typealias Element = C.Iterator.Element
    
    private let _base: C
    private let _indices: Indices
    
    public subscript(idx: Index) -> Element {
        return _base[_indices[idx]]
    }
    
    public var startIndex : Index {
        return _indices.startIndex
    }
    public var endIndex : Index {
        return _indices.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return _indices.index(before: i)
    }
    
    public var count : Indices.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
}

public extension LazyCollection {
    
    func collect<Indices : Sequence where Base.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherSequence<Base, Indices> {
        return LazyGatherSequence(_base: self.elements, _indices: indices)
    }
    
    func collect<Indices : Collection where Base.Index == Indices.Iterator.Element>(_ indices: Indices) -> LazyGatherCollection<Base, Indices> {
        return LazyGatherCollection(_base: self.elements, _indices: indices)
    }
}

public extension RandomAccessCollection {
    
    func slice(by maxLength: IndexDistance) -> [SubSequence] {
        return Array(self.lazy.slice(by: maxLength))
    }
}

public struct LazySliceSequence<Base : RandomAccessCollection> : IteratorProtocol, LazySequenceProtocol {
    
    private let base: Base
    private let maxLength: Base.IndexDistance
    private var currentIndex: Base.Index
    
    public mutating func next() -> Base.SubSequence? {
        
        if currentIndex != base.endIndex {
            let nextIndex = base.index(currentIndex, offsetBy: maxLength, limitedBy: base.endIndex) ?? base.endIndex
            let result = base[currentIndex..<nextIndex]
            currentIndex = nextIndex
            return result
        }
        return nil
    }
}

public extension LazyCollection where Base : RandomAccessCollection {
    
    func slice(by maxLength: Base.IndexDistance) -> LazySliceSequence<Base> {
        return LazySliceSequence(base: elements, maxLength: maxLength, currentIndex: elements.startIndex)
    }
}

public extension Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatSequence<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(self.suffix(from: subRange.upperBound))
    }
}

public extension Collection where SubSequence : Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatCollection<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(self.suffix(from: subRange.upperBound))
    }
}

public extension BidirectionalCollection where SubSequence : BidirectionalCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatBidirectionalCollection<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(self.suffix(from: subRange.upperBound))
    }
}

public extension LazyCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Base.Index>) -> LazySequence<ConcatSequence<Base.SubSequence, Base.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollection where Base.SubSequence : Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Base.Index>) -> LazyCollection<ConcatCollection<Base.SubSequence, Base.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyBidirectionalCollection where Base.SubSequence : BidirectionalCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Base.Index>) -> LazyCollection<ConcatBidirectionalCollection<Base.SubSequence, Base.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<S : Sequence where S.Iterator.Element == Elements.SubSequence.Iterator.Element>(_ subRange: Range<Elements.Index>, with newElements: S) -> LazySequence<ConcatSequence<ConcatSequence<Elements.SubSequence, S>, Elements.SubSequence>> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollection where Base.SubSequence : Collection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<C : Collection where C.Iterator.Element == Base.SubSequence.Iterator.Element>(_ subRange: Range<Base.Index>, with newElements: C) -> LazyCollection<ConcatCollection<ConcatCollection<Base.SubSequence, C>, Base.SubSequence>> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyBidirectionalCollection where Base.SubSequence : BidirectionalCollection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<C : BidirectionalCollection where C.Iterator.Element == Base.SubSequence.Iterator.Element>(_ subRange: Range<Base.Index>, with newElements: C) -> LazyCollection<ConcatBidirectionalCollection<ConcatBidirectionalCollection<Base.SubSequence, C>, Elements.SubSequence>> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension Sequence where Iterator.Element : Comparable {
    
    /// Returns the maximal `SubSequence`s of `self`, in order, around elements
    /// match in `separator`.
    ///
    /// - Parameter maxSplits: The maximum number of `SubSequence`s to
    ///   return, minus 1.
    ///   If `maxSplit + 1` `SubSequence`s are returned, the last one is
    ///   a suffix of `self` containing the remaining elements.
    ///   The default value is `Int.max`.
    ///
    /// - omittingEmptySubsequences: If `false`, an empty subsequence is
    ///   returned in the result for each pair of consecutive elements
    ///   satisfying the `isSeparator` predicate and for each element at the
    ///   start or end of the sequence satisfying the `isSeparator` predicate.
    ///   If `true`, only nonempty subsequences are returned. The default
    ///   value is `true`.
    ///
    /// - Requires: `maxSplit >= 0`
    func split<S: Sequence where S.Iterator.Element == Iterator.Element>(separator: S, maxSplit: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [SubSequence] {
        return self.split(maxSplits: maxSplit, omittingEmptySubsequences: omittingEmptySubsequences) { separator.contains($0) }
    }
}

public extension LazySequence {
    
    /// Return a `Sequence` containing tuples satisfies `predicate` with each elements of two `sources`.
    func merge<S : Sequence>(with: S, predicate: (Elements.Iterator.Element, S.Iterator.Element) -> Bool) -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<LazyFilterSequence<S>, (Elements.Iterator.Element, S.Iterator.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension LazyCollection {
    
    /// Return a `Collection` containing tuples satisfies `predicate` with each elements of two `sources`.
    func merge<C : Collection>(with: C, predicate: (Elements.Iterator.Element, C.Iterator.Element) -> Bool) -> LazyCollection<FlattenCollection<LazyMapCollection<Elements, LazyMapCollection<LazyFilterCollection<C>, (Elements.Iterator.Element, C.Iterator.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension Sequence {
    
    /// Return an `Array` containing tuples satisfies `predicate` with each elements of two `sources`.
    func merge<S : Sequence>(with: S, predicate: @noescape (Iterator.Element, S.Iterator.Element) throws -> Bool) rethrows -> [(Iterator.Element, S.Iterator.Element)] {
        var result: [(Iterator.Element, S.Iterator.Element)] = []
        for lhs in self {
            for rhs in with where try predicate(lhs, rhs) {
                result.append((lhs, rhs))
            }
        }
        return result
    }
}

public struct LazyChunkElementsIterator<Base : IteratorProtocol> : IteratorProtocol, Sequence {
    
    private var base: Base
    
    public mutating func next() -> Base.Element? {
        return base.next()
    }
}

public struct LazyChunkElementsSequence<Key : Equatable, Base : Sequence> : LazySequenceProtocol {
    
    public let key: Key
    private let base: Base
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsCollection<Key : Equatable, Base : Collection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsBidirectionalCollection<Key : Equatable, Base : BidirectionalCollection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        return base.index(before: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsRandomAccessCollection<Key : Equatable, Base : RandomAccessCollection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        return base.index(before: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public extension Collection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsSequence<Key, SubSequence>] {
        
        var table: [LazyChunkElementsSequence<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsSequence(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}

public extension Collection where SubSequence : Collection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}
public extension Collection where SubSequence : BidirectionalCollection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsBidirectionalCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsBidirectionalCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsBidirectionalCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}
public extension Collection where SubSequence : RandomAccessCollection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsRandomAccessCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsRandomAccessCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsRandomAccessCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}

public struct GroupElementsIterator<Element> : IteratorProtocol, Sequence {
    
    private var base: IndexingIterator<[Element]>
    
    public mutating func next() -> Element? {
        return base.next()
    }
}

public struct GroupElementsCollection<Key : Equatable, Element> : RandomAccessCollection {
    
    public typealias Iterator = GroupElementsIterator<Element>
    
    public let key: Key
    private var base: [Element]
    
    public var startIndex : Int {
        return base.startIndex
    }
    public var endIndex : Int {
        return base.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return base.index(after: i)
    }
    
    public func index(before i: Int) -> Int {
        return base.index(before: i)
    }
    
    public subscript(index: Int) -> Element {
        return base[index]
    }
    
    public var count : Int {
        return base.count
    }
    
    public func makeIterator() -> GroupElementsIterator<Element> {
        return GroupElementsIterator(base: base.makeIterator())
    }
    
    public var elements: [Element] {
        return base
    }
}

public extension Sequence {
    
    /// Groups the elements of a sequence according to a specified key selector function.
    func group<Key : Equatable>(_ by: @noescape (Iterator.Element) throws -> Key) rethrows -> [GroupElementsCollection<Key, Iterator.Element>] {
        
        var table: [GroupElementsCollection<Key, Iterator.Element>] = []
        for item in self {
            let key = try by(item)
            if let idx = table.index(where: { $0.key == key }) {
                table[idx].base.append(item)
            } else {
                table.append(GroupElementsCollection(key: key, base: [item]))
            }
        }
        return table
    }
}

public struct LazyUniqueIterator<Base : IteratorProtocol> : IteratorProtocol, Sequence {
    
    private var pass: [Base.Element]
    private var base: Base
    private let isEquivalent: (Base.Element, Base.Element) -> Bool
    
    public mutating func next() -> Base.Element? {
        while let val = base.next() {
            if !pass.contains({ isEquivalent($0, val) }) {
                pass.append(val)
                return val
            }
        }
        return nil
    }
}

public struct LazyUniqueSequence<Base : Sequence> : LazySequenceProtocol {
    
    private let base: Base
    private let isEquivalent: (Base.Iterator.Element, Base.Iterator.Element) -> Bool
    
    public func makeIterator() -> LazyUniqueIterator<Base.Iterator> {
        return LazyUniqueIterator(pass: [], base: base.makeIterator(), isEquivalent: isEquivalent)
    }
}

public extension Sequence where Iterator.Element : Equatable {
    
    func unique() -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where !result.contains(item) {
            result.append(item)
        }
        return result
    }
}

public extension Sequence {
    
    func unique(isEquivalent: @noescape (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where try !result.contains({ try isEquivalent($0, item) }) {
            result.append(item)
        }
        return result
    }
}

public extension LazySequence where Base.Iterator.Element : Equatable {
    
    func unique() -> LazyUniqueSequence<Base> {
        return LazyUniqueSequence(base: elements, isEquivalent: ==)
    }
}

public extension LazySequence {
    
    func unique(isEquivalent: (Base.Iterator.Element, Base.Iterator.Element) -> Bool) -> LazyUniqueSequence<Base> {
        return LazyUniqueSequence(base: elements, isEquivalent: isEquivalent)
    }
}

public extension Sequence {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    func minElement<R : Comparable>(by: @noescape (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
        return try self.min { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    func maxElement<R : Comparable>(by: @noescape (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
        return try self.max { try by($0) < by($1) }
    }
}

public extension MutableCollection {
    
    /// Return an `Array` containing the sorted elements of `source`.
    /// according to `by`.
    ///
    /// The sorting algorithm is not stable (can change the relative order of
    /// elements that compare equal).(mutable_variant:"sortInPlace")
    func sorted<R : Comparable>(by: @noescape (Iterator.Element) -> R) -> [Iterator.Element] {
        return self.sorted { by($0) < by($1) }
    }
}

public extension Comparable {
    
    func clamp(_ range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

public extension Float32 {
    
    static func random(includeOne: Bool = false) -> Float32 {
        if includeOne {
            return unsafeBitCast((0..<0x800000).randomElement()! + 0x3F800000 as UInt32, to: Float32.self) - 1
        }
        return unsafeBitCast((0..<0x7FFFFF).randomElement()! | 0x3F800000 as UInt32, to: Float32.self) - 1
    }
}

public extension Float64 {
    
    static func random(includeOne: Bool = false) -> Float64 {
        if includeOne {
            return unsafeBitCast((0..<0x10000000000000).randomElement()! + 0x3FF0000000000000 as UInt64, to: Float64.self) - 1
        }
        return unsafeBitCast((0..<0xFFFFFFFFFFFFF).randomElement()! | 0x3FF0000000000000 as UInt64, to: Float64.self) - 1
    }
}

public func random(_ range: ClosedRange<Float>) -> Float {
    let diff = range.upperBound - range.lowerBound
    return (Float.random(true) * diff) + range.lowerBound
}
public func random(_ range: ClosedRange<Double>) -> Double {
    let diff = range.upperBound - range.lowerBound
    return (Double.random(true) * diff) + range.lowerBound
}
public func random(_ range: Range<Float>) -> Float {
    let diff = range.upperBound - range.lowerBound
    return (Float.random() * diff) + range.lowerBound
}
public func random(_ range: Range<Double>) -> Double {
    let diff = range.upperBound - range.lowerBound
    return (Double.random() * diff) + range.lowerBound
}

public extension RandomAccessCollection {
    
    /// Returns a random element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(1).
    ///
    func randomElement() -> Iterator.Element? {
        let _count = UIntMax(self.count.toIntMax())
        switch _count {
        case 0: return nil
        case 1: return self[self.startIndex]
        default: return self[self.index(self.startIndex, offsetBy: numericCast(random_uniform(bound: _count)))]
        }
    }
}

public extension Collection {
    
    /// Return an `Array` containing the shuffled elements of `source`.(mutable_variant:"shuffleInPlace")
    func shuffle() -> [Iterator.Element] {
        var list = self.array
        list.shuffleInPlace()
        return list
    }
}

public extension RandomAccessCollection where Self : MutableCollection, Indices.Index == Index, Indices.SubSequence : RandomAccessCollection, Indices.SubSequence.Iterator.Element == Index {
    
    /// Shuffle `self` in-place.
    mutating func shuffleInPlace() {
        for i in self.indices.dropLast() {
            let j = self.indices.suffix(from: i).randomElement()!
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}

public extension RangeReplaceableCollection {
    
    mutating func replace<C : Collection where Iterator.Element == C.Iterator.Element>(with newElements: C) {
        self.replaceSubrange(startIndex..<endIndex, with: newElements)
    }
}

public extension BidirectionalCollection where Self : MutableCollection, Index : Strideable, Index.Stride : SignedInteger {
    
    private mutating func reverseInPlace(_ range: CountableRange<Index>) {
        var temp: Index?
        for (lhs, rhs) in zip(range, range.reversed()) {
            if lhs != rhs && temp != rhs {
                swap(&self[lhs], &self[rhs])
                temp = lhs
            } else {
                break
            }
        }
    }
    
    mutating func reverseInPlace() {
        self.reverseInPlace(startIndex..<endIndex)
    }
}

public extension BidirectionalCollection where Self : MutableCollection, Indices.SubSequence : BidirectionalCollection, Iterator.Element : Comparable, Indices.SubSequence.Iterator.Element == Index, Index : Strideable, Index.Stride : SignedInteger {
    
    func nextPermute() -> Self {
        var _self = self
        if !_self.isEmpty {
            if let k = _self.indices.dropLast().last(where: { _self[$0] < _self[_self.index(after: $0)] }) {
                let range = _self.index(after: k)..<_self.endIndex
                swap(&_self[k], &_self[range.last { _self[k] < _self[$0] }!])
                _self.reverseInPlace(range)
            } else {
                _self.reverseInPlace()
            }
        }
        return _self
    }
}
