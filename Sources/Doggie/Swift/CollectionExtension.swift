//
//  CollectionExtension.swift
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

extension Sequence {
    
    @inlinable
    public func reduce(_ nextPartialResult: (Element, Element) throws -> Element) rethrows -> Element? {
        return try self.reduce(nil) { partial, current in try partial.map { try nextPartialResult($0, current) } ?? current }
    }
}

extension MutableCollection {
    
    @inlinable
    public var mutableFirst: Element {
        get {
            return self[self.startIndex]
        }
        set {
            self[self.startIndex] = newValue
        }
    }
}

extension MutableCollection where Self : BidirectionalCollection {
    
    @inlinable
    public var mutableLast: Element {
        get {
            return self[self.index(before: self.endIndex)]
        }
        set {
            self[self.index(before: self.endIndex)] = newValue
        }
    }
}

extension Collection where SubSequence == Self {
    
    @inlinable
    public mutating func popFirst(_ n: Int) -> SubSequence {
        precondition(n >= 0, "Can't drop a negative number of elements from a collection")
        let result = self.prefix(n)
        self.removeFirst(Swift.min(self.count, n))
        return result
    }
}

extension BidirectionalCollection where SubSequence == Self {
    
    @inlinable
    public mutating func popLast(_ n: Int) -> SubSequence {
        precondition(n >= 0, "Can't drop a negative number of elements from a collection")
        let result = self.suffix(n)
        self.removeLast(Swift.min(self.count, n))
        return result
    }
}

extension BidirectionalCollection {
    
    @inlinable
    public func suffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        return self.suffix(from: try self.reversed().firstIndex { try !predicate($0) }?.base ?? self.startIndex)
    }
}

extension RandomAccessCollection {
    
