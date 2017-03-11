//
//  Shape.swift
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

public struct Shape : RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public enum Command {
        case move(Point)
        case line(Point)
        case quad(Point, Point)
        case cubic(Point, Point, Point)
        case close
    }
    
    fileprivate class Cache {
        
        var originalBoundary: Rect?
        var boundary: Rect?
        var identity : Shape?
        
        var area: Double?
        
        var table: [String : Any]
        
        init() {
            self.originalBoundary = nil
            self.boundary = nil
            self.identity = nil
            self.area = nil
            self.table = [:]
        }
        init(originalBoundary: Rect?, boundary: Rect?, table: [String : Any]) {
            self.originalBoundary = originalBoundary
            self.boundary = boundary
            self.identity = nil
            self.area = nil
            self.table = table
        }
    }
    
    fileprivate var cache = Cache()
    fileprivate var commands: [Command]
    
    public var baseTransform : SDTransform = SDTransform(SDTransform.Identity()) {
        willSet {
            if baseTransform != newValue {
                cache = Cache(originalBoundary: cache.originalBoundary, boundary: nil, table: cache.table)
            }
        }
    }
    
    public var rotate: Double = 0 {
        didSet {
            if rotate != oldValue {
                cache = Cache(originalBoundary: cache.originalBoundary, boundary: nil, table: cache.table)
            }
        }
    }
    public var scale: Double = 1 {
        didSet {
            if scale != oldValue {
                let boundary = cache.boundary
                let center = self.center
                let _scale = self.scale / oldValue
                cache = Cache(originalBoundary: cache.originalBoundary, boundary: boundary.map { Rect.bound($0.points.map { ($0 - center) * _scale + center }) }, table: cache.table)
            }
        }
    }
    public var transform : SDTransform {
        get {
            let center = self.center
            let translate = SDTransform.Translate(x: center.x, y: center.y)
            let scale = SDTransform.Scale(self.scale)
            let rotate = SDTransform.Rotate(self.rotate)
            return baseTransform * translate.inverse * scale * rotate * translate
        }
        set {
            let center = self.center
            let translate = SDTransform.Translate(x: center.x, y: center.y)
            let scale = SDTransform.Scale(self.scale)
            let rotate = SDTransform.Rotate(self.rotate)
            baseTransform = newValue * translate.inverse * rotate.inverse * scale.inverse * translate
        }
    }
    
    public init() {
        self.commands = []
    }
    
    public init(arrayLiteral elements: Command ...) {
        self.commands = elements
    }
    
    public init(_ elements: Command ...) {
        self.commands = elements
    }
    
    public init<S : Sequence>(_ commands: S) where S.Iterator.Element == Command {
        self.commands = Array(commands)
    }
    
    public var center : Point {
        get {
            return originalBoundary.center * baseTransform
        }
        set {
            let _center = center
            if _center != newValue {
                var boundary = cache.boundary
                let offset = newValue - _center
                boundary?.origin += offset
                baseTransform *= SDTransform.Translate(x: offset.x, y: offset.y)
                cache = Cache(originalBoundary: cache.originalBoundary, boundary: boundary, table: cache.table)
            }
        }
    }
    
    public subscript(position : Int) -> Command {
        get {
            return commands[position]
        }
        set {
            cache = Cache()
            commands[position] = newValue
        }
    }
    
    public subscript(bounds: Range<Int>) -> MutableRangeReplaceableRandomAccessSlice<Shape> {
        get {
            _failEarlyRangeCheck(bounds, bounds: startIndex..<endIndex)
            return MutableRangeReplaceableRandomAccessSlice(base: self, bounds: bounds)
        }
        set {
            self.replaceSubrange(bounds, with: newValue)
        }
    }
    
    public var startIndex: Int {
        return commands.startIndex
    }
    
    public var endIndex: Int {
        return commands.endIndex
    }
    
    public var boundary : Rect {
        if cache.boundary == nil {
            cache.boundary = identity.originalBoundary
        }
        return cache.boundary!
    }
    
    public var originalBoundary : Rect {
        if cache.originalBoundary == nil {
            var bound: Rect? = nil
            self.apply { commands, state in
                switch commands {
                case let .line(p1): bound = bound?.union(Rect.bound([state.last, p1])) ?? Rect.bound([state.last, p1])
                case let .quad(p1, p2): bound = bound?.union(QuadBezierBound(state.last, p1, p2)) ?? QuadBezierBound(state.last, p1, p2)
                case let .cubic(p1, p2, p3): bound = bound?.union(CubicBezierBound(state.last, p1, p2, p3)) ?? CubicBezierBound(state.last, p1, p2, p3)
                default: break
                }
            }
            cache.originalBoundary = bound ?? Rect()
        }
        return cache.originalBoundary!
    }
    
    public var frame : [Point] {
        let _transform = self.transform
        return originalBoundary.points.map { $0 * _transform }
    }
}

