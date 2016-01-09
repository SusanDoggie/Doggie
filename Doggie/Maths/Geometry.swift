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

extension Radius: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "{x: \(x), y: \(y)}"
    }
    public var debugDescription: String {
        return "{x: \(x), y: \(y)}"
    }
}

extension Radius: Hashable {
    
    public var hashValue: Int {
        return hash(x, y)
    }
}

@warn_unused_result
public func == (lhs: Radius, rhs: Radius) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

@warn_unused_result
public func Ellipse(t: Double, _ p: Point, _ r: Radius) -> Point {
    return Point(x: r.x * cos(t) + p.x, y: r.y * sin(t) + p.y)
}

@warn_unused_result
public func EllipseRadius(p0: Point, _ p1: Point, _ r: Radius, _ rotate: Double) -> Radius {
    let _p = p1 - p0
    let _tx = _p.x * cos(rotate) + _p.y * sin(rotate)
    let _ty = _p.y * cos(rotate) - _p.x * sin(rotate)
    let _atan = atan2(_ty / r.y, _tx / r.x)
    return Radius(x: _tx / (2 * cos(_atan)), y: _ty / (2 * sin(_atan)))
}

@warn_unused_result
public func EllipseCenter(r: Radius, _ rotate: Double, _ a: Point, _ b: Point) -> [Point] {
    
    let _sin = sin(rotate)
    let _cos = cos(rotate)
    
    let ax = a.x * _cos + a.y * _sin / r.x
    let ay = a.y * _cos - a.x * _sin / r.y
    let bx = b.x * _cos + b.y * _sin / r.x
    let by = b.y * _cos - b.x * _sin / r.y
    
    let dx = ax - bx
    let dy = ay - by
    let d = dx * dx + dy * dy
    
    if d == 4 {
        let _x = (ax + bx) * r.x * 0.5
        let _y = (ay + by) * r.y * 0.5
        return [Point(x: _x * _cos - _y * _sin, y: _x * _sin + _y * _cos)]
    } else if d < 4 {
        let _x = (ax + bx) * r.x * 0.5
        let _y = (ay + by) * r.y * 0.5
        let _t = sqrt((1 - d * 0.25) / d)
        
        let cx1 = _x + _t * (ay - by) * r.x
        let cy1 = _y + _t * (bx - ax) * r.y
        let cx2 = _x - _t * (ay - by) * r.x
        let cy2 = _y - _t * (bx - ax) * r.y
        
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
@warn_unused_result
public func EllipseStationary(r: Radius, _ a: Double, _ b: Double) -> Double {
    return atan2(r.y * b, r.x * a)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ A cos(t) ⎞
///     ⎜ d e f ⎟ ⎜ B sin(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝    1     ⎠
///
@warn_unused_result
public func EllipseBound<T: SDTransformType>(center: Point, _ r: Radius, _ matrix: T) -> Rect {
    
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

@warn_unused_result
public func Bezier(t: Double, _ p: Double ... ) -> Double {
    return Bezier(t, p)
}

@warn_unused_result
public func Bezier(t: Double, _ p: Point ... ) -> Point {
    return Bezier(t, p)
}

@warn_unused_result
public func Bezier(t: Double, _ p: Vector ... ) -> Vector {
    return Bezier(t, p)
}

@warn_unused_result
public func SplitBezier(t: Double, _ p: Double ... ) -> ([Double], [Double]) {
    return SplitBezier(t, p)
}

@warn_unused_result
public func SplitBezier(t: Double, _ p: Point ... ) -> ([Point], [Point]) {
    return SplitBezier(t, p)
}

@warn_unused_result
public func SplitBezier(t: Double, _ p: Vector ... ) -> ([Vector], [Vector]) {
    return SplitBezier(t, p)
}

@warn_unused_result
public func BezierDerivative(t: Double, _ p: Double ... ) -> Double {
    return Bezier(t, BezierDerivative(p))
}

@warn_unused_result
public func BezierDerivative(t: Double, _ p: Point ... ) -> Point {
    return Bezier(t, BezierDerivative(p))
}

@warn_unused_result
public func BezierDerivative(t: Double, _ p: Vector ... ) -> Vector {
    return Bezier(t, BezierDerivative(p))
}

@warn_unused_result
public func BezierDerivative(p: Double ... ) -> [Double] {
    return BezierDerivative(p)
}

@warn_unused_result
public func BezierDerivative(p: Point ... ) -> [Point] {
    return BezierDerivative(p)
}

@warn_unused_result
public func BezierDerivative(p: Vector ... ) -> [Vector] {
    return BezierDerivative(p)
}

private func Bezier(t: Double, _ p: [Double]) -> Double {
    var result: Double = 0
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerate() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

private func Bezier(t: Double, _ p: [Point]) -> Point {
    var result = Point(x: 0, y: 0)
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerate() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

private func Bezier(t: Double, _ p: [Vector]) -> Vector {
    var result = Vector(x: 0, y: 0, z: 0)
    let _n = p.count - 1
    for (idx, k) in CombinationList(UInt(_n)).enumerate() {
        let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
        result += b * p[idx]
    }
    return result
}

private func BezierPolynomial(p: [Double]) -> Polynomial {
    
    var result = PermutationList(UInt(p.count - 1)).map(Double.init) as Array
    for i in result.indices {
        var sum = 0.0
        let fact = Array(FactorialList(UInt(i)))
        for (j, f) in zip(fact, fact.reverse()).map(*).enumerate() {
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

@warn_unused_result
public func BezierPolynomial(p: Double ... ) -> Polynomial {
    
    return BezierPolynomial(p)
}

@warn_unused_result
public func ClosestBezier(point: Point, _ b0: Point, _ b1: Point, _ b2: Point) -> Double {
    
    let x: Polynomial = [b0.x - point.x, 2 * (b1.x - b0.x), b0.x - 2 * b1.x + b2.x]
    let y: Polynomial = [b0.y - point.y, 2 * (b1.y - b0.y), b0.y - 2 * b1.y + b2.y]
    
    let dot = x * x + y * y
    let _dot = dot.derivative
    
    return _dot.roots.minElement { dot.eval($0) }!
}

@warn_unused_result
public func ClosestBezier(point: Point, _ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point) -> Double {
    
    let x: Polynomial = [b0.x - point.x, 3 * (b1.x - b0.x), 3 * (b2.x + b0.x) - 6 * b1.x, b3.x + 3 * (b1.x - b2.x) - b0.x]
    let y: Polynomial = [b0.y - point.y, 3 * (b1.y - b0.y), 3 * (b2.y + b0.y) - 6 * b1.y, b3.y + 3 * (b1.y - b2.y) - b0.y]
    
    let dot = x * x + y * y
    let _dot = dot.derivative
    
    return _dot.roots.minElement { dot.eval($0) }!
}

@warn_unused_result
public func ClosestBezier(point: Point, _ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ b4: Point , _ b5: Point ... ) -> Double {
    
    let list = [b0, b1, b2, b3, b4] + b5
    
    var x = BezierPolynomial(list.map { $0.x })
    var y = BezierPolynomial(list.map { $0.y })
    
    x[0] -= point.x
    y[0] -= point.y
    
    let dot = x * x + y * y
    let _dot = dot.derivative
    
    return _dot.roots.minElement { dot.eval($0) }!
}

private func SplitBezier(t: Double, _ p: [Double]) -> ([Double], [Double]) {
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

private func SplitBezier(t: Double, _ p: [Point]) -> ([Point], [Point]) {
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

private func SplitBezier(t: Double, _ p: [Vector]) -> ([Vector], [Vector]) {
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

private func BezierDerivative(p: [Double]) -> [Double] {
    let n = Double(p.count)
    var de = [Double]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
}

private func BezierDerivative(p: [Point]) -> [Point] {
    let n = Double(p.count)
    var de = [Point]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
}

private func BezierDerivative(p: [Vector]) -> [Vector] {
    let n = Double(p.count)
    var de = [Vector]()
    var lastPoint = p.first!
    for current in p.dropFirst() {
        de.append(n * (current - lastPoint))
        lastPoint = current
    }
    return de
}

@warn_unused_result
public func QuadBezierStationary(p0: Double, _ p1: Double, _ p2: Double) -> Double? {
    let d = p0 + p2 - 2 * p1
    if d.almostZero {
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
@warn_unused_result
public func QuadBezierStationary(p0: Point, _ p1: Point, _ p2: Point, _ a: Double, _ b: Double) -> Double? {
    let d = a * (p0.x + p2.x - 2 * p1.x) + b * (p0.y + p2.y - 2 * p1.y)
    if d.almostZero {
        return nil
    }
    return (a * (p0.x - p1.x) + b * (p0.y - p1.y)) / d
}

@warn_unused_result
public func CubicBezierStationary(p0: Double, _ p1: Double, _ p2: Double, _ p3: Double) -> [Double] {
    let _a = 3 * (p3 - p0) + 9 * (p1 - p2)
    let _b = 6 * (p2 + p0) - 12 * p1
    let _c = 3 * (p1 - p0)
    if _a.almostZero {
        if _b.almostZero {
            return []
        }
        let t = -_c / _b
        return [t]
    } else {
        let delta = _b * _b - 4 * _a * _c
        let _a2 = 2 * _a
        let _b2 = -_b / _a2
        if !delta.isSignMinus {
            let sqrt_delta = sqrt(delta) / _a2
            let t1 = _b2 + sqrt_delta
            let t2 = _b2 - sqrt_delta
            return [t1, t2]
        } else if delta.almostZero {
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
@warn_unused_result
public func CubicBezierStationary(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ a: Double, _ b: Double) -> [Double] {
    let _ax = 3 * (p3.x - p0.x) + 9 * (p1.x - p2.x)
    let _bx = 6 * (p2.x + p0.x) - 12 * p1.x
    let _cx = 3 * (p1.x - p0.x)
    let _ay = 3 * (p3.y - p0.y) + 9 * (p1.y - p2.y)
    let _by = 6 * (p2.y + p0.y) - 12 * p1.y
    let _cy = 3 * (p1.y - p0.y)
    let _a = a * _ax + b * _ay
    let _b = a * _bx + b * _by
    let _c = a * _cx + b * _cy
    if _a.almostZero {
        if _b.almostZero {
            return []
        }
        let t = -_c / _b
        return [t]
    } else {
        let delta = _b * _b - 4 * _a * _c
        let _a2 = 2 * _a
        let _b2 = -_b / _a2
        if !delta.isSignMinus {
            let sqrt_delta = sqrt(delta) / _a2
            let t1 = _b2 + sqrt_delta
            let t2 = _b2 - sqrt_delta
            return [t1, t2]
        } else if delta.almostZero {
            return [_b2]
        }
    }
    return []
}

@warn_unused_result
public func QuadBezierBound(p0: Point, _ p1: Point, _ p2: Point) -> Rect {
    
    let tx = [0.0, QuadBezierStationary(p0.x, p1.x, p2.x).map { $0.clamp(0...1) } ?? 0.0, 1.0]
    let ty = [0.0, QuadBezierStationary(p0.y, p1.y, p2.y).map { $0.clamp(0...1) } ?? 0.0, 1.0]
    
    let _x = tx.map { Bezier($0, p0.x, p1.x, p2.x) }
    let _y = ty.map { Bezier($0, p0.y, p1.y, p2.y) }
    
    let minX = _x.minElement()!
    let minY = _y.minElement()!
    let maxX = _x.maxElement()!
    let maxY = _y.maxElement()!
    
    return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
@warn_unused_result
public func QuadBezierBound<T: SDTransformType>(p0: Point, _ p1: Point, _ p2: Point, _ matrix: T) -> Rect {
    
    let tx = [0.0, QuadBezierStationary(p0, p1, p2, matrix.a, matrix.b).map { $0.clamp(0...1) } ?? 0.0, 1.0]
    let ty = [0.0, QuadBezierStationary(p0, p1, p2, matrix.d, matrix.e).map { $0.clamp(0...1) } ?? 0.0, 1.0]
    
    let _x = tx.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2)
        return matrix.a * _p.x + matrix.b * _p.y
    }
    let _y = ty.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2)
        return matrix.d * _p.x + matrix.e * _p.y
    }
    
    let minX = _x.minElement()!
    let minY = _y.minElement()!
    let maxX = _x.maxElement()!
    let maxY = _y.maxElement()!
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

@warn_unused_result
public func CubicBezierBound(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Rect {
    
    let tx = [0.0, 1.0] + CubicBezierStationary(p0.x, p1.x, p2.x, p3.x).lazy.map { $0.clamp(0...1) }
    let ty = [0.0, 1.0] + CubicBezierStationary(p0.y, p1.y, p2.y, p3.y).lazy.map { $0.clamp(0...1) }
    
    let _x = tx.map { Bezier($0, p0.x, p1.x, p2.x, p3.x) }
    let _y = ty.map { Bezier($0, p0.y, p1.y, p2.y, p3.y) }
    
    let minX = _x.minElement()!
    let minY = _y.minElement()!
    let maxX = _x.maxElement()!
    let maxY = _y.maxElement()!
    
    return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ B_x(t) ⎞
///     ⎜ d e f ⎟ ⎜ B_y(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝   1    ⎠
///
@warn_unused_result
public func CubicBezierBound<T: SDTransformType>(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ matrix: T) -> Rect {
    
    let tx = [0.0, 1.0] + CubicBezierStationary(p0, p1, p2, p3, matrix.a, matrix.b).lazy.map { $0.clamp(0...1) }
    let ty = [0.0, 1.0] + CubicBezierStationary(p0, p1, p2, p3, matrix.d, matrix.e).lazy.map { $0.clamp(0...1) }
    
    let _x = tx.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2, p3)
        return matrix.a * _p.x + matrix.b * _p.y
    }
    let _y = ty.map { t -> Double in
        let _p = Bezier(t, p0, p1, p2, p3)
        return matrix.d * _p.x + matrix.e * _p.y
    }
    
    let minX = _x.minElement()!
    let minY = _y.minElement()!
    let maxX = _x.maxElement()!
    let maxY = _y.maxElement()!
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

@warn_unused_result
public func BezierArc(angle: Double) -> [Point] {
    
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
    
    while _angle > 0 {
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
            let t = ClosestBezier(end, result[_a], result[_b], result[_c], result[_d])
            let split = SplitBezier(t, result[_a], result[_b], result[_c], result[_d]).0
            result[_b] = split[1]
            result[_c] = split[2]
            result[_d] = end
        }
        _angle -= M_PI_2
        counter += 1
    }
    return angle.isSignMinus ? result.map { Point(x: $0.x, y: -$0.y) } : result
}

@warn_unused_result
public func CubicBezierSelfIntersect(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> (Double, Double)? {
    
    let a = p3.x - p0.x + 3 * (p1.x - p2.x)
    if a.almostZero {
        return nil
    }
    
    let b = (3 * (p0.x + p2.x) - 6 * p1.x) / a
    let c = (3 * (p1.x - p0.x)) / a
    
    let d = p3.y - p0.y + 3 * (p1.y - p2.y)
    if d.almostZero {
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
        return (roots.minElement()!, roots.maxElement()!)
    }
    
    return nil
}

@warn_unused_result
public func LinesIntersect(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Point? {
    
    let d = (p0.x - p1.x) * (p2.y - p3.y) - (p0.y - p1.y) * (p2.x - p3.x)
    if d.almostZero {
        return nil
    }
    let a = (p0.x * p1.y - p0.y * p1.x) / d
    let b = (p2.x * p3.y - p2.y * p3.x) / d
    return Point(x: (p2.x - p3.x) * a - (p0.x - p1.x) * b, y: (p2.y - p3.y) * a - (p0.y - p1.y) * b)
}

@warn_unused_result
public func EllipseLineIntersect<T: SDTransformType>(center: Point, _ radius: Radius, _ matrix: T, _ p0: Point, _ p1: Point) -> [Point]? {
    
    let transform = matrix * SDTransform.Translate(x: center.x, y: center.y) * SDTransform.Scale(x: radius.x, y: radius.y)
    let inverse = transform.inverse
    let _p0 = inverse * p0
    let _p1 = inverse * p1
    let dx = _p1.x - _p0.x
    let dy = _p1.y - _p0.y
    let dr = dx * dx + dy * dy
    if dr.almostZero {
        return nil
    }
    let D = _p0.x * _p1.y - _p1.x * _p0.y
    let delta = dr - D * D
    if delta.almostZero {
        
        return [transform * Point(x: D * dy / dr, y: -D * dx / dr)]
        
    } else if delta > 0 {
        
        let _sqrt = sqrt(delta)
        let s_x = dx * _sqrt
        let s_y = dy * _sqrt
        let t_x = D * dy
        let t_y = -D * dx
        
        return [transform * Point(x: (t_x - s_x) / dr, y: (t_y - s_y) / dr), transform * Point(x: (t_x + s_x) / dr, y: (t_y + s_y) / dr)]
    }
    return []
}

@warn_unused_result
public func EllipsesIntersect<T1: SDTransformType, T2: SDTransformType>(c1: Point, _ r1: Radius, _ m1: T1, _ c2: Point, _ r2: Radius, _ m2: T2) -> [Point]? {
    
    let _m1 = m1 * SDTransform.Translate(x: c1.x, y: c1.y) * SDTransform.Scale(x: r1.x, y: r1.y)
    let _m2 = m2 * SDTransform.Translate(x: c2.x, y: c2.y) * SDTransform.Scale(x: r2.x, y: r2.y)
    let inverse = _m2.inverse * _m1
    
    let a = inverse.a
    let b = inverse.b
    let c = inverse.c
    let d = inverse.d
    let e = inverse.e
    let f = inverse.f
    
    let A = a * a + d * d
    let B = 2 * a * b + 2 * d * e
    let C = b * b + e * e
    let D = 2 * a * c + 2 * d * f
    let E = 2 * b * c + 2 * e * f
    let F = c * c + f * f - 1
    
    let _a = A - D + F
    let _b = 2 * (E - B)
    let _c = 4 * C - 2 * (A - F)
    let _d = 2 * (B + E)
    let _e = A + D + F
    
    let poly = Polynomial(_e, _d, _c, _b, _a)
    return poly.all({ $0.almostZero }) ? nil : poly.roots.map { t in
        let t2 = t * t
        return _m1 * Point(x: (1 - t2) / (t2 + 1), y: 2 * t / (t2 + 1))
    }
}

@warn_unused_result
public func QuadBezierLineIntersect(b0: Point, _ b1: Point, _ b2: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let u0: Polynomial = [
        b0.x - l0.x,
        2 * (b1.x - b0.x),
        b0.x - 2 * b1.x + b2.x
    ]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [
        b0.y - l0.y,
        2 * (b1.y - b0.y),
        b0.y - 2 * b1.y + b2.y
    ]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all({ $0.almostZero }) ? nil : poly.roots
}

@warn_unused_result
public func CubicBezierLineIntersect(b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let u0: Polynomial = [
        b0.x - l0.x,
        3 * (b1.x - b0.x),
        3 * (b2.x + b0.x) - 6 * b1.x,
        b3.x - b0.x + 3 * (b1.x - b2.x)
    ]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [
        b0.y - l0.y,
        3 * (b1.y - b0.y),
        3 * (b2.y + b0.y) - 6 * b1.y,
        b3.y - b0.y + 3 * (b1.y - b2.y)
    ]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all({ $0.almostZero }) ? nil : poly.roots
}

@warn_unused_result
public func QuadBezierEllipseIntersect<T: SDTransformType>(b0: Point, _ b1: Point, _ b2: Point, _ center: Point, _ radius: Radius, _ matrix: T) -> [Double]? {
    
    let _m = matrix * SDTransform.Translate(x: center.x, y: center.y) * SDTransform.Scale(x: radius.x, y: radius.y)
    
    let inverse = _m.inverse
    let _b0 = inverse * b0
    let _b1 = inverse * b1
    let _b2 = inverse * b2
    
    let x2 = _b0.x - 2 * _b1.x + _b2.x
    let x1 = 2 * (_b1.x - _b0.x)
    let x0 = _b0.x
    
    let y2 = _b0.y - 2 * _b1.y + _b2.y
    let y1 = 2 * (_b1.y - _b0.y)
    let y0 = _b0.y
    
    let _a = x2 * x2 + y2 * y2
    let _b = 2 * (x2 * x1 + y2 * y1)
    let _c = x1 * x1 + y1 * y1 + 2 * (x2 * x0 + y2 * y0)
    let _d = 2 * (x1 * x0 + y1 * y0)
    let _e = x0 * x0 + y0 * y0 - 1
    
    let poly = Polynomial(_e, _d, _c, _b, _a)
    return poly.all({ $0.almostZero }) ? nil : poly.roots
}

@warn_unused_result
public func QuadBeziersIntersect(b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ b4: Point, _ b5: Point) -> [Double]? {
    
    let u0: Polynomial = [
        b0.x - b3.x,
        2 * (b1.x - b0.x),
        b0.x - 2 * b1.x + b2.x
    ]
    let u1 = 2 * (b3.x - b4.x)
    let u2 = 2 * b4.x - b3.x -  b5.x
    
    let v0: Polynomial = [
        b0.y - b3.y,
        2 * (b1.y - b0.y),
        b0.y - 2 * b1.y + b2.y
    ]
    let v1 = 2 * (b3.y - b4.y)
    let v2 = 2 * b4.y - b3.y -  b5.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all({ $0.almostZero }) ? nil : det.roots
}

@warn_unused_result
public func CubicBezierEllipseIntersect<T: SDTransformType>(b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ center: Point, _ radius: Radius, _ matrix: T) -> [Double]? {
    
    let _m = matrix * SDTransform.Translate(x: center.x, y: center.y) * SDTransform.Scale(x: radius.x, y: radius.y)
    
    let inverse = _m.inverse
    let _b0 = inverse * b0
    let _b1 = inverse * b1
    let _b2 = inverse * b2
    let _b3 = inverse * b3
    
    let x3 = _b3.x - _b0.x + 3 * (_b1.x - _b2.x)
    let x2 = 3 * (_b2.x + _b0.x) - 6 * _b1.x
    let x1 = 3 * (_b1.x - _b0.x)
    let x0 = _b0.x
    
    let y3 = _b3.y - _b0.y + 3 * (_b1.y - _b2.y)
    let y2 = 3 * (_b2.y + _b0.y) - 6 * _b1.y
    let y1 = 3 * (_b1.y - _b0.y)
    let y0 = _b0.y
    
    let _a = x3 * x3 + y3 * y3
    let _b = 2 * (x3 * x2 + y3 * y2)
    let _c = 2 * (x3 * x1 + y3 * y1) + x2 * x2 + y2 * y2
    let _d = 2 * (x3 * x0 + x2 * x1 + y3 * y0 + y2 * y1)
    let _e = 2 * (x2 * x0 + y2 * y0) + x1 * x1 + y1 * y1
    let _f = 2 * (x1 * x0 + y1 * y0)
    let _g = x0 * x0 + y0 * y0 - 1
    
    let poly = Polynomial(_g, _f, _e, _d, _c, _b, _a)
    return poly.all({ $0.almostZero }) ? nil : poly.roots
}

@warn_unused_result
public func CubicQuadBezierIntersect(c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ q0: Point, _ q1: Point, _ q2: Point) -> [Double]? {
    
    let u0: Polynomial = [
        c0.x - q0.x,
        3 * (c1.x - c0.x),
        3 * (c2.x + c0.x) - 6 * c1.x,
        c3.x - c0.x + 3 * (c1.x - c2.x)
    ]
    let u1 = 2 * (q0.x - q1.x)
    let u2 = 2 * q1.x - q0.x - q2.x
    
    let v0: Polynomial = [
        c0.y - q0.y,
        3 * (c1.y - c0.y),
        3 * (c2.y + c0.y) - 6 * c1.y,
        c3.y - c0.y + 3 * (c1.y - c2.y)
    ]
    let v1 = 2 * (q0.y - q1.y)
    let v2 = 2 * q1.y - q0.y - q2.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all({ $0.almostZero }) ? nil : det.roots
}

@warn_unused_result
public func CubicBeziersIntersect(c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ c4: Point, _ c5: Point, _ c6: Point, _ c7: Point) -> [Double]? {
    
    let u0: Polynomial = [
        c0.x - c4.x,
        3 * (c1.x - c0.x),
        3 * (c2.x + c0.x) - 6 * c1.x,
        c3.x - c0.x + 3 * (c1.x - c2.x)
    ]
    let u1 = 3 * (c4.x - c5.x)
    let u2 = 6 * c5.x - 3 * (c6.x + c4.x)
    let u3 = c4.x - c7.x + 3 * (c6.x - c5.x)
    
    let v0: Polynomial = [
        c0.y - c4.y,
        3 * (c1.y - c0.y),
        3 * (c2.y + c0.y) - 6 * c1.y,
        c3.y - c0.y + 3 * (c1.y - c2.y)
    ]
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
    
    let a = m11 * m22 - m12 * m21
    let b = m12 * m20 - m10 * m22
    let c = m10 * m21 - m11 * m20
    let det = m00 * a + m01 * b + m02 * c
    return det.all({ $0.almostZero }) ? nil : det.roots
}

// MARK: Winding Number

private func _integral(n: Double, _ b: Double, _ c: Double) -> Double {
    
    let delta = b * b - 4 * c
    
    if delta.almostZero {
        return 4 * n / (b * (2 + b))
    }
    if delta.isSignMinus {
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

private func _integral(m: Double, _ n: Double, _ b: Double, _ c: Double) -> Double {
    
    let _m = 0.5 * m
    return _m * log(abs(1 + (1 + b) / c)) + _integral(n - _m * b, b, c)
}

private func _integral(m: Double, _ n: Double, _ b: Double, _ c: Double, _ r: Int) -> Double {
    
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

@warn_unused_result
public func LineWinding(p0: Point, _ p1: Point) -> Double {
    
    let x0 = p0.x
    let x1 = p1.x - p0.x
    let y0 = p0.y
    let y1 = p1.y - p0.y
    
    if x1.almostZero && y1.almostZero {
        return 0
    }
    
    let m = x0 * y1 - x1 * y0
    let a = x1 * x1 + y1 * y1
    let b = 2 * (x0 * x1 + y0 * y1)
    let c = x0 * x0 + y0 * y0
    
    return a.almostZero ? 0 : 0.5 * M_1_PI * _integral(m / a, b / a, c / a)
}

private enum PartialPolynomial {
    
    case One(Double, Int)
    case Two(Double, Double, Int)
}

extension PartialPolynomial {
    
    var degree : Int {
        switch self {
        case One: return 1
        case Two: return 2
        }
    }
    var power : Int {
        switch self {
        case One(_, let p): return p
        case Two(_, _, let p): return p
        }
    }
    var polynomial : Polynomial {
        switch self {
        case One(let a, _): return [a, 1]
        case Two(let a, let b, _): return [a, b, 1]
        }
    }
}

extension PartialPolynomial {
    
    var a : Double {
        switch self {
        case One(let a, _): return a
        case Two(let a, _, _): return a
        }
    }
    func almostEqual(p: Double) -> Bool {
        switch self {
        case One(let a, _): return (p - a).almostZero
        case Two(_, _, _): return false
        }
    }
    func almostEqual(p: (Double, Double)) -> Bool {
        switch self {
        case One(_, _): return false
        case Two(let a, let b, _): return (p.0 - a).almostZero && (p.1 - b).almostZero
        }
    }
}

private func appendPartialPolynomial(inout p: [PartialPolynomial], _ poly: Double) {
    let power = p.lazy.filter { $0.almostEqual(poly) }.maxElement { $0.power }?.power ?? 0
    p.append(.One(poly, power + 1))
}

private func appendPartialPolynomial(inout p: [PartialPolynomial], _ poly: (Double, Double)) {
    let delta = poly.1 * poly.1 - 4 * poly.0
    if delta.almostZero {
        appendPartialPolynomial(&p, 0.5 * poly.1)
        appendPartialPolynomial(&p, 0.5 * poly.1)
    } else if delta > 0 {
        let _sqrt = sqrt(delta)
        appendPartialPolynomial(&p, 0.5 * (poly.1 - _sqrt))
        appendPartialPolynomial(&p, 0.5 * (poly.1 + _sqrt))
    } else {
        let power = p.lazy.filter { $0.almostEqual(poly) }.maxElement { $0.power }?.power ?? 0
        p.append(.Two(poly.0, poly.1, power + 1))
    }
}

private func degree6RationalIntegral(p: Polynomial, _ q: Polynomial) -> Double {
    
    var partials: [PartialPolynomial] = []
    
    let _p = p / q.last!
    let _q = q / q.last!
    let (quo, rem) = remquo(_p, _q)
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
            matrix.appendContentsOf(m.map { $0.eval(0) })
            m = m.map { $0.derivative }
        }
        if MatrixElimination(_q.degree, &matrix) {
            var c = matrix.collect(_q.degree.stride(to: matrix.count, by: _q.degree + 1)).generate()
            for part in partials {
                switch part {
                case .One(let a, let n):
                    let s = c.next()!
                    if n == 1 {
                        result += s * log(abs(1 + 1 / a))
                    } else {
                        let _n = Double(1 - n)
                        result += s * pow(a + 1, _n) * pow(a, _n) / _n
                    }
                case .Two(let a, let b, let n):
                    let s = c.next()!
                    let t = c.next()!
                    result += _integral(t, s, b, a, n)
                }
            }
        }
    }
    
    return result
}

@warn_unused_result
public func QuadBezierWinding(p0: Point, _ p1: Point, _ p2: Point) -> Double {
    
    let x: Polynomial = [p0.x, 2 * (p1.x - p0.x), p0.x - 2 * p1.x + p2.x]
    let y: Polynomial = [p0.y, 2 * (p1.y - p0.y), p0.y - 2 * p1.y + p2.y]
    
    return 0.5 * M_1_PI * degree6RationalIntegral(x * y.derivative - x.derivative * y, x * x + y * y)
}

@warn_unused_result
public func CubicBezierWinding(p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Double {
    
    let x: Polynomial = [p0.x, 3 * (p1.x - p0.x), 3 * (p2.x + p0.x) - 6 * p1.x, p3.x - p0.x + 3 * (p1.x - p2.x)]
    let y: Polynomial = [p0.y, 3 * (p1.y - p0.y), 3 * (p2.y + p0.y) - 6 * p1.y, p3.y - p0.y + 3 * (p1.y - p2.y)]
    
    return 0.5 * M_1_PI * degree6RationalIntegral(x * y.derivative - x.derivative * y, x * x + y * y)
}
