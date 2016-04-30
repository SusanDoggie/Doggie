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

import Foundation

public extension SequenceType {
    
    /// Returns the first element of `self`, or `nil` if `self` is empty.
    var first: Generator.Element? {
        var generator = self.generate()
        return generator.next()
    }
}

public extension Array {
    
    var array: [Generator.Element] {
        return self
    }
}

public extension SequenceType {
    
    var array: [Generator.Element] {
        return self as? [Generator.Element] ?? Array(self)
    }
}

public extension CollectionType where Self == SubSequence {
    
    /// Returns sub-sequence of `self`.
    var slice: SubSequence {
        return self
    }
}

public extension CollectionType {
    
    /// Returns sub-sequence of `self`.
    var slice: SubSequence {
        return self as? SubSequence ?? self[self.indices]
    }
}

public extension AnyGenerator {
    
    var any: AnyGenerator<Element> {
        return self
    }
}

public extension AnySequence {
    
    var any: AnySequence<Element> {
        return self
    }
}

public extension AnyForwardCollection {
    
    var any: AnyForwardCollection<Element> {
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

public extension GeneratorType {
    
    var any: AnyGenerator<Element> {
        return self as? AnyGenerator ?? AnyGenerator(self)
    }
}

public extension SequenceType {
    
    var any: AnySequence<Generator.Element> {
        return self as? AnySequence ?? AnySequence(self.generate)
    }
}

public extension SequenceType where SubSequence : SequenceType, SubSequence.Generator.Element == Generator.Element, SubSequence.SubSequence == SubSequence {
    
    var any: AnySequence<Generator.Element> {
        return self as? AnySequence ?? AnySequence(self)
    }
}

public extension CollectionType {
    
    var any: AnyForwardCollection<Generator.Element> {
        return self as? AnyForwardCollection ?? AnyForwardCollection(self)
    }
}

public extension CollectionType where Index : BidirectionalIndexType {
    
    var any: AnyBidirectionalCollection<Generator.Element> {
        return self as? AnyBidirectionalCollection ?? AnyBidirectionalCollection(self)
    }
}

public extension CollectionType where Index : RandomAccessIndexType {
    
    var any: AnyRandomAccessCollection<Generator.Element> {
        return self as? AnyRandomAccessCollection ?? AnyRandomAccessCollection(self)
    }
}

public extension LazySequenceType {
    
    var any: LazySequence<AnySequence<Elements.Generator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazySequenceType where Elements.SubSequence : SequenceType, Elements.SubSequence.Generator.Element == Elements.Generator.Element, Elements.SubSequence.SubSequence == Elements.SubSequence {
    
    var any: LazySequence<AnySequence<Elements.Generator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazyCollectionType {
    
    var any: LazyCollection<AnyForwardCollection<Elements.Generator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    var any: LazyCollection<AnyBidirectionalCollection<Elements.Generator.Element>> {
        return self.elements.any.lazy
    }
}

public extension LazyCollectionType where Elements.Index : RandomAccessIndexType {
    
    var any: LazyCollection<AnyRandomAccessCollection<Elements.Generator.Element>> {
        return self.elements.any.lazy
    }
}

public extension SequenceType where Generator.Element : Equatable {
    
    /// Return `true` if all of elements in `seq` is `x`.
    ///
    /// - Complexity: O(`self.count`).
    @warn_unused_result
    func all(x: Generator.Element) -> Bool {
        
        for item in self where item != x {
            return false
        }
        return true
    }
}

public extension SequenceType {
    
    /// Return `true` if all of elements in `seq` satisfies `predicate`.
    ///
    /// - Complexity: O(`self.count`).
    @warn_unused_result
    func all(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> Bool {
        
        for item in self where try !predicate(item) {
            return false
        }
        return true
    }
}

public extension Set {
    
    /// Return `true` if all of elements in `seq` is `x`.
    @warn_unused_result
    func all(x: Element) -> Bool {
        
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

public extension SequenceType {
    
    /// Return first of elements in `seq` satisfies `predicate`.
    ///
    /// - Complexity: O(`self.count`).
    @warn_unused_result
    func firstOf(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> Generator.Element? {
        
        for item in self where try predicate(item) {
            return item
        }
        return nil
    }
}

public extension CollectionType where Index : BidirectionalIndexType {
    
    /// Return last of elements in `seq` satisfies `predicate`.
    ///
    /// - Complexity: O(`self.count`).
    @warn_unused_result
    func lastOf(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> Generator.Element? {
        return try self.reverse().firstOf(predicate)
    }
}

public extension CollectionType where Generator.Element : Equatable {
    
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// initial elements.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    func prefixUntil(element: Generator.Element) -> SubSequence {
        return self.prefixUpTo(self.indexOf(element) ?? self.endIndex)
    }
}

public extension CollectionType {
    
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// initial elements.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    func prefixUntil(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> SubSequence {
        return self.prefixUpTo(try self.indexOf(predicate) ?? self.endIndex)
    }
}

public extension CollectionType where Generator.Element : Equatable, Index : BidirectionalIndexType {
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// final elements of `self`.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    func suffixUntil(element: Generator.Element) -> SubSequence {
        return self.suffixFrom(self.reverse().indexOf(element)?.base ?? self.startIndex)
    }
}

public extension CollectionType where Index : BidirectionalIndexType {
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// final elements of `self`.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    func suffixUntil(@noescape predicate: (Generator.Element) throws -> Bool) rethrows -> SubSequence {
        return self.suffixFrom(try self.reverse().indexOf(predicate)?.base ?? self.startIndex)
    }
}

public extension CollectionType where Index : RandomAccessIndexType {
    
    @warn_unused_result
    func matchWith<C : CollectionType where C.Index : RandomAccessIndexType, C.Generator.Element == Generator.Element>(pattern: C, @noescape isEquivalent: (Generator.Element, Generator.Element) throws -> Bool) rethrows -> Index? {
        
        let pattern_count = pattern.count.toIntMax()
        if count.toIntMax() < pattern_count {
            return nil
        }
        let reverse_pattern = pattern.reverse()
        var cursor = startIndex.advancedBy(numericCast(pattern_count - 1))
        while cursor < endIndex {
            let left = startIndex..<cursor
            let pair = zip(left.reverse(), reverse_pattern)
            guard let not_match = try pair.firstOf({ try !isEquivalent(self[$0], $1) }) else {
                return cursor.advancedBy(numericCast(-pattern_count))
            }
            if let pos = try reverse_pattern.dropFirst().indexOf({ try isEquivalent(self[not_match.0], $0) }) {
                let offset = reverse_pattern.startIndex.distanceTo(pos).toIntMax()
                cursor = cursor.advancedBy(numericCast(offset), limit: endIndex)
            } else {
                cursor = cursor.advancedBy(numericCast(pattern_count - 1), limit: endIndex)
            }
        }
        if try self.reverse().startsWith(reverse_pattern, isEquivalent: isEquivalent) {
            return endIndex.advancedBy(numericCast(-pattern_count))
        }
        return nil
    }
}

public extension CollectionType where Index : RandomAccessIndexType, Generator.Element : Equatable {
    
    @warn_unused_result
    func matchWith<C : CollectionType where C.Generator.Element == Generator.Element, C.Index : RandomAccessIndexType>(pattern: C) -> Index? {
        return self.matchWith(pattern) { $0 == $1 }
    }
}

public extension String {
    
    @warn_unused_result
    func hasPattern(pattern: String) -> Bool {
        return Array(characters).matchWith(Array(pattern.characters)) != nil
    }
}

public extension MutableCollectionType {
    
    mutating func mutateEach(@noescape body: (inout Generator.Element) throws -> ()) rethrows {
        for idx in self.indices {
            try body(&self[idx])
        }
    }
}

public struct OptionOneGenerator<T> : GeneratorType, SequenceType {
    
    private var value: T?
    
    public mutating func next() -> T? {
        let _value = value
        value = nil
        return _value
    }
}

public struct OptionOneCollection<T> : CollectionType {
    
    public typealias Generator = OptionOneGenerator<T>
    
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
    
    public func generate() -> OptionOneGenerator<T> {
        return OptionOneGenerator(value: value)
    }
}

public extension SequenceType {
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
    @warn_unused_result
    func scan<R>(initial: R, @noescape combine: (R, Generator.Element) throws -> R) rethrows -> [R] {
        var result = [initial]
        for x in self {
            result.append(try combine(result.last!, x))
        }
        return result
    }
}

public struct LazyScanGenerator<Base: GeneratorType, Element> : GeneratorType, SequenceType {
    
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

public struct LazyScanSequence<Base: SequenceType, Element> : LazySequenceType {
    
    private let initial: Element
    private let base: Base
    private let combine: (Element, Base.Generator.Element) -> Element
    
    public func generate() -> LazyScanGenerator<Base.Generator, Element> {
        return LazyScanGenerator(nextElement: initial, base: base.generate(), combine: combine)
    }
}

public extension LazySequenceType {
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
    @warn_unused_result
    func scan<R>(initial: R, combine: (R, Elements.Generator.Element) -> R) -> LazyScanSequence<Elements, R> {
        return LazyScanSequence(initial: initial, base: self.elements, combine: combine)
    }
}

public struct ConcatGenerator<G1: GeneratorType, G2: GeneratorType where G1.Element == G2.Element> : GeneratorType, SequenceType {
    
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

public struct ConcatSequence<S1 : SequenceType, S2 : SequenceType where S1.Generator.Element == S2.Generator.Element> : SequenceType {
    
    private let base1: S1
    private let base2: S2
    
    public func generate() -> ConcatGenerator<S1.Generator, S2.Generator> {
        return ConcatGenerator(base1: base1.generate(), base2: base2.generate(), flag: true)
    }
    
    public func underestimateCount() -> Int {
        return base1.underestimateCount() + base2.underestimateCount()
    }
}

public struct ConcatCollection<S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element> : CollectionType {
    
    public typealias Generator = ConcatGenerator<S1.Generator, S2.Generator>
    
    private let base1: S1
    private let base2: S2
    
    public var startIndex : ConcatCollectionIndex<S1, S2> {
        return ConcatCollectionIndex(endIndex1: base1.endIndex, endIndex2: base2.endIndex, currect1: base1.startIndex, currect2: base2.startIndex)
    }
    
    public var endIndex : ConcatCollectionIndex<S1, S2> {
        return ConcatCollectionIndex(endIndex1: base1.endIndex, endIndex2: base2.endIndex, currect1: base1.endIndex, currect2: base2.endIndex)
    }
    
    public subscript(index: ConcatCollectionIndex<S1, S2>) -> S1.Generator.Element {
        return index.currect1 != base1.endIndex ? base1[index.currect1] : base2[index.currect2]
    }
    
    public func generate() -> ConcatGenerator<S1.Generator, S2.Generator> {
        return ConcatGenerator(base1: base1.generate(), base2: base2.generate(), flag: true)
    }
    
    public func underestimateCount() -> Int {
        return base1.underestimateCount() + base2.underestimateCount()
    }
}

public struct ConcatCollectionIndex<S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element> : ForwardIndexType {
    
    private let endIndex1: S1.Index
    private let endIndex2: S2.Index
    private let currect1: S1.Index
    private let currect2: S2.Index
    
    public func successor() -> ConcatCollectionIndex<S1, S2> {
        if currect1 != endIndex1 {
            return ConcatCollectionIndex(endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1.successor(), currect2: currect2)
        }
        if currect2 != endIndex2 {
            return ConcatCollectionIndex(endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1, currect2: currect2.successor())
        }
        return self
    }
}

public func == <S1, S2>(lhs: ConcatCollectionIndex<S1, S2>, rhs: ConcatCollectionIndex<S1, S2>) -> Bool {
    return lhs.currect1 == rhs.currect1 && lhs.currect2 == rhs.currect2
}

public struct ConcatBidirectionalCollection<S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element, S1.Index : BidirectionalIndexType, S2.Index : BidirectionalIndexType> : CollectionType {
    
    public typealias Generator = ConcatGenerator<S1.Generator, S2.Generator>
    
    private let base1: S1
    private let base2: S2
    
    public var startIndex : ConcatBidirectionalCollectionIndex<S1, S2> {
        return ConcatBidirectionalCollectionIndex(startIndex1: base1.startIndex, startIndex2: base2.startIndex, endIndex1: base1.endIndex, endIndex2: base2.endIndex, currect1: base1.startIndex, currect2: base2.startIndex)
    }
    
    public var endIndex : ConcatBidirectionalCollectionIndex<S1, S2> {
        return ConcatBidirectionalCollectionIndex(startIndex1: base1.startIndex, startIndex2: base2.startIndex, endIndex1: base1.endIndex, endIndex2: base2.endIndex, currect1: base1.endIndex, currect2: base2.endIndex)
    }
    
    public subscript(index: ConcatBidirectionalCollectionIndex<S1, S2>) -> S1.Generator.Element {
        return index.currect1 != base1.endIndex ? base1[index.currect1] : base2[index.currect2]
    }
    
    public func generate() -> ConcatGenerator<S1.Generator, S2.Generator> {
        return ConcatGenerator(base1: base1.generate(), base2: base2.generate(), flag: true)
    }
    
    public func underestimateCount() -> Int {
        return base1.underestimateCount() + base2.underestimateCount()
    }
}

public struct ConcatBidirectionalCollectionIndex<S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element, S1.Index : BidirectionalIndexType, S2.Index : BidirectionalIndexType> : BidirectionalIndexType {
    
    private let startIndex1: S1.Index
    private let startIndex2: S2.Index
    private let endIndex1: S1.Index
    private let endIndex2: S2.Index
    private let currect1: S1.Index
    private let currect2: S2.Index
    
    public func successor() -> ConcatBidirectionalCollectionIndex<S1, S2> {
        if currect1 != endIndex1 {
            return ConcatBidirectionalCollectionIndex(startIndex1: startIndex1, startIndex2: startIndex2, endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1.successor(), currect2: currect2)
        }
        if currect2 != endIndex2 {
            return ConcatBidirectionalCollectionIndex(startIndex1: startIndex1, startIndex2: startIndex2, endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1, currect2: currect2.successor())
        }
        return self
    }
    public func predecessor() -> ConcatBidirectionalCollectionIndex<S1, S2> {
        if currect2 != startIndex2 {
            return ConcatBidirectionalCollectionIndex(startIndex1: startIndex1, startIndex2: startIndex2, endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1, currect2: currect2.predecessor())
        }
        if currect1 != startIndex1 {
            return ConcatBidirectionalCollectionIndex(startIndex1: startIndex1, startIndex2: startIndex2, endIndex1: endIndex1, endIndex2: endIndex2, currect1: currect1.predecessor(), currect2: currect2)
        }
        return self
    }
}

public func == <S1, S2>(lhs: ConcatBidirectionalCollectionIndex<S1, S2>, rhs: ConcatBidirectionalCollectionIndex<S1, S2>) -> Bool {
    return lhs.currect1 == rhs.currect1 && lhs.currect2 == rhs.currect2
}

public extension SequenceType {
    
    @warn_unused_result
    func concat<S : SequenceType where Generator.Element == S.Generator.Element>(with: S) -> ConcatSequence<Self, S> {
        return ConcatSequence(base1: self, base2: with)
    }
}

public extension CollectionType {
    
    @warn_unused_result
    func concat<S : CollectionType where Generator.Element == S.Generator.Element>(with: S) -> ConcatCollection<Self, S> {
        return ConcatCollection(base1: self, base2: with)
    }
}

public extension CollectionType where Index : BidirectionalIndexType {
    
    @warn_unused_result
    func concat<S : CollectionType where Generator.Element == S.Generator.Element, S.Index : BidirectionalIndexType>(with: S) -> ConcatBidirectionalCollection<Self, S> {
        return ConcatBidirectionalCollection(base1: self, base2: with)
    }
}

public extension LazySequenceType {
    
    @warn_unused_result
    func concat<S : SequenceType where Elements.Generator.Element == S.Generator.Element>(with: S) -> LazySequence<ConcatSequence<Elements, S>> {
        return ConcatSequence(base1: self.elements, base2: with).lazy
    }
}

public extension LazyCollectionType {
    
    @warn_unused_result
    func concat<S : CollectionType where Elements.Generator.Element == S.Generator.Element>(with: S) -> LazyCollection<ConcatCollection<Elements, S>> {
        return ConcatCollection(base1: self.elements, base2: with).lazy
    }
}

public extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    @warn_unused_result
    func concat<S : CollectionType where Elements.Generator.Element == S.Generator.Element, S.Index : BidirectionalIndexType>(with: S) -> LazyCollection<ConcatBidirectionalCollection<Elements, S>> {
        return ConcatBidirectionalCollection(base1: self.elements, base2: with).lazy
    }
}

public extension LazySequenceType {
    
    @warn_unused_result
    func append(newElement: Elements.Generator.Element) -> LazySequence<ConcatSequence<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

public extension LazyCollectionType {
    
    @warn_unused_result
    func append(newElement: Elements.Generator.Element) -> LazyCollection<ConcatCollection<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

public extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    @warn_unused_result
    func append(newElement: Elements.Generator.Element) -> LazyCollection<ConcatBidirectionalCollection<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

public extension CollectionType {
    
    @warn_unused_result
    func collect<Indices : SequenceType where Index == Indices.Generator.Element>(indices: Indices) -> [Generator.Element] {
        return indices.map { self[$0] }
    }
}

public struct LazyGatherGenerator<C: CollectionType, Indices: GeneratorType where C.Index == Indices.Element> : GeneratorType, SequenceType {
    
    private var seq : C
    private var indices : Indices
    
    /// The type of element returned by `next()`.
    public typealias Element = C.Generator.Element
    
    /// Advance to the next element and return it, or `nil` if no next
    /// element exists.
    ///
    /// - Requires: No preceding call to `self.next()` has returned `nil`.
    public mutating func next() -> Element? {
        return indices.next().map { seq[$0] }
    }
}

public struct LazyGatherSequence<C : CollectionType, Indices : SequenceType where C.Index == Indices.Generator.Element> : LazySequenceType {
    
    public typealias Generator = LazyGatherGenerator<C, Indices.Generator>
    
    public typealias Element = C.Generator.Element
    
    private let _base: C
    private let _indices: Indices
    
    public func generate() -> Generator {
        return LazyGatherGenerator(seq: _base, indices: _indices.generate())
    }
    
    public func underestimateCount() -> Int {
        return _indices.underestimateCount()
    }
}

public struct LazyGatherCollection<C : CollectionType, Indices : CollectionType where C.Index == Indices.Generator.Element> : LazyCollectionType {
    
    public typealias Generator = LazyGatherGenerator<C, Indices.Generator>
    
    public typealias Index = Indices.Index
    public typealias Element = C.Generator.Element
    
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
    
    public var count : Index.Distance {
        return _indices.count
    }
    
    public func generate() -> Generator {
        return LazyGatherGenerator(seq: _base, indices: _indices.generate())
    }
    
    public func underestimateCount() -> Int {
        return _indices.underestimateCount()
    }
}

public extension LazyCollectionType {
    
    @warn_unused_result
    func collect<Indices : SequenceType where Elements.Index == Indices.Generator.Element>(indices: Indices) -> LazyGatherSequence<Elements, Indices> {
        return LazyGatherSequence(_base: self.elements, _indices: indices)
    }
    
    @warn_unused_result
    func collect<Indices : CollectionType where Elements.Index == Indices.Generator.Element>(indices: Indices) -> LazyGatherCollection<Elements, Indices> {
        return LazyGatherCollection(_base: self.elements, _indices: indices)
    }
}

public extension CollectionType where Index : Strideable {
    
    @warn_unused_result
    func slice(by maxLength: Index.Stride) -> [SubSequence] {
        return Array(self.lazy.slice(by: maxLength))
    }
}

public extension LazyCollectionType where Elements.Index : Strideable {
    
    @warn_unused_result
    func slice(by maxLength: Elements.Index.Stride) -> LazyMapSequence<Zip2Sequence<StrideTo<Elements.Index>, ConcatSequence<StrideTo<Elements.Index>, CollectionOfOne<Elements.Index>>>, Elements.SubSequence> {
        let startIndex = self.elements.startIndex
        let endIndex = self.elements.endIndex
        let left = startIndex.stride(to: endIndex, by: maxLength)
        let right = startIndex.advancedBy(maxLength).stride(to: endIndex, by: maxLength)
        let mapper = zip(left, right.concat(CollectionOfOne(endIndex)))
        return mapper.lazy.map { self.elements[$0..<$1] }
    }
}

public extension CollectionType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Self.Index>) -> ConcatSequence<SubSequence, SubSequence> {
        return self.prefixUpTo(subRange.startIndex).concat(self.suffixFrom(subRange.endIndex))
    }
}

public extension CollectionType where SubSequence : CollectionType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Self.Index>) -> ConcatCollection<SubSequence, SubSequence> {
        return self.prefixUpTo(subRange.startIndex).concat(self.suffixFrom(subRange.endIndex))
    }
}

public extension CollectionType where SubSequence : CollectionType, SubSequence.Index : BidirectionalIndexType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Self.Index>) -> ConcatBidirectionalCollection<SubSequence, SubSequence> {
        return self.prefixUpTo(subRange.startIndex).concat(self.suffixFrom(subRange.endIndex))
    }
}

public extension LazyCollectionType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Elements.Index>) -> LazySequence<ConcatSequence<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Elements.Index>) -> LazyCollection<ConcatCollection<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType, Elements.SubSequence.Index : BidirectionalIndexType {
    
