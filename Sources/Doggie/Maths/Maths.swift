//
//  Maths.swift
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

import Foundation

@_inlineable
public func FactorialList<T: UnsignedInteger>(_ n: T) -> LazyScanSequence<Slice<CountableClosedRange<T>>, T> {
    
    return (0...n).dropFirst().lazy.scan(1, *)
}
@_inlineable
public func PermutationList<T: UnsignedInteger>(_ n: T) -> LazyScanSequence<ReversedCollection<Slice<CountableClosedRange<T>>>, T> {
    
    return (0...n).dropFirst().reversed().lazy.scan(1, *)
}
@_inlineable
public func CombinationList<T: UnsignedInteger>(_ n: T) -> LazyMapSequence<Zip2Sequence<LazyScanSequence<ReversedCollection<Slice<CountableClosedRange<T>>>, T>, LazyScanSequence<Slice<CountableClosedRange<T>>, T>>, T> {
    
    return zip(PermutationList(n), FactorialList(n)).lazy.map(/)
}

@_inlineable
public func FibonacciList<T: UnsignedInteger>(_ n: T) -> LazyMapSequence<LazyScanSequence<CountableRange<T>, (T, T)>, T> {
    
    return (0..<n).dropLast().lazy.scan((1, 1)) { x, _ in (x.1, x.0 + x.1) }.map { $0.0 }
}

// MARK: Prime

@_inlineable
public func isPrime(_ n: UInt8) -> Bool {
    return isPrime(UInt32(n))
}
@_inlineable
public func isPrime(_ n: UInt16) -> Bool {
    return isPrime(UInt32(n))
}
@_inlineable
public func isPrime(_ n: UInt32) -> Bool {
    let list: [UInt32] = n < 2047 ? [2] : n < 1373653 ? [2, 3] : [2, 7, 61]
    let _n = n - 1
    let s = log2(_n.lowbit)
    let d = _n >> s
    for a in list where a < n && pow(a, d, n) != 1 {
        var flag = true
        for r in 0..<s where pow(a, d << r, n) == _n {
            flag = false
        }
        if flag {
            return false
        }
    }
    return true
}
@_inlineable
public func isPrime(_ n: UInt64) -> Bool {
    let list: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    let _n = n - 1
    let s = log2(_n.lowbit)
    let d = _n >> s
    for a in list where a < n && pow(a, d, n) != 1 {
        var flag = true
        for r in 0..<s where pow(a, d << r, n) == _n {
            flag = false
        }
        if flag {
            return false
        }
    }
    return true
}
@_inlineable
public func isPrime(_ n: UInt) -> Bool {
    let list: [UInt] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    let _n = n - 1
    let s = log2(_n.lowbit)
    let d = _n >> s
    for a in list where a < n && pow(a, d, n) != 1 {
        var flag = true
        for r in 0..<s where pow(a, d << r, n) == _n {
            flag = false
        }
        if flag {
            return false
        }
    }
    return true
}

// MARK: Polynomial

@_inlineable
public func degree2roots(_ b: Double, _ c: Double) -> [Double] {
    if b.almostZero() {
        if c < 0 {
            let _c = sqrt(-c)
            return [_c, -_c]
        } else if c.almostZero() {
            return [0]
        }
    }
    if c.almostZero() {
        return [0, -b]
    }
    let del = b * b - 4 * c
    if del.almostZero() {
        return [-0.5 * b]
    } else if del > 0 {
        let sqrt_del = sqrt(del)
        return [0.5 * (sqrt_del - b), 0.5 * (-sqrt_del - b)]
    }
    return []
}

@_inlineable
public func degree3decompose(_ b: Double, _ c: Double, _ d: Double) -> (Double, (Double, Double)) {
    if d.almostZero() {
        return (0, (b, c))
    }
    let b2 = b * b
    let b3 = b * b2
    let de0 = b2 - 3 * c
    let de1 = 2 * b3 - 9 * c * b + 27 * d
    let de2 = de1 * de1 - 4 * de0 * de0 * de0
    
    if de2.sign == .minus { // delta > 0, three real roots
        let m = b / 3
        let p = -de0 / 3
        let q = de1 / 27
        let p_3 = p / 3
        let s = 2 * sqrt(-p_3)
        let t = acos(q / (p_3 * s)) / 3
        let u = Double.pi * 2 / 3
        let cos1 = cos(t)
        let cos2 = cos(t - u)
        let cos3 = cos(t - 2 * u)
        let s_cos1 = s * cos1
        let s_cos2 = s * cos2
        let s_cos3 = s * cos3
        let k = m - s_cos1 - s_cos3
        return (s_cos2 - m, (m + k, s_cos1 * s_cos3 + m * k))
    }
    
    let c1 = cbrt(0.5 * (de1 + sqrt(de2)))
    let c2 = cbrt(0.5 * (de1 - sqrt(de2)))
    let c3 = c1 + c2
    return ((-b - c3) / 3, ((2 * b - c3) / 3, (b2 - b * c3 + c3 * c3 - 3 * c1 * c2) / 9))
}

