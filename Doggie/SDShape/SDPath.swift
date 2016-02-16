//
//  SDPath.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public protocol SDPathCommand {
    
}

public struct SDPath : SDShape, MutableCollectionType, ArrayLiteralConvertible {
    
    public typealias Generator = IndexingGenerator<SDPath>
    
    private var commands: [SDPathCommand]
    
    public var transform : SDTransform
    
    public init() {
        self.commands = []
        self.transform = SDTransform(SDTransform.Identity())
    }
    
    public init(arrayLiteral elements: SDPathCommand ...) {
        self.commands = elements
        self.transform = SDTransform(SDTransform.Identity())
    }
    
    public init<S : SequenceType where S.Generator.Element == SDPathCommand>(_ commands: S) {
        self.commands = commands.array
        self.transform = SDTransform(SDTransform.Identity())
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
    
    public subscript(index : Int) -> SDPathCommand {
        get {
            return commands[index]
        }
        set {
            commands[index] = newValue
        }
    }
    
    public var count : Int {
        return commands.count
    }
    
    public var startIndex: Int {
        return commands.startIndex
    }
    
    public var endIndex: Int {
        return commands.endIndex
    }
    
    public struct Move : SDPathCommand {
        
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
    
    public struct Line : SDPathCommand {
        
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
    
    public struct QuadBezier : SDPathCommand {
        
        public var p1: Point
        public var p2: Point
        
        public init(x1: Double, y1: Double, x2: Double, y2: Double) {
            p1 = Point(x: x1, y: y1)
            p2 = Point(x: x2, y: y2)
        }
        
        public init(_ p1: Point, _ p2: Point) {
            self.p1 = p1
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
    
    public struct CubicBezier : SDPathCommand {
        
        public var p1: Point
        public var p2: Point
        public var p3: Point
        
        public init(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) {
            p1 = Point(x: x1, y: y1)
            p2 = Point(x: x2, y: y2)
            p3 = Point(x: x3, y: y3)
        }
        
        public init(_ p1: Point, _ p2: Point, _ p3: Point) {
            self.p1 = p1
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
    
    public struct ClosePath : SDPathCommand {
        
        public init() {
            
        }
    }
    
    public var boundary : Rect {
        var bound: Rect? = nil
        self.apply { commands, state in
            switch commands {
            case let line as SDPath.Line:
                if bound == nil {
                    bound = line.bound(state.last)
                } else {
                    bound = bound!.union(line.bound(state.last))
                }
                
            case let quad as SDPath.QuadBezier:
                if bound == nil {
                    bound = quad.bound(state.last)
                } else {
                    bound = bound!.union(quad.bound(state.last))
                }
                
            case let cubic as SDPath.CubicBezier:
                if bound == nil {
                    bound = cubic.bound(state.last)
                } else {
                    bound = bound!.union(cubic.bound(state.last))
                }
                
            default: break
            }
        }
        return bound ?? Rect()
    }
    
    public var frame : Rect {
        var bound: Rect? = nil
        self.apply { commands, state in
            switch commands {
            case let line as SDPath.Line:
                if bound == nil {
                    bound = line.bound(state.last, transform)
                } else {
                    bound = bound!.union(line.bound(state.last, transform))
                }
                
            case let quad as SDPath.QuadBezier:
                if bound == nil {
                    bound = quad.bound(state.last, transform)
                } else {
                    bound = bound!.union(quad.bound(state.last, transform))
                }
                
            case let cubic as SDPath.CubicBezier:
                if bound == nil {
                    bound = cubic.bound(state.last, transform)
                } else {
                    bound = bound!.union(cubic.bound(state.last, transform))
                }
                
            default: break
            }
        }
        return bound ?? Rect()
    }
    
    public var path: SDPath {
        return self
    }
}

extension SDPath {
    
    public init(_ rect: Rect) {
        let points = rect.points
        commands = [Move(points[0]), Line(points[1]), Line(points[2]), Line(points[3]), ClosePath()]
        transform = SDTransform(SDTransform.Identity())
    }
    
    public init<S: SDShape>(_ shape: S) {
        self = shape.path
    }
}

extension SDPath : RangeReplaceableCollectionType {
    
    public mutating func append(x: SDPathCommand) {
        commands.append(x)
    }
    
    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == SDPathCommand>(newElements: S) {
        commands.appendContentsOf(newElements)
    }
    
    public mutating func removeLast() -> SDPathCommand {
        return commands.removeLast()
    }
    
    public mutating func popLast() -> SDPathCommand? {
        return commands.popLast()
    }
    
    public mutating func reserveCapacity(minimumCapacity: Int) {
        commands.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        commands.removeAll(keepCapacity: keepCapacity)
    }
    
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == SDPathCommand>(subRange: Range<Int>, with newElements: C) {
        commands.replaceRange(subRange, with: newElements)
    }
    
    public mutating func insert(newElement: SDPathCommand, atIndex i: Int) {
        commands.insert(newElement, atIndex: i)
    }
    
    public mutating func insertContentsOf<S : CollectionType where S.Generator.Element == SDPathCommand>(newElements: S, at i: Int) {
        commands.insertContentsOf(newElements, at: i)
    }
    
    public mutating func removeAtIndex(i: Int) -> SDPathCommand {
        return commands.removeAtIndex(i)
    }
    
    public mutating func removeRange(subRange: Range<Int>) {
        commands.removeRange(subRange)
    }
}

extension SDPath {
    
    public struct ComputeState {
        
        public let start : Point
        public let last : Point
    }
    
    public struct ComputeStateGenerator : SequenceType, GeneratorType {
        
        private var base : SDPath.Generator
        private var start : Point = Point()
        private var last : Point = Point()
        
        public init(_ base: SDPath) {
            self.base = base.generate()
        }
        
        public mutating func next() -> (SDPathCommand, ComputeState)? {
            var result: (SDPathCommand, ComputeState)? = nil
            if let item = base.next() {
                switch item {
                case let move as SDPath.Move:
                    result = (move, ComputeState(start: move.point, last: move.point))
                    start = move.point
                    last = move.point
                    
                case let line as SDPath.Line:
                    result = (line, ComputeState(start: start, last: last))
                    last = line.point
                    
                case let quad as SDPath.QuadBezier:
                    result = (quad, ComputeState(start: start, last: last))
                    last = quad.point
                    
                case let cubic as SDPath.CubicBezier:
                    result = (cubic, ComputeState(start: start, last: last))
                    last = cubic.point
                    
                case let close as SDPath.ClosePath:
                    result = (close, ComputeState(start: start, last: last))
                    last = start
                    
                default: break
                }
            }
            return result
        }
    }
    
    public func apply(@noescape body: (SDPathCommand, ComputeState) throws -> Void) rethrows {
        
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
    public func bound(last: Point) -> Rect {
        return QuadBezierBound(last, self.p1, self.p2)
    }
    
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return QuadBezierBound(last, self.p1, self.p2, transform)
    }
}

extension SDPath.CubicBezier {
    
    @warn_unused_result
    public func bound(last: Point) -> Rect {
        return CubicBezierBound(last, self.p1, self.p2, self.p3)
    }
    
    @warn_unused_result
    public func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return CubicBezierBound(last, self.p1, self.p2, self.p3, transform)
    }
}

extension SDPath {
    
    public var identity : SDPath {
        if self.transform == SDTransform.Identity() {
            return self
        }
        var _path = SDPath()
        _path.reserveCapacity(self.commands.count)
        for command in self.commands {
            switch command {
            case let move as SDPath.Move: _path.append(SDPath.Move(transform * move.point))
            case let line as SDPath.Line: _path.append(SDPath.Line(transform * line.point))
            case let quad as SDPath.QuadBezier: _path.append(SDPath.QuadBezier(transform * quad.p1, transform * quad.p2))
            case let cubic as SDPath.CubicBezier: _path.append(SDPath.CubicBezier(transform * cubic.p1, transform * cubic.p2, transform * cubic.p3))
            case let close as SDPath.ClosePath: _path.append(close)
            default: break
            }
        }
        return _path
    }
}
