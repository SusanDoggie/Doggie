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

public extension IntegerType {
    
    @warn_unused_result
    static func random() -> Self {
        var _r: Self = 0
        arc4random_buf(&_r, sizeof(Self))
        return _r
    }
}

extension UInt32 {
    
    @warn_unused_result
    static func random(bound: UInt32) -> UInt32 {
        return arc4random_uniform(bound)
    }
}

extension Float32 {
    
    @warn_unused_result
    static func random() -> Float32 {
        return unsafeBitCast(UInt32.random(0x7FFFFF) | 0x3F800000, Float32.self) - 1
    }
}

extension Float64 {
    
    @warn_unused_result
    static func random() -> Float64 {
        return unsafeBitCast(UInt64.random() & 0xFFFFFFFFFFFFF | 0x3FF0000000000000, Float64.self) - 1
    }
}

@warn_unused_result
public func random_bytes(count: Int) -> [UInt8] {
    var buffer = [UInt8](count: count, repeatedValue: 0)
    arc4random_buf(&buffer, buffer.count)
    return buffer
}
@warn_unused_result
public func random(range: Range<Int32>) -> Int32 {
    return Int32(UInt32.random(UInt32(range.endIndex - range.startIndex))) + range.startIndex
}
@warn_unused_result
public func random(range: ClosedInterval<Float>) -> Float {
    let diff = range.end - range.start
    return ((unsafeBitCast(UInt32.random(0x800000) + 0x3F800000, Float32.self) - 1) * diff) + range.start
}
@warn_unused_result
public func random(range: ClosedInterval<Double>) -> Double {
    let diff = range.end - range.start
    return ((Double(UInt64.random()) / Double(UInt64.max)) * diff) + range.start
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