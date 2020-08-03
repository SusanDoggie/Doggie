//
//  Shape.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@frozen
public struct Shape: RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public enum Segment {
        
        case line(Point)
        case quad(Point, Point)
        case cubic(Point, Point, Point)
    }
    
    @frozen
    public struct Component {
        
        public var start: Point
        public var isClosed: Bool
        
        @usableFromInline
        var segments: ArraySlice<Segment>
        
        @usableFromInline
        var cache = Shape.Component.Cache()
        
        @inlinable
        public init() {
            self.start = Point()
            self.isClosed = false
            self.segments = []
        }
        
        @inlinable
        public init<S: Sequence>(start: Point, closed: Bool = false, segments: S) where S.Element == Segment {
            self.start = start
            self.isClosed = closed
            self.segments = segments as? ArraySlice ?? ArraySlice(segments)
        }
    }
    
    @usableFromInline
    var components: [Component]
    
    public var transform: SDTransform = .identity {
        willSet {
            if transform != newValue {
                cache = cache.lck.synchronized { Cache(originalBoundary: cache.originalBoundary, originalArea: cache.originalArea, table: cache.table) }
            }
        }
    }
    
    @usableFromInline
    var cache = Cache()
    
    @inlinable
    public init() {
        self.components = []
    }
    
    @inlinable
    public init(arrayLiteral elements: Component ...) {
        self.components = elements
        self.makeContiguousBuffer()
    }
    
    @inlinable
    public init<S: Sequence>(_ components: S) where S.Element == Component {
        self.components = Array(components)
        self.makeContiguousBuffer()
    }
}

extension Shape: Hashable {
    
    @inlinable
    public static func == (lhs: Shape, rhs: Shape) -> Bool {
        return lhs.transform == rhs.transform && (lhs.components.isStorageEqual(rhs.components) || lhs.components == rhs.components)
    }
    
    @inlinable
    @inline(__always)
    public func isStorageEqual(_ other: Shape) -> Bool {
        return self.transform == other.transform && self.components.isStorageEqual(other.components)
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transform)
        hasher.combine(components)
    }
}

extension Shape.Segment: Hashable {
    
}

extension Shape.Component: Hashable {
    
    @inlinable
    public static func == (lhs: Shape.Component, rhs: Shape.Component) -> Bool {
        return lhs.start == rhs.start && lhs.isClosed == rhs.isClosed && (lhs.segments.isStorageEqual(rhs.segments) || lhs.segments == rhs.segments)
    }
    
    @inlinable
    @inline(__always)
    public func isStorageEqual(_ other: Shape.Component) -> Bool {
        return self.start == other.start && self.isClosed == other.isClosed && self.segments.isStorageEqual(other.segments)
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(isClosed)
        hasher.combine(segments)
    }
}

extension Shape {
    
    @inlinable
    public var center: Point {
        get {
            return originalBoundary.center * transform
        }
        set {
            let offset = newValue - center
            transform *= SDTransform.translate(x: offset.x, y: offset.y)
        }
    }
    
    @inlinable
    public subscript(position: Int) -> Component {
        get {
            return components[position]
        }
        set {
            self.resetCache()
            components[position] = newValue
        }
    }
    
    @inlinable
    public var startIndex: Int {
        return components.startIndex
    }
    
    @inlinable
    public var endIndex: Int {
        return components.endIndex
    }
    
    @inlinable
    public var boundary: Rect {
        return self.originalBoundary.applying(transform) ?? identity.originalBoundary
    }
    
    public var originalBoundary: Rect {
        return cache.lck.synchronized {
            if cache.originalBoundary == nil {
                cache.originalBoundary = self.components.lazy.map { $0.boundary }.reduce { $0.union($1) } ?? Rect()
            }
            return cache.originalBoundary!
        }
    }
    
    @inlinable
    public var frame: [Point] {
        let _transform = self.transform
        return originalBoundary.points.map { $0 * _transform }
    }
}

extension MutableCollection where Element == Shape.Component {
    
    @inlinable
    mutating func makeContiguousBuffer() {
        
        var segments = ArraySlice(self.flatMap { $0.segments })
        let cache = Shape.Component.CacheArray(self.map { component in component.cache.lck.synchronized { component.cache._values } })
        
        for (cache_index, index) in self.indices.enumerated() {
            var component = self[index]
            component.segments = segments.popFirst(component.count)
            component.cache = Shape.Component.Cache(index: cache_index, list: cache)
            self[index] = component
        }
    }
}

extension Shape {
    
