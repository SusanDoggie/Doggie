//
//  SDTransform.swift
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

import Foundation

///
/// Transformation Matrix:
///
///     ⎛ a d 0 ⎞
///     ⎜ b e 0 ⎟
///     ⎝ c f 1 ⎠
///
public struct SDTransform {
    
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double
    
    @_inlineable
    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
    }
}

extension SDTransform : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "SDTransform(a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f))"
    }
}

extension SDTransform : Hashable {
    
    @_inlineable
    public var hashValue: Int {
        return hash_combine(seed: 0, a, b, c, d, e, f)
    }
}

extension SDTransform {
    
    @_inlineable
    public var determinant : Double {
        return a * e - b * d
    }
}

extension SDTransform {
    
    @_inlineable
    public init?(from p0: Point, _ p1: Point, _ p2: Point, to q0: Point, _ q1: Point, _ q2: Point) {
        
        func solve(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double, _ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double)? {
            
            let _det = a * (d - f) + b * (e - c) + c * f - d * e
            
            if _det == 0 {
                return nil
            }
            
            let det = 1 / _det
            
            let _a = d - f
            let _b = f - b
            let _c = b - d
            let _d = e - c
            let _e = a - e
            let _f = c - a
            let _g = c * f - d * e
            let _h = b * e - a * f
            let _i = a * d - b * c
            
            return ((x * _a + y * _b + z * _c) * det, (x * _d + y * _e + z * _f) * det, (x * _g + y * _h + z * _i) * det)
        }
        
        guard let (a, b, c) = solve(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, q0.x, q1.x, q2.x) else { return nil }
        guard let (d, e, f) = solve(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, q0.y, q1.y, q2.y) else { return nil }
        
        self.init(a: a, b: b, c: c, d: d, e: e, f: f)
    }
}

extension SDTransform {
    
    @_inlineable
    public var inverse : SDTransform {
        let det = self.determinant
        return SDTransform(a: e / det, b: -b / det, c: (b * f - c * e) / det, d: -d / det, e: a / det, f: (c * d - a * f) / det)
    }
}

extension SDTransform {
    
    @_inlineable
    public var tx: Double {
        get {
            return c
        }
        set {
            c = newValue
        }
    }
    
    @_inlineable
    public var ty: Double {
        get {
            return f
        }
        set {
            f = newValue
        }
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @_inlineable
    public static var identity : SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: 0, e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 ⎟
    ///     ⎝    0      0    1 ⎠
    ///
    @_inlineable
    public static func rotate(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: cos(angle), b: -sin(angle), c: 0,
                           d: sin(angle), e: cos(angle), f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛   1    0 0 ⎞
    ///     ⎜ tan(a) 1 0 ⎟
    ///     ⎝   0    0 1 ⎠
    ///
    @_inlineable
    public static func skewX(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: 1, b: tan(angle), c: 0,
                           d: 0, e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 tan(a) 0 ⎞
    ///     ⎜ 0   1    0 ⎟
    ///     ⎝ 0   0    1 ⎠
    ///
    @_inlineable
    public static func skewY(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: tan(angle), e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @_inlineable
    public static func scale(_ scale: Double) -> SDTransform {
        
        return SDTransform(a: scale, b: 0, c: 0,
                           d: 0, e: scale, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @_inlineable
    public static func scale(x: Double = 1, y: Double = 1) -> SDTransform {
        
        return SDTransform(a: x, b: 0, c: 0,
                           d: 0, e: y, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    @_inlineable
    public static func translate(x: Double = 0, y: Double = 0) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: x,
                           d: 0, e: 1, f: y)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    @_inlineable
    public static func reflectX(_ x: Double = 0) -> SDTransform {
        
        return SDTransform(a: -1, b: 0, c: 2 * x,
                           d: 0, e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    @_inlineable
    public static func reflectY(_ y: Double = 0) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: 0, e: -1, f: 2 * y)
    }
}

extension SDTransform : Multiplicative {
    
}

@_inlineable
public func ==(lhs: SDTransform, rhs: SDTransform) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d && lhs.e == rhs.e && lhs.f == rhs.f
}
@_inlineable
public func !=(lhs: SDTransform, rhs: SDTransform) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d || lhs.e != rhs.e || lhs.f != rhs.f
}

@_inlineable
public func *(lhs: SDTransform, rhs: SDTransform) -> SDTransform {
    let a = lhs.a * rhs.a + lhs.d * rhs.b
    let b = lhs.b * rhs.a + lhs.e * rhs.b
    let c = lhs.c * rhs.a + lhs.f * rhs.b + rhs.c
    let d = lhs.a * rhs.d + lhs.d * rhs.e
    let e = lhs.b * rhs.d + lhs.e * rhs.e
    let f = lhs.c * rhs.d + lhs.f * rhs.e + rhs.f
    return SDTransform(a: a, b: b, c: c, d: d, e: e, f: f)
}

@_inlineable
public func *=(lhs: inout SDTransform, rhs: SDTransform) {
    lhs = lhs * rhs
}

@_inlineable
public func *(lhs: Point, rhs: SDTransform) -> Point {
    return Point(x: lhs.x * rhs.a + lhs.y * rhs.b + rhs.c, y: lhs.x * rhs.d + lhs.y * rhs.e + rhs.f)
}

@_inlineable
public func *=(lhs: inout Point, rhs: SDTransform) {
    lhs = lhs * rhs
}
