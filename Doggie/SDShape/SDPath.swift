//
//  SDPath.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

import Foundation

public protocol SDPathComponent {
    
}

public struct SDPath : SDShape, MutableCollectionType, ArrayLiteralConvertible {
    
    public typealias Generator = IndexingGenerator<SDPath>
    
    private var component: [SDPathComponent]
    
    public var transform : SDTransform
    
    public init() {
        component = []
        transform = SDTransform(SDTransform.Identity())
    }
    
    public init(arrayLiteral elements: SDPathComponent ...) {
        component = elements
        transform = SDTransform(SDTransform.Identity())
    }
    
    public init<S : SequenceType where S.Generator.Element == SDPathComponent>(_ components: S) {
        component = components.array
        transform = SDTransform(SDTransform.Identity())
    }
    
    public var center : Point {
        get {
            return frame.center
        }
        set {
            let offset = newValue - frame.center
            transform = SDTransform.Translate(x: offset.x, y: offset.y) * transform
        }
    }
    
    public subscript(index : Int) -> SDPathComponent {
        get {
            return component[index]
        }
        set {
            component[index] = newValue
        }
    }
    
    public var count : Int {
        return component.count
    }
    
    public var startIndex: Int {
        return component.startIndex
    }
    
    public var endIndex: Int {
        return component.endIndex
    }
    
    
    public struct Move : SDPathComponent {
        
        public var x: Double
        public var y: Double
        
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
        
        public init(_ point: Point) {
            self.x = point.x
            self.y = point.y
        }
        
        public var point: Point {
            get {
                return Point(x: x, y: y)
            }
            set {
                self.x = newValue.x
                self.y = newValue.y
            }
        }
    }
    
    public struct Line : SDPathComponent {
        
        public var x: Double
        public var y: Double
        
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
        
        public init(_ point: Point) {
            self.x = point.x
            self.y = point.y
        }
        
        public var point: Point {
            get {
                return Point(x: x, y: y)
            }
            set {
                self.x = newValue.x
                self.y = newValue.y
            }
        }
    }
    
    public struct QuadBezier : SDPathComponent {
        
        public var p1: Point?
        public var p2: Point
        
        public init(x1: Double, y1: Double, x2: Double, y2: Double) {
            p1 = Point(x: x1, y: y1)
            p2 = Point(x: x2, y: y2)
        }
        
        public init(x2: Double, y2: Double) {
            p2 = Point(x: x2, y: y2)
        }
        
        public init(_ p1: Point, _ p2: Point) {
            self.p1 = p1
            self.p2 = p2
        }
        
        public init(_ p2: Point) {
            self.p2 = p2
        }
        
        public var point: Point {
            get {
                return p2
            }
            set {
                self.p2 = newValue
            }
        }
    }
    
    public struct CubicBezier : SDPathComponent {
        
        public var p1: Point?
        public var p2: Point
        public var p3: Point
        
        public init(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) {
            p1 = Point(x: x1, y: y1)
            p2 = Point(x: x2, y: y2)
            p3 = Point(x: x3, y: y3)
        }
        
        public init(x2: Double, y2: Double, x3: Double, y3: Double) {
            p2 = Point(x: x2, y: y2)
            p3 = Point(x: x3, y: y3)
        }
        
        public init(_ p1: Point, _ p2: Point, _ p3: Point) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
        }
        
        public init(_ p2: Point, _ p3: Point) {
            self.p2 = p2
            self.p3 = p3
        }
        
