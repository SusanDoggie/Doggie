//
//  Endianness.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct BEInteger<Base: FixedWidthInteger>: FixedWidthInteger {
    
    public var bitPattern: Base
    
    @inlinable
    public init(bitPattern: Base) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    public init(representingValue: Base) {
        self.bitPattern = representingValue.bigEndian
    }
    
    @inlinable
    public var representingValue: Base {
        get {
            return Base(bigEndian: bitPattern)
        }
        set {
            bitPattern = newValue.bigEndian
        }
    }
    
    @inlinable
    public init(bigEndian value: BEInteger) {
        self.bitPattern = value.bitPattern
    }
    
    @inlinable
    public init(littleEndian value: BEInteger) {
        self.bitPattern = value.bitPattern.byteSwapped
    }
    
    @inlinable
    public var bigEndian: BEInteger {
        return self
    }
    
    @inlinable
    public var littleEndian: BEInteger {
        return BEInteger(littleEndian: self)
    }
}

extension BEInteger: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return representingValue.description
    }
}

extension BEInteger: Decodable where Base: Decodable {
    
    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(representingValue: try container.decode(Base.self))
    }
}

extension BEInteger: Encodable where Base: Encodable {
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(representingValue)
    }
}

extension BEInteger: SignedNumeric where Base: SignedNumeric {
    
    @inlinable
    public static prefix func -(x: BEInteger) -> BEInteger {
        return BEInteger(representingValue: -x.representingValue)
    }
    
    @inlinable
    public mutating func negate() {
        self.representingValue.negate()
    }
}

extension BEInteger: SignedInteger where Base: SignedInteger {
    
}

extension BEInteger: UnsignedInteger where Base: UnsignedInteger {
    
}

extension BEInteger {
    
    @inlinable
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(representingValue: Base(integerLiteral: value))
    }
    
    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @inlinable
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @inlinable
    public init(_ value: Base) {
        self.init(representingValue: value)
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @inlinable
    public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
        self.init(representingValue: Base(truncatingIfNeeded: source))
    }
    
    @inlinable
    public init<T: BinaryInteger>(clamping source: T) {
        self.init(representingValue: Base(clamping: source))
    }
    
    @inlinable
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: Base(_truncatingBits: bits))
    }
}

extension BEInteger {
    
    @inlinable
    public static var isSigned: Bool {
        return Base.isSigned
    }
    
    @inlinable
    public static var bitWidth: Int {
        return Base.bitWidth
    }
    
    @inlinable
    public static var max: BEInteger {
        return BEInteger(representingValue: Base.max)
    }
    
    @inlinable
    public static var min: BEInteger {
        return BEInteger(representingValue: Base.min)
    }
}

extension BEInteger {
    
    @inlinable
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @inlinable
    public var magnitude: Base.Magnitude {
        return representingValue.magnitude
    }
    
    @inlinable
    public var trailingZeroBitCount: Int {
        return representingValue.trailingZeroBitCount
    }
    
    @inlinable
    public var nonzeroBitCount: Int {
        return representingValue.nonzeroBitCount
    }
    
    @inlinable
    public var leadingZeroBitCount: Int {
        return representingValue.leadingZeroBitCount
    }
    
    @inlinable
    public var byteSwapped: BEInteger {
        return BEInteger(representingValue: representingValue.byteSwapped)
    }
}

extension BEInteger {
    
    @inlinable
    public var words: Base.Words {
        return self.representingValue.words
    }
    
    @inlinable
    public func distance(to other: BEInteger) -> Base.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @inlinable
    public func advanced(by n: Base.Stride) -> BEInteger {
        return BEInteger(representingValue: self.representingValue.advanced(by: n))
    }
    
