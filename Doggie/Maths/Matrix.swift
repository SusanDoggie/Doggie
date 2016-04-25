//
//  Matrix.swift
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

///
/// Transformation Matrix:
///
///     ⎛ a e i 0 ⎞
///     ⎜ b f j 0 ⎟
///     ⎜ c g k 0 ⎟
///     ⎝ d h l 1 ⎠
///
public protocol MatrixType {
    
    var a: Double { get }
    var b: Double { get }
    var c: Double { get }
    var d: Double { get }
    var e: Double { get }
    var f: Double { get }
    var g: Double { get }
    var h: Double { get }
    var i: Double { get }
    var j: Double { get }
    var k: Double { get }
    var l: Double { get }
    var inverse : Self { get }
}

extension MatrixType {
    
    @_transparent
    public var tx: Double {
        return d
    }
    
    @_transparent
    public var ty: Double {
        return h
    }
    
    @_transparent
    public var tz: Double {
        return l
    }
}

///
/// Transformation Matrix:
///
///     ⎛ a e i 0 ⎞
///     ⎜ b f j 0 ⎟
///     ⎜ c g k 0 ⎟
///     ⎝ d h l 1 ⎠
///
public struct Matrix: MatrixType {
    
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double
    public var g: Double
    public var h: Double
    public var i: Double
    public var j: Double
    public var k: Double
    public var l: Double
    
    public init<T: MatrixType>(_ m: T) {
        self.a = m.a
        self.b = m.b
        self.c = m.c
        self.d = m.d
        self.e = m.e
        self.f = m.f
        self.g = m.g
        self.h = m.h
        self.i = m.i
        self.j = m.j
        self.k = m.k
        self.l = m.l
    }
    
    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double, g: Double, h: Double, i: Double, j: Double, k: Double, l: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
        self.g = g
        self.h = h
        self.i = i
        self.j = j
        self.k = k
        self.l = l
    }
}

extension Matrix : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "{a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f), g: \(g), h: \(h), i: \(i), j: \(j), k: \(k), l: \(l)}"
    }
    public var debugDescription: String {
        return "{a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f), g: \(g), h: \(h), i: \(i), j: \(j), k: \(k), l: \(l)}"
    }
}

extension Matrix {
    
    @_transparent
    public var inverse : Matrix {
        let _a = g * j - f * k
        let _b = c * j - b * k
        let _c = c * f - b * g
        let _d = _a * d - _b * h + _c * l
        let _e = g * i - e * k
        let _f = c * i - a * k
        let _g = c * e - a * g
        let _h = _e * d - _f * h + _g * l
        let _i = f * i - e * j
        let _j = b * i - a * j
        let _k = b * e - a * f
        let _l = _i * d - _j * h + _k * l
        let det = _c * i - _g * j + _k * k
        return Matrix(
            a:  _a / det, b: -_b / det, c:  _c / det, d: -_d / det,
            e: -_e / det, f:  _f / det, g: -_g / det, h:  _h / det,
            i:  _i / det, j: -_j / det, k:  _k / det, l: -_l / det
        )
    }
}

extension Matrix {
    
    @_transparent
    public var tx: Double {
        get {
            return d
        }
        set {
            d = newValue
        }
    }
    
    @_transparent
    public var ty: Double {
        get {
            return h
        }
        set {
            h = newValue
        }
    }
    
