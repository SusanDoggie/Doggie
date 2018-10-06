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

public protocol Homomorphism {
    
    associatedtype Element
    
    func map(_ transform: (Element) -> Element) -> Self
}

extension Homomorphism where Self : Additive, Element : Additive {
    
    @_transparent
    public static prefix func + (val: Self) -> Self {
        return val
    }
    @_transparent
    public static prefix func - (val: Self) -> Self {
        return val.map { -$0 }
    }
}

extension Homomorphism where Self : ScalarMultiplicative, Element : ScalarMultiplicative, Self.Scalar == Element.Scalar {
    
    @_transparent
    public static func * (lhs: Scalar, rhs: Self) -> Self {
        return rhs.map { lhs * $0 }
    }
    @_transparent
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        return lhs.map { $0 * rhs }
    }
    @_transparent
    public static func / (lhs: Self, rhs: Scalar) -> Self {
        return lhs.map { $0 / rhs }
    }
    @_transparent
    public static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
    @_transparent
    public static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}
