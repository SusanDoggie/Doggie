//
//  ShapeRegion.swift
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

private let ShapeCacheNonZeroRegionKey = "ShapeCacheNonZeroRegionKey"
private let ShapeCacheEvenOddRegionKey = "ShapeCacheEvenOddRegionKey"

extension Collection where SubSequence : Collection {
    
    func rotateZip() -> Zip2Sequence<Self, LazyConcatCollection<Self.SubSequence, Self.SubSequence>> {
        return zip(self, self.rotated(1))
    }
}

@frozen
public struct ShapeRegion {
    
    fileprivate let solids: [Solid]
    
    public let boundary: Rect
    
    /// Create an empty `ShapeRegion`.
    public init() {
        self.solids = []
        self.boundary = Rect()
    }
    
    public init(solid: ShapeRegion.Solid) {
        self.solids = [solid]
        self.boundary = solid.boundary
    }
    
    init<S : Sequence>(solids: S) where S.Element == ShapeRegion.Solid {
        let solids = Array(solids)
        self.solids = solids
        self.boundary = solids.first.map { solids.dropFirst().reduce($0.boundary) { $0.union($1.boundary) } } ?? Rect()
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

extension ShapeRegion : RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public var startIndex : Int {
        return solids.startIndex
    }
    public var endIndex : Int {
        return solids.endIndex
    }
    
    public subscript(position: Int) -> Solid {
        return solids[position]
    }
}

extension ShapeRegion {
    
    public var area: Double {
        return solids.reduce(0) { $0 + $1.area }
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> [Shape.Component] {
        return solids.flatMap { $0.components(sign) }
    }
    
    public var shape: Shape {
        let _path = Shape(components(.plus))
        _path.cache.store(value: self, for: ShapeCacheNonZeroRegionKey)
        _path.cache.store(value: self, for: ShapeCacheEvenOddRegionKey)
        return _path
    }
}

extension ShapeRegion.Solid {
    
    public typealias Segment = Shape.BezierSegment
    
    init?<S : Sequence>(segments: S, reference: Double) where S.Element == Segment {
        
        let segments = segments.filter { !$0._invisible(reference: reference) }
        guard segments.count > 0 else { return nil }
        
        let solid = Shape.Component(start: segments[0].start, closed: true, segments: segments.map { $0.segment })
        guard !sqrt(abs(solid.area)).almostZero(reference: reference) else { return nil }
        
        self.init(solid: solid)
    }
}

extension ShapeRegion.Solid {
    
    public var solidRegion: ShapeRegion {
        return ShapeRegion(solid: ShapeRegion.Solid(solid: solid))
    }
}

extension ShapeRegion.Solid {
    
    fileprivate var _solid: ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: self.solid)
    }
    
    func reversed() -> ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: solid.reversed(), holes: holes)
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> LazyConcatCollection<CollectionOfOne<Shape.Component>, [Shape.Component]> {
        return CollectionOfOne(solid.area.sign == sign ? solid : solid.reversed()).concat(holes.components(sign == .plus ? .minus : .plus))
    }
    
    public var shape: Shape {
        let _path = Shape(components(.plus))
        _path.cache.store(value: ShapeRegion(solid: self), for: ShapeCacheNonZeroRegionKey)
        _path.cache.store(value: ShapeRegion(solid: self), for: ShapeCacheEvenOddRegionKey)
        return _path
    }
}

extension Shape.Component {
    
    func _union(_ other: Shape.Component, reference: Double) -> ShapeRegion? {
        
        switch process(other, reference: reference) {
        case .equal, .superset: return ShapeRegion(solid: ShapeRegion.Solid(solid: self))
        case .subset: return ShapeRegion(solid: ShapeRegion.Solid(solid: other))
        case .none: return nil
        case let .regions(left, right): return left.union(right, reference: reference)
        case let .loops(outer, _):
            let _solid = outer.lazy.filter { $0.solid.area.sign == self.area.sign }.max { abs($0.area) }
            guard let solid = _solid?.solid else { return ShapeRegion() }
            let holes = ShapeRegion(solids: outer.filter { $0.solid.area.sign != self.area.sign })
            return ShapeRegion(solids: [ShapeRegion.Solid(solid: solid, holes: holes)])
        }
    }
    func _intersection(_ other: Shape.Component, reference: Double) -> ShapeRegion {
        
        switch process(other, reference: reference) {
        case .equal, .subset: return ShapeRegion(solid: ShapeRegion.Solid(solid: self))
        case .superset: return ShapeRegion(solid: ShapeRegion.Solid(solid: other))
        case .none: return ShapeRegion()
        case let .regions(left, right): return left.intersection(right, reference: reference)
        case let .loops(_, inner): return ShapeRegion(solids: inner)
        }
    }
    func _subtracting(_ other: Shape.Component, reference: Double) -> (ShapeRegion?, Bool) {
        
        switch process(other, reference: reference) {
        case .equal, .subset: return (ShapeRegion(), false)
        case .superset: return (nil, true)
        case .none: return (nil, false)
        case let .regions(left, right): return (left.subtracting(right, reference: reference), false)
        case let .loops(outer, _): return (ShapeRegion(solids: outer), false)
        }
    }
}

