//
//  BinaryFixedPoint.swift
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

public protocol BinaryFixedPoint : Numeric, Hashable, Strideable, CustomStringConvertible, ExpressibleByFloatLiteral {
    
    associatedtype BitPattern : FixedWidthInteger
    
    associatedtype RepresentingValue : BinaryFloatingPoint
    
    static var fractionBitCount: Int { get }
    
    var bitPattern: BitPattern { get }
    
    init(bitPattern: BitPattern)
    
    var representingValue : RepresentingValue { get set }
    
    init(representingValue: RepresentingValue)
}

extension BinaryFixedPoint {
    
    @_transparent
    public init(integerLiteral value: RepresentingValue.IntegerLiteralType) {
        self.init(representingValue: RepresentingValue(integerLiteral: value))
    }
    
    @_transparent
    public init(floatLiteral value: RepresentingValue.FloatLiteralType) {
        self.init(representingValue: RepresentingValue(floatLiteral: value))
    }
    
    @_transparent
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init(_ value: RepresentingValue) {
        self.init(representingValue: value)
    }
}

extension BinaryFixedPoint where RepresentingValue.RawSignificand : FixedWidthInteger {
    
    @_versioned
    @_transparent
    static var _fractionOffset: Int {
        return Self.fractionBitCount - RepresentingValue.significandBitCount
    }
    
    @_versioned
    @_transparent
    static var _exponentBias: Int {
        let s = RepresentingValue.exponentBitCount - 1
        return (1 << s) - 1
    }
    
    @_transparent
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
                    if pattern - 1 == ~BitPattern.min {
                        self.init(bitPattern: BitPattern.min)
                    } else {
                        self.init(bitPattern: ~BitPattern(clamping: pattern) + 1)
                    }
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
                let _bitPattern = RepresentingValue.RawSignificand(bitPattern < 0 ? 0 - bitPattern : bitPattern)
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
    public var hashValue: Int {
        return bitPattern.hashValue
    }
    
    @_transparent
    public var magnitude: RepresentingValue.Magnitude {
        return representingValue.magnitude
    }
    
    @_transparent
    public static var min: Self {
        return Self(bitPattern: BitPattern.min)
    }
    
    @_transparent
    public static var max: Self {
        return Self(bitPattern: BitPattern.max)
    }
    
    @_transparent
    public func distance(to other: Self) -> RepresentingValue.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @_transparent
    public func advanced(by n: RepresentingValue.Stride) -> Self {
        return Self(representingValue: self.representingValue.advanced(by: n))
    }
    
    @_transparent
    public func remainder(dividingBy other: Self) -> Self {
        return Self(representingValue: self.representingValue.remainder(dividingBy: other.representingValue))
    }
    
    @_transparent
    public mutating func formRemainder(dividingBy other: Self) {
        self.representingValue.formRemainder(dividingBy: other.representingValue)
    }
    
    @_transparent
    public func truncatingRemainder(dividingBy other: Self) -> Self {
        return Self(representingValue: self.representingValue.truncatingRemainder(dividingBy: other.representingValue))
    }
    
    @_transparent
    public mutating func formTruncatingRemainder(dividingBy other: Self) {
        self.representingValue.formTruncatingRemainder(dividingBy: other.representingValue)
    }
    
    @_transparent
    public func squareRoot() -> Self {
        return Self(representingValue: self.representingValue.squareRoot())
    }
    
    @_transparent
    public mutating func formSquareRoot() {
        self.representingValue.formSquareRoot()
    }
    
    @_transparent
    public func addingProduct(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(representingValue: self.representingValue.addingProduct(lhs.representingValue, rhs.representingValue))
    }
    
    @_transparent
    public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
        self.representingValue.addProduct(lhs.representingValue, rhs.representingValue)
    }
    
    @_transparent
    public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        return Self(representingValue: self.representingValue.rounded(rule))
    }
    
    @_transparent
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        self.representingValue.round(rule)
    }
    
    @_transparent
    public func isEqual(to other: Self) -> Bool {
        return self.bitPattern == other.bitPattern
    }
    
    @_transparent
    public func isLess(than other: Self) -> Bool {
        return self.bitPattern < other.bitPattern
    }
    
    @_transparent
    public func isLessThanOrEqualTo(_ other: Self) -> Bool {
        return self.bitPattern <= other.bitPattern
    }
}

extension BinaryFixedPoint {
    
    @_transparent
    public static prefix func +(x: Self) -> Self {
        return x
    }
    
    @_transparent
    public static func +(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue + rhs.representingValue)
    }
    
    @_transparent
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs.representingValue += rhs.representingValue
    }
    
    @_transparent
    public static func -(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue - rhs.representingValue)
    }
    
    @_transparent
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs.representingValue -= rhs.representingValue
    }
    
    @_transparent
    public static func *(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue * rhs.representingValue)
    }
    
    @_transparent
    public static func *=(lhs: inout Self, rhs: Self) {
        lhs.representingValue *= rhs.representingValue
    }
    
    @_transparent
    public static func /(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue / rhs.representingValue)
    }
    
    @_transparent
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs.representingValue /= rhs.representingValue
    }
    
    @_transparent
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern == rhs.bitPattern
    }
    
    @_transparent
    public static func !=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern != rhs.bitPattern
    }
    
    @_transparent
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern < rhs.bitPattern
    }
    
    @_transparent
    public static func <=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern <= rhs.bitPattern
    }
    
    @_transparent
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern > rhs.bitPattern
    }
    
    @_transparent
    public static func >=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern >= rhs.bitPattern
    }
}
