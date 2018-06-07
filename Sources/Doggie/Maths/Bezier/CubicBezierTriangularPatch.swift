//
//  CubicBezierTriangularPatch.swift
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

public struct CubicBezierTriangularPatch<Element : ScalarMultiplicative> : Equatable where Element.Scalar == Double {
    
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

extension CubicBezierTriangularPatch {
    
    @inlinable
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

extension CubicBezierTriangularPatch {
    
    @inlinable
    func _split(_ p0: Element, _ p1: Element) -> ((Element, Element), (Element, Element)) {
        let q0 = 0.5 * (p0 + p1)
        return ((p0, q0), (q0, p1))
    }
    
    @inlinable
    func _split(_ p0: Element, _ p1: Element, _ p2: Element) -> ((Element, Element, Element), (Element, Element, Element)) {
        let q0 = 0.5 * (p0 + p1)
        let q1 = 0.5 * (p1 + p2)
        let u0 = 0.5 * (q0 + q1)
        return ((p0, q0, u0), (u0, q1, p2))
    }
    
    @inlinable
    func _split(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element) -> ((Element, Element, Element, Element), (Element, Element, Element, Element)) {
        let q0 = 0.5 * (p0 + p1)
        let q1 = 0.5 * (p1 + p2)
        let q2 = 0.5 * (p2 + p3)
        let u0 = 0.5 * (q0 + q1)
        let u1 = 0.5 * (q1 + q2)
        let v0 = 0.5 * (u0 + u1)
        return ((p0, q0, u0, v0), (v0, u1, q2, p3))
    }
    
    @inlinable
    func _halving(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element,
                  _ p4: Element, _ p5: Element, _ p6: Element,
                  _ p7: Element, _ p8: Element,
                  _ p9: Element) -> (CubicBezierTriangularPatch, CubicBezierTriangularPatch) {
        let ((s0, s1, s2, s3), (t0, t1, t2, t3)) = _split(p0, p1, p2, p3)
        let ((s4, s5, s6), (t4, t5, t6)) = _split(p4, p5, p6)
        let ((s7, s8), (t7, t8)) = _split(p7, p8)
        return (CubicBezierTriangularPatch(s0, s1, s2, s3,
                                           s4, s5, s6,
                                           s7, s8,
                                           p9),
                CubicBezierTriangularPatch(t0, t1, t2, t3,
                                           t4, t5, t6,
                                           t7, t8,
                                           p9))
    }
    
    @inlinable
    public func halving1() -> (CubicBezierTriangularPatch, CubicBezierTriangularPatch) {
        
        return _halving(m030, m021, m012, m003,
                        m120, m111, m102,
                        m210, m201,
                        m300)
    }
    
    @inlinable
    public func halving2() -> (CubicBezierTriangularPatch, CubicBezierTriangularPatch) {
        
        return _halving(m003, m102, m201, m300,
                        m012, m111, m210,
                        m021, m120,
                        m030)
    }
    
    @inlinable
    public func halving3() -> (CubicBezierTriangularPatch, CubicBezierTriangularPatch) {
        
        return _halving(m300, m210, m120, m030,
                        m201, m111, m021,
                        m102, m012,
                        m003)
    }
}

extension CubicBezierTriangularPatch where Element: Tensor {
    
    @inlinable
    func _distance(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element) -> Double {
        return p0.distance(to: p1) + p1.distance(to: p2) + p2.distance(to: p3)
    }
    
    @inlinable
    public func halving() -> (CubicBezierTriangularPatch, CubicBezierTriangularPatch) {
        
        let d1 = _distance(m030, m021, m012, m003)
        let d2 = _distance(m003, m102, m201, m300)
        let d3 = _distance(m300, m210, m120, m030)
        
        if d1 < d2 {
            if d2 < d3 {
                return halving3()
            } else {
                return halving2()
            }
        } else if d1 < d3 {
            return halving3()
        } else {
            return halving1()
        }
    }
}

@inlinable
public func * (lhs: CubicBezierTriangularPatch<Point>, rhs: SDTransform) -> CubicBezierTriangularPatch<Point> {
    return CubicBezierTriangularPatch(lhs.m300 * rhs, lhs.m210 * rhs, lhs.m120 * rhs, lhs.m030 * rhs,
                                      lhs.m201 * rhs, lhs.m111 * rhs, lhs.m021 * rhs,
                                      lhs.m102 * rhs, lhs.m012 * rhs,
                                      lhs.m003 * rhs)
}
@inlinable
public func *= (lhs: inout CubicBezierTriangularPatch<Point>, rhs: SDTransform) {
    lhs = lhs * rhs
}
@inlinable
public func * (lhs: CubicBezierTriangularPatch<Vector>, rhs: Matrix) -> CubicBezierTriangularPatch<Vector> {
    return CubicBezierTriangularPatch(lhs.m300 * rhs, lhs.m210 * rhs, lhs.m120 * rhs, lhs.m030 * rhs,
                                      lhs.m201 * rhs, lhs.m111 * rhs, lhs.m021 * rhs,
                                      lhs.m102 * rhs, lhs.m012 * rhs,
                                      lhs.m003 * rhs)
}
@inlinable
public func *= (lhs: inout CubicBezierTriangularPatch<Vector>, rhs: Matrix) {
    lhs = lhs * rhs
}
