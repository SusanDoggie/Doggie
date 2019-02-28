//
//  Point.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
public struct Point: Hashable {
    
    public var x: Double
    public var y: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.x = 0
        self.y = 0
    }
    
    @inlinable
    @inline(__always)
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    @inlinable
    @inline(__always)
    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Point {
    
    @inlinable
    @inline(__always)
    public init(magnitude: Double, phase: Double) {
        self.x = magnitude * cos(phase)
        self.y = magnitude * sin(phase)
    }
    
    @inlinable
    @inline(__always)
    public var phase: Double {
        get {
            return atan2(y, x)
        }
        set {
            self = Point(magnitude: magnitude, phase: newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    public var magnitude: Double {
        get {
            return hypot(x, y)
        }
        set {
            self = Point(magnitude: newValue, phase: phase)
        }
    }
}

extension Point {
    
    @inlinable
    @inline(__always)
    public func offset(dx: Double, dy: Double) -> Point {
        return Point(x: self.x + dx, y: self.y + dy)
    }
}

extension Point: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Point(x: \(x), y: \(y))"
    }
}

extension Point : Codable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.x = try container.decode(Double.self)
        self.y = try container.decode(Double.self)
    }
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }
}

extension Point : Tensor {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
    public static var numberOfComponents: Int {
        return 2
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Point {
        return Point(x: transform(x), y: transform(y))
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Point, _ transform: (Double, Double) -> Double) -> Point {
        return Point(x: transform(self.x, other.x), y: transform(self.y, other.y))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        return accumulator
    }
}

@inlinable
@inline(__always)
public func dot(_ lhs: Point, _ rhs: Point) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

@inlinable
@inline(__always)
public func cross(_ lhs: Point, _ rhs: Point) -> Double {
    return lhs.x * rhs.y - lhs.y * rhs.x
}

@inlinable
@inline(__always)
public prefix func +(val: Point) -> Point {
    return val
}
@inlinable
@inline(__always)
public prefix func -(val: Point) -> Point {
    return Point(x: -val.x, y: -val.y)
}
@inlinable
@inline(__always)
public func +(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
@inlinable
@inline(__always)
public func -(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@inlinable
@inline(__always)
public func *(lhs: Double, rhs: Point) -> Point {
    return Point(x: lhs * rhs.x, y: lhs * rhs.y)
}
@inlinable
@inline(__always)
public func *(lhs: Point, rhs: Double) -> Point {
    return Point(x: lhs.x * rhs, y: lhs.y * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: Point, rhs: Double) -> Point {
    return Point(x: lhs.x / rhs, y: lhs.y / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout Point, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout Point, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
}
@inlinable
@inline(__always)
public func += (lhs: inout Point, rhs: Point) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
@inlinable
@inline(__always)
public func -= (lhs: inout Point, rhs: Point) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

