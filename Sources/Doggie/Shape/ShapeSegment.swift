//
//  ShapeSegment.swift
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

extension Shape.Component.BezierCollection.Element {
    
    public init(_ p0: Point, _ p1: Point) {
        self.init(start: p0, segment: .line(p1))
    }
    public init(_ p0: Point, _ p1: Point, _ p2: Point) {
        if cross(p1 - p0, p2 - p0).almostZero() {
            self.init(start: p0, segment: .line(p2))
        } else {
            self.init(start: p0, segment: .quad(p1, p2))
        }
    }
    public init(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
        if cross(p1 - p0, p2 - p0).almostZero() && cross(p1 - p0, p3 - p0).almostZero() && cross(p2 - p0, p3 - p0).almostZero() {
            self.init(start: p0, segment: .line(p3))
        } else {
            self.init(start: p0, segment: .cubic(p1, p2, p3))
        }
    }
}

private func split_check(_ t: Double) -> Double? {
    if t.almostZero() {
        return 0
    } else if (t - 1).almostZero() {
        return 1
    } else if 0...1 ~= t {
        return t
    }
    return nil
}
private func split_check(_ t: (Double?, Double?)) -> (Double, Double)? {
    if let lhs = t.0, let rhs = t.1 {
        return (lhs, rhs)
    }
    return nil
}
private func split_check(_ t: (Double?, Double)) -> (Double, Double)? {
    if let lhs = t.0, let rhs = split_check(t.1) {
        return (lhs, rhs)
    }
    return nil
}
private func split_check(_ t: (Double, Double?)) -> (Double, Double)? {
    if let lhs = split_check(t.0), let rhs = t.1 {
        return (lhs, rhs)
    }
    return nil
}

extension Shape.Component.BezierCollection.Element {
    
    public var isPoint: Bool {
        switch self.segment {
        case let .line(p1): return start.almostEqual(p1)
        default: return false
        }
    }
    
    public func point(_ t: Double) -> Point {
        switch self.segment {
        case let .line(p1): return Bezier(start, p1).eval(t)
        case let .quad(p1, p2): return Bezier(start, p1, p2).eval(t)
        case let .cubic(p1, p2, p3): return Bezier(start, p1, p2, p3).eval(t)
        }
    }
    
    public func points(_ t: [Double]) -> [Point] {
        switch self.segment {
        case let .line(p1):
            let bezier = Bezier(start, p1)
            return t.map { bezier.eval($0) }
        case let .quad(p1, p2):
            let bezier = Bezier(start, p1, p2)
            return t.map { bezier.eval($0) }
        case let .cubic(p1, p2, p3):
            let bezier = Bezier(start, p1, p2, p3)
            return t.map { bezier.eval($0) }
        }
    }
    
    public func fromPoint(_ p: Point) -> Double? {
        switch self.segment {
        case let .line(p1):
            return Bezier(start, p1).closest(p).lazy.flatMap(split_check).first { p.almostEqual(self.point($0)) }
        case let .quad(p1, p2):
            return Bezier(start, p1, p2).closest(p).lazy.flatMap(split_check).first { p.almostEqual(self.point($0)) }
        case let .cubic(p1, p2, p3):
            return Bezier(start, p1, p2, p3).closest(p).lazy.flatMap(split_check).first { p.almostEqual(self.point($0)) }
        }
    }
    
