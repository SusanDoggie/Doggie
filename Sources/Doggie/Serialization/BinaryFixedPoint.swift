//
//  BinaryFixedPoint.swift
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

public protocol BinaryFixedPoint : Numeric, Hashable, Strideable, CustomStringConvertible, ExpressibleByFloatLiteral {
    
    associatedtype BitPattern : FixedWidthInteger
    
    associatedtype RepresentingValue : BinaryFloatingPoint
    
    static var fractionBitCount: Int { get }
    
    var bitPattern: BitPattern { get }
    
    init(bitPattern: BitPattern)
    
    var representingValue : RepresentingValue { get set }
    
    init(representingValue: RepresentingValue)
}

extension BinaryFloatingPoint {
    
    @inlinable
    @inline(__always)
    public init<T: BinaryFixedPoint>(_ value: T) where T.RepresentingValue == Self {
        self = value.representingValue
    }
}

extension BinaryFixedPoint {
    
    @inlinable
    @inline(__always)
    public init(integerLiteral value: RepresentingValue.IntegerLiteralType) {
        self.init(representingValue: RepresentingValue(integerLiteral: value))
    }
    
    @inlinable
    @inline(__always)
    public init(floatLiteral value: RepresentingValue.FloatLiteralType) {
        self.init(representingValue: RepresentingValue(floatLiteral: value))
    }
    
    @inlinable
    @inline(__always)
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @inlinable
    @inline(__always)
    public init(_ value: RepresentingValue) {
        self.init(representingValue: value)
    }
}

extension BinaryFixedPoint where BitPattern : ByteOutputStreamable {
    
    @inlinable
    @inline(__always)
    public func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(bitPattern)
    }
}

extension BinaryFixedPoint where BitPattern : ByteDecodable {
    
    @inlinable
    @inline(__always)
    public init(from data: inout Data) throws {
        self.init(bitPattern: try BitPattern(from: &data))
    }
}

extension BinaryFixedPoint where RepresentingValue.RawSignificand : FixedWidthInteger {
    
    @_transparent
    @usableFromInline
    static var _fractionOffset: Int {
        return Self.fractionBitCount - RepresentingValue.significandBitCount
    }
    
    @_transparent
    @usableFromInline
    static var _exponentBias: Int {
        let s = RepresentingValue.exponentBitCount - 1
        return (1 << s) - 1
    }
    
    @inlinable
    @inline(__always)
    public init(representingValue: RepresentingValue) {
        if representingValue.exponentBitPattern == 0 && representingValue.significandBitPattern == 0 {
            self.init(bitPattern: 0)
        } else {
            let offset = Self._fractionOffset + Int(representingValue.exponent)
            let _pattern = RepresentingValue.RawSignificand(1 << RepresentingValue.significandBitCount) | representingValue.significandBitPattern
            let pattern = _pattern << offset
            if BitPattern.isSigned {
                if pattern == 0 {
                    self.init(bitPattern: 0)
                } else if representingValue.sign == .minus {
                    self.init(bitPattern: ~BitPattern(clamping: pattern - 1))
                } else {
                    self.init(bitPattern: BitPattern(clamping: pattern))
                }
            } else {
                if representingValue.sign == .minus {
                    self.init(bitPattern: 0)
                } else {
                    self.init(bitPattern: BitPattern(clamping: pattern))
                }
            }
        }
    }
    
