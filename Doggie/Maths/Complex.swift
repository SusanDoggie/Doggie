//
//  Complex.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public struct Complex {
    
    public var real: Double
    public var imag: Double
    
    public init(_ real: Double) {
        self.real = real
        self.imag = 0.0
    }
    public init(real: Double, imag: Double) {
        self.real = real
        self.imag = imag
    }
    public init(_ real: Int) {
        self.real = Double(real)
        self.imag = 0.0
    }
    public init(real: Int, imag: Int) {
        self.real = Double(real)
        self.imag = Double(imag)
    }
}

extension Complex: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        
        var print = ""
        
        switch real {
        case 0: break
        case 1: "1.0".writeTo(&print)
        case -1: "-1.0".writeTo(&print)
        default: String(format: "%.2f", real).writeTo(&print)
        }
        
        if imag != 0 {
            if !print.isEmpty && !imag.isSignMinus {
                "+".writeTo(&print)
            }
            switch imag {
            case 1: "𝒊".writeTo(&print)
            case -1: "-𝒊".writeTo(&print)
            default: String(format: "%.2f𝒊", imag).writeTo(&print)
            }
        }
        
        if print.isEmpty {
            print = "0.0"
        }
        return print
    }
    
    public var debugDescription: String {
        return self.description
    }
}

extension Complex: Hashable {
    
    public var hashValue: Int {
        return hash_combine(0, real, imag)
    }
}

extension Int8 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension Int16 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension Int32 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension Int64 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension Int {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}

extension UInt8 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension UInt16 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension UInt32 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension UInt64 {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}
extension UInt {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}

extension Float {
    public var i: Complex { return Complex(real: 0, imag: Double(self)) }
}

extension Double {
    public var i: Complex { return Complex(real: 0, imag: self) }
}

@warn_unused_result
public func norm(value: Complex) -> Double {
    return value.real * value.real + value.imag * value.imag
}
@warn_unused_result
public func abs(value: Complex) -> Double {
    return sqrt(norm(value))
}
@warn_unused_result
public func arg(value: Complex) -> Double {
    return atan2(value.imag, value.real)
}
@warn_unused_result
public func conj(value: Complex) -> Complex {
    return Complex(real: value.real, imag: -value.imag)
}
@warn_unused_result
public func polar(rho rho: Double, theta: Double) -> Complex {
    return rho * cis(theta)
}

@warn_unused_result
public func exp(value: Complex) -> Complex {
    return exp(value.real) * cis(value.imag)
}
@warn_unused_result
public func cis(theta: Double) -> Complex {
    return Complex(real: cos(theta), imag: sin(theta))
}

@warn_unused_result
public func cocis(theta: Double) -> Complex {
    return Complex(real: sin(theta), imag: cos(theta))
}

@warn_unused_result
public func sin(x: Complex) -> Complex {
    return Complex(real: sin(x.real) * cosh(x.imag), imag: cos(x.real) * sinh(x.imag))
}
@warn_unused_result
public func cos(x: Complex) -> Complex {
    return Complex(real: cos(x.real) * cosh(x.imag), imag: -sin(x.real) * sinh(x.imag))
}

@warn_unused_result
public func tan(x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) + cosh(_imag)
    return Complex(real: sin(_real) / d, imag: sinh(_imag) / d)
}

@warn_unused_result
public func cot(x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) - cosh(_imag)
    return Complex(real: -sin(_real) / d, imag: sinh(_imag) / d)
}

@warn_unused_result
public func sec(x: Complex) -> Complex {
    let d = cos(x.real * 2) + cosh(x.imag * 2)
    return Complex(real: 2 * cos(x.real) * cosh(x.imag) / d, imag: 2 * sin(x.real) * sinh(x.imag) / d)
}

@warn_unused_result
public func csc(x: Complex) -> Complex {
    let d = cos(x.real * 2) - cosh(x.imag * 2)
    return Complex(real: -2 * sin(x.real) * cosh(x.imag) / d, imag: 2 * cos(x.real) * sinh(x.imag) / d)
}

@warn_unused_result
public func sinh(x: Complex) -> Complex {
    return Complex(real: sinh(x.real) * cos(x.imag), imag: cosh(x.real) * sin(x.imag))
}

@warn_unused_result
public func cosh(x: Complex) -> Complex {
    return Complex(real: cosh(x.real) * cos(x.imag), imag: sinh(x.real) * sin(x.imag))
}

@warn_unused_result
public func tanh(x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) + cosh(_imag)
    return Complex(real: sinh(_real) / d, imag: sin(_imag) / d)
}

@warn_unused_result
public func asin(x: Complex) -> Complex {
    let z = asinh(Complex(real: x.imag, imag: -x.real))
    return Complex(real: -z.imag, imag: z.real)
}

@warn_unused_result
public func acos(x: Complex) -> Complex {
    return M_PI_2 - asin(x)
}

@warn_unused_result
public func atan(x: Complex) -> Complex {
    let z = atanh(Complex(real: -x.imag, imag: x.real))
    return Complex(real: z.imag, imag: -z.real)
}

@warn_unused_result
public func asec(x: Complex) -> Complex {
    return M_PI_2 - acsc(x)
}

@warn_unused_result
public func acsc(x: Complex) -> Complex {
    return asin(1 / x)
}

@warn_unused_result
public func acot(x: Complex) -> Complex {
    return atan(1 / x)
}

@warn_unused_result
public func asinh(x: Complex) -> Complex {
    return log(x + sqrt(x * x + 1))
}

@warn_unused_result
public func acosh(x: Complex) -> Complex {
    return log(x + sqrt(x * x - 1))
}

