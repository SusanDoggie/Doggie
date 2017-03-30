//
//  Complex.swift
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

public struct Complex {
    
    public var real: Double
    public var imag: Double
    
    @_inlineable
    public init(_ real: Double) {
        self.real = real
        self.imag = 0.0
    }
    @_inlineable
    public init(real: Double, imag: Double) {
        self.real = real
        self.imag = imag
    }
    @_inlineable
    public init(_ real: Int) {
        self.real = Double(real)
        self.imag = 0.0
    }
    @_inlineable
    public init(real: Int, imag: Int) {
        self.real = Double(real)
        self.imag = Double(imag)
    }
}

extension Complex {
    
    @_inlineable
    public init(magnitude: Double, phase: Double) {
        self.real = magnitude * cos(phase)
        self.imag = magnitude * sin(phase)
    }
    
    @_inlineable
    public var magnitude: Double {
        get {
            return sqrt(real * real + imag * imag)
        }
        set {
            self = Complex(magnitude: newValue, phase: phase)
        }
    }
    
    @_inlineable
    public var phase: Double {
        get {
            return atan2(imag, real)
        }
        set {
            self = Complex(magnitude: magnitude, phase: newValue)
        }
    }
}

extension Complex: CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        
        var print = ""
        
        switch real {
        case 0: break
        case 1: "1.0".write(to: &print)
        case -1: "-1.0".write(to: &print)
        default: String(format: "%.2f", real).write(to: &print)
        }
        
        if imag != 0 {
            if !print.isEmpty && imag.sign == .plus {
                "+".write(to: &print)
            }
            switch imag {
            case 1: "𝒊".write(to: &print)
            case -1: "-𝒊".write(to: &print)
            default: String(format: "%.2f𝒊", imag).write(to: &print)
            }
        }
        
        if print.isEmpty {
            print = "0.0"
        }
        return print
    }
}

extension Complex: Hashable {
    
    @_inlineable
    public var hashValue: Int {
        return hash_combine(seed: 0, real, imag)
    }
}

@_inlineable
public func norm(_ value: Complex) -> Double {
    return value.real * value.real + value.imag * value.imag
}
@_inlineable
public func sgn(_ value: Complex) -> Complex {
    return value / value.magnitude
}
@_inlineable
public func conj(_ value: Complex) -> Complex {
    return Complex(real: value.real, imag: -value.imag)
}

@_inlineable
public func exp(_ value: Complex) -> Complex {
    return exp(value.real) * cis(value.imag)
}
@_inlineable
public func cis(_ theta: Double) -> Complex {
    return Complex(real: cos(theta), imag: sin(theta))
}

@_inlineable
public func cocis(_ theta: Double) -> Complex {
    return Complex(real: sin(theta), imag: cos(theta))
}

@_inlineable
public func sin(_ x: Complex) -> Complex {
    return Complex(real: sin(x.real) * cosh(x.imag), imag: cos(x.real) * sinh(x.imag))
}
@_inlineable
public func cos(_ x: Complex) -> Complex {
    return Complex(real: cos(x.real) * cosh(x.imag), imag: -sin(x.real) * sinh(x.imag))
}

@_inlineable
public func tan(_ x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) + cosh(_imag)
    return Complex(real: sin(_real) / d, imag: sinh(_imag) / d)
}

@_inlineable
public func cot(_ x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) - cosh(_imag)
    return Complex(real: -sin(_real) / d, imag: sinh(_imag) / d)
}

@_inlineable
public func sec(_ x: Complex) -> Complex {
    let d = cos(x.real * 2) + cosh(x.imag * 2)
    return Complex(real: 2 * cos(x.real) * cosh(x.imag) / d, imag: 2 * sin(x.real) * sinh(x.imag) / d)
}