extension Shape {
    
    public static func Rectangle(origin: Point, size: Size) -> Shape {
        return Rectangle(Rect(origin: origin, size: size))
    }
    public static func Rectangle(x: Double, y: Double, width: Double, height: Double) -> Shape {
        return Rectangle(Rect(x: x, y: y, width: width, height: height))
    }
    public static func Rectangle(_ rect: Rect) -> Shape {
        let points = rect.points
        return [.move(points[0]), .line(points[1]), .line(points[2]), .line(points[3]), .close]
    }
    
    public static func Ellipse(_ rect: Rect) -> Shape {
        return Ellipse(center: rect.center, radius: Radius(x: 0.5 * rect.width, y: 0.5 * rect.height))
    }
    public static func Ellipse(center: Point, radius: Double) -> Shape {
        return Ellipse(center: center, radius: Radius(x: radius, y: radius))
    }
    public static func Ellipse(center: Point, radius: Radius) -> Shape {
        let scale = SDTransform.Scale(x: radius.x, y: radius.y)
        let point = BezierCircle.lazy.map { $0 * scale + center }
        let commands: [Shape.Command] = [
            .move(point[0]),
            .cubic(point[1], point[2], point[3]),
            .cubic(point[4], point[5], point[6]),
            .cubic(point[7], point[8], point[9]),
            .cubic(point[10], point[11], point[12]),
            .close
        ]
        return Shape(commands)
    }
}

extension Shape {
    
    public var area: Double {
        if cache.area == nil {
            let transform = self.transform
            var _area: Double = 0
            self.apply { commands, state in
                switch commands {
                case let .line(p1): _area += LineSignedArea(state.last * transform, p1 * transform)
                case let .quad(p1, p2): _area += QuadBezierSignedArea(state.last * transform, p1 * transform, p2 * transform)
                case let .cubic(p1, p2, p3): _area += CubicBezierSignedArea(state.last * transform, p1 * transform, p2 * transform, p3 * transform)
                default: break
                }
            }
            cache.area = _area
        }
        return cache.area!
    }
}

extension Shape {
    
    @_transparent
    var cacheTable: [String: Any] {
        get {
            return cache.table
        }
        nonmutating set {
            cache.table = newValue
        }
    }
}

extension Shape {
    
    public var lastMove: Bool {
        if let command = self.commands.last, case .move = command {
            return true
        }
        return false
    }
    
    public var lastClose: Bool {
        if let command = self.commands.last, case .close = command {
            return true
        }
        return false
    }
}

extension Shape : RangeReplaceableCollection {
    
    public mutating func append(_ x: Command) {
        cache = Cache()
        commands.append(x)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        commands.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        cache = Cache()
        commands.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Command {
        cache = Cache()
        commands.replaceSubrange(subRange, with: newElements)
    }
}

extension Shape {
    
    public struct ComputeState {
        
        public let start : Point
        public let last : Point
    }
    
    public func apply(body: (Command, ComputeState) throws -> Void) rethrows {
        var start : Point = Point()
        var last : Point = Point()
        for item in self.commands {
            switch item {
            case let .move(point):
                try body(.move(point), ComputeState(start: point, last: point))
                start = point
                last = point
            case let .line(point):
                try body(.line(point), ComputeState(start: start, last: last))
                last = point
            case let .quad(p1, p2):
                try body(.quad(p1, p2), ComputeState(start: start, last: last))
                last = p2
            case let .cubic(p1, p2, p3):
                try body(.cubic(p1, p2, p3), ComputeState(start: start, last: last))
                last = p3
            case .close:
                try body(.close, ComputeState(start: start, last: last))
                last = start
            }
        }
    }
}

extension Shape {
    
    public var identity : Shape {
        if rotate == 0 && scale == 1 && baseTransform == SDTransform.Identity() {
            return self
        }
        if cache.identity == nil {
            let transform = self.transform
            if transform == SDTransform.Identity() {
                let _path = Shape(self.commands)
                _path.cache.originalBoundary = cache.originalBoundary
                _path.cache.boundary = cache.boundary
                _path.cache.area = cache.area
                cache.identity = _path
            } else {
                var _path = Shape()
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
                cache.identity = _path
            }
        }
        return cache.identity!
    }
}