@_inlineable
public func degree4decompose(_ b: Double, _ c: Double, _ d: Double, _ e: Double) -> ((Double, Double), (Double, Double)) {
    if e.almostZero() {
        let z = degree3decompose(b, c, d)
        return ((z.0, 0), z.1)
    }
    let b2 = b * b
    let c2 = c * c
    let d2 = d * d
    let bd = b * d
    let bc = b * c
    let de0 = c2 - 3 * bd + 12 * e
    let de1 = 2 * c * c2 - 9 * bd * c + 27 * (b2 * e + d2) - 72 * e * c
    let _4_de0_3 = 4 * de0 * de0 * de0
    let de2 = de1 * de1 - _4_de0_3
    let P = 8 * c - 3 * b2
    let Q = b * b2 - 4 * bc + 8 * d
    let p = 0.125 * P
    let q = 0.125 * Q
    let m = 0.25 * b
    let S: Double
    if de2.sign == .minus {
        let phi = acos(de1 / sqrt(_4_de0_3))
        let _S = -p + sqrt(de0) * cos(phi / 3)
        S = 0.5 * sqrt(_S * 2 / 3)
    } else {
        let _S = de0.almostZero() && !de2.almostZero() ? cbrt(de1) : cbrt(0.5 * (de1 + sqrt(de2)))
        if _S.almostZero() {
            let _b = 2 * m
            let _c = m * m
            return ((_b, _c), (_b, _c))
        }
        if _S.sign == .minus {
            let S = 0.25 * (_S + de0 / _S - 2 * p) / 3
            return ((2 * m, m * m - S), (2 * m, m * m - S))
        }
        S = 0.5 * sqrt((_S + de0 / _S - 2 * p) / 3)
    }
    let _t = -4 * S * S - 2 * p
    let t1 = _t + q / S
    let t2 = _t - q / S
    let k1 = m + S
    let k2 = m - S
    return ((2 * k1, k1 * k1 - 0.25 * t1), (2 * k2, k2 * k2 - 0.25 * t2))
}

@_inlineable
public func degree3roots(_ b: Double, _ c: Double, _ d: Double) -> [Double] {
    if d.almostZero() {
        let z = degree2roots(b, c)
        return z.contains(0) ? z : [0] + z
    }
    let b2 = b * b
    let b3 = b * b2
    let de0 = b2 - 3 * c
    let de1 = 2 * b3 - 9 * c * b + 27 * d
    let de2 = de1 * de1 - 4 * de0 * de0 * de0
    
    if de2.sign == .minus { // delta > 0, three real roots
        let m = b / 3
        let p = -de0 / 3
        let q = de1 / 27
        let p_3 = p / 3
        let s = 2 * sqrt(-p_3)
        let t = acos(q / (p_3 * s)) / 3
        let u = Double.pi * 2 / 3
        return [s * cos(t) - m, s * cos(t - u) - m, s * cos(t - 2 * u) - m]
    }
    
    let c1 = cbrt(0.5 * (de1 + sqrt(de2)))
    let c2 = cbrt(0.5 * (de1 - sqrt(de2)))
    let c3 = c1 + c2
    var _d2 = degree2roots((2 * b - c3) / 3, (b2 - b * c3 + c3 * c3 - 3 * c1 * c2) / 9)
    _d2.append((-b - c3) / 3)
    return Array(Set(_d2))
}