    @_transparent
    public var representingValue : RepresentingValue {
        get {
            if bitPattern == 0 {
                return 0
            } else {
                let _bitPattern = bitPattern < 0 ? RepresentingValue.RawSignificand(~bitPattern) + 1 : RepresentingValue.RawSignificand(bitPattern)
                let exponent = Int(log2(_bitPattern)) - Self.fractionBitCount
                let offset = Self._fractionOffset + exponent
                let exponentBitPattern = RepresentingValue.RawExponent(Self._exponentBias + exponent)
                let significandBitMask: RepresentingValue.RawSignificand = (1 << RepresentingValue.significandBitCount) - 1
                let significandBitPattern = (_bitPattern >> offset) & significandBitMask
                if BitPattern.isSigned {
                    return RepresentingValue(sign: bitPattern < 0 ? .minus : .plus, exponentBitPattern: exponentBitPattern, significandBitPattern: significandBitPattern)
                } else {
                    return RepresentingValue(sign: .plus, exponentBitPattern: exponentBitPattern, significandBitPattern: significandBitPattern)
                }
            }
        }
        set {
            self = Self(representingValue: newValue)
        }
    }
}

extension BinaryFixedPoint {
    
    @_transparent
    public static var isSigned: Bool {
        return BitPattern.isSigned
    }
}

extension BinaryFixedPoint {
    
    @_transparent
    public var description: String {
        return "\(representingValue)"
    }
    
    @_transparent
    public var magnitude: Self {
        return Self(bitPattern: BitPattern(exactly: bitPattern.magnitude) ?? .max)
    }
    
    @_transparent
    public static var min: Self {
        return Self(bitPattern: BitPattern.min)
    }
    
    @_transparent
    public static var max: Self {
        return Self(bitPattern: BitPattern.max)
    }
    
    @inlinable
    @inline(__always)
    public func distance(to other: Self) -> RepresentingValue.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @inlinable
    @inline(__always)
    public func advanced(by n: RepresentingValue.Stride) -> Self {
        return Self(representingValue: self.representingValue.advanced(by: n))
    }
    
    @inlinable
    @inline(__always)
    public func remainder(dividingBy other: Self) -> Self {
        return self - other * (self / other).rounded(.toNearestOrEven)
    }
    
    @inlinable
    @inline(__always)
    public mutating func formRemainder(dividingBy other: Self) {
        self = self.remainder(dividingBy: other)
    }
    
    @inlinable
    @inline(__always)
    public func truncatingRemainder(dividingBy other: Self) -> Self {
        return self - other * (self / other).rounded(.towardZero)
    }
    
    @inlinable
    @inline(__always)
    public mutating func formTruncatingRemainder(dividingBy other: Self) {
        self = self.truncatingRemainder(dividingBy: other)
    }
    
    @inlinable
    @inline(__always)
    public func squareRoot() -> Self {
        return Self(representingValue: self.representingValue.squareRoot())
    }
    
    @inlinable
    @inline(__always)
    public mutating func formSquareRoot() {
        self.representingValue.formSquareRoot()
    }
    
    @inlinable
    @inline(__always)
    public func addingProduct(_ lhs: Self, _ rhs: Self) -> Self {
        return self + lhs * rhs
    }
    
    @inlinable
    @inline(__always)
    public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
        self += lhs * rhs
    }
    
    @inlinable
    @inline(__always)
    public func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        
        let mask = ((1 as BitPattern) << Self.fractionBitCount) - 1
        let mask2 = (1 as BitPattern.Magnitude) << (Self.fractionBitCount - 1)
        
        let fractional = bitPattern.magnitude & BitPattern.Magnitude(mask)
        
        let floor = Self(bitPattern: bitPattern & ~mask)
        let ceil = fractional == 0 ? floor : floor + 1
        let trunc = bitPattern < 0 ? ceil : floor
        let round = (fractional < mask2) == (bitPattern < 0) ? ceil : floor
        
        switch rule {
        case .toNearestOrAwayFromZero: return round
        case .toNearestOrEven:
            if fractional == mask2 {
                return (bitPattern.magnitude & (mask2 << 1) == 0) == (bitPattern < 0) ? ceil : floor
            } else {
                return round
            }
        case .towardZero: return trunc
        case .awayFromZero: return bitPattern < 0 ? floor : ceil
        case .up: return ceil
        case .down: return floor
        @unknown default: return round
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func round(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        self = self.rounded(rule)
    }
    
    @inlinable
    @inline(__always)
    public func isEqual(to other: Self) -> Bool {
        return self.bitPattern == other.bitPattern
    }
    
    @inlinable
    @inline(__always)
    public func isLess(than other: Self) -> Bool {
        return self.bitPattern < other.bitPattern
    }
    
    @inlinable
    @inline(__always)
    public func isLessThanOrEqualTo(_ other: Self) -> Bool {
        return self.bitPattern <= other.bitPattern
    }
}

