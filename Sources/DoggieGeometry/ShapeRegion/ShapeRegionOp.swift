//
//  ShapeRegionOp.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

extension Shape.Component {
    
    fileprivate func _union(_ other: Shape.Component, reference: Double) -> ShapeRegion? {
        
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
    fileprivate func _intersection(_ other: Shape.Component, reference: Double) -> ShapeRegion {
        
        switch process(other, reference: reference) {
        case .equal, .subset: return ShapeRegion(solid: ShapeRegion.Solid(solid: self))
        case .superset: return ShapeRegion(solid: ShapeRegion.Solid(solid: other))
        case .none: return ShapeRegion()
        case let .regions(left, right): return left.intersection(right, reference: reference)
        case let .loops(_, inner): return ShapeRegion(solids: inner)
        }
    }
    fileprivate func _subtracting(_ other: Shape.Component, reference: Double) -> (ShapeRegion?, Bool) {
        
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
    
    private var _solid: ShapeRegion.Solid {
        return ShapeRegion.Solid(solid: self.solid)
    }
    
    fileprivate func union(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid]? {
        
        if !self.boundary.isIntersect(other.boundary) {
            return nil
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        guard let union = self.solid._union(other.solid, reference: reference) else { return nil }
        
        let a = self.holes.intersection(other.holes, reference: reference).solids
        let b = self.holes.subtracting(other._solid, reference: reference)
        let c = other.holes.subtracting(self._solid, reference: reference)
        
        return union.subtracting(ShapeRegion(solids: chain(chain(a, b), c)), reference: reference).solids
    }
    fileprivate func intersection(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        let other = self.solid.area.sign == other.solid.area.sign ? other : other.reversed()
        
        let intersection = self.solid._intersection(other.solid, reference: reference)
        if !intersection.isEmpty {
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
            let a = chain(subtracting, other.holes.intersection(self._solid, reference: reference))
            return self.holes.isEmpty ? Array(a) : ShapeRegion(solids: a).subtracting(self.holes, reference: reference).solids
        } else {
            return [self]
        }
    }
}

extension ShapeRegion {
    
    fileprivate func intersection(_ other: ShapeRegion.Solid, reference: Double) -> [ShapeRegion.Solid] {
        
        if self.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return []
        }
        
        return self.solids.flatMap { $0.intersection(other, reference: reference) }
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
}

extension ShapeRegion {
    
    @usableFromInline
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
            return ShapeRegion(solids: chain(self.solids, other.solids))
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
        return ShapeRegion(solids: chain(result1, result2))
    }
    
    @usableFromInline
    func intersection(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty || other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return ShapeRegion()
        }
        
        return ShapeRegion(solids: other.solids.flatMap { self.intersection($0, reference: reference) })
    }
    
    @usableFromInline
    func subtracting(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
        if self.isEmpty {
            return ShapeRegion()
        }
        if other.isEmpty || !self.boundary.isIntersect(other.boundary) {
            return self
        }
        
        return other.solids.reduce(self) { ShapeRegion(solids: $0.subtracting($1, reference: reference)) }
    }
    
    @usableFromInline
    func symmetricDifference(_ other: ShapeRegion, reference: Double) -> ShapeRegion {
        
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
            return ShapeRegion(solids: chain(self.solids, other.solids))
        }
        
        let a = self.subtracting(other, reference: reference).solids
        let b = other.subtracting(self, reference: reference).solids
        return ShapeRegion(solids: chain(a, b))
    }
}
