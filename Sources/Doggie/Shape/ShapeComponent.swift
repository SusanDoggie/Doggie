//
//  ShapeComponent.swift
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

extension Shape {
    
    public enum Segment {
        
        case line(Point)
        case quad(Point, Point)
        case cubic(Point, Point, Point)
    }
    
    public struct Component {
        
        public var start: Point
        public var isClosed: Bool
        
        fileprivate var segments: [Segment]
        
        fileprivate var cache = Cache()
        
        public init() {
            self.start = Point()
            self.isClosed = false
            self.segments = []
        }
        public init<S : Sequence>(start: Point, closed: Bool = false, segments: S) where S.Iterator.Element == Segment {
            self.start = start
            self.isClosed = closed
            self.segments = Array(segments)
        }
    }
}

extension Shape.Component {
    
    fileprivate class Cache {
        
        var spaces: RectCollection?
        var boundary: Rect?
        var area: Double?
        
        init() {
            self.spaces = nil
            self.boundary = nil
            self.area = nil
        }
    }
}

extension Shape.Component {
    
    public var spaces : RectCollection {
        if cache.spaces == nil {
            var lastPoint = start
            var bounds: [Rect] = []
            for segment in segments {
                switch segment {
                case let .line(p1):
                    bounds.append(Rect.bound([lastPoint, p1]))
                    lastPoint = p1
                case let .quad(p1, p2):
                    bounds.append(Bezier(lastPoint, p1, p2).boundary)
                    lastPoint = p2
                case let .cubic(p1, p2, p3):
                    bounds.append(Bezier(lastPoint, p1, p2, p3).boundary)
                    lastPoint = p3
                }
            }
            cache.spaces = RectCollection(bounds)
        }
        return cache.spaces!
    }
    
    public var boundary : Rect {
        if cache.boundary == nil {
            var lastPoint = start
            var bound: Rect? = nil
            for segment in segments {
                switch segment {
                case let .line(p1):
                    bound = bound?.union(Rect.bound([lastPoint, p1])) ?? Rect.bound([lastPoint, p1])
                    lastPoint = p1
                case let .quad(p1, p2):
                    bound = bound?.union(Bezier(lastPoint, p1, p2).boundary) ?? Bezier(lastPoint, p1, p2).boundary
                    lastPoint = p2
                case let .cubic(p1, p2, p3):
                    bound = bound?.union(Bezier(lastPoint, p1, p2, p3).boundary) ?? Bezier(lastPoint, p1, p2, p3).boundary
                    lastPoint = p3
                }
            }
            cache.boundary = bound ?? Rect()
        }
        return cache.boundary!
    }
}

extension Shape.Component {
    
    public var area: Double {
        if cache.area == nil {
            var lastPoint = start
            var _area: Double = 0
            for segment in segments {
                switch segment {
                case let .line(p1):
                    _area += Bezier(lastPoint, p1).area
                    lastPoint = p1
                case let .quad(p1, p2):
                    _area += Bezier(lastPoint, p1, p2).area
                    lastPoint = p2
                case let .cubic(p1, p2, p3):
                    _area += Bezier(lastPoint, p1, p2, p3).area
                    lastPoint = p3
                }
            }
            cache.area = _area
        }
        return cache.area!
    }
}

extension Shape.Component : RandomAccessCollection, MutableCollection {
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return segments.startIndex
    }
    
    public var endIndex: Int {
        return segments.endIndex
    }
    
    public subscript(position : Int) -> Shape.Segment {
        get {
            return segments[position]
        }
        set {
            cache = Cache()
            segments[position] = newValue
        }
    }
}

extension Shape.Component : RangeReplaceableCollection {
    
    public mutating func append(_ x: Shape.Segment) {
        cache = Cache()
        segments.append(x)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        segments.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        cache = Cache()
        segments.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Shape.Segment {
        cache = Cache()
        segments.replaceSubrange(subRange, with: newElements)
    }
}

public func * <T: SDTransformProtocol>(lhs: Shape.Component, rhs: T) -> Shape.Component {
    return Shape.Component(start: lhs.start * rhs, closed: lhs.isClosed, segments: lhs.segments.map {
        switch $0 {
        case let .line(p1): return .line(p1 * rhs)
        case let .quad(p1, p2): return .quad(p1 * rhs, p2 * rhs)
        case let .cubic(p1, p2, p3): return .cubic(p1 * rhs, p2 * rhs, p3 * rhs)
        }
    })
}
public func *= <T: SDTransformProtocol>(lhs: inout Shape.Component, rhs: T) {
    lhs = lhs * rhs
}
