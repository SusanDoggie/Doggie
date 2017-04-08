//
//  ShapeRasterize.swift
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

extension Shape {
    
    private func render<T: SignedInteger>(width: Int, height: Int, stencil: inout [T]) {
        
        assert(stencil.count == width * height, "incorrect size of stencil.")
        
        if stencil.count == 0 {
            return
        }
        
        func sort<T>(_ a: inout T, _ b: inout T, _ c: inout T, compare: (T, T) -> Bool) {
            if compare(b, a) { swap(&a, &b) }
            if compare(c, b) { swap(&b, &c) }
            if compare(b, a) { swap(&a, &b) }
        }
        
        func _loop(_ p0: Point, _ p1: Point, _ p2: Point, body: (Int, Int) -> Bool) {
            
            let d = cross(p1 - p0, p2 - p0)
            
            if !d.almostZero() {
                var q0 = p0
                var q1 = p1
                var q2 = p2
                
                sort(&q0, &q1, &q2) { $0.y < $1.y }
                
                func intersect(_ p0: Point, _ p1: Point, y: Double) -> Double? {
                    let d = p1.y - p0.y
                    if d.almostZero() {
                        return nil
                    }
                    return ((p1.x - p0.x) * y - p1.x * p0.y + p0.x * p1.y) / d
                }
                
                let min_y = Swift.max(0, Int(q0.y.rounded()))
                let max_y = Swift.min(height - 1, Int(q2.y.rounded()))
                
                stencil.withUnsafeMutableBufferPointer {
                    if var buf = $0.baseAddress {
                        buf += min_y * width
                        for y in min_y...max_y {
                            let _y = Double(y)
                            if let x1 = _y < q1.y ? intersect(q0, q1, y: _y) : intersect(q1, q2, y: _y), let x2 = intersect(q0, q2, y: _y) {
                                let min_x = Swift.max(0, Int(Swift.min(x1, x2).rounded()))
                                let max_x = Swift.min(width, Int(Swift.max(x1, x2).rounded()))
                                var pixel = buf + min_x
                                for x in min_x..<max_x {
                                    if body(x, y) {
                                        if d.sign == .plus {
                                            pixel.pointee += 1 as T
                                        } else {
                                            pixel.pointee -= 1 as T
                                        }
                                    }
                                    pixel += 1
                                }
                            }
                            buf += width
                        }
                    }
                }
            }
        }
        
        func _triangle(_ p0: Point, _ p1: Point, _ p2: Point) {
            
            _loop(p0, p1, p2) { _ in true }
        }
        
        func _quad(_ p0: Point, _ p1: Point, _ p2: Point) {
            
            if let transform = SDTransform(from: p0, p1, p2, to: Point(x: 0, y: 0), Point(x: 0.5, y: 0), Point(x: 1, y: 1)) {
                _loop(p0, p1, p2) { x, y in
                    let _q = Point(x: x, y: y) * transform
                    return _q.x * _q.x - _q.y < 0
                }
            }
        }
        func _cubic(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
            
            let q0 = p0
            let q1 = 3 * (p1 - p0)
            let q2 = 3 * (p2 + p0) - 6 * p1
            let q3 = p3 - p0 + 3 * (p1 - p2)
            
            let d1 = cross(q3, q0) - cross(q2, q0) - cross(q3, q2)
            let d2 = cross(q1, q0) - cross(q3, q0) + cross(q3, q1)
            let d3 = cross(q2, q0) - cross(q1, q0) - cross(q2, q1)
            
            let discr = 3 * d2 * d2 - 4 * d1 * d3
            
            func _drawCubic(_ p0: Point, _ p1: Point, _ p2: Point, _ v0: Vector, _ v1: Vector, _ v2: Vector) {
                
                _loop(p0, p1, p2) { x, y in
                    if let p = Barycentric(p0, p1, p2, Point(x: x, y: y)) {
                        let v = p.x * v0 + p.y * v1 + p.z * v2
                        return v.x * v.x * v.x - v.y * v.z > 0
                    }
                    return false
                }
            }
            
            func draw(_ k0: Vector, _ k1: Vector, _ k2: Vector, _ k3: Vector) {
                
                let v0 = k0
                let v1 = k0 + k1 / 3
                let v2 = k0 + (2 * k1 + k2) / 3
                let v3 = k0 + k1 + k2 + k3
                
                if !CircleInside(p0, p1, p2, p3) {
                    _drawCubic(p0, p1, p2, v0, v1, v2)
                }
                if !CircleInside(p0, p2, p3, p1) {
                    _drawCubic(p0, p2, p3, v0, v2, v3)
                }
                if !CircleInside(p1, p2, p3, p0) {
                    _drawCubic(p1, p2, p3, v1, v2, v3)
                }
                if !CircleInside(p0, p1, p3, p2) {
                    _drawCubic(p0, p1, p3, v0, v1, v3)
                }
            }
            
            if d1.almostZero() {
                
                if d2.almostZero() {
                    
                    if !d3.almostZero(), let intersect = LinesIntersect(p0, p1, p2, p3) {
                        _quad(p0, intersect, p3)
                    }
                } else {
                    
                    // cusp with cusp at infinity
                    
                    let tl = d3
                    let sl = 3 * d2
                    
                    let tl2 = tl * tl
                    let sl2 = sl * sl
                    
                    let k0 = Vector(x: tl, y: tl2 * tl, z: 1)
                    let k1 = Vector(x: -sl, y: -3 * sl * tl2, z: 0)
                    let k2 = Vector(x: 0, y: 3 * sl2 * tl, z: 0)
                    let k3 = Vector(x: 0, y: -sl2 * sl, z: 0)
                    
                    draw(k0, k1, k2, k3)
                }
                
            } else {
                
                if discr.almostZero() || discr > 0 {
                    
                    // serpentine
                    
                    let delta = sqrt(Swift.max(0, discr)) / sqrt(3)
                    
                    let tl = d2 + delta
                    let sl = 2 * d1
                    let tm = d2 - delta
                    let sm = 2 * d1
                    
                    let tl2 = tl * tl
                    let sl2 = sl * sl
                    let tm2 = tm * tm
                    let sm2 = sm * sm
                    
                    let k0 = Vector(x: tl * tm, y: tl2 * tl, z: tm2 * tm)
                    let k1 = Vector(x: -sm * tl - sl * tm, y: -3 * sl * tl2, z: -3 * sm * tm2)
                    let k2 = Vector(x: sl * sm, y: 3 * sl2 * tl, z: 3 * sm2 * tm)
                    let k3 = Vector(x: 0, y: -sl2 * sl, z: -sm2 * sm)
                    
                    draw(k0, k1, k2, k3)
                    
                } else {
                    
                    // loop
                    
                    let delta = sqrt(-discr)
                    
                    let td = d2 + delta
                    let sd = 2 * d1
                    let te = d2 - delta
                    let se = 2 * d1
                    
                    let td2 = td * td
                    let sd2 = sd * sd
                    let te2 = te * te
                    let se2 = se * se
                    
                    let k0 = Vector(x: td * te, y: td2 * te, z: td * te2)
                    let k1 = Vector(x: -se * td - sd * te, y: -se * td2 - 2 * sd * te * td, z: -sd * te2 - 2 * se * td * te)
                    let k2 = Vector(x: sd * se, y: te * sd2 + 2 * se * td * sd, z: td * se2 + 2 * sd * te * se)
                    let k3 = Vector(x: 0, y: -sd2 * se, z: -sd * se2)
                    
                    draw(k0, k1, k2, k3)
                }
            }
        }
        
        for component in self {
            
            if let first = component.first {
                
                var last = component.start
                
                switch first {
                case let .line(q1): last = q1
                case let .quad(q1, q2):
                    _quad(last, q1, q2)
                    last = q2
                case let .cubic(q1, q2, q3):
                    _cubic(last, q1, q2, q3)
                    last = q3
                }
                for segment in component.dropFirst() {
                    switch segment {
                    case let .line(q1):
                        _triangle(component.start, last, q1)
                        last = q1
                    case let .quad(q1, q2):
                        _triangle(component.start, last, q2)
                        _quad(last, q1, q2)
                        last = q2
                    case let .cubic(q1, q2, q3):
                        _triangle(component.start, last, q3)
                        _cubic(last, q1, q2, q3)
                        last = q3
                    }
                }
            }
        }
    }
    
    @_specialize(Int8) @_specialize(Int16) @_specialize(Int32) @_specialize(Int64) @_specialize(Int)
    public func raster<T: SignedInteger>(width: Int, height: Int, stencil: inout [T]) {
        
        return self.identity.render(width: width, height: width, stencil: &stencil)
    }
}
