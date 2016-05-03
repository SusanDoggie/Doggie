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

public protocol SDPathCommand {
    
}

private enum PathCommand {
    case move(Point)
    case line(Point)
    case quad(Point, Point)
    case cubic(Point, Point, Point)
    case close
}

extension PathCommand {
    
    init(command: SDPathCommand) {
        switch command {
        case let move as SDPath.Move: self = .move(move.point)
        case let line as SDPath.Line: self = .line(line.point)
        case let quad as SDPath.QuadBezier: self = .quad(quad.p1, quad.p2)
        case let cubic as SDPath.CubicBezier: self = .cubic(cubic.p1, cubic.p2, cubic.p3)
        case _ as SDPath.ClosePath: self = .close
        default: fatalError()
        }
    }
    
    var command: SDPathCommand {
        switch self {
        case let move(point): return SDPath.Move(point)
        case let line(point): return SDPath.Line(point)
        case let quad(p1, p2): return SDPath.QuadBezier(p1, p2)
        case let cubic(p1, p2, p3): return SDPath.CubicBezier(p1, p2, p3)
        case close: return SDPath.ClosePath()
        }
    }
}

public struct SDPath : SDShape, MutableCollectionType, ArrayLiteralConvertible {
    
    public typealias Generator = IndexingGenerator<SDPath>
    
    private class BoundaryCache {
        
        var frame: Rect?
        var boundary: Rect?
        
        init() {
            self.frame = nil
            self.boundary = nil
        }
        init(frame: Rect?) {
            self.frame = frame
            self.boundary = nil
        }
    }
    
    private var cache = BoundaryCache()
    private var commands: [PathCommand]
    
    public var baseTransform : SDTransform = SDTransform(SDTransform.Identity()) {
        didSet {
            cache = BoundaryCache(frame: cache.frame)
        }
    }
    
    public var rotate: Double = 0 {
        didSet {
            center = _frame.center * baseTransform * SDTransform.Scale(x: scale, y: scale) * SDTransform.Rotate(oldValue)
        }
    }
    public var scale: Double = 1 {
        didSet {
            center = _frame.center * baseTransform * SDTransform.Scale(x: oldValue, y: oldValue) * SDTransform.Rotate(rotate)
        }
    }
    
    public init() {
        self.commands = []
    }
    
    public init(arrayLiteral elements: SDPathCommand ...) {
        self.commands = elements.map { PathCommand(command: $0) }
    }
    
    public init<S : SequenceType where S.Generator.Element == SDPathCommand>(_ commands: S) {
        self.commands = commands.map { PathCommand(command: $0) }
    }
    
    private init<S : SequenceType where S.Generator.Element == PathCommand>(_ commands: S) {
        self.commands = commands.array
    }
    
    public var center : Point {
        get {
            return _frame.center * transform
        }
        set {
            let offset = newValue * SDTransform.Rotate(rotate).inverse * SDTransform.Scale(x: scale, y: scale).inverse - _frame.center * baseTransform
            baseTransform *= SDTransform.Translate(x: offset.x, y: offset.y)
        }
    }
    
    public subscript(index : Int) -> SDPathCommand {
        get {
            return commands[index].command
        }
        set {
            cache = BoundaryCache()
            commands[index] = PathCommand(command: newValue)
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
        if cache.boundary == nil {
            var bound: Rect? = nil
            let transform = self.transform
            self.apply { commands, state in
                switch commands {
                case let line as SDPath.Line: bound = bound?.union(line.bound(state.last, transform)) ?? line.bound(state.last, transform)
                case let quad as SDPath.QuadBezier: bound = bound?.union(quad.bound(state.last, transform)) ?? quad.bound(state.last, transform)
                case let cubic as SDPath.CubicBezier: bound = bound?.union(cubic.bound(state.last, transform)) ?? cubic.bound(state.last, transform)
                default: break
                }
            }
            cache.boundary = bound ?? Rect()
        }
        return cache.boundary!
    }
    
    private var _frame : Rect {
        if cache.frame == nil {
            var bound: Rect? = nil
            self.apply { commands, state in
                switch commands {
                case let line as SDPath.Line: bound = bound?.union(line.bound(state.last)) ?? line.bound(state.last)
                case let quad as SDPath.QuadBezier: bound = bound?.union(quad.bound(state.last)) ?? quad.bound(state.last)
                case let cubic as SDPath.CubicBezier: bound = bound?.union(cubic.bound(state.last)) ?? cubic.bound(state.last)
                default: break
                }
            }
            cache.frame = bound ?? Rect()
        }
        return cache.frame!
    }
    
    public var frame : [Point] {
        let _transform = self.transform
        return _frame.points.map { $0 * _transform }
    }
    
    public var path: SDPath {
        return self
    }
}

extension SDPath {
    
