//
//  ShapeRegion.swift
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

let ShapeCacheNonZeroRegionKey = "ShapeCacheNonZeroRegionKey"
let ShapeCacheEvenOddRegionKey = "ShapeCacheEvenOddRegionKey"

@frozen
public struct ShapeRegion {
    
    @usableFromInline
    let solids: [Solid]
    
    public let boundary: Rect
    
    /// Create an empty `ShapeRegion`.
    @inlinable
    public init() {
        self.solids = []
        self.boundary = Rect()
    }
    
    @inlinable
    public init(solid: ShapeRegion.Solid) {
        self.solids = [solid]
        self.boundary = solid.boundary
    }
    
    @inlinable
    init<S : Sequence>(solids: S) where S.Element == ShapeRegion.Solid {
        let solids = Array(solids)
        self.solids = solids
        self.boundary = solids.reduce(.null) { $0.union($1.boundary) }
    }
    
    @frozen
    public struct Solid {
        
        public let solid: Shape.Component
        public let holes: ShapeRegion
        
        public let boundary: Rect
        public let area: Double
        
        fileprivate init(solid: Shape.Component, holes: ShapeRegion, boundary: Rect, area: Double) {
            self.solid = solid
            self.holes = holes
            self.boundary = boundary
            self.area = area
        }
        
        @inlinable
        init(solid: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
            var solid = solid
            if !solid.start.almostEqual(solid.end) {
                solid.append(.line(solid.start))
            }
            self.solid = solid
            self.holes = holes
            self.boundary = solid.boundary
            self.area = holes.reduce(abs(solid.area)) { $0 - abs($1.area) }
        }
    }
}

extension Sequence where Element == ShapeRegion.Solid {
    
    func makeContiguousBuffer() -> [ShapeRegion.Solid] {
        let solids = Array(self)
        var _solids = solids.map { $0.solid }
        _solids.makeContiguousBuffer()
        return zip(_solids, solids).map { ShapeRegion.Solid(solid: $0, holes: $1.holes, boundary: $1.boundary, area: $1.area) }
    }
}

extension ShapeRegion: RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    @inlinable
    public var startIndex: Int {
        return solids.startIndex
    }
    @inlinable
    public var endIndex: Int {
        return solids.endIndex
    }
    
    @inlinable
    public subscript(position: Int) -> Solid {
        return solids[position]
    }
}

extension ShapeRegion {
    
    @inlinable
    public var area: Double {
        return solids.reduce(0) { $0 + $1.area }
    }
    
    @inlinable
    public func contains(_ p: Point) -> Bool {
        return solids.contains { $0.contains(p) }
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> [Shape.Component] {
        return solids.flatMap { $0.components(sign) }
    }
}

extension ShapeRegion.Solid {
    
    public typealias Segment = Shape.BezierSegment
    
    @inlinable
    init?<S : Sequence>(segments: S, reference: Double) where S.Element == Segment {
        
        let segments = segments.filter { !$0._invisible(reference: reference) }
        guard segments.count > 0 else { return nil }
        
        let solid = Shape.Component(start: segments[0].start, closed: true, segments: segments.map { $0.segment })
        guard !sqrt(abs(solid.area)).almostZero(reference: reference) else { return nil }
        
        self.init(solid: solid)
    }
}

extension ShapeRegion.Solid {
    
    @inlinable
    public var solidRegion: ShapeRegion {
        return ShapeRegion(solid: ShapeRegion.Solid(solid: solid))
    }
}

extension ShapeRegion.Solid {
    
    @inlinable
    public func contains(_ p: Point) -> Bool {
        return solid.winding(p) != 0 && !holes.contains(p)
    }
    
    @inlinable
    func reversed() -> ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: solid.reversed(), holes: holes)
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> LazyConcatCollection<CollectionOfOne<Shape.Component>, [Shape.Component]> {
        return CollectionOfOne(solid.area.sign == sign ? solid : solid.reversed()).concat(holes.components(sign == .plus ? .minus : .plus))
    }
}

