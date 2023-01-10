//
//  JsonNumber.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

extension Json {
    
    @frozen
    public enum Number {
        
        case signed(Int64)
        
        case unsigned(UInt64)
        
        case number(Double)
        
        case decimal(Decimal)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Json.Number: Sendable { }

extension Json.Number {
    
    @inlinable
    public init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self = .signed(Int64(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self = .unsigned(UInt64(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self = .number(Double(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self = .decimal(value)
    }
}

extension Json.Number: Equatable {
    
    @inlinable
    public static func ==(lhs: Json.Number, rhs: Json.Number) -> Bool {
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(lhs), .signed(rhs)): return lhs == rhs
        case let (.unsigned(lhs), .unsigned(rhs)): return lhs == rhs
        case let (.number(lhs), .number(rhs)): return lhs == rhs
        case let (.decimal(lhs), .decimal(rhs)): return lhs == rhs
        default: return false
        }
    }
}

extension Json.Number: Comparable {
    
    @inlinable
    var _doubleValue: Double {
        switch self {
        case let .signed(value): return Double(value)
        case let .unsigned(value): return Double(value)
        case let .number(value): return value
        case let .decimal(value): return value.doubleValue
        }
    }
    
    @inlinable
    public static func < (lhs: Json.Number, rhs: Json.Number) -> Bool {
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(lhs), .signed(rhs)): return lhs < rhs
        case let (.unsigned(lhs), .unsigned(rhs)): return lhs < rhs
        case let (.number(lhs), .number(rhs)): return lhs < rhs
        case let (.decimal(lhs), .decimal(rhs)): return lhs < rhs
        default: return lhs._doubleValue < rhs._doubleValue
        }
    }
}

extension Json.Number: Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        switch normalized {
        case let .signed(value): hasher.combine(value)
        case let .unsigned(value): hasher.combine(value)
        case let .number(value): hasher.combine(value)
        case let .decimal(value): hasher.combine(value)
        }
    }
}

extension Json.Number: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch self {
        case let .signed(value): return "\(value)"
        case let .unsigned(value): return "\(value)"
        case let .number(value): return "\(value)"
        case let .decimal(value): return "\(value)"
        }
    }
}

extension Json.Number {
    
    @inlinable
    public var normalized: Json.Number {
        switch self {
        case let .signed(value): return value < 0 ? .signed(value) : .unsigned(UInt64(value))
        case let .unsigned(value): return .unsigned(value)
        case let .number(value):
            
            if value.sign == .plus, let integer = UInt64(exactly: value) {
                
                return .unsigned(integer)
                
            } else if let integer = Int64(exactly: value) {
                
                return .signed(integer)
                
            } else if let decimal = Decimal(exactly: value) {
                
                return .decimal(decimal)
                
            } else {
                
                return .number(value)
            }
            
        case let .decimal(value):
            
            if value.sign == .plus, let integer = UInt64(exactly: value) {
                
                return .unsigned(integer)
                
            } else if let integer = Int64(exactly: value) {
                
                return .signed(integer)
                
            } else {
                
                return .decimal(value)
            }
        }
    }
}

extension Json.Number {
    
