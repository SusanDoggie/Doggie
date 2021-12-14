//
//  JsonNumber.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
