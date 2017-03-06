//
//  FloatingPoint.swift
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

import Foundation

public protocol FloatingMathProtocol : FloatingPoint {
    
    static func exp(_ x: Self) -> Self
    static func exp2(_ x: Self) -> Self
    static func expm1(_ x: Self) -> Self
    static func log(_ x: Self) -> Self
    static func log10(_ x: Self) -> Self
    static func log2(_ x: Self) -> Self
    static func log1p(_ x: Self) -> Self
    static func pow(_ x: Self, _ y: Self) -> Self
    static func sqrt(_ x: Self) -> Self
    static func cbrt(_ x: Self) -> Self
    static func hypot(_ x: Self, _ y: Self) -> Self
    static func sin(_ x: Self) -> Self
    static func cos(_ x: Self) -> Self
    static func tan(_ x: Self) -> Self
    static func asin(_ x: Self) -> Self
    static func acos(_ x: Self) -> Self
    static func atan(_ x: Self) -> Self
    static func atan2(_ y: Self, _ x: Self) -> Self
    static func sinh(_ x: Self) -> Self
    static func cosh(_ x: Self) -> Self
    static func tanh(_ x: Self) -> Self
    static func asinh(_ x: Self) -> Self
    static func acosh(_ x: Self) -> Self
    static func atanh(_ x: Self) -> Self
    static func erf(_ x: Self) -> Self
    static func erfc(_ x: Self) -> Self
    static func tgamma(_ x: Self) -> Self
    
}

extension Float : FloatingMathProtocol {
    
    public static func exp(_ x: Float) -> Float {
        return Foundation.exp(x)
    }
    public static func exp2(_ x: Float) -> Float {
        return Foundation.exp2(x)
    }
    public static func expm1(_ x: Float) -> Float {
        return Foundation.expm1(x)
    }
    public static func log(_ x: Float) -> Float {
        return Foundation.log(x)
    }
    public static func log10(_ x: Float) -> Float {
        return Foundation.log10(x)
    }
    public static func log2(_ x: Float) -> Float {
        return Foundation.log2(x)
    }
    public static func log1p(_ x: Float) -> Float {
        return Foundation.log1p(x)
    }
    public static func pow(_ x: Float, _ y: Float) -> Float {
        return Foundation.pow(x, y)
    }
    public static func sqrt(_ x: Float) -> Float {
        return Foundation.sqrt(x)
    }
    public static func cbrt(_ x: Float) -> Float {
        return Foundation.cbrt(x)
    }
    public static func hypot(_ x: Float, _ y: Float) -> Float {
        return Foundation.hypot(x, y)
    }
    public static func sin(_ x: Float) -> Float {
        return Foundation.sin(x)
    }
    public static func cos(_ x: Float) -> Float {
        return Foundation.cos(x)
    }
    public static func tan(_ x: Float) -> Float {
        return Foundation.tan(x)
    }
    public static func asin(_ x: Float) -> Float {
        return Foundation.asin(x)
    }
    public static func acos(_ x: Float) -> Float {
        return Foundation.acos(x)
    }
    public static func atan(_ x: Float) -> Float {
        return Foundation.atan(x)
    }
    public static func atan2(_ y: Float, _ x: Float) -> Float {
        return Foundation.atan2(y, x)
    }
    public static func sinh(_ x: Float) -> Float {
        return Foundation.sinh(x)
    }
    public static func cosh(_ x: Float) -> Float {
        return Foundation.cosh(x)
    }
    public static func tanh(_ x: Float) -> Float {
        return Foundation.tanh(x)
    }
    public static func asinh(_ x: Float) -> Float {
        return Foundation.asinh(x)
    }
    public static func acosh(_ x: Float) -> Float {
        return Foundation.acosh(x)
    }
    public static func atanh(_ x: Float) -> Float {
        return Foundation.atanh(x)
    }
    public static func erf(_ x: Float) -> Float {
        return Foundation.erf(x)
    }
    public static func erfc(_ x: Float) -> Float {
        return Foundation.erfc(x)
    }
    public static func tgamma(_ x: Float) -> Float {
        return Foundation.tgamma(x)
    }
    
}

extension Double : FloatingMathProtocol {
    
    public static func exp(_ x: Double) -> Double {
        return Foundation.exp(x)
    }
    public static func exp2(_ x: Double) -> Double {
        return Foundation.exp2(x)
    }
    public static func expm1(_ x: Double) -> Double {
        return Foundation.expm1(x)
    }
    public static func log(_ x: Double) -> Double {
        return Foundation.log(x)
    }
    public static func log10(_ x: Double) -> Double {
        return Foundation.log10(x)
    }
    public static func log2(_ x: Double) -> Double {
        return Foundation.log2(x)
    }
    public static func log1p(_ x: Double) -> Double {
        return Foundation.log1p(x)
    }
    public static func pow(_ x: Double, _ y: Double) -> Double {
        return Foundation.pow(x, y)
    }
    public static func sqrt(_ x: Double) -> Double {
        return Foundation.sqrt(x)
    }
    public static func cbrt(_ x: Double) -> Double {
        return Foundation.cbrt(x)
    }
    public static func hypot(_ x: Double, _ y: Double) -> Double {
        return Foundation.hypot(x, y)
    }
    public static func sin(_ x: Double) -> Double {
        return Foundation.sin(x)
    }
    public static func cos(_ x: Double) -> Double {
        return Foundation.cos(x)
    }
    public static func tan(_ x: Double) -> Double {
        return Foundation.tan(x)
    }
    public static func asin(_ x: Double) -> Double {
        return Foundation.asin(x)
    }
    public static func acos(_ x: Double) -> Double {
        return Foundation.acos(x)
    }
    public static func atan(_ x: Double) -> Double {
        return Foundation.atan(x)
    }
    public static func atan2(_ y: Double, _ x: Double) -> Double {
        return Foundation.atan2(y, x)
    }
    public static func sinh(_ x: Double) -> Double {
        return Foundation.sinh(x)
    }
    public static func cosh(_ x: Double) -> Double {
        return Foundation.cosh(x)
    }
    public static func tanh(_ x: Double) -> Double {
        return Foundation.tanh(x)
    }
    public static func asinh(_ x: Double) -> Double {
        return Foundation.asinh(x)
    }
    public static func acosh(_ x: Double) -> Double {
        return Foundation.acosh(x)
    }
    public static func atanh(_ x: Double) -> Double {
        return Foundation.atanh(x)
    }
    public static func erf(_ x: Double) -> Double {
        return Foundation.erf(x)
    }
    public static func erfc(_ x: Double) -> Double {
        return Foundation.erfc(x)
    }
    public static func tgamma(_ x: Double) -> Double {
        return Foundation.tgamma(x)
    }
    
}

public func positive_mod<T: FloatingPoint>(_ x: T, _ m: T) -> T {
    let r = x.remainder(dividingBy: m)
    return r < 0 ? r + m : r
}

extension FloatingPoint {
    
    private static var defaultAlmostEqualEpsilon: Self {
        return Self(sign: .plus, exponent: Self.ulpOfOne.exponent / 2, significand: 1)
    }
    
    public func almostZero(epsilon: Self = Self.defaultAlmostEqualEpsilon, reference: Self = 0) -> Bool {
        return self == 0 || abs(self) < abs(epsilon) * max(1, abs(reference))
    }
    
    public func almostEqual(_ other: Self, epsilon: Self = Self.defaultAlmostEqualEpsilon) -> Bool {
        return self == other || abs(self - other).almostZero(epsilon: epsilon, reference: self)
    }
}
