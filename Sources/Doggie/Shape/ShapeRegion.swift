//
//  ShapeRegion.swift
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

private let ShapeCacheNonZeroRegionKey = "ShapeCacheNonZeroRegionKey"
private let ShapeCacheEvenOddRegionKey = "ShapeCacheEvenOddRegionKey"
private let ShapeCacheConstructiveSolidResultKey = "ShapeCacheConstructiveSolidResultKey"

extension RandomAccessCollection where Index : SignedInteger {
    
    fileprivate func indexMod(_ index: Index) -> Index {
        if startIndex == endIndex {
            return endIndex
        }
        let count = self.count
        let offset = numericCast(index - startIndex) % count
        return self.index(startIndex, offsetBy: offset < 0 ? offset + count : offset)
    }
}

extension Collection where SubSequence : Collection {
    
    fileprivate func rotateZip() -> Zip2Sequence<Self, ConcatCollection<Self.SubSequence, Self.SubSequence>> {
        return zip(self, self.rotated(1))
    }
}

public struct ShapeRegion {
    
    fileprivate let solids: [Solid]
    fileprivate let spacePartition: RectCollection
    
    public let boundary: Rect
    
    fileprivate let cache: Cache
    
    /// Create an empty `ShapeRegion`.
    public init() {
        self.solids = []
        self.spacePartition = RectCollection()
        self.boundary = Rect()
        self.cache = Cache()
    }
    
    public init(solid: ShapeRegion.Solid) {
        self.init(solids: CollectionOfOne(solid))
    }
    
    fileprivate init<S : Sequence>(solids: S) where S.Iterator.Element == ShapeRegion.Solid {
        let solids = Array(solids)
        self.solids = solids
        self.spacePartition = RectCollection(solids.map { $0.boundary })
        self.boundary = solids.first.map { solids.dropFirst().reduce($0.boundary) { $0.union($1.boundary) } } ?? Rect()
        self.cache = Cache()
    }
}

extension ShapeRegion {
    
    fileprivate class Cache {
        var subtracting: [ObjectIdentifier: ShapeRegion] = [:]
        var intersection: [ObjectIdentifier: ShapeRegion] = [:]
        var union: [ObjectIdentifier: ShapeRegion] = [:]
        var symmetricDifference: [ObjectIdentifier: ShapeRegion] = [:]
    }
}

extension ShapeRegion : RandomAccessCollection {
    
    public typealias Indices = CountableRange<Int>
    
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
    
    fileprivate var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
    
    public var area: Double {
        return solids.reduce(0) { $0 + $1.area }
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> [Shape.Component] {
        return solids.flatMap { $0.components(sign) }
    }
    
    public var shape: Shape {
        let _path = Shape(components(.plus))
        _path.cacheTable[ShapeCacheNonZeroRegionKey] = self
        _path.cacheTable[ShapeCacheEvenOddRegionKey] = self
        return _path
    }
}

extension ShapeRegion {
    
    public struct Solid {
        
        public let solid: Shape.Component
        public let holes: ShapeRegion
        
        fileprivate let cache: Cache
        
        public let boundary: Rect
        public let area: Double
        
        fileprivate init(solid: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
            self.solid = solid
            self.holes = holes
            self.cache = Cache()
            self.boundary = solid.boundary
            self.area = holes.reduce(abs(solid.area)) { $0 - abs($1.area) }
        }
    }
}

extension ShapeRegion.Solid {
    
    public typealias Segment = Shape.Component.BezierCollection.Element
    
    fileprivate init?<S : Sequence>(segments: S) where S.Element == Segment {
        
        var segments = segments.filter { !$0.isPoint }
        
        guard segments.count > 0 else { return nil }
        
        if !segments[0].start.almostEqual(segments.last!.end) {
            segments.append(Segment(segments.last!.end, segments[0].start))
        }
        
        let solid = Shape.Component(start: segments[0].start, closed: true, segments: segments.map { $0.segment })
        
        guard !solid.area.almostZero() else { return nil }
        
        self.init(solid: solid)
    }
}

extension ShapeRegion.Solid {
    
    fileprivate class Cache {
        
        var subtracting: [ObjectIdentifier: [ShapeRegion.Solid]] = [:]
        var intersection: [ObjectIdentifier: [ShapeRegion.Solid]] = [:]
        var union: [ObjectIdentifier: ([ShapeRegion.Solid], Bool)] = [:]
        
        var reversed: ShapeRegion.Solid?
        
        var solid: ShapeRegion.Solid?
    }
}

extension ShapeRegion.Solid {
    
    fileprivate var _solid: ShapeRegion.Solid {
        if cache.solid == nil {
            cache.solid = ShapeRegion.Solid(solid: self.solid)
        }
        return cache.solid!
    }
    
    fileprivate var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
    
