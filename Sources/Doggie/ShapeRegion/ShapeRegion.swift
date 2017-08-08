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

let ShapeCacheNonZeroRegionKey = "ShapeCacheNonZeroRegionKey"
let ShapeCacheEvenOddRegionKey = "ShapeCacheEvenOddRegionKey"

let ShapeRegionBoundInset: Double = -1e-8

public struct ShapeRegion {
    
    public let boundary: Rect
    
    let regions: [Region]
    let spacePartition: RectCollection
    
    let cache: Cache
    
    public init() {
        self.regions = []
        self.spacePartition = RectCollection()
        self.boundary = Rect()
        self.cache = Cache()
    }
    
    init(_ region: Region) {
        self.regions = [region]
        self.spacePartition = RectCollection([region.bigBound])
        self.boundary = region.boundary
        self.cache = Cache()
    }
    
    init<S : Sequence>(_ regions: S) where S.Element == Region {
        let regions = Array(regions)
        self.regions = regions
        self.spacePartition = RectCollection(regions.map { $0.bigBound })
        self.boundary = regions.first.map { regions.dropFirst().reduce($0.boundary) { $0.union($1.boundary) } } ?? Rect()
        self.cache = Cache()
    }
}

extension ShapeRegion {
    
    struct Region {
        
        let component: Shape.Component
        let holes: ShapeRegion
        
        let cache: Cache
        
        init(component: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
            self.component = component
            self.holes = holes
            self.cache = Cache()
        }
        
        init<S : Sequence>(component: Shape.Component, holes: S) where S.Element == Region {
            self.init(component: component, holes: ShapeRegion(holes))
        }
    }
}

extension ShapeRegion.Region {
    
    var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
    
    class Cache {
        
        var subtracting: [ObjectIdentifier: [ShapeRegion.Region]] = [:]
        var intersection: [ObjectIdentifier: [ShapeRegion.Region]] = [:]
        var union: [ObjectIdentifier: ([ShapeRegion.Region], Bool)] = [:]
        
        var process: [ObjectIdentifier: [ShapeRegion.Region]] = [:]
        var process_regions: [ObjectIdentifier: (ShapeRegion, ShapeRegion)] = [:]
        var intersect_table: [ObjectIdentifier: IntersectionTable] = [:]
        
        var reversed: ShapeRegion.Region?
    }
}

extension ShapeRegion.Region {
    
    func reversed() -> ShapeRegion.Region {
        if cache.reversed == nil {
            cache.reversed = ShapeRegion.Region(component: component.reversed(), holes: holes.regions.map { self.component.area.sign == $0.component.area.sign ? $0 : $0.reversed() })
        }
        return cache.reversed!
    }
}

extension ShapeRegion.Region {
    
    var boundary: Rect {
        return component.boundary
    }
    
    var bigBound: Rect {
        return boundary.inset(dx: ShapeRegionBoundInset, dy: ShapeRegionBoundInset)
    }
}

extension ShapeRegion {
    
    class Cache {
        var subtracting: [ObjectIdentifier: ShapeRegion] = [:]
        var intersection: [ObjectIdentifier: ShapeRegion] = [:]
        var union: [ObjectIdentifier: ShapeRegion] = [:]
        var symmetricDifference: [ObjectIdentifier: ShapeRegion] = [:]
    }
}

extension ShapeRegion : RandomAccessCollection {
    
    public var startIndex: Int {
        return regions.startIndex
    }
    
    public var endIndex: Int {
        return regions.endIndex
    }
    
    public subscript(position: Int) -> ShapeRegion {
        return ShapeRegion(regions[position])
    }
}

extension ShapeRegion {
    
    public var solids: ShapeRegion {
        return ShapeRegion(regions.map { Region(component: $0.component) })
    }
    
    public var holes: ShapeRegion {
        return ShapeRegion(regions.flatMap { $0.holes.regions })
    }
}

extension ShapeRegion {
    
    public var area: Double {
        return regions.reduce(0) { $0 + abs($1.component.area) - abs($1.holes.area) }
    }
    
    private func components(positive: Bool) -> [Shape.Component] {
        
        var result: [Shape.Component] = []
        result.reserveCapacity(regions.count)
        
        for region in regions {
            let isPositive = region.component.area.sign == .plus
            result.append(isPositive == positive ? region.component : region.component.reversed())
            result.append(contentsOf: region.holes.components(positive: !positive))
        }
        
        return result
    }
    
    public var shape: Shape {
        let _path = Shape(self.components(positive: true))
        _path.cacheTable[ShapeCacheNonZeroRegionKey] = self
        _path.cacheTable[ShapeCacheEvenOddRegionKey] = self
        return _path
    }
}

extension ShapeRegion {
    
    var cacheId: ObjectIdentifier {
        return ObjectIdentifier(cache)
    }
    
    var bigBound: Rect {
        return boundary.inset(dx: ShapeRegionBoundInset, dy: ShapeRegionBoundInset)
    }
}

public func * (lhs: ShapeRegion, rhs: SDTransform) -> ShapeRegion {
    return rhs.determinant.almostZero() ? ShapeRegion() : ShapeRegion(lhs.regions.map { ShapeRegion.Region(component: $0.component * rhs, holes: $0.holes * rhs) })
}

public func *= (lhs: inout ShapeRegion, rhs: SDTransform) {
    lhs = lhs * rhs
}
