//
//  Integer.swift
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

public extension UInt64 {
    
    var reverse: UInt64 {
        var x = self
        x = ((x & 0x5555555555555555) << 1) | ((x & 0xAAAAAAAAAAAAAAAA) >> 1)
        x = ((x & 0x3333333333333333) << 2) | ((x & 0xCCCCCCCCCCCCCCCC) >> 2)
        x = ((x & 0x0F0F0F0F0F0F0F0F) << 4) | ((x & 0xF0F0F0F0F0F0F0F0) >> 4)
        x = ((x & 0x00FF00FF00FF00FF) << 8) | ((x & 0xFF00FF00FF00FF00) >> 8)
        x = ((x & 0x0000FFFF0000FFFF) << 16) | ((x & 0xFFFF0000FFFF0000) >> 16)
        x = ((x & 0x00000000FFFFFFFF) << 32) | ((x & 0xFFFFFFFF00000000) >> 32)
        return x
    }
}
public extension UInt32 {
    
    var reverse: UInt32 {
        var x = self
        x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1)
        x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2)
        x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4)
        x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8)
        x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16)
        return x
    }
}
public extension UInt16 {
    
    var reverse: UInt16 {
        var x = self
        x = ((x & 0x5555) << 1) | ((x & 0xAAAA) >> 1)
        x = ((x & 0x3333) << 2) | ((x & 0xCCCC) >> 2)
        x = ((x & 0x0F0F) << 4) | ((x & 0xF0F0) >> 4)
        x = ((x & 0x00FF) << 8) | ((x & 0xFF00) >> 8)
        return x
    }
}
public extension UInt8 {
    
    var reverse: UInt8 {
        var x = self
        x = ((x & 0x55) << 1) | ((x & 0xAA) >> 1)
        x = ((x & 0x33) << 2) | ((x & 0xCC) >> 2)
        x = ((x & 0x0F) << 4) | ((x & 0xF0) >> 4)
        return x
    }
}
public extension Int64 {
    
    var reverse: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).reverse)
    }
}
public extension Int32 {
    
    var reverse: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).reverse)
    }
}
public extension Int16 {
    
    var reverse: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).reverse)
    }
}
public extension Int8 {
    
    var reverse: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).reverse)
    }
}

public func log2<T: UnsignedInteger>(_ x: T) -> T {
    var r: T = 0
    var x = x
    while x != 0 {
        x = x >> 1
        r = r + 1
    }
    return r - 1
}
public func log2(_ x: Int64) -> Int64 {
    return Int64(bitPattern: log2(UInt64(bitPattern: x)))
}
public func log2(_ x: Int32) -> Int32 {
    return Int32(bitPattern: log2(UInt32(bitPattern: x)))
}
public func log2(_ x: Int16) -> Int16 {
    return Int16(bitPattern: log2(UInt16(bitPattern: x)))
}
public func log2(_ x: Int8) -> Int8 {
    return Int8(bitPattern: log2(UInt8(bitPattern: x)))
}
public func log2(_ x: Int) -> Int {
    return Int(bitPattern: log2(UInt(bitPattern: x)))
}

public extension UnsignedInteger {
    
    var hibit: Self {
        let mbit: Self = ~(~0 >> 1)
        if self & mbit != 0 {
            return mbit
        }
        var x = self.toUIntMax()
        for i in 1..<UIntMax(MemoryLayout<Self>.size) {
            x |= x >> i
        }
        return Self((x + 1) >> 1)
    }
}

public extension Int64 {
    
    var hibit: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).hibit)
    }
}
public extension Int32 {
    
    var hibit: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).hibit)
    }
}
public extension Int16 {
    
    var hibit: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).hibit)
    }
}
public extension Int8 {
    
    var hibit: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).hibit)
    }
}
public extension Int {
    
    var hibit: Int {
        return Int(bitPattern: UInt(bitPattern: self).hibit)
    }
}

public extension Integer {
    
    var lowbit: Self {
        return self & (~self &+ 1)
    }
}

public extension UnsignedInteger {
    
    var bitCount: Self {
        var x = self
        var c: Self = 0
        while x != 0 {
            x &= x - 1
            c += 1 as Self
        }
        return c
    }
}
public extension Int64 {
    
    var bitCount: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).bitCount)
    }
}
public extension Int32 {
    
    var bitCount: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).bitCount)
    }
}
public extension Int16 {
    
    var bitCount: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).bitCount)
    }
}
public extension Int8 {
    
    var bitCount: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).bitCount)
    }
}
public extension Int {
    
    var bitCount: Int {
        return Int(bitPattern: UInt(bitPattern: self).bitCount)
    }
}

public extension Integer {
    
    var isPower2 : Bool {
        return 0 < self && self & (self &- 1) == 0
    }
}

public extension Integer {
    
    func align(_ s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}

public func addmod<T: UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    let c = m &- b
    return a < c ? a &+ b : a &- c
}
public func negmod<T: UnsignedInteger>(_ a: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    return m &- a
}
public func submod<T: UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    let c = m &- b
    return a < b ? a &+ c : a &- b
}

public func >><T: UnsignedInteger>(lhs: T, rhs: T) -> T {
    return T(lhs.toUIntMax() >> rhs.toUIntMax())
}

public func mulmod<T: UnsignedInteger>(_ a: T, _ b: T, _ m: T) -> T {
    func _mulmod(_ a: UIntMax, _ b: UIntMax, _ m: UIntMax) -> UIntMax {
        if a == 0 || b == 0 {
            return 0
        }
        let (mul, overflow) = UIntMax.multiplyWithOverflow(a, b)
        if overflow {
            let c = _mulmod(addmod(a, a, m), b >> 1, m)
            return b & 1 == 1 ? addmod(a, c, m) : c
        }
        return mul % m
    }
    assert(m != 0, "divide by zero")
    let a = a % m
    let b = b % m
    if a == 0 || b == 0 {
        return 0
    }
    if m.isPower2 {
        return (a &* b) & (m - 1)
    }
    return T(_mulmod(a.toUIntMax(), b.toUIntMax(), m.toUIntMax()))
}

public func pow<T: UnsignedInteger>(_ x: T, _ n: T, _ m: T) -> T {
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

public func pow(_ x: UInt, _ n: UInt) -> UInt {
    return pow(x, n, UInt.max)
}
public func pow(_ x: UInt64, _ n: UInt64) -> UInt64 {
    return pow(x, n, UInt64.max)
}
public func pow(_ x: UInt32, _ n: UInt32) -> UInt32 {
    return pow(x, n, UInt32.max)
}
public func pow(_ x: UInt16, _ n: UInt16) -> UInt16 {
    return pow(x, n, UInt16.max)
}
public func pow(_ x: UInt8, _ n: UInt8) -> UInt8 {
    return pow(x, n, UInt8.max)
}

public func gcd<U: UnsignedInteger>(_ a: U, _ b: U) -> U {
    var a = a
    var b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}
public func gcd<S: SignedInteger>(_ a: S, _ b: S) -> S {
    var a = a
    var b = b
    let sign = a >= 0 || b >= 0
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return sign ? abs(a) : -abs(a)
}

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

public func lcm<T: UnsignedInteger>(_ a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}
public func lcm<T: SignedInteger>(_ a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}

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
public func combination<T: UnsignedInteger>(_ n: T, _ k: T) -> T where T.Stride : SignedInteger {
    return permutation(n, k) / factorial(k)
}

public func fibonacci<T: UnsignedInteger>(_ n: T) -> T {
    func fib(_ n: UIntMax) -> (UIntMax, UIntMax) {
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
    return T(fib(n.toUIntMax()).0)
}