    fileprivate func reversed() -> ShapeRegion.Solid {
        if cache.reversed == nil {
            cache.reversed = ShapeRegion.Solid(solid: solid.reversed(), holes: holes)
        }
        return cache.reversed!
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> ConcatBidirectionalCollection<CollectionOfOne<Shape.Component>, [Shape.Component]> {
        return CollectionOfOne(solid.area.sign == sign ? solid : solid.reversed()).concat(holes.components(sign == .plus ? .minus : .plus))
    }
    
    public var shape: Shape {
        let _path = Shape(components(.plus))
        _path.cacheTable[ShapeCacheNonZeroRegionKey] = ShapeRegion(solid: self)
        _path.cacheTable[ShapeCacheEvenOddRegionKey] = ShapeRegion(solid: self)
        return _path
    }
}

extension Shape.Component {
    
    fileprivate func _union(_ other: Shape.Component) -> ShapeRegion? {
        
        switch process(other) {
        case let .overlap(overlap):
            switch overlap {
            case .equal, .superset: return ShapeRegion(solid: ShapeRegion.Solid(solid: self))
            case .subset: return ShapeRegion(solid: ShapeRegion.Solid(solid: other))
            case .none: return nil
            }
        case let .regions(left, right): return left.union(right)
        case let .segments(forward, backward): return ShapeRegion(solids: forward.enumerated().flatMap { arg in forward.enumerated().contains { $0.0 != arg.0 && $0.1.solid._contains(arg.1.solid) } ? nil : ShapeRegion.Solid(solid: arg.1.solid, holes: ShapeRegion(solids: backward.filter { arg.1.solid._contains($0.solid) })) })
        }
    }
    fileprivate func _intersection(_ other: Shape.Component) -> ShapeRegion {
        
        switch process(other) {
        case let .overlap(overlap):
            switch overlap {
            case .equal, .subset: return ShapeRegion(solid: ShapeRegion.Solid(solid: self))
            case .superset: return ShapeRegion(solid: ShapeRegion.Solid(solid: other))
            case .none: return ShapeRegion()
            }
        case let .regions(left, right): return left.intersection(right)
        case let .segments(forward, _): return ShapeRegion(solids: forward.enumerated().flatMap { arg in forward.enumerated().contains { $0.0 != arg.0 && $0.1.solid._contains(arg.1.solid) } ? arg.1 : nil })
        }
    }
    fileprivate func _subtracting(_ other: Shape.Component) -> (ShapeRegion?, Bool) {
        
        switch process(other) {
        case let .overlap(overlap):
            switch overlap {
            case .equal, .subset: return (ShapeRegion(), false)
            case .superset: return (nil, true)
            case .none: return (nil, false)
            }
        case let .regions(left, right): return (left.subtracting(right), false)
        case let .segments(forward, _): return (ShapeRegion(solids: forward), false)
        }
    }
}

extension ShapeRegion.Solid {
    
    fileprivate func union(_ other: ShapeRegion.Solid) -> ([ShapeRegion.Solid], Bool) {
        
        if !self.boundary.isIntersect(other.boundary) {
            return ([self, other], false)
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        if cache.union[other.cacheId] == nil && other.cache.union[cacheId] == nil {
            if let union = self.solid._union(other.solid) {
                let a = self.holes.intersection(other.holes).solids
                let b = self.holes.subtracting(other._solid)
                let c = other.holes.subtracting(self._solid)
                cache.union[other.cacheId] = (union.subtracting(ShapeRegion(solids: a.concat(b).concat(c))).solids, true)
            } else {
                cache.union[other.cacheId] = ([self, other], false)
            }
        }
        return cache.union[other.cacheId] ?? other.cache.union[cacheId]!
    }
    fileprivate func intersection(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        if cache.intersection[other.cacheId] == nil && other.cache.intersection[cacheId] == nil {
            let intersection = self.solid._intersection(other.solid)
            if intersection.count != 0 {
                cache.intersection[other.cacheId] = intersection.subtracting(self.holes).subtracting(other.holes).solids
            } else {
                cache.intersection[other.cacheId] = []
            }
        }
        return cache.intersection[other.cacheId] ?? other.cache.intersection[cacheId]!
    }
    fileprivate func subtracting(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return [self]
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other.reversed() : other
        
        if cache.subtracting[other.cacheId] == nil {
            let (_subtracting, superset) = self.solid._subtracting(other.solid)
            if superset {
                cache.subtracting[other.cacheId] = [ShapeRegion.Solid(solid: self.solid, holes: self.holes.union(ShapeRegion(solid: other)))]
            } else if let subtracting = _subtracting {
                let a = subtracting.concat(other.holes.intersection(self._solid))
                cache.subtracting[other.cacheId] = self.holes.isEmpty ? Array(a) : ShapeRegion(solids: a).subtracting(self.holes).solids
            } else {
                cache.subtracting[other.cacheId] = [self]
            }
        }
        return cache.subtracting[other.cacheId]!
    }
}

extension ShapeRegion {
    
