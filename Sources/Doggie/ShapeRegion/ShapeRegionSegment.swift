//
//  ShapeRegionSegment.swift
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

typealias ShapeRegionSegment = Shape.Component.BezierCollection.Element

extension ShapeRegionSegment {
    
    init(_ p0: Point, _ p1: Point) {
        self.init(start: p0, segment: .line(p1))
    }
    
    init(_ p0: Point, _ p1: Point, _ p2: Point) {
        if cross(p1 - p0, p2 - p0).almostZero() {
            self.init(start: p0, segment: .line(p2))
        } else {
            self.init(start: p0, segment: .quad(p1, p2))
        }
    }
    
    init(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
        if cross(p1 - p0, p2 - p0).almostZero() && cross(p1 - p0, p3 - p0).almostZero() && cross(p2 - p0, p3 - p0).almostZero() {
            self.init(start: p0, segment: .line(p3))
        } else {
            self.init(start: p0, segment: .cubic(p1, p2, p3))
        }
    }
}

extension ShapeRegionSegment {
    
    var isPoint: Bool {
        switch self.segment {
        case let .line(end): return start.almostEqual(end)
        default: return false
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

extension ShapeRegionSegment {
    
    func point(_ t: Double) -> Point {
        return Bezier(self).eval(t)
    }
    
    func fromPoint(_ p: Point) -> Double? {
        return Bezier(self).closest(p).lazy.flatMap(split_check).first { p.almostEqual(self.point($0)) }
    }
    
    func split(_ t: Double) -> (ShapeRegionSegment, ShapeRegionSegment) {
        switch self.segment {
        case let .line(p1):
            let _split = Bezier(start, p1).split(t)
            return (ShapeRegionSegment(_split.0[0], _split.0[1]), ShapeRegionSegment(_split.1[0], _split.1[1]))
        case let .quad(p1, p2):
            let _split = Bezier(start, p1, p2).split(t)
            return (ShapeRegionSegment(_split.0[0], _split.0[1], _split.0[2]), ShapeRegionSegment(_split.1[0], _split.1[1], _split.1[2]))
        case let .cubic(p1, p2, p3):
            let _split = Bezier(start, p1, p2, p3).split(t)
            return (ShapeRegionSegment(_split.0[0], _split.0[1], _split.0[2], _split.0[3]), ShapeRegionSegment(_split.1[0], _split.1[1], _split.1[2], _split.1[3]))
        }
    }
    
    func split(_ t: [Double]) -> [ShapeRegionSegment] {
        switch self.segment {
        case let .line(p1): return Bezier(start, p1).split(t).map { ShapeRegionSegment($0[0], $0[1]) }
        case let .quad(p1, p2): return Bezier(start, p1, p2).split(t).map { ShapeRegionSegment($0[0], $0[1], $0[2]) }
        case let .cubic(p1, p2, p3): return Bezier(start, p1, p2, p3).split(t).map { ShapeRegionSegment($0[0], $0[1], $0[2], $0[3]) }
        }
    }
    
    func intersect(_ other: ShapeRegionSegment) -> [(Double, Double)]? {
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
        if result == nil {
            let check_1 = self.fromPoint(other.start)
            let check_2 = self.fromPoint(other.end)
            let check_3 = other.fromPoint(self.start)
            let check_4 = other.fromPoint(self.end)
            if check_1 == 0 {
                if check_2 != nil && check_2 != 0 { return nil }
                if check_4 != nil && check_4 != 0 { return nil }
            } else if check_2 == 0 {
                if check_1 != nil && check_1 != 0 { return nil }
                if check_4 != nil && check_4 != 1 { return nil }
            } else if check_3 == 0 {
                if check_4 != nil && check_4 != 0 { return nil }
                if check_2 != nil && check_2 != 0 { return nil }
            } else if check_4 == 0 {
                if check_3 != nil && check_3 != 0 { return nil }
                if check_2 != nil && check_2 != 1 { return nil }
            } else if check_1 == 1 {
                if check_2 != nil && check_2 != 1 { return nil }
                if check_3 != nil && check_3 != 0 { return nil }
            } else if check_2 == 1 {
                if check_1 != nil && check_1 != 1 { return nil }
                if check_3 != nil && check_3 != 1 { return nil }
            } else if check_3 == 1 {
                if check_4 != nil && check_4 != 1 { return nil }
                if check_1 != nil && check_1 != 0 { return nil }
            } else if check_4 == 1 {
                if check_3 != nil && check_3 != 1 { return nil }
                if check_1 != nil && check_1 != 1 { return nil }
            } else if check_1 != nil && check_2 != nil && check_3 == nil && check_4 == nil { return nil
            } else if check_1 == nil && check_2 == nil && check_3 != nil && check_4 != nil { return nil
            }
        }
        return result ?? []
    }
}
