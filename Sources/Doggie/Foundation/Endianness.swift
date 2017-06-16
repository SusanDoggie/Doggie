//
//  Endianness.swift
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

public protocol EndianInteger : FixedWidthInteger {
    
    associatedtype RepresentingValue : FixedWidthInteger
    
    var representingValue : RepresentingValue { get set }
    
    init(representingValue: RepresentingValue)
}

extension EndianInteger {
    
    @_inlineable
    public init(bigEndian value: Self) {
        self.init(representingValue: value.representingValue.bigEndian)
    }
    
    @_inlineable
    public init(littleEndian value: Self) {
        self.init(representingValue: value.representingValue.littleEndian)
    }
    
    @_inlineable
    public init(integerLiteral value: RepresentingValue.IntegerLiteralType) {
        self.init(representingValue: RepresentingValue(integerLiteral: value))
    }
    
    @_inlineable
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_inlineable
    public init?<T>(exactly source: T) where T : FloatingPoint {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_inlineable
    public init<T>(_ source: T) where T : FloatingPoint {
        self.init(representingValue: RepresentingValue(source))
    }
    
    @_inlineable
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(source))
    }
    
    @_inlineable
    public init<T>(extendingOrTruncating source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(extendingOrTruncating: source))
    }
    
    @_inlineable
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(clamping: source))
    }
    
    @_inlineable
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: RepresentingValue(_truncatingBits: bits))
    }
}

extension EndianInteger {
    
    @_inlineable
    public static var isSigned: Bool {
        return RepresentingValue.isSigned
    }
    
    @_inlineable
    public static var bitWidth: Int {
        return RepresentingValue.bitWidth
    }
    
    @_inlineable
    public static var max: Self {
        return Self(representingValue: RepresentingValue.max)
    }
    
    @_inlineable
    public static var min: Self {
        return Self(representingValue: RepresentingValue.min)
    }
}

extension EndianInteger {
    
    @_inlineable
    public var hashValue: Int {
        return representingValue.hashValue
    }
    
    @_inlineable
    public var description: String {
        return representingValue.description
    }
    
    @_inlineable
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @_inlineable
    public var magnitude: RepresentingValue.Magnitude {
        return representingValue.magnitude
    }
    
    @_inlineable
    public var trailingZeroBitCount: Int {
        return representingValue.trailingZeroBitCount
    }
    
    @_inlineable
    public var nonzeroBitCount: Int {
        return representingValue.nonzeroBitCount
    }
    
    @_inlineable
    public var leadingZeroBitCount: Int {
        return representingValue.leadingZeroBitCount
    }
    
    @_inlineable
    public var bigEndian: Self {
        return Self(bigEndian: self)
    }
    
    @_inlineable
    public var littleEndian: Self {
        return Self(littleEndian: self)
    }
    
    @_inlineable
    public var byteSwapped: Self {
        return Self(representingValue: representingValue.byteSwapped)
    }
}

extension EndianInteger {
    
    @_inlineable
    public func _word(at n: Int) -> UInt {
        return representingValue._word(at: n)
    }
    
    @_inlineable
    public func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_inlineable
    public func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_inlineable
    public func multipliedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_inlineable
    public func dividedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_inlineable
    public func remainderReportingOverflow(dividingBy rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_inlineable
    public func multipliedFullWidth(by other: Self) -> (high: Self, low: RepresentingValue.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (Self(representingValue: high), low)
    }
    
    @_inlineable
    public func dividingFullWidth(_ dividend: (high: Self, low: RepresentingValue.Magnitude)) -> (quotient: Self, remainder: Self) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (Self(representingValue: quotient), Self(representingValue: remainder))
    }
}

extension EndianInteger {
    