    public func union(_ other: ShapeRegion) -> ShapeRegion {
        
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
        
        if cache.union[other.cacheId] == nil && other.cache.union[cacheId] == nil {
            var result1 = self.solids
            var result2: [ShapeRegion.Solid] = []
            var remain = other.solids
            outer: while let rhs = remain.popLast() {
                for idx in result1.indices {
                    let (union, flag) = result1[idx].union(rhs)
                    if flag {
                        result1.remove(at: idx)
                        remain.append(contentsOf: union)
                        continue outer
                    }
                }
                result2.append(rhs)
            }
            cache.union[other.cacheId] = ShapeRegion(solids: result1.concat(result2))
        }
        return cache.union[other.cacheId] ?? other.cache.union[cacheId]!
    }
    
    fileprivate func intersection(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if self.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        let overlap = self.spacePartition.search(overlap: other.boundary)
        return overlap.flatMap { solids[$0].intersection(other) }
    }
    
    public func intersection(_ other: ShapeRegion) -> ShapeRegion {
        
        if self.isEmpty || other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return ShapeRegion()
        }
        
        if cache.intersection[other.cacheId] == nil && other.cache.intersection[cacheId] == nil {
            let overlap = self.spacePartition.search(overlap: other.boundary)
            cache.intersection[other.cacheId] = ShapeRegion(solids: overlap.flatMap { other.intersection(self.solids[$0]) })
        }
        return cache.intersection[other.cacheId] ?? other.cache.intersection[cacheId]!
    }
    fileprivate func subtracting(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if self.isEmpty {
            return []
        }
        if !self.boundary.isIntersect(other.boundary) {
            return self.solids
        }
        
        let overlap = self.spacePartition.search(overlap: other.boundary)
        var result: [ShapeRegion.Solid] = []
        result.reserveCapacity(solids.count)
        for (index, solid) in solids.enumerated() {
            if overlap.contains(index) {
                result.append(contentsOf: solid.subtracting(other))
            } else {
                result.append(solid)
            }
        }
        return result
    }
    public func subtracting(_ other: ShapeRegion) -> ShapeRegion {
        
        if self.isEmpty {
            return ShapeRegion()
        }
        if other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return self
        }
        
        if cache.subtracting[other.cacheId] == nil {
            let overlap = self.spacePartition.search(overlap: other.boundary)
            var result: [Solid] = []
            result.reserveCapacity(solids.count)
            for (index, item) in self.solids.enumerated() {
                if overlap.contains(index) {
                    let overlap2 = other.spacePartition.search(overlap: item.boundary)
                    result.append(contentsOf: overlap2.reduce([item]) { remains, idx in remains.flatMap { $0.subtracting(other.solids[idx]) } })
                } else {
                    result.append(item)
                }
            }
            cache.subtracting[other.cacheId] = ShapeRegion(solids: result)
        }
        return cache.subtracting[other.cacheId]!
    }
    public func symmetricDifference(_ other: ShapeRegion) -> ShapeRegion {
        
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
        
        if cache.symmetricDifference[other.cacheId] == nil && other.cache.symmetricDifference[cacheId] == nil {
            let a = self.subtracting(other).solids
            let b = other.subtracting(self).solids
            cache.symmetricDifference[other.cacheId] = ShapeRegion(solids: a.concat(b))
        }
        return cache.symmetricDifference[other.cacheId] ?? other.cache.symmetricDifference[cacheId]!
    }
}

extension ShapeRegion {
    
    public mutating func formUnion(_ other: ShapeRegion) {
        self = self.union(other)
    }
    public mutating func formIntersection(_ other: ShapeRegion) {
        self = self.intersection(other)
    }
    public mutating func subtract(_ other: ShapeRegion) {
        self = self.subtracting(other)
    }
    public mutating func formSymmetricDifference(_ other: ShapeRegion) {
        self = self.symmetricDifference(other)
    }
}

extension ShapeRegion {
    
    public static func Polygon(center: Point, radius: Double, edges: Int) -> ShapeRegion {
        precondition(edges >= 3, "Edges is less than 3")
        let _n = 2 * Double.pi / Double(edges)
        let points = (0..<edges).map { Point(x: center.x + radius * cos(_n * Double($0)), y: center.y + radius * sin(_n * Double($0))) }
        return ShapeRegion(solid: ShapeRegion.Solid(segments: points.rotateZip().map { ShapeRegion.Solid.Segment($0, $1) })!)
    }
}

extension ShapeRegion {
    
