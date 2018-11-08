//
//  CubicBezierPatch.swift
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

public struct CubicBezierPatch<Element : ScalarMultiplicative> : Equatable where Element.Scalar == Double {
    
    public var m00: Element
    public var m01: Element
    public var m02: Element
    public var m03: Element
    public var m10: Element
    public var m11: Element
    public var m12: Element
    public var m13: Element
    public var m20: Element
    public var m21: Element
    public var m22: Element
    public var m23: Element
    public var m30: Element
    public var m31: Element
    public var m32: Element
    public var m33: Element
    
    @inlinable
    @inline(__always)
    public init(coonsPatch m00: Element, _ m01: Element, _ m02: Element, _ m03: Element,
                _ m10: Element, _ m13: Element, _ m20: Element, _ m23: Element,
                _ m30: Element, _ m31: Element, _ m32: Element, _ m33: Element) {
        
        @inline(__always)
        func _eval(_ a: Element, _ b: Element, _ c: Element, _ d: Element, _ e: Element) -> Element {
            let _a = 6 * a
            let _b = 3 * b
            let _c = 2 * c
            let _d = 4 * d
            return (_a + _b - _c - _d - e) / 9
        }
        
        self.m00 = m00
        self.m01 = m01
        self.m02 = m02
        self.m03 = m03
        self.m10 = m10
        self.m11 = _eval(m01 + m10, m31 + m13, m03 + m30, m00, m33)
        self.m12 = _eval(m02 + m13, m32 + m10, m00 + m33, m03, m30)
        self.m13 = m13
        self.m20 = m20
        self.m21 = _eval(m31 + m20, m01 + m23, m33 + m00, m30, m03)
        self.m22 = _eval(m32 + m23, m02 + m20, m30 + m03, m33, m00)
        self.m23 = m23
        self.m30 = m30
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
    }
    
    @inlinable
    @inline(__always)
    public init(_ m00: Element, _ m01: Element, _ m02: Element, _ m03: Element,
                _ m10: Element, _ m11: Element, _ m12: Element, _ m13: Element,
                _ m20: Element, _ m21: Element, _ m22: Element, _ m23: Element,
                _ m30: Element, _ m31: Element, _ m32: Element, _ m33: Element) {
        self.m00 = m00
        self.m01 = m01
        self.m02 = m02
        self.m03 = m03
        self.m10 = m10
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m20 = m20
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m30 = m30
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
    }
}

extension CubicBezierPatch : Hashable where Element : Hashable {
    
}

extension CubicBezierPatch {
    
    @inlinable
    @inline(__always)
    public func eval(_ u: Double, _ v: Double) -> Element {
        let u0 = CubicBezier(m00, m01, m02, m03).eval(u)
        let u1 = CubicBezier(m10, m11, m12, m13).eval(u)
        let u2 = CubicBezier(m20, m21, m22, m23).eval(u)
        let u3 = CubicBezier(m30, m31, m32, m33).eval(u)
        return CubicBezier(u0, u1, u2, u3).eval(v)
    }
}

extension CubicBezierPatch where Element == Vector {
    
    @inlinable
    @inline(__always)
    public func normal(_ u: Double, _ v: Double) -> Element {
        
        let s0 = CubicBezier(m00, m10, m20, m30).eval(v)
        let s1 = CubicBezier(m01, m11, m21, m31).eval(v)
        let s2 = CubicBezier(m02, m12, m22, m32).eval(v)
        let s3 = CubicBezier(m03, m13, m23, m33).eval(v)
        let t0 = CubicBezier(m00, m01, m02, m03).eval(u)
        let t1 = CubicBezier(m10, m11, m12, m13).eval(u)
        let t2 = CubicBezier(m20, m21, m22, m23).eval(u)
        let t3 = CubicBezier(m30, m31, m32, m33).eval(u)
        
        return cross(CubicBezier(s0, s1, s2, s3).derivative().eval(u), CubicBezier(t0, t1, t2, t3).derivative().eval(v))
    }
}

extension CubicBezierPatch {
    
    @inlinable
    @inline(__always)
    public func split(_ u: Double, _ v: Double) -> (CubicBezierPatch, CubicBezierPatch, CubicBezierPatch, CubicBezierPatch) {
        
        let (m0, n0) = CubicBezier(m00, m01, m02, m03).split(u)
        let (m1, n1) = CubicBezier(m10, m11, m12, m13).split(u)
        let (m2, n2) = CubicBezier(m20, m21, m22, m23).split(u)
        let (m3, n3) = CubicBezier(m30, m31, m32, m33).split(u)
        
        let (s0, u0) = CubicBezier(m0.p0, m1.p0, m2.p0, m3.p0).split(v)
        let (s1, u1) = CubicBezier(m0.p1, m1.p1, m2.p1, m3.p1).split(v)
        let (s2, u2) = CubicBezier(m0.p2, m1.p2, m2.p2, m3.p2).split(v)
        let (s3, u3) = CubicBezier(m0.p3, m1.p3, m2.p3, m3.p3).split(v)
        
        let (t0, v0) = CubicBezier(n0.p0, n1.p0, n2.p0, n3.p0).split(v)
        let (t1, v1) = CubicBezier(n0.p1, n1.p1, n2.p1, n3.p1).split(v)
        let (t2, v2) = CubicBezier(n0.p2, n1.p2, n2.p2, n3.p2).split(v)
        let (t3, v3) = CubicBezier(n0.p3, n1.p3, n2.p3, n3.p3).split(v)
        
        let p0 = CubicBezierPatch(s0.p0, s1.p0, s2.p0, s3.p0,
                                  s0.p1, s1.p1, s2.p1, s3.p1,
                                  s0.p2, s1.p2, s2.p2, s3.p2,
                                  s0.p3, s1.p3, s2.p3, s3.p3)
        
        let p1 = CubicBezierPatch(t0.p0, t1.p0, t2.p0, t3.p0,
                                  t0.p1, t1.p1, t2.p1, t3.p1,
                                  t0.p2, t1.p2, t2.p2, t3.p2,
                                  t0.p3, t1.p3, t2.p3, t3.p3)
        
        let p2 = CubicBezierPatch(u0.p0, u1.p0, u2.p0, u3.p0,
                                  u0.p1, u1.p1, u2.p1, u3.p1,
                                  u0.p2, u1.p2, u2.p2, u3.p2,
                                  u0.p3, u1.p3, u2.p3, u3.p3)
        
        let p3 = CubicBezierPatch(v0.p0, v1.p0, v2.p0, v3.p0,
                                  v0.p1, v1.p1, v2.p1, v3.p1,
                                  v0.p2, v1.p2, v2.p2, v3.p2,
                                  v0.p3, v1.p3, v2.p3, v3.p3)
        
        return (p0, p1, p2, p3)
    }
}

