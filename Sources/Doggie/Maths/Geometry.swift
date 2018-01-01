//
//  Geometry.swift
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

@_inlineable
public func Collinear(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let d = p0.x * (p1.y - p2.y) + p1.x * (p2.y - p0.y) + p2.x * (p0.y - p1.y)
    return d.almostZero()
}

@_inlineable
public func CircleInside(_ p0: Point, _ p1: Point, _ p2: Point, _ q: Point) -> Bool? {
    
    func det(_ x0: Double, _ y0: Double, _ z0: Double,
             _ x1: Double, _ y1: Double, _ z1: Double,
             _ x2: Double, _ y2: Double, _ z2: Double) -> Double {
        
        return x0 * y1 * z2 +
            y0 * z1 * x2 +
            z0 * x1 * y2 -
            z0 * y1 * x2 -
            y0 * x1 * z2 -
            x0 * z1 * y2
    }
    
    let s = dot(q, q)
    
    let r = det(p0.x - q.x, p0.y - q.y, dot(p0, p0) - s,
                p1.x - q.x, p1.y - q.y, dot(p1, p1) - s,
                p2.x - q.x, p2.y - q.y, dot(p2, p2) - s)
    
    return r.almostZero() ? nil : r.sign == cross(p1 - p0, p2 - p0).sign
}

@_inlineable
public func Barycentric(_ p0: Point, _ p1: Point, _ p2: Point, _ q: Point) -> Vector? {
    
    let det = (p1.y - p2.y) * (p0.x - p2.x) + (p2.x - p1.x) * (p0.y - p2.y)
    
    if det.almostZero() {
        return nil
    }
    
    let s = ((p1.y - p2.y) * (q.x - p2.x) + (p2.x - p1.x) * (q.y - p2.y)) / det
    let t = ((p2.y - p0.y) * (q.x - p2.x) + (p0.x - p2.x) * (q.y - p2.y)) / det
    
    return Vector(x: s, y: t, z: 1 - s - t)
}

@_inlineable
public func inTriangle(_ p0: Point, _ p1: Point, _ p2: Point, _ position: Point) -> Bool {
    
    var q0 = p0
    var q1 = p1
    var q2 = p2
    
    sort(&q0, &q1, &q2) { $0.y < $1.y }
    
    if q0.y <= position.y && position.y < q2.y {
        
        let t1 = (position.y - q0.y) / (q2.y - q0.y)
        let x1 = q0.x + t1 * (q2.x - q0.x)
        
        let t2: Double
        let x2: Double
        
        if position.y < q1.y {
            t2 = (position.y - q0.y) / (q1.y - q0.y)
            x2 = q0.x + t2 * (q1.x - q0.x)
        } else {
            t2 = (position.y - q1.y) / (q2.y - q1.y)
            x2 = q1.x + t2 * (q2.x - q1.x)
        }
        
        let mid_t = (q1.y - q0.y) / (q2.y - q0.y)
        let mid_x = q0.x + mid_t * (q2.x - q0.x)
        
        if mid_x < q1.x {
            return x1 <= position.x && position.x < x2
        } else {
            return x2 <= position.x && position.x < x1
        }
    }
    
    return false
}

