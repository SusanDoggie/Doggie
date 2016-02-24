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

public extension GeneratorType {
    
    var any: AnyGenerator<Element> {
        return anyGenerator(self)
    }
}

public extension SequenceType {
    
    var array: [Generator.Element] {
        return self as? [Generator.Element] ?? Array(self)
    }
    
    var any: AnySequence<Generator.Element> {
        return AnySequence(self)
    }
}

public extension CollectionType {
    
    /// Returns sub-sequence of `self`.
    var slice: SubSequence {
        return self as? SubSequence ?? self[self.indices]
    }
    
    var any: AnyForwardCollection<Generator.Element> {
        return AnyForwardCollection(self)
    }
}

public extension CollectionType where Index : BidirectionalIndexType {
    
    var any: AnyBidirectionalCollection<Generator.Element> {
        return AnyBidirectionalCollection(self)
    }
}

public extension CollectionType where Index : RandomAccessIndexType {
    
    var any: AnyRandomAccessCollection<Generator.Element> {
        return AnyRandomAccessCollection(self)
    }
}

public extension LazySequenceType {
    
    var any: LazySequence<AnySequence<Elements.Generator.Element>> {
        return AnySequence(self.elements).lazy
    }
}

public extension LazyCollectionType {
    
    var any: LazyCollection<AnyForwardCollection<Elements.Generator.Element>> {
        return AnyForwardCollection(self.elements).lazy
    }
}

public extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    var any: LazyCollection<AnyBidirectionalCollection<Elements.Generator.Element>> {
        return AnyBidirectionalCollection(self.elements).lazy
    }
}

public extension LazyCollectionType where Elements.Index : RandomAccessIndexType {
    
    var any: LazyCollection<AnyRandomAccessCollection<Elements.Generator.Element>> {
        return AnyRandomAccessCollection(self.elements).lazy
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

extension CollectionType where Generator.Element : Equatable {
    
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// initial elements.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    public func prefixUntil(element: Self.Generator.Element) -> Self.SubSequence {
        return self.prefixUpTo(self.indexOf(element) ?? self.endIndex)
    }
}

extension CollectionType {
    
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// initial elements.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    public func prefixUntil(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.SubSequence {
        return self.prefixUpTo(try self.indexOf(predicate) ?? self.endIndex)
    }
}

extension CollectionType where Generator.Element : Equatable, Index : BidirectionalIndexType {
    /// Returns a subsequence, until a element equal to `value`, containing the
    /// final elements of `self`.
    ///
    /// If none of elements equal to `value`, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    public func suffixUntil(element: Self.Generator.Element) -> Self.SubSequence {
        return self.suffixFrom(self.reverse().indexOf(element)?.base ?? self.startIndex)
    }
}

extension CollectionType where Index : BidirectionalIndexType {
    /// Returns a subsequence, until a element satisfying the predicate, containing the
    /// final elements of `self`.
    ///
    /// If none of elements satisfying the predicate, the result contains all
    /// the elements of `self`.
    ///
    /// - Complexity: O(`self.count`)
    @warn_unused_result
    public func suffixUntil(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.SubSequence {
        return self.suffixFrom(try self.reverse().indexOf(predicate)?.base ?? self.startIndex)
    }
}

public struct OptionOneGenerator<T> : GeneratorType {
    
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
    
