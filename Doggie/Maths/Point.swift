//
//  Point.swift
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

public struct Point {
    
    public var x: Double
    public var y: Double
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Point {
    
    public init(magnitude: Double, phase: Double) {
        self.x = magnitude * cos(phase)
        self.y = magnitude * sin(phase)
    }
    
    public var magnitude: Double {
        get {
            return sqrt(x * x + y * y)
        }
        set {
            self = Point(magnitude: newValue, phase: phase)
        }
    }
    
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
    
    public func offset(dx: Double, dy: Double) -> Point {
        return Point(x: self.x + dx, y: self.y + dy)
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        return "{x: \(x), y: \(y)}"
    }
}

extension Point: Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, x, y)
    }
}

public func dot(_ lhs: Point, _ rhs:  Point) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

public func middle(_ p: Point ... ) -> Point {
    let count = Double(p.count)
    var _x = 0.0
    var _y = 0.0
    for point in p {
        _x += point.x
        _y += point.y
    }
    return Point(x: _x / count, y: _y / count)
}
public func distance(_ lhs: Point, _ rhs: Point) -> Double {
    return (lhs - rhs).magnitude
}

public func direction(_ lhs: Point, _ rhs:  Point) -> Double {
    return lhs.x * rhs.y - lhs.y * rhs.x
}
public func direction(_ a: Point, _ b: Point, _ c: Point) -> Double {
    return direction(b - a, c - a)
}

public prefix func +(val: Point) -> Point {
    return val
}
public prefix func -(val: Point) -> Point {
    return Point(x: -val.x, y: -val.y)
}
public func +(lhs: Point, rhs:  Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
public func -(lhs: Point, rhs:  Point) -> Point {
    return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func *(lhs: Double, rhs:  Point) -> Point {
    return Point(x: lhs * rhs.x, y: lhs * rhs.y)
}
public func *(lhs: Point, rhs:  Double) -> Point {
    return Point(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func /(lhs: Point, rhs:  Double) -> Point {
    return Point(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func *= (lhs: inout Point, rhs:  Double) {
    lhs.x *= rhs
    lhs.y *= rhs
}
public func /= (lhs: inout Point, rhs:  Double) {
    lhs.x /= rhs
    lhs.y /= rhs
}
public func += (lhs: inout Point, rhs:  Point) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
public func -= (lhs: inout Point, rhs:  Point) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

public func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func != (lhs: Point, rhs: Point) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}
