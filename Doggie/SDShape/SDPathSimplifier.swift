//
//  SDPathSimplifier.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

extension Double {
    
    func between(a: Double, _ b : Double) -> Bool {
        return a < b ? a <= self && self <= b : b <= self && self <= a
    }
}

protocol SDPathSegmentComponent {
    
    var last: Point { get set }
    var boundary: Rect { get set }
    
    var pathComponent: SDPathComponent { get }
    
    func intersect(other: SDPathSegmentLine, flag: Bool) -> (Self?, Self, SDPathSegmentLine, SDPathSegmentLine?)?
    func intersect(other: SDPathSegmentQuadBezier, flag: Bool) -> (Self?, Self, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier?)?
    func intersect(other: SDPathSegmentCubicBezier, flag: Bool) -> (Self?, Self, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier?)?
    func intersect(other: SDPathSegmentArc, flag: Bool) -> (Self?, Self, SDPathSegmentArc, SDPathSegmentArc?)?
}

struct SDPathSegmentLine : SDPathSegmentComponent {
    
    var last: Point
    var boundary: Rect
    var line: SDPath.Line
    
    init(line: SDPath.Line, state: SDPath.ComputeState) {
        self.last = state.last
        self.boundary = line.bound(state.last).inset(dx: -1e-6, dy: -1e-6)
        self.line = line
    }
    
    init(_ p0: Point, _ p1: Point) {
        self.last = p0
        self.line = SDPath.Line(p1)
        self.boundary = Rect.bound([p0, p1]).inset(dx: -1e-6, dy: -1e-6)
    }
    
    var p0 : Point {
        return last
    }
    var p1 : Point {
        return line.point
    }
    var pathComponent: SDPathComponent {
        return line
    }
}

struct SDPathSegmentQuadBezier : SDPathSegmentComponent {
    
    var last: Point
    var firstControl: Point
    var boundary: Rect
    var qbezier: SDPath.QuadBezier
    
    init(qbezier: SDPath.QuadBezier, state: SDPath.ComputeState) {
        self.last = state.last
        self.firstControl = state.firstControl!
        self.qbezier = qbezier
        self.boundary = QuadBezierBound(state.last, state.firstControl!, qbezier.p2).inset(dx: -1e-6, dy: -1e-6)
    }
    
    init(_ p0: Point, _ p1: Point, _ p2: Point) {
        self.last = p0
        self.firstControl = p1
        self.qbezier = SDPath.QuadBezier(p1, p2)
        self.boundary = QuadBezierBound(last, p1, p2).inset(dx: -1e-6, dy: -1e-6)
    }
    
    var p0 : Point {
        return last
    }
    var p1 : Point {
        return firstControl
    }
    var p2 : Point {
        return qbezier.p2
    }
    var pathComponent: SDPathComponent {
        return qbezier
    }
}

struct SDPathSegmentCubicBezier : SDPathSegmentComponent {
    
    var last: Point
    var firstControl: Point
    var boundary: Rect
    var cbezier: SDPath.CubicBezier
    
    init(cbezier: SDPath.CubicBezier, state: SDPath.ComputeState) {
        self.last = state.last
        self.firstControl = state.firstControl!
        self.cbezier = cbezier
        self.boundary = CubicBezierBound(state.last, state.firstControl!, cbezier.p2, cbezier.p3).inset(dx: -1e-6, dy: -1e-6)
    }
    
    init(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
        self.last = p0
        self.firstControl = p1
        self.cbezier = SDPath.CubicBezier(p1, p2, p3)
        self.boundary = CubicBezierBound(last, p1, p2, p3).inset(dx: -1e-6, dy: -1e-6)
    }
    
    var p0 : Point {
        return last
    }
    var p1 : Point {
        return firstControl
    }
    var p2 : Point {
        return cbezier.p2
    }
    var p3 : Point {
        return cbezier.p3
    }
    var pathComponent: SDPathComponent {
        return cbezier
    }
}

struct SDPathSegmentArc : SDPathSegmentComponent {
    
    var last: Point
    var boundary: Rect
    var arc: SDPath.Arc
    
