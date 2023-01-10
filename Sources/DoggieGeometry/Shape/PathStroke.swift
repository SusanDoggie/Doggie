//
//  PathStroke.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Shape {
    
    public enum LineCap: CaseIterable {
        case butt
        case round
        case square
    }
    
    public enum LineJoin: Hashable {
        case miter(limit: Double)
        case round
        case bevel
    }
}

extension Shape {
    
    fileprivate struct StrokeBuffer {
        
        enum Segment {
            case line(Point, Point)
            case quad(Point, Point, Point)
            case cubic(Point, Point, Point, Point)
        }
        var width: Double
        var cap: LineCap
        var join: LineJoin
        
        var path: [Shape.Component] = []
        
        var buffer1: [Shape.Segment] = []
        var buffer2: [Shape.Segment] = []
        var first: Segment?
        var last: Segment?
        var start = Point()
        var reverse_start = Point()
        
        init(width: Double, cap: LineCap, join: LineJoin) {
            self.width = width
            self.cap = cap
            self.join = join
        }
    }
}

extension Shape.StrokeBuffer.Segment {
    
    var _invisible: Bool {
        switch self {
        case let .line(p0, p1): return p0.almostEqual(p1)
        case let .quad(p0, _, p2): return p0.almostEqual(p2)
        case let .cubic(p0, p1, p2, p3): return p0.almostEqual(p1) && p1.almostEqual(p2) && p2.almostEqual(p3)
        }
    }
    
    var start: Point {
        switch self {
        case let .line(p, _): return p
        case let .quad(p, _, _): return p
        case let .cubic(p, _, _, _): return p
        }
    }
    
    var end: Point {
        switch self {
        case let .line(_, p): return p
        case let .quad(_, _, p): return p
        case let .cubic(_, _, _, p): return p
        }
    }
    
    var start_direction: Point {
        switch self {
        case let .line(p0, p1): return p1 - p0
        case let .quad(p0, p1, p2):
            let z0 = p1 - p0
            if z0.x.almostZero() && z0.y.almostZero() {
                return p2 - p1
            }
            return z0
        case let .cubic(p0, p1, p2, p3):
            let z0 = p1 - p0
            if z0.x.almostZero() && z0.y.almostZero() {
                let z1 = p2 - p1
                if z1.x.almostZero() && z1.y.almostZero() {
                    return p3 - p2
                }
                return z1
            }
            return z0
        }
    }
    
    var end_direction: Point {
        switch self {
        case let .line(p0, p1): return p1 - p0
        case let .quad(p0, p1, p2):
            let z1 = p2 - p1
            if z1.x.almostZero() && z1.y.almostZero() {
                return p1 - p0
            }
            return z1
        case let .cubic(p0, p1, p2, p3):
            let z2 = p3 - p2
            if z2.x.almostZero() && z2.y.almostZero() {
                let z1 = p2 - p1
                if z1.x.almostZero() && z1.y.almostZero() {
                    return p1 - p0
                }
                return z1
            }
            return z2
        }
    }
}

extension Shape.StrokeBuffer {
    