extension BinaryFixedPoint {
    
    @inlinable
    @inline(__always)
    public static prefix func +(x: Self) -> Self {
        return x
    }
    
    @inlinable
    @inline(__always)
    public static func +(lhs: Self, rhs: Self) -> Self {
        let (value, overflow) = lhs.bitPattern.addingReportingOverflow(rhs.bitPattern)
        return overflow ? (rhs < 0 ? .min : .max) : Self(bitPattern: value)
    }
    
    @inlinable
    @inline(__always)
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    @inlinable
    @inline(__always)
    public static func -(lhs: Self, rhs: Self) -> Self {
        let (value, overflow) = lhs.bitPattern.subtractingReportingOverflow(rhs.bitPattern)
        return overflow ? (rhs < 0 ? .max : .min) : Self(bitPattern: value)
    }
    
    @inlinable
    @inline(__always)
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    @inlinable
    @inline(__always)
    public static func *(lhs: Self, rhs: Self) -> Self {
        let base: BitPattern = 1 << Self.fractionBitCount
        let value = base.dividingFullWidth(lhs.bitPattern.multipliedFullWidth(by: rhs.bitPattern)).quotient
        return Self(bitPattern: value)
    }
    
    @inlinable
    @inline(__always)
    public static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    @inlinable
    @inline(__always)
    public static func /(lhs: Self, rhs: Self) -> Self {
        let base: BitPattern = 1 << Self.fractionBitCount
        let value = rhs.bitPattern.dividingFullWidth(lhs.bitPattern.multipliedFullWidth(by: base)).quotient
        return Self(bitPattern: value)
    }
    
    @inlinable
    @inline(__always)
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
    @inlinable
    @inline(__always)
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern < rhs.bitPattern
    }
    
    @inlinable
    @inline(__always)
    public static func <=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern <= rhs.bitPattern
    }
    
    @inlinable
    @inline(__always)
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern > rhs.bitPattern
    }
    
    @inlinable
    @inline(__always)
    public static func >=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern >= rhs.bitPattern
    }
}

extension BinaryFixedPoint where Self : SignedNumeric, BitPattern : SignedNumeric {
    
    @inlinable
    @inline(__always)
    public static prefix func -(x: Self) -> Self {
        if x < 0 {
            return x.magnitude
        } else {
            return Self(bitPattern: -x.bitPattern)
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func negate() {
        self = -self
    }
}

extension BinaryFixedPoint {
    
    @inlinable
    @inline(__always)
    public static func random<T>(in range: Range<Self>, using generator: inout T) -> Self where T : RandomNumberGenerator {
        return Self(bitPattern: BitPattern.random(in: range.lowerBound.bitPattern..<range.upperBound.bitPattern, using: &generator))
    }
    
    @inlinable
    @inline(__always)
    public static func random(in range: Range<Self>) -> Self {
        var g = SystemRandomNumberGenerator()
        return Self.random(in: range, using: &g)
    }
    
    @inlinable
    @inline(__always)
    public static func random<T>(in range: ClosedRange<Self>, using generator: inout T) -> Self where T : RandomNumberGenerator {
        return Self(bitPattern: BitPattern.random(in: range.lowerBound.bitPattern...range.upperBound.bitPattern, using: &generator))
    }
    
    @inlinable
    @inline(__always)
    public static func random(in range: ClosedRange<Self>) -> Self {
        var g = SystemRandomNumberGenerator()
        return Self.random(in: range, using: &g)
    }
}