    public static func Rectangle(origin: Point, size: Size) -> ShapeRegion {
        return Rectangle(Rect(origin: origin, size: size))
    }
    public static func Rectangle(x: Double, y: Double, width: Double, height: Double) -> ShapeRegion {
        return Rectangle(Rect(x: x, y: y, width: width, height: height))
    }
    public static func Rectangle(_ rect: Rect) -> ShapeRegion {
        let points = rect.points
        let segments: [ShapeRegion.Solid.Segment] = [
            ShapeRegion.Solid.Segment(points[0], points[1]),
            ShapeRegion.Solid.Segment(points[1], points[2]),
            ShapeRegion.Solid.Segment(points[2], points[3]),
            ShapeRegion.Solid.Segment(points[3], points[0])
        ]
        return ShapeRegion(solid: ShapeRegion.Solid(segments: segments)!)
    }
}

extension ShapeRegion {
    
    public static func Ellipse(_ rect: Rect) -> ShapeRegion {
        return Ellipse(center: rect.center, radius: Radius(x: 0.5 * rect.width, y: 0.5 * rect.height))
    }
    public static func Ellipse(center: Point, radius: Double) -> ShapeRegion {
        return Ellipse(center: center, radius: Radius(x: radius, y: radius))
    }
    public static func Ellipse(x: Double, y: Double, radius: Double) -> ShapeRegion {
        return Ellipse(center: Point(x: x, y: y), radius: Radius(x: radius, y: radius))
    }
    public static func Ellipse(x: Double, y: Double, rx: Double, ry: Double) -> ShapeRegion {
        return Ellipse(center: Point(x: x, y: y), radius: Radius(x: rx, y: ry))
    }
    public static func Ellipse(center: Point, radius: Radius) -> ShapeRegion {
        let scale = SDTransform.scale(x: radius.x, y: radius.y)
        let point = BezierCircle.map { $0 * scale + center }
        let segments: [ShapeRegion.Solid.Segment] = [
            ShapeRegion.Solid.Segment(point[0], point[1], point[2], point[3]),
            ShapeRegion.Solid.Segment(point[3], point[4], point[5], point[6]),
            ShapeRegion.Solid.Segment(point[6], point[7], point[8], point[9]),
            ShapeRegion.Solid.Segment(point[9], point[10], point[11], point[12])
        ]
        return ShapeRegion(solid: ShapeRegion.Solid(segments: segments)!)
    }
}

extension ShapeRegion {
    
    public init(_ path: Shape, winding: Shape.WindingRule) {
        self.init()
        let cacheKey: String
        switch winding {
        case .nonZero: cacheKey = ShapeCacheNonZeroRegionKey
        case .evenOdd: cacheKey = ShapeCacheEvenOddRegionKey
        }
        if let region = path.identity.cacheTable[cacheKey] as? ShapeRegion {
            self = region
        } else {
            if let region = path.cacheTable[cacheKey] as? ShapeRegion {
                self = region
            } else {
                switch winding {
                case .nonZero: self.addLoopWithNonZeroWinding(loops: path.breakLoop())
                case .evenOdd: self.addLoopWithEvenOddWinding(loops: path.breakLoop())
                }
                path.cacheTable[cacheKey] = self
            }
            self *= path.transform
            path.identity.cacheTable[cacheKey] = self
        }
    }
    
    fileprivate mutating func addLoopWithNonZeroWinding(loops: [ShapeRegion.Solid]) {
        
        var positive: [ShapeRegion] = []
        var negative: [ShapeRegion] = []
        
        for loop in loops {
            var remain = ShapeRegion(solid: loop)
            if loop.solid.area.sign == .minus {
                for index in negative.indices {
                    (negative[index], remain) = (negative[index].union(remain), negative[index].intersection(remain))
                    if remain.isEmpty {
                        break
                    }
                }
                if !remain.isEmpty {
                    negative.append(remain)
                }
            } else {
                for index in positive.indices {
                    (positive[index], remain) = (positive[index].union(remain), positive[index].intersection(remain))
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
                (positive[p_index], negative[n_index]) = (positive[p_index].subtracting(negative[n_index]), negative[n_index].subtracting(positive[p_index]))
                if positive[p_index].isEmpty {
                    positive.removeLast()
                }
                if negative[n_index].isEmpty {
                    break
                }
            }
        }
        self = ShapeRegion(solids: OptionOneCollection(positive.first?.solids).concat(OptionOneCollection(negative.first?.solids)).joined())
    }
    
    fileprivate mutating func addLoopWithEvenOddWinding(loops: [ShapeRegion.Solid]) {
        
        self = loops.reduce(ShapeRegion()) { $0.symmetricDifference(ShapeRegion(solid: $1)) }
    }
}

public func * (lhs: ShapeRegion, rhs: SDTransform) -> ShapeRegion {
    return rhs.determinant.almostZero() ? ShapeRegion() : ShapeRegion(solids: lhs.solids.map { ShapeRegion.Solid(solid: $0.solid * rhs, holes: $0.holes * rhs) })
}
public func *= (lhs: inout ShapeRegion, rhs: SDTransform) {
    lhs = lhs * rhs
}

extension Shape.Component {
    
