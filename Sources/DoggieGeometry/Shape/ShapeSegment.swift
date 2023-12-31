//
//  ShapeSegment.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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
    
    @frozen
    public struct BezierSegment {
        
        public var start: Point
        public var segment: Shape.Segment
        
        @inlinable
        public init(start: Point, segment: Shape.Segment) {
            self.start = start
            self.segment = segment
        }
    }
    
    @frozen
    public struct BezierCollection: RandomAccessCollection, MutableCollection {
        
        public typealias Indices = Range<Int>
        
        public typealias Index = Int
        
        @usableFromInline
        var component: Shape.Component
        
        @usableFromInline
        init(component: Shape.Component) {
            self.component = component
        }
        
        @inlinable
        public var startIndex: Int {
            return component.startIndex
        }
        
        @inlinable
        public var endIndex: Int {
            return component.endIndex
        }
        
        @inlinable
        public subscript(position: Int) -> Shape.BezierSegment {
            get {
                return Shape.BezierSegment(start: position == 0 ? component.start : component[position - 1].end, segment: component[position])
            }
            set {
                if position == 0 {
                    component.start = newValue.start
                } else {
                    component[position - 1].end = newValue.start
                }
                component[position] = newValue.segment
            }
        }
    }
}

extension Shape.Component {
    
    @inlinable
    public var bezier: Shape.BezierCollection {
        get {
            return Shape.BezierCollection(component: self)
        }
        set {
            self = newValue.component
        }
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public init(_ bezier: Shape.BezierSegment) {
        switch bezier.segment {
        case let .line(p1): self.init(bezier.start, p1)
        case let .quad(p1, p2): self.init(bezier.start, p1, p2)
        case let .cubic(p1, p2, p3): self.init(bezier.start, p1, p2, p3)
        }
    }
}

extension Shape.BezierSegment {
    
    @inlinable
    public var boundary: Rect {
        switch self.segment {
        case let .line(p1): return LineSegment(self.start, p1).boundary
        case let .quad(p1, p2): return QuadBezier(self.start, p1, p2).boundary
        case let .cubic(p1, p2, p3): return CubicBezier(self.start, p1, p2, p3).boundary
        }
    }
}

extension Shape.BezierSegment {
    
    @inlinable
    public var end: Point {
        get {
            return segment.end
        }
        set {
            segment.end = newValue
        }
    }
}

extension Shape.BezierSegment {
    
    @inlinable
    public init(_ p0: Point, _ p1: Point) {
        self.init(start: p0, segment: .line(p1))
    }
    @inlinable
    public init(_ p0: Point, _ p1: Point, _ p2: Point) {
        if cross(p1 - p0, p2 - p0).almostZero() {
            self.init(start: p0, segment: .line(p2))
        } else {
            self.init(start: p0, segment: .quad(p1, p2))
        }
    }
    @inlinable
    public init(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) {
        
        if cross(p1 - p0, p2 - p0).almostZero() && cross(p1 - p0, p3 - p0).almostZero() && cross(p2 - p0, p3 - p0).almostZero() {
            
            self.init(start: p0, segment: .line(p3))
            
        } else {
            
            let (q1, q2, q3) = CubicBezier(p0, p1, p2, p3)._polynomial
            
            let d1 = -cross(q3, q2)
            let d2 = cross(q3, q1)
            let d3 = -cross(q2, q1)
            
            if d1.almostZero() && d2.almostZero() && !d3.almostZero(), let intersect = LineSegment(p0, p1).intersect(LineSegment(p2, p3)) {
                self.init(start: p0, segment: .quad(intersect, p3))
            } else {
                self.init(start: p0, segment: .cubic(p1, p2, p3))
            }
        }
    }
}

extension Shape.BezierSegment {
    
