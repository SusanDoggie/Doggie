//
//  Foundation.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

public let isLittleEndian = TARGET_RT_LITTLE_ENDIAN == 1
public let isBigEndian = TARGET_RT_BIG_ENDIAN == 1

public let Progname = String.fromCString(getprogname())!

public func Environment(name: String) -> String? {
    return String.fromCString(getenv(name))
}

private let _bits_reverse_table: [UInt8] = [0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0, 0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8, 0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4, 0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC, 0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2, 0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA, 0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6, 0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE, 0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1, 0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9, 0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5, 0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD, 0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3, 0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB, 0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7, 0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF]

public extension UInt64 {
    
    var reverse: UInt64 {
        let _a = UInt64(_bits_reverse_table[Int(self & 0xFF)]) << 56
        let _b = UInt64(_bits_reverse_table[Int((self >> 8) & 0xFF)]) << 48
        let _c = UInt64(_bits_reverse_table[Int((self >> 16) & 0xFF)]) << 40
        let _d = UInt64(_bits_reverse_table[Int((self >> 24) & 0xFF)]) << 32
        let _e = UInt64(_bits_reverse_table[Int((self >> 32) & 0xFF)]) << 24
        let _f = UInt64(_bits_reverse_table[Int((self >> 40) & 0xFF)]) << 16
        let _g = UInt64(_bits_reverse_table[Int((self >> 48) & 0xFF)]) << 8
        let _h = UInt64(_bits_reverse_table[Int((self >> 56) & 0xFF)])
        return _a | _b | _c | _d | _e | _f | _g | _h
    }
    
    var hibit: UInt64 {
        var n = self
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        n |= n >> 8
        n |= n >> 16
        n |= n >> 32
        return n - (n >> 1)
    }
}
public extension UInt32 {
    
    var reverse: UInt32 {
        let _a = UInt32(_bits_reverse_table[Int(self & 0xFF)]) << 24
        let _b = UInt32(_bits_reverse_table[Int((self >> 8) & 0xFF)]) << 16
        let _c = UInt32(_bits_reverse_table[Int((self >> 16) & 0xFF)]) << 8
        let _d = UInt32(_bits_reverse_table[Int((self >> 24) & 0xFF)])
        return _a | _b | _c | _d
    }
    
    var hibit: UInt32 {
        var n = self
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        n |= n >> 8
        n |= n >> 16
        return n - (n >> 1)
    }
}
public extension UInt16 {
    
    var reverse: UInt16 {
        let _a = UInt16(_bits_reverse_table[Int(self & 0xFF)]) << 8
        let _b = UInt16(_bits_reverse_table[Int((self >> 8) & 0xFF)])
        return _a | _b
    }
    
    var hibit: UInt16 {
        var n = self
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        n |= n >> 8
        return n - (n >> 1)
    }
}
public extension UInt8 {
    
    var reverse: UInt8 {
        return _bits_reverse_table[Int(self)]
    }
    
    var hibit: UInt8 {
        var n = self
        n |= n >> 1
        n |= n >> 2
        n |= n >> 4
        return n - (n >> 1)
    }
}
public extension Int64 {
    
    var reverse: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).reverse)
    }
    var hibit: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).hibit)
    }
}
public extension Int32 {
    
    var reverse: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).reverse)
    }
    var hibit: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).hibit)
    }
}
public extension Int16 {
    
    var reverse: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).reverse)
    }
    var hibit: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).hibit)
    }
}
public extension Int8 {
    
    var reverse: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).reverse)
    }
    var hibit: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).hibit)
    }
}

extension IntegerType {
    
    public var isPower2 : Bool {
        return 0 < self && self & (self - 1) == 0
    }
    
    @warn_unused_result
    public func align(s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}

public extension String {
    
    var trim: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

public extension UnsafePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}
public extension UnsafeMutablePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}
public extension COpaquePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}

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

