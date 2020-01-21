//
//  VariableRoundStroke.swift
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

extension LineSegment where Element == Point {
    
    fileprivate func _offset(_ a0: Double, _ a1: Double) -> (Point, Point, [Shape.Segment])? {
        guard let line = self.offset(a0, a1) else { return nil }
        return a0.sign == .plus ? (line.p0, line.p1, [.line(line.p1)]) : (line.p1, line.p0, [.line(line.p0)])
    }
}

extension BezierProtocol where Scalar == Double, Element == Point {
    
    fileprivate func _offset(_ a0: Double, _ a1: Double) -> (Point, Point, [Shape.Segment])? {
        
        var start = Point()
        var segments: [Shape.Segment] = []
        
        if a0.sign == .plus {
            
            self.offset(a0, a1) { _, segment in
                if segments.isEmpty {
                    start = segment.p0
                }
                segments.append(.cubic(segment.p1, segment.p2, segment.p3))
            }
            
            return segments.last.map { (start, $0.end, segments) }
            
        } else {
            
            self.offset(a0, a1) { _, segment in
                start = segment.p3
                segments.append(.cubic(segment.p2, segment.p1, segment.p0))
            }
            
            return segments.first.map { (start, $0.end, segments) }
        }
    }
}

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
        
        let widths = widths.map { abs($0) }
        
        var last = Circle(center: self.start, width: widths[0])
        var last_max: Circle?
        var result: [Shape.Component] = []
        
        var start = Point()
        var reverse_start = Point()
        var segments1: [Shape.Segment] = []
        var segments2: [Shape.Segment] = []
        
        func add_round_node(_ p0: Point, _ p1: Point, _ center: Point, _ join: Bool, _ reverse: Bool, _ segments: inout [Shape.Segment]) {
            
            guard !p0.almostEqual(p1) else { return }
            
            let radius = p0.distance(to: center)
            guard !radius.almostZero() else { return }
            
            let a0 = (p0 - center).phase
            let a1 = (p1 - center).phase
            
            let angle = join ? _phase_diff(a1, a0, false) : positive_mod(a1 - a0, 2 * .pi)
            let arc = BezierArc(angle).map { radius * $0 * SDTransform.rotate(a0) + center }
            
            if reverse {
                for i in (0..<arc.count / 3).reversed() {
                    segments.append(.cubic(arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
                }
            } else {
                for i in 0..<arc.count / 3 {
                    segments.append(.cubic(arc[i * 3 + 1], arc[i * 3 + 2], arc[i * 3 + 3]))
                }
            }
        }
        
        func flush(_ center: Point) {
            guard let l0 = segments1.last?.end else { return }
            add_round_node(l0, reverse_start, center, false, false, &segments1)
            result.append(Shape.Component(start: start, closed: true, segments: segments1 + segments2.reversed()))
            segments1.removeAll(keepingCapacity: true)
            segments2.removeAll(keepingCapacity: true)
        }
        
        func add_segment(_ current: Circle, _ _segments1: (Point, Point, [Shape.Segment])?, _ _segments2: (Point, Point, [Shape.Segment])?) {
            
            if let (p0, _, s0) = _segments1, let (q0, q1, s1) = _segments2 {
                
                if let circle = last_max {
                    if circle.radius > last.radius { result.append(circle.shape) }
                    last_max = nil
                }
                
                if let l0 = segments1.last?.end {
                    add_round_node(l0, p0, last.center, true, false, &segments1)
                    add_round_node(q1, reverse_start, last.center, true, true, &segments2)
                } else {
                    add_round_node(q1, p0, last.center, false, false, &segments1)
                    start = q1
                }
                reverse_start = q0
                
                segments1.append(contentsOf: s0)
                segments2.append(contentsOf: s1)
                
            } else if !segments1.isEmpty {
                
                flush(current.center)
                
            } else {
                
                last_max = last_max.map { current.radius > $0.radius ? current : $0 } ?? current
            }
        }
        
        for (width, segment) in zip(widths.dropFirst(), self) {
            
            let current: Circle
            
            let _segments1: (Point, Point, [Shape.Segment])?
            let _segments2: (Point, Point, [Shape.Segment])?
            
            switch segment {
            case let .line(p1):
                
                let segment = LineSegment(last.center, p1)
                current = Circle(center: p1, width: width)
                _segments1 = segment._offset(last.radius, current.radius)
                _segments2 = segment._offset(-last.radius, -current.radius)
                
            case let .quad(p1, p2):
                
                let segment = QuadBezier(last.center, p1, p2)
                current = Circle(center: p2, width: width)
                _segments1 = segment._offset(last.radius, current.radius)
                _segments2 = segment._offset(-last.radius, -current.radius)
                
            case let .cubic(p1, p2, p3):
                
                let segment = CubicBezier(last.center, p1, p2, p3)
                current = Circle(center: p3, width: width)
                _segments1 = segment._offset(last.radius, current.radius)
                _segments2 = segment._offset(-last.radius, -current.radius)
            }
            
            add_segment(current, _segments1, _segments2)
            last = current
        }
        
        if isClosed && !start.almostEqual(last.center) {
            
            let current = Circle(center: start, width: widths[0])
            let segment = LineSegment(last.center, start)
            
            add_segment(current, segment._offset(last.radius, current.radius), segment._offset(-last.radius, -current.radius))
            flush(start)
            
        } else {
            flush(last.center)
            if let circle = last_max { result.append(circle.shape) }
        }
        
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
