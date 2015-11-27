//
//  Maths.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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
    
    public var almostZero : Bool {
        return abs(self) < 1e-9
    }
}

public func gcd<U: UnsignedIntegerType>(var a: U, var _ b: U) -> U {
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}
public func gcd<S: SignedIntegerType>(var a: S, var _ b: S) -> S {
    let sign = a >= 0 || b >= 0
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return sign ? abs(a) : -abs(a)
}

public func exgcd<U: UnsignedIntegerType>(var a: U, var _ b: U) -> (gcd: U, x: U, y: U) {
    var x: (U, U) = (1, 0)
    var y: (U, U) = (0, 1)
    while b != 0 {
        let q = a / b
        x = (x.1, x.0 + q * x.1)
        y = (y.1, y.0 + q * y.1)
        (a, b) = (b, a % b)
    }
    return (a, x.0, y.0)
}
public func exgcd<U: UnsignedIntegerType, S: SignedIntegerType>(var a: U, var _ b: U) -> (gcd: U, x: S, y: S) {
    var x: (S, S) = (1, 0)
    var y: (S, S) = (0, 1)
    while b != 0 {
        let q: S = numericCast(a / b)
        x = (x.1, x.0 - q * x.1)
        y = (y.1, y.0 - q * y.1)
        (a, b) = (b, a % b)
    }
    return (a, x.0, y.0)
}
public func exgcd<S: SignedIntegerType>(var a: S, var _ b: S) -> (gcd: S, x: S, y: S) {
    var iter = 0
    let sign1 = a >= 0 || b < 0
    let sign2 = a < 0 || b >= 0
    var x: (S, S) = (1, 0)
    var y: (S, S) = (0, 1)
    while b != 0 {
        let q = a / b
        x = (x.1, x.0 - q * x.1)
        y = (y.1, y.0 - q * y.1)
        (a, b) = (b, a % b)
        ++iter
    }
    if iter & 1 == 0 ? sign1 : sign2 {
        return (a, x.0, y.0)
    } else {
        return (-a, -x.0, -y.0)
    }
}

public func modinv<U: UnsignedIntegerType>(var a: U, var _ b: U) -> U {
    let _b = b
    var iter = 0
    var x: (U, U) = (1, 0)
    while b != 0 {
        x = (x.1, x.0 + (a / b) * x.1)
        (a, b) = (b, a % b)
        ++iter
    }
    if a != 1 {
        /* gcd(a, b) != 1, No inverse exists */
        return 0
    }
    if iter & 1 == 0 {
        return x.0
    } else {
        return _b - x.0
    }
}

public func lcm<T: UnsignedIntegerType>(a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}
public func lcm<T: SignedIntegerType>(a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}
public func factorial<T: UnsignedIntegerType>(x: T) -> T {
    if x == 0 || x == 1 {
        return 1
    }
    var _a: T = 1
    for i in 2...x {
        _a = _a * i
    }
    return _a
}

public func permutation<T: UnsignedIntegerType>(n: T, _ k: T) -> T {
    if k == 0 {
        return 1
    }
    if n < k {
        return 0
    }
    var _a: T = 1
    for i in (n - k + 1)...n {
        _a = _a * i
    }
    return _a
}
public func combination<T: UnsignedIntegerType>(n: T, _ k: T) -> T {
    return permutation(n, k) / factorial(k)
}

public func pow<T: UnsignedIntegerType>(x: T, _ n: T, _ m: T) -> T {
    if n == 0 && m != 1 {
        return 1
    }
    if x == 0 || m == 1 || x % m == 0 {
        return 0
    }
    let _x = x % m
    let p = pow((_x * _x) % m, T(n.toUIntMax() >> 1), m)
    return n & 1 == 1 ? (_x * p) % m : p
}
public func pow(x: UInt, _ n: UInt) -> UInt {
    return pow(x, n, UInt.max)
}
public func pow(x: UInt64, _ n: UInt64) -> UInt64 {
    return pow(x, n, UInt64.max)
}
public func pow(x: UInt32, _ n: UInt32) -> UInt32 {
    return pow(x, n, UInt32.max)
}
public func pow(x: UInt16, _ n: UInt16) -> UInt16 {
    return pow(x, n, UInt16.max)
}
public func pow(x: UInt8, _ n: UInt8) -> UInt8 {
    return pow(x, n, UInt8.max)
}