    @inlinable
    public func addingReportingOverflow(_ rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func subtractingReportingOverflow(_ rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func multipliedReportingOverflow(by rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func dividedReportingOverflow(by rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func remainderReportingOverflow(dividingBy rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func multipliedFullWidth(by other: BEInteger) -> (high: BEInteger, low: Base.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (BEInteger(representingValue: high), low)
    }
    
    @inlinable
    public func dividingFullWidth(_ dividend: (high: BEInteger, low: Base.Magnitude)) -> (quotient: BEInteger, remainder: BEInteger) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (BEInteger(representingValue: quotient), BEInteger(representingValue: remainder))
    }
}

extension BEInteger {
    
    @inlinable
    public static prefix func + (x: BEInteger) -> BEInteger {
        return x
    }
    @inlinable
    public static func + (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue + rhs.representingValue)
    }
    @inlinable
    public static func += (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue += rhs.representingValue
    }
    @inlinable
    public static func - (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue - rhs.representingValue)
    }
    @inlinable
    public static func -= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue -= rhs.representingValue
    }
    @inlinable
    public static func * (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue * rhs.representingValue)
    }
    @inlinable
    public static func *= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue *= rhs.representingValue
    }
    @inlinable
    public static func / (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue / rhs.representingValue)
    }
    @inlinable
    public static func /= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue /= rhs.representingValue
    }
    @inlinable
    public static func % (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue % rhs.representingValue)
    }
    @inlinable
    public static func %= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue %= rhs.representingValue
    }
    @inlinable
    public static func & (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue & rhs.representingValue)
    }
    @inlinable
    public static func &= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue &= rhs.representingValue
    }
    @inlinable
    public static func | (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue | rhs.representingValue)
    }
    @inlinable
    public static func |= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue |= rhs.representingValue
    }
    @inlinable
    public static func ^ (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue ^ rhs.representingValue)
    }
    @inlinable
    public static func ^= (lhs: inout BEInteger, rhs: BEInteger) {
        lhs.representingValue ^= rhs.representingValue
    }
    @inlinable
    public static prefix func ~ (x: BEInteger) -> BEInteger {
        return BEInteger(representingValue: ~x.representingValue)
    }
    @inlinable
    public static func &>> (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue &>> rhs.representingValue)
    }
    @inlinable
    public static func &<< (lhs: BEInteger, rhs: BEInteger) -> BEInteger {
        return BEInteger(representingValue: lhs.representingValue &<< rhs.representingValue)
    }
    @inlinable
    public static func > (lhs: BEInteger, rhs: BEInteger) -> Bool {
        return lhs.representingValue > rhs.representingValue
    }
    @inlinable
    public static func < (lhs: BEInteger, rhs: BEInteger) -> Bool {
        return lhs.representingValue < rhs.representingValue
    }
    @inlinable
    public static func >= (lhs: BEInteger, rhs: BEInteger) -> Bool {
        return lhs.representingValue >= rhs.representingValue
    }
    @inlinable
    public static func <= (lhs: BEInteger, rhs: BEInteger) -> Bool {
        return lhs.representingValue <= rhs.representingValue
    }
}

@frozen
public struct LEInteger<Base: FixedWidthInteger>: FixedWidthInteger {
    
    public var bitPattern: Base
    
    @inlinable
    public init(bitPattern: Base) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    public init(representingValue: Base) {
        self.bitPattern = representingValue.littleEndian
    }
    
    @inlinable
    public var representingValue: Base {
        get {
            return Base(littleEndian: bitPattern)
        }
        set {
            bitPattern = newValue.littleEndian
        }
    }
    
    @inlinable
    public init(bigEndian value: LEInteger) {
        self.bitPattern = value.bitPattern.byteSwapped
    }
    
    @inlinable
    public init(littleEndian value: LEInteger) {
        self.bitPattern = value.bitPattern
    }
    
    @inlinable
    public var bigEndian: LEInteger {
        return LEInteger(bigEndian: self)
    }
    
    @inlinable
    public var littleEndian: LEInteger {
        return self
    }
}

extension LEInteger: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return representingValue.description
    }
}

extension LEInteger: Decodable where Base: Decodable {
    
    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(representingValue: try container.decode(Base.self))
    }
}

extension LEInteger: Encodable where Base: Encodable {
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(representingValue)
    }
}

extension LEInteger: SignedNumeric where Base: SignedNumeric {
    
    @inlinable
    public static prefix func -(x: LEInteger) -> LEInteger {
        return LEInteger(representingValue: -x.representingValue)
    }
    
    @inlinable
    public mutating func negate() {
        self.representingValue.negate()
    }
}

extension LEInteger: SignedInteger where Base: SignedInteger {
    
}

extension LEInteger: UnsignedInteger where Base: UnsignedInteger {
    
}

extension LEInteger {
    
    @inlinable
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(representingValue: Base(integerLiteral: value))
    }
    
    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @inlinable
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @inlinable
    public init(_ value: Base) {
        self.init(representingValue: value)
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @inlinable
    public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
        self.init(representingValue: Base(truncatingIfNeeded: source))
    }
    
    @inlinable
    public init<T: BinaryInteger>(clamping source: T) {
        self.init(representingValue: Base(clamping: source))
    }
    
    @inlinable
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: Base(_truncatingBits: bits))
    }
}

extension LEInteger {
    
    @inlinable
    public static var isSigned: Bool {
        return Base.isSigned
    }
    
    @inlinable
    public static var bitWidth: Int {
        return Base.bitWidth
    }
    
    @inlinable
    public static var max: LEInteger {
        return LEInteger(representingValue: Base.max)
    }
    
    @inlinable
    public static var min: LEInteger {
        return LEInteger(representingValue: Base.min)
    }
}

extension LEInteger {
    
    @inlinable
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @inlinable
    public var magnitude: Base.Magnitude {
        return representingValue.magnitude
    }
    