    @inlinable
    public mutating func makeContiguousBuffer() {
        self.components.makeContiguousBuffer()
    }
}

extension Shape {
    
    @usableFromInline
    mutating func resetCache() {
        if isKnownUniquelyReferenced(&cache) {
            cache.originalBoundary = nil
            cache.originalArea = nil
            cache.identity = nil
            cache.table = [:]
        } else {
            cache = Cache()
        }
    }
}

extension Shape {
    
    @inlinable
    public mutating func rotate(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.rotate(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func skewX(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewX(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func skewY(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewY(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func scale(_ scale: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(scale) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func scale(x: Double = 1, y: Double = 1) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(x: x, y: y) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func translate(x: Double = 0, y: Double = 0) {
        self.transform *= SDTransform.translate(x: x, y: y)
    }
    
    @inlinable
    public mutating func reflectX() {
        self.transform *= SDTransform.reflectX(self.center.x)
    }
    
    @inlinable
    public mutating func reflectY() {
        self.transform *= SDTransform.reflectY(self.center.y)
    }
    
    @inlinable
    public mutating func reflectX(_ x: Double) {
        self.transform *= SDTransform.reflectX(x)
    }
    
    @inlinable
    public mutating func reflectY(_ y: Double) {
        self.transform *= SDTransform.reflectY(y)
    }
}

extension Shape {
    
    @inlinable
    public var currentPoint: Point {
        guard let last = self.components.last else { return Point() }
        return last.isClosed ? last.start : last.end
    }
}

extension Shape {
    
    @usableFromInline
    final class Cache {
        
        let lck = SDLock()
        
        var originalBoundary: Rect?
        var originalArea: Double?
        var identity: Shape?
        
        var table: [String: Any]
        
        @usableFromInline
        init() {
            self.originalBoundary = nil
            self.originalArea = nil
            self.identity = nil
            self.table = [:]
        }
        init(originalBoundary: Rect?, originalArea: Double?, table: [String: Any]) {
            self.originalBoundary = originalBoundary
            self.originalArea = originalArea
            self.identity = nil
            self.table = table
        }
    }
}

extension Shape.Cache {
    
    func load<Value>(for key: String) -> Value? {
        return lck.synchronized { table[key] as? Value }
    }
    
    func load<Value>(for key: String, body: () -> Value) -> Value {
        
        return lck.synchronized {
            
            if let object = table[key], let value = object as? Value {
                return value
            }
            let value = body()
            table[key] = value
            return value
        }
    }
    
    func store<Value>(value: Value, for key: String) {
        lck.synchronized { table[key] = value }
    }
}

extension Shape.Component {
    
    @frozen
    @usableFromInline
    struct Cache {
        
        var index: Int
        var list: CacheArray
        
        @usableFromInline
        init() {
            self.index = 0
            self.list = CacheArray([CacheArray.Element()])
        }
        
        @usableFromInline
        init(index: Int, list: CacheArray) {
            self.index = index
            self.list = list
        }
    }
    
    @usableFromInline
    mutating func resetCache() {
        if isKnownUniquelyReferenced(&cache.list) {
            cache.list.storage[cache.index] = CacheArray.Element()
        } else {
            cache = Cache()
        }
    }
}

extension Shape.Component {
    
    @usableFromInline
    final class CacheArray {
        
        let lck = SDLock()
        var storage: [Element]
        
        @usableFromInline
        init(_ storage: [Element]) {
            self.storage = storage
        }
    }
}

extension Shape.Component.CacheArray {
    
    @frozen
    @usableFromInline
    struct Element {
        
        var boundary: Rect?
        var area: Double?
        
        var table: [String: Any]?
        
        init() {
            self.boundary = nil
            self.area = nil
            self.table = nil
        }
    }
}

extension Shape.Component.Cache {
    
    @usableFromInline
    var lck: SDLock {
        return list.lck
    }
    
    @usableFromInline
    var _values: Shape.Component.CacheArray.Element {
        get {
            return list.storage[index]
        }
        nonmutating set {
            list.storage[index] = newValue
        }
    }
    
    var boundary: Rect? {
        get {
            return _values.boundary
        }
        nonmutating set {
            _values.boundary = newValue
        }
    }
    var area: Double? {
        get {
            return _values.area
        }
        nonmutating set {
            _values.area = newValue
        }
    }
    
    var table: [String: Any] {
        get {
            return _values.table ?? [:]
        }
        nonmutating set {
            _values.table = newValue
        }
    }
}

extension Shape.Component.Cache {
    
    func load<Value>(for key: String) -> Value? {
        return lck.synchronized { table[key] as? Value }
    }
    
    func load<Value>(for key: String, body: () -> Value) -> Value {
        
        return lck.synchronized {
            
            if let object = table[key], let value = object as? Value {
                return value
            }
            let value = body()
            table[key] = value
            return value
        }
    }
    
    func store<Value>(value: Value, for key: String) {
        lck.synchronized { table[key] = value }
    }
}

extension Shape.Component {
    
    public var boundary: Rect {
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

extension Shape.Component: RandomAccessCollection, MutableCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    @inlinable
    public var startIndex: Int {
        return 0
    }
    
    @inlinable
    public var endIndex: Int {
        return segments.count
    }
    
    @inlinable
    public subscript(position: Int) -> Shape.Segment {
        get {
            return segments[position + segments.startIndex]
        }
        set {
            self.resetCache()
            segments[position + segments.startIndex] = newValue
        }
    }
}

extension Shape.Segment {
    
    @inlinable
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
    
    @inlinable
    public var end: Point {
        return segments.last?.end ?? start
    }
}

extension Shape.Component {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Shape.Segment>) throws -> R) rethrows -> R {
        return try segments.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Shape.Segment>) throws -> R) rethrows -> R {
        self.resetCache()
        return try segments.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Shape.Segment>) throws -> R) rethrows -> R? {
        return try segments.withContiguousStorageIfAvailable(body)
    }
    
    @inlinable
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Shape.Segment>) throws -> R) rethrows -> R? {
        self.resetCache()
        return try segments.withContiguousMutableStorageIfAvailable(body)
    }
}

extension Shape.Component: RangeReplaceableCollection {
    
    @inlinable
    public mutating func append(_ newElement: Shape.Segment) {
        self.resetCache()
        segments.append(newElement)
    }
    
    @inlinable
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Shape.Segment {
        self.resetCache()
        segments.append(contentsOf: newElements)
    }
    
    @inlinable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        segments.reserveCapacity(minimumCapacity)
    }
    
    @inlinable
    public mutating func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Shape.Segment {
        self.resetCache()
        segments.replaceSubrange(subRange.lowerBound + segments.startIndex..<subRange.upperBound + segments.startIndex, with: newElements)
    }
}

extension Shape.Component {
    