    public init<S: SDShape>(_ shape: S) {
        self = shape.path
    }
}

extension SDPath : RangeReplaceableCollectionType {
    
    public mutating func append(x: SDPathCommand) {
        cache = BoundaryCache()
        commands.append(PathCommand(command: x))
    }
    
    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == SDPathCommand>(newElements: S) {
        cache = BoundaryCache()
        commands.appendContentsOf(newElements.lazy.map { PathCommand(command: $0) } as LazyMapSequence)
    }
    
    public mutating func appendContentsOf<C : CollectionType where C.Generator.Element == SDPathCommand>(newElements: C) {
        cache = BoundaryCache()
        commands.appendContentsOf(newElements.lazy.map { PathCommand(command: $0) } as LazyMapCollection)
    }
    
    public mutating func removeLast() -> SDPathCommand {
        cache = BoundaryCache()
        return commands.removeLast().command
    }
    
    public mutating func popLast() -> SDPathCommand? {
        cache = BoundaryCache()
        return commands.popLast()?.command
    }
    
    public mutating func reserveCapacity(minimumCapacity: Int) {
        commands.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        cache = BoundaryCache()
        commands.removeAll(keepCapacity: keepCapacity)
    }
    
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == SDPathCommand>(subRange: Range<Int>, with newElements: C) {
        cache = BoundaryCache()
        commands.replaceRange(subRange, with: newElements.lazy.map { PathCommand(command: $0) } as LazyMapCollection)
    }
    
    public mutating func insert(newElement: SDPathCommand, atIndex i: Int) {
        cache = BoundaryCache()
        commands.insert(PathCommand(command: newElement), atIndex: i)
    }
    
    public mutating func insertContentsOf<S : CollectionType where S.Generator.Element == SDPathCommand>(newElements: S, at i: Int) {
        cache = BoundaryCache()
        commands.insertContentsOf(newElements.lazy.map { PathCommand(command: $0) } as LazyMapCollection, at: i)
    }
    
    public mutating func removeAtIndex(i: Int) -> SDPathCommand {
        cache = BoundaryCache()
        return commands.removeAtIndex(i).command
    }
    
    public mutating func removeRange(subRange: Range<Int>) {
        cache = BoundaryCache()
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

private extension SDPath.Line {
    
    func bound(last: Point) -> Rect {
        return Rect.bound([last, self.point])
    }
    func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return Rect.bound([last * transform, self.point * transform])
    }
}

private extension SDPath.QuadBezier {
    
    func bound(last: Point) -> Rect {
        return QuadBezierBound(last, self.p1, self.p2)
    }
    func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return QuadBezierBound(last, self.p1, self.p2, transform)
    }
}

private extension SDPath.CubicBezier {
    
    func bound(last: Point) -> Rect {
        return CubicBezierBound(last, self.p1, self.p2, self.p3)
    }
    func bound<T: SDTransformType>(last: Point, _ transform: T) -> Rect {
        return CubicBezierBound(last, self.p1, self.p2, self.p3, transform)
    }
}

extension SDPath {
    
    public var identity : SDPath {
        if rotate == 0 && scale == 1 && baseTransform == SDTransform.Identity() {
            return self
        }
        let transform = self.transform
        if transform == SDTransform.Identity() {
            return SDPath(self.commands)
        }
        var _path = SDPath()
        _path.reserveCapacity(self.commands.count)
        for command in self.commands {
            switch command {
            case let .move(point): _path.commands.append(.move(point * transform))
            case let .line(point): _path.commands.append(.line(point * transform))
            case let .quad(p1, p2): _path.commands.append(.quad(p1 * transform, p2 * transform))
            case let .cubic(p1, p2, p3): _path.commands.append(.cubic(p1 * transform, p2 * transform, p3 * transform))
            case .close: _path.commands.append(.close)
            }
        }
        return _path
    }
}
