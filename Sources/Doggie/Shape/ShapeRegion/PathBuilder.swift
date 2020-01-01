//
//  PathBuilder.swift
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

private let ShapeCacheInterscetionResultKey = "ShapeCacheInterscetionResultKey"

enum InterscetionResult {
    
    case none
    case equal
    case superset
    case subset
    case regions(ShapeRegion, ShapeRegion)
    case loops([ShapeRegion.Solid], [ShapeRegion.Solid])
}

struct InterscetionTable {
    
    var _left_segments: [Split : Split] = [:]
    var _right_segments: [Split : Split] = [:]
    
    var left_segments: [Split : Split] = [:]
    var right_segments: [Split : Split] = [:]
    
    var looping_left: [(Split, Split)] = []
    var looping_right: [(Split, Split)] = []
    
    var left_overlap: Set<Segment> = []
    var right_overlap: Set<Segment> = []
}

extension InterscetionTable {
    
    struct Split : Comparable, Hashable {
        
        let point_id: Int
        let point: Point
        let index: Int
        let split: Double
        
        init(point_id: Int = -1, point: Point, index: Int, count: Int, split: Double) {
            self.point_id = point_id
            self.point = point
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
    
    struct Segment : Hashable {
        
        let from: Int
        let to: Int
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
    
    fileprivate func almostEqual(_ other: InterscetionTable.Split, reference: Double) -> Bool {
        return self == other || self.point.almostEqual(other.point, reference: reference) || (self.index == other.index && self.split.almostEqual(other.split))
    }
}

extension Shape.Component {
    
    fileprivate func almost_equal(_ s0: InterscetionTable.Split, _ s1: InterscetionTable.Split, reference: Double) -> Bool {
        return sqrt(abs(self.split_path(s0, s1).reduce(0) { $0 + $1.area })).almostZero(reference: reference) || sqrt(abs(self.split_path(s1, s0).reduce(0) { $0 + $1.area })).almostZero(reference: reference)
    }
}

extension InterscetionTable {
    
    init(_ left: Shape.Component, _ right: Shape.Component, reference: Double) {
        
        let epsilon = -1e-8 * max(1, abs(reference))
        
        var left_split: [Int: Split] = [:]
        var right_split: [Int: Split] = [:]
        var overlap: [Overlap: Bool] = [:]
        var point_id = 0
        
        for (r_idx, r_segment) in right.bezier.indexed() where r_segment.boundary.isIntersect(left.boundary.inset(dx: epsilon, dy: epsilon)) {
            
            for (l_idx, l_segment) in left.bezier.indexed() where l_segment.boundary.isIntersect(r_segment.boundary.inset(dx: epsilon, dy: epsilon)) {
                
                if let intersect = l_segment.intersect(r_segment) {
                    
                    for (l_split, r_split) in intersect {
                        
                        let lhs = Split(point_id: point_id, point: l_segment.point(l_split), index: l_idx, count: left.count, split: l_split)
                        let rhs = Split(point_id: point_id, point: r_segment.point(r_split), index: r_idx, count: right.count, split: r_split)
                        
                        if left_split.values.contains(where: { $0.almostEqual(lhs) }) && right_split.values.contains(where: { $0.almostEqual(rhs) }) {
                            continue
                        }
                        
                        let _lhs = right_split.values.compactMap { $0.almostEqual(rhs, reference: reference) ? left_split[$0.point_id] : nil }
                        let _rhs = left_split.values.compactMap { $0.almostEqual(lhs, reference: reference) ? right_split[$0.point_id] : nil }
                        
                        if _lhs.isEmpty && _rhs.isEmpty {
                            
                            left_split[point_id] = lhs
                            right_split[point_id] = rhs
                            
                        } else {
                            
                            if let _lhs = _lhs.first(where: { !left.almost_equal($0, lhs, reference: reference) }) {
                                looping_left.append((_lhs, lhs))
                            }
                            if let _rhs = _rhs.first(where: { !right.almost_equal($0, rhs, reference: reference) }) {
                                looping_right.append((_rhs, rhs))
                            }
                        }
                        
                        point_id += 1
                    }
                } else {
                    overlap[Overlap(left: l_idx, right: r_idx)] = l_segment.closest(r_segment.start) < l_segment.closest(r_segment.end)
                }
            }
        }
        
        guard looping_left.isEmpty && looping_right.isEmpty else { return }
        
        left_segments = left_split.count > 1 ? Dictionary(uniqueKeysWithValues: left_split.values.sorted().rotateZip()) : [:]
        right_segments = right_split.count > 1 ? Dictionary(uniqueKeysWithValues: right_split.values.sorted().rotateZip()) : [:]
        
        _left_segments = left_segments
        _right_segments = right_segments
        
        for (l_start, l_end) in _left_segments {
            
            guard let idx = _right_segments.index(forKey: l_start) else { continue }
            
            let r_start = _right_segments[idx].key
            let r_end = _right_segments[idx].value
            
            guard r_end == l_end else { continue }
            
            let segments = left.split_path(l_start, l_end) + right.split_path(r_start, r_end).map { $0.reversed() }.reversed()
            
            if ShapeRegion.Solid(segments: segments, reference: reference) == nil ||
                overlap[InterscetionTable.Overlap(left: l_start.index, right: r_start.index)] == true {
                
                if let _start = left_segments.first(where: { $0.value == l_start })?.key, _start != left_segments[l_start] {
                    left_segments[_start] = left_segments[l_start]
                }
                if let _start = right_segments.first(where: { $0.value == r_start })?.key, _start != right_segments[r_start] {
                    right_segments[_start] = right_segments[r_start]
                }
                
                left_segments[l_start] = nil
                right_segments[r_start] = nil
                
                left_overlap.insert(Segment(from: l_start.point_id, to: l_end.point_id))
                right_overlap.insert(Segment(from: r_start.point_id, to: r_end.point_id))
            }
        }
        
        for (l_start, l_end) in _left_segments {
            
            guard let idx = _right_segments.index(forKey: l_end) else { continue }
            
            let r_start = _right_segments[idx].key
            let r_end = _right_segments[idx].value
            
            guard r_end == l_start else { continue }
            
            do {
                
                let segments = left.split_path(l_start, l_end) + right.split_path(r_start, r_end)
                
                if ShapeRegion.Solid(segments: segments, reference: reference) == nil {
                    
                    left_segments[l_start] = nil
                    right_segments[r_start] = nil
                    
                    left_overlap.insert(Segment(from: l_start.point_id, to: l_end.point_id))
                    right_overlap.insert(Segment(from: r_start.point_id, to: r_end.point_id))
                    
                    continue
                }
            }
            
            do {
                
                var l_end_index = l_end.split == 0 ? l_end.index - 1 : l_end.index
                var r_end_index = r_end.split == 0 ? r_end.index - 1 : r_end.index
                
                if l_end_index < 0 {
                    l_end_index += left.count
                }
                if r_end_index < 0 {
                    r_end_index += right.count
                }
                
                let l_range = l_start.index...(l_start.index <= l_end_index ? l_end_index : l_end_index + left.count)
                let r_range = r_start.index...(r_start.index <= r_end_index ? r_end_index : r_end_index + right.count)
                let check = l_range.allSatisfy { l_idx in r_range.contains { r_idx in overlap[InterscetionTable.Overlap(left: l_idx % left.count, right: r_idx % right.count)] == false } }
                
                if check {
                    
                    left_segments[l_start] = nil
                    right_segments[r_start] = nil
                    
                    left_overlap.insert(Segment(from: l_start.point_id, to: l_end.point_id))
                    right_overlap.insert(Segment(from: r_start.point_id, to: r_end.point_id))
                    
                    continue
                }
            }
        }
    }
}

extension Shape.Component {
    
    func split_path(_ start: InterscetionTable.Split, _ end: InterscetionTable.Split) -> [ShapeRegion.Solid.Segment] {
        
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
    
    private func mid_point(_ start: InterscetionTable.Split, _ end: InterscetionTable.Split) -> Point {
        let segments = self.split_path(start, end)
        let lengths = segments.scan(0) { $0 + $1.length() }
        let half = 0.5 * lengths[lengths.count - 1]
        return segments[lengths.dropLast().lastIndex(where: { $0 < half }) ?? 0].point(0.5)
    }
    
    private func _contains(_ other: Shape.Component) -> Bool {
        
        if !self.boundary.isIntersect(other.boundary) {
            return false
        }
        if abs(self.area) < abs(other.area) {
            return false
        }
        
        for index in 0..<other.count {
            if self.bezier.allSatisfy({ !$0.overlap(other.bezier[index]) }) {
                return self.winding(other.bezier[index].point(0.5)) != 0
            }
        }
        
        return false
    }
    
    private func _breakLoop(_ points: [(InterscetionTable.Split, InterscetionTable.Split)], reference: Double) -> ShapeRegion {
        guard !points.isEmpty else { return ShapeRegion(solid: ShapeRegion.Solid(solid: self)) }
        return ShapeRegion(solids: self.breakLoop(points, reference: reference))
    }
    
    private func _process(_ other: Shape.Component, reference: Double) -> InterscetionResult {
        
        let table = InterscetionTable(self, other, reference: reference)
        
        guard table.looping_left.isEmpty && table.looping_right.isEmpty else {
            
            let left = self._breakLoop(table.looping_left, reference: reference)
            let right = other._breakLoop(table.looping_right, reference: reference)
            
            if left.count == 1 && right.count == 1 {
                if other._contains(self) {
                    return .subset
                }
                if self._contains(other) {
                    return .superset
                }
                return .none
            }
            
            return .regions(left, right)
        }
        
        let check1 = !table._left_segments.isEmpty && !table.left_overlap.isStrictSubset(of: table._left_segments.map { InterscetionTable.Segment(from: $0.point_id, to: $1.point_id) })
        let check2 = !table._right_segments.isEmpty && !table.right_overlap.isStrictSubset(of: table._right_segments.map { InterscetionTable.Segment(from: $0.point_id, to: $1.point_id) })
        
        if check1 && check2 {
            
            return .equal
            
        } else if check1 {
            
            let is_inner_right = table.right_segments.contains { !$0.almostEqual($1) && self.winding(other.mid_point($0, table._right_segments[$0]!)) != 0 }
            if is_inner_right || (table.right_segments.isEmpty && self._contains(other)) {
                return .superset
            }
            
            return .none
            
        } else if check2 {
            
            let is_inner_left = table.left_segments.contains { !$0.almostEqual($1) && other.winding(self.mid_point($0, table._left_segments[$0]!)) != 0 }
            if is_inner_left || (table.left_segments.isEmpty && other._contains(self)) {
                return .subset
            }
            
            return .none
        }
        
        var left_segments = table.left_segments
        var right_segments = table.right_segments
        
        var outer: [[ShapeRegion.Solid.Segment]] = []
        var inner: [[ShapeRegion.Solid.Segment]] = []
        
        let reverse = self.area.sign != other.area.sign
        
        var _is_outer_left: Bool?
        var flag = true
        
        while let (start, current) = left_segments.first {
            
            left_segments[start] = nil
            
            var current = current
            var segments = self.split_path(start, current)
            guard !segments.isEmpty else { continue }
            
            var is_left = true
            let is_outer_left = other.winding(self.mid_point(start, table._left_segments[start]!)) == 0
            _is_outer_left = is_outer_left
            
            var breaker = 0
            
            while current != start {
                
                breaker += 1
                
                if is_left {
                    
                    if let next = left_segments[current] {
                        
                        let _segments = self.split_path(current, next)
                        guard !_segments.isEmpty else { break }
                        
                        let _is_outer = other.winding(self.mid_point(current, table._left_segments[current]!)) == 0
                        
                        if is_outer_left == _is_outer {
                            segments.append(contentsOf: _segments)
                            left_segments[current] = nil
                            current = next
                            breaker = 0
                        } else {
                            guard breaker < 2 else { break }
                            guard let _current = right_segments.index(forKey: current).map({ right_segments[$0].key }) else { break }
                            current = _current
                            flag = false
                            is_left = false
                        }
                        
                    } else {
                        guard breaker < 2 else { break }
                        guard let _current = right_segments.index(forKey: current).map({ right_segments[$0].key }) else { break }
                        current = _current
                        flag = false
                        is_left = false
                    }
                    
                } else {
                    
                    if let next = right_segments[current] {
                        
                        let _segments = other.split_path(current, next)
                        guard !_segments.isEmpty else { break }
                        
                        let _is_outer = self.winding(other.mid_point(current, table._right_segments[current]!)) == 0
                        
                        if reverse ? is_outer_left != _is_outer : is_outer_left == _is_outer {
                            segments.append(contentsOf: _segments)
                            right_segments[current] = nil
                            current = next
                            breaker = 0
                        } else {
                            guard breaker < 2 else { break }
                            guard let _current = left_segments.index(forKey: current).map({ left_segments[$0].key }) else { break }
                            current = _current
                            flag = false
                            is_left = true
                        }
                        
                    } else {
                        guard breaker < 2 else { break }
                        guard let _current = left_segments.index(forKey: current).map({ left_segments[$0].key }) else { break }
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
            
            if _is_outer_left.map({ $0 == false }) ?? other._contains(self) {
                return .subset
            }
            
            let is_inner_right = table.right_segments.contains { !$0.almostEqual($1) && self.winding(other.mid_point($0, table._right_segments[$0]!)) != 0 }
            if is_inner_right || (table.right_segments.isEmpty && self._contains(other)) {
                return .superset
            }
            
            return .none
        }
        
        let _outer = outer.compactMap { ShapeRegion.Solid(segments: $0, reference: reference) }
        let _inner = inner.compactMap { ShapeRegion.Solid(segments: $0, reference: reference) }
        
        return .loops(_outer.makeContiguousBuffer(), _inner.makeContiguousBuffer())
    }
    
    private var interscetionResultCache: WeakDictionary<Shape.Component.CacheArray, [Int: InterscetionResult]> {
        get {
            return cache.load(for: ShapeCacheInterscetionResultKey) ?? WeakDictionary()
        }
        nonmutating set {
            cache.store(value: newValue, for: ShapeCacheInterscetionResultKey)
        }
    }
    
    func process(_ other: Shape.Component, reference: Double) -> InterscetionResult {
        
        if interscetionResultCache[other.cache] == nil {
            if let result = other.interscetionResultCache[self.cache] {
                switch result {
                case .none: return .none
                case .equal: return .equal
                case .superset: return .subset
                case .subset: return .superset
                case let .regions(lhs, rhs): return .regions(rhs, lhs)
                case let .loops(outer, inner): return self.area.sign == other.area.sign ? .loops(outer, inner) : .loops(inner, outer)
                }
            } else {
                interscetionResultCache[other.cache] = self._process(other, reference: reference)
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