@_inlineable
public func csc(_ x: Complex) -> Complex {
    let d = cos(x.real * 2) - cosh(x.imag * 2)
    return Complex(real: -2 * sin(x.real) * cosh(x.imag) / d, imag: 2 * cos(x.real) * sinh(x.imag) / d)
}

@_inlineable
public func sinh(_ x: Complex) -> Complex {
    return Complex(real: sinh(x.real) * cos(x.imag), imag: cosh(x.real) * sin(x.imag))
}

@_inlineable
public func cosh(_ x: Complex) -> Complex {
    return Complex(real: cosh(x.real) * cos(x.imag), imag: sinh(x.real) * sin(x.imag))
}

@_inlineable
public func tanh(_ x: Complex) -> Complex {
    let _real = x.real * 2
    let _imag = x.imag * 2
    let d = cos(_real) + cosh(_imag)
    return Complex(real: sinh(_real) / d, imag: sin(_imag) / d)
}

@_inlineable
public func asin(_ x: Complex) -> Complex {
    let z = asinh(Complex(real: x.imag, imag: -x.real))
    return Complex(real: -z.imag, imag: z.real)
}

@_inlineable
public func acos(_ x: Complex) -> Complex {
    return 0.5 * Double.pi - asin(x)
}

@_inlineable
public func atan(_ x: Complex) -> Complex {
    let z = atanh(Complex(real: -x.imag, imag: x.real))
    return Complex(real: z.imag, imag: -z.real)
}

@_inlineable
public func asec(_ x: Complex) -> Complex {
    return 0.5 * Double.pi - acsc(x)
}

@_inlineable
public func acsc(_ x: Complex) -> Complex {
    return asin(1 / x)
}

@_inlineable
public func acot(_ x: Complex) -> Complex {
    return atan(1 / x)
}

@_inlineable
public func asinh(_ x: Complex) -> Complex {
    return log(x + sqrt(x * x + 1))
}

@_inlineable
public func acosh(_ x: Complex) -> Complex {
    return log(x + sqrt(x * x - 1))
}

@_inlineable
public func atanh(_ x: Complex) -> Complex {
    return (log(1 + x) - log(1 - x)) * 0.5
}

@_inlineable
public func log(_ c: Complex) -> Complex {
    return Complex(real: log(c.magnitude), imag: c.phase)
}

@_inlineable
public func log10(_ c: Complex) -> Complex {
    return log(c) / M_LN10
}

@_inlineable
public func pow(_ a: Complex, _ b: Complex) -> Complex {
    let _norm = norm(a)
    let _arg = a.phase
    return pow(_norm, 0.5 * b.real) * exp(-b.imag * _arg) * cis(b.real * _arg + 0.5 * b.imag * log(_norm))
}

@_inlineable
public func pow(_ c: Complex, _ n: Double) -> Complex {
    return pow(norm(c), 0.5 * n) * cis(c.phase * n)
}

@_inlineable
public func sqrt(_ c: Complex) -> Complex {
    return sqrt(c.magnitude) * cis(0.5 * c.phase)
}

@_inlineable
public func cbrt(_ c: Complex) -> Complex {
    return cbrt(c.magnitude) * cis(c.phase / 3)
}

