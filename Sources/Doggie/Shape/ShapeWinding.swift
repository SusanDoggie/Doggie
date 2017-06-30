//
//  ShapeWinding.swift
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
    
    public enum WindingRule {
        case nonZero
        case evenOdd
    }
    
    @_inlineable
    public func contains(_ p: Point, winding: WindingRule) -> Bool {
        switch winding {
        case .nonZero: return self.winding(p) != 0
        case .evenOdd: return self.winding(p) & 1 == 1
        }
    }
}

@inline(__always)
private func inTriangle(_ position: Point, _ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    
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

extension Shape.Component {
    
    public func winding(_ position: Point) -> Int {
        
        var counter = 0
        
        self.render {
            
            switch $0 {
            case let .triangle(p0, p1, p2):
                
                if inTriangle(position, p0, p1, p2) {
                    
                    let d = cross(p1 - p0, p2 - p0)
                    
                    if d.sign == .plus {
                        counter += 1
                    } else {
                        counter -= 1
                    }
                }
                
            case let .quadratic(p0, p1, p2):
                
                if inTriangle(position, p0, p1, p2) {
                    
                    if let p = Barycentric(p0, p1, p2, position) {
                        
                        let _q = p.x * Point(x: 0, y: 0) + p.y * Point(x: 0.5, y: 0) + p.z * Point(x: 1, y: 1)
                        
                        if _q.x * _q.x - _q.y < 0 {
                            
                            let d = cross(p1 - p0, p2 - p0)
                            
                            if d.sign == .plus {
                                counter += 1
                            } else {
                                counter -= 1
                            }
                        }
                    }
                }
                
            case let .cubic(p0, p1, p2, v0, v1, v2):
                
                if inTriangle(position, p0, p1, p2) {
                    
                    if let p = Barycentric(p0, p1, p2, position) {
                        
                        let v = p.x * v0 + p.y * v1 + p.z * v2
                        
                        if v.x * v.x * v.x - v.y * v.z < 0 {
                            
                            let d = cross(p1 - p0, p2 - p0)
                            
                            if d.sign == .plus {
                                counter += 1
                            } else {
                                counter -= 1
                            }
                        }
                    }
                }
            }
        }
        
        return counter
    }
}

extension Shape {
    
    @_inlineable
    public func winding(_ position: Point) -> Int {
        return self.identity.reduce(0) { $0 + $1.winding(position) }
    }
}
