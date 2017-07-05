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

public protocol BinaryFixedPoint : Numeric, Hashable, CustomStringConvertible, ExpressibleByFloatLiteral where RepresentingValue.RawSignificand : FixedWidthInteger {
    
    associatedtype BitPattern : FixedWidthInteger
    
    associatedtype RepresentingValue : BinaryFloatingPoint
    
    static var fractionalBitCount: Int { get }
    
    var bitPattern: BitPattern { get }
    
    init(bitPattern: BitPattern)
    
    var representingValue : RepresentingValue { get set }
    
    init(representingValue: RepresentingValue)
}

extension BinaryFixedPoint {
    
    @_inlineable
    public init(integerLiteral value: RepresentingValue.IntegerLiteralType) {
        self.init(representingValue: RepresentingValue(integerLiteral: value))
    }
    
    @_inlineable
    public init(floatLiteral value: RepresentingValue.FloatLiteralType) {
        self.init(representingValue: RepresentingValue(floatLiteral: value))
    }
    
    @_inlineable
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
}

extension BinaryFixedPoint {
    
    @_versioned
    @_inlineable
    static var _fractionOffset: Int {
        return Self.fractionalBitCount - RepresentingValue.significandBitCount
    }
    
    @_inlineable
    public init(representingValue: RepresentingValue) {
        if representingValue.exponentBitPattern == 0 && representingValue.significandBitPattern == 0 {
            self.init(bitPattern: 0)
        } else {
            if BitPattern.isSigned {
                let offset = Self._fractionOffset + Int(representingValue.exponent)
                let pattern = RepresentingValue.RawSignificand(1 << RepresentingValue.significandBitCount) | representingValue.significandBitPattern
                if representingValue.sign == .minus {
                    self.init(bitPattern: 0 - BitPattern(clamping: pattern << offset))
                } else {
                    self.init(bitPattern: BitPattern(clamping: pattern << offset))
                }
            } else {
                if representingValue.sign == .minus {
                    self.init(bitPattern: 0)
                } else {
                    let offset = Self._fractionOffset + Int(representingValue.exponent)
                    let pattern = RepresentingValue.RawSignificand(1 << RepresentingValue.significandBitCount) | representingValue.significandBitPattern
                    self.init(bitPattern: BitPattern(clamping: pattern << offset))
                }
            }
        }
    }
    
    @_inlineable
    public var representingValue : RepresentingValue {
        get {
            if bitPattern == 0 {
                return 0
            } else {
                let _bitPattern = RepresentingValue.RawSignificand(bitPattern < 0 ? 0 - bitPattern : bitPattern)
                let exponent = RepresentingValue.RawSignificand.bitWidth - _bitPattern.leadingZeroBitCount - Self.fractionalBitCount - 1
                let offset = Self._fractionOffset + exponent
                let exponentBitPattern = Self.RepresentingValue.RawExponent(Int((1 as RepresentingValue).exponentBitPattern) + exponent)
                let significandBitMask: RepresentingValue.RawSignificand = (1 << RepresentingValue.significandBitCount) - 1
                let significandBitPattern = (_bitPattern & (significandBitMask << offset)) >> offset
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
    
    @_inlineable
    public var description: String {
        return "\(representingValue)"
    }
    
    @_inlineable
    public var hashValue: Int {
        return bitPattern.hashValue
    }
    
    @_inlineable
    public var magnitude: RepresentingValue.Magnitude {
        return representingValue.magnitude
    }
}

extension BinaryFixedPoint {
    
    @_inlineable
    public static func +(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue + rhs.representingValue)
    }
    
    @_inlineable
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs.representingValue += rhs.representingValue
    }
    
    @_inlineable
    public static func -(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue - rhs.representingValue)
    }
    
    @_inlineable
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs.representingValue -= rhs.representingValue
    }
    
    @_inlineable
    public static func *(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue * rhs.representingValue)
    }
    
    @_inlineable
    public static func *=(lhs: inout Self, rhs: Self) {
        lhs.representingValue *= rhs.representingValue
    }
    
    @_inlineable
    public static func /(lhs: Self, rhs: Self) -> Self {
        return self.init(representingValue: lhs.representingValue / rhs.representingValue)
    }
    
    @_inlineable
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs.representingValue /= rhs.representingValue
    }
    
    @_inlineable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern == rhs.bitPattern
    }
    
    @_inlineable
    public static func !=(lhs: Self, rhs: Self) -> Bool {
        return lhs.bitPattern != rhs.bitPattern
    }
}