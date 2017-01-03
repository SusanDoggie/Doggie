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
public protocol SDTransformProtocol {
    
    var a: Double { get }
    var b: Double { get }
    var c: Double { get }
    var d: Double { get }
    var e: Double { get }
    var f: Double { get }
    var inverse : Self { get }
    
    static func == (_: Self, _: Self) -> Bool
    static func != (_: Self, _: Self) -> Bool
}

extension SDTransformProtocol {
    
    public var tx: Double {
        return c
    }
    
    public var ty: Double {
        return f
    }
}

///
/// Transformation Matrix:
///
///     ⎛ a d 0 ⎞
///     ⎜ b e 0 ⎟
///     ⎝ c f 1 ⎠
///
public struct SDTransform: SDTransformProtocol {
    
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double
    
    public init<T: SDTransformProtocol>(_ m: T) {
        self.a = m.a
        self.b = m.b
        self.c = m.c
        self.d = m.d
        self.e = m.e
        self.f = m.f
    }
    
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
    public var description: String {
        return "{a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f)}"
    }
}

extension SDTransform {
    
    public var inverse : SDTransform {
        let det = a * e - b * d
        return SDTransform(a: e / det, b: -b / det, c: (b * f - c * e) / det, d: -d / det, e: a / det, f: (c * d - a * f) / det)
    }
}

extension SDTransform {
    
    public var tx: Double {
        get {
            return c
        }
        set {
            c = newValue
        }
    }
    
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
    public struct Identity: SDTransformProtocol {
        
