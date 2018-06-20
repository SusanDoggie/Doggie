//
//  BezierOffset.swift
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

@inline(__always)
private func QuadBezierFittingCurvature(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let u = p2 - p0
    let v = p1 - 0.5 * (p2 + p0)
    return u.magnitude < v.magnitude * 4
}
private func QuadBezierFitting(_ p: [Point], _ limit: Int, _ inflection_check: Bool) -> [[Point]] {
    
    if p.count < 4 {
        return [p]
    }
    
    let bezier = Bezier(p)
    
    if inflection_check {
        var t = bezier.inflection.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
        t.append(contentsOf: Bezier(p.map { $0.x }).stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
        t.append(contentsOf: Bezier(p.map { $0.y }).stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
        return bezier.split(t).flatMap { QuadBezierFitting($0.points, limit - 1, false) }
    }
    
    let d = zip(p.dropFirst(), p).map(-)
    
    func split(_ t: Double) -> [[Point]] {
        let (left, right) = bezier.split(t)
        return QuadBezierFitting(left.points, limit - 1, false) + QuadBezierFitting(right.points, limit - 1, false)
    }
    
    let start = p.first!
    let end = p.last!
    
    if limit > 0 && p.dropFirst().dropLast().contains(where: { QuadBezierFittingCurvature(start, $0, end) }) {
        return split(0.5)
    }
    
    let m0 = d.first { !$0.x.almostZero() || !$0.y.almostZero() }
    let m1 = d.last { !$0.x.almostZero() || !$0.y.almostZero() }
    
    if let m0 = m0, let m1 = m1 {
        if let mid = QuadBezierFitting(start, end, m0, m1) {
            if QuadBezierFittingCurvature(start, mid, end) {
                if limit > 0 {
                    return split(0.5)
                } else {
                    let u = Bezier(p).eval(0.5)
                    let v = 0.25 * (start + end)
                    return [[start, 2 * (u - v), end]]
                }
            }
            return [[start, mid, end]]
        }
    }
    return [[start, end]]
}
public func QuadBezierFitting(_ p: [Point]) -> [[Point]] {
    
    return QuadBezierFitting(p, 3, true)
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

@inline(__always)
private func BezierFitting(start: Double, end: Double, _ passing: [(Double, Double)]) -> [Double]? {
    
    let n = passing.count
    
    var matrix: [Double] = []
    matrix.reserveCapacity(n * (n + 1))
    
    let c = CombinationList(UInt(n + 1)).dropFirst().dropLast()
    for (t, p) in passing {
        let s = 1 - t
        let tn = pow(t, Double(n + 1))
        let sn = pow(s, Double(n + 1))
        let st = t / s
        let u = sequence(first: sn * st) { $0 * st }
        let v = zip(c, u).lazy.map { Double($0) * $1 }
        matrix.append(contentsOf: v.concat(CollectionOfOne(p - sn * start - tn * end)))
    }
    
    if MatrixElimination(n, &matrix) {
        let a: LazyMapSequence = matrix.lazy.slice(by: n + 1).map { $0.last! }
        let b = CollectionOfOne(start).concat(a).concat(CollectionOfOne(end))
        return Array(b)
    }
    
    return nil
}

public func BezierFitting(start: Double, end: Double, _ passing: (Double, Double) ...) -> [Double]? {
    
    return BezierFitting(start: start, end: end, passing)
}

public func BezierFitting(start: Point, end: Point, _ passing: (Double, Point) ...) -> [Point]? {
    
    let x = BezierFitting(start: start.x, end: end.x, passing.map { ($0, $1.x) })
    let y = BezierFitting(start: start.y, end: end.y, passing.map { ($0, $1.y) })
    if let x = x, let y = y {
        return zip(x, y).map { Point(x: $0, y: $1) }
    }
    return nil
}

public func BezierFitting(start: Vector, end: Vector, _ passing: (Double, Vector) ...) -> [Vector]? {
    
    let x = BezierFitting(start: start.x, end: end.x, passing.map { ($0, $1.x) })
    let y = BezierFitting(start: start.y, end: end.y, passing.map { ($0, $1.y) })
    let z = BezierFitting(start: start.z, end: end.z, passing.map { ($0, $1.z) })
    if let x = x, let y = y, let z = z {
        return zip(zip(x, y), z).map { Vector(x: $0.0, y: $0.1, z: $1) }
    }
    return nil
}

public func BezierOffset(_ p0: Point, _ p1: Point, _ a: Double) -> (Point, Point)? {
    if a.almostZero() {
        return (p0, p1)
    }
    let _x = p1.x - p0.x
    let _y = p1.y - p0.y
    if _x.almostZero() && _y.almostZero() {
        return nil
    }
    let _xy = sqrt(_x * _x + _y * _y)
    let s = a * _y / _xy
    let t = -a * _x / _xy
    return (p0 + Point(x: s, y: t), p1 + Point(x: s, y: t))
}

@inline(__always)
private func BezierOffsetCurvature(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let u = p2 - p0
    let v = p1 - 0.5 * (p2 + p0)
    return u.magnitude < v.magnitude * 3
}

public func BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double) -> [[Point]] {
    
    return _BezierOffset(p0, p1, p2, a, 3)
}
public func BezierOffset(_ p: [Point], _ a: Double) -> [[Point]] {
    
    var ph0: Double?
    
    return QuadBezierFitting(p).flatMap { points -> [[Point]] in
        
        var join: [[Point]]  = []
        let d = zip(points.dropFirst(), points).map(-)
        
        if let ph0 = ph0, let ph1 = d.first(where: { !$0.x.almostZero() || !$0.y.almostZero() })?.phase {
            let angle = (ph1 - ph0).remainder(dividingBy: 2 * Double.pi)
            if !angle.almostZero() {
                let rotate = SDTransform.rotate(ph0 - 0.5 * Double.pi)
                let offset = points[0]
                let bezierArc = BezierArc(angle).lazy.map { $0 * rotate * a + offset }
                for i in 0..<bezierArc.count / 3 {
                    join.append([bezierArc[i * 3], bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]])
                }
            }
        }
        ph0 = d.last { !$0.x.almostZero() || !$0.y.almostZero() }?.phase ?? ph0
        
        switch points.count {
        case 2: return BezierOffset(points[0], points[1], a).map { join + [[$0, $1]] } ?? join
        case 3: return join + _BezierOffset(points[0], points[1], points[2], a, 3)
        default: fatalError()
        }
    }
}
private func _BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double, _ limit: Int) -> [[Point]] {
    
    if a.almostZero() {
        return [[p0, p1, p2]]
    }
    
    let q0 = p1 - p0
    let q1 = p2 - p1
    
    if (q0.x.almostZero() && q0.y.almostZero()) || (q1.x.almostZero() && q1.y.almostZero()) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
    }
    let ph0 = q0.phase
    let ph1 = q1.phase
    
    if ph0.almostEqual(ph1) || ph0.almostEqual(ph1 + 2 * Double.pi) || ph0.almostEqual(ph1 - 2 * Double.pi) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
    }
    
    func split(_ t: Double) -> [[Point]] {
        let (left, right) = Bezier(p0, p1, p2).split(t)
        return _BezierOffset(left[0], left[1], left[2], a, limit - 1) + _BezierOffset(right[0], right[1], right[2], a, limit - 1)
    }
    
    if limit > 0 && BezierOffsetCurvature(p0, p1, p2) {
        return split(0.5)
    }
    
    let s = 1 / q0.magnitude
    let t = 1 / q1.magnitude
    let start = Point(x: p0.x + a * q0.y * s, y: p0.y - a * q0.x * s)
    let end = Point(x: p2.x + a * q1.y * t, y: p2.y - a * q1.x * t)
    
    if let mid = QuadBezierFitting(start, end, q0, q1) {
        if BezierOffsetCurvature(start, mid, end) {
            if limit > 0 {
                return split(0.5)
            } else {
                let m = Bezier(q0, q1).eval(0.5).unit
                let _mid = Bezier(p0, p1, p2).eval(0.5) + Point(x: a * m.y, y: -a * m.x)
                if let (lhs, rhs) = CubicBezierFitting(start, end, q0, -q1, [_mid]) {
                    let _lhs = start + abs(lhs) * q0
                    let _rhs = end - abs(rhs) * q1
                    return [[start, _lhs, _rhs, end]]
                }
                return [[start, 2 * (_mid - 0.25 * (start + end)), end]]
            }
        }
        return [[start, mid, end]]
    }
    
    return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
}
