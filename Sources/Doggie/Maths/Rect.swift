//
//  Rect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct Size {
    
    public var width: Double
    public var height: Double
    
    @_transparent
    public init() {
        self.width = 0
        self.height = 0
    }
    
    @_transparent
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    @_transparent
    public init(width: Int, height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }
}

extension Size: CustomStringConvertible {
    
    @_transparent
    public var description: String {
        return "Size(width: \(width), height: \(height))"
    }
}

extension Size: Hashable {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(seed: 0, width, height)
    }
}

@_transparent
public func == (lhs: Size, rhs: Size) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}
@_transparent
public func != (lhs: Size, rhs: Size) -> Bool {
    return lhs.width != rhs.width || lhs.height != rhs.height
}

extension Size {
    
    @_inlineable
    public func aspectFit(_ bound: Size) -> Size {
        let u = width * bound.height
        let v = bound.width * height
        if u < v {
            return Size(width: u / height, height: bound.height)
        } else {
            return Size(width: bound.width, height: v / width)
        }
    }
    
    @_inlineable
    public func aspectFill(_ bound: Size) -> Size {
        let u = width * bound.height
        let v = bound.width * height
        if u < v {
            return Size(width: bound.width, height: v / width)
        } else {
            return Size(width: u / height, height: bound.height)
        }
    }
}

extension Size : ScalarMultiplicative {
    
    public typealias Scalar = Double
    
}

@_transparent
public prefix func +(val: Size) -> Size {
    return val
}
@_transparent
public prefix func -(val: Size) -> Size {
    return Size(width: -val.width, height: -val.height)
}
@_transparent
public func +(lhs: Size, rhs: Size) -> Size {
    return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}
@_transparent
public func -(lhs: Size, rhs: Size) -> Size {
    return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

@_transparent
public func *(lhs: Double, rhs: Size) -> Size {
    return Size(width: lhs * rhs.width, height: lhs * rhs.height)
}
@_transparent
public func *(lhs: Size, rhs: Double) -> Size {
    return Size(width: lhs.width * rhs, height: lhs.height * rhs)
}

@_transparent
public func /(lhs: Size, rhs: Double) -> Size {
    return Size(width: lhs.width / rhs, height: lhs.height / rhs)
}

@_transparent
public func *= (lhs: inout Size, rhs: Double) {
    lhs.width *= rhs
    lhs.height *= rhs
}
@_transparent
public func /= (lhs: inout Size, rhs: Double) {
    lhs.width /= rhs
    lhs.height /= rhs
}
@_transparent
public func += (lhs: inout Size, rhs: Size) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}
@_transparent
public func -= (lhs: inout Size, rhs: Size) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}

public struct Rect {
    
    public var origin : Point
    public var size : Size
    
    @_transparent
    public init() {
        self.origin = Point()
        self.size = Size()
    }
    
    @_transparent
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    @_transparent
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
    
    @_transparent
    public init(x: Int, y: Int, width: Int, height: Int) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

extension Rect: CustomStringConvertible {
    
    @_transparent
    public var description: String {
        return "Rect(x: \(x), y: \(y), width: \(width), height: \(height))"
    }
}

extension Rect: Hashable {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(seed: 0, origin.hashValue, size.hashValue)
    }
}

@_transparent
public func == (lhs: Rect, rhs: Rect) -> Bool {
    return lhs.origin == rhs.origin && lhs.size == rhs.size
}
@_transparent
public func != (lhs: Rect, rhs: Rect) -> Bool {
    return lhs.origin != rhs.origin || lhs.size != rhs.size
}

extension Rect {
    
    @_transparent
    public var x : Double {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }
    
    @_transparent
    public var y : Double {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }
    
    @_transparent
    public var width : Double {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }
    
    @_transparent
    public var height : Double {
        get {
            return size.height
        }
        set {
            size.height = newValue
        }
    }
}

extension Rect {
    