    @inlinable
    public var int8Value: Int8? {
        switch self {
        case let .signed(value): return Int8(exactly: value)
        case let .unsigned(value): return Int8(exactly: value)
        case let .number(value): return Int8(exactly: value)
        case let .decimal(value): return Int8(exactly: value)
        }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        switch self {
        case let .signed(value): return UInt8(exactly: value)
        case let .unsigned(value): return UInt8(exactly: value)
        case let .number(value): return UInt8(exactly: value)
        case let .decimal(value): return UInt8(exactly: value)
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        switch self {
        case let .signed(value): return Int16(exactly: value)
        case let .unsigned(value): return Int16(exactly: value)
        case let .number(value): return Int16(exactly: value)
        case let .decimal(value): return Int16(exactly: value)
        }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        switch self {
        case let .signed(value): return UInt16(exactly: value)
        case let .unsigned(value): return UInt16(exactly: value)
        case let .number(value): return UInt16(exactly: value)
        case let .decimal(value): return UInt16(exactly: value)
        }
    }
    
    @inlinable
    public var int32Value: Int32? {
        switch self {
        case let .signed(value): return Int32(exactly: value)
        case let .unsigned(value): return Int32(exactly: value)
        case let .number(value): return Int32(exactly: value)
        case let .decimal(value): return Int32(exactly: value)
        }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        switch self {
        case let .signed(value): return UInt32(exactly: value)
        case let .unsigned(value): return UInt32(exactly: value)
        case let .number(value): return UInt32(exactly: value)
        case let .decimal(value): return UInt32(exactly: value)
        }
    }
    
    @inlinable
    public var int64Value: Int64? {
        switch self {
        case let .signed(value): return value
        case let .unsigned(value): return Int64(exactly: value)
        case let .number(value): return Int64(exactly: value)
        case let .decimal(value): return Int64(exactly: value)
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch self {
        case let .signed(value): return UInt64(exactly: value)
        case let .unsigned(value): return value
        case let .number(value): return UInt64(exactly: value)
        case let .decimal(value): return UInt64(exactly: value)
        }
    }
    
    @inlinable
    public var intValue: Int? {
        switch self {
        case let .signed(value): return Int(exactly: value)
        case let .unsigned(value): return Int(exactly: value)
        case let .number(value): return Int(exactly: value)
        case let .decimal(value): return Int(exactly: value)
        }
    }
    
    @inlinable
    public var uintValue: UInt? {
        switch self {
        case let .signed(value): return UInt(exactly: value)
        case let .unsigned(value): return UInt(exactly: value)
        case let .number(value): return UInt(exactly: value)
        case let .decimal(value): return UInt(exactly: value)
        }
    }
    
    @inlinable
    public var floatValue: Float? {
        switch self {
        case let .signed(value): return Float(exactly: value)
        case let .unsigned(value): return Float(exactly: value)
        case let .number(value): return Float(value)
        case let .decimal(value): return Float(exactly: value)
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch self {
        case let .signed(value): return Double(exactly: value)
        case let .unsigned(value): return Double(exactly: value)
        case let .number(value): return value
        case let .decimal(value): return Double(exactly: value)
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch self {
        case let .signed(value): return Decimal(exactly: value)
        case let .unsigned(value): return Decimal(exactly: value)
        case let .number(value): return Decimal(exactly: value)
        case let .decimal(value): return value
        }
    }
}

extension Json.Number {
    
    @inlinable
    public func remainder(dividingBy other: Json.Number) -> Json.Number {
        switch (self, other) {
        case let (.signed(lhs), .signed(rhs)): return .init(lhs % rhs)
        case let (.unsigned(lhs), .unsigned(rhs)): return .init(lhs % rhs)
        default: return .init(self._doubleValue.remainder(dividingBy: other._doubleValue))
        }
    }
}

extension Json.Number {
    
    @inlinable
    public static func abs(_ value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(value < 0 ? -value : value)
        case let .unsigned(value): return .init(value)
        case let .number(value): return .init(value < 0 ? -value : value)
        case let .decimal(value): return .init(value < 0 ? -value : value)
        }
    }
    
    @inlinable
    public static func floor(_ value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(value)
        case let .unsigned(value): return .init(value)
        case let .number(value): return .init(value.rounded(.down))
        case let .decimal(value): return .init(value.rounded(scale: 0, roundingMode: .down))
        }
    }
    
    @inlinable
    public static func ceil(_ value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(value)
        case let .unsigned(value): return .init(value)
        case let .number(value): return .init(value.rounded(.up))
        case let .decimal(value): return .init(value.rounded(scale: 0, roundingMode: .up))
        }
    }
    
    @inlinable
    public static func round(_ value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(value)
        case let .unsigned(value): return .init(value)
        case let .number(value): return .init(value.rounded(.toNearestOrAwayFromZero))
        case let .decimal(value): return .init(value.rounded(scale: 0, roundingMode: .plain))
        }
    }
    
    @inlinable
    public static func trunc(_ value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(value)
        case let .unsigned(value): return .init(value)
        case let .number(value): return .init(value.rounded(.towardZero))
        case let .decimal(value): return .init(value.rounded(scale: 0, roundingMode: value < 0 ? .up : .down))
        }
    }
}

extension Json.Number {
    
    @inlinable
    static func _pow<T: FixedWidthInteger>(_ x: T, _ n: UInt64) -> T? {
        if x == 0 { return 0 }
        if n == 0 { return 1 }
        let (mul, overflow) = x.multipliedReportingOverflow(by: x)
        guard overflow, let p = _pow(mul, n >> 1) else { return nil }
        return n & 1 == 1 ? x * p : p
    }
    