public func == <S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element>(lhs: ConcatCollectionIndex<S1, S2>, rhs: ConcatCollectionIndex<S1, S2>) -> Bool {
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

public func == <S1 : CollectionType, S2 : CollectionType where S1.Generator.Element == S2.Generator.Element, S1.Index : BidirectionalIndexType, S2.Index : BidirectionalIndexType>(lhs: ConcatBidirectionalCollectionIndex<S1, S2>, rhs: ConcatBidirectionalCollectionIndex<S1, S2>) -> Bool {
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
}

public extension CollectionType {
    
    @warn_unused_result
    func collect<I : SequenceType where Index == I.Generator.Element>(indices: I) -> [Generator.Element] {
        return Array(PermutationGenerator(elements: self, indices: indices))
    }
}

public extension LazyCollectionType {
    
    @warn_unused_result
    func collect<I : SequenceType where Elements.Index == I.Generator.Element>(indices: I) -> PermutationGenerator<Elements, I> {
        return PermutationGenerator(elements: self.elements, indices: indices)
    }
    
    @warn_unused_result
    func collect<I : CollectionType where Elements.Index == I.Generator.Element>(indices: I) -> PermutationCollection<Elements, I> {
        return PermutationCollection(_base: self.elements, _indices: indices)
    }
}

public extension CollectionType where Index : Strideable {
    
    @warn_unused_result
    public func stride(by stride: Index.Stride) -> [Generator.Element] {
        return Array(self.lazy.stride(by: stride))
    }
}

public extension LazyCollectionType where Elements.Index : Strideable {
    
    @warn_unused_result
    public func stride(by stride: Elements.Index.Stride) -> PermutationGenerator<Elements, StrideTo<Elements.Index>> {
        return self.collect(self.elements.startIndex.stride(to: self.elements.endIndex, by: stride))
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
    ///
    /// The sorting algorithm is not stable (can change the relative order of
    /// elements that compare equal).
    @warn_unused_result(mutable_variant="sortInPlace")
    func sort<R : Comparable>(@noescape by: (Generator.Element) -> R) -> [Generator.Element] {
        return self.sort { by($0) < by($1) }
    }
}

public extension MutableCollectionType where Self.Index : RandomAccessIndexType {
    
    /// Return an `Array` containing the sorted elements of `source`.
    ///
    /// The sorting algorithm is not stable (can change the relative order of
    /// elements that compare equal).
    mutating func sortInPlace<R : Comparable>(@noescape by: (Generator.Element) -> R) {
        self.sortInPlace { by($0) < by($1) }
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

public extension GeneratorType where Element : Comparable {
    
    @warn_unused_result
    func bound() -> (min: Element, max: Element) {
        var generator = self
        var min = generator.next()!
        var max = min
        while let val = generator.next() {
            if val < min {
                min = val
            } else if max < val {
                max = val
            }
        }
        return (min, max)
    }
}

public extension SequenceType where Generator.Element : Comparable {
    
    @warn_unused_result
    func bound() -> (min: Generator.Element, max: Generator.Element) {
        return self.generate().bound()
    }
}

public extension Comparable {
    
    @warn_unused_result
    func clamp(range: ClosedInterval<Self>) -> Self {
        if self <= range.start {
            return range.start
        }
        if self >= range.end {
            return range.end
        }
        return self
    }
}

public extension ForwardIndexType where Self : Comparable {
    
    @warn_unused_result
    func clamp(range: Range<Self>) -> Self {
        if self <= range.startIndex {
            return range.minElement()!
        }
        if self >= range.endIndex {
            return range.maxElement()!
        }
        return self
    }
}

public extension RangeReplaceableCollectionType {
    
    mutating func replace<C : CollectionType where Generator.Element == C.Generator.Element>(with newElements: C) {
        self.replaceRange(self.indices, with: newElements)
    }
}

public extension IntegerType {
    
    @warn_unused_result
    static func random() -> Self {
        var _r: Self = 0
        arc4random_buf(&_r, sizeof(Self))
        return _r
    }
}

@warn_unused_result
public func random_bytes(count: Int) -> [UInt8] {
    var buffer = [UInt8](count: count, repeatedValue: 0)
    arc4random_buf(&buffer, buffer.count)
    return buffer
}

@warn_unused_result
public func random(bound: UInt32) -> UInt32 {
    return arc4random_uniform(bound)
}
@warn_unused_result
public func random(range: Range<Int32>) -> Int32 {
    return Int32(random(UInt32(range.endIndex - range.startIndex))) + range.startIndex
}
@warn_unused_result
public func random(range: ClosedInterval<Double>) -> Double {
    let diff = range.end - range.start
    return ((Double(arc4random()) / Double(0x100000000 as UInt64)) * diff) + range.start
}
@warn_unused_result
public func random(range: HalfOpenInterval<Double>) -> Double {
    let diff = range.end - range.start
    return ((Double(arc4random()) / Double(0xFFFFFFFF as UInt64)) * diff) + range.start
}

@warn_unused_result
public func byteArray<T : IntegerType>(bytes: T ... ) -> [UInt8] {
    let count = bytes.count * sizeof(T)
    var buf = [UInt8](count: count, repeatedValue: 0)
    memcpy(&buf, bytes, count)
    return buf
}
@warn_unused_result
public func byteArray(data: UnsafePointer<Void>, length: Int) -> [UInt8] {
    var buf = [UInt8](count: length, repeatedValue: 0)
    memcpy(&buf, data, length)
    return buf
}

@warn_unused_result
public func unsafeBitCast<T, U>(x: T) -> U {
    return unsafeBitCast(x, U.self)
}

public func SDTimer(count count: Int = 1, @noescape block: () -> Void) -> NSTimeInterval {
    var time: clock_t = 0
    for _ in 0..<count {
        autoreleasepool {
            let start = clock()
            block()
            time += clock() - start
        }
    }
    return Double(time) / Double(count * Int(CLOCKS_PER_SEC))
}

@warn_unused_result
public func timeFormat(time: Double) -> String {
    let minutes = Int(floor(time / 60.0))
    let seconds = lround(time - Double(minutes * 60))
    return String(format: "%d:%02d", minutes, seconds)
}

public func autoreleasepool<R>(@noescape code: () -> R) -> R {
    var result: R!
    autoreleasepool {
        result = code()
    }
    return result
}

public extension String {
    @warn_unused_result
    static func fromBytes(buffer: [UInt8]) -> String! {
        return String.fromCString(UnsafePointer(buffer + [0]))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt64) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt32) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt16) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt8) -> String! {
        let buffer: [UInt8] = [cs, 0]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int64) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int32) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int16) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int8) -> String! {
        let buffer: [UInt8] = [UInt8(cs), 0]
        return String.fromCString(UnsafePointer(buffer))
    }
}

