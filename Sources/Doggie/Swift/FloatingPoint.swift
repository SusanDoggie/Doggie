//
//  FloatingPoint.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

public protocol FloatingMathProtocol : FloatingPoint, ExpressibleByFloatLiteral {
    
    static func exp(_ x: Self) -> Self
    static func exp2(_ x: Self) -> Self
    static func expm1(_ x: Self) -> Self
    static func log(_ x: Self) -> Self
    static func log10(_ x: Self) -> Self
    static func log2(_ x: Self) -> Self
    static func log1p(_ x: Self) -> Self
    static func pow(_ x: Self, _ y: Self) -> Self
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
    
    @inlinable
    @inline(__always)
    public static func exp(_ x: Float) -> Float {
        return Foundation.exp(x)
    }
    @inlinable
    @inline(__always)
    public static func exp2(_ x: Float) -> Float {
        return Foundation.exp2(x)
    }
    @inlinable
    @inline(__always)
    public static func expm1(_ x: Float) -> Float {
        return Foundation.expm1(x)
    }
    @inlinable
    @inline(__always)
    public static func log(_ x: Float) -> Float {
        return Foundation.log(x)
    }
    @inlinable
    @inline(__always)
    public static func log10(_ x: Float) -> Float {
        return Foundation.log10(x)
    }
    @inlinable
    @inline(__always)
    public static func log2(_ x: Float) -> Float {
        return Foundation.log2(x)
    }
    @inlinable
    @inline(__always)
    public static func log1p(_ x: Float) -> Float {
        return Foundation.log1p(x)
    }
    @inlinable
    @inline(__always)
    public static func pow(_ x: Float, _ y: Float) -> Float {
        return Foundation.pow(x, y)
    }
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: Float) -> Float {
        return Foundation.cbrt(x)
    }
    @inlinable
    @inline(__always)
    public static func hypot(_ x: Float, _ y: Float) -> Float {
        return Foundation.hypot(x, y)
    }
    @inlinable
    @inline(__always)
    public static func sin(_ x: Float) -> Float {
        return Foundation.sin(x)
    }
    @inlinable
    @inline(__always)
    public static func cos(_ x: Float) -> Float {
        return Foundation.cos(x)
    }
    @inlinable
    @inline(__always)
    public static func tan(_ x: Float) -> Float {
        return Foundation.tan(x)
    }
    @inlinable
    @inline(__always)
    public static func asin(_ x: Float) -> Float {
        return Foundation.asin(x)
    }
    @inlinable
    @inline(__always)
    public static func acos(_ x: Float) -> Float {
        return Foundation.acos(x)
    }
    @inlinable
    @inline(__always)
    public static func atan(_ x: Float) -> Float {
        return Foundation.atan(x)
    }
    @inlinable
    @inline(__always)
    public static func atan2(_ y: Float, _ x: Float) -> Float {
        return Foundation.atan2(y, x)
    }
    @inlinable
    @inline(__always)
    public static func sinh(_ x: Float) -> Float {
        return Foundation.sinh(x)
    }
    @inlinable
    @inline(__always)
    public static func cosh(_ x: Float) -> Float {
        return Foundation.cosh(x)
    }
    @inlinable
    @inline(__always)
    public static func tanh(_ x: Float) -> Float {
        return Foundation.tanh(x)
    }
    @inlinable
    @inline(__always)
    public static func asinh(_ x: Float) -> Float {
        return Foundation.asinh(x)
    }
    @inlinable
    @inline(__always)
    public static func acosh(_ x: Float) -> Float {
        return Foundation.acosh(x)
    }
    @inlinable
    @inline(__always)
    public static func atanh(_ x: Float) -> Float {
        return Foundation.atanh(x)
    }
    @inlinable
    @inline(__always)
    public static func erf(_ x: Float) -> Float {
        return Foundation.erf(x)
    }
    @inlinable
    @inline(__always)
    public static func erfc(_ x: Float) -> Float {
        return Foundation.erfc(x)
    }
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: Float) -> Float {
        return Foundation.tgamma(x)
    }
    
}

