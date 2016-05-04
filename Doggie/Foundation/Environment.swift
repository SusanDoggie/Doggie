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

@warn_unused_result
public func unsafeBitCast<T, U>(x: T) -> U {
    return unsafeBitCast(x, U.self)
}

@warn_unused_result
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