        public init() {
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 ⎟
    ///     ⎝    0      0    1 ⎠
    ///
    public struct Rotate: SDTransformProtocol {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛   1    0 0 ⎞
    ///     ⎜ tan(a) 1 0 ⎟
    ///     ⎝   0    0 1 ⎠
    ///
    public struct SkewX: SDTransformProtocol {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 tan(a) 0 ⎞
    ///     ⎜ 0   1    0 ⎟
    ///     ⎝ 0   0    1 ⎠
    ///
    public struct SkewY: SDTransformProtocol {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    public struct Scale: SDTransformProtocol {
        
        public var x: Double
        public var y: Double
        
        public init(_ scale: Double) {
            self.x = scale
            self.y = scale
        }
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    public struct Translate: SDTransformProtocol {
        
        public var x: Double
        public var y: Double
        
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    public struct ReflectX: SDTransformProtocol {
        
        public var x: Double
        
        public init() {
            self.x = 0
        }
        public init(_ x: Double) {
            self.x = x
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    public struct ReflectY: SDTransformProtocol {
        
        public var y: Double
        
        public init() {
            self.y = 0
        }
        public init(_ y: Double) {
            self.y = y
        }
    }
}

extension SDTransform.Identity {
    
    public var a: Double {
        return 1
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return 1
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.Identity {
        return self
    }
}

public func == (_: SDTransform.Identity, _: SDTransform.Identity) -> Bool {
    return true
}
public func != (_: SDTransform.Identity, _: SDTransform.Identity) -> Bool {
    return false
}

public func * (_: SDTransform.Identity, _: SDTransform.Identity) -> SDTransform.Identity {
    return SDTransform.Identity()
}

public func * <T: SDTransformProtocol>(_: SDTransform.Identity, rhs: T) -> T {
    return rhs
}

public func * <S: SDTransformProtocol>(lhs: S, _: SDTransform.Identity) -> S {
    return lhs
}

public func *= <S: SDTransformProtocol>(_: inout S, _: SDTransform.Identity) {
}

extension SDTransform.Rotate {
    
    public var a: Double {
        return cos(angle)
    }
    public var b: Double {
        return -sin(angle)
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return sin(angle)
    }
    public var e: Double {
        return cos(angle)
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.Rotate {
        return SDTransform.Rotate(-angle)
    }
}

public func == (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> Bool {
    return lhs.angle == rhs.angle
}
public func != (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> Bool {
    return lhs.angle != rhs.angle
}

public func * (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> SDTransform.Rotate {
    return SDTransform.Rotate(lhs.angle + rhs.angle)
}

public func *= (lhs: inout SDTransform.Rotate, rhs: SDTransform.Rotate) {
    return lhs.angle += rhs.angle
}

extension SDTransform.SkewX {
    
    public var a: Double {
        return 1
    }
    public var b: Double {
        return tan(angle)
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return 1
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.SkewX {
        return SDTransform.SkewX(-angle)
    }
}

public func == (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> Bool {
    return lhs.angle == rhs.angle
}
public func != (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> Bool {
    return lhs.angle != rhs.angle
}

public func * (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> SDTransform.SkewX {
    return SDTransform.SkewX(atan(tan(lhs.angle) + tan(rhs.angle)))
}

public func *= (lhs: inout SDTransform.SkewX, rhs: SDTransform.SkewX) {
    return lhs.angle = atan(tan(lhs.angle) + tan(rhs.angle))
}

extension SDTransform.SkewY {
    
    public var a: Double {
        return 1
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return tan(angle)
    }
    public var e: Double {
        return 1
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.SkewY {
        return SDTransform.SkewY(-angle)
    }
}

public func == (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> Bool {
    return lhs.angle == rhs.angle
}
public func != (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> Bool {
    return lhs.angle != rhs.angle
}

public func * (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> SDTransform.SkewY {
    return SDTransform.SkewY(atan(tan(lhs.angle) + tan(rhs.angle)))
}

public func *= (lhs: inout SDTransform.SkewY, rhs: SDTransform.SkewY) {
    return lhs.angle = atan(tan(lhs.angle) + tan(rhs.angle))
}

extension SDTransform.Scale {
    
    public var a: Double {
        return x
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return y
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.Scale {
        return SDTransform.Scale(x: 1 / x, y: 1 / y)
    }
}

public func == (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func != (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}

public func * (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> SDTransform.Scale {
    return SDTransform.Scale(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

public func *= (lhs: inout SDTransform.Scale, rhs: SDTransform.Scale) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
}

extension SDTransform.Translate {
    
    public var a: Double {
        return 1
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return x
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return 1
    }
    public var f: Double {
        return y
    }
    
    public var inverse : SDTransform.Translate {
        return SDTransform.Translate(x: -x, y: -y)
    }
}

extension SDTransform.Translate {
    
    public var tx: Double {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    
    public var ty: Double {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
}

public func == (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func != (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}

public func * (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> SDTransform.Translate {
    return SDTransform.Translate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func *= (lhs: inout SDTransform.Translate, rhs: SDTransform.Translate) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

extension SDTransform.ReflectX {
    
    public var a: Double {
        return -1
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return 2 * x
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return 1
    }
    public var f: Double {
        return 0
    }
    
    public var inverse : SDTransform.ReflectX {
        return self
    }
}

public func == (lhs: SDTransform.ReflectX, rhs: SDTransform.ReflectX) -> Bool {
    return lhs.x == rhs.x
}
public func != (lhs: SDTransform.ReflectX, rhs: SDTransform.ReflectX) -> Bool {
    return lhs.x != rhs.x
}

extension SDTransform.ReflectY {
    
    public var a: Double {
        return 1
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return 0
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return -1
    }
    public var f: Double {
        return 2 * y
    }
    
    public var inverse : SDTransform.ReflectY {
        return self
    }
}

public func == (lhs: SDTransform.ReflectY, rhs: SDTransform.ReflectY) -> Bool {
    return lhs.y == rhs.y
}
public func != (lhs: SDTransform.ReflectY, rhs: SDTransform.ReflectY) -> Bool {
    return lhs.y != rhs.y
}

public func == <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d && lhs.e == rhs.e && lhs.f == rhs.f
}
public func != <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d || lhs.e != rhs.e || lhs.f != rhs.f
}

public func * <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> SDTransform {
    let a = lhs.a * rhs.a + lhs.d * rhs.b
    let b = lhs.b * rhs.a + lhs.e * rhs.b
    let c = lhs.c * rhs.a + lhs.f * rhs.b + rhs.c
    let d = lhs.a * rhs.d + lhs.d * rhs.e
    let e = lhs.b * rhs.d + lhs.e * rhs.e
    let f = lhs.c * rhs.d + lhs.f * rhs.e + rhs.f
    return SDTransform(a: a, b: b, c: c, d: d, e: e, f: f)
}

public func *= <T: SDTransformProtocol>(lhs: inout SDTransform, rhs: T) {
    lhs = lhs * rhs
}

public func * <T: SDTransformProtocol>(lhs: Point, rhs: T) -> Point {
    return Point(x: lhs.x * rhs.a + lhs.y * rhs.b + rhs.c, y: lhs.x * rhs.d + lhs.y * rhs.e + rhs.f)
}

public func *= <T: SDTransformProtocol>(lhs: inout Point, rhs: T) {
    lhs = lhs * rhs
}
