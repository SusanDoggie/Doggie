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

extension RandomAccessCollection where Index : SignedInteger {
    
    func indexMod(_ index: Index) -> Index {
        if startIndex == endIndex {
            return endIndex
        }
        let count = self.count
        let offset = Int(index - startIndex) % count
        return self.index(startIndex, offsetBy: offset < 0 ? offset + count : offset)
    }
}

extension Collection where SubSequence : Collection {
    
    func rotateZip() -> Zip2Sequence<Self, ConcatCollection<Self.SubSequence, Self.SubSequence>> {
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
    
    init<S : Sequence>(solids: S) where S.Element == ShapeRegion.Solid {
        let solids = Array(solids)
        self.solids = solids
        self.spacePartition = RectCollection(solids.map { $0.boundary })
        self.boundary = solids.first.map { solids.dropFirst().reduce($0.boundary) { $0.union($1.boundary) } } ?? Rect()
        self.cache = Cache()
    }
    
    public struct Solid {
        
        public let solid: Shape.Component
        public let holes: ShapeRegion
        
        public let boundary: Rect
        public let area: Double
        
        fileprivate init(solid: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
            self.solid = solid
            self.holes = holes
            self.boundary = solid.boundary
            self.area = holes.reduce(abs(solid.area)) { $0 - abs($1.area) }
        }
    }
}

extension ShapeRegion {
    
    fileprivate class Cache {
        
        let lck = SDLock()
        
        var subtracting = WeakDictionary<ShapeRegion.Cache, ShapeRegion>()
        var intersection = WeakDictionary<ShapeRegion.Cache, ShapeRegion>()
        var union = WeakDictionary<ShapeRegion.Cache, ShapeRegion>()
        var symmetricDifference = WeakDictionary<ShapeRegion.Cache, ShapeRegion>()
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
        _path.cache[ShapeCacheNonZeroRegionKey] = self
        _path.cache[ShapeCacheEvenOddRegionKey] = self
        return _path
    }
}

extension ShapeRegion.Solid {
    
    public typealias Segment = Shape.Component.BezierCollection.Element
    
    init?<S : Sequence>(segments: S) where S.Element == Segment {
        
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
    
    public var solidRegion: ShapeRegion {
        return ShapeRegion(solid: ShapeRegion.Solid(solid: solid))
    }
}

extension ShapeRegion.Solid {
    
    fileprivate var _solid: ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: self.solid)
    }
    
