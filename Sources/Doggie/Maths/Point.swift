//
//  Point.swift
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

import Foundation

public struct Point {
    
    public var x: Double
    public var y: Double
    
    @_transparent
    public init() {
        self.x = 0
        self.y = 0
    }
    
    @_transparent
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    @_transparent
    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Point {
    
    @_transparent
    public init(magnitude: Double, phase: Double) {
        self.x = magnitude * cos(phase)
        self.y = magnitude * sin(phase)
    }
    
    @_transparent
    public var phase: Double {
        get {
            return atan2(y, x)
        }
        set {
            self = Point(magnitude: magnitude, phase: newValue)
        }
    }
}

extension Point {
    
    @_transparent
    public func offset(dx: Double, dy: Double) -> Point {
        return Point(x: self.x + dx, y: self.y + dy)
    }
}

extension Point: CustomStringConvertible {
    
    @_transparent
    public var description: String {
        return "Point(x: \(x), y: \(y))"
    }
}

extension Point: Hashable {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(x, y)
    }
}

extension Point : Tensor {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 2
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return x
            case 1: return y
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: x = newValue
            case 1: y = newValue
            default: fatalError()
            }
        }
    }
}

@_transparent
public func dot(_ lhs: Point, _ rhs: Point) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

@_transparent
public func cross(_ lhs: Point, _ rhs: Point) -> Double {
    return lhs.x * rhs.y - lhs.y * rhs.x
}

@_transparent
public prefix func +(val: Point) -> Point {
    return val
}
@_transparent
public prefix func -(val: Point) -> Point {
    return Point(x: -val.x, y: -val.y)
}
@_transparent
public func +(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
@_transparent
public func -(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@_transparent
public func *(lhs: Double, rhs: Point) -> Point {
    return Point(x: lhs * rhs.x, y: lhs * rhs.y)
}
@_transparent
public func *(lhs: Point, rhs: Double) -> Point {
    return Point(x: lhs.x * rhs, y: lhs.y * rhs)
}

@_transparent
public func /(lhs: Point, rhs: Double) -> Point {
    return Point(x: lhs.x / rhs, y: lhs.y / rhs)
}

@_transparent
public func *= (lhs: inout Point, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
}
@_transparent
public func /= (lhs: inout Point, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
}
@_transparent
public func += (lhs: inout Point, rhs: Point) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
@_transparent
public func -= (lhs: inout Point, rhs: Point) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

@_transparent
public func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
@_transparent
public func != (lhs: Point, rhs: Point) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}