extension Shape {
    
    public init(_ region: ShapeRegion) {
        self.init(region.components(.plus))
        self.cache.store(value: region, for: ShapeCacheNonZeroRegionKey)
        self.cache.store(value: region, for: ShapeCacheEvenOddRegionKey)
    }
    
    public init(_ solid: ShapeRegion.Solid) {
        self.init(solid.components(.plus))
        self.cache.store(value: ShapeRegion(solid: solid), for: ShapeCacheNonZeroRegionKey)
        self.cache.store(value: ShapeRegion(solid: solid), for: ShapeCacheEvenOddRegionKey)
    }
}

extension ShapeRegion {
    
    @inlinable
    public func union(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.minX, y: -bound.minY)
        return (self * transform).union(other * transform, reference: reference) * transform.inverse
    }
    @inlinable
    public func intersection(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.minX, y: -bound.minY)
        return (self * transform).intersection(other * transform, reference: reference) * transform.inverse
    }
    @inlinable
    public func subtracting(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.minX, y: -bound.minY)
        return (self * transform).subtracting(other * transform, reference: reference) * transform.inverse
    }
    @inlinable
    public func symmetricDifference(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.minX, y: -bound.minY)
        return (self * transform).symmetricDifference(other * transform, reference: reference) * transform.inverse
    }
    
    @inlinable
    public mutating func formUnion(_ other: ShapeRegion) {
        self = self.union(other)
    }
    
    @inlinable
    public mutating func formIntersection(_ other: ShapeRegion) {
        self = self.intersection(other)
    }
    
    @inlinable
    public mutating func subtract(_ other: ShapeRegion) {
        self = self.subtracting(other)
    }
    
    @inlinable
    public mutating func formSymmetricDifference(_ other: ShapeRegion) {
        self = self.symmetricDifference(other)
    }
}

extension ShapeRegion {
    
    @inlinable
    public func isEqual(to other: ShapeRegion) -> Bool {
        return self.symmetricDifference(other).isEmpty
    }
    
    @inlinable
    public func isSubset(of other: ShapeRegion) -> Bool {
        return self.subtracting(other).isEmpty
    }
    
    @inlinable
    public func isSuperset(of other: ShapeRegion) -> Bool {
        return other.isSubset(of: self)
    }
    
    @inlinable
    public func isDisjoint(with other: ShapeRegion) -> Bool {
        return self.intersection(other).isEmpty
    }
    
    @inlinable
    public func isStrictSubset(of other: ShapeRegion) -> Bool {
        return self.subtracting(other).isEmpty && !other.subtracting(self).isEmpty
    }
    
    @inlinable
    public func isStrictSuperset(of other: ShapeRegion) -> Bool {
        return other.isStrictSubset(of: self)
    }
}

extension ShapeRegion {
    
    @inlinable
    public static func Polygon(center: Point, radius: Double, edges: Int) -> ShapeRegion {
        return radius.almostZero() ? ShapeRegion() : ShapeRegion(solid: ShapeRegion.Solid(solid: Shape.Component.Polygon(center: center, radius: radius, edges: edges)))
    }
    
    @inlinable
    public init(rect: Rect) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(rect: rect)))
        }
    }
    
    @inlinable
    public init(roundedRect rect: Rect, radius: Radius) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(roundedRect: rect, radius: radius)))
        }
    }
    
    @inlinable
    public init(ellipseIn rect: Rect) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(ellipseIn: rect)))
        }
    }
}

@inlinable
public func * (lhs: ShapeRegion, rhs: SDTransform) -> ShapeRegion {
    return rhs.determinant.almostZero() ? ShapeRegion() : ShapeRegion(solids: lhs.solids.map { ShapeRegion.Solid(solid: $0.solid * rhs, holes: $0.holes * rhs) })
}

@inlinable
public func *= (lhs: inout ShapeRegion, rhs: SDTransform) {
    lhs = lhs * rhs
}
