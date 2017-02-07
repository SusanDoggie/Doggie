//
//  SDPathStroke.swift
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

extension SDPath {
    
    public enum LineCap {
        case butt
        case round
        case square
    }
    
    public enum LineJoin {
        case miter(limit: Double)
        case round
        case bevel
    }
    
    fileprivate struct StrokeBuffer {
        
        enum Segment {
            case line(Point, Point)
            case quad(Point, Point, Point)
            case cubic(Point, Point, Point, Point)
        }
        var width: Double
        var cap: LineCap
        var join: LineJoin
        
        var path: [Command] = []
        
        var buffer1: [Command] = []
        var buffer2: [Command] = []
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

extension SDPath.StrokeBuffer.Segment {
    
    var isPoint: Bool {
        switch self {
        case let .line(p0, p1):
            let z0 = p1 - p0
            return z0.x.almostZero() && z0.y.almostZero()
        case let .quad(p0, p1, p2):
            let z0 = p1 - p0
            let z1 = p2 - p1
            return z0.x.almostZero() && z0.y.almostZero() && z1.x.almostZero() && z1.y.almostZero()
        case let .cubic(p0, p1, p2, p3):
            let z0 = p1 - p0
            let z1 = p2 - p1
            let z2 = p3 - p2
            return z0.x.almostZero() && z0.y.almostZero() && z1.x.almostZero() && z1.y.almostZero() && z2.x.almostZero() && z2.y.almostZero()
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
    
    var startDirection: Point {
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
    
    var endDirection: Point {
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

extension SDPath.StrokeBuffer {
    
    mutating func flush() {
        
        if first != nil {
            var cap_buffer: [SDPath.Command] = []
            switch cap {
            case .butt: buffer1.append(.line(reverse_start))
            case .round:
                do {
                    let last_point = last!.end
                    let a = last!.endDirection.phase - 0.5 * Double.pi
                    let r = 0.5 * width
                    let bezierCircle = BezierCircle.lazy.map { $0 * SDTransform.Rotate(a) * r + last_point }
                    buffer1.append(.cubic(bezierCircle[1], bezierCircle[2], bezierCircle[3]))
                    buffer1.append(.cubic(bezierCircle[4], bezierCircle[5], bezierCircle[6]))
                }
                do {
                    let start_point = first!.start
                    let a = first!.startDirection.phase - 0.5 * Double.pi
                    let r = -0.5 * width
                    let bezierCircle = BezierCircle.lazy.map { $0 * SDTransform.Rotate(a) * r + start_point }
                    cap_buffer.append(.cubic(bezierCircle[1], bezierCircle[2], bezierCircle[3]))
                    cap_buffer.append(.cubic(bezierCircle[4], bezierCircle[5], bezierCircle[6]))
                }
            case .square:
                do {
                    let d = last!.endDirection
                    let m = d.magnitude
                    let u = width * 0.5 * d.y / m
                    let v = -width * 0.5 * d.x / m
                    buffer1.append(.line(last!.end + Point(x: u - v, y: v + u)))
                    buffer1.append(.line(last!.end - Point(x: u + v, y: v - u)))
                    buffer1.append(.line(reverse_start))
                }
                do {
                    let d = first!.startDirection
                    let m = d.magnitude
                    let u = -width * 0.5 * d.y / m
                    let v = width * 0.5 * d.x / m
                    cap_buffer.append(.line(first!.start + Point(x: u - v, y: v + u)))
                    cap_buffer.append(.line(first!.start - Point(x: u + v, y: v - u)))
                    cap_buffer.append(.line(start))
                }
            }
            path.append(.move(start))
            path.append(contentsOf: buffer1)
            path.append(contentsOf: buffer2.reversed())
            path.append(contentsOf: cap_buffer)
            path.append(.close)
            
            buffer1.removeAll(keepingCapacity: true)
            buffer2.removeAll(keepingCapacity: true)
            first = nil
            last = nil
        }
    }
    
    mutating func addJoin(_ segment: Segment) {
        
        let ph0 = last!.endDirection.phase
        let ph1 = segment.startDirection.phase
        let angle = (ph1 - ph0).remainder(dividingBy: 2 * Double.pi)
        if !angle.almostZero() {
            switch join {
            case let .miter(limit):
                if limit * sin(0.5 * (Double.pi - abs(angle))) < 1 {
                    do {
                        let d = segment.startDirection
                        let m = d.magnitude
                        let u = width * 0.5 * d.y / m
                        let v = -width * 0.5 * d.x / m
                        buffer1.append(.line(segment.start + Point(x: u, y: v)))
                    }
                    buffer2.append(.line(reverse_start))
                } else {
                    if angle > 0 {
                        do {
                            let d0 = last!.endDirection
                            let m0 = d0.magnitude
                            let u0 = width * 0.5 * d0.y / m0
                            let v0 = -width * 0.5 * d0.x / m0
                            
                            let d1 = segment.startDirection
                            let m1 = d1.magnitude
                            let u1 = width * 0.5 * d1.y / m1
                            let v1 = -width * 0.5 * d1.x / m1
                            
                            let p0 = last!.end + Point(x: u0, y: v0)
                            let p1 = p0 + Point(x: -v0, y: u0)
                            let q0 = segment.start + Point(x: u1, y: v1)
                            let q1 = q0 + Point(x: -v1, y: u1)
                            let intersect = LinesIntersect(p0, p1, q0, q1)!
                            buffer1.append(.line(intersect))
                            buffer1.append(.line(q0))
                        }
                        buffer2.append(.line(reverse_start))
                    } else {
                        do {
                            let d = segment.startDirection
                            let m = d.magnitude
                            let u = width * 0.5 * d.y / m
                            let v = -width * 0.5 * d.x / m
                            buffer1.append(.line(segment.start + Point(x: u, y: v)))
                        }
                        do {
                            let d0 = segment.startDirection
                            let m0 = d0.magnitude
                            let u0 = -width * 0.5 * d0.y / m0
                            let v0 = width * 0.5 * d0.x / m0
                            
                            let d1 = last!.endDirection
                            let m1 = d1.magnitude
                            let u1 = -width * 0.5 * d1.y / m1
                            let v1 = width * 0.5 * d1.x / m1
                            
                            let p0 = segment.start + Point(x: u0, y: v0)
                            let p1 = p0 + Point(x: -v0, y: u0)
                            let q0 = last!.end + Point(x: u1, y: v1)
                            let q1 = q0 + Point(x: -v1, y: u1)
                            let intersect = LinesIntersect(p0, p1, q0, q1)!
                            buffer2.append(.line(q0))
                            buffer2.append(.line(intersect))
                            reverse_start = p0
                        }
                    }
                }
            case .round:
                if angle > 0 {
                    do {
                        let a = ph0 - 0.5 * Double.pi
                        let r = 0.5 * width
                        let bezierArc = BezierArc(angle).lazy.map { $0 * SDTransform.Rotate(a) * r + segment.start }
                        for i in 0..<bezierArc.count / 3 {
                            buffer1.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                        }
                    }
                    buffer2.append(.line(reverse_start))
                } else {
                    do {
                        let d = segment.startDirection
                        let m = d.magnitude
                        let u = width * 0.5 * d.y / m
                        let v = -width * 0.5 * d.x / m
                        buffer1.append(.line(segment.start + Point(x: u, y: v)))
                    }
                    do {
                        let a = ph1 - 0.5 * Double.pi
                        let r = -0.5 * width
                        let bezierArc = BezierArc(-angle).lazy.map { $0 * SDTransform.Rotate(a) * r + segment.start }
                        reverse_start = bezierArc[0]
                        for i in (0..<bezierArc.count / 3).reversed() {
                            buffer2.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                        }
                    }
                }
            default: break
            }
        }
    }
    
    mutating func closePath() {
        
        if first != nil {
            switch join {
            case .bevel: break
            default: self.addJoin(first!)
            }
            path.append(.move(start))
            path.append(contentsOf: buffer1)
            path.append(.close)
            path.append(.move(reverse_start))
            path.append(contentsOf: buffer2.reversed())
            path.append(.close)
            
            buffer1.removeAll(keepingCapacity: true)
            buffer2.removeAll(keepingCapacity: true)
            first = nil
            last = nil
        }
    }
    
    mutating func addSegment(_ segment: Segment) {
        
        if segment.isPoint {
            return
        }
        
        var flag = false
        
        if first == nil {
            flag = true
            first = segment
        } else {
            switch join {
            case .bevel:
                do {
                    let d = segment.startDirection
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
            if let (q0, q1) = BezierOffset(p0, p1, width * 0.5) {
                if flag {
                    start = q0
                }
                buffer1.append(.line(q1))
            }
            if let (q0, q1) = BezierOffset(p0, p1, -width * 0.5) {
                reverse_start = q1
                buffer2.append(.line(q0))
            }
        case let .quad(p0, p1, p2):
            do {
                let path = BezierOffset(p0, p1, p2, width * 0.5)
                if let first = path.first {
                    if flag {
                        start = first[0]
                    }
                    for item in path {
                        switch item.count {
                        case 2: buffer1.append(.line(item[1]))
                        case 3: buffer1.append(.quad(item[1], item[2]))
                        case 4: buffer1.append(.cubic(item[1], item[2], item[3]))
                        default: break
                        }
                    }
                }
            }
            do {
                let path = BezierOffset(p0, p1, p2, -width * 0.5)
                for item in path {
                    switch item.count {
                    case 2:
                        reverse_start = item[1]
                        buffer2.append(.line(item[0]))
                    case 3:
                        reverse_start = item[2]
                        buffer2.append(.quad(item[1], item[0]))
                    case 4:
                        reverse_start = item[3]
                        buffer2.append(.cubic(item[2], item[1], item[0]))
                    default: break
                    }
                }
            }
        case let .cubic(p0, p1, p2, p3):
            do {
                let path = BezierOffset(p0, p1, p2, p3, width * 0.5)
                if let first = path.first {
                    if flag {
                        start = first[0]
                    }
                    for item in path {
                        switch item.count {
                        case 2: buffer1.append(.line(item[1]))
                        case 3: buffer1.append(.quad(item[1], item[2]))
                        case 4: buffer1.append(.cubic(item[1], item[2], item[3]))
                        default: break
                        }
                    }
                }
            }
            do {
                let path = BezierOffset(p0, p1, p2, p3, -width * 0.5)
                for item in path {
                    switch item.count {
                    case 2:
                        reverse_start = item[1]
                        buffer2.append(.line(item[0]))
                    case 3:
                        reverse_start = item[2]
                        buffer2.append(.quad(item[1], item[0]))
                    case 4:
                        reverse_start = item[3]
                        buffer2.append(.cubic(item[2], item[1], item[0]))
                    default: break
                    }
                }
            }
        }
        
    }
    
}

extension SDPath {
    
    public func strokePath(width: Double, cap: LineCap, join: LineJoin) -> SDPath {
        var buffer = StrokeBuffer(width: width, cap: cap, join: join)
        buffer.path.reserveCapacity(self.count << 4)
        self.identity.apply { command, state in
            switch command {
            case .move: buffer.flush()
            case .close:
                let z = state.start - state.last
                if !z.x.almostZero() || !z.y.almostZero() {
                    buffer.addSegment(.line(state.last, state.start))
                }
                buffer.closePath()
            case let .line(p1): buffer.addSegment(.line(state.last, p1))
            case let .quad(p1, p2): buffer.addSegment(.quad(state.last, p1, p2))
            case let .cubic(p1, p2, p3): buffer.addSegment(.cubic(state.last, p1, p2, p3))
            }
        }
        buffer.flush()
        return SDPath(buffer.path)
    }
    
}
