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
    public func _offset_point(_ a: Double, _ t: Double) -> Point? {
        
        let d = self.derivative()
        let q: Point
        
        if t.almostZero() {
            guard let _q = d.first(where: { !$0.almostZero() }) else { return nil }
            q = _q
        } else if t.almostEqual(1) {
            guard let _q = d.last(where: { !$0.almostZero() }) else { return nil }
            q = _q
        } else {
            q = d.eval(t)
        }
        
        let m = q.magnitude
        guard !m.almostZero() else { return nil }
        
        return self.eval(t).offset(dx: a * q.y / m, dy: -a * q.x / m)
    }
    
    @inlinable
    func _offset(_ a: Double, _ calback: (ClosedRange<Double>, CubicBezier<Point>) throws -> Void) rethrows {
        
        let n = 1 << degree
        var s = 0.0
        
        for _t in stride(from: 0, through: n, by: 1).dropFirst() {
            
            let t = Double(_t) / Double(n)
            
            let u0 = 2 * s - t
            let u3 = 2 * t - s
            
            guard let q0 = self._offset_point(a, u0) else { return }
            guard let q1 = self._offset_point(a, s) else { return }
            guard let q2 = self._offset_point(a, t) else { return }
            guard let q3 = self._offset_point(a, u3) else { return }
            
            let m0 = q2 - q0
            let m1 = q3 - q1
            
            try calback(s...t, CubicBezier(q1, q1 + m0 / 6, q2 - m1 / 6, q2))
            
            s = t
        }
    }
    
    @inlinable
    public func offset(_ a: Double, _ calback: (ClosedRange<Double>, CubicBezier<Point>) throws -> Void) rethrows {
        
        var t: [Double]
        
        switch self {
        case let bezier as QuadBezier<Point>:
            
            if a.almostZero() {
                try calback(0...1, bezier.elevated())
                return
            }
            
            t = bezier.stationary.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
            
        case let bezier as CubicBezier<Point>:
            
            if a.almostZero() {
                try calback(0...1, bezier)
                return
            }
            
            t = bezier.inflection.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
            t.append(contentsOf: bezier.stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
            
        case let bezier as Bezier<Point>:
            
            t = bezier.inflection.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
            t.append(contentsOf: bezier.stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
            
        default: t = []
        }
        
        if t.count == 0 {
            try _offset(a, calback)
        } else {
            t.sort()
            for ((s, t), segment) in zip(zip(CollectionOfOne(0).concat(t), t.appended(1)), self.split(t)) {
                let c = t - s
                try segment._offset(a) { try calback($0.lowerBound * c + s ... $0.upperBound * c + s, $1) }
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
