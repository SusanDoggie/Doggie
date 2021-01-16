//
//  MathsExtension.swift
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

extension Int8: Multiplicative {
    
}

extension Int16: Multiplicative {
    
}

extension Int32: Multiplicative {
    
}

extension Int64: Multiplicative {
    
}

extension Int: Multiplicative {
    
}

#if !os(macOS) && !targetEnvironment(macCatalyst)

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: ScalarProtocol {
    
    public typealias Scalar = Float16
    
}

#endif

extension float16: ScalarProtocol {
    
    public typealias Scalar = float16
    
}

extension Float: ScalarProtocol {
    
    public typealias Scalar = Float
    
}

extension Double: ScalarProtocol {
    
    public typealias Scalar = Double
    
}

extension CGFloat: ScalarProtocol {
    
    public typealias Scalar = CGFloat
    
}

extension Complex {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.real.almostZero(epsilon: epsilon, reference: reference) && self.imag.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Complex, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.real.almostEqual(other.real, epsilon: epsilon) && self.imag.almostEqual(other.imag, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Complex, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.real.almostEqual(other.real, epsilon: epsilon, reference: reference) && self.imag.almostEqual(other.imag, epsilon: epsilon, reference: reference)
    }
}

extension Polynomial {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.allSatisfy { $0.almostZero(epsilon: epsilon, reference: reference) }
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Polynomial, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return (0..<Swift.max(self.count, other.count)).allSatisfy { self[$0].almostEqual(other[$0], epsilon: epsilon) }
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Polynomial, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return (0..<Swift.max(self.count, other.count)).allSatisfy { self[$0].almostEqual(other[$0], epsilon: epsilon, reference: reference) }
    }
}
