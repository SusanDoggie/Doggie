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
    
    func breakLoop(reference: Double) -> [ShapeRegion.Solid] {
        
        var intersects: [(InterscetionTable.Split, InterscetionTable.Split)] = []
        for (index1, segment1) in bezier.enumerated() {
            for (index2, segment2) in bezier.suffix(from: index1 + 1).indexed() {
                if !segment2.boundary.inset(dx: -1e-6, dy: -1e-6).isIntersect(segment1.boundary.inset(dx: -1e-6, dy: -1e-6)) {
                    continue
                }
                if let _intersects = segment1.intersect(segment2) {
                    for _intersect in _intersects {
                        let s0 = InterscetionTable.Split(point: segment1.point(_intersect.0), index: index1, count: self.count, split: _intersect.0)
                        let s1 = InterscetionTable.Split(point: segment2.point(_intersect.1), index: index2, count: self.count, split: _intersect.1)
                        if s0.almostEqual(s1) {
                            continue
                        }
                        if intersects.contains(where: { $0.almostEqual(s0) && $1.almostEqual(s1) }) {
                            continue
                        }
                        if intersects.contains(where: { $1.almostEqual(s0) && $0.almostEqual(s1) }) {
                            continue
                        }
                        intersects.append((s0, s1))
                    }
                } else {
                    if let a = segment2.fromPoint(segment1.end) {
                        let s0 = InterscetionTable.Split(point: segment1.end, index: index1, count: self.count, split: 1)
                        let s1 = InterscetionTable.Split(point: segment2.point(a), index: index2, count: self.count, split: a)
                        if s0.almostEqual(s1) {
                            continue
                        }
                        if intersects.contains(where: { $0.almostEqual(s0) && $1.almostEqual(s1) }) {
                            continue
                        }
                        if intersects.contains(where: { $1.almostEqual(s0) && $0.almostEqual(s1) }) {
                            continue
                        }
                        intersects.append((s0, s1))
                    }
                    if let b = segment1.fromPoint(segment2.start) {
                        let s0 = InterscetionTable.Split(point: segment1.point(b), index: index1, count: self.count, split: b)
                        let s1 = InterscetionTable.Split(point: segment2.start, index: index2, count: self.count, split: 0)
                        if s0.almostEqual(s1) {
                            continue
                        }
                        if intersects.contains(where: { $0.almostEqual(s0) && $1.almostEqual(s1) }) {
                            continue
                        }
                        if intersects.contains(where: { $1.almostEqual(s0) && $0.almostEqual(s1) }) {
                            continue
                        }
                        intersects.append((s0, s1))
                    }
                }
            }
        }
        
        return breakLoop(intersects, reference: reference)
    }
    
    func breakLoop(_ points: [(InterscetionTable.Split, InterscetionTable.Split)], reference: Double) -> [ShapeRegion.Solid] {
        
        if points.count == 0 {
            return ShapeRegion.Solid(segments: self.bezier, reference: reference).map { [$0] } ?? []
        }
        
        var result: [ShapeRegion.Solid] = []
        
        var graph = Graph<Int, [(InterscetionTable.Split, InterscetionTable.Split)]>()
        
        let _points = points.enumerated().flatMap { [($0, $1.0), ($0, $1.1)] }.sorted { $0.1 < $1.1 }
        
        for (left, right) in _points.rotateZip() {
            if left.0 == right.0 {
                if let solid = ShapeRegion.Solid(segments: self.split_path(left.1, right.1), reference: reference) {
                    result.append(solid)
                }
            } else {
                graph[from: left.0, to: right.0, default: []].append((left.1, right.1))
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
                            segments.append(contentsOf: self.split_path(split.0, split.1))
                            if var splits = graph[from: left, to: right], splits.count != 1 {
                                splits.removeLast()
                                graph[from: left, to: right] = splits
                            } else {
                                graph[from: left, to: right] = nil
                            }
                        }
                    }
                    if let solid = ShapeRegion.Solid(segments: segments, reference: reference) {
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
        
        let bound = self.boundary
        let reference = bound.width * bound.height
        
        var solids: [ShapeRegion.Solid] = []
        
        for item in self {
            var path: [ShapeRegion.Solid.Segment] = []
            for segment in item.bezier {
                
                switch segment.segment {
                case let .cubic(p1, p2, p3):
                    
                    if segment.start.almostEqual(p3) {
                        if let loop = ShapeRegion.Solid(segments: CollectionOfOne(segment), reference: reference) {
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
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split.0), reference: reference) {
                                    solids.append(loop)
                                }
                                segment = split.1
                                
                            } else if check_2 && check_3 {
                                
                                let split = segment.split(a)
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split.1), reference: reference) {
                                    solids.append(loop)
                                }
                                segment = split.0
                                
                            } else if check_2 && check_4 {
                                
                                let split = segment.split([a, b])
                                if let loop = ShapeRegion.Solid(segments: CollectionOfOne(split[1]), reference: reference) {
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
                if let solid = ShapeRegion.Solid(segments: path, reference: reference) {
                    solids.append(solid)
                }
            }
        }
        
        return solids.flatMap { $0.solid.breakLoop(reference: reference) }
    }
}

