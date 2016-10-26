//
//  Geometry.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

// MARK: Ellipse

public struct Radius {
    
    public var x: Double
    public var y: Double
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Radius: CustomStringConvertible {
    public var description: String {
        return "{x: \(x), y: \(y)}"
    }
}

extension Radius: Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, x, y)
    }
}

public func == (lhs: Radius, rhs: Radius) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func != (lhs: Radius, rhs: Radius) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}

public func Ellipse(_ t: Double, _ p: Point, _ r: Radius) -> Point {
    return Point(x: r.x * cos(t) + p.x, y: r.y * sin(t) + p.y)
}

public func EllipseRadius(_ p0: Point, _ p1: Point, _ r: Radius, _ rotate: Double) -> Radius {
    let _p = p1 - p0
    let _tx = _p.x * cos(rotate) + _p.y * sin(rotate)
    let _ty = _p.y * cos(rotate) - _p.x * sin(rotate)
    let _atan = atan2(_ty / r.y, _tx / r.x)
    return Radius(x: _tx / (2 * cos(_atan)), y: _ty / (2 * sin(_atan)))
}

public func EllipseCenter(_ r: Radius, _ rotate: Double, _ a: Point, _ b: Point) -> [Point] {
    
    let _sin = sin(rotate)
    let _cos = cos(rotate)
    
    let ax = a.x * _cos + a.y * _sin
    let ay = a.y * _cos - a.x * _sin
    let bx = b.x * _cos + b.y * _sin
    let by = b.y * _cos - b.x * _sin
    
    let dx = (ax - bx) / r.x
    let dy = (ay - by) / r.y
    let d = dx * dx + dy * dy
    
    let _x = 0.5 * (ax + bx)
    let _y = 0.5 * (ay + by)
    
    if d == 4 {
        return [Point(x: _x * _cos - _y * _sin, y: _x * _sin + _y * _cos)]
    } else if d < 4 {
        let _t = sqrt((1 - d * 0.25) / d)
        
        let cx1 = _x + _t * dy * r.x
        let cy1 = _y - _t * dx * r.y
        let cx2 = _x - _t * dy * r.x
        let cy2 = _y + _t * dx * r.y
        
        return [Point(x: cx1 * _cos - cy1 * _sin, y: cx1 * _sin + cy1 * _cos),
            Point(x: cx2 * _cos - cy2 * _sin, y: cx2 * _sin + cy2 * _cos)]
    }
    
    return []
}

