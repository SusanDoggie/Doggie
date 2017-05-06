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

extension Shape.Component {
    
    public func winding(_ p: Point) -> Int {
        
        var winding = 0
        
        if self.count != 0 {
            
            let end = self.end
            
            let minY = Swift.min(start.y, end.y)
            let maxY = Swift.max(start.y, end.y)
            
            if (minY - 1e-14...maxY + 1e-14).contains(p.y) {
                
                let s = start.y - end.y
                if !s.almostZero() {
                    let t = -end.y / s
                    let x = end.x + t * (start.x - end.x)
                    
                    if t.almostZero() || t.almostEqual(1) {
                        if (p.x < x) == (end.y < start.y) {
                            winding += 1
                        } else {
                            winding -= 1
                        }
                    } else {
                        if (p.x < x) == (end.y < start.y) {
                            winding += 2
                        } else {
                            winding -= 2
                        }
                    }
                }
            }
        }
        
        for (p0, segment) in self.spaces.search(y: p.y - 1e-14...p.y + 1e-14).lazy.map({ self.bezier[$0] }) {
            switch segment {
            case let .line(p1):
                
                let s = p1.y - p0.y
                if !s.almostZero() {
                    let t = -p0.y / s
                    let x = p0.x + t * (p1.x - p0.x)
                    
                    if t.almostZero() || t.almostEqual(1) {
                        if (p.x < x) == (p0.y < p1.y) {
                            winding += 1
                        } else {
                            winding -= 1
                        }
                    } else {
                        if (p.x < x) == (p0.y < p1.y) {
                            winding += 2
                        } else {
                            winding -= 2
                        }
                    }
                }
                
            case let .quad(p1, p2):
                
                let _poly = Bezier(p0.y, p1.y, p2.y).polynomial - p.y
                
                if !_poly.almostZero() {
                    
                    let x_bezier = Bezier(p0.x, p1.x, p2.x)
                    let derivative = Bezier(p0, p1, p2).derivative()
                    
                    for t in _poly.roots.filter({ $0.almostZero() || $0.almostEqual(1) || 0...1 ~= $0 }) {
                        
                        let x = x_bezier.eval(t)
                        let dy = derivative.eval(t).y
                        
                        if !dy.almostZero() {
                            
                            if t.almostZero() || t.almostEqual(1) {
                                if (p.x < x) == (dy > 0) {
                                    winding += 1
                                } else {
                                    winding -= 1
                                }
                            } else {
                                if (p.x < x) == (dy > 0) {
                                    winding += 2
                                } else {
                                    winding -= 2
                                }
                            }
                        }
                    }
                }
                
            case let .cubic(p1, p2, p3):
                
                let _poly = Bezier(p0.y, p1.y, p2.y, p3.y).polynomial - p.y
                
                if !_poly.almostZero() {
                    
                    let x_bezier = Bezier(p0.x, p1.x, p2.x, p3.x)
                    let derivative = Bezier(p0, p1, p2, p3).derivative()
                    
                    let roots = _poly.roots.filter({ $0.almostZero() || $0.almostEqual(1) || 0...1 ~= $0 })
                    
                    for t in roots {
                        
                        let x = x_bezier.eval(t)
                        let dy = derivative.eval(t).y
                        
                        if dy.almostZero() {
                            if roots.count == 1 {
                                if t.almostZero() {
                                    if (p.x < x) == (p3.y > 0) {
                                        winding += 1
                                    } else {
                                        winding -= 1
                                    }
                                } else if t.almostEqual(1) {
                                    if (p.x < x) == (p0.y < 0) {
                                        winding += 1
                                    } else {
                                        winding -= 1
                                    }
                                } else if p0.y.sign != p3.y.sign {
                                    if (p.x < x) == (p0.y < p3.y) {
                                        winding += 2
                                    } else {
                                        winding -= 2
                                    }
                                }
                            }
                        } else {
                            if t.almostZero() || t.almostEqual(1) {
                                if (p.x < x) == (dy > 0) {
                                    winding += 1
                                } else {
                                    winding -= 1
                                }
                            } else {
                                if (p.x < x) == (dy > 0) {
                                    winding += 2
                                } else {
                                    winding -= 2
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return winding >> 1
    }
}

extension Shape {
    
    public func winding(_ p: Point) -> Int {
        return self.identity.reduce(0) { $0 + $1.winding(p) }
    }
}