    @_transparent
    public var tz: Double {
        get {
            return l
        }
        set {
            l = newValue
        }
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    public struct Identity: MatrixType {
        
        public init() {
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1    0      0    0 ⎞
    ///     ⎜ 0  cos(a) sin(a) 0 ⎟
    ///     ⎜ 0 -sin(a) cos(a) 0 ⎟
    ///     ⎝ 0    0      0    1 ⎠
    ///
    public struct RotateX: MatrixType {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ cos(a) 0 -sin(a) 0 ⎞
    ///     ⎜   0    1    0    0 ⎟
    ///     ⎜ sin(a) 0  cos(a) 0 ⎟
    ///     ⎝   0    0    0    1 ⎠
    ///
    public struct RotateY: MatrixType {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 0 ⎟
    ///     ⎜    0      0    1 0 ⎟
    ///     ⎝    0      0    0 1 ⎠
    ///
    public struct RotateZ: MatrixType {
        
        public var angle: Double
        
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    public struct Scale: MatrixType {
        
        public var x: Double
        public var y: Double
        public var z: Double
        
        public init(ratio: Double) {
            if ratio > 1 {
                self.x = 1 / ratio
                self.y = 1
            } else {
                self.x = 1
                self.y = ratio
            }
            self.z = 1
        }
        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    public struct Translate: MatrixType {
        
        public var x: Double
        public var y: Double
        public var z: Double
        
        public init(x: Double, y: Double, z: Double) {
            self.x = x
            self.y = y
            self.z = z
        }
    }
    
    @warn_unused_result
    public static func Rotate(roll x: Double, pitch y: Double, yaw z: Double) -> Matrix {
        return RotateX(x) * RotateY(y) * RotateZ(z)
    }
    @warn_unused_result
    public static func Rotate(radian: Double, x: Double, y: Double, z: Double) -> Matrix {
        let _abs = sqrt(x * x + y * y + z * z)
        let vx = x / _abs
        let vy = y / _abs
        let vz = z / _abs
        let _cos = cos(radian)
        let _cosp = 1.0 - _cos
        let _sin = sin(radian)
        return Matrix(
            a: _cos + _cosp * vx * vx,
            b: _cosp * vx * vy - vz * _sin,
            c: _cosp * vx * vz + vy * _sin,
            d: 0.0,
            e: _cosp * vy * vx + vz * _sin,
            f: _cos + _cosp * vy * vy,
            g: _cosp * vy * vz - vx * _sin,
            h: 0.0,
            i: _cosp * vz * vx - vy * _sin,
            j: _cosp * vz * vy + vx * _sin,
            k: _cos + _cosp * vz * vz,
            l: 0.0
        )
    }
    
    @warn_unused_result
    public static func CameraTransform(position tx: Double, _ ty: Double, _ tz: Double, rotate ax: Double, _ ay: Double, _ az: Double) -> Matrix {
        return Translate(x: -tx, y: -ty, z: -tz) * RotateZ(-az) * RotateY(-ay) * RotateX(-ax)
    }
}

@warn_unused_result
public func PerspectiveProjectMatrix(alpha alpha: Double, aspect: Double, nearZ: Double, farZ: Double) -> [Double] {
    let cotan = 1.0 / tan(alpha * 0.5)
    return [
        cotan / aspect, 0.0, 0.0, 0.0,
        0.0, cotan, 0.0, 0.0,
        0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), (2.0 * farZ * nearZ) / (nearZ - farZ),
        0.0, 0.0, -1.0, 0.0
    ]
}

extension Matrix.Identity {
    
    @_transparent
    public var a: Double {
        return 1
    }
    @_transparent
    public var b: Double {
        return 0
    }
    @_transparent
    public var c: Double {
        return 0
    }
    @_transparent
    public var d: Double {
        return 0
    }
    @_transparent
    public var e: Double {
        return 0
    }
    @_transparent
    public var f: Double {
        return 1
    }
    @_transparent
    public var g: Double {
        return 0
    }
    @_transparent
    public var h: Double {
        return 0
    }
    @_transparent
    public var i: Double {
        return 0
    }
    @_transparent
    public var j: Double {
        return 0
    }
    @_transparent
    public var k: Double {
        return 1
    }
    @_transparent
    public var l: Double {
        return 0
    }
    
    @_transparent
    public var inverse : Matrix.Identity {
        return self
    }
}

@warn_unused_result
@_transparent
public func == (_: Matrix.Identity, _: Matrix.Identity) -> Bool {
    return true
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.Identity, rhs: Matrix.Identity) -> Bool {
    return false
}

@warn_unused_result
@_transparent
public func * (_: Matrix.Identity, _: Matrix.Identity) -> Matrix.Identity {
    return Matrix.Identity()
}

@warn_unused_result
@_transparent
public func * <T: MatrixType>(_: Matrix.Identity, rhs: T) -> T {
    return rhs
}

@warn_unused_result
@_transparent
public func * <S: MatrixType>(lhs: S, _: Matrix.Identity) -> S {
    return lhs
}

@_transparent
public func *= <S: MatrixType>(inout _: S, _: Matrix.Identity) {
}

extension Matrix.RotateX {
    
    @_transparent
    public var a: Double {
        return 1
    }
    @_transparent
    public var b: Double {
        return 0
    }
    @_transparent
    public var c: Double {
        return 0
    }
    @_transparent
    public var d: Double {
        return 0
    }
    @_transparent
    public var e: Double {
        return 0
    }
    @_transparent
    public var f: Double {
        return cos(angle)
    }
    @_transparent
    public var g: Double {
        return -sin(angle)
    }
    @_transparent
    public var h: Double {
        return 0
    }
    @_transparent
    public var i: Double {
        return 0
    }
    @_transparent
    public var j: Double {
        return sin(angle)
    }
    @_transparent
    public var k: Double {
        return cos(angle)
    }
    @_transparent
    public var l: Double {
        return 0
    }
    
    @_transparent
    public var inverse : Matrix.RotateX {
        return Matrix.RotateX(-angle)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
@_transparent
public func * (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Matrix.RotateX {
    return Matrix.RotateX(lhs.angle + rhs.angle)
}

@_transparent
public func *= (inout lhs: Matrix.RotateX, rhs: Matrix.RotateX) {
    return lhs.angle += rhs.angle
}

extension Matrix.RotateY {
    
    @_transparent
    public var a: Double {
        return cos(angle)
    }
    @_transparent
    public var b: Double {
        return 0
    }
    @_transparent
    public var c: Double {
        return sin(angle)
    }
    @_transparent
    public var d: Double {
        return 0
    }
    @_transparent
    public var e: Double {
        return 0
    }
    @_transparent
    public var f: Double {
        return 1
    }
    @_transparent
    public var g: Double {
        return 0
    }
    @_transparent
    public var h: Double {
        return 0
    }
    @_transparent
    public var i: Double {
        return -sin(angle)
    }
    @_transparent
    public var j: Double {
        return 0
    }
    @_transparent
    public var k: Double {
        return cos(angle)
    }
    @_transparent
    public var l: Double {
        return 0
    }
    
    @_transparent
    public var inverse : Matrix.RotateY {
        return Matrix.RotateY(-angle)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
@_transparent
public func * (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Matrix.RotateY {
    return Matrix.RotateY(lhs.angle + rhs.angle)
}

@_transparent
public func *= (inout lhs: Matrix.RotateY, rhs: Matrix.RotateY) {
    return lhs.angle += rhs.angle
}

extension Matrix.RotateZ {
    
    @_transparent
    public var a: Double {
        return cos(angle)
    }
    @_transparent
    public var b: Double {
        return -sin(angle)
    }
    @_transparent
    public var c: Double {
        return 0
    }
    @_transparent
    public var d: Double {
        return 0
    }
    @_transparent
    public var e: Double {
        return sin(angle)
    }
    @_transparent
    public var f: Double {
        return cos(angle)
    }
    @_transparent
    public var g: Double {
        return 0
    }
    @_transparent
    public var h: Double {
        return 0
    }
    @_transparent
    public var i: Double {
        return 0
    }
    @_transparent
    public var j: Double {
        return 0
    }
    @_transparent
    public var k: Double {
        return 1
    }
    @_transparent
    public var l: Double {
        return 0
    }
    
    @_transparent
    public var inverse : Matrix.RotateZ {
        return Matrix.RotateZ(-angle)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
@_transparent
public func * (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Matrix.RotateZ {
    return Matrix.RotateZ(lhs.angle + rhs.angle)
}

@_transparent
public func *= (inout lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) {
    return lhs.angle += rhs.angle
}

extension Matrix.Scale {
    
    @_transparent
    public var a: Double {
        return x
    }
    @_transparent
    public var b: Double {
        return 0
    }
    @_transparent
    public var c: Double {
        return 0
    }
    @_transparent
    public var d: Double {
        return 0
    }
    @_transparent
    public var e: Double {
        return 0
    }
    @_transparent
    public var f: Double {
        return y
    }
    @_transparent
    public var g: Double {
        return 0
    }
    @_transparent
    public var h: Double {
        return 0
    }
    @_transparent
    public var i: Double {
        return 0
    }
    @_transparent
    public var j: Double {
        return 0
    }
    @_transparent
    public var k: Double {
        return z
    }
    @_transparent
    public var l: Double {
        return 0
    }
    
    @_transparent
    public var inverse : Matrix.Scale {
        return Matrix.Scale(x: 1 / x, y: 1 / y, z: 1 / z)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}

@warn_unused_result
@_transparent
public func * (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Matrix.Scale {
    return Matrix.Scale(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
}

@_transparent
public func *= (inout lhs: Matrix.Scale, rhs: Matrix.Scale) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
    lhs.z *= rhs.z
}

extension Matrix.Translate {
    
    @_transparent
    public var a: Double {
        return 1
    }
    @_transparent
    public var b: Double {
        return 0
    }
    @_transparent
    public var c: Double {
        return 0
    }
    @_transparent
    public var d: Double {
        return x
    }
    @_transparent
    public var e: Double {
        return 0
    }
    @_transparent
    public var f: Double {
        return 1
    }
    @_transparent
    public var g: Double {
        return 0
    }
    @_transparent
    public var h: Double {
        return y
    }
    @_transparent
    public var i: Double {
        return 0
    }
    @_transparent
    public var j: Double {
        return 0
    }
    @_transparent
    public var k: Double {
        return 1
    }
    @_transparent
    public var l: Double {
        return z
    }
    
    @_transparent
    public var inverse : Matrix.Translate {
        return Matrix.Translate(x: -x, y: -y, z: -z)
    }
}

@warn_unused_result
@_transparent
public func == (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@warn_unused_result
@_transparent
public func != (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}

@warn_unused_result
@_transparent
public func * (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Matrix.Translate {
    return Matrix.Translate(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

@_transparent
public func *= (inout lhs: Matrix.Translate, rhs: Matrix.Translate) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

@warn_unused_result
@_transparent
public func == <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d
        && lhs.e == rhs.e && lhs.f == rhs.f && lhs.g == rhs.g && lhs.h == rhs.h
        && lhs.i == rhs.i && lhs.j == rhs.j && lhs.k == rhs.k && lhs.l == rhs.l
}
@warn_unused_result
@_transparent
public func != <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d
        || lhs.e != rhs.e || lhs.f != rhs.f || lhs.g != rhs.g || lhs.h != rhs.h
        || lhs.i != rhs.i || lhs.j != rhs.j || lhs.k != rhs.k || lhs.l != rhs.l
}

@warn_unused_result
@_transparent
public func * <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Matrix {
    let a = rhs.a * lhs.a + rhs.b * lhs.e + rhs.c * lhs.i
    let b = rhs.a * lhs.b + rhs.b * lhs.f + rhs.c * lhs.j
    let c = rhs.a * lhs.c + rhs.b * lhs.g + rhs.c * lhs.k
    let d = rhs.a * lhs.d + rhs.b * lhs.h + rhs.c * lhs.l + rhs.d
    let e = rhs.e * lhs.a + rhs.f * lhs.e + rhs.g * lhs.i
    let f = rhs.e * lhs.b + rhs.f * lhs.f + rhs.g * lhs.j
    let g = rhs.e * lhs.c + rhs.f * lhs.g + rhs.g * lhs.k
    let h = rhs.e * lhs.d + rhs.f * lhs.h + rhs.g * lhs.l + rhs.h
    let i = rhs.i * lhs.a + rhs.j * lhs.e + rhs.k * lhs.i
    let j = rhs.i * lhs.b + rhs.j * lhs.f + rhs.k * lhs.j
    let k = rhs.i * lhs.c + rhs.j * lhs.g + rhs.k * lhs.k
    let l = rhs.i * lhs.d + rhs.j * lhs.h + rhs.k * lhs.l + rhs.l
    return Matrix(a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h, i: i, j: j, k: k, l: l)
}

@_transparent
public func *= <T: MatrixType>(inout lhs: Matrix, rhs: T) {
    lhs = lhs * rhs
}

@warn_unused_result
@_transparent
public func * <T: MatrixType>(lhs: Vector, rhs: T) -> Vector {
    return Vector(x: rhs.a * lhs.x + rhs.b * lhs.y + rhs.c * lhs.z + rhs.d, y: rhs.e * lhs.x + rhs.f * lhs.y + rhs.g * lhs.z + rhs.h, z: rhs.i * lhs.x + rhs.j * lhs.y + rhs.k * lhs.z + rhs.l)
}