///
/// :param: rx radius of ellipse in x-axis
/// :param: ry radius of ellipse in y-axis
///
/// :param: a value of 'a' in matrix if parallel to x-axis or value of 'd' in matrix if parallel to y-axis.
/// :param: b value of 'b' in matrix if parallel to x-axis or value of 'e' in matrix if parallel to y-axis.
///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ A cos(t) ⎞
///     ⎜ d e f ⎟ ⎜ B sin(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝    1     ⎠
///
public func EllipseStationary(_ r: Radius, _ a: Double, _ b: Double) -> Double {
    return atan2(r.y * b, r.x * a)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ A cos(t) ⎞
///     ⎜ d e f ⎟ ⎜ B sin(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝    1     ⎠
///
public func EllipseBound<T: SDTransformProtocol>(_ center: Point, _ r: Radius, _ matrix: T) -> Rect {
    
    let t1 = EllipseStationary(r, matrix.a, matrix.b)
    let t2 = EllipseStationary(r, matrix.d, matrix.e)
    
    let p0 = Ellipse(t1, center, r)
    let p1 = Ellipse(t1 + M_PI, center, r)
    let p2 = Ellipse(t2, center, r)
    let p3 = Ellipse(t2 + M_PI, center, r)
    
    let _p0 = matrix.a * p0.x + matrix.b * p0.y
    let _p1 = matrix.a * p1.x + matrix.b * p1.y
    let _p2 = matrix.d * p2.x + matrix.e * p2.y
    let _p3 = matrix.d * p3.x + matrix.e * p3.y
    
    let minX = min(_p0, _p1)
    let minY = min(_p2, _p3)
    let maxX = max(_p0, _p1)
    let maxY = max(_p2, _p3)
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

// MARK: Bézier Curve

public func Bezier(_ t: Double, _ p0: Double, _ p1: Double) -> Double {
    return p0 + t * (p1 - p0)
}
public func Bezier(_ t: Double, _ p0: Double, _ p1: Double, _ p2: Double) -> Double {
    let _t = 1 - t
    return _t * _t * p0 + 2 * _t * t * p1 + t * t * p2
}
public func Bezier(_ t: Double, _ p0: Double, _ p1: Double, _ p2: Double, _ p3: Double) -> Double {
    let t2 = t * t
    let _t = 1 - t
    let _t2 = _t * _t
    return _t * _t2 * p0 + 3 * _t2 * t * p1 + 3 * _t * t2 * p2 + t * t2 * p3
}
public func Bezier(_ t: Double, _ p0: Point, _ p1: Point) -> Point {
    return p0 + t * (p1 - p0)
}
public func Bezier(_ t: Double, _ p0: Point, _ p1: Point, _ p2: Point) -> Point {
    let _t = 1 - t
    return _t * _t * p0 + 2 * _t * t * p1 + t * t * p2
}
public func Bezier(_ t: Double, _ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Point {
    let t2 = t * t
    let _t = 1 - t
    let _t2 = _t * _t
    return _t * _t2 * p0 + 3 * _t2 * t * p1 + 3 * _t * t2 * p2 + t * t2 * p3
}
public func Bezier(_ t: Double, _ p0: Vector, _ p1: Vector) -> Vector {
    return p0 + t * (p1 - p0)
}
public func Bezier(_ t: Double, _ p0: Vector, _ p1: Vector, _ p2: Vector) -> Vector {
    let _t = 1 - t
    return _t * _t * p0 + 2 * _t * t * p1 + t * t * p2
}
public func Bezier(_ t: Double, _ p0: Vector, _ p1: Vector, _ p2: Vector, _ p3: Vector) -> Vector {
    let t2 = t * t
    let _t = 1 - t
    let _t2 = _t * _t
    return _t * _t2 * p0 + 3 * _t2 * t * p1 + 3 * _t * t2 * p2 + t * t2 * p3
}
public func Bezier(_ t: Double, _ p0: Double, _ p1: Double, _ p2: Double, _ p3: Double, _ p4: Double, _ rest: Double ... ) -> Double {
    return Bezier(t, [p0, p1, p2, p3, p4] + rest)
}

public func Bezier(_ t: Double, _ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ p4: Point, _ rest: Point ... ) -> Point {
    return Bezier(t, [p0, p1, p2, p3, p4] + rest)
}

public func Bezier(_ t: Double, _ p0: Vector, _ p1: Vector, _ p2: Vector, _ p3: Vector, _ p4: Vector, _ rest: Vector ... ) -> Vector {
    return Bezier(t, [p0, p1, p2, p3, p4] + rest)
}

public func SplitBezier(_ t: Double, _ p: Double ... ) -> ([Double], [Double]) {
    return SplitBezier(t, p)
}

public func SplitBezier(_ t: Double, _ p: Point ... ) -> ([Point], [Point]) {
    return SplitBezier(t, p)
}

public func SplitBezier(_ t: Double, _ p: Vector ... ) -> ([Vector], [Vector]) {
    return SplitBezier(t, p)
}

public func SplitBezier(_ t: [Double], _ p: Double ... ) -> [[Double]] {
    return SplitBezier(t, p)
}

public func SplitBezier(_ t: [Double], _ p: Point ... ) -> [[Point]] {
    return SplitBezier(t, p)
}

public func SplitBezier(_ t: [Double], _ p: Vector ... ) -> [[Vector]] {
    return SplitBezier(t, p)
}

public func BezierDerivative(_ p: Double ... ) -> [Double] {
    return BezierDerivative(p)
}

public func BezierDerivative(_ p: Point ... ) -> [Point] {
    return BezierDerivative(p)
}

public func BezierDerivative(_ p: Vector ... ) -> [Vector] {
    return BezierDerivative(p)
}

@_transparent
private func Bezier(_ t: Double, _ p: [Double]) -> Double {
    var result: Double = 0
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerated() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

@_transparent
private func Bezier(_ t: Double, _ p: [Point]) -> Point {
    var result = Point()
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerated() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

@_transparent
private func Bezier(_ t: Double, _ p: [Vector]) -> Vector {
    var result = Vector()
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerated() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

@_transparent
private func BezierPolynomial(_ p: [Double]) -> Polynomial {
    
    var result = PermutationList(UInt(p.count - 1)).map(Double.init) as Array
    for i in result.indices {
        var sum = 0.0
        let fact = Array(FactorialList(UInt(i)))
        for (j, f) in zip(fact, fact.reversed()).map(*).enumerated() {
            if (i + j) & 1 == 0 {
                sum += p[j] / Double(f)
            } else {
                sum -= p[j] / Double(f)
            }
        }
        result[i] *= sum
    }
    return Polynomial(result)
}

public func BezierPolynomial(_ p: Double ... ) -> Polynomial {
    
    return BezierPolynomial(p)
}

public func BezierDegreeElevation(_ p: Double ... ) -> [Double] {
    let n = Double(p.count)
    var result = [p[0]]
    for (k, points) in zip(p, p.dropFirst()).enumerated() {
        let t = Double(k + 1) / n
        result.append(t * points.0 + (1 - t) * points.1)
    }
    result.append(p.last!)
    return result
}

public func BezierDegreeElevation(_ p: Point ... ) -> [Point] {
    let n = Double(p.count)
    var result = [p[0]]
    for (k, points) in zip(p, p.dropFirst()).enumerated() {
        let t = Double(k + 1) / n
        result.append(t * points.0 + (1 - t) * points.1)
    }
    result.append(p.last!)
    return result
}

public func BezierDegreeElevation(_ p: Vector ... ) -> [Vector] {
    let n = Double(p.count)
    var result = [p[0]]
    for (k, points) in zip(p, p.dropFirst()).enumerated() {
        let t = Double(k + 1) / n
        result.append(t * points.0 + (1 - t) * points.1)
    }
    result.append(p.last!)
    return result
}

public func BezierPolynomial(_ poly: Polynomial) -> [Double] {
    let de = (0..<poly.degree).scan(poly) { p, _ in p.derivative / Double(p.degree) }
    var result: [Double] = []
    for n in de.indices {
        let s = zip(CombinationList(UInt(n)), de)
        result.append(s.reduce(0) { $0 + Double($1.0) * $1.1[0] })
    }
    return result
}

public func ClosestBezier(_ point: Point, _ b0: Point, _ b1: Point) -> [Double] {
    let a = b0 - point
    let b = b1 - b0
    let x: Polynomial = [a.x, b.x]
    let y: Polynomial = [a.y, b.y]
    let dot = x * x + y * y
    return dot.derivative.roots.sorted(by: { dot.eval($0) })
}

public func ClosestBezier(_ point: Point, _ b0: Point, _ b1: Point, _ b2: Point) -> [Double] {
    let a = b0 - point
    let b = 2 * (b1 - b0)
    let c = b0 - 2 * b1 + b2
    let x: Polynomial = [a.x, b.x, c.x]
    let y: Polynomial = [a.y, b.y, c.y]
    let dot = x * x + y * y
    return dot.derivative.roots.sorted(by: { dot.eval($0) })
}

public func ClosestBezier(_ point: Point, _ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point) -> [Double] {
    let a = b0 - point
    let b = 3 * (b1 - b0)
    let c = 3 * (b2 + b0) - 6 * b1
    let d = b3 + 3 * (b1 - b2) - b0
    let x: Polynomial = [a.x, b.x, c.x, d.x]
    let y: Polynomial = [a.y, b.y, c.y, d.y]
    let dot = x * x + y * y
    let y_roots = y.roots
    let roots = x.roots.filter { x in y_roots.contains { x.almostEqual($0) } }
    return roots.count != 0 ? roots.sorted(by: { dot.eval($0) }) : dot.derivative.roots.sorted(by: { dot.eval($0) })
}

public func ClosestBezier(_ point: Point, _ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ b4: Point , _ b5: Point ... ) -> [Double] {
    let list = [b0, b1, b2, b3, b4] + b5
    let x = BezierPolynomial(list.map { $0.x }) - point.x
    let y = BezierPolynomial(list.map { $0.y }) - point.y
    let dot = x * x + y * y
    return dot.derivative.roots.sorted(by: { dot.eval($0) })
}

private func SplitBezier(_ t: Double, _ p: [Double]) -> ([Double], [Double]) {
    let _t = 1 - t
    if p.count == 2 {
        let split = _t * p.first! + t * p.last!
        return ([p.first!, split], [split, p.last!])
    }
    var subpath = [Double]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        subpath.append(_t * lastPoint + t * current)
        lastPoint = current
    }
    let split = SplitBezier(t, subpath)
    return ([p.first!] + split.0, split.1 + [p.last!])
}
@_transparent
private func SplitBezier(_ t: [Double], _ p: [Double]) -> [[Double]] {
    var result: [[Double]] = []
    var remain = p
    var last_t = 0.0
    for _t in t.sorted() {
        let split = SplitBezier((_t - last_t) / (1 - last_t), remain)
        result.append(split.0)
        remain = split.1
        last_t = _t
    }
    result.append(remain)
    return result
}

private func SplitBezier(_ t: Double, _ p: [Point]) -> ([Point], [Point]) {
    let _t = 1 - t
    if p.count == 2 {
        let split = _t * p.first! + t * p.last!
        return ([p.first!, split], [split, p.last!])
    }
    var subpath = [Point]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        subpath.append(_t * lastPoint + t * current)
        lastPoint = current
    }
    let split = SplitBezier(t, subpath)
    return ([p.first!] + split.0, split.1 + [p.last!])
}
@_transparent
private func SplitBezier(_ t: [Double], _ p: [Point]) -> [[Point]] {
    var result: [[Point]] = []
    var remain = p
    var last_t = 0.0
    for _t in t.sorted() {
        let split = SplitBezier((_t - last_t) / (1 - last_t), remain)
        result.append(split.0)
        remain = split.1
        last_t = _t
    }
    result.append(remain)
    return result
}

private func SplitBezier(_ t: Double, _ p: [Vector]) -> ([Vector], [Vector]) {
    let _t = 1 - t
    if p.count == 2 {
        let split = _t * p.first! + t * p.last!
        return ([p.first!, split], [split, p.last!])
    }
    var subpath = [Vector]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        subpath.append(_t * lastPoint + t * current)
        lastPoint = current
    }
    let split = SplitBezier(t, subpath)
    return ([p.first!] + split.0, split.1 + [p.last!])
}
@_transparent
private func SplitBezier(_ t: [Double], _ p: [Vector]) -> [[Vector]] {
    var result: [[Vector]] = []
    var remain = p
    var last_t = 0.0
    for _t in t.sorted() {
        let split = SplitBezier((_t - last_t) / (1 - last_t), remain)
        result.append(split.0)
        remain = split.1
        last_t = _t
    }
    result.append(remain)
    return result
}

@_transparent
private func BezierDerivative(_ p: [Double]) -> [Double] {
    let n = Double(p.count - 1)
    var de = [Double]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
}

@_transparent
private func BezierDerivative(_ p: [Point]) -> [Point] {
    let n = Double(p.count - 1)
    var de = [Point]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
}

@_transparent
private func BezierDerivative(_ p: [Vector]) -> [Vector] {
    let n = Double(p.count - 1)
    var de = [Vector]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
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

@_transparent
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

@_transparent
private func BezierOffsetCurvature(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let u = p2 - p0
    let v = p1 - 0.5 * (p2 + p0)
    return u.magnitude < v.magnitude * 3
}
@_transparent
private func BezierOffsetCurvature(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Bool {
    let u = p3 - p0
    let v = p1 - 0.5 * (p3 + p0)
    let w = p2 - 0.5 * (p3 + p0)
    return u.magnitude < max(v.magnitude, w.magnitude) * 3
}

public func BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double) -> [[Point]]? {
    
    let q0 = p1 - p0
    let q1 = p2 - p1
    
    if (q0.x.almostZero() && q0.y.almostZero()) || (q1.x.almostZero() && q1.y.almostZero()) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] }
    }
    let ph0 = q0.phase
    let ph1 = q1.phase
    
    if ph0.almostEqual(ph1) || ph0.almostEqual(ph1 + 2 * M_PI) || ph0.almostEqual(ph1 - 2 * M_PI) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] }
    }
    if ph0.almostEqual(ph1 + M_PI) || ph0.almostEqual(ph1 - M_PI) {
        if let w = QuadBezierStationary(p0.x, p1.x, p2.x) ?? QuadBezierStationary(p0.y, p1.y, p2.y) {
            let g = Bezier(w, p0, p1, p2)
            if let left = BezierOffset(p0, g, a), let right = BezierOffset(g, p2, a) {
                let angle = ph0 - M_PI_2
                let bezierCircle = BezierCircle.lazy.map { $0 * SDTransform.Rotate(angle) * a + g }
                let i = [bezierCircle[0],
                         bezierCircle[1],
                         bezierCircle[2],
                         bezierCircle[3]]
                let j = [bezierCircle[3],
                         bezierCircle[4],
                         bezierCircle[5],
                         bezierCircle[6]]
                return [[left.0, left.1], i, j, [right.0, right.1]]
            }
        }
    }
    
    func split(_ t: Double) -> [[Point]]? {
        let (left, right) = SplitBezier(t, p0, p1, p2)
        if let _left = BezierOffset(left[0], left[1], left[2], a), let _right = BezierOffset(right[0], right[1], right[2], a) {
            return _left + _right
        }
        return nil
    }
    
    if BezierOffsetCurvature(p0, p1, p2) {
        return split(0.5)
    } else {
        
        let s = 1 / q0.magnitude
        let t = 1 / q1.magnitude
        let start = Point(x: p0.x + a * q0.y * s, y: p0.y - a * q0.x * s)
        let end = Point(x: p2.x + a * q1.y * t, y: p2.y - a * q1.x * t)
        
        if let mid = QuadBezierFitting(start, end, q0, q1) {
            return BezierOffsetCurvature(start, mid, end) ? split(0.5) : [[start, mid, end]]
        }
    }
    
    return BezierOffset(p0, p2, a).map { [[$0, $1]] }
}

