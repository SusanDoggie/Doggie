//
//  CubicBezier.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
public struct CubicBezier<Element : ScalarMultiplicative> : BezierProtocol where Element.Scalar == Double {
    
    public typealias Scalar = Double
    
    public var p0: Element
    public var p1: Element
    public var p2: Element
    public var p3: Element
    
    @inlinable
    @inline(__always)
    public init() {
        self.p0 = .zero
        self.p1 = .zero
        self.p2 = .zero
        self.p3 = .zero
    }
    
    @inlinable
    @inline(__always)
    public init(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
}

extension Bezier {
    
    @inlinable
    public init(_ bezier: CubicBezier<Element>) {
        self.init(bezier.p0, bezier.p1, bezier.p2, bezier.p3)
    }
}

extension CubicBezier : Hashable where Element : Hashable {
    
}

extension CubicBezier: Decodable where Element : Decodable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(try container.decode(Element.self),
                  try container.decode(Element.self),
                  try container.decode(Element.self),
                  try container.decode(Element.self))
    }
}

extension CubicBezier: Encodable where Element : Encodable {
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(p0)
        try container.encode(p1)
        try container.encode(p2)
        try container.encode(p3)
    }
}

extension CubicBezier {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Element) -> Element) -> CubicBezier {
        return CubicBezier(transform(p0), transform(p1), transform(p2), transform(p3))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, p0)
        updateAccumulatingResult(&accumulator, p1)
        updateAccumulatingResult(&accumulator, p2)
        updateAccumulatingResult(&accumulator, p3)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: CubicBezier, _ transform: (Element, Element) -> Element) -> CubicBezier {
        return CubicBezier(transform(p0, other.p0), transform(p1, other.p1), transform(p2, other.p2), transform(p3, other.p3))
    }
}

extension CubicBezier {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    @inlinable
    @inline(__always)
    public var startIndex: Int {
        return 0
    }
    @inlinable
    @inline(__always)
    public var endIndex: Int {
        return 4
    }
    
    @inlinable
    public subscript(position: Int) -> Element {
        get {
            switch position {
            case 0: return p0
            case 1: return p1
            case 2: return p2
            case 3: return p3
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: p0 = newValue
            case 1: p1 = newValue
            case 2: p2 = newValue
            case 3: p3 = newValue
            default: fatalError()
            }
        }
    }
}

extension CubicBezier {
    
    @inlinable
    public var start: Element {
        return p0
    }
    
    @inlinable
    public var end: Element {
        return p3
    }
    
    @inlinable
    public func eval(_ t: Double) -> Element {
        let t2 = t * t
        let _t = 1 - t
        let _t2 = _t * _t
        let a = _t * _t2 * p0
        let b = 3 * _t2 * t * p1
        let c = 3 * _t * t2 * p2
        let d = t * t2 * p3
        return a + b + c + d
    }
    
    @inlinable
    public func split(_ t: Double) -> (CubicBezier, CubicBezier) {
        let q0 = p0 + t * (p1 - p0)
        let q1 = p1 + t * (p2 - p1)
        let q2 = p2 + t * (p3 - p2)
        let u0 = q0 + t * (q1 - q0)
        let u1 = q1 + t * (q2 - q1)
        let v0 = u0 + t * (u1 - u0)
        return (CubicBezier(p0, q0, u0, v0), CubicBezier(v0, u1, q2, p3))
    }
    
    @inlinable
    public func elevated() -> Bezier<Element> {
        return Bezier(self).elevated()
    }
    
    @inlinable
    public func derivative() -> QuadBezier<Element> {
        let q0 = 3 * (p1 - p0)
        let q1 = 3 * (p2 - p1)
        let q2 = 3 * (p3 - p2)
        return QuadBezier(q0, q1, q2)
    }
}

extension CubicBezier where Element == Point {
    
    @inlinable
    public var x: CubicBezier<Double> {
        return CubicBezier<Double>(p0.x, p1.x, p2.x, p3.x)
    }
    
    @inlinable
    public var y: CubicBezier<Double> {
        return CubicBezier<Double>(p0.y, p1.y, p2.y, p3.y)
    }
}

extension CubicBezier where Element == Vector {
    
    @inlinable
    public var x: CubicBezier<Double> {
        return CubicBezier<Double>(p0.x, p1.x, p2.x, p3.x)
    }
    
    @inlinable
    public var y: CubicBezier<Double> {
        return CubicBezier<Double>(p0.y, p1.y, p2.y, p3.y)
    }
    
    @inlinable
    public var z: CubicBezier<Double> {
        return CubicBezier<Double>(p0.z, p1.z, p2.z, p3.z)
    }
}

extension CubicBezier {
    
