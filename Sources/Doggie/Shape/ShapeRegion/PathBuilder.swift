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

private let ShapeCacheInterscetionResultKey = "ShapeCacheInterscetionResultKey"

enum InterscetionResult {
    
    struct Loop {
        
        var outer: [ShapeRegion.Solid]
        var inner: [ShapeRegion.Solid]
        
        func reversed() -> Loop {
            return Loop(outer: outer.map { $0.reversed() }, inner: inner.map { $0.reversed() })
        }
    }
    
    case none
    case equal
    case superset
    case subset
    case regions(ShapeRegion, ShapeRegion)
    case loops(Loop)
}

struct InterscetionTable {
    
    var left_segments: [Split : Split] = [:]
    var right_segments: [Split : Split] = [:]
    
    var looping_left: [(Split, Split)] = []
    var looping_right: [(Split, Split)] = []
    
    var left_overlap: Set<Int> = []
    var right_overlap: Set<Int> = []
}

extension InterscetionTable {
    
    struct Split : Comparable, Hashable {
        
        let point_id: Int
        let index: Int
        let split: Double
        
        init(point_id: Int = -1, index: Int, count: Int, split: Double) {
            self.point_id = point_id
            self.index = split == 1 ? (index + 1) % count : index % count
            self.split = split == 1 ? 0 : split
        }
        
        func hash(into hasher: inout Hasher) {
            point_id.hash(into: &hasher)
        }
        
        static func == (lhs: InterscetionTable.Split, rhs: InterscetionTable.Split) -> Bool {
            return lhs.point_id != -1 && lhs.point_id == rhs.point_id
        }
        
        static func < (lhs: InterscetionTable.Split, rhs: InterscetionTable.Split) -> Bool {
            return (lhs.index, lhs.split) < (rhs.index, rhs.split)
        }
    }
    
    struct Overlap : Hashable {
        
        let left: Int
        let right: Int
    }
}

extension InterscetionTable.Split {
    
    func almostEqual(_ other: InterscetionTable.Split) -> Bool {
        return self == other || (self.index == other.index && self.split.almostEqual(other.split))
    }
}

extension InterscetionTable {
    
    init(_ left: Shape.Component, _ right: Shape.Component) {
        
        var left_split: [Int: Split] = [:]
        var right_split: [Int: Split] = [:]
        var overlap: [Overlap: Bool] = [:]
        var point_id = 0
        
        for (r_idx, r_segment) in right.bezier.indexed() where r_segment.boundary.isIntersect(left.boundary.inset(dx: -1e-8, dy: -1e-8)) {
            
            for (l_idx, l_segment) in left.bezier.indexed() where l_segment.boundary.isIntersect(r_segment.boundary.inset(dx: -1e-8, dy: -1e-8)) {
                
                if let intersect = r_segment.intersect(l_segment) {
                    
                    for (l_split, r_split) in intersect {
                        
                        let lhs = Split(point_id: point_id, index: l_idx, count: left.count, split: l_split)
                        let rhs = Split(point_id: point_id, index: r_idx, count: right.count, split: r_split)
                        
                        if left_split.values.contains(where: { $0.almostEqual(lhs) }) && right_split.values.contains(where: { $0.almostEqual(rhs) }) {
                            continue
                        }
                        
                        let _lhs = right_split.values.first(where: { $0.almostEqual(rhs) }).flatMap { left_split[$0.point_id] }
                        let _rhs = left_split.values.first(where: { $0.almostEqual(lhs) }).flatMap { right_split[$0.point_id] }
                        
                        if let _lhs = _lhs {
                            looping_left.append((_lhs, lhs))
                        } else {
                            left_split[point_id] = lhs
                        }
                        if let _rhs = _rhs {
                            looping_right.append((_rhs, rhs))
                        } else {
                            right_split[point_id] = rhs
                        }
                        
                        point_id += 1
                    }
                } else {
                    overlap[Overlap(left: l_idx, right: r_idx)] = l_segment.closest(r_segment.start) < l_segment.closest(r_segment.end)
                }
            }
        }
        
        //guard looping_left.isEmpty && looping_right.isEmpty else { return }
        
        left_overlap = Set(overlap.map { $0.key.left })
        right_overlap = Set(overlap.map { $0.key.right })
        
        left_segments = Dictionary(uniqueKeysWithValues: left_split.values.sorted().rotateZip())
        right_segments = Dictionary(uniqueKeysWithValues: right_split.values.sorted().rotateZip())
        
        for (start, end) in left_segments {
            
            guard let idx = right_segments.index(forKey: start) else { continue }
            
            let r_start = right_segments[idx].key
            let r_end = right_segments[idx].value
            
            guard r_end == end else { continue }
            guard let _overlap = overlap[InterscetionTable.Overlap(left: start.index, right: r_start.index)] else { continue }
            
            left_segments[start] = nil
            right_segments[r_start] = nil
            
            if _overlap {
                if let new_start = left_segments.first(where: { $0.value == start })?.key {
                    left_segments[new_start] = end
                }
                if let new_start = right_segments.first(where: { $0.value == r_start })?.key {
                    right_segments[new_start] = r_end
                }
            }
        }
    }
}

extension Shape.Component {
    
