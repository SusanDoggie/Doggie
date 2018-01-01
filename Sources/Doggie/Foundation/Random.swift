//
//  Random.swift
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

import Foundation

public func random_uniform<T : FixedWidthInteger>(_ bound: T) -> T {
    let fd = open("/dev/urandom", O_RDONLY)
    defer { close(fd) }
    var _rand: T = 0
    withUnsafeMutableBytes(of: &_rand) { _ = Foundation.read(fd, $0.baseAddress, T.bitWidth) }
    _rand &= T.max
    if bound.isPower2 {
        _rand &= bound &- 1
    } else {
        let limit = T.max - T.max % bound
        while _rand >= limit {
            withUnsafeMutableBytes(of: &_rand) { _ = Foundation.read(fd, $0.baseAddress, T.bitWidth) }
            _rand &= T.max
        }
        _rand %= bound
    }
    return _rand
}

extension BinaryFloatingPoint where RawSignificand : FixedWidthInteger, RawSignificand.Stride : SignedInteger & FixedWidthInteger {
    
    @_inlineable
    public static func random(includeOne: Bool = false) -> Self {
        let exponentBitPattern = RawSignificand((1 as Self).exponentBitPattern) << significandBitCount
        let maxsignificand: RawSignificand = 1 << significandBitCount
        let rand = includeOne ? (0...maxsignificand).random()! : (0..<maxsignificand).random()!
        let pattern = exponentBitPattern + rand
        let exponent = pattern >> significandBitCount
        let significand = pattern & (maxsignificand - 1)
        return Self(sign: .plus, exponentBitPattern: RawExponent(exponent), significandBitPattern: RawSignificand(significand)) - 1
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

extension RandomAccessCollection where IndexDistance : FixedWidthInteger {
    
    /// Returns a random element in `self` or `nil` if the sequence is empty.
    ///
    /// - complexity: O(1).
    @_inlineable
    public func random() -> Element? {
        switch count {
        case 0: return nil
        case 1: return self[self.startIndex]
        default: return self[self.index(self.startIndex, offsetBy: random_uniform(count))]
        }
    }
}

extension MutableCollection where Self : RandomAccessCollection, IndexDistance : FixedWidthInteger {
    
    /// Shuffle `self` in-place.
    @_inlineable
    public mutating func shuffle() {
        for i in self.indices.dropLast() {
            swapAt(i, self.indices.suffix(from: i).random()!)
        }
    }
}
extension Sequence {
    
    /// Return an `Array` containing the shuffled elements of `self`.
    @_inlineable
    public func shuffled() -> [Element] {
        var list = ContiguousArray(self)
        list.shuffle()
        return Array(list)
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