    fileprivate func breakLoop() -> [ShapeRegion.Solid] {
        
        var intersects: [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)] = []
        for (index1, segment1) in bezier.enumerated() {
            for (index2, segment2) in bezier.suffix(from: index1 + 1).indexed() {
                if !segment2.boundary.inset(dx: -1e-6, dy: -1e-6).isIntersect(segment1.boundary.inset(dx: -1e-6, dy: -1e-6)) {
                    continue
                }
                if let _intersects = segment1.intersect(segment2) {
                    for _intersect in _intersects {
                        let _l_idx = _intersect.0 == 1 ? self.indexMod(index1 + 1) : index1
                        let _r_idx = _intersect.1 == 1 ? self.indexMod(index2 + 1) : index2
                        let _t1 = _intersect.0 == 1 ? 0 : _intersect.0
                        let _t2 = _intersect.1 == 1 ? 0 : _intersect.1
                        if _l_idx == _r_idx && _t1 == 0 && _t2 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(_t1) && $0.1.index == _r_idx && $0.1.split.almostEqual(_t2) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(_t1) && $0.0.index == _r_idx && $0.0.split.almostEqual(_t2) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: _t1), ConstructiveSolidResult.Split(index: _r_idx, split: _t2)))
                    }
                } else {
                    if let a = segment2.fromPoint(segment1.end) {
                        let _l_idx = self.indexMod(index1 + 1)
                        let _r_idx = a == 1 ? self.indexMod(index2 + 1) : index2
                        let _t2 = a == 1 ? 0 : a
                        if _l_idx == _r_idx && _t2 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(0) && $0.1.index == _r_idx && $0.1.split.almostEqual(_t2) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(0) && $0.0.index == _r_idx && $0.0.split.almostEqual(_t2) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: 0), ConstructiveSolidResult.Split(index: _r_idx, split: _t2)))
                    }
                    if let b = segment1.fromPoint(segment2.start) {
                        let _l_idx = b == 1 ? self.indexMod(index1 + 1) : index1
                        let _r_idx = index2
                        let _t1 = b == 1 ? 0 : b
                        if _l_idx == _r_idx && _t1 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(_t1) && $0.1.index == _r_idx && $0.1.split.almostEqual(0) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(_t1) && $0.0.index == _r_idx && $0.0.split.almostEqual(0) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: _t1), ConstructiveSolidResult.Split(index: _r_idx, split: 0)))
                    }
                }
            }
        }
        return breakLoop(intersects.filter { !$0.0.almostEqual($0.1) })
    }
    
    fileprivate func breakLoop(_ points: [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]) -> [ShapeRegion.Solid] {
        
        if points.count == 0 {
            return Array(OptionOneCollection(ShapeRegion.Solid(segments: self.bezier)))
        }
        
        var result: [ShapeRegion.Solid] = []
        
        var graph = Graph<Int, [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]>()
        
        let _points = points.enumerated().flatMap { [($0.0, $0.1.0), ($0.0, $0.1.1)] }.sorted { $0.1 < $1.1 }
        
        for (left, right) in _points.rotateZip() {
            if left.0 == right.0 {
                result.append(contentsOf: OptionOneCollection(ShapeRegion.Solid(segments: self.splitPath(left.1, right.1))))
            } else {
                if var splits = graph[from: left.0, to: right.0] {
                    splits.append((left.1, right.1))
                    graph[from: left.0, to: right.0] = splits
                } else {
                    graph[from: left.0, to: right.0] = [(left.1, right.1)]
                }
            }
        }
        while let graph_first = graph.first {
            var path: [Int] = [graph_first.from, graph_first.to]
            while let last = path.last, let node = graph.nodes(from: last).first?.0 {
                if let i = path.index(where: { $0 == node }) {
                    let loop = path.suffix(from: i)
                    var segments: [ShapeRegion.Solid.Segment] = []
                    for (left, right) in loop.rotateZip() {
                        if let split = graph[from: left, to: right]?.last {
                            segments.append(contentsOf: self.splitPath(split.0, split.1))
                            if var splits = graph[from: left, to: right], splits.count != 1 {
                                splits.removeLast()
                                graph[from: left, to: right] = splits
                            } else {
                                graph[from: left, to: right] = nil
                            }
                        }
                    }
                    result.append(contentsOf: OptionOneCollection(ShapeRegion.Solid(segments: segments)))
                    if i == 0 {
                        break
                    }
                    path.removeSubrange(path.index(after: i)..<path.endIndex)
                } else {
                    path.append(node)
                }
            }
        }
        return result
    }
}

extension Shape {
    