public func BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ a: Double) -> [[Point]]? {
    
    let q0 = p1 - p0
    let q1 = p2 - p1
    let q2 = p3 - p2
    
    let z0 = q0.x.almostZero() && q0.y.almostZero()
    let z1 = q1.x.almostZero() && q1.y.almostZero()
    let z2 = q2.x.almostZero() && q2.y.almostZero()
    
    if (z0 && z1) || (z0 && z2) || (z1 && z2) {
        return BezierOffset(p0, p3, a).map { [[$0, $1]] }
    }
    
    let ph0 = q0.phase
    let ph1 = q1.phase
    let ph2 = q2.phase
    let zh0 = ph0.almostEqual(ph1) || ph0.almostEqual(ph1 + 2 * M_PI) || ph0.almostEqual(ph1 - 2 * M_PI)
    let zh1 = ph1.almostEqual(ph2) || ph1.almostEqual(ph2 + 2 * M_PI) || ph1.almostEqual(ph2 - 2 * M_PI)
    let zh2 = ph0.almostEqual(ph1 + M_PI) || ph0.almostEqual(ph1 - M_PI)
    let zh3 = ph1.almostEqual(ph2 + M_PI) || ph1.almostEqual(ph2 - M_PI)
    
    if zh0 && zh1 {
        return BezierOffset(p0, p3, a).map { [[$0, $1]] }
    }
    if (zh2 && zh3) || (zh2 && zh1) || (zh3 && zh0) {
        
    }
    
    func split(_ t: Double) -> [[Point]]? {
        let (left, right) = SplitBezier(t, p0, p1, p2, p3)
        if let _left = BezierOffset(left[0], left[1], left[2], left[3], a), let _right = BezierOffset(right[0], right[1], right[2], right[3], a) {
            return _left + _right
        }
        return nil
    }
    
    if let t = CubicBezierLineIntersect(p0, p1, p2, p3, p0, p3)?.min(by: { abs(0.5 - $0) }), !t.almostZero() && !(1 - t).almostZero() {
        
        return split(t)
    } else if BezierOffsetCurvature(p0, p1, p2, p3) {
        
        return split(0.5)
    } else {
        
        let _q0 = z0 ? q1 : q0
        let _q1 = z2 ? q1 : q2
        
        let s = 1 / _q0.magnitude
        let t = 1 / _q1.magnitude
        let start = Point(x: p0.x + a * _q0.y * s, y: p0.y - a * _q0.x * s)
        let end = Point(x: p3.x + a * _q1.y * t, y: p3.y - a * _q1.x * t)
        
        if let mid = QuadBezierFitting(start, end, _q0, _q1) {
            return BezierOffsetCurvature(start, mid, end) ? split(0.5) : [[start, mid, end]]
        }
    }
    
    return BezierOffset(p0, p3, a).map { [[$0, $1]] }
}