    func splitPath(_ start: InterscetionTable.Split, _ end: InterscetionTable.Split) -> [ShapeRegion.Solid.Segment] {
        
        if start.almostEqual(end) {
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
    
    func _contains(_ other: Shape.Component, hint: Set<Int> = []) -> Bool {
        
        if !self.boundary.isIntersect(other.boundary) {
            return false
        }
        if abs(self.area) < abs(other.area) {
            return false
        }
        
        var hint = hint
        
        if hint.count == 0 {
            
            for index in 0..<other.count {
                if self.bezier.allSatisfy({ !$0.overlap(other.bezier[index]) }) {
                    return self.winding(other.bezier[index].point(0.5)) != 0
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
    
    private func _breakLoop(_ points: [(InterscetionTable.Split, InterscetionTable.Split)]) -> ShapeRegion {
        guard !points.isEmpty else { return ShapeRegion(solid: ShapeRegion.Solid(solid: self)) }
        var region = ShapeRegion()
        for loop in self.breakLoop(points) {
            region.formUnion(ShapeRegion(solid: loop))
        }
        return region
    }
    
    private func _process(_ other: Shape.Component) -> InterscetionResult {
        
        let table = InterscetionTable(self, other)
        
        //guard table.looping_left.isEmpty && table.looping_right.isEmpty else { return .regions(self._breakLoop(table.looping_left), other._breakLoop(table.looping_right)) }
        
        if !table.left_overlap.isStrictSubset(of: 0..<self.count) || !table.right_overlap.isStrictSubset(of: 0..<other.count) {
            if self._contains(other) {
                return .superset
            }
            if other._contains(self) {
                return .subset
            }
            return .equal
        }
        
        var left_segments = table.left_segments
        var right_segments = table.right_segments
        
        var outer: [[ShapeRegion.Solid.Segment]] = []
        var inner: [[ShapeRegion.Solid.Segment]] = []
        
        let reverse = self.area.sign != other.area.sign
        
        var flag = true
        
        outer: while let (start, current) = left_segments.first {
            
            left_segments[start] = nil
            
            var current = current
            var segments = self.splitPath(start, current)
            guard !segments.isEmpty else { continue }
            
            var is_left = true
            let is_outer_left = other.winding(segments[0].point(0.5)) == 0
            
            var breaker = 0
            
            while current != start {
                
                breaker += 1
                
                if is_left {
                    
                    if let next = left_segments[current] {
                        
                        let _segments = self.splitPath(current, next)
                        guard !_segments.isEmpty else { continue outer }
                        
                        let _is_outer = other.winding(_segments[0].point(0.5)) == 0
                        
                        if is_outer_left == _is_outer {
                            segments.append(contentsOf: _segments)
                            left_segments[current] = nil
                            current = next
                            breaker = 0
                        } else {
                            guard breaker < 2 else { continue outer }
                            guard let _current = right_segments.index(forKey: current).map({ right_segments[$0].key }) else { continue outer }
                            current = _current
                            flag = false
                            is_left = false
                        }
                        
                    } else {
                        guard breaker < 2 else { continue outer }
                        guard let _current = right_segments.index(forKey: current).map({ right_segments[$0].key }) else { continue outer }
                        current = _current
                        flag = false
                        is_left = false
                    }
                    
                } else {
                    
                    if let next = right_segments[current] {
                        
                        let _segments = other.splitPath(current, next)
                        guard !_segments.isEmpty else { continue outer }
                        
                        let _is_outer = self.winding(_segments[0].point(0.5)) == 0
                        
                        if reverse ? is_outer_left != _is_outer : is_outer_left == _is_outer {
                            segments.append(contentsOf: _segments)
                            right_segments[current] = nil
                            current = next
                            breaker = 0
                        } else {
                            guard breaker < 2 else { continue outer }
                            guard let _current = left_segments.index(forKey: current).map({ left_segments[$0].key }) else { continue outer }
                            current = _current
                            flag = false
                            is_left = true
                        }
                        
                    } else {
                        guard breaker < 2 else { continue outer }
                        guard let _current = left_segments.index(forKey: current).map({ left_segments[$0].key }) else { continue outer }
                        current = _current
                        flag = false
                        is_left = true
                    }
                }
            }
            
            if is_outer_left {
                outer.append(segments)
            } else {
                inner.append(segments)
            }
        }
        
        if flag {
            if self._contains(other) {
                return .superset
            }
            if other._contains(self) {
                return .subset
            }
            return .none
        }
        
        let _outer = outer.compactMap { ShapeRegion.Solid(segments: $0) }
        let _inner = inner.compactMap { ShapeRegion.Solid(segments: $0) }
        
        return .loops(InterscetionResult.Loop(outer: _outer, inner: _inner))
    }
    
    private var interscetionResultCache: WeakDictionary<Shape.Component.CacheArray, [Int: InterscetionResult]> {
        get {
            return cache.load(for: ShapeCacheInterscetionResultKey) ?? WeakDictionary()
        }
        nonmutating set {
            cache.store(value: newValue, for: ShapeCacheInterscetionResultKey)
        }
    }
    
    func process(_ other: Shape.Component) -> InterscetionResult {
        
        if interscetionResultCache[other.cache] == nil {
            if let result = other.interscetionResultCache[self.cache] {
                switch result {
                case .none: return .none
                case .equal: return .equal
                case .superset: return .subset
                case .subset: return .superset
                case let .regions(lhs, rhs): return .regions(rhs, lhs)
                case let .loops(loops): return self.area.sign == other.area.sign ? .loops(loops) : .loops(loops.reversed())
                }
            } else {
                interscetionResultCache[other.cache] = self._process(other)
            }
        }
        return interscetionResultCache[other.cache]!
    }
}

extension WeakDictionary where Key == Shape.Component.CacheArray, Value == [Int: InterscetionResult] {
    
    fileprivate subscript(key: Shape.Component.Cache) -> InterscetionResult? {
        get {
            return self[key.list]?[key.index]
        }
        set {
            self[key.list, default: [:]][key.index] = newValue
        }
    }
}