    fileprivate func breakLoop() -> [ShapeRegion.Solid] {
        
        var solids: [ShapeRegion.Solid] = []
        
        for item in self {
            var path: [ShapeRegion.Solid.Segment] = []
            for segment in item.bezier {
                
                switch segment.segment {
                case let .cubic(p1, p2, p3):
                    
                    if segment.start.almostEqual(p3) {
                        solids.append(ShapeRegion.Solid(segments: CollectionOfOne(segment))!)
                    } else {
                        
                        var segment = segment
                        if let (_a, _b) = CubicBezierSelfIntersect(segment.start, p1, p2, p3) {
                            
                            let a = Swift.min(_a, _b)
                            let b = Swift.max(_a, _b)
                            
                            let check_1 = a.almostZero()
                            let check_2 = !check_1 && a > 0
                            let check_3 = (b - 1).almostZero()
                            let check_4 = !check_3 && b < 1
                            
                            if check_1 && check_4 {
                                
                                let split = segment.split(b)
                                solids.append(ShapeRegion.Solid(segments: CollectionOfOne(split.0))!)
                                segment = split.1
                                
                            } else if check_2 && check_3 {
                                
                                let split = segment.split(a)
                                solids.append(ShapeRegion.Solid(segments: CollectionOfOne(split.1))!)
                                segment = split.0
                                
                            } else if check_2 && check_4 {
                                
                                let split = segment.split([a, b])
                                solids.append(ShapeRegion.Solid(segments: CollectionOfOne(split[1]))!)
                                path.append(split[0])
                                segment = split[2]
                            }
                        }
                        path.append(segment)
                    }
                    
                default: path.append(segment)
                }
            }
            if path.count != 0 {
                solids.append(contentsOf: OptionOneCollection(ShapeRegion.Solid(segments: path)))
            }
        }
        
        return solids.flatMap { $0.solid.breakLoop() }
    }
}

private enum ConstructiveSolidResult {
    
    case overlap(Overlap)
    case regions(ShapeRegion, ShapeRegion)
    case segments([ShapeRegion.Solid], [ShapeRegion.Solid])
}

extension ConstructiveSolidResult {
    
    fileprivate enum Overlap {
        case none, equal, superset, subset
    }
}

extension ConstructiveSolidResult {
    
    fileprivate struct Split {
        let index: Int
        let split: Double
    }
    
    fileprivate struct Table {
        
        var l_graph: [Int: (Int, Split, Split)] = [:]
        var r_graph: [Int: (Int, Split, Split)] = [:]
        var overlap: Overlap = .none
        var looping_left: [(Split, Split)] = []
        var looping_right: [(Split, Split)] = []
    }
}

extension ConstructiveSolidResult.Table {
    
