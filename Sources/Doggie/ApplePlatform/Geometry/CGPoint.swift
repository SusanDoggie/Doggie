//
//  CGPoint.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

extension CGPoint {
    
    @inlinable
    @inline(__always)
    public init(_ p: Point) {
        self.init(x: CGFloat(p.x), y: CGFloat(p.y))
    }
    @inlinable
    @inline(__always)
    public init<T : BinaryInteger>(x: T, y: T) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
    @inlinable
    @inline(__always)
    public init<T : BinaryFloatingPoint>(x: T, y: T) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
}

extension Point {
    
    @inlinable
    @inline(__always)
    public init(_ p: CGPoint) {
        self.init(x: p.x, y: p.y)
    }
}

extension CGPoint {
    
    @inlinable
    @inline(__always)
    public init(magnitude: CGFloat, phase: CGFloat) {
        self.init(x: magnitude * cos(phase), y: magnitude * sin(phase))
    }
    
    @inlinable
    @inline(__always)
    public var phase: CGFloat {
        get {
            return atan2(y, x)
        }
        set {
            self = CGPoint(magnitude: magnitude, phase: newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    public var magnitude: CGFloat {
        get {
            return hypot(x, y)
        }
        set {
            self = CGPoint(magnitude: newValue, phase: phase)
        }
    }
}

extension CGPoint {
    
    @inlinable
    @inline(__always)
    public func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

@inlinable
@inline(__always)
public func dot(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
    return lhs.x * rhs.x + lhs.y * rhs.y
}

@inlinable
@inline(__always)
public func cross(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
    return lhs.x * rhs.y - lhs.y * rhs.x
}

@inlinable
@inline(__always)
public prefix func +(val: CGPoint) -> CGPoint {
    return val
}
@inlinable
@inline(__always)
public prefix func -(val: CGPoint) -> CGPoint {
    return CGPoint(x: -val.x, y: -val.y)
}
@inlinable
@inline(__always)
public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
@inlinable
@inline(__always)
public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@inlinable
@inline(__always)
public func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}
@inlinable
@inline(__always)
public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x *= rhs
    lhs.y *= rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x /= rhs
    lhs.y /= rhs
}
@inlinable
@inline(__always)
public func += (lhs: inout CGPoint, rhs: CGPoint) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
@inlinable
@inline(__always)
public func -= (lhs: inout CGPoint, rhs: CGPoint) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