extension ShapeRegion.Solid {
    
    fileprivate func union(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid]? {
        
        if !self.boundary.isIntersect(other.boundary) {
            return nil
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        guard let union = self.solid._union(other.solid, reference: reference) else { return nil }
        
        let a = self.holes.intersection(other.holes, reference: reference).solids
        let b = self.holes.subtracting(other._solid, reference: reference)
        let c = other.holes.subtracting(self._solid, reference: reference)
        
        return union.subtracting(ShapeRegion(solids: a.concat(b).concat(c)), reference: reference).solids
    }
    fileprivate func intersection(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        let intersection = self.solid._intersection(other.solid, reference: reference)
        if intersection.count != 0 {
            return intersection.subtracting(self.holes, reference: reference).subtracting(other.holes, reference: reference).solids
        } else {
            return []
        }
    }
    fileprivate func subtracting(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return [self]
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other.reversed() : other
        
        let (_subtracting, superset) = self.solid._subtracting(other.solid, reference: reference)
        if superset {
            return [ShapeRegion.Solid(solid: self.solid, holes: self.holes.union(ShapeRegion(solid: other), reference: reference))]
        } else if let subtracting = _subtracting {
            let a = subtracting.concat(other.holes.intersection(self._solid, reference: reference))
            return self.holes.isEmpty ? Array(a) : ShapeRegion(solids: a).subtracting(self.holes, reference: reference).solids
        } else {
            return [self]
        }
    }
}

extension ShapeRegion {
    
    func union(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty && other.isEmpty {
            return ShapeRegion()
        }
        if self.isEmpty && !other.isEmpty {
            return other
        }
        if !self.isEmpty && other.isEmpty {
            return self
        }
        if !self.boundary.isIntersect(other.boundary) {
            return ShapeRegion(solids: self.solids.concat(other.solids))
        }
        
        var result1 = self.solids
        var result2: [ShapeRegion.Solid] = []
        var remain = other.solids
        outer: while let rhs = remain.popLast() {
            for idx in result1.indices {
                if let union = result1[idx].union(rhs, reference: reference) {
                    result1.remove(at: idx)
                    remain.append(contentsOf: union)
                    continue outer
                }
            }
            result2.append(rhs)
        }
        return ShapeRegion(solids: result1.concat(result2))
    }
    
    fileprivate func intersection(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if self.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        return self.solids.flatMap { $0.intersection(other, reference: reference) }
    }
    
    fileprivate func intersection(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty || other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return ShapeRegion()
        }
        
        return ShapeRegion(solids: other.solids.flatMap { self.intersection($0, reference: reference) })
    }
    fileprivate func subtracting(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if self.isEmpty {
            return []
        }
        if !self.boundary.isIntersect(other.boundary) {
            return self.solids
        }
        
        return self.solids.flatMap { $0.subtracting(other, reference: reference) }
    }
    fileprivate func subtracting(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty {
            return ShapeRegion()
        }
        if other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return self
        }
        
        return other.solids.reduce(self) { ShapeRegion(solids: $0.subtracting($1, reference: reference)) }
    }
    fileprivate func symmetricDifference(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty && other.isEmpty {
            return ShapeRegion()
        }
        if self.isEmpty && !other.isEmpty {
            return other
        }
        if !self.isEmpty && other.isEmpty {
            return self
        }
        if !self.boundary.isIntersect(other.boundary) {
            return ShapeRegion(solids: self.solids.concat(other.solids))
        }
        
        let a = self.subtracting(other, reference: reference).solids
        let b = other.subtracting(self, reference: reference).solids
        return ShapeRegion(solids: a.concat(b))
    }
}

extension ShapeRegion {
    