    fileprivate init(_ left: Shape.Component, _ right: Shape.Component) {
        
        struct SplitData {
            fileprivate let left: ConstructiveSolidResult.Split
            fileprivate let right: ConstructiveSolidResult.Split
            let point: Point
        }
        
        let left_spaces = left.spaces
        let right_spaces = right.spaces
        
        var data: [SplitData] = []
        var overlap_r_index: Set<Int> = []
        var overlap_l_index: Set<Int> = []
        var overlap_l: [ConstructiveSolidResult.Split] = []
        for r_idx in right_spaces.search(overlap: left.boundary.inset(dx: -1e-8, dy: -1e-8)) {
            let r_segment = right.bezier[r_idx]
            for l_idx in left_spaces.search(overlap: r_segment.boundary.inset(dx: -1e-8, dy: -1e-8)) {
                let l_segment = left.bezier[l_idx]
                if let intersect = l_segment.intersect(r_segment) {
                    for (t1, t2) in intersect {
                        let _t1 = t1 == 1 ? 0 : t1
                        let _t2 = t2 == 1 ? 0 : t2
                        let _l_idx = t1 == 1 ? left.indexMod(l_idx + 1) : l_idx
                        let _r_idx = t2 == 1 ? right.indexMod(r_idx + 1) : r_idx
                        if data.contains(where: { $0.left.index == _l_idx && $0.left.split.almostEqual(_t1) && $0.right.index == _r_idx && $0.right.split.almostEqual(_t2) }) {
                            continue
                        }
                        data.append(SplitData(left: ConstructiveSolidResult.Split(index: _l_idx, split: _t1), right: ConstructiveSolidResult.Split(index: _r_idx, split: _t2), point: l_segment.point(t1)))
                    }
                } else {
                    overlap_l_index.insert(l_idx)
                    overlap_r_index.insert(r_idx)
                    overlap_l.append(ConstructiveSolidResult.Split(index: l_idx, split: [r_segment.start, r_segment.end].flatMap { l_segment.fromPoint($0) }.min() ?? 0))
                }
            }
        }
        if !overlap_l_index.isStrictSubset(of: 0..<left.count) && !overlap_r_index.isStrictSubset(of: 0..<right.count) {
            overlap = .equal
            return
        }
        
        for (index, item) in data.enumerated() {
            looping_left.append(contentsOf: data.suffix(from: index + 1).filter { item.right.almostEqual($0.right) }.map { (item.left, $0.left) })
            looping_right.append(contentsOf: data.suffix(from: index + 1).filter { item.left.almostEqual($0.left) }.map { (item.right, $0.right) })
        }
        if looping_left.count != 0 || looping_right.count != 0 {
            return
        }
        if data.count < 2 {
            if left._contains(right, hint: Set(0..<right.count).subtracting(overlap_r_index)) {
                overlap = .superset
            } else if right._contains(left, hint: Set(0..<left.count).subtracting(overlap_l_index)) {
                overlap = .subset
            }
            return
        }
        
        let _l_list = data.enumerated().sorted { $0.1.left < $1.1.left }
        
        var _winding: [((Int, SplitData), (Int, SplitData), Bool?)] = []
        _winding.reserveCapacity(data.count)
        
        for (s0, s1) in _l_list.rotateZip() {
            if overlap_l.contains(where: { $0.almostEqual(s0.1.left) }) {
                _winding.append((s0, s1, nil))
            } else {
                _winding.append((s0, s1, right.winding(left.mid_point(s0.1.left, s1.1.left)) != 0))
            }
        }
        
        guard let check = _winding.lazy.flatMap({ $0.2 }).first, _winding.contains(where: { $2 == nil ? $1.1.right < $0.1.right : $2 != check }) else {
            
            if left._contains(right, hint: Set(0..<right.count).subtracting(overlap_r_index)) {
                overlap = .superset
            } else if right._contains(left, hint: Set(0..<left.count).subtracting(overlap_l_index)) {
                overlap = .subset
            }
            return
        }
        
        for (i, t0) in _winding.enumerated() {
            if t0.2 == nil && t0.0.1.right < t0.1.1.right {
                _winding[i].2 = _winding.rotated(i).lazy.flatMap({ $0.2 }).first
            }
        }
        
        var begin: Int?
        var last: Int?
        var record: Bool?
        for (i0, i1, winding) in _winding.rotated(_winding.index { $0.2 != _winding[0].2 } ?? 0) {
            if begin == nil {
                begin = i0.0
                last = i0.0
                record = winding
                continue
            }
            if record != winding {
                l_graph[last!] = (i0.0, data[last!].left, i0.1.left)
                last = i0.0
                record = winding
            }
            if i1.0 == begin {
                l_graph[last!] = (i1.0, data[last!].left, i1.1.left)
            }
        }
        
        let _r_list = data.enumerated().sorted { $0.1.right < $1.1.right }
        for (s0, s1) in _r_list.filter({ l_graph.keys.contains($0.0) }).rotateZip() {
            r_graph[s0.0] = (s1.0, s0.1.right, s1.1.right)
        }
    }
}

extension ConstructiveSolidResult.Split : Comparable {
    
    fileprivate func almostEqual(_ other: ConstructiveSolidResult.Split) -> Bool {
        return self.index == other.index && self.split.almostEqual(other.split)
    }
    
    fileprivate static func ==(lhs: ConstructiveSolidResult.Split, rhs: ConstructiveSolidResult.Split) -> Bool {
        return (lhs.index, lhs.split) == (rhs.index, rhs.split)
    }
    
    fileprivate static func <(lhs: ConstructiveSolidResult.Split, rhs: ConstructiveSolidResult.Split) -> Bool {
        return (lhs.index, lhs.split) < (rhs.index, rhs.split)
    }
}

extension Shape.Component {
    
    fileprivate func mid_point(_ start: ConstructiveSolidResult.Split, _ end: ConstructiveSolidResult.Split) -> Point {
        
        if start.index == end.index {
            if start.split < end.split {
                return self.bezier[start.index].point(0.5 * (start.split + end.split))
            } else {
                return self.bezier[end.index].end
            }
        }
        return self.bezier[start.index].end
    }
    
    fileprivate func splitPath(_ start: ConstructiveSolidResult.Split, _ end: ConstructiveSolidResult.Split) -> [ShapeRegion.Solid.Segment] {
        
        if start.index == end.index && start.split.almostEqual(end.split) {
            return []
        }
        if start.index == end.index {
            let splits = self.bezier[start.index].split([start.split, end.split])
            if start.split < end.split {
                return [splits[1]]
            } else {
                let a = OptionOneCollection(start.split == 1 ? nil : splits[2])
                let b = self.bezier.suffix(from: start.index)
                let c = self.bezier.prefix(upTo: start.index)
                let d = OptionOneCollection(end.split == 0 ? nil : splits[0])
                return Array(a.concat(b.concat(c).dropFirst()).concat(d))
            }
        } else if start.index < end.index {
            let a = CollectionOfOne(self.bezier[start.index].split(start.split).1)
            let b = self.bezier[start.index..<end.index]
            let c = OptionOneCollection(self.bezier[end.index].split(end.split).0)
            return Array(a.concat(b.dropFirst()).concat(c))
        } else {
            let a = CollectionOfOne(self.bezier[start.index].split(start.split).1)
            let b = self.bezier.suffix(from: start.index)
            let c = self.bezier.prefix(upTo: end.index)
            let d = OptionOneCollection(self.bezier[end.index].split(end.split).0)
            return Array(a.concat(b.concat(c).dropFirst()).concat(d))
        }
    }
}

