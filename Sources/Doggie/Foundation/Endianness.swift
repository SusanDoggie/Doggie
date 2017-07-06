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

@_versioned
protocol EndianInteger : FixedWidthInteger {
    
    associatedtype BitPattern : FixedWidthInteger
    
    associatedtype RepresentingValue : FixedWidthInteger
    
    var bitPattern: BitPattern { get }
    
    init(bitPattern: BitPattern)
    
    var representingValue : RepresentingValue { get set }
    
    init(representingValue: RepresentingValue)
}

extension EndianInteger {
    
    @_transparent
    public init(bigEndian value: Self) {
        self.init(representingValue: value.representingValue.bigEndian)
    }
    
    @_transparent
    public init(littleEndian value: Self) {
        self.init(representingValue: value.representingValue.littleEndian)
    }
    
    @_transparent
    public init(integerLiteral value: RepresentingValue.IntegerLiteralType) {
        self.init(representingValue: RepresentingValue(integerLiteral: value))
    }
    
    @_transparent
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init?<T>(exactly source: T) where T : FloatingPoint {
        guard let value = RepresentingValue(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init(_ value: RepresentingValue) {
        self.init(representingValue: value)
    }
    
    @_transparent
    public init<T>(_ source: T) where T : FloatingPoint {
        self.init(representingValue: RepresentingValue(source))
    }
    
    @_transparent
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(source))
    }
    
    @_transparent
    public init<T>(extendingOrTruncating source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(extendingOrTruncating: source))
    }
    
    @_transparent
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(representingValue: RepresentingValue(clamping: source))
    }
    
    @_transparent
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: RepresentingValue(_truncatingBits: bits))
    }
}

extension EndianInteger {
    
    @_transparent
    public static var isSigned: Bool {
        return RepresentingValue.isSigned
    }
    
    @_transparent
    public static var bitWidth: Int {
        return RepresentingValue.bitWidth
    }
    
    @_transparent
    public static var max: Self {
        return Self(representingValue: RepresentingValue.max)
    }
    
    @_transparent
    public static var min: Self {
        return Self(representingValue: RepresentingValue.min)
    }
}

extension EndianInteger {
    
    @_transparent
    public var hashValue: Int {
        return representingValue.hashValue
    }
    
    @_transparent
    public var description: String {
        return representingValue.description
    }
    
    @_transparent
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @_transparent
    public var magnitude: RepresentingValue.Magnitude {
        return representingValue.magnitude
    }
    
    @_transparent
    public var trailingZeroBitCount: Int {
        return representingValue.trailingZeroBitCount
    }
    
    @_transparent
    public var nonzeroBitCount: Int {
        return representingValue.nonzeroBitCount
    }
    
    @_transparent
    public var leadingZeroBitCount: Int {
        return representingValue.leadingZeroBitCount
    }
    
    @_transparent
    public var bigEndian: Self {
        return Self(bigEndian: self)
    }
    
    @_transparent
    public var littleEndian: Self {
        return Self(littleEndian: self)
    }
    
    @_transparent
    public var byteSwapped: Self {
        return Self(representingValue: representingValue.byteSwapped)
    }
}

extension EndianInteger {
    
    @_transparent
    public func _word(at n: Int) -> UInt {
        return representingValue._word(at: n)
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
    public func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func dividedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func remainderReportingOverflow(dividingBy rhs: Self) -> (partialValue: Self, overflow: ArithmeticOverflow) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (Self(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedFullWidth(by other: Self) -> (high: Self, low: RepresentingValue.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (Self(representingValue: high), low)
    }
    
    @_transparent
    public func dividingFullWidth(_ dividend: (high: Self, low: RepresentingValue.Magnitude)) -> (quotient: Self, remainder: Self) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (Self(representingValue: quotient), Self(representingValue: remainder))
    }
}

extension EndianInteger {
    
    @_transparent
    public static prefix func +(x: Self) -> Self {
        return x
    }
    
    @_transparent
    public static func +(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue + rhs.representingValue)
    }
    
    @_transparent
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs.representingValue += rhs.representingValue
    }
    
    @_transparent
    public static func -(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue - rhs.representingValue)
    }
    
    @_transparent
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs.representingValue -= rhs.representingValue
    }
    
    @_transparent
    public static func *(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue * rhs.representingValue)
    }
    
    @_transparent
    public static func *=(lhs: inout Self, rhs: Self) {
        lhs.representingValue *= rhs.representingValue
    }
    
    @_transparent
    public static func /(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue / rhs.representingValue)
    }
    
    @_transparent
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs.representingValue /= rhs.representingValue
    }
    
    @_transparent
    public static func %(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue % rhs.representingValue)
    }
    
    @_transparent
    public static func %=(lhs: inout Self, rhs: Self) {
        lhs.representingValue %= rhs.representingValue
    }
    
    @_transparent
    public static func &(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue & rhs.representingValue)
    }
    
    @_transparent
    public static func &=(lhs: inout Self, rhs: Self) {
        lhs.representingValue &= rhs.representingValue
    }
    
    @_transparent
    public static func |(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue | rhs.representingValue)
    }
    
    @_transparent
    public static func |=(lhs: inout Self, rhs: Self) {
        lhs.representingValue |= rhs.representingValue
    }
    
    @_transparent
    public static func ^(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue ^ rhs.representingValue)
    }
    
    @_transparent
    public static func ^=(lhs: inout Self, rhs: Self) {
        lhs.representingValue ^= rhs.representingValue
    }
    
    @_transparent
    prefix public static func ~(x: Self) -> Self {
        return Self(representingValue: ~x.representingValue)
    }
    
    @_transparent
    public static func &>>(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue &>> rhs.representingValue)
    }
    
    @_transparent
    public static func &<<(lhs: Self, rhs: Self) -> Self {
        return Self(representingValue: lhs.representingValue &<< rhs.representingValue)
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
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue > rhs.representingValue
    }
    
    @_transparent
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue < rhs.representingValue
    }
    
    @_transparent
    public static func >=(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue >= rhs.representingValue
    }
    
    @_transparent
    public static func <=(lhs: Self, rhs: Self) -> Bool {
        return lhs.representingValue <= rhs.representingValue
    }
}

public struct BEInteger<Base : FixedWidthInteger> : FixedWidthInteger, EndianInteger {
    
    public var bitPattern: Base
    
    @_transparent
    public init(bitPattern: Base) {
        self.bitPattern = bitPattern
    }
    
    @_versioned
    @_transparent
    init(representingValue: Base) {
        self.bitPattern = representingValue.bigEndian
    }
    
    @_versioned
    @_transparent
    var representingValue: Base {
        get {
            return Base(bigEndian: bitPattern)
        }
        set {
            bitPattern = newValue.bigEndian
        }
    }
}

public struct LEInteger<Base : FixedWidthInteger> : FixedWidthInteger, EndianInteger {
    
    public var bitPattern: Base
    
    @_transparent
    public init(bitPattern: Base) {
        self.bitPattern = bitPattern
    }
    
    @_versioned
    @_transparent
    init(representingValue: Base) {
        self.bitPattern = representingValue.littleEndian
    }
    
    @_versioned
    @_transparent
    var representingValue: Base {
        get {
            return Base(littleEndian: bitPattern)
        }
        set {
            bitPattern = newValue.littleEndian
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