// MARK: Stationary Points

public func QuadBezierStationary(_ p0: Double, _ p1: Double, _ p2: Double) -> Double? {
    let d = p0 + p2 - 2 * p1
    if d.almostZero() {
        return nil
    }
    return (p0 - p1) / d
}

///
/// :param: a value of 'a' in matrix if parallel to x-axis or value of 'd' in matrix if parallel to y-axis.
/// :param: b value of 'b' in matrix if parallel to x-axis or value of 'e' in matrix if parallel to y-axis.
///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
public func QuadBezierStationary(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double, _ b: Double) -> Double? {
    let d = a * (p0.x + p2.x - 2 * p1.x) + b * (p0.y + p2.y - 2 * p1.y)
    if d.almostZero() {
        return nil
    }
    return (a * (p0.x - p1.x) + b * (p0.y - p1.y)) / d
}

public func CubicBezierStationary(_ p0: Double, _ p1: Double, _ p2: Double, _ p3: Double) -> [Double] {
    let _a = 3 * (p3 - p0) + 9 * (p1 - p2)
    let _b = 6 * (p2 + p0) - 12 * p1
    let _c = 3 * (p1 - p0)
    if _a.almostZero() {
        if _b.almostZero() {
            return []
        }
        let t = -_c / _b
        return [t]
    } else {
        let delta = _b * _b - 4 * _a * _c
        let _a2 = 2 * _a
        let _b2 = -_b / _a2
        if delta.sign == .plus {
            let sqrt_delta = sqrt(delta) / _a2
            let t1 = _b2 + sqrt_delta
            let t2 = _b2 - sqrt_delta
            return [t1, t2]
        } else if delta.almostZero() {
            return [_b2]
        }
    }
    return []
}

