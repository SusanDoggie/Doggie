//
//  Arithmetic.swift
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

public protocol Additive : Equatable {
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func += (lhs: inout Self, rhs: Self)
    
    static func - (lhs: Self, rhs: Self) -> Self
    
    static func -= (lhs: inout Self, rhs: Self)
    
    static prefix func + (x: Self) -> Self
    
    static prefix func - (x: Self) -> Self
}

public protocol ScalarProtocol: SignedNumeric, Strideable, ExpressibleByFloatLiteral, Multiplicative, ScalarMultiplicative where Scalar == Self {
    
    static func * (lhs: Self, rhs: Self) -> Self
    
    static func *= (lhs: inout Self, rhs: Self)
}

public protocol ScalarMultiplicative : Additive {
    
    associatedtype Scalar : ScalarProtocol
    
    init()
    
    static func * (lhs: Scalar, rhs: Self) -> Self
    
    static func * (lhs: Self, rhs: Scalar) -> Self
    
    static func *= (lhs: inout Self, rhs: Scalar)
    
    static func / (lhs: Self, rhs: Scalar) -> Self
    
    static func /= (lhs: inout Self, rhs: Scalar)
}

public protocol Multiplicative : Equatable {
    
    static func * (lhs: Self, rhs: Self) -> Self
    
    static func *= (lhs: inout Self, rhs: Self)
}

public protocol MapReduce {
    
    associatedtype Element
    
    func map(_ transform: (Element) -> Element) -> Self
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result
    
    func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> ()) -> Result
}

extension MapReduce {
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return self.reduce(into: initialResult) { $0 = nextPartialResult($0, $1) }
    }
}

extension MapReduce where Self : Additive, Element : Additive {
    
    @inlinable
    @inline(__always)
    public static prefix func + (val: Self) -> Self {
        return val
    }
    @inlinable
    @inline(__always)
    public static prefix func - (val: Self) -> Self {
        return val.map { -$0 }
    }
}

extension MapReduce where Self : ScalarMultiplicative, Element : ScalarMultiplicative, Self.Scalar == Element.Scalar {
    
    @inlinable
    @inline(__always)
    public static func * (lhs: Scalar, rhs: Self) -> Self {
        return rhs.map { lhs * $0 }
    }
    @inlinable
    @inline(__always)
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        return lhs.map { $0 * rhs }
    }
    @inlinable
    @inline(__always)
    public static func / (lhs: Self, rhs: Scalar) -> Self {
        return lhs.map { $0 / rhs }
    }
    @inlinable
    @inline(__always)
    public static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
    @inlinable
    @inline(__always)
    public static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}