        public var point: Point {
            get {
                return p3
            }
            set {
                self.p3 = newValue
            }
        }
    }
    
    public struct Arc : SDPathComponent {
        
        public var x: Double
        public var y: Double
        
        public var rx: Double
        public var ry: Double
        
        public var rotate : Double
        
        public var largeArc : Bool
        
        ///  draw with positive direction
        public var sweep : Bool
        
        public init(x: Double, y: Double, rx: Double, ry: Double, rotate: Double, largeArc : Bool, sweep : Bool) {
            self.x = x
            self.y = y
            self.rx = rx
            self.ry = ry
            self.rotate = rotate
            self.largeArc = largeArc
            self.sweep = sweep
        }
        
        public init(point: Point, radius: Radius, rotate: Double, largeArc : Bool, sweep : Bool) {
            self.x = point.x
            self.y = point.y
            self.rx = radius.x
            self.ry = radius.y
            self.rotate = rotate
            self.largeArc = largeArc
            self.sweep = sweep
        }
        
        public var point: Point {
            get {
                return Point(x: x, y: y)
            }
            set {
                self.x = newValue.x
                self.y = newValue.y
            }
        }
        public var radius: Radius {
            get {
                return Radius(x: rx, y: ry)
            }
            set {
                self.rx = newValue.x
                self.ry = newValue.y
            }
        }
    }
    
    public struct ClosePath : SDPathComponent {
        
        public init() {
            
        }
    }
    
    public var boundary : Rect {
        var bound: Rect? = nil
        self.apply { component, state in
            switch component {
            case let line as SDPath.Line:
                if bound == nil {
                    bound = line.bound(state.last)
                } else {
                    bound = bound!.union(line.bound(state.last))
                }
                
            case let quad as SDPath.QuadBezier:
                if bound == nil {
                    bound = quad.bound(state.last, state.lastControl)
                } else {
                    bound = bound!.union(quad.bound(state.last, state.lastControl))
                }
                
            case let cubic as SDPath.CubicBezier:
                if bound == nil {
                    bound = cubic.bound(state.last, state.lastControl)
                } else {
                    bound = bound!.union(cubic.bound(state.last, state.lastControl))
                }
                
            case let arc as SDPath.Arc:
                if bound == nil {
                    bound = arc.bound(state.last)
                } else {
                    bound = bound!.union(arc.bound(state.last))
                }
                
            default: break
            }
        }
        return bound ?? Rect()
    }
    
    public var frame : Rect {
        var bound: Rect? = nil
        self.apply { component, state in
            switch component {
            case let line as SDPath.Line:
                if bound == nil {
                    bound = line.bound(state.last, transform)
                } else {
                    bound = bound!.union(line.bound(state.last, transform))
                }
                
            case let quad as SDPath.QuadBezier:
                if bound == nil {
                    bound = quad.bound(state.last, state.lastControl, transform)
                } else {
                    bound = bound!.union(quad.bound(state.last, state.lastControl, transform))
                }
                
            case let cubic as SDPath.CubicBezier:
                if bound == nil {
                    bound = cubic.bound(state.last, state.lastControl, transform)
                } else {
                    bound = bound!.union(cubic.bound(state.last, state.lastControl, transform))
                }
                
            case let arc as SDPath.Arc:
                if bound == nil {
                    bound = arc.bound(state.last, transform)
                } else {
                    bound = bound!.union(arc.bound(state.last, transform))
                }
                
            default: break
            }
        }
        return bound ?? Rect()
    }
    
}

extension SDPath {
    
    public init(_ rect: Rect) {
        let points = rect.points
        component = [Move(points[0]), Line(points[1]), Line(points[2]), Line(points[3]), ClosePath()]
        transform = SDTransform(SDTransform.Identity())
    }
    
    public init(_ rect: SDRectangle) {
        let points = rect.points
        component = [Move(points[0]), Line(points[1]), Line(points[2]), Line(points[3]), ClosePath()]
        transform = SDTransform(SDTransform.Identity())
    }
    
    public init(_ ellipse: SDEllipse) {
        let a = Point(x: ellipse.x + ellipse.rx, y: ellipse.y)
        let b = Point(x: ellipse.x - ellipse.rx, y: ellipse.y)
        self.init(arrayLiteral: SDPath.Move(a),
            SDPath.Arc(point: b, radius: ellipse.radius, rotate: 0, largeArc: true, sweep: true),
            SDPath.Arc(point: a, radius: ellipse.radius, rotate: 0, largeArc: true, sweep: true),
            SDPath.ClosePath()
        )
        self.transform = ellipse.transform
    }
}

extension SDPath : RangeReplaceableCollectionType {
    
    public mutating func append(x: SDPathComponent) {
        component.append(x)
    }
    
    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == SDPathComponent>(newElements: S) {
        component.appendContentsOf(newElements)
    }
    
    public mutating func removeLast() -> SDPathComponent {
        return component.removeLast()
    }
    
    public mutating func popLast() -> SDPathComponent? {
        return component.popLast()
    }
    
    public mutating func reserveCapacity(minimumCapacity: Int) {
        component.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        component.removeAll(keepCapacity: keepCapacity)
    }
    
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == SDPathComponent>(subRange: Range<Int>, with newElements: C) {
        component.replaceRange(subRange, with: newElements)
    }
    
    public mutating func insert(newElement: SDPathComponent, atIndex i: Int) {
        component.insert(newElement, atIndex: i)
    }
    
    public mutating func insertContentsOf<S : CollectionType where S.Generator.Element == SDPathComponent>(newElements: S, at i: Int) {
        component.insertContentsOf(newElements, at: i)
    }
    
    public mutating func removeAtIndex(i: Int) -> SDPathComponent {
        return component.removeAtIndex(i)
    }
    
    public mutating func removeRange(subRange: Range<Int>) {
        component.removeRange(subRange)
    }
}

