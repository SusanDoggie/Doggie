//
//  CubicBezierTriangularPatch.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

@frozen
public struct CubicBezierTriangularPatch<Element: ScalarMultiplicative>: Equatable where Element.Scalar == Double {
    
    public var m300: Element
    public var m210: Element
    public var m120: Element
    public var m030: Element
    public var m201: Element
    public var m111: Element
    public var m021: Element
    public var m102: Element
    public var m012: Element
    public var m003: Element
    
    @inlinable
    @inline(__always)
    public init(_ m300: Element, _ m210: Element, _ m120: Element, _ m030: Element,
                _ m201: Element, _ m111: Element, _ m021: Element,
                _ m102: Element, _ m012: Element,
                _ m003: Element) {
        self.m300 = m300
        self.m210 = m210
        self.m120 = m120
        self.m030 = m030
        self.m201 = m201
        self.m111 = m111
        self.m021 = m021
        self.m102 = m102
        self.m012 = m012
        self.m003 = m003
    }
}

extension CubicBezierTriangularPatch: Hashable where Element: Hashable {
    
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension CubicBezierTriangularPatch: Sendable where Element: Sendable { }

extension CubicBezierTriangularPatch {
    
    @inlinable
    @inline(__always)
    public func eval(_ u: Double, _ v: Double) -> Element {
        
        let w = 1 - u - v
        
        let u2 = u * u
        let u3 = u2 * u
        let v2 = v * v
        let v3 = v2 * v
        let w2 = w * w
        let w3 = w2 * w
        
        let n300 = u3 * m300
        let n030 = v3 * m030
        let n003 = w3 * m003
        let n210 = 3 * u2 * v * m210
        let n201 = 3 * u2 * w * m201
        let n120 = 3 * u * v2 * m120
        let n021 = 3 * v2 * w * m021
        let n012 = 3 * v * w2 * m012
        let n102 = 3 * u * w2 * m102
        let n111 = 6 * u * v * w * m111
        
        return n300 + n030 + n003 + n210 + n201 + n120 + n021 + n012 + n102 + n111
    }
}

extension CubicBezierTriangularPatch where Element == Vector {
    
    @inlinable
    @inline(__always)
    public func normal(_ u: Double, _ v: Double) -> Element {
        
        let w = 1 - u - v
        
        let u2 = 3 * u * u
        let v2 = 3 * v * v
        let w2 = 3 * w * w
        let uv = 6 * u * v
        let uw = 6 * u * w
        let vw = 6 * v * w
        
        let s0 = u2 * (m300 - m201)
        let s1 = v2 * (m120 - m021)
        let s2 = w2 * (m102 - m003)
        let s3 = uv * (m210 - m111)
        let s4 = uw * (m201 - m102)
        let s5 = vw * (m111 - m012)
        
        let t0 = u2 * (m210 - m201)
        let t1 = v2 * (m030 - m021)
        let t2 = w2 * (m012 - m003)
        let t3 = uv * (m120 - m111)
        let t4 = uw * (m111 - m102)
        let t5 = vw * (m021 - m012)
        
        let s = s0 + s1 + s2 + s3 + s4 + s5
        let t = t0 + t1 + t2 + t3 + t4 + t5
        
        return cross(s, t)
    }
}

@inlinable
@inline(__always)
public func * (lhs: CubicBezierTriangularPatch<Point>, rhs: SDTransform) -> CubicBezierTriangularPatch<Point> {
    return CubicBezierTriangularPatch(lhs.m300 * rhs, lhs.m210 * rhs, lhs.m120 * rhs, lhs.m030 * rhs,
                                      lhs.m201 * rhs, lhs.m111 * rhs, lhs.m021 * rhs,
                                      lhs.m102 * rhs, lhs.m012 * rhs,
                                      lhs.m003 * rhs)
}
@inlinable
@inline(__always)
public func *= (lhs: inout CubicBezierTriangularPatch<Point>, rhs: SDTransform) {
    lhs = lhs * rhs
}
@inlinable
@inline(__always)
public func * (lhs: CubicBezierTriangularPatch<Vector>, rhs: Matrix) -> CubicBezierTriangularPatch<Vector> {
    return CubicBezierTriangularPatch(lhs.m300 * rhs, lhs.m210 * rhs, lhs.m120 * rhs, lhs.m030 * rhs,
                                      lhs.m201 * rhs, lhs.m111 * rhs, lhs.m021 * rhs,
                                      lhs.m102 * rhs, lhs.m012 * rhs,
                                      lhs.m003 * rhs)
}
@inlinable
@inline(__always)
public func *= (lhs: inout CubicBezierTriangularPatch<Vector>, rhs: Matrix) {
    lhs = lhs * rhs
}
