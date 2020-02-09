//
//  BezierOffset.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@inlinable
func _phase_diff(_ lhs: Double, _ rhs: Double, _ minus_signed: Bool) -> Double {
    var diff = lhs - rhs
    while diff < -.pi { diff += 2 * .pi }
    while .pi < diff { diff -= 2 * .pi }
    if diff.almostEqual(-.pi) || diff.almostEqual(.pi) {
        return minus_signed ? -.pi : .pi
    }
    return diff
}

@inlinable
func _phase_diff(_ lhs: Point, _ rhs: Point, _ minus_signed: Bool) -> Double {
    return _phase_diff(lhs.phase, rhs.phase, minus_signed)
}

public func CubicBezierFitting(_ p0: Point, _ p3: Point, _ m0: Point, _ m1: Point, _ points: [(Double, Point)]) -> CubicBezier<Point>? {
    
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
    
    let u = (_c2 * _b1 - _c1 * _b2) / t
    let v = (_c1 * _a2 - _c2 * _a1) / t
    
    return u < 0 || v < 0 ? nil : CubicBezier(p0, p0 + u * m0, p3 + v * m1, p3)
}

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
    public func _length(_ t: Double = 1) -> Double {
        switch self {
        case let bezier as LineSegment<Point>: return bezier.length(t)
        case let bezier as QuadBezier<Point>: return bezier.length(t)
        default:
            
            var p0 = self.start
            var sum = 0.0
            
            for _t in 1...16 {
                let p1 = self.eval(Double(_t) * t / 16)
                sum += p0.distance(to: p1)
                p0 = p1
            }
            
            return sum
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
    
    @inlinable
    public var _inflection: [Double] {
        switch self {
        case let bezier as CubicBezier<Point>: return Array(bezier.inflection)
        default: return []
        }
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    public func offset(_ a: Double) -> LineSegment? {
        
        if a.almostZero() {
            return self
        }
        
        let _x = p1.x - p0.x
        let _y = p1.y - p0.y
        
        if _x.almostZero() && _y.almostZero() {
            return nil
        }
        
        let m = sqrt(_x * _x + _y * _y)
        let s = a * _y / m
        let t = -a * _x / m
        
        return LineSegment(p0 + Point(x: s, y: t), p1 + Point(x: s, y: t))
    }
    
    @inlinable
    public func offset(_ a0: Double, _ a1: Double) -> LineSegment? {
        
        if a0.almostEqual(a1) { return self.offset(a0) }
        
        let r0 = abs(a0)
        let r1 = abs(a1)
        
        guard a0.sign == a1.sign || a0 == 0 || a1 == 0 else { return nil }
        let minus_signed = (a0 != 0 && a0.sign == .minus) || a1.sign == .minus
        
        let d = p1 - p0
        let m = d.magnitude
        let p = d.phase
        
        let _r = r1 - r0
        
        guard m > abs(_r) && !m.almostEqual(abs(_r)) else { return nil }
        
        let a = asin(_r / m)
        
        let x1, y1, x2, y2: Double
        
        if minus_signed {
            x1 = r0 * cos(0.5 * .pi + a)
            y1 = r0 * sin(0.5 * .pi + a)
            x2 = r1 * cos(0.5 * .pi + a)
            y2 = r1 * sin(0.5 * .pi + a)
        } else {
            x1 = r0 * cos(0.5 * .pi + a)
            y1 = -r0 * sin(0.5 * .pi + a)
            x2 = r1 * cos(0.5 * .pi + a)
            y2 = -r1 * sin(0.5 * .pi + a)
        }
        
        let t1 = SDTransform.rotate(p) * SDTransform.translate(x: p0.x, y: p0.y)
        let t2 = SDTransform.rotate(p) * SDTransform.translate(x: p1.x, y: p1.y)
        
        return LineSegment(Point(x: x1, y: y1) * t1, Point(x: x2, y: y2) * t2)
    }
}

extension BezierProtocol where Scalar == Double, Element == Point {
    
    @inlinable
    func __offset_arc(_ a: Double, _ last_direction: Point, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        let d0 = last_direction
        let d3 = self._direction(0).unit
        
        guard !d0.almostZero() && !d3.almostZero() else { return }
        
        let angle = _phase_diff(d3, d0, a.sign == .minus)
        guard !angle.almostZero() else { return }
        
        let arc = BezierArc(angle).map { a * $0 * SDTransform.rotate(d0.phase - 0.5 * .pi) + start }
        
        for i in 0..<arc.count / 3 {
            try calback(CubicBezier(arc[i * 3], arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
        }
    }
    @inlinable
    func __offset(_ a: Double, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        let d0 = self._direction(0).unit
        let d3 = self._direction(1).unit
        
        guard !d0.almostZero() && !d3.almostZero() else { return }
        
        let q0 = self.start.offset(dx: a * d0.y, dy: -a * d0.x)
        let q3 = self.end.offset(dx: a * d3.y, dy: -a * d3.x)
        
        let angle = _phase_diff(d3, d0, a.sign == .minus)
        
        if abs(angle) > 0.25 * .pi {
            
            let center = self.eval(0.5)
            let arc = BezierArc(angle).map { a * $0 * SDTransform.rotate(d0.phase - 0.5 * .pi) + center }
            
            for i in 0..<arc.count / 3 {
                try calback(CubicBezier(arc[i * 3], arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
            }
            
        } else {
            
            guard let m0 = self._offset_point(a, 0.25) else { return }
            guard let m1 = self._offset_point(a, 0.5) else { return }
            guard let m2 = self._offset_point(a, 0.75) else { return }
            
            if let curve = CubicBezierFitting(q0, q3, d0, -d3, [(0.25, m0), (0.5, m1), (0.75, m2)]) {
                try calback(curve)
            } else {
                try calback(LineSegment(q0, q3).elevated().elevated())
            }
        }
    }
    
    @inlinable
    func _offset(_ a: Double, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        var last_direction: Point?
        for segment in self.split((1..<degree).map { Double($0) / Double(degree) }) {
            
            if let d0 = last_direction {
                try segment.__offset_arc(a, d0, calback)
            }
            
            try segment.__offset(a, calback)
            
            last_direction = segment._direction(1).unit
        }
    }
    
    @inlinable
    func _offset2(_ a: Double, _ limit: Int, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        if limit > 0 && (abs(self._curvature(0)) > 1 || abs(self._curvature(1)) > 1) {
            let (segment1, segment2) = self.split(0.5)
            try segment1._offset2(a, limit - 1, calback)
            try segment2.__offset_arc(a, segment1._direction(1).unit, calback)
            try segment2._offset2(a, limit - 1, calback)
            return
        }
        
        try self.__offset(a, calback)
    }
    
    @inlinable
    public func offset(_ a: Double, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        let split = self._inflection + self._stationary
        let t = split.flatMap { abs(self._curvature($0)) > 0.05 ? [$0, $0 - 0.0625, $0 + 0.0625] : [$0] }.sorted().filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
        
        var last_direction: Point?
        for ((s, t), segment) in zip(zip(CollectionOfOne(0).concat(t), t.appended(1)), self.split(t)) where !s.almostEqual(t) {
            
            if let d0 = last_direction {
                try segment.__offset_arc(a, d0, calback)
            }
            
            let c = t - s
            if c > 0.125 {
                try segment._offset(a, calback)
            } else {
                try segment._offset2(a, 2, calback)
            }
            
            last_direction = segment._direction(1).unit
        }
    }
    
    @inlinable
    public func offset(_ a: Double) -> [CubicBezier<Point>] {
        var result: [CubicBezier<Point>] = []
        self.offset(a) { result.append($0) }
        return result
    }
}

extension BezierProtocol where Scalar == Double, Element == Point {
    
    @inlinable
    func __offset_arc(_ minus_signed: Bool, _ width: (Double) -> Point, _ last_direction: Point, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        func _offset_point(_ t: Double) -> (Point, Point)? {
            let q = self._direction(t)
            return q.almostZero() ? nil : (self.eval(t), width(t) * SDTransform.rotate(q.phase))
        }
        
        guard let (u0, v0) = _offset_point(0) else { return }
        
        let d0 = last_direction
        let d3 = v0.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
        
        guard !d0.almostZero() && !d3.almostZero() else { return }
        
        let angle = _phase_diff(d3, d0, minus_signed)
        guard !angle.almostZero() else { return }
        
        var a = (u0 + v0).distance(to: start)
        if minus_signed { a = -a }
        
        let arc = BezierArc(angle).map { a * $0 * SDTransform.rotate(d0.phase - 0.5 * .pi) + start }
        
        for i in 0..<arc.count / 3 {
            try calback(CubicBezier(arc[i * 3], arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
        }
    }
    @inlinable
    func __offset(_ minus_signed: Bool, _ width: (Double) -> Point, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        func _offset_point(_ t: Double) -> (Point, Point)? {
            let q = self._direction(t)
            return q.almostZero() ? nil : (self.eval(t), width(t) * SDTransform.rotate(q.phase))
        }
        
        guard let (u0, v0) = _offset_point(0) else { return }
        guard let (u1, v1) = _offset_point(1) else { return }
        
        let q0 = u0 + v0
        let q3 = u1 + v1
        
        let d0 = v0.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
        let d3 = v1.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
        
        let angle = _phase_diff(d3, d0, minus_signed)
        
        if abs(angle) > 0.25 * .pi {
            
            let center = self.eval(0.5)
            guard var a = _offset_point(0.5).map({ $0 + $1 })?.distance(to: center) else { return }
            if minus_signed { a = -a }
            
            let arc = BezierArc(angle).map { a * $0 * SDTransform.rotate(d0.phase - 0.5 * .pi) + center }
            
            for i in 0..<arc.count / 3 {
                try calback(CubicBezier(arc[i * 3], arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
            }
            
        } else {
            
            guard let m0 = _offset_point(0.25).map({ $0 + $1 }) else { return }
            guard let m1 = _offset_point(0.5).map({ $0 + $1 }) else { return }
            guard let m2 = _offset_point(0.75).map({ $0 + $1 }) else { return }
            
            if let curve = CubicBezierFitting(q0, q3, d0, -d3, [(0.25, m0), (0.5, m1), (0.75, m2)]) {
                try calback(curve)
            } else {
                try calback(LineSegment(q0, q3).elevated().elevated())
            }
        }
    }
    
    @inlinable
    func _offset(_ minus_signed: Bool, _ width: (Double) -> Point, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        let t = (1..<degree).map { Double($0) / Double(degree) }
        
        var last_direction: Point?
        for ((s, t), segment) in zip(zip(CollectionOfOne(0).concat(t), t.appended(1)), self.split(t)) {
            
            let c = t - s
            
            if let d0 = last_direction {
                try segment.__offset_arc(minus_signed, { width($0 * c + s) }, d0, calback)
            }
            
            try segment.__offset(minus_signed, { width($0 * c + s) }, calback)
            
            let r0 = width(t) * SDTransform.rotate(segment._direction(1).phase)
            last_direction = r0.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
        }
    }
    
    @inlinable
    func _offset2(_ minus_signed: Bool, _ width: (Double) -> Point, _ limit: Int, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        if limit > 0 && (abs(self._curvature(0)) > 1 || abs(self._curvature(1)) > 1) {
            
            let (segment1, segment2) = self.split(0.5)
            
            try segment1._offset2(minus_signed, { width($0 * 0.5) }, limit - 1, calback)
            
            do {
                let r0 = width(0.5) * SDTransform.rotate(segment1._direction(1).phase)
                let d0 = r0.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
                try segment2.__offset_arc(minus_signed, { width($0 * 0.5 + 0.5) }, d0, calback)
            }
            
            try segment2._offset2(minus_signed, { width($0 * 0.5 + 0.5) }, limit - 1, calback)
            
            return
        }
        
        try self.__offset(minus_signed, width, calback)
    }
    
    @inlinable
    public func offset(_ a0: Double, _ a1: Double, _ calback: (CubicBezier<Point>) throws -> Void) rethrows {
        
        if a0.almostEqual(a1) { return try self.offset(a0, calback) }
        
        guard a0.sign == a1.sign || a0 == 0 || a1 == 0 else { return }
        let minus_signed = (a0 != 0 && a0.sign == .minus) || a1.sign == .minus
        
        let length = self._length(1)
        guard let tangent = LineSegment(Point(), Point(x: length, y: 0)).offset(a0, a1) else { return }
        
        let split = self._inflection + self._stationary
        let t = self._inflection.flatMap { abs(self._curvature($0)) > 0.05 ? [$0, $0 - 0.0625, $0 + 0.0625] : [$0] }.sorted().filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
        
        func width(_ t: Double) -> Point {
            let s = self._length(t)
            return tangent.eval(s / length) - Point(x: s, y: 0)
        }
        
        var last_direction: Point?
        for ((s, t), segment) in zip(zip(CollectionOfOne(0).concat(t), t.appended(1)), self.split(t)) where !s.almostEqual(t) {
            
            let c = t - s
            
            if let d0 = last_direction {
                try segment.__offset_arc(minus_signed, { width($0 * c + s) }, d0, calback)
            }
            
            if c > 0.125 {
                try segment._offset(minus_signed, { width($0 * c + s) }, calback)
            } else {
                try segment._offset2(minus_signed, { width($0 * c + s) }, 2, calback)
            }
            
            let r0 = width(t) * SDTransform.rotate(segment._direction(1).phase)
            last_direction = r0.unit * SDTransform.rotate(minus_signed ? -0.5 * .pi : 0.5 * .pi)
        }
    }
    
    @inlinable
    public func offset(_ a0: Double, _ a1: Double) -> [CubicBezier<Point>] {
        var result: [CubicBezier<Point>] = []
        self.offset(a0, a1) { result.append($0) }
        return result
    }
}
