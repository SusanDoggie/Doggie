//
//  PathBuilder.swift
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

private let ShapeCacheConstructiveSolidResultKey = "ShapeCacheConstructiveSolidResultKey"

enum ConstructiveSolidResult {
    
    case overlap(Overlap)
    case regions(ShapeRegion, ShapeRegion)
    case segments([ShapeRegion.Solid], [ShapeRegion.Solid])
}

extension ConstructiveSolidResult {
    
    enum Overlap : CaseIterable {
        case none, equal, superset, subset
    }
}

extension ConstructiveSolidResult {
    
    struct Split {
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
        var overlap_l: [(ConstructiveSolidResult.Split, Bool)] = []
        for r_idx in right_spaces.search(overlap: left.boundary.inset(dx: -1e-8, dy: -1e-8)) {
            let r_segment = right.bezier[r_idx]
            for l_idx in left_spaces.search(overlap: right_spaces[r_idx].inset(dx: -1e-8, dy: -1e-8)) {
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
                    let direction = l_segment.closest(r_segment.start) < l_segment.closest(r_segment.end)
                    overlap_l.append((ConstructiveSolidResult.Split(index: l_idx, split: [r_segment.start, r_segment.end].compactMap { l_segment.fromPoint($0) }.min() ?? 0), direction))
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
        
        var _winding: [((Int, SplitData), (Int, SplitData), Bool?, Bool?)] = []
        _winding.reserveCapacity(data.count)
        
        for (s0, s1) in _l_list.rotateZip() {
            if let overlap = overlap_l.first(where: { $0.0.almostEqual(s0.1.left) }) {
                _winding.append((s0, s1, nil, overlap.1))
            } else {
                _winding.append((s0, s1, right.winding(left.mid_point(s0.1.left, s1.1.left)) != 0, nil))
            }
        }
        
        guard let check = _winding.lazy.compactMap({ $0.2 }).first, _winding.contains(where: { $2 == nil ? $3 == false : $2 != check }) else {
            
            if left._contains(right, hint: Set(0..<right.count).subtracting(overlap_r_index)) {
                overlap = .superset
            } else if right._contains(left, hint: Set(0..<left.count).subtracting(overlap_l_index)) {
                overlap = .subset
            }
            return
        }
        
        for (i, t0) in _winding.enumerated() {
            if t0.2 == nil && t0.3 == true {
                _winding[i].2 = _winding.rotated(i).lazy.compactMap({ $0.2 }).first
            }
        }
        
        var begin: Int?
        var last: Int?
        var record: Bool?
        for (i0, i1, winding, _) in _winding.rotated(_winding.firstIndex { $0.2 != _winding[0].2 } ?? 0) {
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
        for (s0, s1) in _r_list.filter({ _r_index, _ in l_graph.keys.contains(_r_index) || l_graph.values.contains { $0.0 == _r_index } }).rotateZip() {
            r_graph[s0.0] = (s1.0, s0.1.right, s1.1.right)
        }
    }
}

extension ConstructiveSolidResult.Split : Comparable {
    
    func almostEqual(_ other: ConstructiveSolidResult.Split) -> Bool {
        return self.index == other.index && self.split.almostEqual(other.split)
    }
    
    static func ==(lhs: ConstructiveSolidResult.Split, rhs: ConstructiveSolidResult.Split) -> Bool {
        return (lhs.index, lhs.split) == (rhs.index, rhs.split)
    }
    
    static func <(lhs: ConstructiveSolidResult.Split, rhs: ConstructiveSolidResult.Split) -> Bool {
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
    
    func splitPath(_ start: ConstructiveSolidResult.Split, _ end: ConstructiveSolidResult.Split) -> [ShapeRegion.Solid.Segment] {
        
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
            let c = CollectionOfOne(self.bezier[end.index].split(end.split).0)
            return Array(a.concat(b.dropFirst()).concat(c))
        } else {
            let a = CollectionOfOne(self.bezier[start.index].split(start.split).1)
            let b = self.bezier.suffix(from: start.index)
            let c = self.bezier.prefix(upTo: end.index)
            let d = CollectionOfOne(self.bezier[end.index].split(end.split).0)
            return Array(a.concat(b.concat(c).dropFirst()).concat(d))
        }
    }
}

extension Shape.Component {
    
    func _contains(_ other: Shape.Component, hint: Set<Int> = []) -> Bool {
        
        if !self.boundary.isIntersect(other.boundary) {
            return false
        }
        if abs(self.area) < abs(other.area) {
            return false
        }
        
        var hint = hint
        
        if hint.count == 0 {
            
            let self_spaces = self.spaces
            let other_spaces = other.spaces
            
            for index in 0..<other.count {
                let overlap = self_spaces.search(overlap: other_spaces[index].inset(dx: -1e-8, dy: -1e-8))
                if overlap.allSatisfy({ !self.bezier[$0].overlap(other.bezier[index]) }) {
                    hint.insert(index)
                }
            }
        }
        
        func _length(_ bezier: Shape.Component.BezierCollection.Element) -> Double {
            let points = bezier.points([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
            return zip(points, points.dropFirst()).reduce(0) { $0 + $1.0.distance(to: $1.1) }
        }
        
        if let index = hint.max(by: { _length(other.bezier[$0]) }) {
            return self.winding(other.bezier[index].point(0.5)) != 0
        }
        
        return false
    }
}

extension WeakDictionary where Key == Shape.Component.CacheArray, Value == [Int: ConstructiveSolidResult] {
    
    fileprivate subscript(key: Shape.Component.Cache) -> ConstructiveSolidResult? {
        get {
            return self[key.list]?[key.index]
        }
        set {
            self[key.list, default: [:]][key.index] = newValue
        }
    }
}

extension Shape.Component {
    
    private var constructiveSolidResultCache: WeakDictionary<Shape.Component.CacheArray, [Int: ConstructiveSolidResult]> {
        get {
            return cache.load(for: ShapeCacheConstructiveSolidResultKey) ?? WeakDictionary()
        }
        nonmutating set {
            cache.store(value: newValue, for: ShapeCacheConstructiveSolidResultKey)
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
                    if let (next, s0, s1) = r_graph[last_idx] {
                        segments.append(contentsOf: other.splitPath(s0, s1))
                        r_graph[last_idx] = nil
                        last_idx = next
                    } else {
                        return []
                    }
                } else {
                    if let (next, s0, s1) = l_graph[last_idx] {
                        segments.append(contentsOf: self.splitPath(s0, s1))
                        l_graph[last_idx] = nil
                        last_idx = next
                    } else {
                        return []
                    }
                }
                flag = !flag
            }
            
            if let solid = ShapeRegion.Solid(segments: segments) {
                result.append(solid)
            }
        }
        
        return result
    }
    
    private func _breakLoop(_ points: [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]) -> ShapeRegion {
        let area = self.area
        let loops = self.breakLoop(points)
        return ShapeRegion(solids: loops.filter { $0.area.sign == area.sign }).subtracting(ShapeRegion(solids: loops.filter { $0.area.sign != area.sign }))
    }
    
    func process(_ other: Shape.Component) -> ConstructiveSolidResult {
        
        if constructiveSolidResultCache[other.cache] == nil {
            if let result = other.constructiveSolidResultCache[self.cache] {
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
                    constructiveSolidResultCache[other.cache] = .regions(self._breakLoop(intersectTable.looping_left), other._breakLoop(intersectTable.looping_right))
                } else {
                    
                    if intersectTable.l_graph.count == 0 {
                        constructiveSolidResultCache[other.cache] = .overlap(intersectTable.overlap)
                    } else {
                        let segments = create_solids(other, intersectTable.l_graph, intersectTable.r_graph)
                        let forward = segments.filter { self.area.sign == $0.solid.area.sign }
                        let backward = segments.filter { self.area.sign != $0.solid.area.sign }
                        constructiveSolidResultCache[other.cache] = .segments(forward, backward)
                    }
                }
            }
        }
        return constructiveSolidResultCache[other.cache]!
    }
}