extension Double : FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    public static func exp(_ x: Double) -> Double {
        return Foundation.exp(x)
    }
    @inlinable
    @inline(__always)
    public static func exp2(_ x: Double) -> Double {
        return Foundation.exp2(x)
    }
    @inlinable
    @inline(__always)
    public static func expm1(_ x: Double) -> Double {
        return Foundation.expm1(x)
    }
    @inlinable
    @inline(__always)
    public static func log(_ x: Double) -> Double {
        return Foundation.log(x)
    }
    @inlinable
    @inline(__always)
    public static func log10(_ x: Double) -> Double {
        return Foundation.log10(x)
    }
    @inlinable
    @inline(__always)
    public static func log2(_ x: Double) -> Double {
        return Foundation.log2(x)
    }
    @inlinable
    @inline(__always)
    public static func log1p(_ x: Double) -> Double {
        return Foundation.log1p(x)
    }
    @inlinable
    @inline(__always)
    public static func pow(_ x: Double, _ y: Double) -> Double {
        return Foundation.pow(x, y)
    }
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: Double) -> Double {
        return Foundation.cbrt(x)
    }
    @inlinable
    @inline(__always)
    public static func hypot(_ x: Double, _ y: Double) -> Double {
        return Foundation.hypot(x, y)
    }
    @inlinable
    @inline(__always)
    public static func sin(_ x: Double) -> Double {
        return Foundation.sin(x)
    }
    @inlinable
    @inline(__always)
    public static func cos(_ x: Double) -> Double {
        return Foundation.cos(x)
    }
    @inlinable
    @inline(__always)
    public static func tan(_ x: Double) -> Double {
        return Foundation.tan(x)
    }
    @inlinable
    @inline(__always)
    public static func asin(_ x: Double) -> Double {
        return Foundation.asin(x)
    }
    @inlinable
    @inline(__always)
    public static func acos(_ x: Double) -> Double {
        return Foundation.acos(x)
    }
    @inlinable
    @inline(__always)
    public static func atan(_ x: Double) -> Double {
        return Foundation.atan(x)
    }
    @inlinable
    @inline(__always)
    public static func atan2(_ y: Double, _ x: Double) -> Double {
        return Foundation.atan2(y, x)
    }
    @inlinable
    @inline(__always)
    public static func sinh(_ x: Double) -> Double {
        return Foundation.sinh(x)
    }
    @inlinable
    @inline(__always)
    public static func cosh(_ x: Double) -> Double {
        return Foundation.cosh(x)
    }
    @inlinable
    @inline(__always)
    public static func tanh(_ x: Double) -> Double {
        return Foundation.tanh(x)
    }
    @inlinable
    @inline(__always)
    public static func asinh(_ x: Double) -> Double {
        return Foundation.asinh(x)
    }
    @inlinable
    @inline(__always)
    public static func acosh(_ x: Double) -> Double {
        return Foundation.acosh(x)
    }
    @inlinable
    @inline(__always)
    public static func atanh(_ x: Double) -> Double {
        return Foundation.atanh(x)
    }
    @inlinable
    @inline(__always)
    public static func erf(_ x: Double) -> Double {
        return Foundation.erf(x)
    }
    @inlinable
    @inline(__always)
    public static func erfc(_ x: Double) -> Double {
        return Foundation.erfc(x)
    }
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: Double) -> Double {
        return Foundation.tgamma(x)
    }
    
}

extension CGFloat : FloatingMathProtocol {
    
    #if canImport(CoreGraphics)
    
