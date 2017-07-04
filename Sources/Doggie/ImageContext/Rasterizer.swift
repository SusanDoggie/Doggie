//
//  Rasterizer.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

@_versioned
protocol RasterizeBufferProtocol {
    
    var width: Int { get }
    
    var height: Int { get }
    
    static func + (lhs: Self, rhs: Int) -> Self
    
    static func += (lhs: inout Self, rhs: Int)
    
}

extension RasterizeBufferProtocol {
    
    @_versioned
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Vector, Point, Self) throws -> Void) rethrows {
        
        let det = (p1.y - p2.y) * (p0.x - p2.x) + (p2.x - p1.x) * (p0.y - p2.y)
        
        if det.almostZero() {
            return
        }
        
        let s0 = (p1.y - p2.y) / det
        let s1 = (p2.x - p1.x) / det
        let t0 = (p2.y - p0.y) / det
        let t1 = (p0.x - p2.x) / det
        
        let s2 = s0 * p2.x + s1 * p2.y
        let t2 = t0 * p2.x + t1 * p2.y
        
        try self.rasterize(p0, p1, p2) { point, buf in
            
            let s = s0 * point.x + s1 * point.y - s2
            let t = t0 * point.x + t1 * point.y - t2
            
            try operation(Vector(x: s, y: t, z: 1 - s - t), point, buf)
        }
    }
    
    @_versioned
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Point, Self) throws -> Void) rethrows {
        
        if !Rect.bound([p0, p1, p2]).isIntersect(Rect(x: 0, y: 0, width: Double(width), height: Double(height))) {
            return
        }
        
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
        
        let d = cross(p1 - p0, p2 - p0)
        
        if !d.almostZero() {
            
            var q0 = p0
            var q1 = p1
            var q2 = p2
            
            sort(&q0, &q1, &q2) { $0.y < $1.y }
            
            let y0 = Int(q0.y.rounded().clamped(to: 0...Double(height - 1)))
            let y1 = Int(q1.y.rounded().clamped(to: 0...Double(height - 1)))
            let y2 = Int(q2.y.rounded().clamped(to: 0...Double(height - 1)))
            
            var buf = self
            
            if let (mid_x, _) = scan(q0, q2, q1.y) {
                
                buf += y0 * width
                
                @inline(__always)
                func _drawLoop(_ range: CountableClosedRange<Int>, _ x0: Double, _ dx0: Double, _ x1: Double, _ dx1: Double, operation: (Point, Self) throws -> Void) rethrows {
                    
                    let (min_x, min_dx, max_x, max_dx) = mid_x < q1.x ? (x0, dx0, x1, dx1) : (x1, dx1, x0, dx0)
                    
                    var _min_x = min_x
                    var _max_x = max_x
                    
                    for y in range {
                        let _y = Double(y)
                        if _min_x < _max_x && q0.y..<q2.y ~= _y {
                            let __min_x = Int(_min_x.rounded().clamped(to: 0...Double(width - 1)))
                            let __max_x = Int(_max_x.rounded().clamped(to: 0...Double(width - 1)))
                            var pixel = buf + __min_x
                            for x in __min_x...__max_x {
                                let _x = Double(x)
                                if _min_x..<_max_x ~= _x {
                                    try operation(Point(x: _x, y: _y), pixel)
                                }
                                pixel += 1
                            }
                        }
                        _min_x += min_dx
                        _max_x += max_dx
                        buf += width
                    }
                }
                
                if q1.y < Double(y1) {
                    
                    if let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                        
                        if y0 < y1, let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                            
                            try _drawLoop(y0...y1 - 1, x0, dx0, x1, dx1, operation: operation)
                        }
                        
                        try _drawLoop(y1...y2, x0, dx0, x2, dx2, operation: operation)
                        
                    } else if let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                        
                        try _drawLoop(y0...y1, x0, dx0, x1, dx1, operation: operation)
                    }
                } else {
                    
                    if let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                        
                        try _drawLoop(y0...y1, x0, dx0, x1, dx1, operation: operation)
                        
                        if y1 < y2, let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                            
                            try _drawLoop(y1 + 1...y2, x0 + dx0, dx0, x2 + dx2, dx2, operation: operation)
                        }
                    } else if let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                        
                        try _drawLoop(y1...y2, x0, dx0, x2, dx2, operation: operation)
                    }
                }
            }
            
        }
    }
    
}