    @_inlineable
    public static func +(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue + rhs.representingValue)
    }
    
    @_inlineable
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs.representingValue += rhs.representingValue
    }
    
    @_inlineable
    public static func -(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue - rhs.representingValue)
    }
    
    @_inlineable
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs.representingValue -= rhs.representingValue
    }
    
    @_inlineable
    public static func *(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue * rhs.representingValue)
    }
    
    @_inlineable
    public static func *=(lhs: inout Self, rhs: Self) {
        lhs.representingValue *= rhs.representingValue
    }
    
    @_inlineable
    public static func /(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue / rhs.representingValue)
    }
    
    @_inlineable
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs.representingValue /= rhs.representingValue
    }
    
    @_inlineable
    public static func %(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue % rhs.representingValue)
    }
    
    @_inlineable
    public static func %=(lhs: inout Self, rhs: Self) {
        lhs.representingValue %= rhs.representingValue
    }
    
    @_inlineable
    public static func &(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue & rhs.representingValue)
    }
    
    @_inlineable
    public static func &=(lhs: inout Self, rhs: Self) {
        lhs.representingValue &= rhs.representingValue
    }
    
    @_inlineable
    public static func |(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue | rhs.representingValue)
    }
    
    @_inlineable
    public static func |=(lhs: inout Self, rhs: Self) {
        lhs.representingValue |= rhs.representingValue
    }
    
    @_inlineable
    public static func ^(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue ^ rhs.representingValue)
    }
    
    @_inlineable
    public static func ^=(lhs: inout Self, rhs: Self) {
        lhs.representingValue ^= rhs.representingValue
    }
    
    @_inlineable
    prefix public static func ~(x: Self) -> Self {
        return Self(representingValue: ~x.representingValue)
    }
    
    @_inlineable
    public static func &>>(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue &>> rhs.representingValue)
    }
    
    @_inlineable
    public static func &<<(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue &<< rhs.representingValue)
    }
    
    @_inlineable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue == rhs.representingValue
    }
    
    @_inlineable
    public static func !=(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue != rhs.representingValue
    }
    
    @_inlineable
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue > rhs.representingValue
    }
    
    @_inlineable
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue < rhs.representingValue
    }
    
    @_inlineable
    public static func >=(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue >= rhs.representingValue
    }
    
    @_inlineable
    public static func <=(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue <= rhs.representingValue
    }
}

@_fixed_layout
public struct BEInteger<Base : FixedWidthInteger> : EndianInteger {
    
    @_versioned
    var storage: Base
    
    @_inlineable
    public init(representingValue: Base) {
        self.storage = representingValue.bigEndian
    }
    
    @_inlineable
    public var representingValue: Base {
        get {
            return Base(bigEndian: storage)
        }
        set {
            storage = newValue.bigEndian
        }
    }
}

@_fixed_layout
public struct LEInteger<Base : FixedWidthInteger> : EndianInteger {
    
    @_versioned
    var storage: Base
    
    @_inlineable
    public init(representingValue: Base) {
        self.storage = representingValue.littleEndian
    }
    
    @_inlineable
    public var representingValue: Base {
        get {
            return Base(littleEndian: storage)
        }
        set {
            storage = newValue.littleEndian
        }
    }
}

public typealias BEInt = BEInteger<Int>
public typealias BEInt8 = BEInteger<Int8>
public typealias BEInt16 = BEInteger<Int16>
public typealias BEInt32 = BEInteger<Int32>
public typealias BEInt64 = BEInteger<Int64>
public typealias BEUInt = BEInteger<UInt>
public typealias BEUInt8 = BEInteger<UInt8>
public typealias BEUInt16 = BEInteger<UInt16>
public typealias BEUInt32 = BEInteger<UInt32>
public typealias BEUInt64 = BEInteger<UInt64>
public typealias LEInt = LEInteger<Int>
public typealias LEInt8 = LEInteger<Int8>
public typealias LEInt16 = LEInteger<Int16>
public typealias LEInt32 = LEInteger<Int32>
public typealias LEInt64 = LEInteger<Int64>
public typealias LEUInt = LEInteger<UInt>
public typealias LEUInt8 = LEInteger<UInt8>
public typealias LEUInt16 = LEInteger<UInt16>
public typealias LEUInt32 = LEInteger<UInt32>
public typealias LEUInt64 = LEInteger<UInt64>