@warn_unused_result
public func tensorFormatter(data: (Double, String)...) -> String {
    var print = ""
    for val in data where val.0 != 0 {
        if print != "" && !val.0.isSignMinus {
            print += "+"
        }
        switch val {
        case (1.0, ""):
            print += "1.0"
        case (1.0, _):
            print += "\(val.1)"
        case (-1.0, ""):
            print += "-1.0"
        case (-1.0, _):
            print += "-\(val.1)"
        default:
            let _val = String(format: "%.2f", val.0)
            print += "\(_val)\(val.1)"
        }
    }
    if print == "" {
        print = "0.0"
    }
    return print
}

@warn_unused_result
public func hash<S : SequenceType where S.Generator.Element : Hashable>(val: S) -> Int {
    let _val = val.array
    switch _val.count {
    case 0, 1: return Set(_val.lazy.map { $0.hashValue }).hashValue
    case 2:
        let a = _val[0].hashValue
        let b = _val[1].hashValue
        return Set([a &+ b, a &- b]).hashValue
    default: return hash(hash(_val.prefix(2)), hash(_val.dropFirst(2)))
    }
}

@warn_unused_result
public func hash<T: Hashable>(val: T ... ) -> Int {
    return hash(val)
}

@warn_unused_result
public func == <T : Comparable>(lhs: T, rhs: T) -> Bool {
    return !(lhs < rhs || rhs < lhs)
}