    @inlinable
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
            reversed.cache.boundary = self.cache.boundary
            reversed.cache.area = self.cache.area.map { -$0 }
        }
        
        return reversed
    }
}

extension Shape.Component {
    
    @inlinable
    public static func Polygon(center: Point, radius: Double, edges: Int) -> Shape.Component {
        precondition(edges >= 3, "Edges is less than 3")
        let _n = 2 * .pi / Double(edges)
        var segments: [Shape.Segment] = []
        for i in 1..<edges {
            let p = Point(x: cos(_n * Double(i)), y: sin(_n * Double(i)))
            segments.append(.line(center + radius * p))
        }
        return Shape.Component(start: Point(x: center.x + radius, y: center.y), closed: true, segments: segments)
    }
    
    @inlinable
    public init(rect: Rect) {
        let points = rect.points
        self.init(start: points[0], closed: true, segments: [.line(points[1]), .line(points[2]), .line(points[3])])
    }
    
    @inlinable
    public init(roundedRect rect: Rect, radius: Radius) {
        let x_radius = Swift.min(0.5 * rect.width, abs(radius.x))
        let y_radius = Swift.min(0.5 * rect.height, abs(radius.y))
        let transform = SDTransform.scale(x: x_radius, y: y_radius) * SDTransform.translate(x: x_radius + rect.minX, y: y_radius + rect.minY)
        
        let x_padding = rect.width - 2 * x_radius
        let y_padding = rect.height - 2 * y_radius
        
        let t1 = transform * SDTransform.translate(x: x_padding, y: y_padding)
        let t2 = transform * SDTransform.translate(x: 0, y: y_padding)
        let t3 = transform * SDTransform.translate(x: 0, y: 0)
        let t4 = transform * SDTransform.translate(x: x_padding, y: 0)
        
        let segments: [Shape.Segment] = [
            .cubic(bezier_circle[1] * t1, bezier_circle[2] * t1, bezier_circle[3] * t1), .line(bezier_circle[3] * t2),
            .cubic(bezier_circle[4] * t2, bezier_circle[5] * t2, bezier_circle[6] * t2), .line(bezier_circle[6] * t3),
            .cubic(bezier_circle[7] * t3, bezier_circle[8] * t3, bezier_circle[9] * t3), .line(bezier_circle[9] * t4),
            .cubic(bezier_circle[10] * t4, bezier_circle[11] * t4, bezier_circle[12] * t4)
        ]
        self.init(start: bezier_circle[0] * t1, closed: true, segments: segments)
    }
    