extension SDPath {
    
    public struct ComputeState {
        
        public let start : Point
        public let last : Point
        public let lastControl : Point?
        public let firstControl : Point?
    }
    
    public struct ComputeStateGenerator : SequenceType, GeneratorType {
        
        private var base : SDPath.Generator
        private var start : Point = Point()
        private var last : Point = Point()
        private var lastControl : Point? = nil
        private var firstControl : Point? = nil
        
        public init(_ base: SDPath) {
            self.base = base.generate()
        }
        
        public mutating func next() -> (SDPathComponent, ComputeState)? {
            var result: (SDPathComponent, ComputeState)? = nil
            if let item = base.next() {
                switch item {
                case let move as SDPath.Move:
                    result = (move, ComputeState(start: move.point, last: move.point, lastControl: nil, firstControl: nil))
                    start = move.point
                    last = move.point
                    lastControl = nil
                    firstControl = nil
                    
                case let line as SDPath.Line:
                    result = (line, ComputeState(start: start, last: last, lastControl: nil, firstControl: nil))
                    last = line.point
                    lastControl = nil
                    firstControl = nil
                    
                case let quad as SDPath.QuadBezier:
                    firstControl = quad.firstControl(last, lastControl)
                    result = (quad, ComputeState(start: start, last: last, lastControl: lastControl, firstControl: firstControl))
                    last = quad.point
                    lastControl = firstControl
                    
                case let cubic as SDPath.CubicBezier:
                    firstControl = cubic.firstControl(last, lastControl)
                    result = (cubic, ComputeState(start: start, last: last, lastControl: lastControl, firstControl: firstControl))
                    last = cubic.point
                    lastControl = cubic.p2
                    
                case let arc as SDPath.Arc:
                    result = (arc, ComputeState(start: start, last: last, lastControl: nil, firstControl: nil))
                    last = arc.point
                    lastControl = nil
                    firstControl = nil
                    
                case let close as SDPath.ClosePath:
                    result = (close, ComputeState(start: start, last: last, lastControl: nil, firstControl: nil))
                    last = start
                    lastControl = nil
                    firstControl = nil
                    
                default: break
                }
            }
            return result
        }
    }
    
    public func apply(@noescape body: (SDPathComponent, ComputeState) throws -> Void) rethrows {
        
        try ComputeStateGenerator(self).forEach(body)
    }
}

extension SDPath.Line {
    
    @warn_unused_result
    public func bound(last: Point) -> Rect {
        return Rect.bound([last, self.point])
    }
    
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return Rect.bound([transform * last, transform * self.point])
    }
}

extension SDPath.QuadBezier {
    
    @warn_unused_result
    public func firstControl(last: Point, _ lastControl: Point?) -> Point {
        if let p1 = self.p1 {
            return p1
        }
        if let lastControl = lastControl {
            return last + last - lastControl
        }
        return last
    }
    
    @warn_unused_result
    public func bound(last: Point, _ lastControl: Point?) -> Rect {
        return QuadBezierBound(last, self.firstControl(last, lastControl), self.p2)
    }
    
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ lastControl: Point?, _ transform: T) -> Rect {
        return QuadBezierBound(last, self.firstControl(last, lastControl), self.p2, transform)
    }
}

extension SDPath.CubicBezier {
    
    @warn_unused_result
    public func firstControl(last: Point, _ lastControl: Point?) -> Point {
        if let p1 = self.p1 {
            return p1
        }
        if let lastControl = lastControl {
            return last + last - lastControl
        }
        return last
    }
    
    @warn_unused_result
    public func bound(last: Point, _ lastControl: Point?) -> Rect {
        return CubicBezierBound(last, self.firstControl(last, lastControl), self.p2, self.p3)
    }
    
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ lastControl: Point?, _ transform: T) -> Rect {
        return CubicBezierBound(last, self.firstControl(last, lastControl), self.p2, self.p3, transform)
    }
}

extension SDPath.Arc {
    
