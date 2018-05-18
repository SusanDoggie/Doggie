//
//  Ellipse.swift
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

public struct Radius : Hashable {
    
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

extension Radius: CustomStringConvertible {
    
    @_transparent
    public var description: String {
        return "Radius(x: \(x), y: \(y))"
    }
}

extension Radius : Codable {
    
    @_transparent
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.x = try container.decode(Double.self)
        self.y = try container.decode(Double.self)
    }
    
    @_transparent
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }
}

@_inlineable
public func Ellipse(_ t: Double, _ p: Point, _ r: Radius) -> Point {
    return Point(x: r.x * cos(t) + p.x, y: r.y * sin(t) + p.y)
}

@_inlineable
public func EllipseRadius(_ p0: Point, _ p1: Point, _ r: Radius, _ rotate: Double) -> Radius {
    let _p = p1 - p0
    let _tx = _p.x * cos(rotate) + _p.y * sin(rotate)
    let _ty = _p.y * cos(rotate) - _p.x * sin(rotate)
    let _atan = atan2(_ty / r.y, _tx / r.x)
    return Radius(x: _tx / (2 * cos(_atan)), y: _ty / (2 * sin(_atan)))
}

@_inlineable
public func EllipseCenter(_ r: Radius, _ rotate: Double, _ a: Point, _ b: Point) -> [Point] {
    
    let _sin = sin(rotate)
    let _cos = cos(rotate)
    
    let ax = a.x * _cos + a.y * _sin
    let ay = a.y * _cos - a.x * _sin
    let bx = b.x * _cos + b.y * _sin
    let by = b.y * _cos - b.x * _sin
    
    let dx = (ax - bx) / r.x
    let dy = (ay - by) / r.y
    let d = dx * dx + dy * dy
    
    let _x = 0.5 * (ax + bx)
    let _y = 0.5 * (ay + by)
    
    if d == 4 {
        return [Point(x: _x * _cos - _y * _sin, y: _x * _sin + _y * _cos)]
    } else if d < 4 {
        let _t = sqrt((1 - d * 0.25) / d)
        
        let cx1 = _x + _t * dy * r.x
        let cy1 = _y - _t * dx * r.y
        let cx2 = _x - _t * dy * r.x
        let cy2 = _y + _t * dx * r.y
        
        return [Point(x: cx1 * _cos - cy1 * _sin, y: cx1 * _sin + cy1 * _cos),
                Point(x: cx2 * _cos - cy2 * _sin, y: cx2 * _sin + cy2 * _cos)]
    }
    
    return []
}

///
/// :param: rx radius of ellipse in x-axis
/// :param: ry radius of ellipse in y-axis
///
/// :param: a value of 'a' in matrix if parallel to x-axis or value of 'd' in matrix if parallel to y-axis.
/// :param: b value of 'b' in matrix if parallel to x-axis or value of 'e' in matrix if parallel to y-axis.
///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ A cos(t) ⎞
///     ⎜ d e f ⎟ ⎜ B sin(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝    1     ⎠
///
@_inlineable
public func EllipseStationary(_ r: Radius, _ a: Double, _ b: Double) -> Double {
    return atan2(r.y * b, r.x * a)
}

///
/// Transformation Matrix:
///
///     ⎛ a b c ⎞ ⎛ A cos(t) ⎞
///     ⎜ d e f ⎟ ⎜ B sin(t) ⎟
///     ⎝ 0 0 1 ⎠ ⎝    1     ⎠
///
@_inlineable
public func EllipseBound(_ center: Point, _ r: Radius, _ matrix: SDTransform) -> Rect {
    
    let t1 = EllipseStationary(r, matrix.a, matrix.b)
    let t2 = EllipseStationary(r, matrix.d, matrix.e)
    
    let p0 = Ellipse(t1, center, r)
    let p1 = Ellipse(t1 + Double.pi, center, r)
    let p2 = Ellipse(t2, center, r)
    let p3 = Ellipse(t2 + Double.pi, center, r)
    
    let _p0 = matrix.a * p0.x + matrix.b * p0.y
    let _p1 = matrix.a * p1.x + matrix.b * p1.y
    let _p2 = matrix.d * p2.x + matrix.e * p2.y
    let _p3 = matrix.d * p3.x + matrix.e * p3.y
    
    let minX = min(_p0, _p1)
    let minY = min(_p2, _p3)
    let maxX = max(_p0, _p1)
    let maxY = max(_p2, _p3)
    
    return Rect(x: minX + matrix.c, y: minY + matrix.f, width: maxX - minX, height: maxY - minY)
}

// MARK: Area

@_inlineable
public func ArcSignedArea(_ startAngle: Double, _ endAngle: Double, _ center: Point, _ radius: Radius) -> Double {
    
    let diffAngle = endAngle - startAngle
    let sin1 = sin(startAngle)
    let cos1 = cos(startAngle)
    let sin2 = sin(endAngle)
    let cos2 = cos(endAngle)
    let _sin = sin2 - sin1
    let _cos = cos2 - cos1
    return 0.5 * (radius.x * radius.y * diffAngle - radius.x * center.y * _cos + radius.y * center.x * _sin)
}