@_inlineable
public func +(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real + rhs, imag: lhs.imag)
}
@_inlineable
public func -(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real - rhs, imag: lhs.imag)
}
@_inlineable
public func +(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs + rhs.real, imag: rhs.imag)
}
@_inlineable
public func -(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs - rhs.real, imag: -rhs.imag)
}
@_inlineable
public func +(lhs: Complex, rhs:  Complex) -> Complex {
    return Complex(real: lhs.real + rhs.real, imag: lhs.imag + rhs.imag)
}
@_inlineable
public func -(lhs: Complex, rhs:  Complex) -> Complex {
    return Complex(real: lhs.real - rhs.real, imag: lhs.imag - rhs.imag)
}
@_inlineable
public func *(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real * rhs, imag: lhs.imag * rhs)
}
@_inlineable
public func *(lhs: Double, rhs:  Complex) -> Complex {
    return Complex(real: lhs * rhs.real, imag: lhs * rhs.imag)
}
@_inlineable
public func *(lhs: Complex, rhs:  Complex) -> Complex {
    let _real = lhs.real * rhs.real - lhs.imag * rhs.imag
    let _imag = lhs.real * rhs.imag + lhs.imag * rhs.real
    return Complex(real: _real, imag: _imag)
}
@_inlineable
public func /(lhs: Complex, rhs:  Double) -> Complex {
    return Complex(real: lhs.real / rhs, imag: lhs.imag / rhs)
}
@_inlineable
public func /(lhs: Double, rhs:  Complex) -> Complex {
    let _norm = norm(rhs)
    let _real = lhs * rhs.real / _norm
    let _imag = -rhs.imag * lhs / _norm
    return Complex(real: _real, imag: _imag)
}
@_inlineable
public func /(lhs: Complex, rhs:  Complex) -> Complex {
    let _norm = norm(rhs)
    let _real = lhs.real * rhs.real + lhs.imag * rhs.imag
    let _imag = lhs.imag * rhs.real - lhs.real * rhs.imag
    return Complex(real: _real / _norm, imag: _imag / _norm)
}
@_inlineable
public prefix func + (value: Complex) -> Complex {
    return value
}
@_inlineable
public prefix func -(value:  Complex) -> Complex {
    return Complex(real: -value.real, imag: -value.imag)
}
@_inlineable
public func +=(lhs: inout Complex, rhs:  Double) {
    lhs.real += rhs
}
@_inlineable
public func -=(lhs: inout Complex, rhs:  Double) {
    lhs.real -= rhs
}
@_inlineable
public func *=(lhs: inout Complex, rhs:  Double) {
    lhs.real *= rhs
    lhs.imag *= rhs
}
@_inlineable
public func /=(lhs: inout Complex, rhs:  Double) {
    lhs.real /= rhs
    lhs.imag /= rhs
}
@_inlineable
public func +=(lhs: inout Complex, rhs:  Complex) {
    lhs.real += rhs.real
    lhs.imag += rhs.imag
}
@_inlineable
public func -=(lhs: inout Complex, rhs:  Complex) {
    lhs.real -= rhs.real
    lhs.imag -= rhs.imag
}
@_inlineable
public func *=(lhs: inout Complex, rhs:  Complex) {
    let _real = lhs.real * rhs.real - lhs.imag * rhs.imag
    let _imag = lhs.real * rhs.imag + lhs.imag * rhs.real
    lhs.real = _real
    lhs.imag = _imag
}
@_inlineable
public func /=(lhs: inout Complex, rhs:  Complex) {
    let _norm = norm(rhs)
    let _real = lhs.real * rhs.real + lhs.imag * rhs.imag
    let _imag = lhs.imag * rhs.real - lhs.real * rhs.imag
    lhs.real = _real / _norm
    lhs.imag = _imag / _norm
}
@_inlineable
public func ==(lhs: Double, rhs: Complex) -> Bool {
    return lhs == rhs.real && rhs.imag == 0.0
}
@_inlineable
public func !=(lhs: Double, rhs: Complex) -> Bool {
    return lhs != rhs.real || rhs.imag != 0.0
}
@_inlineable
public func ==(lhs: Complex, rhs: Double) -> Bool {
    return lhs.real == rhs && lhs.imag == 0.0
}
@_inlineable
public func !=(lhs: Complex, rhs: Double) -> Bool {
    return lhs.real != rhs || lhs.imag != 0.0
}
@_inlineable
public func ==(lhs: Complex, rhs: Complex) -> Bool {
    return lhs.real == rhs.real && lhs.imag == rhs.imag
}
@_inlineable
public func !=(lhs: Complex, rhs: Complex) -> Bool {
    return lhs.real != rhs.real || lhs.imag != rhs.imag
}

