//
//  Random.swift
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

public func sec_random(_ buffer: UnsafeMutableRawPointer, size: Int) {
    let buffer = buffer.assumingMemoryBound(to: UInt8.self)
    let rand_file = open("/dev/random", O_RDONLY)
    var read_bytes = 0
    while read_bytes < size {
        let r = read(rand_file, buffer + read_bytes, size - read_bytes)
        if r > 0 {
            read_bytes += r
        }
    }
    close(rand_file)
}

public func sec_random_uniform(_ bound: UIntMax) -> UIntMax {
    let RANDMAX: UIntMax = ~0
    var _rand: UIntMax = 0
    sec_random(&_rand, size: MemoryLayout<UIntMax>.size)
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            sec_random(&_rand, size: MemoryLayout<UIntMax>.size)
        }
        _rand %= bound
    }
    return _rand
}

public func random_uniform(_ bound: UIntMax) -> UIntMax {
    let RANDMAX: UIntMax = ~0
    var _rand: UIntMax = 0
    arc4random_buf(&_rand, MemoryLayout<UIntMax>.size)
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = RANDMAX - RANDMAX % bound
        while _rand >= limit {
            arc4random_buf(&_rand, MemoryLayout<UIntMax>.size)
        }
        _rand %= bound
    }
    return _rand
}

public extension BinaryFloatingPoint {
    
    static func random(includeOne: Bool = false) -> Self {
        let significandBitCount: UIntMax = numericCast(Self.significandBitCount)
        let exponentBitPattern = numericCast((1 as Self).exponentBitPattern) << significandBitCount
        let maxsignificand = 1 << significandBitCount
        let rand = includeOne ? (0...maxsignificand).random()! : (0..<maxsignificand).random()!
        let pattern = exponentBitPattern + rand
        let exponent = pattern >> significandBitCount
        let significand = pattern & (maxsignificand - 1)
        return Self(sign: .plus, exponentBitPattern: numericCast(exponent), significandBitPattern: numericCast(significand)) - 1
    }
}

public func normal_distribution(mean: Double, variance: Double) -> Double {
    let u = 1 - Double.random(includeOne: false)
    let v = 1 - Double.random(includeOne: false)
    
    let r = -2 * log(u)
    let theta = 2 * M_PI * v
    
    return sqrt(variance * r) * cos(theta) + mean
}
public func normal_distribution(mean: Complex, variance: Double) -> Complex {
    let u = 1 - Double.random(includeOne: false)
    let v = 1 - Double.random(includeOne: false)
    
    let r = -2 * log(u)
    let theta = 2 * M_PI * v
    
    return Complex(magnitude: sqrt(variance * r), phase: theta) + mean
}