    @inlinable
    public var trailingZeroBitCount: Int {
        return representingValue.trailingZeroBitCount
    }
    
    @inlinable
    public var nonzeroBitCount: Int {
        return representingValue.nonzeroBitCount
    }
    
    @inlinable
    public var leadingZeroBitCount: Int {
        return representingValue.leadingZeroBitCount
    }
    
    @inlinable
    public var byteSwapped: LEInteger {
        return LEInteger(representingValue: representingValue.byteSwapped)
    }
}

extension LEInteger {
    
    @inlinable
    public var words: Base.Words {
        return self.representingValue.words
    }
    
    @inlinable
    public func distance(to other: LEInteger) -> Base.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @inlinable
    public func advanced(by n: Base.Stride) -> LEInteger {
        return LEInteger(representingValue: self.representingValue.advanced(by: n))
    }
    
    @inlinable
    public func addingReportingOverflow(_ rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func subtractingReportingOverflow(_ rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func multipliedReportingOverflow(by rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func dividedReportingOverflow(by rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func remainderReportingOverflow(dividingBy rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @inlinable
    public func multipliedFullWidth(by other: LEInteger) -> (high: LEInteger, low: Base.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (LEInteger(representingValue: high), low)
    }
    
    @inlinable
    public func dividingFullWidth(_ dividend: (high: LEInteger, low: Base.Magnitude)) -> (quotient: LEInteger, remainder: LEInteger) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (LEInteger(representingValue: quotient), LEInteger(representingValue: remainder))
    }
}

extension LEInteger {
    
    @inlinable
    public static prefix func + (x: LEInteger) -> LEInteger {
        return x
    }
    @inlinable
    public static func + (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue + rhs.representingValue)
    }
    @inlinable
    public static func += (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue += rhs.representingValue
    }
    @inlinable
    public static func - (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue - rhs.representingValue)
    }
    @inlinable
    public static func -= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue -= rhs.representingValue
    }
    @inlinable
    public static func * (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue * rhs.representingValue)
    }
    @inlinable
    public static func *= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue *= rhs.representingValue
    }
    @inlinable
    public static func / (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue / rhs.representingValue)
    }
    @inlinable
    public static func /= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue /= rhs.representingValue
    }
    @inlinable
    public static func % (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue % rhs.representingValue)
    }
    @inlinable
    public static func %= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue %= rhs.representingValue
    }
    @inlinable
    public static func & (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue & rhs.representingValue)
    }
    @inlinable
    public static func &= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue &= rhs.representingValue
    }
    @inlinable
    public static func | (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue | rhs.representingValue)
    }
    @inlinable
    public static func |= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue |= rhs.representingValue
    }
    @inlinable
    public static func ^ (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue ^ rhs.representingValue)
    }
    @inlinable
    public static func ^= (lhs: inout LEInteger, rhs: LEInteger) {
        lhs.representingValue ^= rhs.representingValue
    }
    @inlinable
    public static prefix func ~ (x: LEInteger) -> LEInteger {
        return LEInteger(representingValue: ~x.representingValue)
    }
    @inlinable
    public static func &>> (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue &>> rhs.representingValue)
    }
    @inlinable
    public static func &<< (lhs: LEInteger, rhs: LEInteger) -> LEInteger {
        return LEInteger(representingValue: lhs.representingValue &<< rhs.representingValue)
    }
    @inlinable
    public static func > (lhs: LEInteger, rhs: LEInteger) -> Bool {
        return lhs.representingValue > rhs.representingValue
    }
    @inlinable
    public static func < (lhs: LEInteger, rhs: LEInteger) -> Bool {
        return lhs.representingValue < rhs.representingValue
    }
    @inlinable
    public static func >= (lhs: LEInteger, rhs: LEInteger) -> Bool {
        return lhs.representingValue >= rhs.representingValue
    }
    @inlinable
    public static func <= (lhs: LEInteger, rhs: LEInteger) -> Bool {
        return lhs.representingValue <= rhs.representingValue
    }
}

extension FixedWidthInteger {
    
    @inlinable
    public init(_ value: BEInteger<Self>) {
        self = value.representingValue
    }
    
    @inlinable
    public init(_ value: LEInteger<Self>) {
        self = value.representingValue
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

extension FloatingPoint {
    
    @inlinable
    public init(_ value: BEUInt) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEUInt8) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEUInt16) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEUInt32) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEUInt64) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEInt) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEInt8) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEInt16) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEInt32) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: BEInt64) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEUInt) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEUInt8) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEUInt16) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEUInt32) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEUInt64) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEInt) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEInt8) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEInt16) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEInt32) {
        self.init(value.representingValue)
    }
    @inlinable
    public init(_ value: LEInt64) {
        self.init(value.representingValue)
    }
}
