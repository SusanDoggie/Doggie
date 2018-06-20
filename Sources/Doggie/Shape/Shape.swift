//
//  Shape.swift
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

public struct Shape : RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public enum Segment {
        
        case line(Point)
        case quad(Point, Point)
        case cubic(Point, Point, Point)
    }
    
    public struct Component {
        
        public var start: Point
        public var isClosed: Bool
        
        fileprivate var segments: [Segment]
        
        var cache = Shape.Component.Cache()
        
        public init() {
            self.start = Point()
            self.isClosed = false
            self.segments = []
        }
        
        public init<S : Sequence>(start: Point, closed: Bool = false, segments: S) where S.Element == Segment {
            self.start = start
            self.isClosed = closed
            self.segments = Array(segments)
        }
    }
    
    private var components: [Component]
    
    public var transform : SDTransform = SDTransform.identity {
        willSet {
            if transform != newValue {
                cache = cache.lck.synchronized { Cache(originalBoundary: cache.originalBoundary, table: cache.table) }
            }
        }
    }
    
    var cache = Cache()
    
    public init() {
        self.components = []
    }
    
    public init(arrayLiteral elements: Component ...) {
        self.components = elements
    }
    
    public init<S : Sequence>(_ components: S) where S.Element == Component {
        self.components = Array(components)
    }
    
    public var center : Point {
        get {
            return originalBoundary.center * transform
        }
        set {
            let offset = newValue - center
            transform *= SDTransform.translate(x: offset.x, y: offset.y)
        }
    }
    
    public subscript(position : Int) -> Component {
        get {
            return components[position]
        }
        set {
            cache = Cache()
            components[position] = newValue
        }
    }
    
    public var startIndex: Int {
        return components.startIndex
    }
    
    public var endIndex: Int {
        return components.endIndex
    }
    
    public var boundary : Rect {
        return self.originalBoundary.apply(transform) ?? identity.originalBoundary
    }
    
    public var originalBoundary : Rect {
        return cache.lck.synchronized {
            if cache.originalBoundary == nil {
                cache.originalBoundary = self.components.reduce(nil) { $0?.union($1.boundary) ?? $1.boundary } ?? Rect()
            }
            return cache.originalBoundary!
        }
    }
    
    public mutating func rotate(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.rotate(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    public mutating func scale(_ scale: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(scale) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    public var frame : [Point] {
        let _transform = self.transform
        return originalBoundary.points.map { $0 * _transform }
    }
}

extension Shape {
    
    public var currentPoint: Point {
        guard let last = self.components.last else { return Point() }
        return last.isClosed ? last.start : last.end
    }
}

extension Shape {
    
    class Cache {
        
        let lck = SDLock()
        
        var originalBoundary: Rect?
        var identity : Shape?
        
        var area: Double?
        
        var table: [String : Any]
        
        init() {
            self.originalBoundary = nil
            self.identity = nil
            self.area = nil
            self.table = [:]
        }
        init(originalBoundary: Rect?, table: [String : Any]) {
            self.originalBoundary = originalBoundary
            self.identity = nil
            self.area = nil
            self.table = table
        }
    }
    
    var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
}

extension Shape.Cache {
    
    subscript<Value>(key: String) -> Value? {
        get {
            return lck.synchronized { table[key] as? Value }
        }
        set {
            lck.synchronized { table[key] = newValue }
        }
    }
    
    subscript<Value>(key: String, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
    
    subscript<Value>(key: String, body: () -> Value) -> Value {
        
        return lck.synchronized {
            
            if let object = table[key], let value = object as? Value {
                return value
            }
            let value = body()
            table[key] = value
            return value
        }
    }
}

extension Shape.Component {
    
    class Cache {
        
        let lck = SDLock()
        
        var spaces: RectCollection?
        var boundary: Rect?
        var area: Double?
        
        var table: [String : Any]
        
        init() {
            self.spaces = nil
            self.boundary = nil
            self.area = nil
            self.table = [:]
        }
    }
    
    var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
}

extension Shape.Component.Cache {
    
    subscript<Value>(key: String) -> Value? {
        get {
            return lck.synchronized { table[key] as? Value }
        }
        set {
            lck.synchronized { table[key] = newValue }
        }
    }
    
    subscript<Value>(key: String, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
    
    subscript<Value>(key: String, body: () -> Value) -> Value {
        
        return lck.synchronized {
            
            if let object = table[key], let value = object as? Value {
                return value
            }
            let value = body()
            table[key] = value
            return value
        }
    }
}

extension Shape.Component {
    
    public var spaces : RectCollection {
        return cache.lck.synchronized {
            if cache.spaces == nil {
                var lastPoint = start
                var bounds: [Rect] = []
                bounds.reserveCapacity(segments.count)
                for segment in segments {
                    switch segment {
                    case let .line(p1):
                        bounds.append(LineSegment(lastPoint, p1).boundary)
                        lastPoint = p1
                    case let .quad(p1, p2):
                        bounds.append(QuadBezier(lastPoint, p1, p2).boundary)
                        lastPoint = p2
                    case let .cubic(p1, p2, p3):
                        bounds.append(CubicBezier(lastPoint, p1, p2, p3).boundary)
                        lastPoint = p3
                    }
                }
                cache.spaces = RectCollection(bounds)
            }
            return cache.spaces!
        }
    }
    
    public var boundary : Rect {
        return cache.lck.synchronized {
            if cache.boundary == nil {
                var lastPoint = start
                var bound = Rect(origin: start, size: Size())
                for segment in segments {
                    switch segment {
                    case let .line(p1):
                        bound = bound.union(LineSegment(lastPoint, p1).boundary)
                        lastPoint = p1
                    case let .quad(p1, p2):
                        bound = bound.union(QuadBezier(lastPoint, p1, p2).boundary)
                        lastPoint = p2
                    case let .cubic(p1, p2, p3):
                        bound = bound.union(CubicBezier(lastPoint, p1, p2, p3).boundary)
                        lastPoint = p3
                    }
                }
                cache.boundary = bound
            }
            return cache.boundary!
        }
    }
}

extension Shape.Component {
    
    public var area: Double {
        return cache.lck.synchronized {
            if cache.area == nil {
                var lastPoint = start
                var _area: Double = 0
                for segment in segments {
                    switch segment {
                    case let .line(p1):
                        _area += LineSegment(lastPoint, p1).area
                        lastPoint = p1
                    case let .quad(p1, p2):
                        _area += QuadBezier(lastPoint, p1, p2).area
                        lastPoint = p2
                    case let .cubic(p1, p2, p3):
                        _area += CubicBezier(lastPoint, p1, p2, p3).area
                        lastPoint = p3
                    }
                }
                cache.area = _area + LineSegment(lastPoint, start).area
            }
            return cache.area!
        }
    }
}

extension Shape.Component : RandomAccessCollection, MutableCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return segments.startIndex
    }
    
    public var endIndex: Int {
        return segments.endIndex
    }
    
    public subscript(position : Int) -> Shape.Segment {
        get {
            return segments[position]
        }
        set {
            cache = Cache()
            segments[position] = newValue
        }
    }
}

extension Shape.Segment {
    
    public var end: Point {
        get {
            switch self {
            case let .line(p1): return p1
            case let .quad(_, p2): return p2
            case let .cubic(_, _, p3): return p3
            }
        }
        set {
            switch self {
            case .line: self = .line(newValue)
            case let .quad(p1, _): self = .quad(p1, newValue)
            case let .cubic(p1, p2, _): self = .cubic(p1, p2, newValue)
            }
        }
    }
}
extension Shape.Component {
    
    public var end: Point {
        return segments.last?.end ?? start
    }
}

extension Shape.Component : RangeReplaceableCollection {
    
    public mutating func append(_ newElement: Shape.Segment) {
        cache = Cache()
        segments.append(newElement)
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == Shape.Segment {
        cache = Cache()
        segments.append(contentsOf: newElements)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        segments.reserveCapacity(minimumCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Shape.Segment {
        cache = Cache()
        segments.replaceSubrange(subRange, with: newElements)
    }
}

extension Shape.Component {
    
    public struct BezierCollection: RandomAccessCollection, MutableCollection {
        
        public typealias Indices = Range<Int>
        
        public typealias Index = Int
        
        fileprivate var component: Shape.Component
        
        public var startIndex: Int {
            return component.startIndex
        }
        public var endIndex: Int {
            return component.endIndex
        }
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
        
        public struct Element {
            
            public var start: Point
            public var segment: Shape.Segment
            
            public init(start: Point, segment: Shape.Segment) {
                self.start = start
                self.segment = segment
            }
        }
    }
    
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
    
    public init(_ bezier: Shape.Component.BezierCollection.Element) {
        switch bezier.segment {
        case let .line(p1): self.init(bezier.start, p1)
        case let .quad(p1, p2): self.init(bezier.start, p1, p2)
        case let .cubic(p1, p2, p3): self.init(bezier.start, p1, p2, p3)
        }
    }
}

extension Shape.Component.BezierCollection.Element {
    
    public var boundary: Rect {
        switch self.segment {
        case let .line(p1): return LineSegment(self.start, p1).boundary
        case let .quad(p1, p2): return QuadBezier(self.start, p1, p2).boundary
        case let .cubic(p1, p2, p3): return CubicBezier(self.start, p1, p2, p3).boundary
        }
    }
}

extension Shape.Component.BezierCollection.Element {
    
    public var end: Point {
        get {
            return segment.end
        }
        set {
            segment.end = newValue
        }
    }
}

extension Shape.Component {
    
    public mutating func reverse() {
        self = self.reversed()
    }
    
    public func reversed() -> Shape.Component {
        
        var _segments: [Shape.Segment] = []
        _segments.reserveCapacity(segments.count)
        
        var p0 = start
        
        for segment in segments {
            switch segment {
            case let .line(p1):
                _segments.append(.line(p0))
                p0 = p1
            case let .quad(p1, p2):
                _segments.append(.quad(p1, p0))
                p0 = p2
            case let .cubic(p1, p2, p3):
                _segments.append(.cubic(p2, p1, p0))
                p0 = p3
            }
        }
        
        let reversed = Shape.Component(start: p0, closed: isClosed, segments: _segments.reversed())
        
        cache.lck.synchronized {
            reversed.cache.spaces = self.cache.spaces.map { RectCollection($0.reversed()) }
            reversed.cache.boundary = self.cache.boundary
            reversed.cache.area = self.cache.area.map { -$0 }
        }
        
        return reversed
    }
}

extension Shape {
    
    public static func Polygon(center: Point, radius: Double, edges: Int) -> Shape {
        precondition(edges >= 3, "Edges is less than 3")
        let _n = 2 * Double.pi / Double(edges)
        let segments: [Shape.Segment] = (1..<edges).map { .line(Point(x: center.x + radius * cos(_n * Double($0)), y: center.y + radius * sin(_n * Double($0)))) }
        return [Component(start: Point(x: center.x + radius, y: center.y), closed: true, segments: segments)]
    }
    
    public init(rect: Rect) {
        let points = rect.standardized.points
        self = [Component(start: points[0], closed: true, segments: [.line(points[1]), .line(points[2]), .line(points[3])])]
    }
    
    public init(roundedRect rect: Rect, radius: Radius) {
        let rect = rect.standardized
        let x_radius = Swift.min(0.5 * rect.width, abs(radius.x))
        let y_radius = Swift.min(0.5 * rect.height, abs(radius.y))
        let transform = SDTransform.scale(x: x_radius, y: y_radius) * SDTransform.translate(x: x_radius + rect.x, y: y_radius + rect.y)
        
        let x_padding = rect.width - 2 * x_radius
        let y_padding = rect.height - 2 * y_radius
        
        let t1 = transform * SDTransform.translate(x: x_padding, y: y_padding)
        let t2 = transform * SDTransform.translate(x: 0, y: y_padding)
        let t3 = transform * SDTransform.translate(x: 0, y: 0)
        let t4 = transform * SDTransform.translate(x: x_padding, y: 0)
        
        let segments: [Shape.Segment] = [
            .cubic(BezierCircle[1] * t1, BezierCircle[2] * t1, BezierCircle[3] * t1), .line(BezierCircle[3] * t2),
            .cubic(BezierCircle[4] * t2, BezierCircle[5] * t2, BezierCircle[6] * t2), .line(BezierCircle[6] * t3),
            .cubic(BezierCircle[7] * t3, BezierCircle[8] * t3, BezierCircle[9] * t3), .line(BezierCircle[9] * t4),
            .cubic(BezierCircle[10] * t4, BezierCircle[11] * t4, BezierCircle[12] * t4)
        ]
        self = [Component(start: BezierCircle[0] * t1, closed: true, segments: segments)]
    }
    
    public init(ellipseIn rect: Rect) {
        let rect = rect.standardized
        let transform = SDTransform.scale(x: 0.5 * rect.width, y: 0.5 * rect.height) * SDTransform.translate(x: rect.midX, y: rect.midY)
        let segments: [Shape.Segment] = [
            .cubic(BezierCircle[1] * transform, BezierCircle[2] * transform, BezierCircle[3] * transform),
            .cubic(BezierCircle[4] * transform, BezierCircle[5] * transform, BezierCircle[6] * transform),
            .cubic(BezierCircle[7] * transform, BezierCircle[8] * transform, BezierCircle[9] * transform),
            .cubic(BezierCircle[10] * transform, BezierCircle[11] * transform, BezierCircle[12] * transform)
        ]
        self = [Component(start: BezierCircle[0] * transform, closed: true, segments: segments)]
    }
}

extension Shape {
    
    public var originalArea : Double {
        return cache.lck.synchronized {
            if cache.area == nil {
                cache.area = self.components.reduce(0) { $0 + $1.area }
            }
            return cache.area!
        }
    }
    
    public var area: Double {
        return identity.originalArea
    }
}

extension Shape : RangeReplaceableCollection {
    
    public mutating func append(_ newElement: Component) {
        cache = Cache()
        components.append(newElement)
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == Component {
        cache = Cache()
        components.append(contentsOf: newElements)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        components.reserveCapacity(minimumCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Component {
        cache = Cache()
        components.replaceSubrange(subRange, with: newElements)
    }
}

extension Shape {
    
    public var identity : Shape {
        if transform == SDTransform.identity {
            return self
        }
        return cache.lck.synchronized {
            if cache.identity == nil {
                cache.identity = Shape(self.components.map { $0 * transform })
            }
            return cache.identity!
        }
    }
}

public func * (lhs: Shape.Component, rhs: SDTransform) -> Shape.Component {
    return Shape.Component(start: lhs.start * rhs, closed: lhs.isClosed, segments: lhs.segments.map {
        switch $0 {
        case let .line(p1): return .line(p1 * rhs)
        case let .quad(p1, p2): return .quad(p1 * rhs, p2 * rhs)
        case let .cubic(p1, p2, p3): return .cubic(p1 * rhs, p2 * rhs, p3 * rhs)
        }
    })
}
public func *= (lhs: inout Shape.Component, rhs: SDTransform) {
    lhs = lhs * rhs
}

public func * (lhs: Shape, rhs: SDTransform) -> Shape {
    var result = lhs
    result.transform *= rhs
    return result
}
public func *= (lhs: inout Shape, rhs: SDTransform) {
    lhs = lhs * rhs
}

