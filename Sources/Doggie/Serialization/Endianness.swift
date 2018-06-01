//
//  Endianness.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct BEInteger<Base : FixedWidthInteger> : FixedWidthInteger {
    
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
    
    @_transparent
    public init(bigEndian value: BEInteger) {
        self.bitPattern = value.bitPattern
    }
    
    @_transparent
    public init(littleEndian value: BEInteger) {
        self.bitPattern = value.bitPattern.byteSwapped
    }
    
    @_transparent
    public var bigEndian: BEInteger {
        return self
    }
    
    @_transparent
    public var littleEndian: BEInteger {
        return BEInteger(littleEndian: self)
    }
}

extension BEInteger: Decodable where Base : Decodable {
    
    @_transparent
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(representingValue: try container.decode(Base.self))
    }
}

extension BEInteger: Encodable where Base : Encodable {
    
    @_transparent
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(representingValue)
    }
}

extension BEInteger: SignedNumeric where Base : SignedNumeric {
    
    @_transparent
    public static prefix func -(x: BEInteger) -> BEInteger {
        return BEInteger(representingValue: -x.representingValue)
    }
    
    @_transparent
    public mutating func negate() {
        self.representingValue.negate()
    }
}

extension BEInteger: SignedInteger where Base : SignedInteger {
    
}

extension BEInteger: UnsignedInteger where Base : UnsignedInteger {
    
}

extension BEInteger {
    
    @_transparent
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(representingValue: Base(integerLiteral: value))
    }
    
    @_transparent
    public init?<T : BinaryInteger>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init?<T : BinaryFloatingPoint>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init(_ value: Base) {
        self.init(representingValue: value)
    }
    
    @_transparent
    public init<T : BinaryInteger>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @_transparent
    public init<T : BinaryFloatingPoint>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @_transparent
    public init<T : BinaryInteger>(truncatingIfNeeded source: T) {
        self.init(representingValue: Base(truncatingIfNeeded: source))
    }
    
    @_transparent
    public init<T : BinaryInteger>(clamping source: T) {
        self.init(representingValue: Base(clamping: source))
    }
    
    @_transparent
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: Base(_truncatingBits: bits))
    }
}

extension BEInteger {
    
    @_transparent
    public static var isSigned: Bool {
        return Base.isSigned
    }
    
    @_transparent
    public static var bitWidth: Int {
        return Base.bitWidth
    }
    
    @_transparent
    public static var max: BEInteger {
        return BEInteger(representingValue: Base.max)
    }
    
    @_transparent
    public static var min: BEInteger {
        return BEInteger(representingValue: Base.min)
    }
}

extension BEInteger {
    
    @_transparent
    public var description: String {
        return representingValue.description
    }
    
    @_transparent
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @_transparent
    public var magnitude: Base.Magnitude {
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
    public var byteSwapped: BEInteger {
        return BEInteger(representingValue: representingValue.byteSwapped)
    }
}

extension BEInteger {
    
    @_transparent
    public var words: Base.Words {
        return self.representingValue.words
    }
    
    @_transparent
    public func distance(to other: BEInteger) -> Base.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @_transparent
    public func advanced(by n: Base.Stride) -> BEInteger {
        return BEInteger(representingValue: self.representingValue.advanced(by: n))
    }
    