    @inlinable
    public init(_ bezier: LineSegment<Point>) {
        self.init(bezier.p0, bezier.p1)
    }
    @inlinable
    public init(_ bezier: QuadBezier<Point>) {
        self.init(bezier.p0, bezier.p1, bezier.p2)
    }
    @inlinable
    public init(_ bezier: CubicBezier<Point>) {
        self.init(bezier.p0, bezier.p1, bezier.p2, bezier.p3)
    }
}

extension Shape.BezierSegment {
    
    @inlinable
    public func reversed() -> Shape.BezierSegment {
        switch self.segment {
        case let .line(p1): return Shape.BezierSegment(p1, start)
        case let .quad(p1, p2): return Shape.BezierSegment(p2, p1, start)
        case let .cubic(p1, p2, p3): return Shape.BezierSegment(p3, p2, p1, start)
        }
    }
    
    @inlinable
    public func length(_ t: Double = 1) -> Double {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).length(t)
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).length(t)
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3)._length(t)
        }
    }
    
    @inlinable
    public var area: Double {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).area
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).area
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3).area
        }
    }
    
    @inlinable
    public func _invisible(reference: Double) -> Bool {
        switch self.segment {
        case let .line(p1): return start.almostEqual(p1, reference: reference)
        case let .quad(_, p2): return start.almostEqual(p2, reference: reference)
        case let .cubic(p1, p2, p3): return start.almostEqual(p1, reference: reference) && p1.almostEqual(p2, reference: reference) && p2.almostEqual(p3, reference: reference)
        }
    }
    
    @inlinable
    public func point(_ t: Double) -> Point {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).eval(t)
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).eval(t)
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3).eval(t)
        }
    }
    
    @inlinable
    public func points(_ t: [Double]) -> [Point] {
        switch self.segment {
        case let .line(p1): return t.map { LineSegment(start, p1).eval($0) }
        case let .quad(p1, p2): return t.map { QuadBezier(start, p1, p2).eval($0) }
        case let .cubic(p1, p2, p3): return t.map { CubicBezier(start, p1, p2, p3).eval($0) }
        }
    }
    
    @inlinable
    func split_check(_ t: Double) -> Double? {
        guard 0...1 ~= t else { return nil }
        let p = self.point(t)
        if t.almostZero() || start.almostEqual(p) { return 0 }
        if t.almostEqual(1) || end.almostEqual(p) { return 1 }
        return t
    }
    
    @inlinable
    func __closest(_ p: Point) -> Double? {
        let list: [Double]
        switch self.segment {
        case let .line(p1): list = LineSegment(start, p1).closest(p)
        case let .quad(p1, p2): list = QuadBezier(start, p1, p2).closest(p)
        case let .cubic(p1, p2, p3): list = CubicBezier(start, p1, p2, p3).closest(p)
        }
        return list.first { split_check($0) != nil && p.almostEqual(self.point($0)) } ?? list.first { p.almostEqual(self.point($0)) } ?? list.first
    }
    
    @inlinable
    public func _closest(_ p: Point) -> Double? {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).closest(p, in: -0.5...1.5).lazy.compactMap(split_check).first { p.almostEqual(self.point($0)) }
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).closest(p, in: -0.5...1.5).lazy.compactMap(split_check).first { p.almostEqual(self.point($0)) }
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3).closest(p, in: -0.5...1.5).lazy.compactMap(split_check).first { p.almostEqual(self.point($0)) }
        }
    }
    
    @inlinable
    public func closest(_ p: Point) -> Double {
        let _min = p.distance(to: self.start) < p.distance(to: self.end) ? 0.0 : 1.0
        return self.__closest(p).flatMap(split_check) ?? _min
    }
    
    @inlinable
    public func split(_ t: Double) -> (Shape.BezierSegment, Shape.BezierSegment) {
        switch self.segment {
        case let .line(p1):
            let _split = LineSegment(start, p1).split(t)
            return (Shape.BezierSegment(_split.0), Shape.BezierSegment(_split.1))
        case let .quad(p1, p2):
            let _split = QuadBezier(start, p1, p2).split(t)
            return (Shape.BezierSegment(_split.0), Shape.BezierSegment(_split.1))
        case let .cubic(p1, p2, p3):
            let _split = CubicBezier(start, p1, p2, p3).split(t)
            return (Shape.BezierSegment(_split.0), Shape.BezierSegment(_split.1))
        }
    }
    
    @inlinable
    public func split(_ t: [Double]) -> [Shape.BezierSegment] {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).split(t).map { Shape.BezierSegment($0) }
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).split(t).map { Shape.BezierSegment($0) }
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3).split(t).map { Shape.BezierSegment($0) }
        }
    }
    
    @inlinable
    func _overlap(_ other: Shape.BezierSegment) -> Bool {
        
        guard !self.start.almostEqual(self.end) else { return false }
        guard !other.start.almostEqual(other.end) else { return false }
        
        let check_1 = self._closest(other.start)
        let check_2 = self._closest(other.end)
        let check_3 = other._closest(self.start)
        let check_4 = other._closest(self.end)
        
        var counter = 0
        
        if check_1 != nil { counter += 1 }
        if check_2 != nil { counter += 1 }
        if check_3 != nil { counter += 1 }
        if check_4 != nil { counter += 1 }
        
        return check_1 == 0 || check_1 == 1 || check_2 == 0 || check_2 == 1 || check_3 == 0 || check_3 == 1 || check_4 == 0 || check_4 == 1 ? counter > 2 : counter == 2
    }
    
    @inlinable
    public func overlap(_ other: Shape.BezierSegment) -> Bool {
        
        switch self.segment {
        case let .line(p1):
            switch other.segment {
            case let .line(q1):
                if LineSegment(start, p1).intersect(LineSegment(other.start, q1)) != nil {
                    return false
                }
            case let .quad(q1, q2):
                if !QuadBezier(other.start, q1, q2).overlap(LineSegment(start, p1)) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicBezier(other.start, q1, q2, q3).overlap(LineSegment(start, p1)) {
                    return false
                }
            }
        case let .quad(p1, p2):
            switch other.segment {
            case let .line(q1):
                if !QuadBezier(start, p1, p2).overlap(LineSegment(other.start, q1)) {
                    return false
                }
            case let .quad(q1, q2):
                if !QuadBezier(start, p1, p2).overlap(QuadBezier(other.start, q1, q2)) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicBezier(other.start, q1, q2, q3).overlap(QuadBezier(start, p1, p2)) {
                    return false
                }
            }
        case let .cubic(p1, p2, p3):
            switch other.segment {
            case let .line(q1):
                if !CubicBezier(start, p1, p2, p3).overlap(LineSegment(other.start, q1)) {
                    return false
                }
            case let .quad(q1, q2):
                if !CubicBezier(start, p1, p2, p3).overlap(QuadBezier(other.start, q1, q2)) {
                    return false
                }
            case let .cubic(q1, q2, q3):
                if !CubicBezier(start, p1, p2, p3).overlap(CubicBezier(other.start, q1, q2, q3)) {
                    return false
                }
            }
        }
        
        return _overlap(other)
    }
    
    @inlinable
    public func intersect(_ other: Shape.BezierSegment) -> [(Double, Double)]? {
        
        @inline(__always)
        func _filter(_ lhs: Double?, _ rhs: Double?) -> (Double, Double)? {
            if let lhs = lhs, let rhs = rhs {
                return (lhs, rhs)
            }
            return nil
        }
        
        var result: [(Double, Double)]?
        
        switch self.segment {
        case let .line(p1):
            switch other.segment {
            case let .line(q1):
                if let p = LineSegment(start, p1).intersect(LineSegment(other.start, q1)) {
                    result = _filter(__closest(p), other.__closest(p)).map { [($0, $1)] } ?? []
                }
            case let .quad(q1, q2):
                if let t = QuadBezier(other.start, q1, q2).intersect(LineSegment(start, p1), in: -0.5...1.5) {
                    result = t.compactMap { _filter(__closest(QuadBezier(other.start, q1, q2).eval($0)), $0) }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(other.start, q1, q2, q3).intersect(LineSegment(start, p1), in: -0.5...1.5) {
                    result = t.compactMap { _filter(__closest(CubicBezier(other.start, q1, q2, q3).eval($0)), $0) }
                }
            }
        case let .quad(p1, p2):
            switch other.segment {
            case let .line(q1):
                if let t = QuadBezier(start, p1, p2).intersect(LineSegment(other.start, q1), in: -0.5...1.5) {
                    result = t.compactMap { _filter($0, other.__closest(QuadBezier(start, p1, p2).eval($0))) }
                }
            case let .quad(q1, q2):
                if let t = QuadBezier(start, p1, p2).intersect(QuadBezier(other.start, q1, q2), in: -0.5...1.5) {
                    result = t.compactMap { _filter($0, other.__closest(QuadBezier(start, p1, p2).eval($0))) }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(other.start, q1, q2, q3).intersect(QuadBezier(start, p1, p2), in: -0.5...1.5) {
                    result = t.compactMap { _filter(__closest(CubicBezier(other.start, q1, q2, q3).eval($0)), $0) }
                }
            }
        case let .cubic(p1, p2, p3):
            switch other.segment {
            case let .line(q1):
                if let t = CubicBezier(start, p1, p2, p3).intersect(LineSegment(other.start, q1), in: -0.5...1.5) {
                    result = t.compactMap { _filter($0, other.__closest(CubicBezier(start, p1, p2, p3).eval($0))) }
                }
            case let .quad(q1, q2):
                if let t = CubicBezier(start, p1, p2, p3).intersect(QuadBezier(other.start, q1, q2), in: -0.5...1.5) {
                    result = t.compactMap { _filter($0, other.__closest(CubicBezier(start, p1, p2, p3).eval($0))) }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(start, p1, p2, p3).intersect(CubicBezier(other.start, q1, q2, q3), in: -0.5...1.5) {
                    result = t.compactMap { _filter($0, other.__closest(CubicBezier(start, p1, p2, p3).eval($0))) }
                }
            }
        }
        
        if var result = result {
            
            let check1 = start.almostEqual(other.start)
            let check2 = start.almostEqual(other.end)
            let check3 = end.almostEqual(other.start)
            let check4 = end.almostEqual(other.end)
            
            let check5 = check1 || check2 || other._closest(start) != nil
            let check6 = check3 || check4 || other._closest(end) != nil
            let check7 = check1 || check3 || self._closest(other.start) != nil
            let check8 = check2 || check4 || self._closest(other.end) != nil
            
            if check5, let idx = result.enumerated().min(by: { abs($0.1.0) })?.0 { result[idx].0 = 0 }
            if check6, let idx = result.enumerated().min(by: { abs($0.1.0 - 1) })?.0 { result[idx].0 = 1 }
            if check7, let idx = result.enumerated().min(by: { abs($0.1.1) })?.0 { result[idx].1 = 0 }
            if check8, let idx = result.enumerated().min(by: { abs($0.1.1 - 1) })?.0 { result[idx].1 = 1 }
            
            return result.compactMap { _filter(split_check($0), split_check($1)) }.sorted { $0.0 }
        }
        
        return _overlap(other) ? nil : []
    }
}

@inlinable
public func * (lhs: Shape.BezierSegment, rhs: SDTransform) -> Shape.BezierSegment {
    return Shape.BezierSegment(start: lhs.start * rhs, segment: lhs.segment * rhs)
}
@inlinable
public func *= (lhs: inout Shape.BezierSegment, rhs: SDTransform) {
    lhs = lhs * rhs
}
