//
//  BezierOffset.swift
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

extension BezierProtocol where Scalar == Double, Element == Point {
    
    @inlinable
    public func _direction(_ t: Double) -> Point {
        if t.almostZero() {
            return self.derivative().first { !$0.almostZero() } ?? Point()
        }
        if t.almostEqual(1) {
            return self.derivative().last { !$0.almostZero() } ?? Point()
        }
        return self.derivative().eval(t)
    }
    
    @inlinable
    public func _offset_point(_ a: Double, _ t: Double) -> Point? {
        let q = self._direction(t).unit
        return q.almostZero() ? nil : self.eval(t).offset(dx: a * q.y, dy: -a * q.x)
    }
    
    @inlinable
    public func _closest(_ point: Point) -> [Double] {
        switch self {
        case let bezier as LineSegment<Point>: return bezier.closest(point)
        case let bezier as QuadBezier<Point>: return bezier.closest(point)
        case let bezier as CubicBezier<Point>: return bezier.closest(point)
        case let bezier as Bezier<Point>: return bezier.closest(point)
        default: return []
        }
    }
    
    @inlinable
    public func _curvature(_ t: Double) -> Double {
        switch self {
        case let bezier as QuadBezier<Point>: return bezier.curvature(t)
        case let bezier as CubicBezier<Point>: return bezier.curvature(t)
        case let bezier as Bezier<Point>: return bezier.curvature(t)
        default: return 0
        }
    }
    
    @inlinable
    public var _stationary: [Double] {
        switch self {
        case let bezier as QuadBezier<Point>: return bezier.stationary
        case let bezier as CubicBezier<Point>: return bezier.stationary
        case let bezier as Bezier<Point>: return bezier.stationary
        default: return []
        }
    }
}

extension BezierProtocol where Scalar == Double, Element == Point {
    
    @inlinable
    func _offset(_ a: Double, _ calback: (ClosedRange<Double>, CubicBezier<Point>) throws -> Void) rethrows {
        
        var s = 0.0
        
        for _t in 1...degree {
            
            let t = Double(_t) / Double(degree)
            
            let d0 = self._direction(s).unit
            let d3 = self._direction(t).unit
            
            guard !d0.almostZero() && !d3.almostZero() else { continue }
            
            let q0 = self.eval(s).offset(dx: a * d0.y, dy: -a * d0.x)
            let q3 = self.eval(t).offset(dx: a * d3.y, dy: -a * d3.x)
            
            guard let m0 = self._offset_point(a, 0.25 * (t - s) + s) else { continue }
            guard let m1 = self._offset_point(a, 0.5 * (t - s) + s) else { continue }
            guard let m2 = self._offset_point(a, 0.75 * (t - s) + s) else { continue }
            guard let (c0, c1) = CubicBezierFitting(q0, q3, d0, -d3, [(0.25, m0), (0.5, m1), (0.75, m2)]) else { continue }
            
            try calback(s...t, CubicBezier(q0, q0 + abs(c0) * d0, q3 - abs(c1) * d3, q3))
            
            s = t
        }
    }
    
    @inlinable
    func _offset2(_ a: Double, _ calback: (ClosedRange<Double>, CubicBezier<Point>) throws -> Void) rethrows {
        
        var s = 0.0
        
        for _t in 1...degree {
            
            let t = Double(_t) / Double(degree)
            
            let p0 = self.eval(s)
            let p3 = self.eval(t)
            
            guard let u = self._closest(0.5 * (p0 + p3)).first(where: { !$0.almostEqual(s) && !$0.almostEqual(t) && s...t ~= $0 }) else { continue }
            guard let m = self._offset_point(a, u) else { continue }
            
            let d0 = self._direction(s).unit
            let d3 = self._direction(t).unit
            
            guard !d0.almostZero() && !d3.almostZero() else { continue }
            
            let q0 = p0.offset(dx: a * d0.y, dy: -a * d0.x)
            let q3 = p3.offset(dx: a * d3.y, dy: -a * d3.x)
            
            guard let (c0, c1) = CubicBezierFitting(q0, q3, d0, -d3, [m]) else { continue }
            
            try calback(s...t, CubicBezier(q0, q0 + abs(c0) * d0, q3 - abs(c1) * d3, q3))
            
            s = t
        }
    }
    