    @_transparent
    public func addingReportingOverflow(_ rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func subtractingReportingOverflow(_ rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedReportingOverflow(by rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func dividedReportingOverflow(by rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func remainderReportingOverflow(dividingBy rhs: BEInteger) -> (partialValue: BEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (BEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedFullWidth(by other: BEInteger) -> (high: BEInteger, low: Base.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (BEInteger(representingValue: high), low)
    }
    
    @_transparent
    public func dividingFullWidth(_ dividend: (high: BEInteger, low: Base.Magnitude)) -> (quotient: BEInteger, remainder: BEInteger) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (BEInteger(representingValue: quotient), BEInteger(representingValue: remainder))
    }
}

public struct LEInteger<Base : FixedWidthInteger> : FixedWidthInteger {
    
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
    
    @_transparent
    public init(bigEndian value: LEInteger) {
        self.bitPattern = value.bitPattern.byteSwapped
    }
    
    @_transparent
    public init(littleEndian value: LEInteger) {
        self.bitPattern = value.bitPattern
    }
    
    @_transparent
    public var bigEndian: LEInteger {
        return LEInteger(bigEndian: self)
    }
    
    @_transparent
    public var littleEndian: LEInteger {
        return self
    }
}

extension LEInteger: Decodable where Base : Decodable {
    
    @_transparent
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(representingValue: try container.decode(Base.self))
    }
}

extension LEInteger: Encodable where Base : Encodable {
    
    @_transparent
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(representingValue)
    }
}

extension LEInteger: SignedNumeric where Base : SignedNumeric {
    
    @_transparent
    public static prefix func -(x: LEInteger) -> LEInteger {
        return LEInteger(representingValue: -x.representingValue)
    }
    
    @_transparent
    public mutating func negate() {
        self.representingValue.negate()
    }
}

extension LEInteger: SignedInteger where Base : SignedInteger {
    
}

extension LEInteger: UnsignedInteger where Base : UnsignedInteger {
    
}

extension LEInteger {
    
    @_transparent
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(representingValue: Base(integerLiteral: value))
    }
    
    @_transparent
    public init?<T : BinaryInteger>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init?<T : BinaryFloatingPoint>(exactly source: T) {
        guard let value = Base(exactly: source) else { return nil }
        self.init(representingValue: value)
    }
    
    @_transparent
    public init(_ value: Base) {
        self.init(representingValue: value)
    }
    
    @_transparent
    public init<T : BinaryInteger>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @_transparent
    public init<T : BinaryFloatingPoint>(_ source: T) {
        self.init(representingValue: Base(source))
    }
    
    @_transparent
    public init<T : BinaryInteger>(truncatingIfNeeded source: T) {
        self.init(representingValue: Base(truncatingIfNeeded: source))
    }
    
    @_transparent
    public init<T : BinaryInteger>(clamping source: T) {
        self.init(representingValue: Base(clamping: source))
    }
    
    @_transparent
    public init(_truncatingBits bits: UInt) {
        self.init(representingValue: Base(_truncatingBits: bits))
    }
}

extension LEInteger {
    
    @_transparent
    public static var isSigned: Bool {
        return Base.isSigned
    }
    
    @_transparent
    public static var bitWidth: Int {
        return Base.bitWidth
    }
    
    @_transparent
    public static var max: LEInteger {
        return LEInteger(representingValue: Base.max)
    }
    
    @_transparent
    public static var min: LEInteger {
        return LEInteger(representingValue: Base.min)
    }
}

extension LEInteger {
    
    @_transparent
    public var description: String {
        return representingValue.description
    }
    
    @_transparent
    public var bitWidth: Int {
        return representingValue.bitWidth
    }
    
    @_transparent
    public var magnitude: Base.Magnitude {
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
    public var byteSwapped: LEInteger {
        return LEInteger(representingValue: representingValue.byteSwapped)
    }
}

extension LEInteger {
    
    @_transparent
    public var words: Base.Words {
        return self.representingValue.words
    }
    
    @_transparent
    public func distance(to other: LEInteger) -> Base.Stride {
        return self.representingValue.distance(to: other.representingValue)
    }
    
    @_transparent
    public func advanced(by n: Base.Stride) -> LEInteger {
        return LEInteger(representingValue: self.representingValue.advanced(by: n))
    }
    
    @_transparent
    public func addingReportingOverflow(_ rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.addingReportingOverflow(rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func subtractingReportingOverflow(_ rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.subtractingReportingOverflow(rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedReportingOverflow(by rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.multipliedReportingOverflow(by: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func dividedReportingOverflow(by rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.dividedReportingOverflow(by: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func remainderReportingOverflow(dividingBy rhs: LEInteger) -> (partialValue: LEInteger, overflow: Bool) {
        let (partialValue, overflow) = representingValue.remainderReportingOverflow(dividingBy: rhs.representingValue)
        return (LEInteger(representingValue: partialValue), overflow)
    }
    
    @_transparent
    public func multipliedFullWidth(by other: LEInteger) -> (high: LEInteger, low: Base.Magnitude) {
        let (high, low) = representingValue.multipliedFullWidth(by: other.representingValue)
        return (LEInteger(representingValue: high), low)
    }
    
    @_transparent
    public func dividingFullWidth(_ dividend: (high: LEInteger, low: Base.Magnitude)) -> (quotient: LEInteger, remainder: LEInteger) {
        let (quotient, remainder) = representingValue.dividingFullWidth((dividend.high.representingValue, dividend.low))
        return (LEInteger(representingValue: quotient), LEInteger(representingValue: remainder))
    }
}

@_transparent
public prefix func + <Base>(x: BEInteger<Base>) -> BEInteger<Base> {
    return x
}
@_transparent
public func + <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue + rhs.representingValue)
}
@_transparent
public func += <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue += rhs.representingValue
}
@_transparent
public func - <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue - rhs.representingValue)
}
@_transparent
public func -= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue -= rhs.representingValue
}
@_transparent
public func * <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue * rhs.representingValue)
}
@_transparent
public func *= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue *= rhs.representingValue
}
@_transparent
public func / <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue / rhs.representingValue)
}
@_transparent
public func /= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue /= rhs.representingValue
}
@_transparent
public func % <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue % rhs.representingValue)
}
@_transparent
public func %= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue %= rhs.representingValue
}
@_transparent
public func & <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue & rhs.representingValue)
}
@_transparent
public func &= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue &= rhs.representingValue
}
@_transparent
public func | <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue | rhs.representingValue)
}
@_transparent
public func |= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue |= rhs.representingValue
}
@_transparent
public func ^ <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue ^ rhs.representingValue)
}
@_transparent
public func ^= <Base>(lhs: inout BEInteger<Base>, rhs: BEInteger<Base>) {
    lhs.representingValue ^= rhs.representingValue
}
@_transparent
public prefix func ~ <Base>(x: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: ~x.representingValue)
}
@_transparent
public func &>> <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue &>> rhs.representingValue)
}
@_transparent
public func &<< <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> BEInteger<Base> {
    return BEInteger(representingValue: lhs.representingValue &<< rhs.representingValue)
}
@_transparent
public func > <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> Bool {
    return lhs.representingValue > rhs.representingValue
}
@_transparent
public func < <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> Bool {
    return lhs.representingValue < rhs.representingValue
}
@_transparent
public func >= <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> Bool {
    return lhs.representingValue >= rhs.representingValue
}
@_transparent
public func <= <Base>(lhs: BEInteger<Base>, rhs: BEInteger<Base>) -> Bool {
    return lhs.representingValue <= rhs.representingValue
}