    @inlinable
    @inline(__always)
    public static func exp(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.exp(x)
    }
    @inlinable
    @inline(__always)
    public static func exp2(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.exp2(x)
    }
    @inlinable
    @inline(__always)
    public static func expm1(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.expm1(x)
    }
    @inlinable
    @inline(__always)
    public static func log(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.log(x)
    }
    @inlinable
    @inline(__always)
    public static func log10(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.log10(x)
    }
    @inlinable
    @inline(__always)
    public static func log2(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.log2(x)
    }
    @inlinable
    @inline(__always)
    public static func log1p(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.log1p(x)
    }
    @inlinable
    @inline(__always)
    public static func pow(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        return CoreGraphics.pow(x, y)
    }
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.cbrt(x)
    }
    @inlinable
    @inline(__always)
    public static func hypot(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        return CoreGraphics.hypot(x, y)
    }
    @inlinable
    @inline(__always)
    public static func sin(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.sin(x)
    }
    @inlinable
    @inline(__always)
    public static func cos(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.cos(x)
    }
    @inlinable
    @inline(__always)
    public static func tan(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.tan(x)
    }
    @inlinable
    @inline(__always)
    public static func asin(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.asin(x)
    }
    @inlinable
    @inline(__always)
    public static func acos(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.acos(x)
    }
    @inlinable
    @inline(__always)
    public static func atan(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.atan(x)
    }
    @inlinable
    @inline(__always)
    public static func atan2(_ y: CGFloat, _ x: CGFloat) -> CGFloat {
        return CoreGraphics.atan2(y, x)
    }
    @inlinable
    @inline(__always)
    public static func sinh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.sinh(x)
    }
    @inlinable
    @inline(__always)
    public static func cosh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.cosh(x)
    }
    @inlinable
    @inline(__always)
    public static func tanh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.tanh(x)
    }
    @inlinable
    @inline(__always)
    public static func asinh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.asinh(x)
    }
    @inlinable
    @inline(__always)
    public static func acosh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.acosh(x)
    }
    @inlinable
    @inline(__always)
    public static func atanh(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.atanh(x)
    }
    @inlinable
    @inline(__always)
    public static func erf(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.erf(x)
    }
    @inlinable
    @inline(__always)
    public static func erfc(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.erfc(x)
    }
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: CGFloat) -> CGFloat {
        return CoreGraphics.tgamma(x)
    }
    
    #else
    
    @inlinable
    @inline(__always)
    public static func exp(_ x: CGFloat) -> CGFloat {
        return Foundation.exp(x)
    }
    @inlinable
    @inline(__always)
    public static func exp2(_ x: CGFloat) -> CGFloat {
        return Foundation.exp2(x)
    }
    @inlinable
    @inline(__always)
    public static func expm1(_ x: CGFloat) -> CGFloat {
        return Foundation.expm1(x)
    }
    @inlinable
    @inline(__always)
    public static func log(_ x: CGFloat) -> CGFloat {
        return Foundation.log(x)
    }
    @inlinable
    @inline(__always)
    public static func log10(_ x: CGFloat) -> CGFloat {
        return Foundation.log10(x)
    }
    @inlinable
    @inline(__always)
    public static func log2(_ x: CGFloat) -> CGFloat {
        return Foundation.log2(x)
    }
    @inlinable
    @inline(__always)
    public static func log1p(_ x: CGFloat) -> CGFloat {
        return Foundation.log1p(x)
    }
    @inlinable
    @inline(__always)
    public static func pow(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        return Foundation.pow(x, y)
    }
    @inlinable
    @inline(__always)
    public static func cbrt(_ x: CGFloat) -> CGFloat {
        return Foundation.cbrt(x)
    }
    @inlinable
    @inline(__always)
    public static func hypot(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        return Foundation.hypot(x, y)
    }
    @inlinable
    @inline(__always)
    public static func sin(_ x: CGFloat) -> CGFloat {
        return Foundation.sin(x)
    }
    @inlinable
    @inline(__always)
    public static func cos(_ x: CGFloat) -> CGFloat {
        return Foundation.cos(x)
    }
    @inlinable
    @inline(__always)
    public static func tan(_ x: CGFloat) -> CGFloat {
        return Foundation.tan(x)
    }
    @inlinable
    @inline(__always)
    public static func asin(_ x: CGFloat) -> CGFloat {
        return Foundation.asin(x)
    }
    @inlinable
    @inline(__always)
    public static func acos(_ x: CGFloat) -> CGFloat {
        return Foundation.acos(x)
    }
    @inlinable
    @inline(__always)
    public static func atan(_ x: CGFloat) -> CGFloat {
        return Foundation.atan(x)
    }
    @inlinable
    @inline(__always)
    public static func atan2(_ y: CGFloat, _ x: CGFloat) -> CGFloat {
        return Foundation.atan2(y, x)
    }
    @inlinable
    @inline(__always)
    public static func sinh(_ x: CGFloat) -> CGFloat {
        return Foundation.sinh(x)
    }
    @inlinable
    @inline(__always)
    public static func cosh(_ x: CGFloat) -> CGFloat {
        return Foundation.cosh(x)
    }
    @inlinable
    @inline(__always)
    public static func tanh(_ x: CGFloat) -> CGFloat {
        return Foundation.tanh(x)
    }
    @inlinable
    @inline(__always)
    public static func asinh(_ x: CGFloat) -> CGFloat {
        return Foundation.asinh(x)
    }
    @inlinable
    @inline(__always)
    public static func acosh(_ x: CGFloat) -> CGFloat {
        return Foundation.acosh(x)
    }
    @inlinable
    @inline(__always)
    public static func atanh(_ x: CGFloat) -> CGFloat {
        return Foundation.atanh(x)
    }
    @inlinable
    @inline(__always)
    public static func erf(_ x: CGFloat) -> CGFloat {
        return Foundation.erf(x)
    }
    @inlinable
    @inline(__always)
    public static func erfc(_ x: CGFloat) -> CGFloat {
        return Foundation.erfc(x)
    }
    @inlinable
    @inline(__always)
    public static func tgamma(_ x: CGFloat) -> CGFloat {
        return Foundation.tgamma(x)
    }
    
    #endif
    
}

@inlinable
@inline(__always)
public func positive_mod<T: FloatingPoint>(_ x: T, _ m: T) -> T {
    let r = x.remainder(dividingBy: m)
    return r < 0 ? r + m : r
}

extension FloatingPoint {
    
    @_transparent
    public static var defaultAlmostEqualEpsilon: Self {
        return Self(sign: .plus, exponent: Self.ulpOfOne.exponent / 2, significand: 1)
    }
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Self = Self.defaultAlmostEqualEpsilon, reference: Self = 0) -> Bool {
        return self == 0 || abs(self) < abs(epsilon) * max(1, abs(reference))
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Self, epsilon: Self = Self.defaultAlmostEqualEpsilon) -> Bool {
        return self == other || abs(self - other).almostZero(epsilon: epsilon, reference: self)
    }
}
