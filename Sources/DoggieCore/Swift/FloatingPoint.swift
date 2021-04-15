//
//  FloatingPoint.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@_transparent
public func positive_mod<T: FloatingPoint>(_ x: T, _ m: T) -> T {
    let r = x.truncatingRemainder(dividingBy: m)
    return r < 0 ? r + m : r
}

extension FloatingPoint {
    
    @_transparent
    public func almostZero(epsilon: Self = Self.ulpOfOne.squareRoot(), reference: Self = 0) -> Bool {
        if self == 0 { return true }
        return self.isFinite && abs(self) < abs(epsilon) * max(1, abs(reference))
    }
    
    @_transparent
    public func almostEqual(_ other: Self, epsilon: Self = Self.ulpOfOne.squareRoot()) -> Bool {
        return self == other || abs(self - other).almostZero(epsilon: epsilon, reference: self)
    }
    
    @_transparent
    public func almostEqual(_ other: Self, epsilon: Self = Self.ulpOfOne.squareRoot(), reference: Self) -> Bool {
        return self == other || abs(self - other).almostZero(epsilon: epsilon, reference: reference)
    }
}

extension BinaryFloatingPoint where Self: RawBitPattern {
    
    @_transparent
    public init(bigEndian value: Self) {
        self.init(bitPattern: BitPattern(bigEndian: value.bitPattern))
    }
    
    @_transparent
    public init(littleEndian value: Self) {
        self.init(bitPattern: BitPattern(littleEndian: value.bitPattern))
    }
}
