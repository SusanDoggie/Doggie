//
//  Random.swift
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

public class RandomGenerator {
    
    private let rand_file: Int32
    
    fileprivate init(source: String) {
        rand_file = open(source, O_RDONLY)
    }
    
    deinit {
        close(rand_file)
    }
    
    public func read(_ buffer: UnsafeMutableRawPointer, size: Int) {
        let buffer = buffer.assumingMemoryBound(to: UInt8.self)
        var read_bytes = 0
        while read_bytes < size {
            let r = Foundation.read(rand_file, buffer + read_bytes, size - read_bytes)
            if r > 0 {
                read_bytes += r
            }
        }
    }
}

public let _dev_random = RandomGenerator(source: "/dev/random")
public let _dev_urandom = RandomGenerator(source: "/dev/urandom")

@_inlineable
public func sec_random_uniform<T : FixedWidthInteger>(_ bound: T) -> T {
    let RANDMAX: T = ~0
    var _rand: T = 0
    _dev_random.read(&_rand, size: T.bitWidth)
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            _dev_random.read(&_rand, size: T.bitWidth)
        }
        _rand %= bound
    }
    return _rand
}

@_inlineable
public func random_uniform<T : FixedWidthInteger>(_ bound: T) -> T {
    let RANDMAX: T = ~0
    var _rand: T = 0
    _dev_urandom.read(&_rand, size: T.bitWidth)
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            _dev_urandom.read(&_rand, size: T.bitWidth)
        }
        _rand %= bound
    }
    return _rand
}

extension BinaryFloatingPoint where RawSignificand : FixedWidthInteger, RawSignificand.Stride : SignedInteger & FixedWidthInteger {
    
    @_inlineable
    public static func random(includeOne: Bool = false) -> Self {
        let significandBitCount = Self.significandBitCount
        let exponentBitPattern: RawSignificand = numericCast((1 as Self).exponentBitPattern) << significandBitCount
        let maxsignificand: RawSignificand = 1 << significandBitCount
        let rand = includeOne ? (0...maxsignificand).random()! : (0..<maxsignificand).random()!
        let pattern = exponentBitPattern + rand
        let exponent = pattern >> significandBitCount
        let significand = pattern & (maxsignificand - 1)
        return Self(sign: .plus, exponentBitPattern: numericCast(exponent), significandBitPattern: numericCast(significand)) - 1
    }
}

public extension Range where Bound : BinaryFloatingPoint, Bound.RawSignificand : FixedWidthInteger, Bound.RawSignificand.Stride : SignedInteger & FixedWidthInteger {
    
    @_inlineable
    public func random() -> Bound {
        let diff = upperBound - lowerBound
        return (Bound.random() * diff) + lowerBound
    }
}
public extension ClosedRange where Bound : BinaryFloatingPoint, Bound.RawSignificand : FixedWidthInteger, Bound.RawSignificand.Stride : SignedInteger & FixedWidthInteger {
    
    @_inlineable
    public func random() -> Bound {
        let diff = upperBound - lowerBound
        return (Bound.random(includeOne: true) * diff) + lowerBound
    }
}
@_inlineable
public func normal_distribution(mean: Double, variance: Double) -> Double {
    let u = 1 - Double.random(includeOne: false)
    let v = 1 - Double.random(includeOne: false)
    
    let r = -2 * log(u)
    let theta = 2 * Double.pi * v
    
    return sqrt(variance * r) * cos(theta) + mean
}
@_inlineable
public func normal_distribution(mean: Complex, variance: Double) -> Complex {
    let u = 1 - Double.random(includeOne: false)
    let v = 1 - Double.random(includeOne: false)
    
    let r = -2 * log(u)
    let theta = 2 * Double.pi * v
    
    return Complex(magnitude: sqrt(variance * r), phase: theta) + mean
}