public struct Graph<Node : Hashable, Link> : CollectionType {
    
    public typealias Generator = GraphGenerator<Node, Link>
    
    private var table: [Node:[Node:Link]]
    
    /// Create an empty graph.
    public init() {
        table = Dictionary()
    }
    
    /// The number of links in the graph.
    ///
    /// - Complexity: O(`count of from nodes`).
    public var count: Int {
        return table.reduce(0) { $0 + $1.1.count }
    }
    
    /// - Complexity: O(1).
    @warn_unused_result
    public func generate() -> Generator {
        return Generator(_base: table.lazy.flatMap { from, to in to.lazy.map { (from, $0, $1) } }.generate())
    }
    
    /// The position of the first element in a non-empty dictionary.
    ///
    /// Identical to `endIndex` in an empty dictionary.
    ///
    /// - Complexity: Amortized O(1).
    public var startIndex: GraphIndex<Node, Link> {
        let _base = table.indices.lazy.flatMap { from in self.table[from].1.indices.lazy.map { (from, $0) } }
        return GraphIndex(base: _base, current: _base.startIndex)
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// - Complexity: Amortized O(1).
    public var endIndex: GraphIndex<Node, Link> {
        let _base = table.indices.lazy.flatMap { from in self.table[from].1.indices.lazy.map { (from, $0) } }
        return GraphIndex(base: _base, current: _base.endIndex)
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(idx: GraphIndex<Node, Link>) -> Generator.Element {
        let _idx = idx.index
        let (from, to_val) = table[_idx.0]
        let (to, val) = to_val[_idx.1]
        return (from, to, val)
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(from fromNode: Node, to toNode: Node) -> Link? {
        get {
            return linkValue(from: fromNode, to: toNode)
        }
        set {
            if newValue != nil {
                updateLink(from: fromNode, to: toNode, with: newValue!)
            } else {
                removeLink(from: fromNode, to: toNode)
            }
        }
    }
    
    /// Return `true` iff it has link from `fromNode` to `toNode`.
    ///
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func isLinked(from fromNode: Node, to toNode: Node) -> Bool {
        return linkValue(from: fromNode, to: toNode) != nil
    }
    
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func linkValue(from fromNode: Node, to toNode: Node) -> Link? {
        return table[fromNode]?[toNode]
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func updateLink(from fromNode: Node, to toNode: Node, with link: Link) -> Link? {
        if table[fromNode] == nil {
            table[fromNode] = [toNode: link]
            return nil
        }
        return table[fromNode]!.updateValue(link, forKey: toNode)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func removeLink(from fromNode: Node, to toNode: Node) -> Link? {
        if var list = table[fromNode], let result = list[toNode] {
            list.removeValueForKey(toNode)
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValueForKey(fromNode)
            }
            return result
        }
        return nil
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - Complexity: O(`count of nodes`).
    @warn_unused_result
    public func contains(node: Node) -> Bool {
        for (_node, list) in table where _node == node || list.keys.contains(node) {
            return true
        }
        return false
    }
    
    /// `true` iff `count == 0`.
    public var isEmpty: Bool {
        return table.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeNode(node: Node) {
        table[node] = nil
        for (fromNode, var list) in table {
            list.removeValueForKey(node)
            if list.count != 0 {
                table.updateValue(list, forKey: fromNode)
            } else {
                table.removeValueForKey(fromNode)
            }
        }
    }
    
    /// Remove all elements.
    ///
    /// - parameter keepCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeAll(keepCapacity: Bool = false) {
        table.removeAll(keepCapacity: keepCapacity)
    }
    
    /// A collection containing just the links of `self`.
    public var links: LazyMapCollection<Graph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - Complexity: O(`count of nodes`).
    public var nodes: Set<Node> {
        var _nodes = Set<Node>()
        for (_node, list) in table {
            _nodes.insert(_node)
            _nodes.unionInPlace(list.keys)
        }
        return _nodes
    }
    
    /// A set of nodes which has connection with `nearNode`.
    @warn_unused_result
    public func nodes(near nearNode: Node) -> Set<Node> {
        return Set(self.nodes(from: nearNode).concat(self.nodes(to: nearNode)).lazy.map { $0.0 })
    }
    
    /// A collection of nodes which connected from `fromNode`.
    @warn_unused_result
    public func nodes(from fromNode: Node) -> AnyForwardCollection<(Node, Link)> {
        return table[fromNode]?.any ?? EmptyCollection().any
    }
    
    /// A collection of nodes which connected to `toNode`.
    @warn_unused_result
    public func nodes(to toNode: Node) -> AnyForwardCollection<(Node, Link)> {
        return table.lazy.flatMap { from, to in to[toNode].map { (from, $0) } }.any
    }
}

extension Graph: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joinWithSeparator(", "))]"
    }
    public var debugDescription: String {
        
        return "[\(self.map { "(from: \($0.from), to: \($0.to)): \($0.2)" }.joinWithSeparator(", "))]"
    }
}

public struct GraphIndex<Node : Hashable, Link> : ForwardIndexType {
    
