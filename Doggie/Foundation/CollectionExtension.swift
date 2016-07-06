//
//  CollectionExtension.swift
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

public extension LazySequenceProtocol {
    
    var any: LazySequence<AnySequence<Elements.Iterator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazySequenceProtocol where Elements.SubSequence : Sequence, Elements.SubSequence.Iterator.Element == Elements.Iterator.Element, Elements.SubSequence.SubSequence == Elements.SubSequence {
    
    var any: LazySequence<AnySequence<Elements.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : Collection, Elements.SubSequence.Iterator.Element == Elements.Iterator.Element, Elements.SubSequence.Index == Elements.Index, Elements.SubSequence.Indices : Collection, Elements.SubSequence.Indices.Iterator.Element == Elements.Index, Elements.SubSequence.Indices.Index == Elements.Index, Elements.SubSequence.Indices.SubSequence == Elements.SubSequence.Indices, Elements.SubSequence.SubSequence == Elements.SubSequence, Elements.Indices : Collection, Elements.Indices.Iterator.Element == Elements.Index, Elements.Indices.Index == Elements.Index, Elements.Indices.SubSequence == Elements.Indices {
    
    var any: LazyCollection<AnyCollection<Elements.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyCollectionProtocol where Elements : BidirectionalCollection, Elements.SubSequence : BidirectionalCollection, Elements.SubSequence.Iterator.Element == Elements.Iterator.Element, Elements.SubSequence.Index == Elements.Index, Elements.SubSequence.Indices : BidirectionalCollection, Elements.SubSequence.Indices.Iterator.Element == Elements.Index, Elements.SubSequence.Indices.Index == Elements.Index, Elements.SubSequence.Indices.SubSequence == Elements.SubSequence.Indices, Elements.SubSequence.SubSequence == Elements.SubSequence, Elements.Indices : BidirectionalCollection, Elements.Indices.Iterator.Element == Elements.Index, Elements.Indices.Index == Elements.Index, Elements.Indices.SubSequence == Elements.Indices {
    
    var any: LazyCollection<AnyBidirectionalCollection<Elements.Iterator.Element>> {
        return elements.any.lazy
    }
}

public extension LazyCollectionProtocol where Elements : RandomAccessCollection, Elements.SubSequence : RandomAccessCollection, Elements.SubSequence.Iterator.Element == Elements.Iterator.Element, Elements.SubSequence.Index == Elements.Index, Elements.SubSequence.Indices : RandomAccessCollection, Elements.SubSequence.Indices.Iterator.Element == Elements.Index, Elements.SubSequence.Indices.Index == Elements.Index, Elements.SubSequence.Indices.SubSequence == Elements.SubSequence.Indices, Elements.SubSequence.SubSequence == Elements.SubSequence, Elements.Indices : RandomAccessCollection, Elements.Indices.Iterator.Element == Elements.Index, Elements.Indices.Index == Elements.Index, Elements.Indices.SubSequence == Elements.Indices {
    
    var any: LazyCollection<AnyRandomAccessCollection<Elements.Iterator.Element>> {
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
    func all(_ predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> Bool {
        
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
    func prefix(until element: Iterator.Element) -> SubSequence {
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
    func prefix(until predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
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
    func suffix(until element: Iterator.Element) -> SubSequence {
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
    func suffix(until predicate: @noescape (Iterator.Element) throws -> Bool) rethrows -> SubSequence {
        return self.suffix(from: try self.reversed().index(where: predicate)?.base ?? self.startIndex)
    }
}

public extension RandomAccessCollection where Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index {
    
    func match<C : BidirectionalCollection where C.Iterator.Element == Iterator.Element>(with pattern: C, isEquivalent: @noescape (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> Index? {
        
        let pattern_count: IndexDistance = numericCast(pattern.count)
        if count < pattern_count {
            return nil
        }
        let reverse_pattern = pattern.reversed()
        var cursor = self.index(startIndex, offsetBy: pattern_count - 1, limitedBy: endIndex) ?? endIndex
        while cursor < endIndex {
            let left = self.indices.prefix(through: cursor)
            let pair = zip(left.reversed(), reverse_pattern)
            guard let not_match = try pair.first(where: { try !isEquivalent(self[$0], $1) }) else {
                return self.index(cursor, offsetBy: 1 - pattern_count)
            }
            let notMatchValue = self[not_match.0]
            if let pos = try reverse_pattern.dropFirst().index(where: { try isEquivalent(notMatchValue, $0) }) {
                let offset = reverse_pattern.distance(from: reverse_pattern.startIndex, to: pos)
                cursor = self.index(not_match.0, offsetBy: numericCast(offset), limitedBy: endIndex) ?? endIndex
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

public extension RandomAccessCollection where Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index, Iterator.Element : Equatable {
    
    func match<C : BidirectionalCollection where C.Iterator.Element == Iterator.Element>(with pattern: C) -> Index? {
        return self.match(with: pattern, isEquivalent: ==)
    }
}

public extension String {
    
    func hasPattern(pattern: String) -> Bool {
        return Array(characters).match(with: Array(pattern.characters)) != nil
    }
}

public extension MutableCollection where Indices.Iterator.Element == Index {
    
    mutating func mutateEach(body: @noescape (inout Iterator.Element) throws -> ()) rethrows {
        for idx in self.indices {
            try body(&self[idx])
        }
    }
}

public extension LazySequenceProtocol {
    
    func append(_ newElement: Elements.Iterator.Element) -> LazySequence<ConcatSequence<Elements, CollectionOfOne<Elements.Iterator.Element>>> {
        return self.elements.concat(with: CollectionOfOne(newElement)).lazy
    }
}

public extension LazyCollectionProtocol {
    
    func append(_ newElement: Elements.Iterator.Element) -> LazyCollection<ConcatCollection<Elements, CollectionOfOne<Elements.Iterator.Element>>> {
        return self.elements.concat(with: CollectionOfOne(newElement)).lazy
    }
}

public extension LazyCollectionProtocol where Elements : BidirectionalCollection {
    
    func append(_ newElement: Elements.Iterator.Element) -> LazyCollection<ConcatBidirectionalCollection<Elements, CollectionOfOne<Elements.Iterator.Element>>> {
        return self.elements.concat(with: CollectionOfOne(newElement)).lazy
    }
}

public extension Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatSequence<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(with: self.suffix(from: subRange.upperBound))
    }
}

public extension Collection where SubSequence : Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatCollection<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(with: self.suffix(from: subRange.upperBound))
    }
}

public extension BidirectionalCollection where SubSequence : BidirectionalCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Self.Index>) -> ConcatBidirectionalCollection<SubSequence, SubSequence> {
        return self.prefix(upTo: subRange.lowerBound).concat(with: self.suffix(from: subRange.upperBound))
    }
}

public extension LazyCollectionProtocol {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Elements.Index>) -> LazySequence<ConcatSequence<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : Collection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Elements.Index>) -> LazyCollection<ConcatCollection<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : BidirectionalCollection {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    func dropRange(_ subRange: Range<Elements.Index>) -> LazyCollection<ConcatBidirectionalCollection<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionProtocol {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<S : Sequence where S.Iterator.Element == Elements.SubSequence.Iterator.Element>(_ subRange: Range<Elements.Index>, with newElements: S) -> LazySequence<ConcatSequence<ConcatSequence<Elements.SubSequence, S>, Elements.SubSequence>> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(with: newElements).concat(with: self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : Collection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<C : Collection where C.Iterator.Element == Elements.SubSequence.Iterator.Element>(_ subRange: Range<Elements.Index>, with newElements: C) -> LazyCollection<ConcatCollection<ConcatCollection<Elements.SubSequence, C>, Elements.SubSequence>> {
        return self.elements.prefix(upTo: subRange.lowerBound).concat(with: newElements).concat(with: self.elements.suffix(from: subRange.upperBound)).lazy
    }
}

public extension LazyCollectionProtocol where Elements.SubSequence : BidirectionalCollection {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    func replaceRange<C : BidirectionalCollection where C.Iterator.Element == Elements.SubSequence.Iterator.Element>(_ subRange: Range<Elements.Index>, with newElements: C) -> LazyCollection<ConcatBidirectionalCollection<ConcatBidirectionalCollection<Elements.SubSequence, C>, Elements.SubSequence>> {
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

public extension LazySequenceProtocol {
    
    /// Return a `Sequence` containing tuples satisfies `predicate` with each elements of two `sources`.
    func merge<S : Sequence>(with: S, predicate: (Elements.Iterator.Element, S.Iterator.Element) -> Bool) -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<LazyFilterSequence<S>, (Elements.Iterator.Element, S.Iterator.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension LazyCollectionProtocol {
    
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

public extension Sequence {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    func min<R : Comparable>(by: @noescape (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
        return try self.min { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    func max<R : Comparable>(by: @noescape (Iterator.Element) throws -> R) rethrows -> Iterator.Element? {
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

extension BinaryFloatingPoint {
    
    static func random(includeOne: Bool = false) -> Self {
        let significandBitCount: UIntMax = numericCast(Self.significandBitCount)
        let exponentBitPattern = numericCast((1 as Self).exponentBitPattern) << significandBitCount
        let maxsignificand = 1 << significandBitCount
        let rand = includeOne ? (0...maxsignificand).random()! : (0..<maxsignificand).random()!
        let pattern = exponentBitPattern + rand
        let exponent = pattern >> significandBitCount
        let significand = pattern & (maxsignificand - 1)
        return Self(sign: .plus, exponentBitPattern: numericCast(exponent), significandBitPattern: numericCast(significand)) - 1
    }
}

public func random<T : BinaryFloatingPoint>(_ range: ClosedRange<T>) -> T {
    let diff = range.upperBound - range.lowerBound
    return (T.random(includeOne: true) * diff) + range.lowerBound
}
public func random<T : BinaryFloatingPoint>(_ range: Range<T>) -> T {
    let diff = range.upperBound - range.lowerBound
    return (T.random() * diff) + range.lowerBound
}

public extension RandomAccessCollection {
    
    /// Returns a random element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(1).
    ///
    func random() -> Iterator.Element? {
        let _count = UIntMax(self.count.toIntMax())
        switch _count {
        case 0: return nil
        case 1: return self[self.startIndex]
        default: return self[self.index(self.startIndex, offsetBy: numericCast(random_uniform(_count)))]
        }
    }
}

public extension Collection {
    
    /// Return an `Array` containing the shuffled elements of `source`.(mutable_variant:"shuffleInPlace")
    func shuffled() -> [Iterator.Element] {
        var list = self.array
        list.shuffleInPlace()
        return list
    }
}

public extension RandomAccessCollection where Self : MutableCollection, Indices.Index == Index, Indices.SubSequence : RandomAccessCollection, Indices.SubSequence.Iterator.Element == Index {
    
    /// Shuffle `self` in-place.
    mutating func shuffleInPlace() {
        for i in self.indices.dropLast() {
            let j = self.indices.suffix(from: i).random()!
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

public extension BidirectionalCollection where Self : MutableCollection, Indices.SubSequence : BidirectionalCollection, Iterator.Element : Comparable, Indices.SubSequence.Iterator.Element == Index, Indices.Index == Index {
    
    @_transparent
    private mutating func reverseInPlace(_ range: Indices.SubSequence) {
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
    func nextPermute() -> Self {
        var _self = self
        if !_self.isEmpty {
            if let k = _self.indices.dropLast().last(where: { _self[$0] < _self[_self.index(after: $0)] }) {
                let range = _self.indices.suffix(from: _self.index(after: k))
                swap(&_self[k], &_self[range.last { _self[k] < _self[$0] }!])
                _self.reverseInPlace(range)
            } else {
                _self.reverseInPlace(_self.indices.slice)
            }
        }
        return _self
    }
}