    public func split(_ t: Double) -> (Shape.Component.BezierCollection.Element, Shape.Component.BezierCollection.Element) {
        switch self.segment {
        case let .line(p1):
            let _split = Bezier(start, p1).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0[0], _split.0[1]), Shape.Component.BezierCollection.Element(_split.1[0], _split.1[1]))
        case let .quad(p1, p2):
            let _split = Bezier(start, p1, p2).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0[0], _split.0[1], _split.0[2]), Shape.Component.BezierCollection.Element(_split.1[0], _split.1[1], _split.1[2]))
        case let .cubic(p1, p2, p3):
            let _split = Bezier(start, p1, p2, p3).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0[0], _split.0[1], _split.0[2], _split.0[3]), Shape.Component.BezierCollection.Element(_split.1[0], _split.1[1], _split.1[2], _split.1[3]))
        }
    }
    
    public func split(_ t: [Double]) -> [Shape.Component.BezierCollection.Element] {
        switch self.segment {
        case let .line(p1): return Bezier(start, p1).split(t).map { Shape.Component.BezierCollection.Element($0[0], $0[1]) }
        case let .quad(p1, p2): return Bezier(start, p1, p2).split(t).map { Shape.Component.BezierCollection.Element($0[0], $0[1], $0[2]) }
        case let .cubic(p1, p2, p3): return Bezier(start, p1, p2, p3).split(t).map { Shape.Component.BezierCollection.Element($0[0], $0[1], $0[2], $0[3]) }
        }
    }
    
    private func _overlap(_ other: Shape.Component.BezierCollection.Element) -> Bool {
        
        guard !self.start.almostEqual(self.end) else { return false }
        guard !other.start.almostEqual(other.end) else { return false }
        
        let check_1 = self.fromPoint(other.start)
        let check_2 = self.fromPoint(other.end)
        let check_3 = other.fromPoint(self.start)
        let check_4 = other.fromPoint(self.end)
        
        var counter = 0
        
        if check_1 != nil { counter += 1 }
        if check_2 != nil { counter += 1 }
        if check_3 != nil { counter += 1 }
        if check_4 != nil { counter += 1 }
        
        return check_1 == 0 || check_1 == 1 || check_2 == 0 || check_2 == 1 || check_3 == 0 || check_3 == 1 || check_4 == 0 || check_4 == 1 ? counter > 2 : counter == 2
    }
    
    public func overlap(_ other: Shape.Component.BezierCollection.Element) -> Bool {
        
        switch self.segment {
        case let .line(p1):
            switch other.segment {
            case let .line(q1):
                if LinesIntersect(start, p1, other.start, q1) != nil {
                    return false
                }
            case let .quad(q1, q2):
                if !QuadBezierLineOverlap(other.start, q1, q2, start, p1) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicBezierLineOverlap(other.start, q1, q2, q3, start, p1) {
                    return false
                }
            }
        case let .quad(p1, p2):
            switch other.segment {
            case let .line(q1):
                if !QuadBezierLineOverlap(start, p1, p2, other.start, q1) {
                    return false
                }
            case let .quad(q1, q2):
                if !QuadBeziersOverlap(start, p1, p2, other.start, q1, q2) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicQuadBezierOverlap(other.start, q1, q2, q3, start, p1, p2) {
                    return false
                }
            }
        case let .cubic(p1, p2, p3):
            switch other.segment {
            case let .line(q1):
                if !CubicBezierLineOverlap(start, p1, p2, p3, other.start, q1) {
                    return false
                }
            case let .quad(q1, q2):
                if !CubicQuadBezierOverlap(start, p1, p2, p3, other.start, q1, q2) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicBeziersOverlap(start, p1, p2, p3, other.start, q1, q2, q3) {
                    return false
                }
            }
        }
        
        return _overlap(other)
    }
    
    public func intersect(_ other: Shape.Component.BezierCollection.Element) -> [(Double, Double)]? {
        var result: [(Double, Double)]? = nil
        switch self.segment {
        case let .line(p1):
            switch other.segment {
            case let .line(q1):
                if let p = LinesIntersect(start, p1, other.start, q1) {
                    result = [(fromPoint(p), other.fromPoint(p))].flatMap(split_check)
                }
            case let .quad(q1, q2):
                if let t = QuadBezierLineIntersect(other.start, q1, q2, start, p1) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2).eval($0)), $0) }.flatMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezierLineIntersect(other.start, q1, q2, q3, start, p1) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2, q3).eval($0)), $0) }.flatMap(split_check).sorted { $0.0 }
                }
            }
        case let .quad(p1, p2):
            switch other.segment {
            case let .line(q1):
                if let t = QuadBezierLineIntersect(start, p1, p2, other.start, q1) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2).eval($0))) }.flatMap(split_check).sorted { $0.0 }
                }
            case let .quad(q1, q2):
                if let t = QuadBeziersIntersect(start, p1, p2, other.start, q1, q2) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2).eval($0))) }.flatMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicQuadBezierIntersect(other.start, q1, q2, q3, start, p1, p2) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2, q3).eval($0)), $0) }.flatMap(split_check).sorted { $0.0 }
                }
            }
        case let .cubic(p1, p2, p3):
            switch other.segment {
            case let .line(q1):
                if let t = CubicBezierLineIntersect(start, p1, p2, p3, other.start, q1) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.flatMap(split_check).sorted { $0.0 }
                }
            case let .quad(q1, q2):
                if let t = CubicQuadBezierIntersect(start, p1, p2, p3, other.start, q1, q2) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.flatMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBeziersIntersect(start, p1, p2, p3, other.start, q1, q2, q3) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.flatMap(split_check).sorted { $0.0 }
                }
            }
        }
        
        return result == nil && _overlap(other) ? nil : result ?? []
    }
}
