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
    
    let solids: [(component: Shape.Component, holes: ShapeRegion)]
    let spacePartition: RectCollection
    
    let cache: Cache
    
    public init() {
        self.solids = []
        self.spacePartition = RectCollection()
        self.boundary = Rect()
        self.cache = Cache()
    }
    
    init<S : Sequence>(_ solids: S) where S.Element == (Shape.Component, ShapeRegion) {
        self.solids = Array(solids)
        self.spacePartition = RectCollection()
        self.boundary = Rect()
        self.cache = Cache()
    }
    
    init(component: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
        self.init([(component, holes)])
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
        return solids.startIndex
    }
    
    public var endIndex: Int {
        return solids.endIndex
    }
    
    public subscript(position: Int) -> ShapeRegion {
        let (component, holes) = solids[position]
        return ShapeRegion(component: component, holes: holes)
    }
}

extension ShapeRegion {
    
    public var area: Double {
        return solids.reduce(0) { $0 + abs($1.component.area) - abs($1.holes.area) }
    }
    
    private func components(positive: Bool) -> [Shape.Component] {
        
        var result: [Shape.Component] = []
        result.reserveCapacity(solids.count)
        
        for (component, holes) in solids {
            let isPositive = component.area.sign == .plus
            result.append(isPositive == positive ? component : component.reversed())
            result.append(contentsOf: holes.components(positive: !positive))
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
    return rhs.determinant.almostZero() ? ShapeRegion() : ShapeRegion(lhs.solids.map { ($0.component * rhs, $0.holes * rhs) })
}

public func *= (lhs: inout ShapeRegion, rhs: SDTransform) {
    lhs = lhs * rhs
}