    @inlinable
    public init(ellipseIn rect: Rect) {
        let transform = SDTransform.scale(x: 0.5 * rect.width, y: 0.5 * rect.height) * SDTransform.translate(x: rect.midX, y: rect.midY)
        let segments: [Shape.Segment] = [
            .cubic(bezier_circle[1] * transform, bezier_circle[2] * transform, bezier_circle[3] * transform),
            .cubic(bezier_circle[4] * transform, bezier_circle[5] * transform, bezier_circle[6] * transform),
            .cubic(bezier_circle[7] * transform, bezier_circle[8] * transform, bezier_circle[9] * transform),
            .cubic(bezier_circle[10] * transform, bezier_circle[11] * transform, bezier_circle[12] * transform)
        ]
        self.init(start: bezier_circle[0] * transform, closed: true, segments: segments)
    }
    
    @inlinable
    public init?<C: Collection>(polygon points: C) where C.Element == Point {
        guard let start = points.first else { return nil }
        self.init(start: start, closed: true, segments: points.dropFirst().map { .line($0) })
    }
    
    @inlinable
    public init?<C: Collection>(polyline points: C) where C.Element == Point {
        guard let start = points.first else { return nil }
        self.init(start: start, closed: false, segments: points.dropFirst().map { .line($0) })
    }
}

extension Shape {
    
    @inlinable
    public static func Polygon(center: Point, radius: Double, edges: Int) -> Shape {
        return [Component.Polygon(center: center, radius: radius, edges: edges)]
    }
    
    @inlinable
    public init(rect: Rect) {
        self = [Component(rect: rect)]
    }
    
    @inlinable
    public init(roundedRect rect: Rect, radius: Radius) {
        self = [Component(roundedRect: rect, radius: radius)]
    }
    
    @inlinable
    public init(ellipseIn rect: Rect) {
        self = [Component(ellipseIn: rect)]
    }
    
    @inlinable
    public init<C: Collection>(polygon points: C) where C.Element == Point {
        self = Component(polygon: points).map { [$0] } ?? []
    }
    
    @inlinable
    public init<C: Collection>(polyline points: C) where C.Element == Point {
        self = Component(polyline: points).map { [$0] } ?? []
    }
}

extension Shape {
    
    public var originalArea: Double {
        return cache.lck.synchronized {
            if cache.originalArea == nil {
                cache.originalArea = self.components.reduce(0) { $0 + $1.area }
            }
            return cache.originalArea!
        }
    }
    
    @inlinable
    public var area: Double {
        return identity.originalArea
    }
}

extension Shape {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Component>) throws -> R) rethrows -> R {
        return try components.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Component>) throws -> R) rethrows -> R {
        self.resetCache()
        return try components.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Component>) throws -> R) rethrows -> R? {
        return try components.withContiguousStorageIfAvailable(body)
    }
    
    @inlinable
    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Component>) throws -> R) rethrows -> R? {
        self.resetCache()
        return try components.withContiguousMutableStorageIfAvailable(body)
    }
}

extension Shape: RangeReplaceableCollection {
    
    @inlinable
    public mutating func append(_ newElement: Component) {
        self.resetCache()
        components.append(newElement)
    }
    
    @inlinable
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Component {
        self.resetCache()
        components.append(contentsOf: newElements)
    }
    
    @inlinable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        components.reserveCapacity(minimumCapacity)
    }
    
    @inlinable
    public mutating func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Component {
        self.resetCache()
        components.replaceSubrange(subRange, with: newElements)
    }
}

extension Shape {
    