///
/// :param: a value of 'a' in matrix if parallel to x-axis or value of 'd' in matrix if parallel to y-axis.
/// :param: b value of 'b' in matrix if parallel to x-axis or value of 'e' in matrix if parallel to y-axis.
///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
public func CubicBezierStationary(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ a: Double, _ b: Double) -> [Double] {
    let _ax = 3 * (p3.x - p0.x) + 9 * (p1.x - p2.x)
    let _bx = 6 * (p2.x + p0.x) - 12 * p1.x
    let _cx = 3 * (p1.x - p0.x)
    let _ay = 3 * (p3.y - p0.y) + 9 * (p1.y - p2.y)
    let _by = 6 * (p2.y + p0.y) - 12 * p1.y
    let _cy = 3 * (p1.y - p0.y)
    let _a = a * _ax + b * _ay
    let _b = a * _bx + b * _by
    let _c = a * _cx + b * _cy
    if _a.almostZero() {
        if _b.almostZero() {
            return []
        }
        let t = -_c / _b
        return [t]
    } else {
        let delta = _b * _b - 4 * _a * _c
        let _a2 = 2 * _a
        let _b2 = -_b / _a2
        if delta.sign == .plus {
            let sqrt_delta = sqrt(delta) / _a2
            let t1 = _b2 + sqrt_delta
            let t2 = _b2 - sqrt_delta
            return [t1, t2]
        } else if delta.almostZero() {
            return [_b2]
        }
    }
    return []
}

// MARK: Boundary

public func QuadBezierBound(_ p0: Point, _ p1: Point, _ p2: Point) -> Rect {
    
    let tx = [0.0, QuadBezierStationary(p0.x, p1.x, p2.x).map { $0.clamped(to: 0...1) } ?? 0.0, 1.0]
    let ty = [0.0, QuadBezierStationary(p0.y, p1.y, p2.y).map { $0.clamped(to: 0...1) } ?? 0.0, 1.0]
    
    let _x = tx.map { Bezier($0, p0.x, p1.x, p2.x) }
    let _y = ty.map { Bezier($0, p0.y, p1.y, p2.y) }
    
    let minX = _x.min()!
    let minY = _y.min()!
    let maxX = _x.max()!
    let maxY = _y.max()!
    
    return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
public func QuadBezierBound<T: SDTransformProtocol>(_ p0: Point, _ p1: Point, _ p2: Point, _ matrix: T) -> Rect {
    
    let tx = [0.0, QuadBezierStationary(p0, p1, p2, matrix.a, matrix.b).map { $0.clamped(to: 0...1) } ?? 0.0, 1.0]
    let ty = [0.0, QuadBezierStationary(p0, p1, p2, matrix.d, matrix.e).map { $0.clamped(to: 0...1) } ?? 0.0, 1.0]
    
    let _x = tx.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2)
        return matrix.a * _p.x + matrix.b * _p.y
    }
    let _y = ty.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2)
        return matrix.d * _p.x + matrix.e * _p.y
    }
    
    let minX = _x.min()!
    let minY = _y.min()!
    let maxX = _x.max()!
    let maxY = _y.max()!
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

public func CubicBezierBound(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Rect {
    
    let tx = [0.0, 1.0] + CubicBezierStationary(p0.x, p1.x, p2.x, p3.x).lazy.map { $0.clamped(to: 0...1) }
    let ty = [0.0, 1.0] + CubicBezierStationary(p0.y, p1.y, p2.y, p3.y).lazy.map { $0.clamped(to: 0...1) }
    
    let _x = tx.map { Bezier($0, p0.x, p1.x, p2.x, p3.x) }
    let _y = ty.map { Bezier($0, p0.y, p1.y, p2.y, p3.y) }
    
    let minX = _x.min()!
    let minY = _y.min()!
    let maxX = _x.max()!
    let maxY = _y.max()!
    
    return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
public func CubicBezierBound<T: SDTransformProtocol>(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ matrix: T) -> Rect {
    
    let tx = [0.0, 1.0] + CubicBezierStationary(p0, p1, p2, p3, matrix.a, matrix.b).lazy.map { $0.clamped(to: 0...1) }
    let ty = [0.0, 1.0] + CubicBezierStationary(p0, p1, p2, p3, matrix.d, matrix.e).lazy.map { $0.clamped(to: 0...1) }
    
    let _x = tx.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2, p3)
        return matrix.a * _p.x + matrix.b * _p.y
    }
    let _y = ty.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2, p3)
        return matrix.d * _p.x + matrix.e * _p.y
    }
    
    let minX = _x.min()!
    let minY = _y.min()!
    let maxX = _x.max()!
    let maxY = _y.max()!
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