    public var startIndex : Bit {
        return .Zero
    }
    public var endIndex : Bit {
        return value == nil ? .Zero : .One
    }
    public subscript(idx: Bit) -> T {
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

public struct LazyScanGenerator<Base: GeneratorType, Element> : GeneratorType {
    
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

public struct ConcatGenerator<G1: GeneratorType, G2: GeneratorType where G1.Element == G2.Element> : GeneratorType {
    
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

extension SequenceType {
    
    @warn_unused_result
    public func concat<S : SequenceType where Generator.Element == S.Generator.Element>(with: S) -> ConcatSequence<Self, S> {
        return ConcatSequence(base1: self, base2: with)
    }
}

extension CollectionType {
    
    @warn_unused_result
    public func concat<S : CollectionType where Generator.Element == S.Generator.Element>(with: S) -> ConcatCollection<Self, S> {
        return ConcatCollection(base1: self, base2: with)
    }
}

extension CollectionType where Index : BidirectionalIndexType {
    
    @warn_unused_result
    public func concat<S : CollectionType where Generator.Element == S.Generator.Element, S.Index : BidirectionalIndexType>(with: S) -> ConcatBidirectionalCollection<Self, S> {
        return ConcatBidirectionalCollection(base1: self, base2: with)
    }
}

extension LazySequenceType {
    
    @warn_unused_result
    public func concat<S : SequenceType where Elements.Generator.Element == S.Generator.Element>(with: S) -> LazySequence<ConcatSequence<Elements, S>> {
        return ConcatSequence(base1: self.elements, base2: with).lazy
    }
}

extension LazyCollectionType {
    
    @warn_unused_result
    public func concat<S : CollectionType where Elements.Generator.Element == S.Generator.Element>(with: S) -> LazyCollection<ConcatCollection<Elements, S>> {
        return ConcatCollection(base1: self.elements, base2: with).lazy
    }
}

extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    @warn_unused_result
    public func concat<S : CollectionType where Elements.Generator.Element == S.Generator.Element, S.Index : BidirectionalIndexType>(with: S) -> LazyCollection<ConcatBidirectionalCollection<Elements, S>> {
        return ConcatBidirectionalCollection(base1: self.elements, base2: with).lazy
    }
}

extension LazySequenceType {
    
    func append(newElement: Elements.Generator.Element) -> LazySequence<ConcatSequence<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

extension LazyCollectionType {
    
    func append(newElement: Elements.Generator.Element) -> LazyCollection<ConcatCollection<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

extension LazyCollectionType where Elements.Index : BidirectionalIndexType {
    
    func append(newElement: Elements.Generator.Element) -> LazyCollection<ConcatBidirectionalCollection<Elements, CollectionOfOne<Elements.Generator.Element>>> {
        return self.concat(CollectionOfOne(newElement))
    }
}

public struct PermutationCollection<C : CollectionType, I : CollectionType where C.Index == I.Generator.Element> : CollectionType {
    
    public typealias Generator = PermutationGenerator<C, I>
    
    public typealias Index = I.Index
    public typealias Element = C.Generator.Element
    
    private let _base: C
    private let _indices: I
    
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
        return PermutationGenerator(elements: _base, indices: _indices)
    }
    
    public func underestimateCount() -> Int {
        return _indices.underestimateCount()
    }
}

public extension CollectionType {
    
    @warn_unused_result
    func collect<I : SequenceType where Index == I.Generator.Element>(indices: I) -> PermutationGenerator<Self, I> {
        return PermutationGenerator(elements: self, indices: indices)
    }
    
    @warn_unused_result
    func collect<I : CollectionType where Index == I.Generator.Element>(indices: I) -> PermutationCollection<Self, I> {
        return PermutationCollection(_base: self, _indices: indices)
    }
}

public extension LazyCollectionType {
    
    @warn_unused_result
    func collect<I : SequenceType where Elements.Index == I.Generator.Element>(indices: I) -> LazySequence<PermutationGenerator<Elements, I>> {
        return self.elements.collect(indices).lazy
    }
    
    @warn_unused_result
    func collect<I : CollectionType where Elements.Index == I.Generator.Element>(indices: I) -> LazyCollection<PermutationCollection<Elements, I>> {
        return self.elements.collect(indices).lazy
    }
}

public struct LazyStrideSequence<C: CollectionType where C.Index : Strideable> : LazySequenceType {
    
    private let base: C
    private let stride: C.Index.Stride
    
    public func generate() -> LazyStrideGenerator<C> {
        return LazyStrideGenerator(base: base, stride: stride)
    }
}

public struct LazyStrideGenerator<C: CollectionType where C.Index : Strideable> : GeneratorType {
    
    private let base: C
    private var left: C.Index?
    private var mapper: ConcatGenerator<StrideToGenerator<C.Index>, GeneratorOfOne<C.Index>>
    
    private init(base: C, stride: C.Index.Stride) {
        self.base = base
        let startIndex = base.startIndex
        let endIndex = base.endIndex
        self.mapper = startIndex.stride(to: endIndex, by: stride).concat(CollectionOfOne(endIndex)).generate()
        self.left = self.mapper.next()
    }
    
    public mutating func next() -> C.SubSequence? {
        if let left = self.left, let right = mapper.next() {
            self.left = right
            return base[left..<right]
        }
        self.left = nil
        return nil
    }
}

public extension CollectionType where Index : Strideable {
    
    @warn_unused_result
    public func stride(by maxLength: Index.Stride) -> [SubSequence] {
        return Array(self.lazy.stride(by: maxLength))
    }
}

public extension LazyCollectionType where Elements.Index : Strideable {
    
    @warn_unused_result
    public func stride(by maxLength: Elements.Index.Stride) -> LazyStrideSequence<Elements> {
        return LazyStrideSequence(base: self.elements, stride: maxLength)
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
    func replaceRange<S : SequenceType where S.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: S) -> ConcatSequence<ConcatSequence<Elements.SubSequence, S>, Elements.SubSequence> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex))
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func replaceRange<C : CollectionType where C.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: C) -> ConcatCollection<ConcatCollection<Elements.SubSequence, C>, Elements.SubSequence> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex))
    }
}