    @_transparent
    public var minX : Double {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    @_transparent
    public var minY : Double {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    @_transparent
    public var maxX : Double {
        get {
            return x + width
        }
        set {
            x = newValue - width
        }
    }
    @_transparent
    public var maxY : Double {
        get {
            return y + height
        }
        set {
            y = newValue - height
        }
    }
    @_transparent
    public var midX : Double {
        get {
            return 0.5 * width + x
        }
        set {
            x = newValue - 0.5 * width
        }
    }
    @_transparent
    public var midY : Double {
        get {
            return 0.5 * height + y
        }
        set {
            y = newValue - 0.5 * height
        }
    }
    @_transparent
    public var center : Point {
        get {
            return Point(x: midX, y: midY)
        }
        set {
            midX = newValue.x
            midY = newValue.y
        }
    }
}

extension Rect {
    
    @_inlineable
    public func aspectFit(bound: Rect) -> Rect {
        var rect = Rect(origin: Point(), size: self.size.aspectFit(bound.size))
        rect.center = bound.center
        return rect
    }
    
    @_inlineable
    public func aspectFill(bound: Rect) -> Rect {
        var rect = Rect(origin: Point(), size: self.size.aspectFill(bound.size))
        rect.center = bound.center
        return rect
    }
}

extension Rect {
    
    @_inlineable
    public var points : [Point] {
        let minX = self.minX
        let maxX = self.maxX
        let minY = self.minY
        let maxY = self.maxY
        let a = Point(x: maxX, y: minY)
        let b = Point(x: maxX, y: maxY)
        let c = Point(x: minX, y: maxY)
        let d = Point(x: minX, y: minY)
        return [a, b, c, d]
    }
    
    @_inlineable
    public static func bound<S : Sequence>(_ points: S) -> Rect where S.Element == Point {
        
        var minX = 0.0
        var maxX = 0.0
        var minY = 0.0
        var maxY = 0.0
        
        for (i, p) in points.enumerated() {
            if i == 0 {
                minX = p.x
                maxX = p.x
                minY = p.y
                maxY = p.y
            } else {
                minX = min(minX, p.x)
                maxX = max(maxX, p.x)
                minY = min(minY, p.y)
                maxY = max(maxY, p.y)
            }
        }
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Rect {
    
    @_inlineable
    public func union(_ other : Rect) -> Rect {
        let minX = min(self.minX, other.minX)
        let minY = min(self.minY, other.minY)
        let maxX = max(self.maxX, other.maxX)
        let maxY = max(self.maxY, other.maxY)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    @_inlineable
    public func intersect(_ other : Rect) -> Rect {
        let minX = max(self.minX, other.minX)
        let minY = max(self.minY, other.minY)
        let _width = max(0, min(self.maxX, other.maxX) - minX)
        let _height = max(0, min(self.maxY, other.maxY) - minY)
        return Rect(x: minX, y: minY, width: _width, height: _height)
    }
    @_inlineable
    public func inset(dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width - 2 * dx, height: self.height - 2 * dy)
    }
    @_inlineable
    public func inset(top: Double, left: Double, right: Double, bottom: Double) -> Rect {
        return Rect(x: self.x + left, y: self.y + top, width: self.width - left - right, height: self.height - top - bottom)
    }
    @_inlineable
    public func offset(dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width, height: self.height)
    }
    @_inlineable
    public func contains(_ point: Point) -> Bool {
        return minX...maxX ~= point.x && minY...maxY ~= point.y
    }
    @_inlineable
    public func contains(_ rect: Rect) -> Bool {
        let a = Point(x: rect.minX, y: rect.minY)
        let b = Point(x: rect.maxX, y: rect.maxY)
        return self.contains(a) && self.contains(b)
    }
    @_inlineable
    public func isIntersect(_ rect: Rect) -> Bool {
        return self.minX < rect.maxX && self.maxX > rect.minX && self.minY < rect.maxY && self.maxY > rect.minY
    }
}
