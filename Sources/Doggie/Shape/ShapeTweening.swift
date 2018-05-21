//
//  ShapeTweening.swift
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

extension Bezier where Element == Point {
    
    public func tweened(to end: Bezier, _ t: Double) -> Bezier {
        
        let start_start = self[0]
        let start_end = self[self.count - 1]
        let end_start = end[0]
        let end_end = end[end.count - 1]
        let d1 = start_end - start_start
        let d2 = end_end - end_start
        
        let m1 = d1.magnitude
        let m2 = d2.magnitude
        
        if m1.almostZero() || m2.almostZero() {
            return (1 - t) * self + t * end
        }
        
        let s = self * (SDTransform.translate(x: -start_start.x, y: -start_start.y) * SDTransform.scale(1 / m1) * SDTransform.rotate(-d1.phase))
        let e = end * (SDTransform.translate(x: -end_start.x, y: -end_start.y) * SDTransform.scale(1 / m2) * SDTransform.rotate(-d2.phase))
        
        let mid = (1 - t) * s + t * e
        
        let mid_start = (1 - t) * start_start + t * end_start
        let mid_end = (1 - t) * start_end + t * end_end
        let d3 = mid_end - mid_start
        
        return mid * (SDTransform.rotate(d3.phase) * SDTransform.scale(d3.magnitude) * SDTransform.translate(x: mid_start.x, y: mid_start.y))
    }
}

extension Shape {
    
    public func tweened(to end: Shape, _ t: Double) -> Shape {
        return self.identity._tweened(to: end.identity, t)
    }
    
    private func _tweened(to end: Shape, _ t: Double) -> Shape {
        
        var components = Shape()
        components.reserveCapacity(Swift.max(self.count, end.count))
        
        for (_start, _end) in zip(self, end) {
            components.append(_start.tweened(to: _end, t))
        }
        
        if self.count < end.count {
            for i in self.count..<end.count {
                let _end = end[i]
                let _start = Shape.Component(start: self.currentPoint, closed: _end.isClosed, segments: [])
                components.append(_start.tweened(to: _end, t))
            }
        } else if self.count > end.count {
            for i in end.count..<self.count {
                let _start = self[i]
                let _end = Shape.Component(start: end.currentPoint, closed: _start.isClosed, segments: [])
                components.append(_start.tweened(to: _end, t))
            }
        }
        
        return components
    }
}

extension Shape.Component {
    
    public func tweened(to end: Shape.Component, _ t: Double) -> Shape.Component {
        
        if self.count == 0 && end.count == 0 {
            return Shape.Component(start: (1 - t) * self.start + t * end.start, closed: self.isClosed, segments: [])
        }
        
        var segments: [Bezier<Point>] = []
        segments.reserveCapacity(Swift.max(self.count, end.count))
        
        for (_start, _end) in zip(self.bezier, end.bezier) {
            segments.append(Bezier(_start).tweened(to: Bezier(_end), t))
        }
        
        if self.count < end.count {
            for i in self.count..<end.count {
                let _end = Bezier(end.bezier[i])
                let _start = self.isClosed ? (i == self.count ? Bezier(self.end, self.start) : Bezier(self.start)) : Bezier(self.end)
                segments.append(_start.tweened(to: _end, t))
            }
        } else if self.count > end.count {
            for i in end.count..<self.count {
                let _start = Bezier(self.bezier[i])
                let _end = end.isClosed ? (i == end.count ? Bezier(end.end, end.start) : Bezier(end.start)) : Bezier(end.end)
                segments.append(_start.tweened(to: _end, t))
            }
        }
        
        return Shape.Component(start: segments[0][0], closed: self.isClosed, segments: segments.map {
            switch $0.count {
            case 2: return .line($0[1])
            case 3: return .quad($0[1], $0[2])
            case 4: return .cubic($0[1], $0[2], $0[3])
            default: fatalError()
            }
        })
    }
}