    public func union(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.x, y: -bound.y)
        return (self * transform).union(other * transform, reference: reference) * transform.inverse
    }
    public func intersection(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.x, y: -bound.y)
        return (self * transform).intersection(other * transform, reference: reference) * transform.inverse
    }
    public func subtracting(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.x, y: -bound.y)
        return (self * transform).subtracting(other * transform, reference: reference) * transform.inverse
    }
    public func symmetricDifference(_ other: ShapeRegion) -> ShapeRegion {
        let bound = self.boundary.union(other.boundary)
        let reference = bound.width * bound.height
        let transform = SDTransform.translate(x: -bound.x, y: -bound.y)
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
    
    public static func Polygon(center: Point, radius: Double, edges: Int) -> ShapeRegion {
        return radius.almostZero() ? ShapeRegion() : ShapeRegion(solid: ShapeRegion.Solid(solid: Shape.Component.Polygon(center: center, radius: radius, edges: edges)))
    }
    
    public init(rect: Rect) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(rect: rect)))
        }
    }
    
    public init(roundedRect rect: Rect, radius: Radius) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(roundedRect: rect, radius: radius)))
        }
    }
    
    public init(ellipseIn rect: Rect) {
        if rect.width.almostZero() || rect.height.almostZero() {
            self.init()
        } else {
            self.init(solid: ShapeRegion.Solid(solid: Shape.Component(ellipseIn: rect)))
        }
    }
}

extension ShapeRegion {
    
    public init(_ path: Shape, winding: Shape.WindingRule) {
        
        let cacheKey: String
        
        switch winding {
        case .nonZero: cacheKey = ShapeCacheNonZeroRegionKey
        case .evenOdd: cacheKey = ShapeCacheEvenOddRegionKey
        }
        
        if let region: ShapeRegion = path.identity.cache.load(for: cacheKey) {
            
            self = region
            
        } else if var region: ShapeRegion = path.cache.load(for: cacheKey) {
            
            region *= path.transform
            self = region
            
            path.identity.cache.store(value: region, for: cacheKey)
            
        } else {
            
            var region = ShapeRegion()
            
            var _path = path
            _path.transform = .identity
            
            let bound = _path.boundary
            let reference = bound.width * bound.height
            _path.transform = SDTransform.translate(x: -bound.x, y: -bound.y)
            
            switch winding {
            case .nonZero: region.addLoopWithNonZeroWinding(loops: _path.identity.breakLoop(), reference: reference)
            case .evenOdd: region.addLoopWithEvenOddWinding(loops: _path.identity.breakLoop(), reference: reference)
            }
            
            region *= _path.transform.inverse
            
            path.cache.store(value: region, for: cacheKey)
            
            region *= path.transform
            self = region
            
            path.identity.cache.store(value: region, for: cacheKey)
        }
    }
    
    fileprivate mutating func addLoopWithNonZeroWinding(loops: [ShapeRegion.Solid], reference: Double) {
        
        var positive: [ShapeRegion] = []
        var negative: [ShapeRegion] = []
        
        for loop in loops {
            var remain = ShapeRegion(solid: loop)
            if loop.solid.area.sign == .minus {
                for index in negative.indices {
                    (negative[index], remain) = (negative[index].union(remain, reference: reference), negative[index].intersection(remain, reference: reference))
                    if remain.isEmpty {
                        break
                    }
                }
                if !remain.isEmpty {
                    negative.append(remain)
                }
            } else {
                for index in positive.indices {
                    (positive[index], remain) = (positive[index].union(remain, reference: reference), positive[index].intersection(remain, reference: reference))
                    if remain.isEmpty {
                        break
                    }
                }
                if !remain.isEmpty {
                    positive.append(remain)
                }
            }
        }
        for n_index in negative.indices.reversed() {
            for p_index in positive.indices.reversed() {
                (positive[p_index], negative[n_index]) = (positive[p_index].subtracting(negative[n_index], reference: reference), negative[n_index].subtracting(positive[p_index], reference: reference))
                if positive[p_index].isEmpty {
                    positive.removeLast()
                }
                if negative[n_index].isEmpty {
                    break
                }
            }
        }
        var solids: [ShapeRegion.Solid] = []
        if let positive = positive.first?.solids {
            solids.append(contentsOf: positive)
        }
        if let negative = negative.first?.solids {
            solids.append(contentsOf: negative)
        }
        self = ShapeRegion(solids: solids)
    }
    
    fileprivate mutating func addLoopWithEvenOddWinding(loops: [ShapeRegion.Solid], reference: Double) {
        self = loops.reduce(ShapeRegion()) { $0.symmetricDifference(ShapeRegion(solid: $1), reference: reference) }
    }
}

public func * (lhs: ShapeRegion, rhs: SDTransform) -> ShapeRegion {
    return rhs.determinant.almostZero() ? ShapeRegion() : ShapeRegion(solids: lhs.solids.map { ShapeRegion.Solid(solid: $0.solid * rhs, holes: $0.holes * rhs) })
}
public func *= (lhs: inout ShapeRegion, rhs: SDTransform) {
    lhs = lhs * rhs
}