public func log2(x: Int) -> Int {
    return Int(flsl(x)) - 1
}
public func log2(x: Int8) -> Int8 {
    return Int8(fls(Int32(x) & 0xFF)) - 1
}
public func log2(x: Int16) -> Int16 {
    return Int16(fls(Int32(x) & 0xFFFF)) - 1
}
public func log2(x: Int32) -> Int32 {
    return fls(x) - 1
}
public func log2(x: Int64) -> Int64 {
    return Int64(flsll(x)) - 1
}
public func log2(x: UInt) -> UInt {
    return UInt(log2(Int(bitPattern: x)))
}
public func log2(x: UInt8) -> UInt8 {
    return UInt8(log2(Int8(bitPattern: x)))
}
public func log2(x: UInt16) -> UInt16 {
    return UInt16(log2(Int16(bitPattern: x)))
}
public func log2(x: UInt32) -> UInt32 {
    return UInt32(log2(Int32(bitPattern: x)))
}
public func log2(x: UInt64) -> UInt64 {
    return UInt64(log2(Int64(bitPattern: x)))
}

// MARK: Polynomial

public func degree2roots(b: Double, _ c: Double) -> [Double] {
    if b.almostZero {
        if c < 0 {
            let _c = sqrt(-c)
            return [_c, -_c]
        } else if c.almostZero {
            return [0]
        }
    }
    if c.almostZero {
        return [0, -b]
    }
    let del = b * b - 4 * c
    if del.almostZero {
        return [-0.5 * b]
    } else if del > 0 {
        let sqrt_del = sqrt(del)
        return [0.5 * (sqrt_del - b), 0.5 * (-sqrt_del - b)]
    }
    return []
}

public func degree3roots(b: Double, _ c: Double, _ d: Double) -> [Double] {
    if d.almostZero {
        let z = degree2roots(b, c)
        return z.contains(0) ? z : [0] + z
    }
    let b2 = b * b
    let b3 = b * b2
    let de0 = b2 - 3 * c
    let de1 = 2 * b3 - 9 * c * b + 27 * d
    let de2 = de1 * de1 - 4 * de0 * de0 * de0
    let m = b / 3
    if de2.almostZero {
        if de0.almostZero {
            return [-m] // repeated roots
        }
        let bc = b * c
        let d9 = 9 * d
        let x0 = (d9 - bc) / (2 * de0) // repeated roots
        let x1 = (4 * bc - d9 - b3) / de0
        return [x0, x1]
    } else if de0.almostZero {
        let C = cbrt(de1)
        let x0 = -(b + C + de0 / C) / 3
        let z = degree2roots((b + x0), c + b * x0 + x0 * x0)
        return z.contains(x0) ? z : [x0] + z
    }
    
    //depressed cubic
    let p = -de0 / 3
    let q = de1 / 27
    
    if q.almostZero {
        if p < 0 {
            let _p = sqrt(-p)
            return [-m, _p - m, -_p - m]
        }
        return [-m]
    }
    
    if de2 < 0 { // delta > 0, three real roots
        let p_3 = p / 3
        let s = 2 * sqrt(-p_3)
        let t = acos(q / (p_3 * s)) / 3
        let u = M_PI * 2 / 3
        return [s * cos(t) - m, s * cos(t - u) - m, s * cos(t - 2 * u) - m]
    }
    
    // one real roots
    if p > 0 {
        let p_3 = p / 3
        let s = 2 * sqrt(p_3)
        let t = asinh(q / (p_3 * s)) / 3
        return [-s * sinh(t) - m]
    }
    
    let p_3 = p / 3
    let s = 2 * sqrt(-p_3)
    let abs_q = -abs(q)
    let t = acosh(abs_q / (p_3 * s)) / 3
    return [abs_q / q * s * cosh(t) - m]
}

