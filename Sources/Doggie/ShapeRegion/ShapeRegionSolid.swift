//
//  ShapeRegionSolid.swift
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

extension ShapeRegion {
    
    public struct Solid {
        
        let segments: Shape.Component
        public let holes: ShapeRegion
        
        let cache: Cache
        
        init(segments: Shape.Component, holes: ShapeRegion = ShapeRegion()) {
            self.segments = segments
            self.holes = holes
            self.cache = Cache()
        }
        
        init<S : Sequence>(segments: Shape.Component, holes: S) where S.Iterator.Element == ShapeRegion.Solid {
            self.segments = segments
            self.holes = ShapeRegion(holes)
            self.cache = Cache()
        }
    }
}

extension ShapeRegion.Solid {
    
    class Cache {
        
    }
}

extension ShapeRegion.Solid {
    
    public var area: Double {
        return abs(segments.area) - holes.area
    }
    public var boundary: Rect {
        return segments.boundary
    }
    
    public var solid: ShapeRegion.Solid {
        return ShapeRegion.Solid(segments: segments)
    }
    
    var bigBound: Rect {
        return boundary.inset(dx: ShapeRegionBoundInset, dy: ShapeRegionBoundInset)
    }
}
