//
//  Rect.swift
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

public struct Size {
    
    public var width: Double
    public var height: Double
    
    public init() {
        self.width = 0
        self.height = 0
    }
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    public init(width: Int, height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }
}

extension Size: CustomStringConvertible {
    public var description: String {
        return "{w: \(width), h: \(height)}"
    }
}

extension Size: Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, width, height)
    }
}

public func == (lhs: Size, rhs: Size) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}
public func != (lhs: Size, rhs: Size) -> Bool {
    return lhs.width != rhs.width || lhs.height != rhs.height
}

extension Size {
    
    public func aspectFit(_ bound: Size) -> Size {
        let ratio = width / height
        if ratio < bound.width / bound.height {
            return Size(width: bound.height * ratio, height: bound.height)
        } else {
            return Size(width: bound.width, height: bound.width / ratio)
        }
    }
    
    public func aspectFill(_ bound: Size) -> Size {
        let ratio = width / height
        if ratio < bound.width / bound.height {
            return Size(width: bound.width, height: bound.width / ratio)
        } else {
            return Size(width: bound.height * ratio, height: bound.height)
        }
    }
}

public prefix func +(val: Size) -> Size {
    return val
}
public prefix func -(val: Size) -> Size {
    return Size(width: -val.width, height: -val.height)
}
public func +(lhs: Size, rhs:  Size) -> Size {
    return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}
public func -(lhs: Size, rhs:  Size) -> Size {
    return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func *(lhs: Double, rhs:  Size) -> Size {
    return Size(width: lhs * rhs.width, height: lhs * rhs.height)
}
public func *(lhs: Size, rhs:  Double) -> Size {
    return Size(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func /(lhs: Size, rhs:  Double) -> Size {
    return Size(width: lhs.width / rhs, height: lhs.height / rhs)
}

public func *= (lhs: inout Size, rhs:  Double) {
    lhs.width *= rhs
    lhs.height *= rhs
}
public func /= (lhs: inout Size, rhs:  Double) {
    lhs.width /= rhs
    lhs.height /= rhs
}
public func += (lhs: inout Size, rhs:  Size) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}
public func -= (lhs: inout Size, rhs:  Size) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}

public struct Rect {
    
    public var origin : Point
    public var size : Size
    
    public init() {
        self.origin = Point()
        self.size = Size()
    }
    
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

extension Rect: CustomStringConvertible {
    public var description: String {
        return "{x: \(x), y: \(y), w: \(width), h: \(height)}"
    }
}

extension Rect: Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, origin.hashValue, size.hashValue)
    }
}

public func == (lhs: Rect, rhs: Rect) -> Bool {
    return lhs.origin == rhs.origin && lhs.size == rhs.size
}
public func != (lhs: Rect, rhs: Rect) -> Bool {
    return lhs.origin != rhs.origin || lhs.size != rhs.size
}

extension Rect {
    
    public var x : Double {
        get {
            return origin.x
        }
        set {
            origin.x = newValue
        }
    }
    
    public var y : Double {
        get {
            return origin.y
        }
        set {
            origin.y = newValue
        }
    }
    
    public var width : Double {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }
    
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
    
    public var minX : Double {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    public var minY : Double {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    public var maxX : Double {
        get {
            return x + width
        }
        set {
            x = newValue - width
        }
    }
    public var maxY : Double {
        get {
            return y + height
        }
        set {
            y = newValue - height
        }
    }
    public var midX : Double {
        get {
            return 0.5 * width + x
        }
        set {
            x = newValue - 0.5 * width
        }
    }
    public var midY : Double {
        get {
            return 0.5 * height + y
        }
        set {
            y = newValue - 0.5 * height
        }
    }
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
    
    public func aspectFit(bound: Rect) -> Rect {
        var rect = Rect(origin: Point(), size: self.size.aspectFit(bound.size))
        rect.center = bound.center
        return rect
    }
    
    public func aspectFill(bound: Rect) -> Rect {
        var rect = Rect(origin: Point(), size: self.size.aspectFill(bound.size))
        rect.center = bound.center
        return rect
    }
}

extension Rect {
    
    public var points : [Point] {
        let a = Point(x: self.minX, y: self.minY)
        let b = Point(x: self.maxX, y: self.minY)
        let c = Point(x: self.maxX, y: self.maxY)
        let d = Point(x: self.minX, y: self.maxY)
        return [a, b, c, d]
    }
    
    public static func bound(_ points: [Point]) -> Rect {
        if points.count == 0 {
            return Rect()
        }
        let _x = points.map { $0.x }
        let _y = points.map { $0.y }
        let minX = _x.min()!
        let minY = _y.min()!
        let maxX = _x.max()!
        let maxY = _y.max()!
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Rect {
    
    public func union(_ other : Rect) -> Rect {
        let minX = min(self.minX, other.minX)
        let minY = min(self.minY, other.minY)
        let maxX = max(self.maxX, other.maxX)
        let maxY = max(self.maxY, other.maxY)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    public func intersect(_ other : Rect) -> Rect {
        let minX = max(self.minX, other.minX)
        let minY = max(self.minY, other.minY)
        let _width = max(0, min(self.maxX, other.maxX) - minX)
        let _height = max(0, min(self.maxY, other.maxY) - minY)
        return Rect(x: minX, y: minY, width: _width, height: _height)
    }
    public func inset(dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width - 2 * dx, height: self.height - 2 * dy)
    }
    public func offset(dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width, height: self.height)
    }
    public func contains(_ point: Point) -> Bool {
        return (minX...maxX).contains(point.x) && (minY...maxY).contains(point.y)
    }
    public func contains(_ rect: Rect) -> Bool {
        let a = Point(x: rect.minX, y: rect.minY)
        let b = Point(x: rect.maxX, y: rect.maxY)
        return self.contains(a) && self.contains(b)
    }
    public func isIntersect(_ rect: Rect) -> Bool {
        return self.minX < rect.maxX && self.maxX > rect.minX && self.minY < rect.maxY && self.maxY > rect.minY
    }
}
