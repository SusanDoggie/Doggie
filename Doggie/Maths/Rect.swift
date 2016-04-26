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

import Foundation

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

extension Size: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "{w: \(width), h: \(height)}"
    }
    public var debugDescription: String {
        return "{w: \(width), h: \(height)}"
    }
}

extension Size: Hashable {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(0, width, height)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Size, rhs: Size) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}
@warn_unused_result
@_transparent
public func != (lhs: Size, rhs: Size) -> Bool {
    return lhs.width != rhs.width || lhs.height != rhs.height
}

extension Size {
    
    @warn_unused_result
    @_transparent
    public func aspectFit(bound: Size) -> Size {
        let ratio = width / height
        if ratio < bound.width / bound.height {
            return Size(width: bound.height * ratio, height: bound.height)
        } else {
            return Size(width: bound.width, height: bound.width / ratio)
        }
    }
    
    @warn_unused_result
    @_transparent
    public func aspectFill(bound: Size) -> Size {
        let ratio = width / height
        if ratio < bound.width / bound.height {
            return Size(width: bound.width, height: bound.width / ratio)
        } else {
            return Size(width: bound.height * ratio, height: bound.height)
        }
    }
}

@warn_unused_result
public prefix func +(val: Size) -> Size {
    return val
}
@warn_unused_result
public prefix func -(val: Size) -> Size {
    return Size(width: -val.width, height: -val.height)
}
@warn_unused_result
@_transparent
public func +(lhs: Size, rhs:  Size) -> Size {
    return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}
@warn_unused_result
@_transparent
public func -(lhs: Size, rhs:  Size) -> Size {
    return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

@warn_unused_result
@_transparent
public func *(lhs: Double, rhs:  Size) -> Size {
    return Size(width: lhs * rhs.width, height: lhs * rhs.height)
}
@warn_unused_result
@_transparent
public func *(lhs: Size, rhs:  Double) -> Size {
    return Size(width: lhs.width * rhs, height: lhs.height * rhs)
}

@warn_unused_result
@_transparent
public func /(lhs: Size, rhs:  Double) -> Size {
    return Size(width: lhs.width / rhs, height: lhs.height / rhs)
}

@_transparent
public func *= (inout lhs: Size, rhs:  Double) {
    lhs.width *= rhs
    lhs.height *= rhs
}
@_transparent
public func /= (inout lhs: Size, rhs:  Double) {
    lhs.width /= rhs
    lhs.height /= rhs
}
@_transparent
public func += (inout lhs: Size, rhs:  Size) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}
@_transparent
public func -= (inout lhs: Size, rhs:  Size) {
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
}

extension Rect: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "{x: \(x), y: \(y), w: \(width), h: \(height)}"
    }
    public var debugDescription: String {
        return "{x: \(x), y: \(y), w: \(width), h: \(height)}"
    }
}

extension Rect: Hashable {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(0, origin.hashValue, size.hashValue)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Rect, rhs: Rect) -> Bool {
    return lhs.origin == rhs.origin && lhs.size == rhs.size
}
@warn_unused_result
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
            width = newValue - x
        }
    }
    @_transparent
    public var maxY : Double {
        get {
            return y + height
        }
        set {
            height = newValue - y
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
    
    @_transparent
    public var points : [Point] {
        let a = Point(x: self.minX, y: self.minY)
        let b = Point(x: self.maxX, y: self.minY)
        let c = Point(x: self.maxX, y: self.maxY)
        let d = Point(x: self.minX, y: self.maxY)
        return [a, b, c, d]
    }
    
    @_transparent
    public static func bound(points: [Point]) -> Rect {
        if points.count == 0 {
            return Rect()
        }
        let _x = points.map { $0.x }
        let _y = points.map { $0.y }
        let minX = _x.minElement()!
        let minY = _y.minElement()!
        let maxX = _x.maxElement()!
        let maxY = _y.maxElement()!
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Rect {
    
    @warn_unused_result
    @_transparent
    public func union(other : Rect) -> Rect {
        let minX = min(self.minX, other.minX)
        let minY = min(self.minY, other.minY)
        let maxX = max(self.maxX, other.maxX)
        let maxY = max(self.maxY, other.maxY)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    @warn_unused_result
    @_transparent
    public func intersect(other : Rect) -> Rect {
        let minX = max(self.minX, other.minX)
        let minY = max(self.minY, other.minY)
        let _width = max(0, min(self.maxX, other.maxX) - minX)
        let _height = max(0, min(self.maxY, other.maxY) - minY)
        return Rect(x: minX, y: minY, width: _width, height: _height)
    }
    @warn_unused_result
    @_transparent
    public func inset(dx dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width - 2 * dx, height: self.height - 2 * dy)
    }
    @warn_unused_result
    @_transparent
    public func offset(dx dx: Double, dy: Double) -> Rect {
        return Rect(x: self.x + dx, y: self.y + dy, width: self.width, height: self.height)
    }
    @warn_unused_result
    @_transparent
    public func contains(point: Point) -> Bool {
        return (minX...maxX).contains(point.x) && (minY...maxY).contains(point.y)
    }
    @warn_unused_result
    @_transparent
    public func contains(rect: Rect) -> Bool {
        let a = Point(x: rect.minX, y: rect.minY)
        let b = Point(x: rect.maxX, y: rect.maxY)
        return self.contains(a) && self.contains(b)
    }
    @warn_unused_result
    @_transparent
    public func isIntersect(rect: Rect) -> Bool {
        return self.minX < rect.maxX && self.maxX > rect.minX && self.minY < rect.maxY && self.maxY > rect.minY
    }
}