@_transparent
public prefix func + <Base>(x: LEInteger<Base>) -> LEInteger<Base> {
    return x
}
@_transparent
public func + <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue + rhs.representingValue)
}
@_transparent
public func += <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue += rhs.representingValue
}
@_transparent
public func - <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue - rhs.representingValue)
}
@_transparent
public func -= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue -= rhs.representingValue
}
@_transparent
public func * <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue * rhs.representingValue)
}
@_transparent
public func *= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue *= rhs.representingValue
}
@_transparent
public func / <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue / rhs.representingValue)
}
@_transparent
public func /= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue /= rhs.representingValue
}
@_transparent
public func % <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue % rhs.representingValue)
}
@_transparent
public func %= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue %= rhs.representingValue
}
@_transparent
public func & <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue & rhs.representingValue)
}
@_transparent
public func &= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue &= rhs.representingValue
}
@_transparent
public func | <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue | rhs.representingValue)
}
@_transparent
public func |= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue |= rhs.representingValue
}
@_transparent
public func ^ <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue ^ rhs.representingValue)
}
@_transparent
public func ^= <Base>(lhs: inout LEInteger<Base>, rhs: LEInteger<Base>) {
    lhs.representingValue ^= rhs.representingValue
}
@_transparent
public prefix func ~ <Base>(x: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: ~x.representingValue)
}
@_transparent
public func &>> <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue &>> rhs.representingValue)
}
@_transparent
public func &<< <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> LEInteger<Base> {
    return LEInteger(representingValue: lhs.representingValue &<< rhs.representingValue)
}
@_transparent
public func > <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> Bool {
    return lhs.representingValue > rhs.representingValue
}
@_transparent
public func < <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> Bool {
    return lhs.representingValue < rhs.representingValue
}
@_transparent
public func >= <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> Bool {
    return lhs.representingValue >= rhs.representingValue
}
@_transparent
public func <= <Base>(lhs: LEInteger<Base>, rhs: LEInteger<Base>) -> Bool {
    return lhs.representingValue <= rhs.representingValue
}

extension FixedWidthInteger {
    
    @_transparent
    public init(_ value: BEInteger<Self>) {
        self = value.representingValue
    }
    
    @_transparent
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
    
    @_transparent
    public init(_ value: BEUInt) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEUInt8) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEUInt16) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEUInt32) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEUInt64) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEInt) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEInt8) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEInt16) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEInt32) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: BEInt64) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEUInt) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEUInt8) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEUInt16) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEUInt32) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEUInt64) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEInt) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEInt8) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEInt16) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEInt32) {
        self.init(value.representingValue)
    }
    @_transparent
    public init(_ value: LEInt64) {
        self.init(value.representingValue)
    }
}