public var BezierCircle: [Point] {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    return [
        Point(x: 1, y: 0),
        Point(x: 1, y: c),
        Point(x: c, y: 1),
        Point(x: 0, y: 1),
        Point(x: -c, y: 1),
        Point(x: -1, y: c),
        Point(x: -1, y: 0),
        Point(x: -1, y: -c),
        Point(x: -c, y: -1),
        Point(x: 0, y: -1),
        Point(x: c, y: -1),
        Point(x: 1, y: -c),
        Point(x: 1, y: 0)
    ]
}
public func BezierArc(_ angle: Double) -> [Point] {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    var counter = 0
    var _angle = abs(angle)
    var result = [Point(x: 1, y: 0)]
    
    while _angle > 0 && !_angle.almostZero() {
        switch counter & 3 {
        case 0:
            result.append(Point(x: 1, y: c))
            result.append(Point(x: c, y: 1))
            result.append(Point(x: 0, y: 1))
        case 1:
            result.append(Point(x: -c, y: 1))
            result.append(Point(x: -1, y: c))
            result.append(Point(x: -1, y: 0))
        case 2:
            result.append(Point(x: -1, y: -c))
            result.append(Point(x: -c, y: -1))
            result.append(Point(x: 0, y: -1))
        case 3:
            result.append(Point(x: c, y: -1))
            result.append(Point(x: 1, y: -c))
            result.append(Point(x: 1, y: 0))
        default: break
        }
        if _angle < M_PI_2 {
            let offset = Double(counter & 3) * M_PI_2
            let s = _angle + offset
            let _a = result.count - 4
            let _b = result.count - 3
            let _c = result.count - 2
            let _d = result.count - 1
            let end = Point(x: cos(s), y: sin(s))
            let t = ClosestBezier(end, result[_a], result[_b], result[_c], result[_d]).first!
            let split = SplitBezier(t, result[_a], result[_b], result[_c], result[_d]).0
            result[_b] = split[1]
            result[_c] = split[2]
            result[_d] = end
        }
        _angle -= M_PI_2
        counter += 1
    }
    return angle.sign == .minus ? result.map { Point(x: $0.x, y: -$0.y) } : result
}

// MARK: Path Intersection

public func CubicBezierSelfIntersect(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> (Double, Double)? {
    
    let a = p3.x - p0.x + 3 * (p1.x - p2.x)
    if a.almostZero() {
        return nil
    }
    
    let b = (3 * (p0.x + p2.x) - 6 * p1.x) / a
    let c = (3 * (p1.x - p0.x)) / a
    
    let d = p3.y - p0.y + 3 * (p1.y - p2.y)
    if d.almostZero() {
        return nil
    }
    let e = (3 * (p0.y + p2.y) - 6 * p1.y) / d
    if b == e {
        return nil
    }
    let f = (3 * (p1.y - p0.y)) / d
    let g = (f - c) / (b - e)
    
    let g_2 = g * g
    
    let _b = -3 * g
    let _c = 3 * g_2 + 2 * (g * b + c)
    let _d = -g_2 * g - b * g_2 - c * g
    let roots = Polynomial(_d, _c, _b, 2).roots
    if roots.count == 3 {
        return (roots.min()!, roots.max()!)
    }
    
    return nil
}

public func LinesIntersect(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Point? {
    
    let d = (p0.x - p1.x) * (p2.y - p3.y) - (p0.y - p1.y) * (p2.x - p3.x)
    if d.almostZero() {
        return nil
    }
    let a = (p0.x * p1.y - p0.y * p1.x) / d
    let b = (p2.x * p3.y - p2.y * p3.x) / d
    return Point(x: (p2.x - p3.x) * a - (p0.x - p1.x) * b, y: (p2.y - p3.y) * a - (p0.y - p1.y) * b)
}

public func QuadBezierLineIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let a = b0 - l0
    let b = 2 * (b1 - b0)
    let c = b0 - 2 * b1 + b2
    
    let u0: Polynomial = [a.x, b.x, c.x]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [a.y, b.y, c.y]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all({ $0.almostZero() }) ? nil : poly.roots
}

public func CubicBezierLineIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let a = b0 - l0
    let b = 3 * (b1 - b0)
    let c = 3 * (b2 + b0) - 6 * b1
    let d = b3 - b0 + 3 * (b1 - b2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all({ $0.almostZero() }) ? nil : poly.roots
}

public func QuadBeziersIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ b4: Point, _ b5: Point) -> [Double]? {
    
    let a = b0 - b3
    let b = 2 * (b1 - b0)
    let c = b0 - 2 * b1 + b2
    
    let u0: Polynomial = [a.x, b.x, c.x]
    let u1 = 2 * (b3.x - b4.x)
    let u2 = 2 * b4.x - b3.x -  b5.x
    
    let v0: Polynomial = [a.y, b.y, c.y]
    let v1 = 2 * (b3.y - b4.y)
    let v2 = 2 * b4.y - b3.y -  b5.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all({ $0.almostZero() }) ? nil : det.roots
}