    @inlinable
    public var _polynomial: (Element, Element, Element) {
        let b = 3 * (p1 - p0)
        var c = 3 * (p2 + p0)
        c -= 6 * p1
        let d = p3 - p0 + 3 * (p1 - p2)
        return (b, c, d)
    }
}

extension CubicBezier where Element == Double {
    
    @inlinable
    public var polynomial: Polynomial {
        let a = p0
        let (b, c, d) = _polynomial
        return [a, b, c, d]
    }
}

extension CubicBezier where Element : Tensor {
    
    @inlinable
    public func closest(_ point: Element, in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double] {
        let a = p0 - point
        let (b, c, d) = _polynomial
        var dot: Polynomial = []
        for i in 0..<Element.numberOfComponents {
            let p: Polynomial = [a[i], b[i], c[i], d[i]]
            dot += p * p
        }
        return dot.derivative.roots(in: range).sorted(by: { dot.eval($0) })
    }
}

extension CubicBezier where Element == Point {
    
    @inlinable
    public var area: Double {
        let a = p3.x - p0.x + 3 * (p1.x - p2.x)
        let b = 3 * (p2.x + p0.x) - 6 * p1.x
        let c = 3 * (p1.x - p0.x)
        
        let d = p3.y - p0.y + 3 * (p1.y - p2.y)
        let e = 3 * (p2.y + p0.y) - 6 * p1.y
        let f = 3 * (p1.y - p0.y)
        
        return 0.5 * (p0.x * p3.y - p3.x * p0.y) + 0.1 * (b * d - a * e) + 0.25 * (c * d - a * f) + (c * e - b * f) / 6
    }
}

extension CubicBezier where Element == Point {
    
    @inlinable
    public var inflection: Degree2Roots {
        let p = (p3 - p0).phase
        let _p1 = (p1 - p0) * SDTransform.rotate(-p)
        let _p2 = (p2 - p0) * SDTransform.rotate(-p)
        let _p3 = (p3 - p0) * SDTransform.rotate(-p)
        let a = _p2.x * _p1.y
        let b = _p3.x * _p1.y
        let c = _p1.x * _p2.y
        let d = _p3.x * _p2.y
        let x = 18 * (2 * b + 3 * (c - a) - d)
        let y = 18 * (3 * (a - c) - b)
        let z = 18 * (c - a)
        if x.almostZero() {
            return y.almostZero() ? Degree2Roots() : Degree2Roots(-z / y)
        }
        return degree2roots(y / x, z / x)
    }
    
    @inlinable
    public func curvature(_ t: Double) -> Double {
        let x = self.x.polynomial
        let y = self.y.polynomial
        return _bezier_curvature(x, y, t)
    }
    
    @inlinable
    public var stationary: [Double] {
        let x = self.x.polynomial
        let y = self.y.polynomial
        return _bezier_stationary(x, y)
    }
}

extension CubicBezier where Element == Double {
    
    @inlinable
    public var stationary: Degree2Roots {
        let _a = 3 * (p3 - p0) + 9 * (p1 - p2)
        let _b = 6 * (p2 + p0) - 12 * p1
        let _c = 3 * (p1 - p0)
        if _a.almostZero() {
            if _b.almostZero() {
                return Degree2Roots()
            }
            let t = -_c / _b
            return Degree2Roots(t)
        } else {
            let delta = _b * _b - 4 * _a * _c
            let _a2 = 2 * _a
            let _b2 = -_b / _a2
            if delta.sign == .plus {
                let sqrt_delta = sqrt(delta) / _a2
                let t1 = _b2 + sqrt_delta
                let t2 = _b2 - sqrt_delta
                return Degree2Roots(t1, t2)
            } else if delta.almostZero() {
                return Degree2Roots(_b2)
            }
        }
        return Degree2Roots()
    }
}

extension CubicBezier where Element == Point {
    
