//
//  Rational.swift
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
public struct Rational: Comparable, Hashable {
    
    public let numerator: Int64
    public let denominator: Int64
    
    @inlinable
    @inline(__always)
    public init<T: BinaryInteger>(_ numerator: T) {
        self.numerator = Int64(numerator)
        self.denominator = 1
    }
    
    @inlinable
    @inline(__always)
    public init<T: UnsignedInteger>(_ numerator: T, _ denominator: T) {
        
        if numerator == 0 || denominator == 0 || numerator == 1 || denominator == 1 {
            
            self.numerator = Int64(numerator)
            self.denominator = Int64(denominator)
            
        } else {
            
            let common = gcd(numerator, denominator)
            
            self.numerator = Int64(numerator / common)
            self.denominator = Int64(denominator / common)
        }
    }
    
    @inlinable
    @inline(__always)
    public init<T: SignedInteger>(_ numerator: T, _ denominator: T) {
        
        if numerator == 0 || denominator == 0 || numerator == 1 || denominator == 1 {
            
            self.numerator = Int64(numerator)
            self.denominator = Int64(denominator)
            
        } else {
            
            let common = gcd(Swift.abs(numerator), Swift.abs(denominator))
            
            if denominator < 0 {
                self.numerator = Int64(-numerator / common)
                self.denominator = Int64(-denominator / common)
            } else {
                self.numerator = Int64(numerator / common)
                self.denominator = Int64(denominator / common)
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(_ value: T) {
        
        if value.isZero {
            
            self.init(0)
            
        } else if value.isFinite {
            
            let bias = 1 << T.significandBitCount
            let exponent = value.exponent
            
            let n = Int(value.significandBitPattern) | bias
            self.init(value.sign == .plus ? n : -n, bias)
            
            self *= exponent > 0 ? Rational(1 << exponent, 1) : Rational(1, 1 << -exponent)
            
        } else {
            self.init(0, 0)
        }
    }
}

extension Rational: ExpressibleByFloatLiteral {
    
    @inlinable
    @inline(__always)
    public init(integerLiteral value: Int64) {
        self.init(value)
    }
    
    @inlinable
    @inline(__always)
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension Rational: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "\(doubleValue)"
    }
}

extension Rational: SignedNumeric {
    
    @inlinable
    @inline(__always)
    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard let value = Int64(exactly: source) else { return nil }
        self.init(value)
    }
    
    public typealias Magnitude = Rational
    
    @inlinable
    @inline(__always)
    public static func abs(_ x: Rational) -> Rational {
        return x.magnitude
    }
    
    @inlinable
    @inline(__always)
    public var magnitude: Rational {
        return Rational(Swift.abs(numerator), denominator)
    }
}

extension Rational {
    
    @inlinable
    @inline(__always)
    public var floatValue: Float {
        return Float(doubleValue)
    }
    
    @inlinable
    @inline(__always)
    public var doubleValue: Double {
        return Double(numerator) / Double(denominator)
    }
}

extension Rational {
    
    @inlinable
    @inline(__always)
    public func distance(to other: Rational) -> Rational {
        return other - self
    }
    
    @inlinable
    @inline(__always)
    public func advanced(by n: Rational) -> Rational {
        return self + n
    }
}

extension Rational: ScalarProtocol {
    
    public typealias Scalar = Rational
    
    @inlinable
    @inline(__always)
    public init() {
        self.init(0)
    }
}

@inlinable
@inline(__always)
func _common_denom(_ lhs: Rational, _ rhs: Rational) -> (Int64, Int64, Int64) {
    let denom = gcd(lhs.denominator, rhs.denominator)
    let d1 = lhs.denominator / denom
    let d2 = rhs.denominator / denom
    return (lhs.numerator * d2, rhs.numerator * d1, lhs.denominator * d2)
}

@inlinable
@inline(__always)
public func <(lhs: Rational, rhs: Rational) -> Bool {
    let (n1, n2, _) = _common_denom(lhs, rhs)
    return n1 < n2
}

@inlinable
@inline(__always)
public prefix func +(x: Rational) -> Rational {
    return x
}

@inlinable
@inline(__always)
public prefix func -(x: Rational) -> Rational {
    return Rational(-x.numerator, x.denominator)
}

@inlinable
@inline(__always)
public func +(lhs: Rational, rhs: Rational) -> Rational {
    let (n1, n2, denom) = _common_denom(lhs, rhs)
    return Rational(n1 + n2, denom)
}

@inlinable
@inline(__always)
public func -(lhs: Rational, rhs: Rational) -> Rational {
    let (n1, n2, denom) = _common_denom(lhs, rhs)
    return Rational(n1 - n2, denom)
}

@inlinable
@inline(__always)
public func *(lhs: Rational, rhs: Rational) -> Rational {
    return Rational(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator)
}

@inlinable
@inline(__always)
public func /(lhs: Rational, rhs: Rational) -> Rational {
    return Rational(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
}

@inlinable
@inline(__always)
public func +=(lhs: inout Rational, rhs: Rational) {
    lhs = lhs + rhs
}

@inlinable
@inline(__always)
public func -=(lhs: inout Rational, rhs: Rational) {
    lhs = lhs - rhs
}

@inlinable
@inline(__always)
public func *=(lhs: inout Rational, rhs: Rational) {
    lhs = lhs * rhs
}

@inlinable
@inline(__always)
public func /=(lhs: inout Rational, rhs: Rational) {
    lhs = lhs / rhs
}

