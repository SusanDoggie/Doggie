//
//  Maths.swift
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

public let M_SQRT3 = 1.7320508075688772935274463415058723669428052538103806
public let M_SQRT5 = 2.2360679774997896964091736687312762354406183596115257

extension Double {
    
    public func almostZero(epsilon: Double = 1e-9, reference: Double = 0) -> Bool {
        return abs(self) < abs(epsilon) * max(1, abs(reference))
    }
    
    public func almostEqual(other: Double, epsilon: Double = 1e-9) -> Bool {
        return abs(self - other).almostZero(epsilon, reference: self)
    }
}

@warn_unused_result
public func FactorialList<T: UnsignedIntegerType>(n: T) -> LazyScanSequence<Slice<Range<T>>, T> {
    
    return (0...n).dropFirst().lazy.scan(1) { $0 * $1 }
}
@warn_unused_result
public func PermutationList<T: UnsignedIntegerType>(n: T) -> LazyScanSequence<ReverseRandomAccessCollection<Slice<Range<T>>>, T> {
    
    return (0...n).dropFirst().lazy.reverse().scan(1) { $0 * $1 }
}
@warn_unused_result
public func CombinationList<T: UnsignedIntegerType>(n: T) -> LazyMapSequence<Zip2Sequence<LazyScanSequence<ReverseRandomAccessCollection<Slice<Range<T>>>, T>, LazyScanSequence<Slice<Range<T>>, T>>, T> {
    
    return zip(PermutationList(n), FactorialList(n)).lazy.map(/)
}

@warn_unused_result
public func FibonacciList<T: UnsignedIntegerType>(n: T) -> LazyMapSequence<LazyScanSequence<Slice<Range<T>>, (Int, Int)>, Int> {
    
    return (0..<n).dropLast().lazy.scan((1, 1)) { ($0.0.1, $0.0.0 + $0.0.1) }.map { $0.0 }
}

// MARK: Prime

