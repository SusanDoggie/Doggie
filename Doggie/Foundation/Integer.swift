//
//  Integer.swift
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

@warn_unused_result
public func log2(x: Int64) -> Int64 {
    return Int64(flsll(x)) - 1
}
@warn_unused_result
public func log2(x: Int32) -> Int32 {
    return fls(x) - 1
}
@warn_unused_result
public func log2(x: Int16) -> Int16 {
    return Int16(truncatingBitPattern: log2(Int32(x) & 0xFFFF))
}
@warn_unused_result
public func log2(x: Int8) -> Int8 {
    return Int8(truncatingBitPattern: log2(Int32(x) & 0xFF))
}
@warn_unused_result
public func log2(x: Int) -> Int {
    return Int(flsl(x)) - 1
}
@warn_unused_result
public func log2(x: UInt64) -> UInt64 {
    return UInt64(bitPattern: log2(Int64(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt32) -> UInt32 {
    return UInt32(bitPattern: log2(Int32(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt16) -> UInt16 {
    return UInt16(bitPattern: log2(Int16(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt8) -> UInt8 {
    return UInt8(bitPattern: log2(Int8(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt) -> UInt {
    return UInt(bitPattern: log2(Int(bitPattern: x)))
}

public extension UInt64 {
    
    var hibit: UInt64 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt32 {
    
    var hibit: UInt32 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt16 {
    
    var hibit: UInt16 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt8 {
    
    var hibit: UInt8 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt {
    
    var hibit: UInt {
        return self == 0 ? 0 : 1 << log2(self)
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

public extension IntegerType {
    
    var lowbit: Self {
        return self & (~self &+ 1)
    }
}

public extension UnsignedIntegerType {
    
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

public extension IntegerType {
    
    var isPower2 : Bool {
        return 0 < self && self & (self &- 1) == 0
    }
}

public extension IntegerType {
    
    @warn_unused_result
    func align(s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}

@warn_unused_result
public func << <T: UnsignedIntegerType>(lhs: T, rhs: T) -> T {
    switch lhs {
    case let lhs as UInt8: return (lhs << (rhs as! UInt8)) as! T
    case let lhs as UInt16: return (lhs << (rhs as! UInt16)) as! T
    case let lhs as UInt32: return (lhs << (rhs as! UInt32)) as! T
    case let lhs as UInt64: return (lhs << (rhs as! UInt64)) as! T
    case let lhs as UInt: return (lhs << (rhs as! UInt)) as! T
    default: return T((lhs.toUIntMax() << rhs.toUIntMax()) & (~T.allZeros).toUIntMax())
    }
}
@warn_unused_result
public func >> <T: UnsignedIntegerType>(lhs: T, rhs: T) -> T {
    switch lhs {
    case let lhs as UInt8: return (lhs >> (rhs as! UInt8)) as! T
    case let lhs as UInt16: return (lhs >> (rhs as! UInt16)) as! T
    case let lhs as UInt32: return (lhs >> (rhs as! UInt32)) as! T
    case let lhs as UInt64: return (lhs >> (rhs as! UInt64)) as! T
    case let lhs as UInt: return (lhs >> (rhs as! UInt)) as! T
    default: return T((lhs.toUIntMax() >> rhs.toUIntMax()) & (~T.allZeros).toUIntMax())
    }
}

@warn_unused_result
public func >>= <T: UnsignedIntegerType>(inout lhs: T, rhs: T) {
    lhs = lhs >> rhs
}
@warn_unused_result
public func <<= <T: UnsignedIntegerType>(inout lhs: T, rhs: T) {
    lhs = lhs << rhs
}

@warn_unused_result
public func addmod<T: UnsignedIntegerType>(a: T, _ b: T, _ m: T) -> T {
    let a = a < m ? a : a % m
    let b = b < m ? b : b % m
    let c = m &- b
    return a < c ? a &+ b : a &- c
}

@warn_unused_result
public func mulmod(a: UInt8, _ b: UInt8, _ m: UInt8) -> UInt8 {
    return UInt8((UInt16(a) &* UInt16(b)) % UInt16(m))
}
@warn_unused_result
public func mulmod(a: UInt16, _ b: UInt16, _ m: UInt16) -> UInt16 {
    return UInt16(truncatingBitPattern: (UInt32(a) &* UInt32(b)) % UInt32(m))
}
@warn_unused_result
public func mulmod(a: UInt32, _ b: UInt32, _ m: UInt32) -> UInt32 {
    return UInt32(truncatingBitPattern: (UInt64(a) &* UInt64(b)) % UInt64(m))
}

@warn_unused_result
public func mulmod<T: UnsignedIntegerType>(a: T, _ b: T, _ m: T) -> T {
    let a = a < m ? a : a % m
    let b = b < m ? b : b % m
    if a == 0 || b == 0 || m == 1 {
        return 0
    }
    let (mul, overflow) = T.multiplyWithOverflow(a, b)
    if m.isPower2 {
        return mul & (m - 1)
    }
    if overflow {
        let c = mulmod(addmod(a, a, m), b >> 1, m)
        return b & 1 == 1 ? addmod(a, c, m) : c
    }
    return mul % m
}

@warn_unused_result
public func pow(x: UInt8, _ n: UInt8, _ m: UInt8) -> UInt8 {
    
    let x = x < m ? x : x % m
    
    if x == 0 || m == 1 {
        return 0
    }
    if n == 0 {
        return 1
    }
    
    let p = pow(mulmod(x, x, m), n >> 1, m)
    return n & 1 == 1 ? mulmod(x, p, m) : p
}

@warn_unused_result
public func pow(x: UInt16, _ n: UInt16, _ m: UInt16) -> UInt16 {
    
    let x = x < m ? x : x % m
    
    if x == 0 || m == 1 {
        return 0
    }
    if n == 0 {
        return 1
    }
    
    let p = pow(mulmod(x, x, m), n >> 1, m)
    return n & 1 == 1 ? mulmod(x, p, m) : p
}

@warn_unused_result
public func pow(x: UInt32, _ n: UInt32, _ m: UInt32) -> UInt32 {
    
    let x = x < m ? x : x % m
    
    if x == 0 || m == 1 {
        return 0
    }
    if n == 0 {
        return 1
    }
    
    let p = pow(mulmod(x, x, m), n >> 1, m)
    return n & 1 == 1 ? mulmod(x, p, m) : p
}
@warn_unused_result
public func pow<T: UnsignedIntegerType>(x: T, _ n: T, _ m: T) -> T {
    
    let x = x < m ? x : x % m
    
    if x == 0 || m == 1 {
        return 0
    }
    if n == 0 {
        return 1
    }
    
    let p = pow(mulmod(x, x, m), n >> 1, m)
    return n & 1 == 1 ? mulmod(x, p, m) : p
}

@warn_unused_result
public func pow(x: UInt, _ n: UInt) -> UInt {
    return pow(x, n, UInt.max)
}
@warn_unused_result
public func pow(x: UInt64, _ n: UInt64) -> UInt64 {
    return pow(x, n, UInt64.max)
}
@warn_unused_result
public func pow(x: UInt32, _ n: UInt32) -> UInt32 {
    return pow(x, n, UInt32.max)
}
@warn_unused_result
public func pow(x: UInt16, _ n: UInt16) -> UInt16 {
    return pow(x, n, UInt16.max)
}
@warn_unused_result
public func pow(x: UInt8, _ n: UInt8) -> UInt8 {
    return pow(x, n, UInt8.max)
}

private func sec_random(buffer: UnsafeMutablePointer<Void>, _ size: Int) {
    let _rand_file = open("/dev/random", O_RDONLY)
    read(_rand_file, buffer, size)
    close(_rand_file)
}

public func random_uniform(bound: UIntMax) -> UIntMax {
    let RANDMAX: UIntMax = ~0
    var _rand: UIntMax = 0
    sec_random(&_rand, sizeof(UIntMax))
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            sec_random(&_rand, sizeof(UIntMax))
        }
        _rand %= bound
    }
    return _rand
}

@warn_unused_result
public func gcd<U: UnsignedIntegerType>(a: U, _ b: U) -> U {
    var a = a
    var b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}
@warn_unused_result
public func gcd<S: SignedIntegerType>(a: S, _ b: S) -> S {
    var a = a
    var b = b
    let sign = a >= 0 || b >= 0
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return sign ? abs(a) : -abs(a)
}

@warn_unused_result
public func exgcd<S: SignedIntegerType>(a: S, _ b: S) -> (gcd: S, x: S, y: S) {
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

@warn_unused_result
public func modinv<U: UnsignedIntegerType>(a: U, _ b: U) -> U {
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

@warn_unused_result
public func lcm<T: UnsignedIntegerType>(a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}
@warn_unused_result
public func lcm<T: SignedIntegerType>(a: T, _ b: T) -> T {
    return a * b / gcd(a, b)
}

@warn_unused_result
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

@warn_unused_result
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
@warn_unused_result
public func combination<T: UnsignedIntegerType>(n: T, _ k: T) -> T {
    return permutation(n, k) / factorial(k)
}

@warn_unused_result
public func fibonacci<T: UnsignedIntegerType>(n: T) -> T {
    func fib(n: T) -> (T, T) {
        switch n {
        case 0: return (1, 1)
        case 1: return (1, 2)
        default:
            let (a, b) = fib(n / 2 - 1)
            let b2 = b * b
            let c = a * a + b2
            let d = 2 * a * b + b2
            return n & 1 == 0 ? (c, d) : (d, c + d)
        }
    }
    return fib(n).0
}