extension Shape.Component {
    
    fileprivate func _contains(_ other: Shape.Component, hint: Set<Int> = []) -> Bool {
        
        if !self.boundary.contains(other.boundary) {
            return false
        }
        if abs(self.area) < abs(other.area) {
            return false
        }
        
        for index in hint {
            return self.winding(other.bezier[index].point(0.5)) != 0
        }
        
        let self_spaces = self.spaces
        let other_spaces = other.spaces
        
        for index in 0..<other.count {
            let overlap = self_spaces.search(overlap: other_spaces[index])
            if overlap.all(where: { !self.bezier[$0].overlap(other.bezier[index]) }) {
                return self.winding(other.bezier[index].point(0.5)) != 0
            }
        }
        
        return false
    }
}

extension Shape.Component {
    
    private var constructiveSolidResultCache: [ObjectIdentifier: ConstructiveSolidResult] {
        get {
            return cacheTable[ShapeCacheConstructiveSolidResultKey] as? [ObjectIdentifier: ConstructiveSolidResult] ?? [:]
        }
        nonmutating set {
            cacheTable[ShapeCacheConstructiveSolidResultKey] = newValue
        }
    }
    
    private func create_solids(_ other: Shape.Component, _ l_graph: [Int: (Int, ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)], _ r_graph: [Int: (Int, ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]) -> [ShapeRegion.Solid] {
        
        var result: [ShapeRegion.Solid] = []
        
        var l_graph = l_graph
        var r_graph = r_graph
        
        while let (first_from, (first_to, first_s0, first_s1)) = l_graph.first {
            
            var segments: [ShapeRegion.Solid.Segment] = self.splitPath(first_s0, first_s1)
            var last_idx = first_to
            var flag = true
            
            l_graph[first_from] = nil
            
            while last_idx != first_from {
                if flag {
                    let (next, s0, s1) = r_graph[last_idx]!
                    segments.append(contentsOf: other.splitPath(s0, s1))
                    r_graph[last_idx] = nil
                    last_idx = next
                } else {
                    let (next, s0, s1) = l_graph[last_idx]!
                    segments.append(contentsOf: self.splitPath(s0, s1))
                    l_graph[last_idx] = nil
                    last_idx = next
                }
                flag = !flag
            }
            
            result.append(contentsOf: OptionOneCollection(ShapeRegion.Solid(segments: segments)))
        }
        
        return result
    }
    
    fileprivate func process(_ other: Shape.Component) -> ConstructiveSolidResult {
        
        if constructiveSolidResultCache[other.cacheId] == nil {
            if let result = other.constructiveSolidResultCache[self.cacheId] {
                switch result {
                case let .overlap(overlap):
                    switch overlap {
                    case .none: return .overlap(.none)
                    case .equal: return .overlap(.equal)
                    case .superset: return .overlap(.subset)
                    case .subset: return .overlap(.superset)
                    }
                case let .regions(lhs, rhs): return .regions(rhs, lhs)
                case let .segments(forward, backward): return self.area.sign == other.area.sign ? .segments(forward, backward) : .segments(backward, forward)
                }
            } else {
                let intersectTable = ConstructiveSolidResult.Table(self, other)
                if intersectTable.looping_left.count != 0 || intersectTable.looping_right.count != 0 {
                    constructiveSolidResultCache[other.cacheId] = .regions(ShapeRegion(solids: self.breakLoop(intersectTable.looping_left)), ShapeRegion(solids: other.breakLoop(intersectTable.looping_right)))
                } else {
                    
                    if intersectTable.l_graph.count == 0 {
                        constructiveSolidResultCache[other.cacheId] = .overlap(intersectTable.overlap)
                    } else {
                        let segments = create_solids(other, intersectTable.l_graph, intersectTable.r_graph)
                        let forward = segments.filter { self.area.sign == $0.solid.area.sign }
                        let backward = segments.filter { self.area.sign != $0.solid.area.sign }
                        constructiveSolidResultCache[other.cacheId] = .segments(forward, backward)
                    }
                }
            }
        }
        return constructiveSolidResultCache[other.cacheId]!
    }
}