    init(arc: SDPath.Arc, state: SDPath.ComputeState) {
        self.last = state.last
        self.boundary = arc.bound(state.last).inset(dx: -1e-6, dy: -1e-6)
        self.arc = arc
    }
    
    init(last: Point, arc: SDPath.Arc) {
        self.last = last
        self.boundary = arc.bound(last).inset(dx: -1e-6, dy: -1e-6)
        self.arc = arc
    }
    
    var p0 : Point {
        return last
    }
    var p1 : Point {
        return arc.point
    }
    var pathComponent: SDPathComponent {
        return arc
    }
}

func bound(a: Double, _ b: Double) -> ClosedInterval<Double> {
    return a < b ? a...b : b...a
}

extension SDPathSegmentLine {
    
    func split_check(point: Point) -> Int {
        if (point.x - self.p0.x).almostZero {
            return 1
        } else if (point.x - self.p1.x).almostZero {
            return 2
        } else if point.x.between(self.p0.x, self.p1.x) {
            return 3
        }
        return 0
    }
    func split(point: Point) -> (SDPathSegmentLine?, SDPathSegmentLine?) {
        if (point.x - self.p0.x).almostZero {
            return (nil, self)
        } else if (point.x - self.p1.x).almostZero {
            return (self, nil)
        } else if point.x.between(self.p0.x, self.p1.x) {
            return (SDPathSegmentLine(self.p0, point), SDPathSegmentLine(point, self.p1))
        }
        return (nil, nil)
    }
    