    mutating func flush() {
        
        guard let first = first, let last = last else { return }
        
        var cap_buffer: [Shape.Segment] = []
        switch cap {
        case .butt: buffer1.append(.line(reverse_start))
        case .round:
            do {
                let last_point = last.end
                let a = last.end_direction.phase - 0.5 * .pi
                let r = 0.5 * width
                let _bezier_circle = bezier_circle.lazy.map { $0 * SDTransform.rotate(a) * r + last_point }
                buffer1.append(.cubic(_bezier_circle[1], _bezier_circle[2], _bezier_circle[3]))
                buffer1.append(.cubic(_bezier_circle[4], _bezier_circle[5], _bezier_circle[6]))
            }
            do {
                let start_point = first.start
                let a = first.start_direction.phase - 0.5 * .pi
                let r = -0.5 * width
                let _bezier_circle = bezier_circle.lazy.map { $0 * SDTransform.rotate(a) * r + start_point }
                cap_buffer.append(.cubic(_bezier_circle[1], _bezier_circle[2], _bezier_circle[3]))
                cap_buffer.append(.cubic(_bezier_circle[4], _bezier_circle[5], _bezier_circle[6]))
            }
        case .square:
            do {
                let d = last.end_direction
                let m = d.magnitude
                let u = width * 0.5 * d.y / m
                let v = -width * 0.5 * d.x / m
                buffer1.append(.line(last.end + Point(x: u - v, y: v + u)))
                buffer1.append(.line(last.end - Point(x: u + v, y: v - u)))
                buffer1.append(.line(reverse_start))
            }
            do {
                let d = first.start_direction
                let m = d.magnitude
                let u = -width * 0.5 * d.y / m
                let v = width * 0.5 * d.x / m
                cap_buffer.append(.line(first.start + Point(x: u - v, y: v + u)))
                cap_buffer.append(.line(first.start - Point(x: u + v, y: v - u)))
                cap_buffer.append(.line(start))
            }
        }
        
        var component = Shape.Component(start: start, closed: true, segments: buffer1)
        component.append(contentsOf: buffer2.reversed())
        component.append(contentsOf: cap_buffer)
        path.append(component)
        
        self.buffer1.removeAll(keepingCapacity: true)
        self.buffer2.removeAll(keepingCapacity: true)
        self.first = nil
        self.last = nil
    }
    
    mutating func addJoin(_ segment: Segment) {
        
        guard let last = last else { return }
        
        let ph0 = last.end_direction.phase
        let ph1 = segment.start_direction.phase
        let angle = _phase_diff(ph1, ph0, false)
        
        guard !angle.almostZero() else { return }
        
        switch join {
        case let .miter(limit):
            if limit * sin(0.5 * (.pi - abs(angle))) < 1 {
                do {
                    let d = segment.start_direction
                    let m = d.magnitude
                    let u = width * 0.5 * d.y / m
                    let v = -width * 0.5 * d.x / m
                    buffer1.append(.line(segment.start + Point(x: u, y: v)))
                }
                buffer2.append(.line(reverse_start))
            } else {
                if angle > 0 {
                    do {
                        let d0 = last.end_direction
                        let m0 = d0.magnitude
                        let u0 = width * 0.5 * d0.y / m0
                        let v0 = -width * 0.5 * d0.x / m0
                        
                        let d1 = segment.start_direction
                        let m1 = d1.magnitude
                        let u1 = width * 0.5 * d1.y / m1
                        let v1 = -width * 0.5 * d1.x / m1
                        
                        let p0 = last.end + Point(x: u0, y: v0)
                        let p1 = p0 + Point(x: -v0, y: u0)
                        let q0 = segment.start + Point(x: u1, y: v1)
                        let q1 = q0 + Point(x: -v1, y: u1)
                        if let intersect = LineSegment(p0, p1).intersect(LineSegment(q0, q1)) {
                            buffer1.append(.line(intersect))
                        }
                        buffer1.append(.line(q0))
                    }
                    buffer2.append(.line(reverse_start))
                } else {
                    do {
                        let d = segment.start_direction
                        let m = d.magnitude
                        let u = width * 0.5 * d.y / m
                        let v = -width * 0.5 * d.x / m
                        buffer1.append(.line(segment.start + Point(x: u, y: v)))
                    }
                    do {
                        let d0 = segment.start_direction
                        let m0 = d0.magnitude
                        let u0 = -width * 0.5 * d0.y / m0
                        let v0 = width * 0.5 * d0.x / m0
                        
                        let d1 = last.end_direction
                        let m1 = d1.magnitude
                        let u1 = -width * 0.5 * d1.y / m1
                        let v1 = width * 0.5 * d1.x / m1
                        
                        let p0 = segment.start + Point(x: u0, y: v0)
                        let p1 = p0 + Point(x: -v0, y: u0)
                        let q0 = last.end + Point(x: u1, y: v1)
                        let q1 = q0 + Point(x: -v1, y: u1)
                        buffer2.append(.line(q0))
                        if let intersect = LineSegment(p0, p1).intersect(LineSegment(q0, q1)) {
                            buffer2.append(.line(intersect))
                        }
                        reverse_start = p0
                    }
                }
            }
        case .round:
            do {
                let a = ph0 - 0.5 * .pi
                let r = 0.5 * width
                let bezierArc = BezierArc(angle).lazy.map { $0 * SDTransform.rotate(a) * r + segment.start }
                for i in 0..<bezierArc.count / 3 {
                    buffer1.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                }
            }
            do {
                let a = ph1 - 0.5 * .pi
                let r = -0.5 * width
                let bezierArc = BezierArc(-angle).lazy.map { $0 * SDTransform.rotate(a) * r + segment.start }
                reverse_start = bezierArc[0]
                for i in (0..<bezierArc.count / 3).reversed() {
                    buffer2.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                }
            }
        default: break
        }
    }
    
