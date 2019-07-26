//
//  VariableRoundStroke.swift
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

extension Shape.Component {
    
    private struct Circle {
        
        var center: Point
        var radius: Double
        
        init(center: Point, width: Double) {
            self.center = center
            self.radius = 0.5 * abs(width)
        }
        
        var shape: Shape.Component {
            return Shape.Component(ellipseIn: Rect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
        }
    }
    
    public func variableRoundStroke(widths: [Double]) -> [Shape.Component] {
        
        precondition(widths.count == self.count + 1, "invalid count of widths.")
        
        var last = Circle(center: self.start, width: widths[0])
        var last_max = last
        var result: [Shape.Component] = []
        
        for (width, segment) in zip(widths.dropFirst(), self) {
            
            let width = abs(width)
            
            switch segment {
            case let .line(p1):
                
                let current = Circle(center: p1, width: width)
                
                defer {
                    last = current
                    last_max = current.radius > last_max.radius ? current : last_max
                }
                
                let segment = LineSegment(last.center, p1)
                
                guard let s0 = segment.offset(last.radius, 0.5 * width) else { continue }
                guard let s1 = segment.offset(-last.radius, -0.5 * width) else { continue }
                
                result.append(Shape.Component(start: s0.p0, closed: true, segments: [.line(s0.p1), .line(s1.p1), .line(s1.p0)]))
                result.append(last_max.shape)
                
                last_max = current
                
            case let .quad(p1, p2):
                
                let current = Circle(center: p2, width: width)
                
                defer {
                    last = current
                    last_max = current.radius > last_max.radius ? current : last_max
                }
                
                let segment = QuadBezier(last.center, p1, p2)
                
                var _start: Point?
                var _reverse_start: Point?
                var segments1: [Shape.Segment] = []
                var segments2: [Shape.Segment] = []
                
                segment.offset(last.radius, 0.5 * width) { _, segment in
                    if _start == nil {
                        _start = segment.p0
                    }
                    segments1.append(.cubic(segment.p1, segment.p2, segment.p3))
                }
                
                guard let start = _start else { continue }
                
                segment.offset(-last.radius, -0.5 * width) { _, segment in
                    _reverse_start = segment.p3
                    segments2.append(.cubic(segment.p2, segment.p1, segment.p0))
                }
                
                guard let reverse_start = _reverse_start else { continue }
                
                result.append(Shape.Component(start: start, closed: true, segments: segments1 + [.line(reverse_start)] + segments2.reversed()))
                result.append(last_max.shape)
                
                last_max = current
                
            case let .cubic(p1, p2, p3):
                
                let current = Circle(center: p3, width: width)
                
                defer {
                    last = current
                    last_max = current.radius > last_max.radius ? current : last_max
                }
                
                let segment = CubicBezier(last.center, p1, p2, p3)
                
                var _start: Point?
                var _reverse_start: Point?
                var segments1: [Shape.Segment] = []
                var segments2: [Shape.Segment] = []
                
                segment.offset(last.radius, 0.5 * width) { _, segment in
                    if _start == nil {
                        _start = segment.p0
                    }
                    segments1.append(.cubic(segment.p1, segment.p2, segment.p3))
                }
                
                guard let start = _start else { continue }
                
                segment.offset(-last.radius, -0.5 * width) { _, segment in
                    _reverse_start = segment.p3
                    segments2.append(.cubic(segment.p2, segment.p1, segment.p0))
                }
                
                guard let reverse_start = _reverse_start else { continue }
                
                result.append(Shape.Component(start: start, closed: true, segments: segments1 + [.line(reverse_start)] + segments2.reversed()))
                result.append(last_max.shape)
                
                last_max = current
            }
        }
        
        if isClosed && !start.almostEqual(last.center) {
            
            let width = abs(widths[0])
            let segment = LineSegment(last.center, start)
            
            guard let s0 = segment.offset(last.radius, 0.5 * width) else { return result }
            guard let s1 = segment.offset(-last.radius, -0.5 * width) else { return result }
            
            result.append(Shape.Component(start: s0.p0, closed: true, segments: [.line(s0.p1), .line(s1.p1), .line(s1.p0)]))
        }
        
        result.append(last_max.shape)
        
        return result
    }
}

extension Shape {
    
    public func variableRoundStroke(widths: [Double]) -> Shape {
        
        var result: Shape = []
        var widths = ArraySlice(widths)
        
        for item in self.identity {
            result.append(contentsOf: item.variableRoundStroke(widths: Array(widths.prefix(item.count + 1))))
            widths = widths.dropFirst(item.count + 1)
        }
        
        return result
    }
}