    /// Returns first range of `pattern` appear in `self`, or `nil` if not match.
    ///
    /// - complexity: Amortized O(`self.count`)
    @inlinable
    public func range<C : RandomAccessCollection>(of pattern: C, where isEquivalent: (Element, Element) throws -> Bool) rethrows -> Range<Index>? where C.Element == Element {
        
        let pattern_count = pattern.count
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
            if let pos = try reverse_pattern.dropFirst().firstIndex(where: { try isEquivalent(notMatchValue, $0) }) {
                cursor = self.index(not_match.0, offsetBy: reverse_pattern.distance(from: reverse_pattern.startIndex, to: pos), limitedBy: endIndex) ?? endIndex
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

extension RandomAccessCollection where Element : Equatable {
    
    /// Returns first range of `pattern` appear in `self`, or `nil` if not match.
    ///
    /// - complexity: Amortized O(`self.count`)
    @inlinable
    public func range<C : RandomAccessCollection>(of pattern: C) -> Range<Index>? where C.Element == Element {
        return self.range(of: pattern, where: ==)
    }
}

extension MutableCollection {
    
    @inlinable
    public mutating func mutateEach(body: (inout Element) throws -> ()) rethrows {
        for idx in self.indices {
            try body(&self[idx])
        }
    }
}

extension Sequence {
    
    @inlinable
    public func appended(_ newElement: Element) -> ConcatSequence<Self, CollectionOfOne<Element>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

extension Collection {
    
    @inlinable
    public func appended(_ newElement: Element) -> ConcatCollection<Self, CollectionOfOne<Element>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

extension LazySequenceProtocol {
    
    @inlinable
    public func appended(_ newElement: Elements.Element) -> LazySequence<ConcatSequence<Elements, CollectionOfOne<Elements.Element>>> {
        return self.elements.appended(newElement).lazy
    }
}

extension LazyCollectionProtocol {
    
    @inlinable
    public func appended(_ newElement: Elements.Element) -> LazyCollection<ConcatCollection<Elements, CollectionOfOne<Elements.Element>>> {
        return self.elements.appended(newElement).lazy
    }
}

extension Collection where SubSequence : Collection {
    
    @inlinable
    public func rotated(at index: Index) -> ConcatCollection<SubSequence, SubSequence> {
        return self.suffix(from: index).concat(self.prefix(upTo: index))
    }
}

extension Collection where SubSequence : Collection {
    
    @inlinable
    public func rotated(_ n: Int) -> ConcatCollection<SubSequence, SubSequence> {
        let count = self.count
        if count == 0 {
            return self[...].concat(self[...])
        }
        if n < 0 {
            let _n = -n % count
            return self.suffix(_n).concat(self.dropLast(_n))
        }
        let _n = n % count
        return self.dropFirst(_n).concat(self.prefix(_n))
    }
}

extension LazyCollectionProtocol where Elements.SubSequence : Collection {
    
    @inlinable
    public func rotated(_ n: Int) -> LazyCollection<ConcatCollection<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.rotated(n).lazy
    }
}

extension Collection where Element : Comparable {
    
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
    @inlinable
    public func split<S: Sequence>(separator: S, maxSplit: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [SubSequence] where S.Element == Element {
        return self.split(maxSplits: maxSplit, omittingEmptySubsequences: omittingEmptySubsequences) { separator.contains($0) }
    }
}

extension LazySequenceProtocol {
    
    /// Return a `Sequence` containing tuples satisfies `predicate` with each elements of two `sources`.
    @inlinable
    public func merge<S>(with: S, where predicate: @escaping (Elements.Element, S.Element) -> Bool) -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<LazyFilterSequence<S>, (Elements.Element, S.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

extension LazyCollectionProtocol {
    
    /// Return a `Collection` containing tuples satisfies `predicate` with each elements of two `sources`.
    @inlinable
    public func merge<C>(with: C, where predicate: @escaping (Elements.Element, C.Element) -> Bool) -> LazyCollection<FlattenCollection<LazyMapCollection<Elements, LazyMapCollection<LazyFilterCollection<C>, (Elements.Element, C.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

extension Sequence {
    
    /// Return an `Array` containing tuples satisfies `predicate` with each elements of two `sources`.
    @inlinable
    public func merge<S : Sequence>(with: S, where predicate: (Element, S.Element) throws -> Bool) rethrows -> [(Element, S.Element)] {
        var result = ContiguousArray<(Element, S.Element)>()
        for lhs in self {
            for rhs in with where try predicate(lhs, rhs) {
                result.append((lhs, rhs))
            }
        }
        return Array(result)
    }
}

extension Sequence {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(`elements.count`).
    @inlinable
    public func min<R : Comparable>(by: (Element) throws -> R) rethrows -> Element? {
        return try self.min { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(`elements.count`).
    @inlinable
    public func max<R : Comparable>(by: (Element) throws -> R) rethrows -> Element? {
        return try self.max { try by($0) < by($1) }
    }
}

extension MutableCollection where Self : RandomAccessCollection {
    
    @inlinable
    public mutating func sort<R : Comparable>(by: (Element) -> R) {
        self.sort { by($0) < by($1) }
    }
}
extension Sequence {
    
    @inlinable
    public func sorted<R : Comparable>(by: (Element) -> R) -> [Element] {
        return self.sorted { by($0) < by($1) }
    }
}

extension Comparable {
    
    @inlinable
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Strideable where Stride : SignedInteger {
    
    @inlinable
    public func clamped(to range: Range<Self>) -> Self {
        return self.clamped(to: ClosedRange(range))
    }
}

extension RangeReplaceableCollection {
    
    @inlinable
    public mutating func replace<C : Collection>(with newElements: C) where Element == C.Element {
        self.replaceSubrange(startIndex..<endIndex, with: newElements)
    }
}

extension BidirectionalCollection where Self : MutableCollection {
    
    @inlinable
    public mutating func reverseSubrange(_ range: Indices.SubSequence) {
        for (lhs, rhs) in zip(range, range.reversed()) {
            if lhs < rhs {
                swapAt(lhs, rhs)
            } else {
                break
            }
        }
    }
}

extension BidirectionalCollection where Self : MutableCollection {
    
    @inlinable
    public mutating func nextPermute(by areInIncreasingOrder: (Element, Element) -> Bool) {
        if !self.isEmpty {
            if let k = self.indices.dropLast().last(where: { areInIncreasingOrder(self[$0], self[self.index(after: $0)]) }) {
                let range = self.indices.suffix(from: self.index(after: k))
                self.swapAt(k, range.last { areInIncreasingOrder(self[k], self[$0]) }!)
                self.reverseSubrange(range)
            } else {
                self.reverse()
            }
        }
    }
    
    @inlinable
    public mutating func nextPermute<R : Comparable>(by: (Element) -> R) {
        self.nextPermute { by($0) < by($1) }
    }
}

extension BidirectionalCollection where Self : MutableCollection, Element : Comparable {
    
    @inlinable
    public mutating func nextPermute() {
        self.nextPermute(by: <)
    }
}