public func degree4roots(b: Double, _ c: Double, _ d: Double, _ e: Double) -> [Double] {
    if e.almostZero {
        let z = degree3roots(b, c, d)
        return z.contains(0) ? z : [0] + z
    }
    if b.almostZero && d.almostZero { // biquadratic
        var result = [Double]()
        for z in degree2roots(c, e) {
            if z > 0 {
                result.append(sqrt(z))
                result.append(-sqrt(z))
            } else if z.almostZero {
                result.append(0)
            }
        }
        return result
    }
    let b2 = b * b
    let b4 = b2 * b2
    let c2 = c * c
    let d2 = d * d
    let bd = b * d
    let bc = b * c
    let cb2 = bc * b
    let de0 = c2 - 3 * bd + 12 * e
    let de1 = 2 * c * c2 - 9 * bd * c + 27 * (b2 * e + d2) - 72 * e * c
    let _de0 = 4 * de0 * de0 * de0
    let de2 = de1 * de1 - _de0
    let P = 8 * c - 3 * b2
    let Q = b * b2 - 4 * bc + 8 * d
    let D = 64 * e + 16 * (cb2 - c2 - bd) - 3 * b4
    let p = 0.125 * P
    let q = 0.125 * Q
    let m = 0.25 * b
    if de2.almostZero {
        if D.almostZero {
            if de0.almostZero {
                return [-m] // repeated roots
            }
            if P < 0 { // special case of (x - u)^2 (x - v)^2
                return degree2roots(0.5 * b, sqrt(e))
            }
            if P > 0 && Q.almostZero { // no real roots
                return []
            }
        }
        func find_true_root(u: [Double]) -> Double {
            return u.lazy.minElement { u -> Double in
                let u2 = u * u
                let u3 = u * u2
                let u4 = u * u3
                let t = u4 + b * u3 + c * u2 + d * u + e
                return abs(t)
                }!
        }
        if de0.almostZero { // special case of (x - u)^3 (x - v)
            let u = find_true_root(degree2roots(0.5 * b, c / 6))
            let v = -b - 3 * u
            return [u, v]
        }
        
        // find double reals
        let u = find_true_root(degree3roots(0.75 * b, 0.5 * c, 0.25 * d))
        if P < 0 && D < 0 { // a double reals and two real simple roots
            return [u] + degree2roots(b + 2 * u, e / (u * u))
        }
        return [u] //double reals only
    }
    if de2 < 0 {
        if P < 0 && D < 0 { // four real roots
            let phi = acos(de1 / sqrt(_de0))
            let _S = -p + sqrt(de0) * cos(phi / 3)
            let S = 0.5 * sqrt(_S * 2 / 3)
            let S2 = S * S
            let _t = -4 * S2 - 2 * p
            let t0 = 0.5 * sqrt(_t + q / S)
            let t1 = 0.5 * sqrt(_t - q / S)
            return [-S + t0 - m, -S - t0 - m, S + t1 - m, S - t1 - m]
        }
        return []
    }
    
    //depressed quartic
    let r = e - 0.25 * bd + 0.0625 * cb2 - 0.01171875 * b4
    if q.almostZero { // biquadratic
        var result = [Double]()
        for z in degree2roots(p, r) {
            if z > 0 {
                result.append(sqrt(z) - m)
                result.append(-sqrt(z) - m)
            } else if z.almostZero {
                result.append(-m)
            }
        }
        return result
    }
    if r.almostZero {
        let z = degree3roots(0, p, q)
        return z.contains(0) ? z.map { $0 - m } : [-m] + z.map { $0 - m }
    }
    
    let p2 = p * p
    let fy = degree3roots(2.5 * p, 2 * p2 - r, 0.5 * (p * p2 - p * r - 0.25 * q * q))
    for y in fy {
        let _y = p + 2 * y
        if _y > 0 {
            let sqrt_y = sqrt(_y)
            let x = -3 * p - 2 * y
            let y = 2 * q / sqrt_y
            if x - y > 0 {
                let z = sqrt(x - y)
                return [0.5 * (sqrt_y + z) - m, 0.5 * (sqrt_y - z) - m]
            }
            let z = sqrt(x + y)
            return [0.5 * (-sqrt_y + z) - m, 0.5 * (-sqrt_y - z) - m]
        }
    }
    return []
}