    public var identity: Shape {
        if transform == .identity {
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

extension Shape.Component {
    
    @inlinable
    public mutating func line(to p1: Point) {
        self.append(.line(p1))
    }
    
    @inlinable
    public mutating func quad(to p2: Point, control p1: Point) {
        self.append(.quad(p1, p2))
    }
    
    @inlinable
    public mutating func curve(to p3: Point, control1 p1: Point, control2 p2: Point) {
        self.append(.cubic(p1, p2, p3))
    }
    
    @inlinable
    public mutating func arc(to p1: Point, radius: Radius, rotate: Double, largeArc: Bool, sweep: Bool) {
        
        let start = self.end
        let end = p1
        
        @inline(__always)
        func arcDetails() -> (Point, Radius) {
            let centers = EllipseCenter(radius, rotate, start, end)
            if centers.isEmpty {
                return (0.5 * (start + end), EllipseRadius(start, end, radius, rotate))
            } else if centers.count == 1 || (cross(centers[0] - start, end - start).sign == (sweep ? .plus : .minus) ? largeArc : !largeArc) {
                return (centers[0], radius)
            } else {
                return (centers[1], radius)
            }
        }
        
        let (center, radius) = arcDetails()
        let _arc_transform = SDTransform.scale(x: radius.x, y: radius.y) * SDTransform.rotate(rotate)
        let _arc_transform_inverse = _arc_transform.inverse
        let _begin = (start - center) * _arc_transform_inverse
        let _end = (end - center) * _arc_transform_inverse
        let startAngle = atan2(_begin.y, _begin.x)
        var endAngle = atan2(_end.y, _end.x)
        
        if sweep {
            while endAngle < startAngle {
                endAngle += 2 * .pi
            }
        } else {
            while endAngle > startAngle {
                endAngle -= 2 * .pi
            }
        }
        
        let _transform = SDTransform.rotate(startAngle) * _arc_transform
        let point = BezierArc(endAngle - startAngle).lazy.map { $0 * _transform + center }
        
        if point.count > 1 {
            for i in 0..<point.count / 3 {
                self.append(.cubic(point[i * 3 + 1], point[i * 3 + 2], point[i * 3 + 3]))
            }
        }
    }
}

extension Shape {
    
    @inlinable
    public mutating func move(to p1: Point) {
        self.append(Shape.Component(start: p1, closed: false, segments: []))
    }
    
    @inlinable
    public mutating func line(to p1: Point) {
        if self.isEmpty || self.last?.isClosed == true {
            self.append(Shape.Component(start: self.last?.start ?? Point(), closed: false, segments: []))
        }
        self.mutableLast.line(to: p1)
    }
    
    @inlinable
    public mutating func quad(to p2: Point, control p1: Point) {
        if self.isEmpty || self.last?.isClosed == true {
            self.append(Shape.Component(start: self.last?.start ?? Point(), closed: false, segments: []))
        }
        self.mutableLast.quad(to: p2, control: p1)
    }
    
    @inlinable
    public mutating func curve(to p3: Point, control1 p1: Point, control2 p2: Point) {
        if self.isEmpty || self.last?.isClosed == true {
            self.append(Shape.Component(start: self.last?.start ?? Point(), closed: false, segments: []))
        }
        self.mutableLast.curve(to: p3, control1: p1, control2: p2)
    }
    
    @inlinable
    public mutating func arc(to p1: Point, radius: Radius, rotate: Double, largeArc: Bool, sweep: Bool) {
        if self.isEmpty || self.last?.isClosed == true {
            self.append(Shape.Component(start: self.last?.start ?? Point(), closed: false, segments: []))
        }
        self.mutableLast.arc(to: p1, radius: radius, rotate: rotate, largeArc: largeArc, sweep: sweep)
    }
    
    @inlinable
    public mutating func close() {
        if self.isEmpty || self.last?.isClosed == true {
            self.append(Shape.Component(start: self.last?.start ?? Point(), closed: false, segments: []))
        }
        self.mutableLast.isClosed = true
    }
}

@inlinable
public func * (lhs: Shape.Segment, rhs: SDTransform) -> Shape.Segment {
    switch lhs {
    case let .line(p1): return .line(p1 * rhs)
    case let .quad(p1, p2): return .quad(p1 * rhs, p2 * rhs)
    case let .cubic(p1, p2, p3): return .cubic(p1 * rhs, p2 * rhs, p3 * rhs)
    }
}
@inlinable
public func *= (lhs: inout Shape.Segment, rhs: SDTransform) {
    lhs = lhs * rhs
}

@inlinable
public func * (lhs: Shape.Component, rhs: SDTransform) -> Shape.Component {
    return Shape.Component(start: lhs.start * rhs, closed: lhs.isClosed, segments: lhs.segments.map { $0 * rhs })
}

@inlinable
public func *= (lhs: inout Shape.Component, rhs: SDTransform) {
    lhs = lhs * rhs
}

@inlinable
public func * (lhs: Shape, rhs: SDTransform) -> Shape {
    var result = lhs
    result.transform *= rhs
    return result
}
@inlinable
public func *= (lhs: inout Shape, rhs: SDTransform) {
    lhs = lhs * rhs
}