    fileprivate func reversed() -> ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: solid.reversed(), holes: holes)
    }
    
    fileprivate func components(_ sign: FloatingPointSign) -> ConcatCollection<CollectionOfOne<Shape.Component>, [Shape.Component]> {
        return CollectionOfOne(solid.area.sign == sign ? solid : solid.reversed()).concat(holes.components(sign == .plus ? .minus : .plus))
    }
    
    public var shape: Shape {
        let _path = Shape(components(.plus))
        _path.cache[ShapeCacheNonZeroRegionKey] = ShapeRegion(solid: self)
        _path.cache[ShapeCacheEvenOddRegionKey] = ShapeRegion(solid: self)
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
        case let .segments(forward, backward): return ShapeRegion(solids: forward.enumerated().compactMap { arg in forward.enumerated().contains { $0.0 != arg.0 && $0.1.solid._contains(arg.1.solid) } ? nil : ShapeRegion.Solid(solid: arg.1.solid, holes: ShapeRegion(solids: backward.filter { arg.1.solid._contains($0.solid) })) })
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
        case let .segments(forward, _): return ShapeRegion(solids: forward.enumerated().compactMap { arg in forward.enumerated().contains { $0.0 != arg.0 && $0.1.solid._contains(arg.1.solid) } ? arg.1 : nil })
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
        
        if let union = self.solid._union(other.solid) {
            let a = self.holes.intersection(other.holes).solids
            let b = self.holes.subtracting(other._solid)
            let c = other.holes.subtracting(self._solid)
            return (union.subtracting(ShapeRegion(solids: a.concat(b).concat(c))).solids, true)
        } else {
            return ([self, other], false)
        }
    }
    fileprivate func intersection(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        let intersection = self.solid._intersection(other.solid)
        if intersection.count != 0 {
            return intersection.subtracting(self.holes).subtracting(other.holes).solids
        } else {
            return []
        }
    }
    fileprivate func subtracting(_ other: ShapeRegion.Solid) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return [self]
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other.reversed() : other
        
        let (_subtracting, superset) = self.solid._subtracting(other.solid)
        if superset {
            return [ShapeRegion.Solid(solid: self.solid, holes: self.holes.union(ShapeRegion(solid: other)))]
        } else if let subtracting = _subtracting {
            let a = subtracting.concat(other.holes.intersection(self._solid))
            return self.holes.isEmpty ? Array(a) : ShapeRegion(solids: a).subtracting(self.holes).solids
        } else {
            return [self]
        }
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
        
        return synchronized([cache.lck, other.cache.lck]) {
            
            if cache.union[other.cache] == nil && other.cache.union[cache] == nil {
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
                cache.union[other.cache] = ShapeRegion(solids: result1.concat(result2))
            }
            return cache.union[other.cache] ?? other.cache.union[cache]!
        }
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
        
        return synchronized([cache.lck, other.cache.lck]) {
            
            if cache.intersection[other.cache] == nil && other.cache.intersection[cache] == nil {
                let overlap = self.spacePartition.search(overlap: other.boundary)
                cache.intersection[other.cache] = ShapeRegion(solids: overlap.flatMap { other.intersection(self.solids[$0]) })
            }
            return cache.intersection[other.cache] ?? other.cache.intersection[cache]!
        }
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
        
        return cache.lck.synchronized {
            
            if cache.subtracting[other.cache] == nil {
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
                cache.subtracting[other.cache] = ShapeRegion(solids: result)
            }
            return cache.subtracting[other.cache]!
        }
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
        
        return synchronized([cache.lck, other.cache.lck]) {
            
            if cache.symmetricDifference[other.cache] == nil && other.cache.symmetricDifference[cache] == nil {
                let a = self.subtracting(other).solids
                let b = other.subtracting(self).solids
                cache.symmetricDifference[other.cache] = ShapeRegion(solids: a.concat(b))
            }
            return cache.symmetricDifference[other.cache] ?? other.cache.symmetricDifference[cache]!
        }
    }
}

extension ShapeRegion {
    
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
        if let solid = ShapeRegion.Solid(segments: Shape.Polygon(center: center, radius: radius, edges: edges)[0].bezier) {
            return ShapeRegion(solid: solid)
        } else {
            return ShapeRegion()
        }
    }
    
    public init(rect: Rect) {
        if let solid = ShapeRegion.Solid(segments: Shape(rect: rect)[0].bezier) {
            self.init(solid: solid)
        } else {
            self.init()
        }
    }
    
    public init(roundedRect rect: Rect, radius: Radius) {
        if let solid = ShapeRegion.Solid(segments: Shape(roundedRect: rect, radius: radius)[0].bezier) {
            self.init(solid: solid)
        } else {
            self.init()
        }
    }
    
    public init(ellipseIn rect: Rect) {
        if let solid = ShapeRegion.Solid(segments: Shape(ellipseIn: rect)[0].bezier) {
            self.init(solid: solid)
        } else {
            self.init()
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
        
        self = path.identity.cache[cacheKey] {
            
            var region: ShapeRegion = path.cache[cacheKey] {
                
                var region = ShapeRegion()
                
                switch winding {
                case .nonZero: region.addLoopWithNonZeroWinding(loops: path.breakLoop())
                case .evenOdd: region.addLoopWithEvenOddWinding(loops: path.breakLoop())
                }
                
                return region
            }
            
            region *= path.transform
            return region
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
        var solids: [ShapeRegion.Solid] = []
        if let positive = positive.first?.solids {
            solids.append(contentsOf: positive)
        }
        if let negative = negative.first?.solids {
            solids.append(contentsOf: negative)
        }
        self = ShapeRegion(solids: solids)
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

