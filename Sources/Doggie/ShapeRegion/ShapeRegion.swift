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
    
    let solids: [Solid]
    let spacePartition: RectCollection
    
    public let bound: Rect
    
    let cache: Cache
    
    public init() {
        self.solids = []
        self.spacePartition = RectCollection()
        self.bound = Rect()
        self.cache = Cache()
    }
    
    public init(_ solid: ShapeRegion.Solid) {
        self.init(CollectionOfOne(solid))
    }
    
    init<S : Sequence>(_ solids: S) where S.Iterator.Element == ShapeRegion.Solid {
        let solids = solids.filter { !$0.segments.isEmpty && !$0.segments.area.almostZero() }
        self.solids = solids
        self.spacePartition = RectCollection(solids.map { $0.bigBound })
        self.bound = solids.first.map { solids.dropFirst().reduce($0.boundary) { $0.union($1.boundary) } } ?? Rect()
        self.cache = Cache()
    }
}

extension ShapeRegion {
    
    class Cache {
        
    }
}

extension ShapeRegion : RandomAccessCollection {
    
    public var startIndex: Int {
        return solids.startIndex
    }
    
    public var endIndex: Int {
        return solids.endIndex
    }
    
    public subscript(position: Int) -> Solid {
        return solids[position]
    }
}

extension ShapeRegion {
    
    public var area: Double {
        return solids.reduce(0) { $0 + abs($1.area) }
    }
}

