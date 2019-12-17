//
//  Rasterizer.swift
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

@usableFromInline
protocol RasterizeBufferProtocol {
    
    var width: Int { get }
    
    var height: Int { get }
    
    static func + (lhs: Self, rhs: Int) -> Self
    
    static func += (lhs: inout Self, rhs: Int)
    
}

extension RasterizeBufferProtocol {
    
    @inlinable
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Vector, Point, Self) -> Void) {
        
        let det = (p1.y - p2.y) * (p0.x - p2.x) + (p2.x - p1.x) * (p0.y - p2.y)
        
        guard !det.almostZero() else { return }
        
        let _det = 1 / det
        
        let s0 = (p1.y - p2.y) * _det
        let s1 = (p2.x - p1.x) * _det
        let t0 = (p2.y - p0.y) * _det
        let t1 = (p0.x - p2.x) * _det
        
        let s2 = s0 * p2.x + s1 * p2.y
        let t2 = t0 * p2.x + t1 * p2.y
        
        self.rasterize(p0, p1, p2) { point, buf in
            
            let s = s0 * point.x + s1 * point.y - s2
            let t = t0 * point.x + t1 * point.y - t2
            
            operation(Vector(x: s, y: t, z: 1 - s - t), point, buf)
        }
    }
    
    @inlinable
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Point, Self) -> Void) {
        self._rasterize(p0, p1, p2) { x, y, buf in operation(Point(x: x, y: y), buf) }
    }
    
    @inlinable
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Self) -> Void) {
        self._rasterize(p0, p1, p2) { _, _, buf in operation(buf) }
    }
    
    @inlinable
    @inline(__always)
    func _rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Int, Int, Self) -> Void) {
        
        guard Rect.bound([p0, p1, p2]).isIntersect(Rect(x: 0, y: 0, width: Double(width), height: Double(height))) else { return }
        
        @inline(__always)
        func scan(_ p0: Point, _ p1: Point, _ y: Double) -> (Double, Double)? {
            let d = p1.y - p0.y
            if d.almostZero() {
                return nil
            }
            let _d = 1 / d
            let q = (p1.x - p0.x) * _d
            let r = (p0.x * p1.y - p1.x * p0.y) * _d
            return (q * y + r, q)
        }
        
        @inline(__always)
        func intRange(_ min: Double, _ max: Double, _ bound: Range<Int>) -> Range<Int> {
            
            let _min = min.rounded(.up)
            let _max = max.rounded(.down)
            
            let __min = Int(_min)
            let __max = Int(_max)
            
            guard __min <= __max else { return (__min..<__min).clamped(to: bound) }
            
            return _max == max ? (__min..<__max).clamped(to: bound) : Range(__min...__max).clamped(to: bound)
        }
        
        guard !cross(p1 - p0, p2 - p0).almostZero() else { return }
        
        var q0 = p0
        var q1 = p1
        var q2 = p2
        
        sort(&q0, &q1, &q2) { $0.y < $1.y }
        
        guard let (mid_x, _) = scan(q0, q2, q1.y) else { return }
        
        @inline(__always)
        func _drawLoop(_ s0: Point, _ s1: Point, operation: (Int, Int, Self) -> Void) {
            
            let y_range = intRange(s0.y, s1.y, 0..<height)
            
            var buf = self + y_range.lowerBound * width
            
            guard let (x0, dx0) = scan(q0, q2, Double(y_range.lowerBound)) else { return }
            guard let (x1, dx1) = scan(s0, s1, Double(y_range.lowerBound)) else { return }
            
            let (min_x, min_dx, max_x, max_dx) = mid_x < q1.x ? (x0, dx0, x1, dx1) : (x1, dx1, x0, dx0)
            
            var _min_x = min_x
            var _max_x = max_x
            
            for y in y_range {
                if _min_x < _max_x {
                    let x_range = intRange(_min_x, _max_x, 0..<width)
                    var pixel = buf + x_range.lowerBound
                    for x in x_range {
                        operation(x, y, pixel)
                        pixel += 1
                    }
                }
                _min_x += min_dx
                _max_x += max_dx
                buf += width
            }
        }
        
        _drawLoop(q0, q1, operation: operation)
        _drawLoop(q1, q2, operation: operation)
    }
    
}

