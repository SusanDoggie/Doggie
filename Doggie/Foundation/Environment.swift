//
//  Environment.swift
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

public let isLittleEndian = TARGET_RT_LITTLE_ENDIAN == 1
public let isBigEndian = TARGET_RT_BIG_ENDIAN == 1

public let Progname = String.fromCString(getprogname())!

public func Environment(name: String) -> String? {
    return String.fromCString(getenv(name))
}

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
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int32 {
    
    var hibit: Int32 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int16 {
    
    var hibit: Int16 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int8 {
    
    var hibit: Int8 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int {
    
    var hibit: Int {
        return self == 0 ? 0 : 1 << log2(self)
    }
}

extension IntegerType {
    
    public var isPower2 : Bool {
        return 0 < self && self & (self &- 1) == 0
    }
    
    @warn_unused_result
    public func align(s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}

public extension UnsafePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}
public extension UnsafeMutablePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}
public extension COpaquePointer {
    
    var bitPattern: Int {
        return unsafeBitCast(self)
    }
}

public extension Comparable {
    
    @warn_unused_result
    func clamp(range: ClosedInterval<Self>) -> Self {
        return min(max(self, range.start), range.end)
    }
}

@warn_unused_result
public func arc4random_uniform(bound: UIntMax) -> UIntMax {
    let RANDMAX: UIntMax = ~0
    var _rand: UIntMax = 0
    arc4random_buf(&_rand, sizeof(UIntMax))
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            arc4random_buf(&_rand, sizeof(UIntMax))
        }
        _rand %= bound
    }
    return _rand
}

public extension Float32 {
    
    @warn_unused_result
    static func random(includeOne includeOne: Bool = false) -> Float32 {
        if includeOne {
            return unsafeBitCast(arc4random_uniform(0x800000) + 0x3F800000 as UInt32, Float32.self) - 1
        }
        return unsafeBitCast(arc4random_uniform(0x7FFFFF) | 0x3F800000 as UInt32, Float32.self) - 1
    }
}

public extension Float64 {
    
    @warn_unused_result
    static func random(includeOne includeOne: Bool = false) -> Float64 {
        if includeOne {
            return unsafeBitCast(arc4random_uniform(0x10000000000000) + 0x3FF0000000000000 as UInt64, Float64.self) - 1
        }
        return unsafeBitCast(arc4random_uniform(0xFFFFFFFFFFFFF) | 0x3FF0000000000000 as UInt64, Float64.self) - 1
    }
}

@warn_unused_result
public func random_bytes(count: Int) -> [UInt8] {
    var buffer = [UInt8](count: count, repeatedValue: 0)
    arc4random_buf(&buffer, buffer.count)
    return buffer
}

@warn_unused_result
public func random(range: ClosedInterval<Float>) -> Float {
    let diff = range.end - range.start
    return (Float.random(includeOne: true) * diff) + range.start
}
@warn_unused_result
public func random(range: ClosedInterval<Double>) -> Double {
    let diff = range.end - range.start
    return (Double.random(includeOne: true) * diff) + range.start
}
@warn_unused_result
public func random(range: HalfOpenInterval<Float>) -> Float {
    let diff = range.end - range.start
    return (Float.random() * diff) + range.start
}
@warn_unused_result
public func random(range: HalfOpenInterval<Double>) -> Double {
    let diff = range.end - range.start
    return (Double.random() * diff) + range.start
}

@warn_unused_result
public func byteArray<T : IntegerType>(bytes: T ... ) -> [UInt8] {
    let count = bytes.count * sizeof(T)
    var buf = [UInt8](count: count, repeatedValue: 0)
    memcpy(&buf, bytes, count)
    return buf
}
@warn_unused_result
public func byteArray(data: UnsafePointer<Void>, length: Int) -> [UInt8] {
    var buf = [UInt8](count: length, repeatedValue: 0)
    memcpy(&buf, data, length)
    return buf
}

@warn_unused_result
public func unsafeBitCast<T, U>(x: T) -> U {
    return unsafeBitCast(x, U.self)
}

public func SDTimer(count count: Int = 1, @noescape block: () -> Void) -> NSTimeInterval {
    var time: UInt64 = 0
    for _ in 0..<count {
        autoreleasepool {
            let start = mach_absolute_time()
            block()
            time += mach_absolute_time() - start
        }
    }
    var timebaseInfo = mach_timebase_info()
    mach_timebase_info(&timebaseInfo)
    let frac = Double(timebaseInfo.numer) / Double(timebaseInfo.denom)
    return 1e-9 * Double(time) * frac / Double(count)
}

@warn_unused_result
public func timeFormat(time: Double) -> String {
    let minutes = Int(floor(time / 60.0))
    let seconds = lround(time - Double(minutes * 60))
    return String(format: "%d:%02d", minutes, seconds)
}

public func autoreleasepool<R>(@noescape code: () -> R) -> R {
    var result: R!
    autoreleasepool {
        result = code()
    }
    return result
}

@warn_unused_result
public func == <T : Comparable>(lhs: T, rhs: T) -> Bool {
    return !(lhs < rhs || rhs < lhs)
}

private let _hash_phi = 0.6180339887498948482045868343656381177203091798057628
private let _hash_seed = Int(bitPattern: UInt(round(_hash_phi * Double(UInt.max))))

@warn_unused_result
public func hash_combine<T: Hashable>(seed: Int, _ value: T) -> Int {
    let a = seed << 6
    let b = seed >> 2
    let c = value.hashValue &+ _hash_seed &+ a &+ b
    return seed ^ c
}
@warn_unused_result
public func hash_combine<S: SequenceType where S.Generator.Element : Hashable>(seed: Int, _ values: S) -> Int {
    return values.reduce(seed, combine: hash_combine)
}
@warn_unused_result
public func hash_combine<T: Hashable>(seed: Int, _ a: T, _ b: T, _ res: T ... ) -> Int {
    return hash_combine(seed, CollectionOfOne(a).concat(CollectionOfOne(b)).concat(res))
}