extension CubicBezierPatch where Element == Point {
    
    @inlinable
    public func warping(_ bezier: Bezier<Point>) -> [Bezier<Point>] {
        
        let u = Bezier(bezier.points.map { $0.x }).polynomial
        let v = Bezier(bezier.points.map { $0.y }).polynomial
        let u2 = u * u
        let v2 = v * v
        let u3 = u2 * u
        let v3 = v2 * v
        
        let _u = 1 - u
        let _v = 1 - v
        let _u2 = _u * _u
        let _v2 = _v * _v
        let _u3 = _u2 * _u
        let _v3 = _v2 * _v
        
        let u_u2 = 3 * _u2 * u
        let u2_u = 3 * _u * u2
        let v_v2 = 3 * _v2 * v
        let v2_v = 3 * _v * v2
        
        var c0x = _u3 * m00.x + u_u2 * m01.x
        c0x += u2_u * m02.x + u3 * m03.x
        var c0y = _u3 * m00.y + u_u2 * m01.y
        c0y += u2_u * m02.y + u3 * m03.y
        var c1x = _u3 * m10.x + u_u2 * m11.x
        c1x += u2_u * m12.x + u3 * m13.x
        var c1y = _u3 * m10.y + u_u2 * m11.y
        c1y += u2_u * m12.y + u3 * m13.y
        var c2x = _u3 * m20.x + u_u2 * m21.x
        c2x += u2_u * m22.x + u3 * m23.x
        var c2y = _u3 * m20.y + u_u2 * m21.y
        c2y += u2_u * m22.y + u3 * m23.y
        var c3x = _u3 * m30.x + u_u2 * m31.x
        c3x += u2_u * m32.x + u3 * m33.x
        var c3y = _u3 * m30.y + u_u2 * m31.y
        c3y += u2_u * m32.y + u3 * m33.y
        
        var _x = _v3 * c0x + v_v2 * c1x + v2_v * c2x + v3 * c3x
        var _y = _v3 * c0y + v_v2 * c1y + v2_v * c2y + v3 * c3y
        
        while _x.last?.almostZero() == true {
            _x.removeLast()
        }
        while _y.last?.almostZero() == true {
            _y.removeLast()
        }
        
        var x = Bezier(_x)
        var y = Bezier(_y)
        
        let degree = max(x.degree, y.degree)
        
        while x.degree != degree {
            x = x.elevated()
        }
        while y.degree != degree {
            y = y.elevated()
        }
        
        let points = zip(x, y).map { Point(x: $0, y: $1) }
        
        switch degree {
        case 1, 2, 3: return [Bezier(points)]
        default: return QuadBezierFitting(points).map(Bezier.init)
        }
    }
}

@inlinable
@inline(__always)
public func * (lhs: CubicBezierPatch<Point>, rhs: SDTransform) -> CubicBezierPatch<Point> {
    return CubicBezierPatch(lhs.m00 * rhs, lhs.m01 * rhs, lhs.m02 * rhs, lhs.m03 * rhs,
                            lhs.m10 * rhs, lhs.m11 * rhs, lhs.m12 * rhs, lhs.m13 * rhs,
                            lhs.m20 * rhs, lhs.m21 * rhs, lhs.m22 * rhs, lhs.m23 * rhs,
                            lhs.m30 * rhs, lhs.m31 * rhs, lhs.m32 * rhs, lhs.m33 * rhs)
}
@inlinable
@inline(__always)
public func *= (lhs: inout CubicBezierPatch<Point>, rhs: SDTransform) {
    lhs = lhs * rhs
}
@inlinable
@inline(__always)
public func * (lhs: CubicBezierPatch<Vector>, rhs: Matrix) -> CubicBezierPatch<Vector> {
    return CubicBezierPatch(lhs.m00 * rhs, lhs.m01 * rhs, lhs.m02 * rhs, lhs.m03 * rhs,
                            lhs.m10 * rhs, lhs.m11 * rhs, lhs.m12 * rhs, lhs.m13 * rhs,
                            lhs.m20 * rhs, lhs.m21 * rhs, lhs.m22 * rhs, lhs.m23 * rhs,
                            lhs.m30 * rhs, lhs.m31 * rhs, lhs.m32 * rhs, lhs.m33 * rhs)
}
@inlinable
@inline(__always)
public func *= (lhs: inout CubicBezierPatch<Vector>, rhs: Matrix) {
    lhs = lhs * rhs
}
