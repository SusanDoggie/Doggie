//
//  Integer.swift
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

extension FixedWidthInteger {
    
    @inlinable
    public var reverse: Self {
        
        var m1: Self = 0
        for _ in 0..<bitWidth >> 3 {
            m1 = (m1 << 8) | 0x0F
        }
        
        let m2 = (m1 << 2) ^ m1
        let m3 = (m2 << 1) ^ m2
        
        let s1 = (0xF0 as Self).byteSwapped
        let s2 = s1 << 2
        let s3 = s2 << 1
        
        let x0 = self.byteSwapped
        let u0 = (x0 & m1) << 4
        let v0 = ((x0 & ~m1) >> 4) & ~s1
        
        let x1 = u0 | v0
        let u1 = (x1 & m2) << 2
        let v1 = ((x1 & ~m2) >> 2) & ~s2
        
        let x2 = u1 | v1
        let u2 = (x2 & m3) << 1
        let v2 = ((x2 & ~m3) >> 1) & ~s3
        
        return u2 | v2
    }
}

@inlinable
@inline(__always)
public func log2<T: FixedWidthInteger>(_ x: T) -> T {
    return x == 0 ? 0 : T(x.bitWidth - x.leadingZeroBitCount - 1)
}

extension FixedWidthInteger {
    
    @inlinable
    public var hibit: Self {
        return 1 << log2(self)
    }
}

extension FixedWidthInteger {
    
    @inlinable
    public var lowbit: Self {
        return 1 << self.trailingZeroBitCount
    }
}

extension BinaryInteger {
    
    @inlinable
    public var isPower2 : Bool {
        return 0 < self && self & (self - 1) == 0
    }
}

extension BinaryInteger {
    
    @inlinable
    @inline(__always)
    public func align(_ s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}

@inlinable
@inline(__always)
func _scale_integer<T: FixedWidthInteger & UnsignedInteger, R: FixedWidthInteger & UnsignedInteger>(_ x: T, _ from_max: T, _ to_max: R) -> R {
    
    @inline(__always)
    func __scale_integer<T: FixedWidthInteger & UnsignedInteger>(_ x: T, _ from_max: T, _ to_max: T) -> T {
        let (quotient, remainder) = from_max.dividingFullWidth(x.multipliedFullWidth(by: to_max))
        let (_remainder, overflow) = remainder.multipliedReportingOverflow(by: 2)
        return !overflow && _remainder < from_max ? quotient : quotient + 1
    }
    
    return T.bitWidth > R.bitWidth ? R(__scale_integer(x, from_max, T(to_max))) : __scale_integer(R(x), R(from_max), to_max)
}

@inlinable
@inline(__always)
public func addmod<T: FixedWidthInteger & UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    let c = m &- b
    return a < c ? a &+ b : a &- c
}
@inlinable
@inline(__always)
public func negmod<T: FixedWidthInteger & UnsignedInteger>(_ a: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    return m &- a
}
@inlinable
@inline(__always)
public func submod<T: FixedWidthInteger & UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    let c = m &- b
    return a < b ? a &+ c : a &- b
}

@inlinable
@inline(__always)
public func mulmod<T: FixedWidthInteger & UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    if a == 0 || b == 0 {
        return 0
    }
    if m.isPower2 {
        return (a &* b) & (m - 1)
    }
    return m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
}

@inlinable
public func pow<T: FixedWidthInteger & UnsignedInteger>(_ x: T, _ n: T, _ m: T = T.max) -> T {
    assert(m != 0, "divide by zero")
    let x = x % m
    if x == 0 || m == 1 {
        return 0
    }
    if n == 0 {
        return 1
    }
    let p = pow(mulmod(x, x, m), n >> 1, m)
    return n & 1 == 1 ? mulmod(x, p, m) : p
}

@inlinable
@inline(__always)
public func gcd<U: UnsignedInteger>(_ a: U, _ b: U) -> U {
    var a = a
    var b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}
@inlinable
@inline(__always)
public func gcd<S: SignedInteger>(_ a: S, _ b: S) -> S {
    var a = a
    var b = b
    let sign = a >= 0 || b >= 0
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return sign ? abs(a) : -abs(a)
}

@inlinable
@inline(__always)
public func exgcd<S: SignedInteger>(_ a: S, _ b: S) -> (gcd: S, x: S, y: S) {
    var a = a
    var b = b
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
        iter += 1
    }
    if iter & 1 == 0 ? sign1 : sign2 {
        return (a, x.0, y.0)
    } else {
        return (-a, -x.0, -y.0)
    }
}

@inlinable
@inline(__always)
public func modinv<U: UnsignedInteger>(_ a: U, _ b: U) -> U {
    var a = a
    var b = b
    let _b = b
    var iter = 0
    var x: (U, U) = (1, 0)
    while b != 0 {
        x = (x.1, x.0 + (a / b) * x.1)
        (a, b) = (b, a % b)
        iter += 1
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

@inlinable
@inline(__always)
public func lcm<T: UnsignedInteger>(_ a: T, _ b: T) -> T {
    return a / gcd(a, b) * b
}
@inlinable
@inline(__always)
public func lcm<T: SignedInteger>(_ a: T, _ b: T) -> T {
    return a / gcd(a, b) * b
}

@inlinable
@inline(__always)
public func factorial<T: UnsignedInteger>(_ x: T) -> T where T.Stride : SignedInteger {
    if x == 0 || x == 1 {
        return 1
    }
    var _a: T = 1
    for i in 2...x {
        _a = _a * i
    }
    return _a
}

@inlinable
@inline(__always)
public func permutation<T: UnsignedInteger>(_ n: T, _ k: T) -> T where T.Stride : SignedInteger {
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

@inlinable
@inline(__always)
public func combination<T: UnsignedInteger>(_ n: T, _ k: T) -> T where T.Stride : SignedInteger {
    return permutation(n, k) / factorial(k)
}

@inlinable
public func fibonacci<T: FixedWidthInteger & UnsignedInteger>(_ n: T) -> T {
    func fib(_ n: T) -> (T, T) {
        switch n {
        case 0: return (1, 1)
        case 1: return (1, 2)
        default:
            let (a, b) = fib((n >> 1) - 1)
            let b2 = b * b
            let c = a * a + b2
            let d = 2 * a * b + b2
            return n & 1 == 0 ? (c, d) : (d, c + d)
        }
    }
    return fib(n).0
}