@warn_unused_result
public func atanh(x: Complex) -> Complex {
    return (log(1 + x) - log(1 - x)) * 0.5
}

@warn_unused_result
public func log(c: Complex) -> Complex {
    return Complex(real: log(abs(c)), imag: arg(c))
}

@warn_unused_result
public func log10(c: Complex) -> Complex {
    return log(c) / M_LN10
}

@warn_unused_result
public func pow(a: Complex, _ b: Complex) -> Complex {
    let _norm = norm(a)
    let _arg = arg(a)
    return pow(_norm, 0.5 * b.real) * exp(-b.imag * _arg) * cis(b.real * _arg + 0.5 * b.imag * log(_norm))
}

@warn_unused_result
public func pow(c: Complex, _ n: Double) -> Complex {
    return pow(norm(c), 0.5 * n) * cis(arg(c) * n)
}

@warn_unused_result
public func sqrt(c: Complex) -> Complex {
    return sqrt(abs(c)) * cis(0.5 * arg(c))
}

@warn_unused_result
public func cbrt(c: Complex) -> Complex {
    return cbrt(abs(c)) * cis(arg(c) / 3)
}

@warn_unused_result
public func +(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real + rhs, imag: lhs.imag)
}
@warn_unused_result
public func -(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real - rhs, imag: lhs.imag)
}
@warn_unused_result
public func +(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs + rhs.real, imag: rhs.imag)
}
@warn_unused_result
public func -(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs - rhs.real, imag: -rhs.imag)
}
@warn_unused_result
public func +(lhs: Complex, rhs:  Complex) -> Complex {
    return Complex(real: lhs.real + rhs.real, imag: lhs.imag + rhs.imag)
}
@warn_unused_result
public func -(lhs: Complex, rhs:  Complex) -> Complex {
    return Complex(real: lhs.real - rhs.real, imag: lhs.imag - rhs.imag)
}
@warn_unused_result
public func *(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real * rhs, imag: lhs.imag * rhs)
}
@warn_unused_result
public func *(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs * rhs.real, imag: lhs * rhs.imag)
}
@warn_unused_result
public func *(lhs: Complex, rhs:  Complex) -> Complex {
    let _real = lhs.real * rhs.real - lhs.imag * rhs.imag
    let _imag = lhs.real * rhs.imag + lhs.imag * rhs.real
    return Complex(real: _real, imag: _imag)
}
@warn_unused_result
public func /(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real / rhs, imag: lhs.imag / rhs)
}
@warn_unused_result
public func /(lhs: Double, rhs:  Complex) -> Complex {
    let _norm = norm(rhs)
    let _real = lhs * rhs.real / _norm
    let _imag = -rhs.imag * lhs / _norm
    return Complex(real: _real, imag: _imag)
}
@warn_unused_result
public func /(lhs: Complex, rhs:  Complex) -> Complex {
    let _norm = norm(rhs)
    let _real = lhs.real * rhs.real + lhs.imag * rhs.imag
    let _imag = lhs.imag * rhs.real - lhs.real * rhs.imag
    return Complex(real: _real / _norm, imag: _imag / _norm)
}
@warn_unused_result
public prefix func + (value: Complex) -> Complex {
    return value
}
@warn_unused_result
public prefix func -(value:  Complex) -> Complex {
    return Complex(real: -value.real, imag: -value.imag)
}
public func +=(inout lhs: Complex, rhs:  Double) {
    lhs.real += rhs
}
public func -=(inout lhs: Complex, rhs:  Double) {
    lhs.real -= rhs
}
public func *=(inout lhs: Complex, rhs:  Double) {
    lhs.real *= rhs
    lhs.imag *= rhs
}
public func /=(inout lhs: Complex, rhs:  Double) {
    lhs.real /= rhs
    lhs.imag /= rhs
}
public func +=(inout lhs: Complex, rhs:  Complex) {
    lhs.real += rhs.real
    lhs.imag += rhs.imag
}
public func -=(inout lhs: Complex, rhs:  Complex) {
    lhs.real -= rhs.real
    lhs.imag -= rhs.imag
}
public func *=(inout lhs: Complex, rhs:  Complex) {
    let _real = lhs.real * rhs.real - lhs.imag * rhs.imag
    let _imag = lhs.real * rhs.imag + lhs.imag * rhs.real
    lhs.real = _real
    lhs.imag = _imag
}
public func /=(inout lhs: Complex, rhs:  Complex) {
    let _norm = norm(rhs)
    let _real = lhs.real * rhs.real + lhs.imag * rhs.imag
    let _imag = lhs.imag * rhs.real - lhs.real * rhs.imag
    lhs.real = _real / _norm
    lhs.imag = _imag / _norm
}
@warn_unused_result
public func ==(lhs: Double, rhs: Complex) -> Bool {
    return lhs == rhs.real && rhs.imag == 0.0
}
@warn_unused_result
public func !=(lhs: Double, rhs: Complex) -> Bool {
    return lhs != rhs.real || rhs.imag != 0.0
}
@warn_unused_result
public func ==(lhs: Complex, rhs: Double) -> Bool {
    return lhs.real == rhs && lhs.imag == 0.0
}
@warn_unused_result
public func !=(lhs: Complex, rhs: Double) -> Bool {
    return lhs.real != rhs || lhs.imag != 0.0
}
@warn_unused_result
public func ==(lhs: Complex, rhs: Complex) -> Bool {
    return lhs.real == rhs.real && lhs.imag == rhs.imag
}
@warn_unused_result
public func !=(lhs: Complex, rhs: Complex) -> Bool {
    return lhs.real != rhs.real || lhs.imag != rhs.imag
}