    /// Remove the indicated `subRange` of elements.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func dropRange(subRange: Range<Elements.Index>) -> LazyCollection<ConcatBidirectionalCollection<Elements.SubSequence, Elements.SubSequence>> {
        return self.elements.dropRange(subRange).lazy
    }
}

public extension LazyCollectionType {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func replaceRange<S : SequenceType where S.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: S) -> LazySequence<ConcatSequence<ConcatSequence<Elements.SubSequence, S>, Elements.SubSequence>> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex)).lazy
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func replaceRange<C : CollectionType where C.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: C) -> LazyCollection<ConcatCollection<ConcatCollection<Elements.SubSequence, C>, Elements.SubSequence>> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex)).lazy
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType, Elements.SubSequence.Index : BidirectionalIndexType {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func replaceRange<C : CollectionType where C.Index : BidirectionalIndexType, C.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: C) -> LazyCollection<ConcatBidirectionalCollection<ConcatBidirectionalCollection<Elements.SubSequence, C>, Elements.SubSequence>> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex)).lazy
    }
}

public extension SequenceType where Generator.Element : Comparable {
    
    /// Returns the maximal `SubSequence`s of `self`, in order, around elements
    /// match in `separator`.
    ///
    /// - Parameter maxSplits: The maximum number of `SubSequence`s to
    ///   return, minus 1.
    ///   If `maxSplit + 1` `SubSequence`s are returned, the last one is
    ///   a suffix of `self` containing the remaining elements.
    ///   The default value is `Int.max`.
    ///
    /// - Parameter allowEmptySubsequences: If `true`, an empty `SubSequence`
    ///   is produced in the result for each pair of consecutive elements
    ///   satisfying `isSeparator`.
    ///   The default value is `false`.
    ///
    /// - Requires: `maxSplit >= 0`
    @warn_unused_result
    func split<S: SequenceType where S.Generator.Element == Generator.Element>(separator: S, maxSplit: Int = Int.max, allowEmptySlices: Bool = false) -> [SubSequence] {
        return self.split(maxSplit, allowEmptySlices: allowEmptySlices) { separator.contains($0) }
    }
}