public extension LazyCollectionType where Elements.SubSequence : CollectionType, Elements.SubSequence.Index : BidirectionalIndexType {
    
    /// Replace the given `subRange` of elements with `newElements`.
    ///
    /// Invalidates all indices with respect to `self`.
    @warn_unused_result
    func replaceRange<C : CollectionType where C.Index : BidirectionalIndexType, C.Generator.Element == Elements.SubSequence.Generator.Element>(subRange: Range<Elements.Index>, with newElements: C) -> ConcatBidirectionalCollection<ConcatBidirectionalCollection<Elements.SubSequence, C>, Elements.SubSequence> {
        return self.elements.prefixUpTo(subRange.startIndex).concat(newElements).concat(self.elements.suffixFrom(subRange.endIndex))
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

public extension SequenceType {
    
    @warn_unused_result
    func chunk<Key : Equatable>(@noescape by: (Generator.Element) throws -> Key) rethrows -> [(key: Key, elements: [Generator.Element])] {
        
        var table: [(key: Key, elements: [Generator.Element])] = []
        var pass: Key?
        for item in self {
            let key = try by(item)
            if pass == key {
                table[table.endIndex - 1].1.append(item)
            } else {
                table.append((key, [item]))
            }
            pass = key
        }
        return table
    }
}

public extension SequenceType {
    
    /// Groups the elements of a sequence according to a specified key selector function.
    @warn_unused_result
    func group<Key : Equatable>(@noescape by: (Generator.Element) throws -> Key) rethrows -> [(key: Key, elements: [Generator.Element])] {
        
        var table: [(key: Key, elements: [Generator.Element])] = []
        for item in self {
            let key = try by(item)
            if let idx = table.indexOf({ $0.0 == key }) {
                table[idx].1.append(item)
            } else {
                table.append((key, [item]))
            }
        }
        return table
    }
}

extension SequenceType {
    /// Returns the minimum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    @warn_unused_result
    public func minElement<R : Comparable>(@noescape by: (Generator.Element) throws -> R) rethrows -> Generator.Element? {
        return try self.minElement { try by($0) < by($1) }
    }
    /// Returns the maximum element in `self` or `nil` if the sequence is empty.
    ///
    /// - Complexity: O(`elements.count`).
    ///
    @warn_unused_result
    public func maxElement<R : Comparable>(@noescape by: (Generator.Element) throws -> R) rethrows -> Generator.Element? {
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
        default: return self[self.startIndex.advancedBy(numericCast(arc4random_uniform(_count)))]
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

public extension RangeReplaceableCollectionType {
    
    mutating func replace<C : CollectionType where Generator.Element == C.Generator.Element>(with newElements: C) {
        self.replaceRange(self.indices, with: newElements)
    }
}
