//
//  CollectionExtension.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public extension Sequence where Iterator.Element : Equatable {
    
    /// Return `true` if all of elements in `seq` is `x`.
    ///
    /// - complexity: O(`self.count`).
    public func all(_ x: Iterator.Element) -> Bool {
        
        for item in self where item != x {
            return false
        }
        return true
    }
}

public extension Sequence {
    
    /// Return `true` if all of elements in `seq` satisfies `predicate`.
    ///
    /// - complexity: O(`self.count`).
    public func all(where predicate: (Iterator.Element) throws -> Bool) rethrows -> Bool {
        
        for item in self where try !predicate(item) {
            return false
        }
        return true
    }
}

public extension Set {
    
    /// Return `true` if all of elements in `seq` is `x`.
    ///
    /// - complexity: O(1).
    public func all(_ x: Element) -> Bool {
        
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

public extension Collection {
    
    public func count(where predicate: (Iterator.Element) throws -> Bool) rethrows -> IndexDistance {
        var counter: IndexDistance = 0
        for item in self where try predicate(item) {
            counter = counter + 1
        }
        return counter
    }
}

public extension RandomAccessCollection {
    
    public func indexMod(_ index: Index) -> Index {
        let count = self.count
        let offset = distance(from: startIndex, to: index) % count
        return self.index(startIndex, offsetBy: offset < 0 ? offset + count : offset)
    }
}

public extension BidirectionalCollection {
    
    /// Returns the last element of the sequence that satisfies the given
    /// predicate or nil if no such element is found.
    ///
    /// - parameter where: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: The last match or `nil` if there was no match.
    public func last(where predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        return try self.reversed().first(where: predicate)
    }
}

public extension Collection where Iterator.Element : Equatable {
    
    public func drop(until element: Iterator.Element) -> SubSequence {
        return self.drop(while: { $0 != element })
    }
    
    public func prefix(until element: Iterator.Element) -> SubSequence {
        return self.prefix(while: { $0 != element })
    }
}

public extension RandomAccessCollection where Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index {
    
    /// Returns first range of `pattern` appear in `self`, or `nil` if not match.
    ///
    /// - complexity: Amortized O(`self.count`)
    public func range<C : RandomAccessCollection>(of pattern: C, where isEquivalent: (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> Range<Index>? where C.Iterator.Element == Iterator.Element {
        
        let pattern_count: IndexDistance = numericCast(pattern.count)
        if count < pattern_count {
            return nil
        }
        let reverse_pattern = pattern.reversed()
        var cursor = self.index(startIndex, offsetBy: pattern_count - 1, limitedBy: endIndex) ?? endIndex
        while cursor < endIndex {
            guard let not_match = try zip(self.indices.prefix(through: cursor).reversed(), reverse_pattern).first(where: { try !isEquivalent(self[$0], $1) }) else {
                let strat = self.index(cursor, offsetBy: 1 - pattern_count)
                let end = self.index(cursor, offsetBy: 1)
                return strat..<end
            }
            let notMatchValue = self[not_match.0]
            if let pos = try reverse_pattern.dropFirst().index(where: { try isEquivalent(notMatchValue, $0) }) {
                cursor = self.index(not_match.0, offsetBy: numericCast(reverse_pattern.distance(from: reverse_pattern.startIndex, to: pos)), limitedBy: endIndex) ?? endIndex
            } else {
                cursor = self.index(not_match.0, offsetBy: pattern_count, limitedBy: endIndex) ?? endIndex
            }
        }
        if try self.reversed().starts(with: reverse_pattern, by: isEquivalent) {
            let strat = self.index(endIndex, offsetBy: -pattern_count)
            return strat..<endIndex
        }
        return nil
    }
}

public extension RandomAccessCollection where Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index, Iterator.Element : Equatable {
    
    /// Returns first range of `pattern` appear in `self`, or `nil` if not match.
    ///
    /// - complexity: Amortized O(`self.count`)
    public func range<C : RandomAccessCollection>(of pattern: C) -> Range<Index>? where C.Iterator.Element == Iterator.Element {
        return self.range(of: pattern, where: ==)
    }
}

public extension MutableCollection where Indices.Iterator.Element == Index {
    
    public mutating func mutateEach(body: (inout Iterator.Element) throws -> ()) rethrows {
        for idx in self.indices {
            try body(&self[idx])
        }
    }
}

public typealias LazyAppendSequence<Elements : Sequence> = LazySequence<ConcatSequence<Elements, CollectionOfOne<Elements.Iterator.Element>>>
public typealias LazyAppendCollection<Elements : Collection> = LazyCollection<ConcatCollection<Elements, CollectionOfOne<Elements.Iterator.Element>>>
public typealias LazyAppendBidirectionalCollection<Elements : BidirectionalCollection> = LazyBidirectionalCollection<ConcatBidirectionalCollection<Elements, CollectionOfOne<Elements.Iterator.Element>>>

public extension LazySequenceProtocol {
    
    public func append(_ newElement: Elements.Iterator.Element) -> LazyAppendSequence<Elements> {
        return self.elements.concat(CollectionOfOne(newElement)).lazy
    }
}

public extension LazyCollectionProtocol {
    
    public func append(_ newElement: Elements.Iterator.Element) -> LazyAppendCollection<Elements> {
        return self.elements.concat(CollectionOfOne(newElement)).lazy
    }
}

public extension LazyCollectionProtocol where Elements : BidirectionalCollection {
    
    public func append(_ newElement: Elements.Iterator.Element) -> LazyAppendBidirectionalCollection<Elements> {
        return self.elements.concat(CollectionOfOne(newElement)).lazy
    }
}

public typealias LazyDropRangeSequence<Elements : Sequence> = LazySequence<ConcatSequence<Elements, Elements>>
public typealias LazyDropRangeCollection<Elements : Collection> = LazyCollection<ConcatCollection<Elements, Elements>>
public typealias LazyDropRangeBidirectionalCollection<Elements : BidirectionalCollection> = LazyBidirectionalCollection<ConcatBidirectionalCollection<Elements, Elements>>

public extension LazyCollectionProtocol {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    public func dropRange(_ subRange: Range<Elements.Index>) -> LazyDropRangeSequence<Elements.SubSequence> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    public func dropRange(_ subRange: Range<Elements.Index>) -> LazyDropRangeCollection<Elements.SubSequence> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : BidirectionalCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    public func dropRange(_ subRange: Range<Elements.Index>) -> LazyDropRangeBidirectionalCollection<Elements.SubSequence> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    public func replaceRange<S : Sequence>(_ subRange: Range<Elements.Index>, with newElements: S) -> LazySequence<ConcatSequence<ConcatSequence<Elements.SubSequence, S>, Elements.SubSequence>> where S.Iterator.Element == Elements.SubSequence.Iterator.Element {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : Collection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    public func replaceRange<C : Collection>(_ subRange: Range<Elements.Index>, with newElements: C) -> LazyCollection<ConcatCollection<ConcatCollection<Elements.SubSequence, C>, Elements.SubSequence>> where C.Iterator.Element == Elements.SubSequence.Iterator.Element {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : BidirectionalCollection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    public func replaceRange<C : BidirectionalCollection>(_ subRange: Range<Elements.Index>, with newElements: C) -> LazyBidirectionalCollection<ConcatBidirectionalCollection<ConcatBidirectionalCollection<Elements.SubSequence, C>, Elements.SubSequence>> where C.Iterator.Element == Elements.SubSequence.Iterator.Element {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(newElements).concat(self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public typealias LazyRotateSequence<Elements : Sequence> = LazySequence<ConcatSequence<Elements, Elements>>
public typealias LazyRotateCollection<Elements : Collection> = LazyCollection<ConcatCollection<Elements, Elements>>
public typealias LazyRotateBidirectionalCollection<Elements : BidirectionalCollection> = LazyBidirectionalCollection<ConcatBidirectionalCollection<Elements, Elements>>

public extension LazyCollectionProtocol where Elements.Iterator.Element == Elements.SubSequence.Iterator.Element {
    
    public func rotated(_ n: Int) -> LazyRotateSequence<Elements.SubSequence> {
        return self.elements.dropFirst(n).concat(self.elements.prefix(n)).lazy
    }
}
public extension LazyCollectionProtocol where Elements.SubSequence : Collection, Elements.Iterator.Element == Elements.SubSequence.Iterator.Element {
    
    public func rotated(_ n: Int) -> LazyRotateCollection<Elements.SubSequence> {
        return self.elements.dropFirst(n).concat(self.elements.prefix(n)).lazy
    }
}
public extension LazyCollectionProtocol where Elements.SubSequence : BidirectionalCollection, Elements.Iterator.Element == Elements.SubSequence.Iterator.Element {
    
    public func rotated(_ n: Int) -> LazyRotateBidirectionalCollection<Elements.SubSequence> {
        return self.elements.dropFirst(n).concat(self.elements.prefix(n)).lazy
    }
}

public extension Sequence where Iterator.Element : Comparable {
    
    /// Returns the maximal `SubSequence`s of `self`, in order, around elements
    /// match in `separator`.
    ///
    /// - parameters:
    ///   - maxSplits: The maximum number of times to split the sequence, or one
    ///     less than the number of subsequences to return. If `maxSplits + 1`
    ///     subsequences are returned, the last one is a suffix of the original
    ///     sequence containing the remaining elements. `maxSplits` must be
    ///     greater than or equal to zero. The default value is `Int.max`.
    ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
    ///     returned in the result for each pair of consecutive elements
    ///     satisfying the `isSeparator` predicate and for each element at the
    ///     start or end of the sequence satisfying the `isSeparator` predicate.
    ///     If `true`, only nonempty subsequences are returned. The default
    ///     value is `true`.
    /// - Returns: An array of subsequences, split from this sequence's elements.
    public func split<S: Sequence>(separator: S, maxSplit: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [SubSequence] where S.Iterator.Element == Iterator.Element {
        return self.split(maxSplits: maxSplit, omittingEmptySubsequences: omittingEmptySubsequences) { separator.contains($0) }
    }
}

public typealias LazyMergeSequence<Elements : Sequence, Others : Sequence> = LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<LazyFilterSequence<Others>, (Elements.Iterator.Element, Others.Iterator.Element)>>>>
public typealias LazyMergeCollection<Elements : Collection, Others : Collection> = LazyCollection<FlattenCollection<LazyMapCollection<Elements, LazyMapCollection<LazyFilterCollection<Others>, (Elements.Iterator.Element, Others.Iterator.Element)>>>>

public extension LazySequenceProtocol {
    
    /// Return a `Sequence` containing tuples satisfies `predicate` with each elements of two `sources`.
    public func merge<S : Sequence>(with: S, where predicate: @escaping (Elements.Iterator.Element, S.Iterator.Element) -> Bool) -> LazyMergeSequence<Elements, S> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension LazyCollectionProtocol {
    
    /// Return a `Collection` containing tuples satisfies `predicate` with each elements of two `sources`.
    public func merge<C : Collection>(with: C, where predicate: @escaping (Elements.Iterator.Element, C.Iterator.Element) -> Bool) -> LazyMergeCollection<Elements, C> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension Sequence {
    
    /// Return an `Array` containing tuples satisfies `predicate` with each elements of two `sources`.
    public func merge<S : Sequence>(with: S, where predicate: (Iterator.Element, S.Iterator.Element) throws -> Bool) rethrows -> [(Iterator.Element, S.Iterator.Element)] {
        var result = ContiguousArray<(Iterator.Element, S.Iterator.Element)>()
        for lhs in self {
            for rhs in with where try predicate(lhs, rhs) {
                result.append((lhs, rhs))
            }
        }
        return Array(result)
    }
}

public extension Sequence {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(`elements.count`).
    public func min<R : Comparable>(by: (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
        return try self.min { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(`elements.count`).
    public func max<R : Comparable>(by: (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
        return try self.max { try by($0) < by($1) }
    }
}

public extension MutableCollection where Self : RandomAccessCollection {
    
    public mutating func sort<R : Comparable>(by: (Iterator.Element) -> R) {
        self.sort { by($0) < by($1) }
    }
}
public extension Sequence {
    
    public func sorted<R : Comparable>(by: (Iterator.Element) -> R) -> [Iterator.Element] {
        return self.sorted { by($0) < by($1) }
    }
}

public extension Comparable {
    
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

public extension Strideable where Stride : SignedInteger {
    
    public func clamped(to range: CountableRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.last ?? range.lowerBound)
    }
    public func clamped(to range: CountableClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

public extension RandomAccessCollection {
    
    /// Returns a random element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(1).
    public func random() -> Iterator.Element? {
        let _count = UIntMax(self.count.toIntMax())
        switch _count {
        case 0: return nil
        case 1: return self[self.startIndex]
        default: return self[self.index(self.startIndex, offsetBy: numericCast(random_uniform(_count)))]
        }
    }
}

public extension MutableCollection where Self : RandomAccessCollection, Indices.Index == Index, Indices.SubSequence : RandomAccessCollection, Indices.SubSequence.Iterator.Element == Index {
    
    /// Shuffle `self` in-place.
    public mutating func shuffle() {
        for i in self.indices.dropLast() {
            let j = self.indices.suffix(from: i).random()!
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}
public extension Sequence {
    
    /// Return an `Array` containing the shuffled elements of `self`.
    public func shuffled() -> [Iterator.Element] {
        var list = ContiguousArray(self)
        list.shuffle()
        return Array(list)
    }
}

public extension RangeReplaceableCollection {
    
    public mutating func replace<C : Collection>(with newElements: C) where Iterator.Element == C.Iterator.Element {
        self.replaceSubrange(startIndex..<endIndex, with: newElements)
    }
}

public extension BidirectionalCollection where Self : MutableCollection, Indices.SubSequence : BidirectionalCollection, Indices.SubSequence.Iterator.Element == Index {
    
    public mutating func reverseSubrange(_ range: Indices.SubSequence) {
        for (lhs, rhs) in zip(range, range.reversed()) {
            if lhs < rhs {
                swap(&self[lhs], &self[rhs])
            } else {
                break
            }
        }
    }
}
public extension BidirectionalCollection where Self : MutableCollection, Indices.SubSequence : BidirectionalCollection, Iterator.Element : Comparable, Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index {
    
    public func nextPermute() -> Self {
        var _self = self
        if !_self.isEmpty {
            if let k = _self.indices.dropLast().last(where: { _self[$0] < _self[_self.index(after: $0)] }) {
                let range = _self.indices.suffix(from: _self.index(after: k))
                swap(&_self[k], &_self[range.last { _self[k] < _self[$0] }!])
                _self.reverseSubrange(range)
            } else {
                _self.reverse()
            }
        }
        return _self
    }
}

// MARK: LazySliceSequence

public extension RandomAccessCollection {
    
    func slice(by maxLength: IndexDistance) -> [SubSequence] {
        return Array(self.lazy.slice(by: maxLength))
    }
}

public struct LazySliceSequence<Base : RandomAccessCollection> : IteratorProtocol, LazySequenceProtocol {
    
    fileprivate let base: Base
    fileprivate let maxLength: Base.IndexDistance
    fileprivate var currentIndex: Base.Index
    
    public mutating func next() -> Base.SubSequence? {
        if currentIndex != base.endIndex {
            let nextIndex = base.index(currentIndex, offsetBy: maxLength, limitedBy: base.endIndex) ?? base.endIndex
            let result = base[currentIndex..<nextIndex]
            currentIndex = nextIndex
            return result
        }
        return nil
    }
    
    public var underestimatedCount: Int {
        return base.underestimatedCount / numericCast(maxLength)
    }
}

public extension LazyCollectionProtocol where Elements : RandomAccessCollection {
    
    func slice(by maxLength: Elements.IndexDistance) -> LazySliceSequence<Elements> {
        precondition(maxLength != 0, "Sliced by zero-length.")
        return LazySliceSequence(base: elements, maxLength: maxLength, currentIndex: elements.startIndex)
    }
}

// MARK: LazyScanSequence

public extension Sequence {
    /// Returns an array containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     (1..<6).scan(0, +) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(N)
    func scan<R>(_ initial: R, _ combine: (R, Iterator.Element) throws -> R) rethrows -> [R] {
        var last = initial
        var result = [initial]
        result.reserveCapacity(self.underestimatedCount + 1)
        for x in self {
            let next = try combine(last, x)
            result.append(next)
            last = next
        }
        return result
    }
}

public struct LazyScanIterator<Base: IteratorProtocol, Element> : IteratorProtocol, Sequence {
    
    fileprivate var nextElement: Element?
    fileprivate var base: Base
    fileprivate let combine: (Element, Base.Element) -> Element
    
    public mutating func next() -> Element? {
        return nextElement.map { result in
            nextElement = base.next().map { combine(result, $0) }
            return result
        }
    }
}

public struct LazyScanSequence<Base: Sequence, Element> : LazySequenceProtocol {
    
    fileprivate let initial: Element
    fileprivate let base: Base
    fileprivate let combine: (Element, Base.Iterator.Element) -> Element
    
    public func makeIterator() -> LazyScanIterator<Base.Iterator, Element> {
        return LazyScanIterator(nextElement: initial, base: base.makeIterator(), combine: combine)
    }
    
    public var underestimatedCount: Int {
        return base.underestimatedCount + 1
    }
}

public extension LazySequenceProtocol {
    /// Returns a sequence containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     Array((1..<6).lazy.scan(0, +)) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(1)
    func scan<R>(_ initial: R, _ combine: @escaping (R, Elements.Iterator.Element) -> R) -> LazyScanSequence<Elements, R> {
        return LazyScanSequence(initial: initial, base: self.elements, combine: combine)
    }
}

// MARK: LazyGatherCollection

public extension Collection {
    
    func collect<I : Sequence>(_ indices: I) -> [Iterator.Element] where Index == I.Iterator.Element {
        return indices.map { self[$0] }
    }
}

public struct LazyGatherIterator<C: Collection, I: IteratorProtocol> : IteratorProtocol, Sequence where C.Index == I.Element {
    
    fileprivate var seq : C
    fileprivate var indices : I
    
    public typealias Element = C.Iterator.Element
    
    public mutating func next() -> Element? {
        return indices.next().map { seq[$0] }
    }
}

public struct LazyGatherSequence<C : Collection, I : Sequence> : LazySequenceProtocol where C.Index == I.Iterator.Element {
    
    public typealias Iterator = LazyGatherIterator<C, I.Iterator>
    
    fileprivate let _base: C
    fileprivate let _indices: I
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
    
    public var underestimatedCount: Int {
        return _indices.underestimatedCount
    }
}

public struct LazyGatherCollection<C : Collection, I : Collection> : LazyCollectionProtocol where C.Index == I.Iterator.Element {
    
    public typealias Iterator = LazyGatherIterator<C, I.Iterator>
    
    fileprivate let _base: C
    fileprivate let _indices: I
    
    public subscript(position: I.Index) -> C.Iterator.Element {
        return _base[_indices[position]]
    }
    
    public var startIndex : I.Index {
        return _indices.startIndex
    }
    public var endIndex : I.Index {
        return _indices.endIndex
    }
    
    public func index(after i: I.Index) -> I.Index {
        return _indices.index(after: i)
    }
    
    public var count : I.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
    
    public var underestimatedCount: Int {
        return _indices.underestimatedCount
    }
}

public struct LazyGatherBidirectionalCollection<C : Collection, I : BidirectionalCollection> : LazyCollectionProtocol, BidirectionalCollection where C.Index == I.Iterator.Element {
    
    public typealias Iterator = LazyGatherIterator<C, I.Iterator>
    
    fileprivate let _base: C
    fileprivate let _indices: I
    
    public subscript(position: I.Index) -> C.Iterator.Element {
        return _base[_indices[position]]
    }
    
    public var startIndex : I.Index {
        return _indices.startIndex
    }
    public var endIndex : I.Index {
        return _indices.endIndex
    }
    
    public func index(after i: I.Index) -> I.Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: I.Index) -> I.Index {
        return _indices.index(before: i)
    }
    
    public var count : I.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
    
    public var underestimatedCount: Int {
        return _indices.underestimatedCount
    }
}

public struct LazyGatherRandomAccessCollection<C : Collection, I : RandomAccessCollection> : LazyCollectionProtocol, RandomAccessCollection where C.Index == I.Iterator.Element {
    
    public typealias Iterator = LazyGatherIterator<C, I.Iterator>
    
    fileprivate let _base: C
    fileprivate let _indices: I
    
    public subscript(position: I.Index) -> C.Iterator.Element {
        return _base[_indices[position]]
    }
    
    public var startIndex : I.Index {
        return _indices.startIndex
    }
    public var endIndex : I.Index {
        return _indices.endIndex
    }
    
    public func index(after i: I.Index) -> I.Index {
        return _indices.index(after: i)
    }
    
    public func index(before i: I.Index) -> I.Index {
        return _indices.index(before: i)
    }
    
    public func index(_ i: I.Index, offsetBy n: I.IndexDistance) -> I.Index {
        return _indices.index(i, offsetBy: n)
    }
    
    public func distance(from start: I.Index, to end: I.Index) -> I.IndexDistance {
        return _indices.distance(from: start, to: end)
    }
    
    public var count : I.IndexDistance {
        return _indices.count
    }
    
    public func makeIterator() -> Iterator {
        return LazyGatherIterator(seq: _base, indices: _indices.makeIterator())
    }
    
    public var underestimatedCount: Int {
        return _indices.underestimatedCount
    }
}

public extension LazyCollectionProtocol {
    
    func collect<I : Sequence>(_ indices: I) -> LazyGatherSequence<Elements, I> where Elements.Index == I.Iterator.Element {
        return LazyGatherSequence(_base: self.elements, _indices: indices)
    }
    
    func collect<I : Collection>(_ indices: I) -> LazyGatherCollection<Elements, I> where Elements.Index == I.Iterator.Element {
        return LazyGatherCollection(_base: self.elements, _indices: indices)
    }
    
    func collect<I : BidirectionalCollection>(_ indices: I) -> LazyGatherBidirectionalCollection<Elements, I> where Elements.Index == I.Iterator.Element {
        return LazyGatherBidirectionalCollection(_base: self.elements, _indices: indices)
    }
    
    func collect<I : RandomAccessCollection>(_ indices: I) -> LazyGatherRandomAccessCollection<Elements, I> where Elements.Index == I.Iterator.Element {
        return LazyGatherRandomAccessCollection(_base: self.elements, _indices: indices)
    }
}

// MARK: OptionOneCollection

public struct OptionOneCollection<T> : RandomAccessCollection {
    
    public typealias Indices = CountableRange<Int>
    
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
    public var count : Int {
        return value == nil ? 0 : 1
    }
    
    public subscript(position: Int) -> T {
        return value!
    }
    
    public var underestimatedCount: Int {
        return value == nil ? 0 : 1
    }
}

// MARK: ConcatCollection

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
    
    public var underestimatedCount: Int {
        return base1.underestimatedCount + base2.underestimatedCount
    }
    
    public func _copyToContiguousArray() -> ContiguousArray<S1.Iterator.Element> {
        var result = ContiguousArray<Iterator.Element>()
        result.reserveCapacity(underestimatedCount)
        
        result.append(contentsOf: base1)
        result.append(contentsOf: base2)
        
        return result
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
    
    public var count : Int {
        return numericCast(base1.count) + numericCast(base2.count)
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
    
    public func _copyToContiguousArray() -> ContiguousArray<S1.Iterator.Element> {
        var result = ContiguousArray<Iterator.Element>()
        result.reserveCapacity(underestimatedCount)
        
        result.append(contentsOf: base1)
        result.append(contentsOf: base2)
        
        return result
    }
    
    public var underestimatedCount: Int {
        return base1.underestimatedCount + base2.underestimatedCount
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
    
    public var count : Int {
        return numericCast(base1.count) + numericCast(base2.count)
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
    
    public func _copyToContiguousArray() -> ContiguousArray<S1.Iterator.Element> {
        var result = ContiguousArray<Iterator.Element>()
        result.reserveCapacity(underestimatedCount)
        
        result.append(contentsOf: base1)
        result.append(contentsOf: base2)
        
        return result
    }
    
    public var underestimatedCount: Int {
        return base1.underestimatedCount + base2.underestimatedCount
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

// MARK: IndexedCollection

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
    
    public var count : C.IndexDistance {
        return base.count
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
    
    public var underestimatedCount: Int {
        return base.underestimatedCount
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
    
    public var count : C.IndexDistance {
        return base.count
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
    
    public var underestimatedCount: Int {
        return base.underestimatedCount
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
    
    public var count : C.IndexDistance {
        return base.count
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
    
    public var underestimatedCount: Int {
        return base.underestimatedCount
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