    @inlinable
    public static func pow(_ lhs: Json.Number, _ rhs: Json.Number) -> Json.Number {
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(_lhs), .unsigned(_rhs)): return _pow(_lhs, _rhs).map { .init($0) } ?? .init(Double.pow(lhs._doubleValue, rhs._doubleValue))
        case let (.unsigned(_lhs), .unsigned(_rhs)): return _pow(_lhs, _rhs).map { .init($0) } ?? .init(Double.pow(lhs._doubleValue, rhs._doubleValue))
        case let (.decimal(_lhs), .unsigned(_rhs)): return Int(exactly: _rhs).map { .init(Foundation.pow(_lhs, $0)) } ?? .init(Double.pow(lhs._doubleValue, rhs._doubleValue))
        default: return .init(Double.pow(lhs._doubleValue, rhs._doubleValue))
        }
    }
}

extension Json.Number {
    
    @inlinable
    public static prefix func +(value: Json.Number) -> Json.Number {
        return value
    }
    
    @inlinable
    public static prefix func -(value: Json.Number) -> Json.Number {
        switch value.normalized {
        case let .signed(value): return .init(-value)
        case let .unsigned(value): return .init(-Int64(value))
        case let .number(value): return .init(-value)
        case let .decimal(value): return .init(-value)
        }
    }
    
    @inlinable
    public static func +(lhs: Json.Number, rhs: Json.Number) -> Json.Number {
        
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(_lhs), .signed(_rhs)):
            
            let (result, overflow) = _lhs.addingReportingOverflow(_rhs)
            return overflow ? .init(lhs._doubleValue + rhs._doubleValue) : .init(result)
            
        case let (.unsigned(_lhs), .unsigned(_rhs)):
            
            let (result, overflow) = _lhs.addingReportingOverflow(_rhs)
            return overflow ? .init(lhs._doubleValue + rhs._doubleValue) : .init(result)
            
        case let (.number(_lhs), .number(_rhs)): return .init(_lhs + _rhs)
        case let (.decimal(_lhs), .decimal(_rhs)): return .init(_lhs + _rhs)
        default: return .init(lhs._doubleValue + rhs._doubleValue)
        }
    }
    
    @inlinable
    public static func -(lhs: Json.Number, rhs: Json.Number) -> Json.Number {
        
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(_lhs), .signed(_rhs)):
            
            let (result, overflow) = _lhs.subtractingReportingOverflow(_rhs)
            return overflow ? .init(lhs._doubleValue - rhs._doubleValue) : .init(result)
            
        case let (.unsigned(_lhs), .unsigned(_rhs)):
            
            let (result, overflow) = _lhs.subtractingReportingOverflow(_rhs)
            return overflow ? .init(lhs._doubleValue - rhs._doubleValue) : .init(result)
            
        case let (.number(_lhs), .number(_rhs)): return .init(_lhs - _rhs)
        case let (.decimal(_lhs), .decimal(_rhs)): return .init(_lhs - _rhs)
        default: return .init(lhs._doubleValue - rhs._doubleValue)
        }
    }
    
    @inlinable
    public static func *(lhs: Json.Number, rhs: Json.Number) -> Json.Number {
        
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(_lhs), .signed(_rhs)):
            
            let (result, overflow) = _lhs.multipliedReportingOverflow(by: _rhs)
            return overflow ? .init(lhs._doubleValue * rhs._doubleValue) : .init(result)
            
        case let (.unsigned(_lhs), .unsigned(_rhs)):
            
            let (result, overflow) = _lhs.multipliedReportingOverflow(by: _rhs)
            return overflow ? .init(lhs._doubleValue * rhs._doubleValue) : .init(result)
            
        case let (.decimal(_lhs), .decimal(_rhs)): return .init(_lhs * _rhs)
        default: return .init(lhs._doubleValue * rhs._doubleValue)
        }
    }
    
    @inlinable
    public static func /(lhs: Json.Number, rhs: Json.Number) -> Json.Number {
        
        switch (lhs.normalized, rhs.normalized) {
        case let (.signed(_lhs), .signed(_rhs)):
            
            let (result, remainder) = _lhs.quotientAndRemainder(dividingBy: _rhs)
            return remainder == 0 ? .init(result) : .init(lhs._doubleValue / rhs._doubleValue)
            
        case let (.unsigned(_lhs), .unsigned(_rhs)):
            
            let (result, remainder) = _lhs.quotientAndRemainder(dividingBy: _rhs)
            return remainder == 0 ? .init(result) : .init(lhs._doubleValue / rhs._doubleValue)
            
        case let (.decimal(_lhs), .decimal(_rhs)): return .init(_lhs / _rhs)
        default: return .init(lhs._doubleValue / rhs._doubleValue)
        }
    }
}
