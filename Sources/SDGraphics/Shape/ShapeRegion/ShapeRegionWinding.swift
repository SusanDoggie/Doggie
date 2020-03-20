//
//  ShapeRegionWinding.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

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
            _path.transform = SDTransform.translate(x: -bound.minX, y: -bound.minY)
            
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
    
    private mutating func addLoopWithNonZeroWinding(loops: [ShapeRegion.Solid], reference: Double) {
        
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
    
    private mutating func addLoopWithEvenOddWinding(loops: [ShapeRegion.Solid], reference: Double) {
        self = loops.reduce(ShapeRegion()) { $0.symmetricDifference(ShapeRegion(solid: $1), reference: reference) }
    }
}