@warn_unused_result
public func isPrime(n: UInt8) -> Bool {
    return isPrime(UInt32(n))
}
@warn_unused_result
public func isPrime(n: UInt16) -> Bool {
    return isPrime(UInt32(n))
}
@warn_unused_result
public func isPrime(n: UInt32) -> Bool {
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
@warn_unused_result
public func isPrime(n: UInt64) -> Bool {
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
@warn_unused_result
public func isPrime(n: UInt) -> Bool {
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

@warn_unused_result
public func degree2roots(b: Double, _ c: Double) -> [Double] {
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

@warn_unused_result
public func degree3decompose(b: Double, _ c: Double, _ d: Double) -> (Double, (Double, Double)) {
    if d.almostZero() {
        return (0, (b, c))
    }
    let b2 = b * b
    let b3 = b * b2
    let de0 = b2 - 3 * c
    let de1 = 2 * b3 - 9 * c * b + 27 * d
    let de2 = de1 * de1 - 4 * de0 * de0 * de0
    
    if de2.isSignMinus { // delta > 0, three real roots
        let m = b / 3
        let p = -de0 / 3
        let q = de1 / 27
        let p_3 = p / 3
        let s = 2 * sqrt(-p_3)
        let t = acos(q / (p_3 * s)) / 3
        let u = M_PI * 2 / 3
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

@warn_unused_result
public func degree4decompose(b: Double, _ c: Double, _ d: Double, _ e: Double) -> ((Double, Double), (Double, Double)) {
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
    if de2.isSignMinus {
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
        if _S.isSignMinus {
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

@warn_unused_result
public func degree5decompose(b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double, eps: Double = 1e-14) -> (Double, (Double, Double), (Double, Double)) {
    
    var eps = eps
    var iter = 0
    
    var r = b.almostZero(reference: c) ? c : c / b
    var s = b.almostZero(reference: d) ? d : d / b
    while true {
        
        let b1 = b - r
        let b2 = c - r * b1 - s
        let b3 = d - r * b2 - s * b1
        let b4 = e - r * b3 - s * b2
        let b5 = f - r * b4 - s * b3
        
        let c1 = b1 - r
        let c2 = b2 - r * c1 - s
        let c3 = b3 - r * c2 - s * c1
        let c4 = b4 - r * c3 - s * c2
        
        let d = c4 * c2 - c3 * c3
        let dr = (b5 * c2 - b4 * c3) / d
        let ds = (b4 * c4 - b5 * c3) / d
        
        r += dr
        s += ds
        
        if dr.almostZero(eps, reference: r) && ds.almostZero(eps, reference: s) {
            break
        }
        
        iter += 1
        if iter % 5000 == 0 {
            eps *= 2
        }
    }
    let b1 = b - r
    let b2 = c - r * b1 - s
    let b3 = d - r * b2 - s * b1
    let degree3result = degree3decompose(b1, b2, b3)
    return (degree3result.0, (r, s), degree3result.1)
}

@warn_unused_result
public func degree6decompose(b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double, _ g: Double, eps: Double = 1e-14) -> ((Double, Double), (Double, Double), (Double, Double)) {
    
    var eps = eps
    var iter = 0
    
    var r = b.almostZero(reference: c) ? c : c / b
    var s = b.almostZero(reference: d) ? d : d / b
    while true {
        
        let b1 = b - r
        let b2 = c - r * b1 - s
        let b3 = d - r * b2 - s * b1
        let b4 = e - r * b3 - s * b2
        let b5 = f - r * b4 - s * b3
        let b6 = g - r * b5 - s * b4
        
        let c1 = b1 - r
        let c2 = b2 - r * c1 - s
        let c3 = b3 - r * c2 - s * c1
        let c4 = b4 - r * c3 - s * c2
        let c5 = b5 - r * c4 - s * c3
        
        let d = c5 * c3 - c4 * c4
        let dr = (b6 * c3 - b5 * c4) / d
        let ds = (b5 * c5 - b6 * c4) / d
        
        r += dr
        s += ds
        
        if dr.almostZero(eps, reference: r) && ds.almostZero(eps, reference: s) {
            break
        }
        
        iter += 1
        if iter % 5000 == 0 {
            eps *= 2
        }
    }
    let b1 = b - r
    let b2 = c - r * b1 - s
    let b3 = d - r * b2 - s * b1
    let b4 = e - r * b3 - s * b2
    let degree4result = degree4decompose(b1, b2, b3, b4)
    return ((r, s), degree4result.0, degree4result.1)
}

@warn_unused_result
public func degree3roots(b: Double, _ c: Double, _ d: Double) -> [Double] {
    if d.almostZero() {
        let z = degree2roots(b, c)
        return z.contains(0) ? z : [0] + z
    }
    let b2 = b * b
    let b3 = b * b2
    let de0 = b2 - 3 * c
    let de1 = 2 * b3 - 9 * c * b + 27 * d
    let de2 = de1 * de1 - 4 * de0 * de0 * de0
    
    if de2.isSignMinus { // delta > 0, three real roots
        let m = b / 3
        let p = -de0 / 3
        let q = de1 / 27
        let p_3 = p / 3
        let s = 2 * sqrt(-p_3)
        let t = acos(q / (p_3 * s)) / 3
        let u = M_PI * 2 / 3
        return [s * cos(t) - m, s * cos(t - u) - m, s * cos(t - 2 * u) - m]
    }
    
    let c1 = cbrt(0.5 * (de1 + sqrt(de2)))
    let c2 = cbrt(0.5 * (de1 - sqrt(de2)))
    let c3 = c1 + c2
    var _d2 = degree2roots((2 * b - c3) / 3, (b2 - b * c3 + c3 * c3 - 3 * c1 * c2) / 9)
    _d2.append((-b - c3) / 3)
    return Array(Set(_d2))
}

@warn_unused_result
public func degree4roots(b: Double, _ c: Double, _ d: Double, _ e: Double) -> [Double] {
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

@warn_unused_result
public func linearScale(f: UInt, _ x: UInt) -> Double {
    return log(Double(x + 1)) / log(Double(f))
}
@warn_unused_result
public func logScale(f: UInt, _ x: Double) -> UInt {
    return UInt(lround(pow(Double(f), x))) - 1
}

@warn_unused_result
public func degreesToRad(alpha: Float) -> Float {
    return alpha * Float(M_PI) / 180.0
}
@warn_unused_result
public func degreesToRad(alpha: Double) -> Double {
    return alpha * M_PI / 180.0
}

@warn_unused_result
public func LogarithmicDynamicRangeCompression(x: Double, _ m: Double) -> Double {
    let alpha = 2.5128624172523393539654752332184326538328336634026474
    let alpha_2 = 0.7959050946318330895721191440438390881317432367303995
    let re = log(1.0 + alpha * abs(x) / m) * alpha_2
    return x.isSignMinus ? -re : re
}

@warn_unused_result
public func LinearInterpolate(t: Double, _ a: Double, _ b: Double) -> Double {
    return a + t * (b - a)
}

@warn_unused_result
public func CosineInterpolate(t: Double, _ a: Double, _ b: Double) -> Double {
    return LinearInterpolate((1.0 - cos(t * M_PI)) * 0.5, a, b)
}

@warn_unused_result
public func CubicInterpolate(t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    let t2 = t * t
    let m0 = d - c - a + b
    let m1 = a - b - m0
    let m2 = c - a
    let m3 = b
    return m0 * t * t2 + m1 * t2 + m2 * t + m3
}

@warn_unused_result
public func HermiteInterpolate(t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double, _ s: Double, _ e: Double) -> Double {
    let t2 = t * t
    let t3 = t2 * t
    let m0 = ((b - a) * (1.0 + e) + (c - b) * (1.0 - e)) * (1.0 - s) * 0.5
    let m1 = ((c - b) * (1.0 + e) + (d - c) * (1.0 - e)) * (1.0 - s) * 0.5
    let a0 = 2.0 * t3 - 3.0 * t2 + 1.0
    let a1 = t3 - 2.0 * t2 + t
    let a2 = t3 - t2
    let a3 = -2.0 * t3 + 3.0 * t2
    return a0 * b + a1 * m0 + a2 * m1 + a3 * c
}

@warn_unused_result
public func Phase(x: Double, _ shift: Double, _ frequency: Double, _ maxFrequency: Double) -> Double {
    return abs((x / maxFrequency + shift) * frequency) % 1.0
}
@warn_unused_result
public func SineWave(phase: Double) -> Double {
    return sin(2 * M_PI * phase)
}
@warn_unused_result
public func SquareWave(phase: Double) -> Double {
    return phase < 0.5 ? 1 : -1
}
@warn_unused_result
public func SawtoothWave(phase: Double) -> Double {
    return phase * 2 - 1.0
}
@warn_unused_result
public func TriangleWave(phase: Double) -> Double {
    return phase < 0.5 ? phase * 4 - 1.0 : 3.0 - phase * 4
}