    func intersect(other: SDPathSegmentLine, flag: Bool) -> (SDPathSegmentLine?, SDPathSegmentLine, SDPathSegmentLine, SDPathSegmentLine?)? {
        
        if let point = LinesIntersect(self.p0, self.p1, other.p0, other.p1) {
            
            let check1 = self.split_check(point)
            let check2 = other.split_check(point)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(point)
                let (c, d) = other.split(point)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentQuadBezier, flag: Bool) -> (SDPathSegmentLine?, SDPathSegmentLine, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier?)? {
        
        for t in QuadBezierLineIntersect(other.p0, other.p1, other.p2, self.p0, self.p1) {
            
            let p = Bezier(t, other.p0, other.p1, other.p2)
            
            let check1 = self.split_check(p)
            let check2 = other.split_check(t)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(p)
                let (c, d) = other.split(t)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentCubicBezier, flag: Bool) -> (SDPathSegmentLine?, SDPathSegmentLine, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier?)? {
        
        for t in CubicBezierLineIntersect(other.p0, other.p1, other.p2, other.p3, self.p0, self.p1) {
            
            let p = Bezier(t, other.p0, other.p1, other.p2, other.p3)
            
            let check1 = self.split_check(p)
            let check2 = other.split_check(t)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(p)
                let (c, d) = other.split(t)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentArc, flag: Bool) -> (SDPathSegmentLine?, SDPathSegmentLine, SDPathSegmentArc, SDPathSegmentArc?)? {
        
        let (center, radius) = other.arc.details(other.p0)
        for point in EllipseLineIntersect(center, radius, SDTransform.Rotate(other.arc.rotate), self.p0, self.p1) {
            
            let check1 = self.split_check(point)
            let check2 = other.split_check(point)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(point)
                let (c, d) = other.split(point)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
}

extension SDPathSegmentQuadBezier {
    
    func split_check(t: Double) -> Int {
        if t.almostZero {
            return 1
        } else if (t - 1).almostZero {
            return 2
        } else if (0...1).contains(t) {
            return 3
        }
        return 0
    }
    func split(t: Double) -> (SDPathSegmentQuadBezier?, SDPathSegmentQuadBezier?) {
        if t.almostZero {
            return (nil, self)
        } else if (t - 1).almostZero {
            return (self, nil)
        } else if (0...1).contains(t) {
            let (b1, b2) = SplitBezier(t, self.p0, self.p1, self.p2)
            return (SDPathSegmentQuadBezier(b1[0], b1[1], b1[2]), SDPathSegmentQuadBezier(b2[0], b2[1], b2[2]))
        }
        return (nil, nil)
    }
    
    func intersect(other: SDPathSegmentLine, flag: Bool) -> (SDPathSegmentQuadBezier?, SDPathSegmentQuadBezier, SDPathSegmentLine, SDPathSegmentLine?)? {
        
        for t in QuadBezierLineIntersect(self.p0, self.p1, self.p2, other.p0, other.p1) {
            
            let p = Bezier(t, self.p0, self.p1, self.p2)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(p)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(p)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentQuadBezier, flag: Bool) -> (SDPathSegmentQuadBezier?, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier?)? {
        
        for t in QuadBeziersIntersect(self.p0, self.p1, self.p2, other.p0, other.p1, other.p2) {
            
            let s = ClosestBezier(Bezier(t, self.p0, self.p1, self.p2), other.p0, other.p1, other.p2)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(s)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(s)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentCubicBezier, flag: Bool) -> (SDPathSegmentQuadBezier?, SDPathSegmentQuadBezier, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier?)? {
        
        for t in CubicQuadBezierIntersect(other.p0, other.p1, other.p2, other.p3, self.p0, self.p1, self.p2) {
            
            let s = ClosestBezier(Bezier(t, other.p0, other.p1, other.p2, other.p3), self.p0, self.p1, self.p2)
            
            let check1 = self.split_check(s)
            let check2 = other.split_check(t)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(s)
                let (c, d) = other.split(t)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentArc, flag: Bool) -> (SDPathSegmentQuadBezier?, SDPathSegmentQuadBezier, SDPathSegmentArc, SDPathSegmentArc?)? {
        
        let (center, radius) = other.arc.details(other.p0)
        for t in QuadBezierEllipseIntersect(self.p0, self.p1, self.p2, center, radius, SDTransform.Rotate(other.arc.rotate)) {
            
            let p = Bezier(t, self.p0, self.p1, self.p2)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(p)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(p)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
}

extension SDPathSegmentCubicBezier {
    
    func split_check(t: Double) -> Int {
        if t.almostZero {
            return 1
        } else if (t - 1).almostZero {
            return 2
        } else if (0...1).contains(t) {
            return 3
        }
        return 0
    }
    func split(t: Double) -> (SDPathSegmentCubicBezier?, SDPathSegmentCubicBezier?) {
        if t.almostZero {
            return (nil, self)
        } else if (t - 1).almostZero {
            return (self, nil)
        } else if (0...1).contains(t) {
            let (b1, b2) = SplitBezier(t, self.p0, self.p1, self.p2, self.p3)
            return (SDPathSegmentCubicBezier(b1[0], b1[1], b1[2], b1[3]), SDPathSegmentCubicBezier(b2[0], b2[1], b2[2], b2[3]))
        }
        return (nil, nil)
    }
    
    func intersect(other: SDPathSegmentLine, flag: Bool) -> (SDPathSegmentCubicBezier?, SDPathSegmentCubicBezier, SDPathSegmentLine, SDPathSegmentLine?)? {
        
        for t in CubicBezierLineIntersect(self.p0, self.p1, self.p2, self.p3, other.p0, other.p1) {
            
            let p = Bezier(t, self.p0, self.p1, self.p2, self.p3)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(p)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(p)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentQuadBezier, flag: Bool) -> (SDPathSegmentCubicBezier?, SDPathSegmentCubicBezier, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier?)? {
        
        for t in CubicQuadBezierIntersect(self.p0, self.p1, self.p2, self.p3, other.p0, other.p1, other.p2) {
            
            let s = ClosestBezier(Bezier(t, self.p0, self.p1, self.p2, self.p3), other.p0, other.p1, other.p2)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(s)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(s)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentCubicBezier, flag: Bool) -> (SDPathSegmentCubicBezier?, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier?)? {
        
        for t in CubicBeziersIntersect(self.p0, self.p1, self.p2, self.p3, other.p0, other.p1, other.p2, other.p3) {
            
            let s = ClosestBezier(Bezier(t, self.p0, self.p1, self.p2, self.p3), other.p0, other.p1, other.p2, other.p3)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(s)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(s)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentArc, flag: Bool) -> (SDPathSegmentCubicBezier?, SDPathSegmentCubicBezier, SDPathSegmentArc, SDPathSegmentArc?)? {
        
        let (center, radius) = other.arc.details(other.p0)
        for t in CubicBezierEllipseIntersect(self.p0, self.p1, self.p2, self.p3, center, radius, SDTransform.Rotate(other.arc.rotate)) {
            
            let p = Bezier(t, self.p0, self.p1, self.p2, self.p3)
            
            let check1 = self.split_check(t)
            let check2 = other.split_check(p)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(t)
                let (c, d) = other.split(p)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
}

extension SDPathSegmentArc {
    
    func split_check(point: Point) -> Int {
        if (point.x - self.p0.x).almostZero && (point.y - self.p0.y).almostZero {
            return 1
        } else if (point.x - self.p1.x).almostZero && (point.y - self.p1.y).almostZero {
            return 2
        } else if self.arc.contains(self.p0, point) {
            return 3
        }
        return 0
    }
    func split(point: Point) -> (SDPathSegmentArc?, SDPathSegmentArc?) {
        if (point.x - self.p0.x).almostZero && (point.y - self.p0.y).almostZero {
            return (nil, self)
        } else if (point.x - self.p1.x).almostZero && (point.y - self.p1.y).almostZero {
            return (self, nil)
        } else if self.arc.contains(self.p0, point) {
            if self.arc.largeArc {
                
                let (center, radius) = self.arc.details(self.p0)
                return (SDPathSegmentArc(last: self.p0, arc: SDPath.Arc(point: point, radius: radius, rotate: self.arc.rotate, largeArc: !direction(self.p0, center, point).isSignMinus == self.arc.sweep, sweep: self.arc.sweep)),
                    SDPathSegmentArc(last: point, arc: SDPath.Arc(point: self.p1, radius: radius, rotate: self.arc.rotate, largeArc: !direction(point, center, self.p1).isSignMinus == self.arc.sweep, sweep: self.arc.sweep)))
                
            } else {
                let radius = self.arc.details(self.p0).1
                return (SDPathSegmentArc(last: self.p0, arc: SDPath.Arc(point: point, radius: radius, rotate: self.arc.rotate, largeArc: false, sweep: self.arc.sweep)),
                    SDPathSegmentArc(last: point, arc: SDPath.Arc(point: self.p1, radius: radius, rotate: self.arc.rotate, largeArc: false, sweep: self.arc.sweep)))
                
            }
        }
        return (nil, nil)
    }
    
    func intersect(other: SDPathSegmentLine, flag: Bool) -> (SDPathSegmentArc?, SDPathSegmentArc, SDPathSegmentLine, SDPathSegmentLine?)? {
        
        let (center, radius) = self.arc.details(self.p0)
        for point in EllipseLineIntersect(center, radius, SDTransform.Rotate(self.arc.rotate), other.p0, other.p1) {
            
            let check1 = self.split_check(point)
            let check2 = other.split_check(point)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(point)
                let (c, d) = other.split(point)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentQuadBezier, flag: Bool) -> (SDPathSegmentArc?, SDPathSegmentArc, SDPathSegmentQuadBezier, SDPathSegmentQuadBezier?)? {
        
        let (center, radius) = self.arc.details(self.p0)
        for t in QuadBezierEllipseIntersect(other.p0, other.p1, other.p2, center, radius, SDTransform.Rotate(self.arc.rotate)) {
            
            let p = Bezier(t, other.p0, other.p1, other.p2)
            
            let check1 = self.split_check(p)
            let check2 = other.split_check(t)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(p)
                let (c, d) = other.split(t)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentCubicBezier, flag: Bool) -> (SDPathSegmentArc?, SDPathSegmentArc, SDPathSegmentCubicBezier, SDPathSegmentCubicBezier?)? {
        
        let (center, radius) = self.arc.details(self.p0)
        for t in CubicBezierEllipseIntersect(other.p0, other.p1, other.p2, other.p3, center, radius, SDTransform.Rotate(self.arc.rotate)) {
            
            let p = Bezier(t, other.p0, other.p1, other.p2, other.p3)
            
            let check1 = self.split_check(p)
            let check2 = other.split_check(t)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(p)
                let (c, d) = other.split(t)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
    
    func intersect(other: SDPathSegmentArc, flag: Bool) -> (SDPathSegmentArc?, SDPathSegmentArc, SDPathSegmentArc, SDPathSegmentArc?)? {
        
        let (center1, radius1) = self.arc.details(self.p0)
        let (center2, radius2) = other.arc.details(other.p0)
        for point in EllipsesIntersect(center1, radius1, SDTransform.Rotate(self.arc.rotate), center2, radius2, SDTransform.Rotate(other.arc.rotate)) {
            
            let check1 = self.split_check(point)
            let check2 = other.split_check(point)
            
            if check1 & 1 != 0 && check2 & 2 != 0 && (!flag || (check1 & 2 != 0 || check2 & 1 != 0)) {
                let (a, b) = self.split(point)
                let (c, d) = other.split(point)
                return (a, b!, c!, d)
            }
        }
        return nil
    }
}

struct SDPathSegment {
    
    var components: [SDPathSegmentComponent] = []
    var oldBound: Rect = Rect()
    var boundarys: [Rect] = []
    var closed: Bool = false
}

extension SDPathSegment : SequenceType {
    
    var start: Point {
        return components.first?.last ?? Point()
    }
    
    func generate() -> SDPathSegmentGenerator {
        return SDPathSegmentGenerator(g1: GeneratorOfOne(SDPath.Move(self.start)), g2: components.lazy.map { $0.pathComponent }.generate(), g3: self.closed ? GeneratorOfOne(SDPath.ClosePath()) : nil)
    }
}

struct SDPathSegmentGenerator : GeneratorType {
    
    var g1: GeneratorOfOne<SDPathComponent>
    var g2: LazyMapGenerator<IndexingGenerator<Array<SDPathSegmentComponent>>, SDPathComponent>
    var g3: GeneratorOfOne<SDPathComponent>?
    
    mutating func next() -> SDPathComponent? {
        return g1.next() ?? g2.next() ?? g3?.next()
    }
}

extension SDPathSegmentComponent {
    
    func _intersect(other: SDPathSegmentComponent, flag: Bool) -> (SDPathSegmentComponent?, SDPathSegmentComponent, SDPathSegmentComponent, SDPathSegmentComponent?)? {
        
        switch other {
        case let line as SDPathSegmentLine:
            if let (a, b, c, d) = self.intersect(line, flag: flag) {
                return (a, b, c, d)
            }
        case let qbezier as SDPathSegmentQuadBezier:
            if let (a, b, c, d) = self.intersect(qbezier, flag: flag) {
                return (a, b, c, d)
            }
        case let cbezier as SDPathSegmentCubicBezier:
            if let (a, b, c, d) = self.intersect(cbezier, flag: flag) {
                return (a, b, c, d)
            }
        case let arc as SDPathSegmentArc:
            if let (a, b, c, d) = self.intersect(arc, flag: flag) {
                return (a, b, c, d)
            }
        default: break
        }
        return nil
    }
}

func simplify<S : SequenceType where S.Generator.Element == SDPathSegmentComponent>(components: S, closed: Bool) -> [SDPathSegment] {
    var result: [SDPathSegment] = []
    var path = SDPathSegment()
    var breakBezierFlag = false
    for item in components {
        switch item {
            
        case let line as SDPathSegmentLine:
            var component : SDPathSegmentComponent? = line
            while let subpaths = path.breakPath(&component) {
                result.appendContentsOf(subpaths)
            }
            if component != nil {
                path.append(component!)
            }
            
        case var qbezier as SDPathSegmentQuadBezier:
            if breakBezierFlag {
                qbezier.qbezier.p1 = qbezier.firstControl
                breakBezierFlag = false
            }
            var component : SDPathSegmentComponent? = qbezier
            while let subpaths = path.breakPath(&component) {
                result.appendContentsOf(subpaths)
                breakBezierFlag = true
            }
            if component != nil {
                path.append(component!)
            }
            
        case var cbezier as SDPathSegmentCubicBezier:
            if breakBezierFlag {
                cbezier.cbezier.p1 = cbezier.firstControl
                breakBezierFlag = false
            }
            var component : SDPathSegmentComponent? = cbezier
            while let subpaths = path.breakPath(&component) {
                result.appendContentsOf(subpaths)
                breakBezierFlag = true
            }
            if component != nil {
                path.append(component!)
            }
            
        case let arc as SDPathSegmentArc:
            var component : SDPathSegmentComponent? = arc
            while let subpaths = path.breakPath(&component) {
                result.appendContentsOf(subpaths)
            }
            if component != nil {
                path.append(component!)
            }
            
        default: break
        }
    }
    if path.components.count != 0 {
        path.closed = closed
        result.append(path)
    }
    return result
}

extension SDPathSegment {
    
    mutating func append(component: SDPathSegmentComponent) {
        oldBound = boundarys.first ?? Rect()
        var idx = (boundarys.count - 1) >> 1
        while idx >= 0 {
            boundarys[idx] = boundarys[idx].union(component.boundary)
            idx = (idx - 1) >> 1
        }
        boundarys.append(component.boundary)
        components.append(component)
    }
    
    mutating func rebuiltHeap() {
        boundarys = components.map { $0.boundary }
        oldBound = boundarys.dropFirst().dropLast().reduce(boundarys.first ?? Rect()) { $0.union($1) }
        var idx = (boundarys.count - 2) >> 1
        while idx >= 0 {
            let left = idx << 1 + 1
            let right = idx << 1 + 2
            boundarys[idx] = boundarys[idx].union(boundarys[left])
            if right < boundarys.count {
                boundarys[idx] = boundarys[idx].union(boundarys[right])
            }
            --idx
        }
    }
    
    mutating func breakPath(inout component: SDPathSegmentComponent?) -> [SDPathSegment]? {
        
        if component != nil {
            if boundarys.count != 0 && oldBound.isIntersect(component!.boundary), let subpath = searchBreakPath(&component, index: 0) {
                return subpath
            }
            if let (a, b, c, d) = components.last?._intersect(component!, flag: components.count == 1) {
                let result = simplify(GeneratorOfOne(b).lazy.concat(GeneratorOfOne(c)), closed: true)
                components = components.dropLast().array + GeneratorOfOne(a).flatMap { $0 }
                self.rebuiltHeap()
                component = d
                return result
            }
        }
        return nil
    }
    
    mutating func searchBreakPath(inout component: SDPathSegmentComponent?, index: Int) -> [SDPathSegment]? {
        
        if index < boundarys.count && boundarys[index].isIntersect(component!.boundary) {
            
            if let (a, b, c, d) = components[index]._intersect(component!, flag: index == 0) {
                let result = simplify(GeneratorOfOne(b).lazy.concat(components.suffixFrom(index + 1)).concat(GeneratorOfOne(c)), closed: true)
                components = components.prefixUpTo(index).array + GeneratorOfOne(a).flatMap { $0 }
                self.rebuiltHeap()
                component = d
                return result
            }
            
            if let path = searchBreakPath(&component, index: index << 1 + 1) ?? searchBreakPath(&component, index: index << 1 + 2) {
                return path
            }
        }
        return nil
    }
}

extension SDPath {
    
    var segments : [SDPathSegment] {
        var result: [SDPathSegment] = []
        var path = SDPathSegment()
        var breakBezierFlag = false
        self.apply { component, state in
            
            switch component {
                
            case _ as SDPath.Move:
                if path.components.count != 0 {
                    result.append(path)
                }
                path = SDPathSegment()
                
            case let line as SDPath.Line:
                var component : SDPathSegmentComponent? = SDPathSegmentLine(line: line, state: state)
                while let subpaths = path.breakPath(&component) {
                    result.appendContentsOf(subpaths)
                }
                if component != nil {
                    path.append(component!)
                }
                
            case var qbezier as SDPath.QuadBezier:
                if breakBezierFlag {
                    qbezier.p1 = state.firstControl
                    breakBezierFlag = false
                }
                var component : SDPathSegmentComponent? = SDPathSegmentQuadBezier(qbezier: qbezier, state: state)
                while let subpaths = path.breakPath(&component) {
                    result.appendContentsOf(subpaths)
                    breakBezierFlag = true
                }
                if component != nil {
                    path.append(component!)
                }
                
            case var cbezier as SDPath.CubicBezier:
                if breakBezierFlag {
                    cbezier.p1 = state.firstControl
                    breakBezierFlag = false
                }
                if (state.last.x - cbezier.p3.x).almostZero && (state.last.y - cbezier.p3.y).almostZero {
                    var subpath = SDPathSegment(components: [SDPathSegmentCubicBezier(state.last, state.firstControl!, cbezier.p2, cbezier.p3)], oldBound: Rect(), boundarys: [], closed: true)
                    subpath.rebuiltHeap()
                    result.append(subpath)
                    breakBezierFlag = true
                    return
                }
                var component : SDPathSegmentComponent? = SDPathSegmentCubicBezier(cbezier: cbezier, state: state)
                if let (a, b) = CubicBezierSelfIntersect(state.last, state.firstControl!, cbezier.p2, cbezier.p3) {
                    
                    if a.almostZero && b < 1 {
                        let spilt = SDPathSegmentCubicBezier(cbezier: cbezier, state: state).split(b)
                        var subpath = SDPathSegment(components: [SDPathSegmentCubicBezier(spilt.0!.p0, spilt.0!.p1, spilt.0!.p2, spilt.0!.p3)], oldBound: Rect(), boundarys: [], closed: true)
                        subpath.rebuiltHeap()
                        result.append(subpath)
                        component = spilt.1
                        breakBezierFlag = true
                        
                    } else if a > 0 && (b - 1).almostZero {
                        let spilt = SDPathSegmentCubicBezier(cbezier: cbezier, state: state).split(a)
                        var subpath = SDPathSegment(components: [SDPathSegmentCubicBezier(spilt.1!.p0, spilt.1!.p1, spilt.1!.p2, spilt.1!.p3)], oldBound: Rect(), boundarys: [], closed: true)
                        subpath.rebuiltHeap()
                        result.append(subpath)
                        component = spilt.0
                        breakBezierFlag = true
                        
                    } else if a > 0 && b < 1 {
                        let spilt = SDPathSegmentCubicBezier(cbezier: cbezier, state: state).split(a)
                        component = spilt.0
                        while let subpaths = path.breakPath(&component) {
                            result.appendContentsOf(subpaths)
                        }
                        if component != nil {
                            path.append(component!)
                        }
                        let spilt2 = spilt.1!.split(CubicBezierSelfIntersect(spilt.1!.p0, spilt.1!.p1, spilt.1!.p2, spilt.1!.p3)!.1)
                        var subpath = SDPathSegment(components: [SDPathSegmentCubicBezier(spilt2.0!.p0, spilt2.0!.p1, spilt2.0!.p2, spilt2.0!.p3)], oldBound: Rect(), boundarys: [], closed: true)
                        subpath.rebuiltHeap()
                        result.append(subpath)
                        component = spilt2.1
                        breakBezierFlag = true
                    }
                }
                while let subpaths = path.breakPath(&component) {
                    result.appendContentsOf(subpaths)
                    breakBezierFlag = true
                }
                if component != nil {
                    path.append(component!)
                }
                
            case let arc as SDPath.Arc:
                var component : SDPathSegmentComponent? = SDPathSegmentArc(arc: arc, state: state)
                while let subpaths = path.breakPath(&component) {
                    result.appendContentsOf(subpaths)
                }
                if component != nil {
                    path.append(component!)
                }
                
            case _ as SDPath.ClosePath:
                var component : SDPathSegmentComponent? = SDPathSegmentLine(line: SDPath.Line(state.start), state: state)
                while let subpaths = path.breakPath(&component) {
                    result.appendContentsOf(subpaths)
                }
                path.closed = true
                result.append(path)
                path = SDPathSegment()
                
            default: break
            }
        }
        if path.components.count != 0 {
            result.append(path)
        }
        return result
    }
    
    public var simplify: SDPath {
        var result = SDPath(segments.flatten())
        result.transform = self.transform
        return result
    }
}