    mutating func closePath() {
        
        guard let first = first else { return }
        
        switch join {
        case .bevel: break
        default: self.addJoin(first)
        }
        
        path.append(Shape.Component(start: start, closed: true, segments: buffer1))
        path.append(Shape.Component(start: reverse_start, closed: true, segments: buffer2.reversed()))
        
        self.buffer1.removeAll(keepingCapacity: true)
        self.buffer2.removeAll(keepingCapacity: true)
        self.first = nil
        self.last = nil
    }
    
    mutating func addSegment(_ segment: Segment) {
        
        if segment._invisible { return }
        
        var flag = false
        
        if first == nil {
            flag = true
            first = segment
        } else {
            switch join {
            case .bevel:
                do {
                    let d = segment.start_direction
                    let m = d.magnitude
                    let u = width * 0.5 * d.y / m
                    let v = -width * 0.5 * d.x / m
                    buffer1.append(.line(segment.start + Point(x: u, y: v)))
                }
                buffer2.append(.line(reverse_start))
            default: self.addJoin(segment)
            }
        }
        last = segment
        
        switch segment {
        case let .line(p0, p1):
            if let segment = LineSegment(p0, p1).offset(width * 0.5) {
                if flag {
                    start = segment.p0
                }
                buffer1.append(.line(segment.p1))
            }
            if let segment = LineSegment(p0, p1).offset(-width * 0.5) {
                reverse_start = segment.p1
                buffer2.append(.line(segment.p0))
            }
        case let .quad(p0, p1, p2):
            var flag2 = true
            QuadBezier(p0, p1, p2).offset(width * 0.5) { segment in
                if flag && flag2 {
                    start = segment.p0
                    flag2 = false
                }
                buffer1.append(.cubic(segment.p1, segment.p2, segment.p3))
            }
            QuadBezier(p0, p1, p2).offset(-width * 0.5) { segment in
                reverse_start = segment.p3
                buffer2.append(.cubic(segment.p2, segment.p1, segment.p0))
            }
        case let .cubic(p0, p1, p2, p3):
            var flag2 = true
            CubicBezier(p0, p1, p2, p3).offset(width * 0.5) { segment in
                if flag && flag2 {
                    start = segment.p0
                    flag2 = false
                }
                buffer1.append(.cubic(segment.p1, segment.p2, segment.p3))
            }
            CubicBezier(p0, p1, p2, p3).offset(-width * 0.5) { segment in
                reverse_start = segment.p3
                buffer2.append(.cubic(segment.p2, segment.p1, segment.p0))
            }
        }
    }
    
}

extension Shape {
    
    public func strokePath(width: Double, cap: LineCap, join: LineJoin) -> Shape {
        
        var buffer = StrokeBuffer(width: abs(width), cap: cap, join: join)
        buffer.path.reserveCapacity(self.count << 1)
        
        for item in self.identity {
            var last = item.start
            for segment in item {
                switch segment {
                case let .line(p1):
                    buffer.addSegment(.line(last, p1))
                    last = p1
                case let .quad(p1, p2):
                    buffer.addSegment(.quad(last, p1, p2))
                    last = p2
                case let .cubic(p1, p2, p3):
                    buffer.addSegment(.cubic(last, p1, p2, p3))
                    last = p3
                }
            }
            if item.isClosed {
                let z = item.start - last
                if !z.x.almostZero() || !z.y.almostZero() {
                    buffer.addSegment(.line(last, item.start))
                }
                buffer.closePath()
            }
            buffer.flush()
        }
        
        return Shape(buffer.path)
    }
    
}