@_inlineable
public func degree4roots(_ b: Double, _ c: Double, _ d: Double, _ e: Double) -> [Double] {
    if e.almostZero() {
        let z = degree3roots(b, c, d)
        return z.contains(0) ? z : [0] + z
    }
    if b.almostZero() && d.almostZero() { // biquadratic
        var result = [Double]()
        for z in degree2roots(c, e) {
            if z > 0 {
                result.append(sqrt(z))
                result.append(-sqrt(z))
            } else if z.almostZero() {
                result.append(0)
            }
        }
        return result
    }
    
    let _d2 = degree4decompose(b, c, d, e)
    return Array(Set(degree2roots(_d2.0.0, _d2.0.1).concat(degree2roots(_d2.1.0, _d2.1.1))))
}

// MARK: Others

@_inlineable
public func linearScale(_ f: UInt, _ x: UInt) -> Double {
    return log(Double(x + 1)) / log(Double(f))
}
@_inlineable
public func logScale(_ f: UInt, _ x: Double) -> UInt {
    return UInt(lround(pow(Double(f), x))) - 1
}

@_inlineable
public func degreesToRad(_ alpha: Float) -> Float {
    return alpha * Float.pi / 180
}
@_inlineable
public func degreesToRad(_ alpha: Double) -> Double {
    return alpha * Double.pi / 180
}

@_inlineable
public func LogarithmicDynamicRangeCompression(_ x: Double, _ m: Double) -> Double {
    let alpha = 2.5128624172523393539654752332184326538328336634026474
    let alpha_2 = 0.7959050946318330895721191440438390881317432367303995
    let re = log(1.0 + alpha * abs(x) / m) * alpha_2
    return x.sign == .minus ? -re : re
}

@_inlineable
public func LinearInterpolate<T: ScalarMultiplicative>(_ t: T.Scalar, _ a: T, _ b: T) -> T {
    return a + t * (b - a)
}

@_inlineable
public func CosineInterpolate<T: ScalarMultiplicative>(_ t: T.Scalar, _ a: T, _ b: T) -> T where T.Scalar : FloatingMathProtocol {
    let u = 1 - T.Scalar.cos(t * T.Scalar.pi)
    let v = 0.5 * u
    return LinearInterpolate(v, a, b)
}

@_inlineable
public func CubicInterpolate<T: ScalarMultiplicative>(_ t: T.Scalar, _ a: T, _ b: T, _ c: T, _ d: T) -> T {
    let t2 = t * t
    let m0 = d - c - a + b
    let m1 = a - b - m0
    let m2 = c - a
    let m3 = b
    let n0 = m0 * t * t2
    let n1 = m1 * t2
    let n2 = m2 * t
    return n0 + n1 + n2 + m3
}

@_inlineable
public func HermiteInterpolate<T: ScalarMultiplicative>(_ t: T.Scalar, _ a: T, _ b: T, _ c: T, _ d: T, _ s: T.Scalar, _ e: T.Scalar) -> T {
    let t2 = t * t
    let t3 = t2 * t
    let _2t3 = 2 * t3
    let _3t2 = 3 * t2
    let s0 = 0.5 * (1 - s)
    let e0 = 1 + e
    let e1 = 1 - e
    let e2 = s0 * e0
    let e3 = s0 * e1
    let u0 = (b - a) * e2
    let u1 = (c - b) * e3
    let v0 = (c - b) * e2
    let v1 = (d - c) * e3
    let m0 = u0 + u1
    let m1 = v0 + v1
    let a0 = _2t3 - _3t2 + 1
    let a1 = t3 - 2 * t2 + t
    let a2 = t3 - t2
    let a3 = -_2t3 + _3t2
    let b0 = a0 * b
    let b1 = a1 * m0
    let b2 = a2 * m1
    let b3 = a3 * c
    return b0 + b1 + b2 + b3
}

@_inlineable
public func Phase(_ x: Double, _ shift: Double, _ frequency: Double, _ maxFrequency: Double) -> Double {
    return abs((x / maxFrequency + shift) * frequency).truncatingRemainder(dividingBy: 1)
}
@_inlineable
public func SineWave(_ phase: Double) -> Double {
    return sin(2 * Double.pi * phase)
}
@_inlineable
public func SquareWave(_ phase: Double) -> Double {
    return phase < 0.5 ? 1 : -1
}
@_inlineable
public func SawtoothWave(_ phase: Double) -> Double {
    return phase * 2 - 1
}
@_inlineable
public func TriangleWave(_ phase: Double) -> Double {
    return phase < 0.5 ? phase * 4 - 1 : 3 - phase * 4
}