    @inlinable
    public func offset(_ a: Double, _ calback: (ClosedRange<Double>, CubicBezier<Point>) throws -> Void) rethrows {
        
        let t = self._stationary.flatMap { abs(self._curvature($0)) > 0.05 ? [$0, $0 - 0.025, $0 + 0.025] : [$0] }.sorted()
            .filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
        
        for ((s, t), segment) in zip(zip(CollectionOfOne(0).concat(t), t.appended(1)), self.split(t)) where !s.almostEqual(t) {
            let c = t - s
            if c > 0.05 {
                try segment._offset(a) { try calback($0.lowerBound * c + s ... $0.upperBound * c + s, $1) }
            } else {
                try segment._offset2(a) { try calback($0.lowerBound * c + s ... $0.upperBound * c + s, $1) }
            }
        }
    }
    
    @inlinable
    public func offset(_ a: Double) -> [(ClosedRange<Double>, CubicBezier<Point>)] {
        var result: [(ClosedRange<Double>, CubicBezier<Point>)] = []
        self.offset(a) { result.append(($0, $1)) }
        return result
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    public func offset(_ a: Double) -> LineSegment<Point>? {
        
        if a.almostZero() {
            return self
        }
        
        let _x = p1.x - p0.x
        let _y = p1.y - p0.y
        
        if _x.almostZero() && _y.almostZero() {
            return nil
        }
        
        let m = 1 / sqrt(_x * _x + _y * _y)
        let s = a * _y * m
        let t = -a * _x * m
        
        return LineSegment(p0 + Point(x: s, y: t), p1 + Point(x: s, y: t))
    }
}

public func QuadBezierFitting(_ p0: Point, _ p2: Point, _ m0: Point, _ m2: Point) -> Point? {
    let a = p2.x - p0.x
    let b = p2.y - p0.y
    let c = m0.x * m2.y - m0.y * m2.x
    if c == 0 {
        return nil
    }
    let d = a * m2.y - b * m2.x
    return p0 + m0 * d / c
}

public func CubicBezierFitting(_ p0: Point, _ p3: Point, _ m0: Point, _ m1: Point, _ points: [(Double, Point)]) -> (Double, Double)? {
    
    var _a1 = 0.0
    var _b1 = 0.0
    var _c1 = 0.0
    var _a2 = 0.0
    var _b2 = 0.0
    var _c2 = 0.0
    
    for (t, p) in points {
        
        let t2 = t * t
        let t3 = t2 * t
        
        let _t = 1 - t
        let _t2 = _t * _t
        let _t3 = _t2 * _t
        
        let t_t2 = 3 * _t2 * t
        let t2_t = 3 * _t * t2
        
        let _a = t_t2 * m0
        let _b = t2_t * m1
        let _c0 = (_t3 + t_t2) * p0
        let _c3 = (t3 + t2_t) * p3
        let _c = _c0 + _c3 - p
        
        _a1 += dot(_a, _a)
        _b1 += dot(_a, _b)
        _c1 += dot(_a, _c)
        
        _a2 += dot(_b, _a)
        _b2 += dot(_b, _b)
        _c2 += dot(_b, _c)
    }
    
    let t = _a1 * _b2 - _b1 * _a2
    
    if t.almostZero() {
        return nil
    }
    
    let _t = 1 / t
    
    let u = (_c2 * _b1 - _c1 * _b2) * _t
    let v = (_c1 * _a2 - _c2 * _a1) * _t
    
    return (u, v)
}

public func CubicBezierFitting(_ p0: Point, _ p3: Point, _ m0: Point, _ m1: Point, _ points: [Point]) -> (Double, Double)? {
    
    let ds = zip(CollectionOfOne(p0).concat(points), points).map { $0.distance(to: $1) }
    let dt = zip(points, points.dropFirst().concat(CollectionOfOne(p3))).map { $0.distance(to: $1) }
    return CubicBezierFitting(p0, p3, m0, m1, Array(zip(zip(ds, dt).map { $0 / ($0 + $1) }, points)))
}
