//
//  ShapeSegment.swift
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
    
    @_fixed_layout
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
        public subscript(position: Int) -> Element {
            get {
                return Element(start: position == 0 ? component.start : component[position - 1].end, segment: component[position])
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
        
        @_fixed_layout
        public struct Element {
            
            public var start: Point
            public var segment: Shape.Segment
            
            @inlinable
            public init(start: Point, segment: Shape.Segment) {
                self.start = start
                self.segment = segment
            }
        }
    }
    
    @inlinable
    public var bezier: BezierCollection {
        get {
            return BezierCollection(component: self)
        }
        set {
            self = newValue.component
        }
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public init(_ bezier: Shape.Component.BezierCollection.Element) {
        switch bezier.segment {
        case let .line(p1): self.init(bezier.start, p1)
        case let .quad(p1, p2): self.init(bezier.start, p1, p2)
        case let .cubic(p1, p2, p3): self.init(bezier.start, p1, p2, p3)
        }
    }
}

extension Shape.Component.BezierCollection.Element {
    
    @inlinable
    public var boundary: Rect {
        switch self.segment {
        case let .line(p1): return LineSegment(self.start, p1).boundary
        case let .quad(p1, p2): return QuadBezier(self.start, p1, p2).boundary
        case let .cubic(p1, p2, p3): return CubicBezier(self.start, p1, p2, p3).boundary
        }
    }
}

extension Shape.Component.BezierCollection.Element {
    
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

extension Shape.Component.BezierCollection.Element {
    
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
            self.init(start: p0, segment: .cubic(p1, p2, p3))
        }
    }
}

extension Shape.Component.BezierCollection.Element {
    
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

@inlinable
func split_check(_ t: Double) -> Double? {
    if t.almostZero() {
        return 0
    } else if (t - 1).almostZero() {
        return 1
    } else if 0...1 ~= t {
        return t
    }
    return nil
}
@inlinable
func split_check(_ t: (Double?, Double?)) -> (Double, Double)? {
    if let lhs = t.0, let rhs = t.1 {
        return (lhs, rhs)
    }
    return nil
}
@inlinable
func split_check(_ t: (Double?, Double)) -> (Double, Double)? {
    if let lhs = t.0, let rhs = split_check(t.1) {
        return (lhs, rhs)
    }
    return nil
}
@inlinable
func split_check(_ t: (Double, Double?)) -> (Double, Double)? {
    if let lhs = split_check(t.0), let rhs = t.1 {
        return (lhs, rhs)
    }
    return nil
}

extension Shape.Component.BezierCollection.Element {
    
