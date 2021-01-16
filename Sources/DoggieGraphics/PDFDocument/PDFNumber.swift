//
//  PDFNumber.swift
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

@frozen
public struct PDFNumber: Hashable {
    
    @usableFromInline
    var base: Base
    
    @inlinable
    public init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self.base = .signed(Int64(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self.base = .unsigned(UInt64(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self.base = .number(Double(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self.base = .decimal(value)
    }
}

extension PDFNumber {
    
    @usableFromInline
    enum Base: Hashable {
        case signed(Int64)
        case unsigned(UInt64)
        case number(Double)
        case decimal(Decimal)
    }
}

extension PDFNumber: ExpressibleByIntegerLiteral {
    
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension PDFNumber: ExpressibleByFloatLiteral {
    
    @inlinable
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension PDFNumber: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch base {
        case let .signed(value): return "\(value)"
        case let .unsigned(value): return "\(value)"
        case let .number(value): return "\(Decimal(value).rounded(scale: 9))"
        case let .decimal(value): return "\(value)"
        }
    }
}

extension PDFNumber {
    
    @inlinable
    public var int64Value: Int64? {
        switch base {
        case let .signed(value): return value
        case let .unsigned(value): return Int64(exactly: value)
        case let .number(value): return Int64(exactly: value)
        case let .decimal(value):
            let int64 = NSDecimalNumber(decimal: value).int64Value
            return Decimal(int64) == value ? int64 : nil
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch base {
        case let .signed(value): return UInt64(exactly: value)
        case let .unsigned(value): return value
        case let .number(value): return UInt64(exactly: value)
        case let .decimal(value):
            let uint64 = NSDecimalNumber(decimal: value).uint64Value
            return Decimal(uint64) == value ? uint64 : nil
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch base {
        case let .signed(value): return Double(value)
        case let .unsigned(value): return Double(value)
        case let .number(value): return value
        case let .decimal(value): return value.doubleValue
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch base {
        case let .signed(value): return Decimal(value)
        case let .unsigned(value): return Decimal(value)
        case let .number(value): return Decimal(value)
        case let .decimal(value): return value
        }
    }
}

extension PDFNumber {
    
    @inlinable
    public func encode(_ data: inout Data) {
        switch base {
        case let .signed(value): data.append(utf8: "\(value)")
        case let .unsigned(value): data.append(utf8: "\(value)")
        case let .number(value): data.append(utf8: "\(Decimal(value).rounded(scale: 9))")
        case let .decimal(value): data.append(utf8: "\(value)")
        }
    }
}