    @inlinable
    public var boundary: Rect {
        
        let bx = self.x
        let by = self.y
        
        let _x = bx.stationary.lazy.map { bx.eval($0.clamped(to: 0...1)) }
        let _y = by.stationary.lazy.map { by.eval($0.clamped(to: 0...1)) }
        
        let minX = _x.min().map { Swift.min(p0.x, p3.x, $0) } ?? Swift.min(p0.x, p3.x)
        let minY = _y.min().map { Swift.min(p0.y, p3.y, $0) } ?? Swift.min(p0.y, p3.y)
        let maxX = _x.max().map { Swift.max(p0.x, p3.x, $0) } ?? Swift.max(p0.x, p3.x)
        let maxY = _y.max().map { Swift.max(p0.y, p3.y, $0) } ?? Swift.max(p0.y, p3.y)
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension CubicBezier where Element == Point {
    
    @inlinable
    public func selfIntersect() -> (Double, Double)? {
        
        let (q1, q2, q3) = _polynomial
        
        let d1 = -cross(q3, q2)
        let d2 = cross(q3, q1)
        let d3 = -cross(q2, q1)
        
        let discr = 3 * d2 * d2 - 4 * d1 * d3
        
        if !d1.almostZero() && !discr.almostZero() && discr < 0 {
            
            let delta = sqrt(-discr)
            
            let s = 0.5 / d1
            let td = d2 + delta
            let te = d2 - delta
            
            return (td * s, te * s)
        }
        
        return nil
    }
    
    @inlinable
    func _intersect(_ other: LineSegment<Element>) -> Polynomial {
        
        let a = p0 - other.p0
        let (b, c, d) = _polynomial
        
        let u0: Polynomial = [a.x, b.x, c.x, d.x]
        let u1 = other.p0.x - other.p1.x
        
        let v0: Polynomial = [a.y, b.y, c.y, d.y]
        let v1 = other.p0.y - other.p1.y
        
        return u1 * v0 - u0 * v1
    }
    
    @inlinable
    func _intersect(_ other: QuadBezier<Element>) -> Polynomial {
        
        let a = p0 - other.p0
        let (b, c, d) = _polynomial
        
        let u0: Polynomial = [a.x, b.x, c.x, d.x]
        let u1 = 2 * (other.p0.x - other.p1.x)
        let u2 = 2 * other.p1.x - other.p0.x - other.p2.x
        
        let v0: Polynomial = [a.y, b.y, c.y, d.y]
        let v1 = 2 * (other.p0.y - other.p1.y)
        let v2 = 2 * other.p1.y - other.p0.y - other.p2.y
        
        // Bézout matrix
        let m00 = u2 * v1 - u1 * v2
        let m01 = u2 * v0 - u0 * v2
        let m10 = m01
        let m11 = u1 * v0 - u0 * v1
        
        return m00 * m11 - m01 * m10
    }
    
    @inlinable
    func _intersect(_ other: CubicBezier) -> Polynomial {
        
        let a = p0 - other.p0
        let (b, c, d) = _polynomial
        
        let u0: Polynomial = [a.x, b.x, c.x, d.x]
        let u1 = 3 * (other.p0.x - other.p1.x)
        let u2 = 6 * other.p1.x - 3 * (other.p2.x + other.p0.x)
        let u3 = other.p0.x - other.p3.x + 3 * (other.p2.x - other.p1.x)
        
        let v0: Polynomial = [a.y, b.y, c.y, d.y]
        let v1 = 3 * (other.p0.y - other.p1.y)
        let v2 = 6 * other.p1.y - 3 * (other.p2.y + other.p0.y)
        let v3 = other.p0.y - other.p3.y + 3 * (other.p2.y - other.p1.y)
        
        // Bézout matrix
        let m00 = u3 * v2 - u2 * v3
        let m01 = u3 * v1 - u1 * v3
        let m02 = u3 * v0 - u0 * v3
        let m10 = m01
        let m11 = u2 * v1 - u1 * v2 + m02
        let m12 = u2 * v0 - u0 * v2
        let m20 = m02
        let m21 = m12
        let m22 = u1 * v0 - u0 * v1
        
        let _a = m11 * m22 - m12 * m21
        let _b = m12 * m20 - m10 * m22
        let _c = m10 * m21 - m11 * m20
        let _d = m00 * _a
        let _e = m01 * _b
        let _f = m02 * _c
        
        return _d + _e + _f
    }
    @inlinable
    public func overlap(_ other: LineSegment<Element>, reference: Double = 0) -> Bool {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) }
    }
    
    @inlinable
    public func overlap(_ other: QuadBezier<Element>, reference: Double = 0) -> Bool {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) }
    }
    
    @inlinable
    public func overlap(_ other: CubicBezier, reference: Double = 0) -> Bool {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) }
    }
    
    @inlinable
    public func intersect(_ other: LineSegment<Element>, in range: ClosedRange<Double> = -.infinity ... .infinity, reference: Double = 0) -> [Double]? {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) } ? nil : det.roots(in: range)
    }
    
    @inlinable
    public func intersect(_ other: QuadBezier<Element>, in range: ClosedRange<Double> = -.infinity ... .infinity, reference: Double = 0) -> [Double]? {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) } ? nil : det.roots(in: range)
    }
    
    @inlinable
    public func intersect(_ other: CubicBezier, in range: ClosedRange<Double> = -.infinity ... .infinity, reference: Double = 0) -> [Double]? {
        let det = self._intersect(other)
        return det.allSatisfy { $0.almostZero(reference: reference) } ? nil : det.roots(in: range)
    }
}