    private typealias Base = LazyCollection<FlattenCollection<LazyMapCollection<Range<DictionaryIndex<Node, [Node : Link]>>, LazyMapCollection<Range<DictionaryIndex<Node, Link>>, (DictionaryIndex<Node, [Node : Link]>, DictionaryIndex<Node, Link>)>>>>
    
    private let base: Base
    private let current: Base.Index
    
    private var index: Base.Generator.Element {
        return base[current]
    }
    
    @warn_unused_result
    public func successor() -> GraphIndex<Node, Link> {
        return GraphIndex(base: base, current: current.successor())
    }
}

public func == <Node : Hashable, Link>(lhs: GraphIndex<Node, Link>, rhs: GraphIndex<Node, Link>) -> Bool {
    return lhs.current == rhs.current
}

public struct GraphGenerator<Node : Hashable, Link> : GeneratorType {
    
    public typealias Element = (from: Node, to: Node, Link)
    
    private var _base: FlattenGenerator<LazyMapGenerator<DictionaryGenerator<Node, [Node : Link]>, LazyMapCollection<[Node : Link], (Node, Node, Link)>>>
    
    public mutating func next() -> Element? {
        return _base.next()
    }
}

extension GraphGenerator: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "GraphGenerator"
    }
    public var debugDescription: String {
        return "GraphGenerator"
    }
}

public struct UndirectedGraph<Node : Hashable, Link> : CollectionType {
    
    public typealias Generator = UndirectedGraphGenerator<Node, Link>
    
    private var graph: Graph<Node, Link>
    
    /// Create an empty graph.
    public init() {
        graph = Graph()
    }
    
    /// The number of links in the graph.
    ///
    /// - Complexity: O(`count of from nodes`).
    public var count: Int {
        return graph.count
    }
    
    /// - Complexity: O(1).
    @warn_unused_result
    public func generate() -> Generator {
        return Generator(base: graph.generate())
    }
    