public func bairstow(var buf: [Double], var eps: Double = 1e-14) -> [Double] {
    
    switch buf.count {
    case 0: return []
    case 1: return [-buf[0]]
    case 2: return degree2roots(buf[0], buf[1])
    case 3: return degree3roots(buf[0], buf[1], buf[2])
    case 4: return degree4roots(buf[0], buf[1], buf[2], buf[3])
    default:
        var r = buf[1] / buf[0]
        var s = buf[2] / buf[0]
        var iter = 0
        while true {
            var b0 = 1.0
            var c0 = 0.0
            var c1 = 0.0
            var c2 = 1.0
            var b1 = buf[0] - r
            var c3 = b1 - r
            for a in buf.dropFirst() {
                (b0, b1) = (b1, a - r * b1 - s * b0)
                (c0, c1, c2, c3) = (c1, c2, c3, b1 - r * c3 - s * c2)
            }
            let d = c2 * c0 - c1 * c1
            let dr = (b1 * c0 - b0 * c1) / d
            let ds = (b0 * c2 - b1 * c1) / d
            
            r += dr
            s += ds
            if abs(dr) < eps && abs(ds) < eps {
                break
            }
            if ++iter % 500 == 0 {
                if eps < 1e-06 {
                    eps *= 10
                }
            }
        }
        Deconvolve(buf.count + 1, [1] + buf, 1, 3, [1, r, s], 1, &buf, 1)
        return degree2roots(r, s) + bairstow(buf[1...buf.count - 2].array, eps: eps)
    }
}

// MARK: Others

public func linearScale(f: UInt, _ x: UInt) -> Double {
    return log(Double(x + 1)) / log(Double(f))
}
public func logScale(f: UInt, _ x: Double) -> UInt {
    return UInt(lround(pow(Double(f), x))) - 1
}

public func degreesToRad(alpha: Float) -> Float {
    return alpha * Float(M_PI) / 180.0
}
public func degreesToRad(alpha: Double) -> Double {
    return alpha * M_PI / 180.0
}

public func LogarithmicDynamicRangeCompression(x: Double, _ m: Double) -> Double {
    let alpha = 2.5128624172523393539654752332184326538328336634026474
    let alpha_2 = 0.7959050946318330895721191440438390881317432367303995
    let re = log(1.0 + alpha * abs(x) / m) * alpha_2
    return x.isSignMinus ? -re : re
}

public func LinearInterpolate(t: Double, _ a: Double, _ b: Double) -> Double {
    return a * (1.0 - t) + b * t
}

public func CosineInterpolate(t: Double, _ a: Double, _ b: Double) -> Double {
    return LinearInterpolate((1.0 - cos(t * M_PI)) * 0.5, a, b)
}

public func CubicInterpolate(t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    let t2 = t * t
    let m0 = d - c - a + b
    let m1 = a - b - m0
    let m2 = c - a
    let m3 = b
    return m0 * t * t2 + m1 * t2 + m2 * t + m3
}

public func HermiteInterpolate(t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double, _ s: Double, _ e: Double) -> Double {
    let t2 = t * t
    let t3 = t2 * t
    var m0 = (b - a) * (1.0 + e) * (1.0 - s) * 0.5
    m0 += (c - b) * (1.0 - e) * (1.0 - s) * 0.5
    var m1 = (c - b) * (1.0 + e) * (1.0 - s) * 0.5
    m1 += (d - c) * (1.0 - e) * (1.0 - s) * 0.5
    let a0 = 2.0 * t3 - 3.0 * t2 + 1.0
    let a1 = t3 - 2.0 * t2 + t
    let a2 = t3 - t2
    let a3 = -2.0 * t3 + 3.0 * t2
    return a0 * b + a1 * m0 + a2 * m1 + a3 * c
}

public func Phase(x: Double, _ shift: Double, _ frequency: Double, _ maxFrequency: Double) -> Double {
    return abs((x / maxFrequency + shift) * frequency) % 1.0
}
public func SineWave(phase: Double) -> Double {
    return sin(2 * M_PI * phase)
}
public func SquareWave(phase: Double) -> Double {
    return phase < 0.5 ? 1 : -1
}
public func SawtoothWave(phase: Double) -> Double {
    return phase * 2 - 1.0
}
public func TriangleWave(phase: Double) -> Double {
    return phase < 0.5 ? phase * 4 - 1.0 : 3.0 - phase * 4
}