public extension LazySequenceType {
    
    /// Return a `Sequence` containing tuples satisfies `predicate` with each elements of two `sources`.
    @warn_unused_result
    func merge<S : SequenceType>(with: S, predicate: (Elements.Generator.Element, S.Generator.Element) -> Bool) -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<LazyFilterSequence<S>, (Elements.Generator.Element, S.Generator.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension LazyCollectionType {
    
    /// Return a `Collection` containing tuples satisfies `predicate` with each elements of two `sources`.
    @warn_unused_result
    func merge<C : CollectionType>(with: C, predicate: (Elements.Generator.Element, C.Generator.Element) -> Bool) -> LazyCollection<FlattenCollection<LazyMapCollection<Elements, LazyMapCollection<LazyFilterCollection<C>, (Elements.Generator.Element, C.Generator.Element)>>>> {
        return self.flatMap { lhs in with.lazy.filter { rhs in predicate(lhs, rhs) }.map { (lhs, $0) } }
    }
}

public extension SequenceType {
    
    /// Return an `Array` containing tuples satisfies `predicate` with each elements of two `sources`.
    @warn_unused_result
    func merge<S : SequenceType>(with: S, @noescape predicate: (Generator.Element, S.Generator.Element) throws -> Bool) rethrows -> [(Generator.Element, S.Generator.Element)] {
        var result: [(Generator.Element, S.Generator.Element)] = []
        for lhs in self {
            for rhs in with where try predicate(lhs, rhs) {
                result.append((lhs, rhs))
            }
        }
        return result
    }
}

public struct LazyChunkElementsGenerator<Base : GeneratorType> : GeneratorType, SequenceType {
    
    private var base: Base
    
    public mutating func next() -> Base.Element? {
        return base.next()
    }
}

public struct LazyChunkElementsSequence<Key : Equatable, Base : SequenceType> : LazySequenceType {
    
    public let key: Key
    private let base: Base
    
    public func generate() -> LazyChunkElementsGenerator<Base.Generator> {
        return LazyChunkElementsGenerator(base: base.generate())
    }
    
    public func underestimateCount() -> Int {
        return base.underestimateCount()
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsCollection<Key : Equatable, Base : CollectionType> : LazyCollectionType {
    
    public typealias Generator = LazyChunkElementsGenerator<Base.Generator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public subscript(index: Base.Index) -> Base.Generator.Element {
        return base[index]
    }
    
    public var count : Base.Index.Distance {
        return base.count
    }
    
    public func generate() -> LazyChunkElementsGenerator<Base.Generator> {
        return LazyChunkElementsGenerator(base: base.generate())
    }
    
    public func underestimateCount() -> Int {
        return base.underestimateCount()
    }
    
    public var elements: Base {
        return base
    }
}

public extension CollectionType {
    
    @warn_unused_result
    func chunk<Key : Equatable>(@noescape by: (Generator.Element) throws -> Key) rethrows -> [LazyChunkElementsSequence<Key, SubSequence>] {
        
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
            scanner = scanner.successor()
        }
        return table
    }
}

public extension CollectionType where SubSequence : CollectionType {
    
    @warn_unused_result
    func chunk<Key : Equatable>(@noescape by: (Generator.Element) throws -> Key) rethrows -> [LazyChunkElementsCollection<Key, SubSequence>] {
        
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
            scanner = scanner.successor()
        }
        return table
    }
}

public struct GroupElementsGenerator<Element> : GeneratorType, SequenceType {
    
    private var base: IndexingGenerator<[Element]>
    
    public mutating func next() -> Element? {
        return base.next()
    }
}

public struct GroupElementsCollection<Key : Equatable, Element> : CollectionType {
    
    public typealias Generator = GroupElementsGenerator<Element>
    
    public let key: Key
    private var base: [Element]
    
    public var startIndex : Int {
        return base.startIndex
    }
    public var endIndex : Int {
        return base.endIndex
    }
    
    public subscript(index: Int) -> Element {
        return base[index]
    }
    
    public var count : Int {
        return base.count
    }
    
    public func generate() -> GroupElementsGenerator<Element> {
        return GroupElementsGenerator(base: base.generate())
    }
    
    public func underestimateCount() -> Int {
        return base.underestimateCount()
    }
    
    public var elements: [Element] {
        return base
    }
}

public extension SequenceType {
    
    /// Groups the elements of a sequence according to a specified key selector function.
    @warn_unused_result
    func group<Key : Equatable>(@noescape by: (Generator.Element) throws -> Key) rethrows -> [GroupElementsCollection<Key, Generator.Element>] {
        
        var table: [GroupElementsCollection<Key, Generator.Element>] = []
        for item in self {
            let key = try by(item)
            if let idx = table.indexOf({ $0.key == key }) {
                table[idx].base.append(item)
            } else {
                table.append(GroupElementsCollection(key: key, base: [item]))
            }
        }
        return table
    }
}

public struct LazyUniqueGenerator<Base : GeneratorType> : GeneratorType, SequenceType {
    
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

public struct LazyUniqueSequence<Base : SequenceType> : LazySequenceType {
    
    private let base: Base
    private let isEquivalent: (Base.Generator.Element, Base.Generator.Element) -> Bool
    
    public func generate() -> LazyUniqueGenerator<Base.Generator> {
        return LazyUniqueGenerator(pass: [], base: base.generate(), isEquivalent: isEquivalent)
    }
}

public extension SequenceType where Generator.Element : Equatable {
    
    @warn_unused_result
    func unique() -> [Generator.Element] {
        var result: [Generator.Element] = []
        for item in self where !result.contains(item) {
            result.append(item)
        }
        return result
    }
}

public extension SequenceType {
    
    @warn_unused_result
    func unique(@noescape isEquivalent: (Generator.Element, Generator.Element) throws -> Bool) rethrows -> [Generator.Element] {
        var result: [Generator.Element] = []
        for item in self where try !result.contains({ try isEquivalent($0, item) }) {
            result.append(item)
        }
        return result
    }
}

public extension LazySequenceType where Elements.Generator.Element : Equatable {
    
    @warn_unused_result
    func unique() -> LazyUniqueSequence<Elements> {
        return LazyUniqueSequence(base: elements, isEquivalent: ==)
    }
}

public extension LazySequenceType {
    
    @warn_unused_result
    func unique(isEquivalent: (Elements.Generator.Element, Elements.Generator.Element) -> Bool) -> LazyUniqueSequence<Elements> {
        return LazyUniqueSequence(base: elements, isEquivalent: isEquivalent)
    }
}

public extension SequenceType {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    @warn_unused_result
    func minElement<R : Comparable>(@noescape by: (Generator.Element) throws -> R) rethrows -> Generator.Element? {
        return try self.minElement { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    @warn_unused_result
    func maxElement<R : Comparable>(@noescape by: (Generator.Element) throws -> R) rethrows -> Generator.Element? {
        return try self.maxElement { try by($0) < by($1) }
    }
}

public extension MutableCollectionType {
    
    /// Return an `Array` containing the sorted elements of `source`.
    /// according to `by`.
    ///
    /// The sorting algorithm is not stable (can change the relative order of
    /// elements that compare equal).
    @warn_unused_result(mutable_variant="sortInPlace")
    func sort<R : Comparable>(@noescape by: (Generator.Element) -> R) -> [Generator.Element] {
        return self.sort { by($0) < by($1) }
    }
}

public extension MutableCollectionType where Self.Index : RandomAccessIndexType {
    
    /// Sort `self` in-place according to `by`.
    ///
    /// The sorting algorithm is not stable (can change the relative order of
    /// elements that compare equal).
    mutating func sortInPlace<R : Comparable>(@noescape by: (Generator.Element) -> R) {
        self.sortInPlace { by($0) < by($1) }
    }
}

public extension Comparable {
    
    @warn_unused_result
    func clamp(range: ClosedInterval<Self>) -> Self {
        return min(max(self, range.start), range.end)
    }
}

public extension Float32 {
    
    @warn_unused_result
    static func random(includeOne includeOne: Bool = false) -> Float32 {
        if includeOne {
            return unsafeBitCast((0..<0x800000).randomElement()! + 0x3F800000 as UInt32, Float32.self) - 1
        }
        return unsafeBitCast((0..<0x7FFFFF).randomElement()! | 0x3F800000 as UInt32, Float32.self) - 1
    }
}

public extension Float64 {
    
    @warn_unused_result
    static func random(includeOne includeOne: Bool = false) -> Float64 {
        if includeOne {
            return unsafeBitCast((0..<0x10000000000000).randomElement()! + 0x3FF0000000000000 as UInt64, Float64.self) - 1
        }
        return unsafeBitCast((0..<0xFFFFFFFFFFFFF).randomElement()! | 0x3FF0000000000000 as UInt64, Float64.self) - 1
    }
}

@warn_unused_result
public func random(range: ClosedInterval<Float>) -> Float {
    let diff = range.end - range.start
    return (Float.random(includeOne: true) * diff) + range.start
}
@warn_unused_result
public func random(range: ClosedInterval<Double>) -> Double {
    let diff = range.end - range.start
    return (Double.random(includeOne: true) * diff) + range.start
}
@warn_unused_result
public func random(range: HalfOpenInterval<Float>) -> Float {
    let diff = range.end - range.start
    return (Float.random() * diff) + range.start
}
@warn_unused_result
public func random(range: HalfOpenInterval<Double>) -> Double {
    let diff = range.end - range.start
    return (Double.random() * diff) + range.start
}

public extension CollectionType where Index : RandomAccessIndexType {
    
    /// Returns a random element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(1).
    ///
    @warn_unused_result
    func randomElement() -> Generator.Element? {
        let _count = UIntMax(self.count.toIntMax())
        switch _count {
        case 0: return nil
        case 1: return self[self.startIndex]
        default: return self[self.startIndex.advancedBy(numericCast(random_uniform(_count)))]
        }
    }
}

public extension CollectionType {
    
    /// Return an `Array` containing the shuffled elements of `source`.
    @warn_unused_result(mutable_variant="shuffleInPlace")
    func shuffle() -> [Generator.Element] {
        var list = self.array
        list.shuffleInPlace()
        return list
    }
}

public extension MutableCollectionType where Index : RandomAccessIndexType {
    
    /// Shuffle `self` in-place.
    mutating func shuffleInPlace() {
        let _endIndex = self.endIndex
        for i in self.indices.dropLast() {
            let j = (i..<_endIndex).randomElement()!
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}

public extension RangeReplaceableCollectionType {
    
    mutating func replace<C : CollectionType where Generator.Element == C.Generator.Element>(with newElements: C) {
        self.replaceRange(self.indices, with: newElements)
    }
}

public extension MutableCollectionType where Index : BidirectionalIndexType {
    
    private mutating func reverseInPlace(range: Range<Index>) {
        var temp: Index?
        for (lhs, rhs) in zip(range, range.reverse()) {
            if lhs != rhs && temp != rhs {
                swap(&self[lhs], &self[rhs])
                temp = lhs
            } else {
                break
            }
        }
    }
    
    mutating func reverseInPlace() {
        self.reverseInPlace(self.indices)
    }
}

public extension MutableCollectionType where Index : BidirectionalIndexType, Generator.Element : Comparable {
    
    @warn_unused_result
    func nextPermute() -> Self {
        var _self = self
        if !_self.isEmpty {
            if let k = _self.indices.dropLast().lastOf({ _self[$0] < _self[$0.successor()] }) {
                let range = k.successor()..<_self.endIndex
                swap(&_self[k], &_self[range.lastOf { _self[k] < _self[$0] }!])
                _self.reverseInPlace(range)
            } else {
                _self.reverseInPlace()
            }
        }
        return _self
    }
}