    /// The position of the first element in a non-empty dictionary.
    ///
    /// Identical to `endIndex` in an empty dictionary.
    ///
    /// - Complexity: Amortized O(1).
    public var startIndex: UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: graph.startIndex)
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// - Complexity: Amortized O(1).
    public var endIndex: UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: graph.endIndex)
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(idx: UndirectedGraphIndex<Node, Link>) -> Generator.Element {
        return graph[idx.base]
    }
    
    /// - Complexity: Amortized O(1).
    public subscript(fromNode: Node, toNode: Node) -> Link? {
        get {
            return linkValue(fromNode, toNode)
        }
        set {
            if newValue != nil {
                updateLink(fromNode, toNode, with: newValue!)
            } else {
                removeLink(fromNode, toNode)
            }
        }
    }
    
    /// Return `true` iff it has link with `fromNode` and `toNode`.
    ///
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func isLinked(fromNode: Node, _ toNode: Node) -> Bool {
        return linkValue(fromNode, toNode) != nil
    }
    
    /// - Complexity: Amortized O(1).
    @warn_unused_result
    public func linkValue(fromNode: Node, _ toNode: Node) -> Link? {
        return graph.linkValue(from: fromNode, to: toNode) ?? graph.linkValue(from: toNode, to: fromNode)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func updateLink(fromNode: Node, _ toNode: Node, with link: Link) -> Link? {
        return graph.updateLink(from: fromNode, to: toNode, with: link) ?? graph.removeLink(from: toNode, to: fromNode)
    }
    
    /// - Complexity: Amortized O(1).
    public mutating func removeLink(fromNode: Node, _ toNode: Node) -> Link? {
        return graph.removeLink(from: fromNode, to: toNode) ?? graph.removeLink(from: toNode, to: fromNode)
    }
    
    /// `true` iff `self` contains `node`.
    ///
    /// - Complexity: O(`count of nodes`).
    @warn_unused_result
    public func contains(node: Node) -> Bool {
        return graph.contains(node)
    }
    
    /// `true` iff `count == 0`.
    public var isEmpty: Bool {
        return graph.isEmpty
    }
    
    /// Remove a node with all connections with it.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeNode(node: Node) {
        graph.removeNode(node)
    }
    
    /// Remove all elements.
    ///
    /// - parameter keepCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - Complexity: O(`count of nodes`).
    public mutating func removeAll(keepCapacity: Bool = false) {
        graph.removeAll(keepCapacity)
    }
    
    /// A collection containing just the links of `self`.
    public var links: LazyMapCollection<UndirectedGraph<Node, Link>, Link> {
        return self.lazy.map { $0.2 }
    }
    
    /// A set containing just the nodes of `self`.
    ///
    /// - Complexity: O(`count of nodes`).
    public var nodes: Set<Node> {
        return graph.nodes
    }
    
    /// A collection of nodes which has connection with `nearNode`.
    @warn_unused_result
    public func nodes(near nearNode: Node) -> ConcatCollection<AnyForwardCollection<(Node, Link)>, AnyForwardCollection<(Node, Link)>> {
        return graph.nodes(from: nearNode).concat(graph.nodes(to: nearNode))
    }
}

extension UndirectedGraph: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        
        return "[\(self.map { "(\($0.0), \($0.1)): \($0.2)" }.joinWithSeparator(", "))]"
    }
    public var debugDescription: String {
        
        return "[\(self.map { "(\($0.0), \($0.1)): \($0.2)" }.joinWithSeparator(", "))]"
    }
}

public struct UndirectedGraphIndex<Node : Hashable, Link> : ForwardIndexType {
    
    private let base: Graph<Node, Link>.Index
    
    @warn_unused_result
    public func successor() -> UndirectedGraphIndex<Node, Link> {
        return UndirectedGraphIndex(base: base.successor())
    }
}

public func == <Node : Hashable, Link>(lhs: UndirectedGraphIndex<Node, Link>, rhs: UndirectedGraphIndex<Node, Link>) -> Bool {
    return lhs.base == rhs.base
}

public struct UndirectedGraphGenerator<Node : Hashable, Link> : GeneratorType {
    
    public typealias Element = (Node, Node, Link)
    
    private var base: Graph<Node, Link>.Generator
    
    public mutating func next() -> Element? {
        return base.next()
    }
}

extension UndirectedGraphGenerator: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "UndirectedGraphGenerator"
    }
    public var debugDescription: String {
        return "UndirectedGraphGenerator"
    }
}
