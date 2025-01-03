//
//  Decimal.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension Decimal {
    
    @inlinable
    @inline(__always)
    public init<Source: BinaryFloatingPoint>(_ value: Source) {
        self.init(Double(value))
    }
    
    @inlinable
    @inline(__always)
    public var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
    @inlinable
    @inline(__always)
    public func rounded(scale: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var x = self
        var result = Decimal()
        NSDecimalRound(&result, &x, scale, roundingMode)
        return result
    }
    
    @inlinable
    @inline(__always)
    public mutating func round(scale: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) {
        self = self.rounded(scale: scale, roundingMode: roundingMode)
    }
    
    @inlinable
    @inline(__always)
    public func raising(toPower power: Int, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var x = self
        var result = Decimal()
        _ = NSDecimalPower(&result, &x, power, roundingMode)
        return result
    }
    
    @inlinable
    @inline(__always)
    public func multiplying(byPowerOf10 power: Int16, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var x = self
        var result = Decimal()
        _ = NSDecimalMultiplyByPowerOf10(&result, &x, power, roundingMode)
        return result
    }
}

extension Decimal {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Double) {
        self.init(value)
        guard self.doubleValue == value else { return nil }
    }
}

extension Decimal {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: String) {
        self.init(string: value, locale: Locale(identifier: "en_US"))
        guard self.description == value else { return nil }
    }
}

extension Float {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).floatValue
        guard Decimal(self) == value else { return nil }
    }
}

extension Double {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).doubleValue
        guard Decimal(self) == value else { return nil }
    }
}

extension UInt8 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).uint8Value
        guard Decimal(self) == value else { return nil }
    }
}

extension Int8 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).int8Value
        guard Decimal(self) == value else { return nil }
    }
}

extension UInt16 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).uint16Value
        guard Decimal(self) == value else { return nil }
    }
}

extension Int16 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).int16Value
        guard Decimal(self) == value else { return nil }
    }
}

extension UInt32 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).uint32Value
        guard Decimal(self) == value else { return nil }
    }
}

extension Int32 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).int32Value
        guard Decimal(self) == value else { return nil }
    }
}

extension UInt64 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).uint64Value
        guard Decimal(self) == value else { return nil }
    }
}

extension Int64 {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).int64Value
        guard Decimal(self) == value else { return nil }
    }
}

extension UInt {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).uintValue
        guard Decimal(self) == value else { return nil }
    }
}

extension Int {
    
    @inlinable
    @inline(__always)
    public init?(exactly value: Decimal) {
        self = NSDecimalNumber(decimal: value).intValue
        guard Decimal(self) == value else { return nil }
    }
}