    @inlinable
    public func length(_ t: Double = 1) -> Double {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).length(t)
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).length(t)
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3)._length(t)
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
        case let .line(p1):
            let bezier = LineSegment(start, p1)
            return t.map { bezier.eval($0) }
        case let .quad(p1, p2):
            let bezier = QuadBezier(start, p1, p2)
            return t.map { bezier.eval($0) }
        case let .cubic(p1, p2, p3):
            let bezier = CubicBezier(start, p1, p2, p3)
            return t.map { bezier.eval($0) }
        }
    }
    
    @inlinable
    func _closest(_ p: Point) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<[Double], Double?>>, Double> {
        switch self.segment {
        case let .line(p1):
            return LineSegment(start, p1).closest(p).lazy.compactMap(split_check)
        case let .quad(p1, p2):
            return QuadBezier(start, p1, p2).closest(p).lazy.compactMap(split_check)
        case let .cubic(p1, p2, p3):
            return CubicBezier(start, p1, p2, p3).closest(p).lazy.compactMap(split_check)
        }
    }
    
    @inlinable
    public func closest(_ p: Point) -> Double {
        if p.distance(to: self.start) < p.distance(to: self.end) {
            if let s = self._closest(p).min(by: { p.distance(to: self.point($0)) }), p.distance(to: self.point(s)) < p.distance(to: self.start) {
                return s
            }
            return 0
        } else {
            if let s = self._closest(p).min(by: { p.distance(to: self.point($0)) }), p.distance(to: self.point(s)) < p.distance(to: self.end) {
                return s
            }
            return 1
        }
    }
    
    @inlinable
    public func fromPoint(_ p: Point) -> Double? {
        return self._closest(p).first { p.almostEqual(self.point($0)) }
    }
    
    @inlinable
    public func split(_ t: Double) -> (Shape.Component.BezierCollection.Element, Shape.Component.BezierCollection.Element) {
        switch self.segment {
        case let .line(p1):
            let _split = LineSegment(start, p1).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0), Shape.Component.BezierCollection.Element(_split.1))
        case let .quad(p1, p2):
            let _split = QuadBezier(start, p1, p2).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0), Shape.Component.BezierCollection.Element(_split.1))
        case let .cubic(p1, p2, p3):
            let _split = CubicBezier(start, p1, p2, p3).split(t)
            return (Shape.Component.BezierCollection.Element(_split.0), Shape.Component.BezierCollection.Element(_split.1))
        }
    }
    
    @inlinable
    public func split(_ t: [Double]) -> [Shape.Component.BezierCollection.Element] {
        switch self.segment {
        case let .line(p1): return LineSegment(start, p1).split(t).map { Shape.Component.BezierCollection.Element($0) }
        case let .quad(p1, p2): return QuadBezier(start, p1, p2).split(t).map { Shape.Component.BezierCollection.Element($0) }
        case let .cubic(p1, p2, p3): return CubicBezier(start, p1, p2, p3).split(t).map { Shape.Component.BezierCollection.Element($0) }
        }
    }
    
    @inlinable
    func _overlap(_ other: Shape.Component.BezierCollection.Element) -> Bool {
        
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
    
    @inlinable
    public func overlap(_ other: Shape.Component.BezierCollection.Element) -> Bool {
        
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
    public func intersect(_ other: Shape.Component.BezierCollection.Element) -> [(Double, Double)]? {
        
        var result: [(Double, Double)]?
        
        switch self.segment {
        case let .line(p1):
            switch other.segment {
            case let .line(q1):
                if let p = LineSegment(start, p1).intersect(LineSegment(other.start, q1)) {
                    result = [(fromPoint(p), other.fromPoint(p))].compactMap(split_check)
                }
            case let .quad(q1, q2):
                if let t = QuadBezier(other.start, q1, q2).intersect(LineSegment(start, p1)) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2).eval($0)), $0) }.compactMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(other.start, q1, q2, q3).intersect(LineSegment(start, p1)) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2, q3).eval($0)), $0) }.compactMap(split_check).sorted { $0.0 }
                }
            }
        case let .quad(p1, p2):
            switch other.segment {
            case let .line(q1):
                if let t = QuadBezier(start, p1, p2).intersect(LineSegment(other.start, q1)) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2).eval($0))) }.compactMap(split_check).sorted { $0.0 }
                }
            case let .quad(q1, q2):
                if let t = QuadBezier(start, p1, p2).intersect(QuadBezier(other.start, q1, q2)) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2).eval($0))) }.compactMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(other.start, q1, q2, q3).intersect(QuadBezier(start, p1, p2)) {
                    result = t.map { (fromPoint(Bezier(other.start, q1, q2, q3).eval($0)), $0) }.compactMap(split_check).sorted { $0.0 }
                }
            }
        case let .cubic(p1, p2, p3):
            switch other.segment {
            case let .line(q1):
                if let t = CubicBezier(start, p1, p2, p3).intersect(LineSegment(other.start, q1)) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.compactMap(split_check).sorted { $0.0 }
                }
            case let .quad(q1, q2):
                if let t = CubicBezier(start, p1, p2, p3).intersect(QuadBezier(other.start, q1, q2)) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.compactMap(split_check).sorted { $0.0 }
                }
            case let .cubic(q1, q2, q3):
                if let t = CubicBezier(start, p1, p2, p3).intersect(CubicBezier(other.start, q1, q2, q3)) {
                    result = t.map { ($0, other.fromPoint(Bezier(start, p1, p2, p3).eval($0))) }.compactMap(split_check).sorted { $0.0 }
                }
            }
        }
        
        return result == nil && _overlap(other) ? nil : result ?? []
    }
}
