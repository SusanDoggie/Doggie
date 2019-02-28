//
//  BreakLoop.swift
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

extension Shape.Component {
    
    func breakLoop() -> [ShapeRegion.Solid] {
        
        var intersects: [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)] = []
        for (index1, segment1) in bezier.enumerated() {
            for (index2, segment2) in bezier.suffix(from: index1 + 1).indexed() {
                if !segment2.boundary.inset(dx: -1e-6, dy: -1e-6).isIntersect(segment1.boundary.inset(dx: -1e-6, dy: -1e-6)) {
                    continue
                }
                if let _intersects = segment1.intersect(segment2) {
                    for _intersect in _intersects {
                        let _l_idx = _intersect.0 == 1 ? self.indexMod(index1 + 1) : index1
                        let _r_idx = _intersect.1 == 1 ? self.indexMod(index2 + 1) : index2
                        let _t1 = _intersect.0 == 1 ? 0 : _intersect.0
                        let _t2 = _intersect.1 == 1 ? 0 : _intersect.1
                        if _l_idx == _r_idx && _t1 == 0 && _t2 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(_t1) && $0.1.index == _r_idx && $0.1.split.almostEqual(_t2) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(_t1) && $0.0.index == _r_idx && $0.0.split.almostEqual(_t2) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: _t1), ConstructiveSolidResult.Split(index: _r_idx, split: _t2)))
                    }
                } else {
                    if let a = segment2.fromPoint(segment1.end) {
                        let _l_idx = self.indexMod(index1 + 1)
                        let _r_idx = a == 1 ? self.indexMod(index2 + 1) : index2
                        let _t2 = a == 1 ? 0 : a
                        if _l_idx == _r_idx && _t2 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(0) && $0.1.index == _r_idx && $0.1.split.almostEqual(_t2) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(0) && $0.0.index == _r_idx && $0.0.split.almostEqual(_t2) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: 0), ConstructiveSolidResult.Split(index: _r_idx, split: _t2)))
                    }
                    if let b = segment1.fromPoint(segment2.start) {
                        let _l_idx = b == 1 ? self.indexMod(index1 + 1) : index1
                        let _r_idx = index2
                        let _t1 = b == 1 ? 0 : b
                        if _l_idx == _r_idx && _t1 == 0 {
                            continue
                        }
                        if intersects.contains(where: { $0.0.index == _l_idx && $0.0.split.almostEqual(_t1) && $0.1.index == _r_idx && $0.1.split.almostEqual(0) }) {
                            continue
                        }
                        if intersects.contains(where: { $0.1.index == _l_idx && $0.1.split.almostEqual(_t1) && $0.0.index == _r_idx && $0.0.split.almostEqual(0) }) {
                            continue
                        }
                        intersects.append((ConstructiveSolidResult.Split(index: _l_idx, split: _t1), ConstructiveSolidResult.Split(index: _r_idx, split: 0)))
                    }
                }
            }
        }
        return breakLoop(intersects.filter { !$0.0.almostEqual($0.1) })
    }
    
    func breakLoop(_ points: [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]) -> [ShapeRegion.Solid] {
        
        if points.count == 0 {
            return ShapeRegion.Solid(segments: self.bezier).map { [$0] } ?? []
        }
        
        var result: [ShapeRegion.Solid] = []
        
        var graph = Graph<Int, [(ConstructiveSolidResult.Split, ConstructiveSolidResult.Split)]>()
        
        let _points = points.enumerated().flatMap { [($0.0, $0.1.0), ($0.0, $0.1.1)] }.sorted { $0.1 < $1.1 }
        
        for (left, right) in _points.rotateZip() {
            if left.0 == right.0 {
                if let solid = ShapeRegion.Solid(segments: self.splitPath(left.1, right.1)) {
                    result.append(solid)
                }
            } else {
                graph[from: left.0, to: right.0, default: Array.init].append((left.1, right.1))
            }
        }
        while let graph_first = graph.first {
            var path: [Int] = [graph_first.from, graph_first.to]
            while let last = path.last, let node = graph.nodes(from: last).first?.0 {
                if let i = path.firstIndex(where: { $0 == node }) {
                    let loop = path.suffix(from: i)
                    var segments: [ShapeRegion.Solid.Segment] = []
                    for (left, right) in loop.rotateZip() {
                        if let split = graph[from: left, to: right]?.last {
                            segments.append(contentsOf: self.splitPath(split.0, split.1))
                            if var splits = graph[from: left, to: right], splits.count != 1 {
                                splits.removeLast()
                                graph[from: left, to: right] = splits
                            } else {
                                graph[from: left, to: right] = nil
                            }
                        }
                    }
                    if let solid = ShapeRegion.Solid(segments: segments) {
                        result.append(solid)
                    }
                    if i == 0 {
                        break
                    }
                    path.removeSubrange(path.index(after: i)..<path.endIndex)
                } else {
                    path.append(node)
                }
            }
        }
        return result
    }
}

extension Shape {
    
    func breakLoop() -> [ShapeRegion.Solid] {
        
        var solids: [ShapeRegion.Solid] = []
        
        for item in self {
            var path: [ShapeRegion.Solid.Segment] = []
            for segment in item.bezier {
                
                switch segment.segment {
                case let .cubic(p1, p2, p3):
                    
                    if segment.start.almostEqual(p3) {
                        if let loop = ShapeRegion.Solid(segments: CollectionOfOne(segment)) {
                            solids.append(loop)
                        }
                    } else {
                        
                        var segment = segment
                        if let (_a, _b) = CubicBezier(segment.start, p1, p2, p3).selfIntersect() {
                            
                            let a = Swift.min(_a, _b)
                            let b = Swift.max(_a, _b)
                            
                            let check_1 = a.almostZero()
                            let check_2 = !check_1 && a > 0
                            let check_3 = (b - 1).almostZero()
                            let check_4 = !check_3 && b < 1
                            
                            if check_1 && check_4 {
                                
                                let split = segment.split(b)
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split.0)) {
                                    solids.append(loop)
                                }
                                segment = split.1
                                
                            } else if check_2 && check_3 {
                                
                                let split = segment.split(a)
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split.1)) {
                                    solids.append(loop)
                                }
                                segment = split.0
                                
                            } else if check_2 && check_4 {
                                
                                let split = segment.split([a, b])
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split[1])) {
                                    solids.append(loop)
                                }
                                path.append(split[0])
                                segment = split[2]
                            }
                        }
                        path.append(segment)
                    }
                    
                default: path.append(segment)
                }
            }
            if path.count != 0 {
                if let solid = ShapeRegion.Solid(segments: path) {
                    solids.append(solid)
                }
            }
        }
        
        return solids.flatMap { $0.solid.breakLoop() }
    }
}

