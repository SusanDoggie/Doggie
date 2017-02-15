//
//  SDPathPatternStroke.swift
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
    
    private struct PatternStrokePathData {
        
        let total: Double
        let segments: [PatternStrokePathSegmentData]
    }
    
    private struct PatternStrokePathSegmentData {
        
        let accumulate: Double
        let length: Double
        let points: [Point]
    }
    
    private struct PatternStrokeBuffer {
        
        var flag = false
        var flag2 = false
        var current_index = 0
        
        var fitting: PatternStrokePathData!
        var buffer: [Command] = []
        
        init() {
        }
        
        var current_segment: PatternStrokePathSegmentData {
            return fitting.segments[current_index]
        }
        
        var current_startX: Double {
            return current_segment.accumulate
        }
        
        var current_endX: Double {
            let segment = current_segment
            return segment.accumulate + segment.length
        }
        
        mutating func moveIndex(_ x: Double) {
            if x.almostZero() || x < 0 {
                current_index = 0
                return
            }
            if x.almostEqual(1) || x > 1 {
                current_index = fitting.segments.count - 1
                return
            }
            let _x = x * fitting.total
            while _x > current_endX || _x.almostEqual(current_endX) {
                current_index += 1
            }
            while _x < current_startX {
                current_index -= 1
            }
        }
        
        mutating func flush() {
            flag = true
        }
        
        mutating func closePath() {
            flag = true
            buffer.append(.close)
        }
        
        mutating func push(_ p: [Point]) {
            if flag {
                buffer.append(.move(p[0]))
                flag = false
                flag2 = false
            }
            if flag2 {
                buffer.append(.line(p[0]))
                flag = false
                flag2 = false
            }
            switch p.count {
            case 2: buffer.append(.line(p[1]))
            case 3: buffer.append(.quad(p[1], p[2]))
            case 4: buffer.append(.cubic(p[1], p[2], p[3]))
            default: break
            }
        }
        
        mutating func addJoin(_ width: Double, _ direction: FloatingPointSign) {
            
            if flag || current_index == 0 {
                return
            }
            
            let last_points = fitting.segments[current_index - 1].points
            let current_points = current_segment.points
            
            let current_first = current_points.first!
            
            let z0 = last_points.lazy.map { current_first - $0 }.last { !$0.x.almostZero() || !$0.y.almostZero() }!
            let z1 = current_points.lazy.map { $0 - current_first }.first { !$0.x.almostZero() || !$0.y.almostZero() }!
            
            let ph0 = z0.phase
            let ph1 = z1.phase
            let angle = (ph1 - ph0).remainder(dividingBy: 2 * Double.pi)
            
            switch direction {
            case .plus:
                let a = ph0 - 0.5 * Double.pi
                let bezierArc = BezierArc(angle).lazy.map { $0 * SDTransform.Rotate(a) * width + current_first }
                for i in 0..<bezierArc.count / 3 {
                    buffer.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                }
            case .minus:
                let a = ph1 - 0.5 * Double.pi
                let bezierArc = BezierArc(-angle).lazy.map { $0 * SDTransform.Rotate(a) * width + current_first }
                for i in (0..<bezierArc.count / 3).reversed() {
                    buffer.append(.cubic(bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]))
                }
            }
        }
        
        mutating func addBezier(_ p0: Point, _ p1: Point) {
            let _max_x = Swift.max(p0.x, p1.x)
            let _min_x = Swift.max(p0.x, p1.x)
            if _max_x < 0 || _max_x.almostZero() || _min_x > 1 || _min_x.almostEqual(1) {
                flag2 = true
                return
            }
            var _flag2 = flag2
            var start = 0.0
            var end = 1.0
            if p0.x < 0 && !p0.x.almostZero() {
                start = -p0.x / (p1.x - p0.x)
            }
            if p0.x > 1 && !p0.x.almostEqual(1) {
                start = (1 - p0.x) / (p1.x - p0.x)
            }
            if p1.x < 0 && !p1.x.almostZero() {
                end = -p0.x / (p1.x - p0.x)
                _flag2 = true
            }
            if p1.x > 1 && !p1.x.almostEqual(1) {
                end = (1 - p0.x) / (p1.x - p0.x)
                _flag2 = true
            }
            
            defer { flag2 = _flag2 }
            
            var _p0 = BezierPoint(start, p0, p1)
            let _p1 = BezierPoint(end, p0, p1)
            
            while true {
                let z = _p1 - _p0
                if z.x.almostZero() {
                    flag2 = flag2 || !z.y.almostZero()
                    return
                }
                moveIndex(_p0.x)
                let current_startX = self.current_startX
                let current_endX = self.current_endX
                if _p0.x.almostEqual(current_startX / fitting.total) {
                    addJoin(_p0.y, z.x.sign)
                }
                if z.x > 0 {
                    let mid = BezierPoint((current_endX / fitting.total - p0.x) / (p1.x - p0.x), p0, p1)
                    let segment_points = current_segment.points
                    let a = [Point(x: 0, y: _p0.y), Point(x: 1, y: mid.y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (p0.x * fitting.total - current_startX) / current_segment.length
                        let _t = (mid.x * fitting.total - current_startX) / current_segment.length
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][0], u[1][1], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(p0.x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(mid.x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][0], u[1][1], u[1][2], a) {
                            push(q)
                        }
                    }
                    _p0 = mid
                } else {
                    let _startX: Double
                    let segment_points: [Point]
                    if _p0.x.almostEqual(current_startX) {
                        let segment = fitting.segments[current_index - 1]
                        _startX = segment.accumulate
                        segment_points = segment.points
                    } else {
                        _startX = current_startX
                        segment_points = current_segment.points
                    }
                    let mid = BezierPoint((_startX / fitting.total - p0.x) / (p1.x - p0.x), p0, p1)
                    let a = [Point(x: 0, y: -_p0.y), Point(x: 1, y: -mid.y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (_p0.x * fitting.total - _startX) / current_segment.length
                        let _t = (mid.x * fitting.total - _startX) / current_segment.length
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][1], u[1][0], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(_p0.x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(mid.x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][2], u[1][1], u[1][0], a) {
                            push(q)
                        }
                    }
                    _p0 = mid
                }
            }
        }
        mutating func addBezier(_ p0: Point, _ p1: Point, _ p2: Point) {
            let bound = QuadBezierBound(p0, p1, p2)
            if bound.maxX < 0 || bound.maxX.almostZero() || bound.minX > 1 || bound.minX.almostEqual(1) {
                flag2 = true
                return
            }
            if let stationary = QuadBezierStationary(p0.x, p1.x, p2.x), !stationary.almostZero() && !stationary.almostEqual(1) && 0...1 ~= stationary {
                let (left, right) = SplitBezier(stationary, p0, p1, p2)
                addBezier(left[0], left[1], left[2])
                addBezier(right[0], right[1], right[2])
                return
            }
            if !bound.minX.almostZero() && bound.minX < 0 {
                let t = Bezier(p0.x, p1.x, p2.x).polynomial.roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted()
                let q = SplitBezier(t, p0, p1, p2)
                for item in q {
                    addBezier(item[0], item[1], item[2])
                }
                return
            }
            if !bound.maxX.almostEqual(1) && bound.maxX > 1 {
                let t = (Bezier(p0.x, p1.x, p2.x).polynomial - 1).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted()
                let q = SplitBezier(t, p0, p1, p2)
                for item in q {
                    addBezier(item[0], item[1], item[2])
                }
                return
            }
            let z0 = p1 - p0
            let z1 = p2 - p1
            if z0.x.almostZero() && z1.x.almostZero() {
                flag2 = true
                return
            }
            
            var _p0 = p0
            var _p1 = p1
            var _p2 = p2
            
            while true {
                let z = _p2 - _p0
                if z.x.almostZero() {
                    flag2 = flag2 || !z.y.almostZero()
                    return
                }
                moveIndex(_p0.x)
                let current_startX = self.current_startX
                let current_endX = self.current_endX
                if _p0.x.almostEqual(current_startX / fitting.total) {
                    addJoin(_p0.y, z.x.sign)
                }
                let x_poly = Bezier(_p0.x, _p1.x, _p2.x).polynomial
                if z.x > 0 {
                    let _mid_t = (x_poly - current_endX / fitting.total).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted().first ?? 1
                    let (left, right) = SplitBezier(_mid_t, _p0, _p1, _p2)
                    let segment_points = current_segment.points
                    let a = [Point(x: 0, y: _p0.y), Point(x: (left[1].x - _p0.x) / z.x, y: left[1].y), Point(x: 1, y: left[2].y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (p0.x * fitting.total - current_startX) / current_segment.length
                        let _t = (left[2].x * fitting.total - current_startX) / current_segment.length
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][0], u[1][1], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(p0.x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(left[2].x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][0], u[1][1], u[1][2], a) {
                            push(q)
                        }
                    }
                    _p0 = right[0]
                    _p1 = right[1]
                    _p2 = right[2]
                } else {
                    let _startX: Double
                    let segment_points: [Point]
                    if _p0.x.almostEqual(current_startX) {
                        let segment = fitting.segments[current_index - 1]
                        _startX = segment.accumulate
                        segment_points = segment.points
                    } else {
                        _startX = current_startX
                        segment_points = current_segment.points
                    }
                    let _mid_t = (x_poly - _startX / fitting.total).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted().first ?? 1
                    let (left, right) = SplitBezier(_mid_t, _p0, _p1, _p2)
                    let a = [Point(x: 0, y: -_p0.y), Point(x: (left[1].x - _p0.x) / z.x, y: -left[1].y), Point(x: 1, y: -left[2].y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (_p0.x * fitting.total - _startX) / current_segment.length
                        let _t = (left[2].x * fitting.total - _startX) / current_segment.length
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][1], u[1][0], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(_p0.x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(left[2].x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][2], u[1][1], u[1][0], a) {
                            push(q)
                        }
                    }
                    _p0 = right[0]
                    _p1 = right[1]
                    _p2 = right[2]
                }
            }
        }
        mutating func addBezier(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
            let bound = CubicBezierBound(p0, p1, p2, p3)
            if bound.maxX < 0 || bound.minX > 1 {
                flag2 = true
                return
            }
            let stationary = CubicBezierStationary(p0.x, p1.x, p2.x, p3.x).filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted()
            if stationary.count != 0 {
                let q = SplitBezier(stationary, p0, p1, p2, p3)
                for item in q {
                    addBezier(item[0], item[1], item[2], item[3])
                }
                return
            }
            if !bound.minX.almostZero() && bound.minX < 0 {
                let t = Bezier(p0.x, p1.x, p2.x, p3.x).polynomial.roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted()
                let q = SplitBezier(t, p0, p1, p2, p3)
                for item in q {
                    addBezier(item[0], item[1], item[2], item[3])
                }
            }
            if !bound.maxX.almostEqual(1) && bound.maxX > 1 {
                let t = (Bezier(p0.x, p1.x, p2.x, p3.x).polynomial - 1).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted()
                let q = SplitBezier(t, p0, p1, p2, p3)
                for item in q {
                    addBezier(item[0], item[1], item[2], item[3])
                }
            }
            let z0 = p1 - p0
            let z1 = p2 - p1
            let z2 = p3 - p2
            if z0.x.almostZero() && z1.x.almostZero() && z2.x.almostZero() {
                flag2 = true
                return
            }
            
            var _p0 = p0
            var _p1 = p1
            var _p2 = p2
            var _p3 = p3
            
            while true {
                let z = _p3 - _p0
                if z.x.almostZero() {
                    flag2 = flag2 || !z.y.almostZero()
                    return
                }
                moveIndex(_p0.x)
                let current_startX = self.current_startX
                let current_endX = self.current_endX
                if _p0.x.almostEqual(current_startX / fitting.total) {
                    addJoin(_p0.y, z.x.sign)
                }
                let x_poly = Bezier(_p0.x, _p1.x, _p2.x, _p3.x).polynomial
                if z.x > 0 {
                    let _mid_t = (x_poly - current_endX / fitting.total).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted().first ?? 1
                    let (left, right) = SplitBezier(_mid_t, _p0, _p1, _p2, _p3)
                    let segment_points = current_segment.points
                    let a = [Point(x: 0, y: _p0.y), Point(x: (left[1].x - _p0.x) / z.x, y: left[1].y), Point(x: (left[2].x - _p0.x) / z.x, y: left[2].y), Point(x: 1, y: left[3].y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (p0.x * fitting.total - current_startX) / current_segment.length
                        let _t = (left[3].x * fitting.total - current_startX) / current_segment.length
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][0], u[1][1], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(p0.x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(left[3].x * fitting.total - current_startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_s, _t], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][0], u[1][1], u[1][2], a) {
                            push(q)
                        }
                    }
                    _p0 = right[0]
                    _p1 = right[1]
                    _p2 = right[2]
                    _p3 = right[3]
                } else {
                    let _startX: Double
                    let segment_points: [Point]
                    if _p0.x.almostEqual(current_startX) {
                        let segment = fitting.segments[current_index - 1]
                        _startX = segment.accumulate
                        segment_points = segment.points
                    } else {
                        _startX = current_startX
                        segment_points = current_segment.points
                    }
                    let _mid_t = (x_poly - _startX / fitting.total).roots.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }.sorted().first ?? 1
                    let (left, right) = SplitBezier(_mid_t, _p0, _p1, _p2, _p3)
                    let a = [Point(x: 0, y: -_p0.y), Point(x: (left[1].x - _p0.x) / z.x, y: -left[1].y), Point(x: (left[2].x - _p0.x) / z.x, y: -left[2].y), Point(x: 1, y: -left[3].y)]
                    switch segment_points.count {
                    case 2:
                        let _s = (_p0.x * fitting.total - _startX) / current_segment.length
                        let _t = (left[3].x * fitting.total - _startX) / current_segment.length
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1])
                        if let q = BezierVariableOffset(u[1][1], u[1][0], a) {
                            push(q)
                        }
                    default:
                        let _s = InverseQuadBezierLength(_p0.x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let _t = InverseQuadBezierLength(left[3].x * fitting.total - _startX, segment_points[0], segment_points[1], segment_points[2])
                        let u = SplitBezier([_t, _s], segment_points[0], segment_points[1], segment_points[2])
                        for q in BezierVariableOffset(u[1][2], u[1][1], u[1][0], a) {
                            push(q)
                        }
                    }
                    _p0 = right[0]
                    _p1 = right[1]
                    _p2 = right[2]
                    _p3 = right[3]
                }
            }
        }
    }
    
    public func strokePath(pattern: SDPath, scaling: Bool) -> SDPath {
        
        let pattern = pattern.identity
        
        let fitting = quadBezierFitting()
        
        var buffer = PatternStrokeBuffer()
        buffer.buffer.reserveCapacity(pattern.count * fitting.count << 4)
        
        for path in fitting {
            
            buffer.fitting = path
            
            var pattern = pattern
            if scaling {
                pattern.transform *= SDTransform.Scale(x: 1 / path.total, y: 1)
                pattern = pattern.identity
            }
            pattern.apply { command, state in
                switch command {
                case .move: buffer.flush()
                case .close:
                    let z = state.start - state.last
                    if !z.x.almostZero() || !z.y.almostZero() {
                        buffer.addBezier(state.last, state.start)
                    }
                    buffer.closePath()
                case let .line(p1): buffer.addBezier(state.last, p1)
                case let .quad(p1, p2): buffer.addBezier(state.last, p1, p2)
                case let .cubic(p1, p2, p3): buffer.addBezier(state.last, p1, p2, p3)
                }
            }
        }
        
        return SDPath(buffer.buffer)
    }
    
    private func quadBezierFitting() -> [PatternStrokePathData] {
        
        var path: [PatternStrokePathData] = []
        var segments: [PatternStrokePathSegmentData] = []
        var accumulate = 0.0
        self.identity.apply { command, state in
            switch command {
            case .move:
                if segments.count != 0 {
                    path.append(PatternStrokePathData(total: accumulate, segments: segments))
                }
                segments.removeAll(keepingCapacity: true)
                accumulate = 0.0
            case .close:
                if segments.count != 0 {
                    let z = state.start - state.last
                    if !z.x.almostZero() || !z.y.almostZero() {
                        let m = z.magnitude
                        segments.append(PatternStrokePathSegmentData(accumulate: accumulate, length: m, points: [state.last, state.start]))
                        accumulate += m
                    }
                    path.append(PatternStrokePathData(total: accumulate, segments: segments))
                }
                segments.removeAll(keepingCapacity: true)
                accumulate = 0.0
            case let .line(p1):
                let m = (p1 - state.last).magnitude
                segments.append(PatternStrokePathSegmentData(accumulate: accumulate, length: m, points: [state.last, p1]))
                accumulate += m
            case let .quad(p1, p2):
                let m = QuadBezierLength(1, state.last, p1, p2)
                segments.append(PatternStrokePathSegmentData(accumulate: accumulate, length: m, points: [state.last, p1, p2]))
                accumulate += m
            case let .cubic(p1, p2, p3):
                let fitting = BezierOffset(p1, p2, p3, 0)
                for item in fitting {
                    switch item.count {
                    case 2:
                        let m = (item[1] - item[0]).magnitude
                        segments.append(PatternStrokePathSegmentData(accumulate: accumulate, length: m, points: item))
                        accumulate += m
                    case 3:
                        let m = QuadBezierLength(1, item[0], item[1], item[2])
                        segments.append(PatternStrokePathSegmentData(accumulate: accumulate, length: m, points: item))
                        accumulate += m
                    default: break
                    }
                }
            }
        }
        if segments.count != 0 {
            path.append(PatternStrokePathData(total: accumulate, segments: segments))
        }
        return path
    }
    
}

