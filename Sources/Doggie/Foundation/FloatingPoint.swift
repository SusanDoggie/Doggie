//
//  FloatingPoint.swift
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

public func positive_mod<T: FloatingPoint>(_ x: T, _ m: T) -> T {
    let r = x.remainder(dividingBy: m)
    return r < 0 ? r + m : r
}

extension FloatingPoint {
    
    private static var defaultAlmostEqualEpsilon: Self {
        return Self(sign: .plus, exponent: Self.ulpOfOne.exponent / 2, significand: 1)
    }
    
    public func almostZero(epsilon: Self = Self.defaultAlmostEqualEpsilon, reference: Self = 0) -> Bool {
        return self == 0 || abs(self) < abs(epsilon) * max(1, abs(reference))
    }
    
    public func almostEqual(_ other: Self, epsilon: Self = Self.defaultAlmostEqualEpsilon) -> Bool {
        return self == other || abs(self - other).almostZero(epsilon: epsilon, reference: self)
    }
}