public func CubicQuadBezierIntersect(_ c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ q0: Point, _ q1: Point, _ q2: Point) -> [Double]? {
    
    let a = c0 - q0
    let b = 3 * (c1 - c0)
    let c = 3 * (c2 + c0) - 6 * c1
    let d = c3 - c0 + 3 * (c1 - c2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = 2 * (q0.x - q1.x)
    let u2 = 2 * q1.x - q0.x - q2.x
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = 2 * (q0.y - q1.y)
    let v2 = 2 * q1.y - q0.y - q2.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all({ $0.almostZero() }) ? nil : det.roots
}

public func CubicBeziersIntersect(_ c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ c4: Point, _ c5: Point, _ c6: Point, _ c7: Point) -> [Double]? {
    
    let a = c0 - c4
    let b = 3 * (c1 - c0)
    let c = 3 * (c2 + c0) - 6 * c1
    let d = c3 - c0 + 3 * (c1 - c2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = 3 * (c4.x - c5.x)
    let u2 = 6 * c5.x - 3 * (c6.x + c4.x)
    let u3 = c4.x - c7.x + 3 * (c6.x - c5.x)
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = 3 * (c4.y - c5.y)
    let v2 = 6 * c5.y - 3 * (c6.y + c4.y)
    let v3 = c4.y - c7.y + 3 * (c6.y - c5.y)
    
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
    let det = m00 * _a + m01 * _b + m02 * _c
    return det.all({ $0.almostZero() }) ? nil : det.roots
}

// MARK: Winding Number

@_transparent
private func _integral(_ n: Double, _ b: Double, _ c: Double) -> Double {
    
    let delta = b * b - 4 * c
    
    if delta.almostZero() {
        return 4 * n / (b * (2 + b))
    }
    if delta.sign == .minus {
        let q = sqrt(-delta)
        return -2 * n * (atan2(q, 2 + b) - atan2(q, b)) / q
    } else {
        let q = sqrt(delta)
        let s = b - q
        let t = b + q
        let u = t * (s + 2)
        let v = s * (t + 2)
        return n * (log(abs(u / v))) / q
    }
}

@_transparent
private func _integral(_ m: Double, _ n: Double, _ b: Double, _ c: Double) -> Double {
    
    let _m = 0.5 * m
    return _m * log(abs(1 + (1 + b) / c)) + _integral(n - _m * b, b, c)
}

private func _integral(_ m: Double, _ n: Double, _ b: Double, _ c: Double, _ r: Int) -> Double {
    
    if r == 1 {
        return _integral(m, n, b, c)
    }
    
    let _r = r - 1
    let s = Double(_r) * (4 * c - b * b)
    
    let t = (2 + b) * n - (b + 2 * c) * m
    let u = s * pow(1 + b + c, Double(_r))
    let v = b * n - 2 * c * m
    let w = s * pow(c, Double(_r))
    
    return t / u - v / w + _integral(0, Double(2 * r - 3) * (2 * n - b * m) / s, b, c, _r)
}

public func LineWinding(_ p0: Point, _ p1: Point) -> Double {
    
    let x0 = p0.x
    let x1 = p1.x - p0.x
    let y0 = p0.y
    let y1 = p1.y - p0.y
    
    if x1.almostZero() && y1.almostZero() {
        return 0
    }
    
    let m = x0 * y1 - x1 * y0
    let a = x1 * x1 + y1 * y1
    let b = 2 * (x0 * x1 + y0 * y1)
    let c = x0 * x0 + y0 * y0
    
    return a.almostZero() ? 0 : 0.5 * M_1_PI * _integral(m / a, b / a, c / a)
}

private enum PartialPolynomial {
    
    case one(Double, Int)
    case two(Double, Double, Int)
}

extension PartialPolynomial {
    
    @_transparent
    var degree : Int {
        switch self {
        case .one: return 1
        case .two: return 2
        }
    }
    @_transparent
    var power : Int {
        switch self {
        case .one(_, let p): return p
        case .two(_, _, let p): return p
        }
    }
    @_transparent
    var polynomial : Polynomial {
        switch self {
        case .one(let a, _): return [a, 1]
        case .two(let a, let b, _): return [a, b, 1]
        }
    }
}

extension PartialPolynomial {
    
    @_transparent
    var a : Double {
        switch self {
        case .one(let a, _): return a
        case .two(let a, _, _): return a
        }
    }
    @_transparent
    func almostEqual(_ p: Double) -> Bool {
        switch self {
        case .one(let a, _): return p.almostEqual(a)
        case .two(_, _, _): return false
        }
    }
    @_transparent
    func almostEqual(_ p: (Double, Double)) -> Bool {
        switch self {
        case .one(_, _): return false
        case .two(let a, let b, _): return p.0.almostEqual(a) && p.1.almostEqual(b)
        }
    }
}

@_transparent
private func appendPartialPolynomial(_ p: inout [PartialPolynomial], _ poly: Double) {
    let power = p.lazy.filter { $0.almostEqual(poly) }.max(by: { $0.power })?.power ?? 0
    p.append(.one(poly, power + 1))
}

@_transparent
private func appendPartialPolynomial(_ p: inout [PartialPolynomial], _ poly: (Double, Double)) {
    let delta = poly.1 * poly.1 - 4 * poly.0
    if delta.almostZero() {
        appendPartialPolynomial(&p, 0.5 * poly.1)
        appendPartialPolynomial(&p, 0.5 * poly.1)
    } else if delta > 0 {
        let _sqrt = sqrt(delta)
        appendPartialPolynomial(&p, 0.5 * (poly.1 - _sqrt))
        appendPartialPolynomial(&p, 0.5 * (poly.1 + _sqrt))
    } else {
        let power = p.lazy.filter { $0.almostEqual(poly) }.max(by: { $0.power })?.power ?? 0
        p.append(.two(poly.0, poly.1, power + 1))
    }
}

private func degree6RationalIntegral(_ p: Polynomial, _ q: Polynomial) -> Double {
    
    var partials: [PartialPolynomial] = []
    
    let _p = p / q.last!
    let _q = q / q.last!
    let (quo, rem) = quorem(_p, _q)
    let _quo_integral = quo.integral
    
    var result = _quo_integral.eval(1) - _quo_integral.eval(0)
    
    switch _q.degree {
    case 0: return result
    case 1: return result + rem[0] * log(abs(1 + 1 / _q[0]))
    case 2: return result + _integral(rem[1], rem[0], _q[1], _q[0])
    case 3:
        let d = degree3decompose(_q[2], _q[1], _q[0])
        appendPartialPolynomial(&partials, -d.0)
        appendPartialPolynomial(&partials, (d.1.1, d.1.0))
    case 4:
        let d = degree4decompose(_q[3], _q[2], _q[1], _q[0])
        appendPartialPolynomial(&partials, (d.0.1, d.0.0))
        appendPartialPolynomial(&partials, (d.1.1, d.1.0))
    case 5:
        let d = degree5decompose(_q[4], _q[3], _q[2], _q[1], _q[0])
        appendPartialPolynomial(&partials, -d.0)
        appendPartialPolynomial(&partials, (d.1.1, d.1.0))
        appendPartialPolynomial(&partials, (d.2.1, d.2.0))
    case 6:
        let d = degree6decompose(_q[5], _q[4], _q[3], _q[2], _q[1], _q[0])
        appendPartialPolynomial(&partials, (d.0.1, d.0.0))
        appendPartialPolynomial(&partials, (d.1.1, d.1.0))
        appendPartialPolynomial(&partials, (d.2.1, d.2.0))
    default: fatalError()
    }
    
    if partials.all({ $0.degree == 1 && $0.power == 1 }) {
        
        let derivative = _q.derivative
        for item in partials {
            let c = rem.eval(-item.a) / derivative.eval(-item.a)
            result += c * log(abs(1 + 1 / item.a))
        }
        
    } else {
        
        var m: [Polynomial] = []
        for item in partials {
            let poly = item.power == 1 ? _q / item.polynomial : _q / pow(item.polynomial, item.power)
            m.append(poly)
            if item.degree == 2 {
                m.append(Polynomial(CollectionOfOne(0).concat(poly)))
            }
        }
        m.append(rem)
        
        var matrix: [Double] = []
        for _ in 0..<_q.degree {
            matrix.append(contentsOf: m.lazy.map { $0[0] })
            m = m.map { $0.derivative }
        }
        if MatrixElimination(_q.degree, &matrix) {
            var c = matrix.lazy.slice(by: _q.degree + 1).map { $0.last! }.makeIterator()
            for part in partials {
                switch part {
                case .one(let a, let n):
                    let s = c.next()!
                    if n == 1 {
                        result += s * log(abs(1 + 1 / a))
                    } else {
                        let _n = Double(1 - n)
                        result += s * (pow(a + 1, _n) - pow(a, _n)) / _n
                    }
                case .two(let a, let b, let n):
                    let s = c.next()!
                    let t = c.next()!
                    result += _integral(t, s, b, a, n)
                }
            }
        }
    }
    
    return result
}

public func QuadBezierWinding(_ p0: Point, _ p1: Point, _ p2: Point) -> Double {
    
    let a = p0
    let b = 2 * (p1 - p0)
    let c = p0 - 2 * p1 + p2
    
    let x: Polynomial = [a.x, b.x, c.x]
    let y: Polynomial = [a.y, b.y, c.y]
    
    return 0.5 * M_1_PI * degree6RationalIntegral(x * y.derivative - x.derivative * y, x * x + y * y)
}

public func CubicBezierWinding(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Double {
    
    let a = p0
    let b = 3 * (p1 - p0)
    let c = 3 * (p2 + p0) - 6 * p1
    let d = p3 - p0 + 3 * (p1 - p2)
    
    let x: Polynomial = [a.x, b.x, c.x, d.x]
    let y: Polynomial = [a.y, b.y, c.y, d.y]
    
    return 0.5 * M_1_PI * degree6RationalIntegral(x * y.derivative - x.derivative * y, x * x + y * y)
}

// MARK: Area

public func BezierSignedArea(_ p: Point ...) -> Double {
    
    let x = BezierPolynomial(p.map { $0.x })
    let y = BezierPolynomial(p.map { $0.y })
    let t = x * y.derivative - x.derivative * y
    return 0.5 * t.integral.eval(1)
}

public func LineSignedArea(_ p0: Point, _ p1: Point) -> Double {
    
    return 0.5 * (p0.x * p1.y - p0.y * p1.x)
}

public func QuadBezierSignedArea(_ p0: Point, _ p1: Point, _ p2: Point) -> Double {
    
    let a = p0.x - 2 * p1.x + p2.x
    let b = 2 * (p1.x - p0.x)
    
    let c = p0.y - 2 * p1.y + p2.y
    let d = 2 * (p1.y - p0.y)
    
    return 0.5 * (p0.x * p2.y - p2.x * p0.y) + (b * c - a * d) / 6
}

public func CubicBezierSignedArea(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Double {
    
    let a = p3.x - p0.x + 3 * (p1.x - p2.x)
    let b = 3 * (p2.x + p0.x) - 6 * p1.x
    let c = 3 * (p1.x - p0.x)
    
    let d = p3.y - p0.y + 3 * (p1.y - p2.y)
    let e = 3 * (p2.y + p0.y) - 6 * p1.y
    let f = 3 * (p1.y - p0.y)
    
    return 0.5 * (p0.x * p3.y - p3.x * p0.y) + 0.1 * (b * d - a * e) + 0.25 * (c * d - a * f) + (c * e - b * f) / 6
}

public func ArcSignedArea(_ startAngle: Double, _ endAngle: Double, _ center: Point, _ radius: Radius) -> Double {
    
    let diffAngle = endAngle - startAngle
    let sin1 = sin(startAngle)
    let cos1 = cos(startAngle)
    let sin2 = sin(endAngle)
    let cos2 = cos(endAngle)
    let _sin = sin2 - sin1
    let _cos = cos2 - cos1
    return 0.5 * (radius.x * radius.y * diffAngle - radius.x * center.y * _cos + radius.y * center.x * _sin)
}
