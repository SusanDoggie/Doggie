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

extension Shape {
    
    private func render<T: Integer>(width: Int, height: Int, stencil: inout [T]) {
        
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
        
        func _bezier(_ p0: Point, _ p1: Point, _ p2: Point) {
            
            if let transform = SDTransform(from: p0, p1, p2, to: Point(x: 0, y: 0), Point(x: 0.5, y: 0), Point(x: 1, y: 1)) {
                _loop(p0, p1, p2) { x, y in
                    let _q = Point(x: x, y: y) * transform
                    return _q.x * _q.x - _q.y < 0
                }
            }
        }
        
        for component in self {
            
            if let first = component.first {
                
                var last = component.start
                
                switch first {
                case let .line(q1): last = q1
                case let .quad(q1, q2):
                    _bezier(last, q1, q2)
                    last = q2
                case let .cubic(q1, q2, q3):
                    last = q3
                }
                for segment in component.dropFirst() {
                    switch segment {
                    case let .line(q1):
                        _triangle(component.start, last, q1)
                        last = q1
                    case let .quad(q1, q2):
                        _triangle(component.start, last, q2)
                        _bezier(last, q1, q2)
                        last = q2
                    case let .cubic(q1, q2, q3):
                        _triangle(component.start, last, q3)
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