    @warn_unused_result
    public func contains(lastPoint: Point, _ testPoint: Point) -> Bool {
        return !direction(lastPoint, testPoint, self.point).isSignMinus == self.sweep
    }
    @warn_unused_result
    public func details(lastPoint: Point) -> (Point, Radius) {
        let centers = EllipseCenter(self.radius, self.rotate, lastPoint, self.point)
        if centers.count == 0 {
            return (middle(self.point, lastPoint), EllipseRadius(lastPoint, self.point, self.radius, self.rotate))
        } else if centers.count == 1 || (self.contains(lastPoint, centers[0]) ? self.largeArc : !self.largeArc) {
            return (centers[0], radius)
        } else {
            return (centers[1], radius)
        }
    }
    @warn_unused_result
    public func bound(last: Point) -> Rect {
        var list: [Point] = [last, self.point]
        
        let rotate = SDTransform.Rotate(self.rotate)
        let (center, radius) = self.details(last)
        
        let t1 = EllipseStationary(radius, rotate.a, rotate.b)
        let t2 = EllipseStationary(radius, rotate.d, rotate.e)
        
        let a = rotate * Ellipse(t1, Point(), radius) + center
        let b = rotate * Ellipse(t1 + M_PI, Point(), radius) + center
        let c = rotate * Ellipse(t2, Point(), radius) + center
        let d = rotate * Ellipse(t2 + M_PI, Point(), radius) + center
        
        if self.contains(last, a) {
            list.append(a)
        }
        if self.contains(last, b) {
            list.append(b)
        }
        if self.contains(last, c) {
            list.append(c)
        }
        if self.contains(last, d) {
            list.append(d)
        }
        return Rect.bound(list)
    }
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        var list: [Point] = [transform * last, transform * self.point]
        
        let rotate = SDTransform.Rotate(self.rotate)
        let (center, radius) = self.details(last)
        let _transform = transform * rotate
        
        let t1 = EllipseStationary(radius, _transform.a, _transform.b)
        let t2 = EllipseStationary(radius, _transform.d, _transform.e)
        
        let a = rotate * Ellipse(t1, Point(), radius) + center
        let b = rotate * Ellipse(t1 + M_PI, Point(), radius) + center
        let c = rotate * Ellipse(t2, Point(), radius) + center
        let d = rotate * Ellipse(t2 + M_PI, Point(), radius) + center
        
        if self.contains(last, a) {
            list.append(transform * a)
        }
        if self.contains(last, b) {
            list.append(transform * b)
        }
        if self.contains(last, c) {
            list.append(transform * c)
        }
        if self.contains(last, d) {
            list.append(transform * d)
        }
        return Rect.bound(list)
    }
}

extension SDPath {
    
    public var identity : SDPath {
        if self.transform == SDTransform.Identity() {
            return self
        }
        var _path = SDPath()
        self.apply { component, state in
            switch component {
            case let move as SDPath.Move:
                
                _path.append(SDPath.Move(transform * move.point))
                
            case let line as SDPath.Line:
                
                _path.append(SDPath.Line(transform * line.point))
                
            case let quad as SDPath.QuadBezier:
                
                if let p1 = quad.p1 {
                    _path.append(SDPath.QuadBezier(transform * p1, transform * quad.p2))
                } else {
                    _path.append(SDPath.QuadBezier(transform * quad.p2))
                }
                
            case let cubic as SDPath.CubicBezier:
                
                if let p1 = cubic.p1 {
                    _path.append(SDPath.CubicBezier(transform * p1, transform * cubic.p2, transform * cubic.p3))
                } else {
                    _path.append(SDPath.CubicBezier(transform * cubic.p2, transform * cubic.p3))
                }
                
            case let arc as SDPath.Arc:
                
                let (center, radius) = arc.details(state.last)
                
                let _arc_transform = SDTransform.Translate(x: center.x, y: center.y) * SDTransform.Rotate(arc.rotate) * SDTransform.Scale(x: radius.x, y: radius.y)
                let _arc_transform_inverse = _arc_transform.inverse
                
                let _2_M_PI = 2 * M_PI
                
                let _begin = _arc_transform_inverse * state.last
                let _end = _arc_transform_inverse * arc.point
                var startAngle = atan2(_begin.y, _begin.x)
                var endAngle = atan2(_end.y, _end.x)
                while startAngle < 0 {
                    startAngle += _2_M_PI
                }
                while startAngle > _2_M_PI {
                    startAngle -= _2_M_PI
                }
                if arc.sweep {
                    while endAngle < startAngle {
                        endAngle += _2_M_PI
                    }
                } else {
                    while endAngle > startAngle {
                        endAngle -= _2_M_PI
                    }
                }
                
                let _transform = transform * _arc_transform * SDTransform.Rotate(startAngle)
                
                var point = BezierArc(endAngle - startAngle).map { _transform * $0 }
                if point.count > 1 {
                    _path.append(SDPath.CubicBezier(point[1], point[2], point[3]))
                    for i in 1..<point.count / 3 {
                        _path.append(SDPath.CubicBezier(point[i * 3 + 1], point[i * 3 + 2], point[i * 3 + 3]))
                    }
                }
                
            case let close as SDPath.ClosePath:
                
                _path.append(close)
                
            default: break
            }
        }
        return _path
    }
}
