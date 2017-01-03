//
//  SDPath.swift
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

public struct SDPath : SDShape, RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
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
        
        var frame: Rect?
        var boundary: Rect?
        var identity : SDPath?
        
        var area: Double?
        
        var table: [String : Any]
        var transformedTable: [String : Any]
        
        init() {
            self.frame = nil
            self.boundary = nil
            self.identity = nil
            self.area = nil
            self.table = [:]
            self.transformedTable = [:]
        }
        init(frame: Rect?, boundary: Rect?, table: [String : Any]) {
            self.frame = frame
            self.boundary = boundary
            self.identity = nil
            self.area = nil
            self.table = table
            self.transformedTable = [:]
        }
    }
    
    fileprivate var cache = Cache()
    fileprivate var commands: [Command]
    
    public var baseTransform : SDTransform = SDTransform(SDTransform.Identity()) {
        willSet {
            if baseTransform != newValue {
                cache = Cache(frame: cache.frame, boundary: nil, table: cache.table)
            }
        }
    }
    
    public var rotate: Double = 0 {
        didSet {
            if rotate != oldValue {
                cache = Cache(frame: cache.frame, boundary: nil, table: cache.table)
                center = originalBoundary.center * baseTransform * SDTransform.Scale(scale) * SDTransform.Rotate(oldValue)
            }
        }
    }
    public var scale: Double = 1 {
        didSet {
            if scale != oldValue {
                let boundary = cache.boundary
                let _center = originalBoundary.center * baseTransform * SDTransform.Scale(oldValue) * SDTransform.Rotate(rotate)
                center = _center
                if boundary != nil {
                    cache = Cache(frame: cache.frame, boundary: Rect.bound(boundary!.points.map { ($0 - _center) * scale / oldValue + _center }), table: cache.table)
                }
            }
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
            return originalBoundary.center * transform
        }
        set {
            let _center = center
            if _center != newValue {
                var boundary = cache.boundary
                boundary?.origin += newValue - _center
                let offset = newValue * SDTransform.Rotate(rotate).inverse * SDTransform.Scale(scale).inverse - originalBoundary.center * baseTransform
                baseTransform *= SDTransform.Translate(x: offset.x, y: offset.y)
                cache = Cache(frame: cache.frame, boundary: boundary, table: cache.table)
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
    
    public subscript(bounds: Range<Int>) -> MutableRangeReplaceableRandomAccessSlice<SDPath> {
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
        if rotate == 0 && scale == 1 && baseTransform == SDTransform.Identity() {
            return originalBoundary
        }
        let transform = self.transform
        if transform == SDTransform.Identity() {
            return originalBoundary
        }
        if cache.boundary == nil {
            var bound: Rect? = nil
            self.apply { commands, state in
                switch commands {
                case let .line(p1): bound = bound?.union(Rect.bound([state.last * transform, p1 * transform])) ?? Rect.bound([state.last * transform, p1 * transform])
                case let .quad(p1, p2): bound = bound?.union(QuadBezierBound(state.last, p1, p2, transform)) ?? QuadBezierBound(state.last, p1, p2, transform)
                case let .cubic(p1, p2, p3): bound = bound?.union(CubicBezierBound(state.last, p1, p2, p3, transform)) ?? CubicBezierBound(state.last, p1, p2, p3, transform)
                default: break
                }
            }
            cache.boundary = bound ?? Rect()
        }
        return cache.boundary!
    }
    
    public var originalBoundary : Rect {
        if cache.frame == nil {
            var bound: Rect? = nil
            self.apply { commands, state in
                switch commands {
                case let .line(p1): bound = bound?.union(Rect.bound([state.last, p1])) ?? Rect.bound([state.last, p1])
                case let .quad(p1, p2): bound = bound?.union(QuadBezierBound(state.last, p1, p2)) ?? QuadBezierBound(state.last, p1, p2)
                case let .cubic(p1, p2, p3): bound = bound?.union(CubicBezierBound(state.last, p1, p2, p3)) ?? CubicBezierBound(state.last, p1, p2, p3)
                default: break
                }
            }
            cache.frame = bound ?? Rect()
        }
        return cache.frame!
    }
    
    public var path: SDPath {
        return self
    }
}

extension SDPath {
    
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

extension SDPath {
    
    enum CacheType {
        case regular
        case transformed
    }
    
    @_transparent
    func setCache(name: String, value: Any, type: CacheType) {
        switch type {
        case .regular: cache.table[name] = value
        case .transformed: cache.transformedTable[name] = value
        }
    }
    @_transparent
    func getCache(name: String, type: CacheType) -> Any? {
        switch type {
        case .regular: return cache.table[name]
        case .transformed:
            if let value = cache.transformedTable[name] {
                return value
            }
            if rotate == 0 && scale == 1 && baseTransform == SDTransform.Identity() {
                return cache.table[name]
            }
            if transform == SDTransform.Identity() {
                return cache.table[name]
            }
            return nil
        }
    }
}

extension SDPath {
    
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

extension SDPath {
    
    public init<S: SDShape>(_ shape: S) {
        self = shape.path
    }
}

extension SDPath : RangeReplaceableCollection {
    
    public mutating func append(_ x: Command) {
        cache = Cache()
        commands.append(x)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        commands.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(_ keepingCapacity: Bool = false) {
        cache = Cache()
        commands.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Command {
        cache = Cache()
        commands.replaceSubrange(subRange, with: newElements)
    }
}

extension SDPath {
    
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

extension SDPath {
    
    @_transparent
    fileprivate var _identity : SDPath {
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
    
    public var identity : SDPath {
        if cache.identity == nil {
            cache.identity = _identity
        }
        return cache.identity!
    }
}
