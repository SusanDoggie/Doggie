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
///     ⎛ a b c d ⎞
///     ⎜ e f g h ⎟
///     ⎜ i j k l ⎟
///     ⎝ 0 0 0 1 ⎠
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

///
/// Transformation Matrix:
///
///     ⎛ a b c d ⎞
///     ⎜ e f g h ⎟
///     ⎜ i j k l ⎟
///     ⎝ 0 0 0 1 ⎠
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
    ///     ⎛ 1   0       0    0 ⎞
    ///     ⎜ 0 cos(a) -sin(a) 0 ⎟
    ///     ⎜ 0 sin(a)  cos(a) 0 ⎟
    ///     ⎝ 0   0       0    1 ⎠
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
    ///     ⎛  cos(a) 0 sin(a) 0 ⎞
    ///     ⎜    0    1   0    0 ⎟
    ///     ⎜ -sin(a) 0 cos(a) 0 ⎟
    ///     ⎝    0    0   0    1 ⎠
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
    ///     ⎛ cos(a) -sin(a) 0 0 ⎞
    ///     ⎜ sin(a)  cos(a) 0 0 ⎟
    ///     ⎜   0       0    1 0 ⎟
    ///     ⎝   0       0    0 1 ⎠
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
    ///     ⎛ 1 0 0 x ⎞
    ///     ⎜ 0 1 0 y ⎟
    ///     ⎜ 0 0 1 z ⎟
    ///     ⎝ 0 0 0 1 ⎠
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
        return RotateZ(z) * RotateY(y) * RotateX(x)
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
        return RotateX(-ax) * RotateY(-ay) * RotateZ(-az) * Translate(x: -tx, y: -ty, z: -tz)
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
        return 0
    }
    public var f: Double {
        return 1
    }
    public var g: Double {
        return 0
    }
    public var h: Double {
        return 0
    }
    public var i: Double {
        return 0
    }
    public var j: Double {
        return 0
    }
    public var k: Double {
        return 1
    }
    public var l: Double {
        return 0
    }
    
    public var inverse : Matrix.Identity {
        return self
    }
}

@warn_unused_result
public func == (_: Matrix.Identity, _: Matrix.Identity) -> Bool {
    return true
}
@warn_unused_result
public func != (lhs: Matrix.Identity, rhs: Matrix.Identity) -> Bool {
    return false
}

@warn_unused_result
public func * (_: Matrix.Identity, _: Matrix.Identity) -> Matrix.Identity {
    return Matrix.Identity()
}

@warn_unused_result
public func * <T: MatrixType>(_: Matrix.Identity, rhs: T) -> T {
    return rhs
}

@warn_unused_result
public func * <S: MatrixType>(lhs: S, _: Matrix.Identity) -> S {
    return lhs
}

public func *= <S: MatrixType>(inout _: S, _: Matrix.Identity) {
}

extension Matrix.RotateX {
    
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
        return 0
    }
    public var f: Double {
        return cos(angle)
    }
    public var g: Double {
        return -sin(angle)
    }
    public var h: Double {
        return 0
    }
    public var i: Double {
        return 0
    }
    public var j: Double {
        return sin(angle)
    }
    public var k: Double {
        return cos(angle)
    }
    public var l: Double {
        return 0
    }
    
    public var inverse : Matrix.RotateX {
        return Matrix.RotateX(-angle)
    }
}

@warn_unused_result
public func == (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
public func != (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
public func * (lhs: Matrix.RotateX, rhs: Matrix.RotateX) -> Matrix.RotateX {
    return Matrix.RotateX(lhs.angle + rhs.angle)
}

public func *= (inout lhs: Matrix.RotateX, rhs: Matrix.RotateX) {
    return lhs.angle += rhs.angle
}

extension Matrix.RotateY {
    
    public var a: Double {
        return cos(angle)
    }
    public var b: Double {
        return 0
    }
    public var c: Double {
        return sin(angle)
    }
    public var d: Double {
        return 0
    }
    public var e: Double {
        return 0
    }
    public var f: Double {
        return 1
    }
    public var g: Double {
        return 0
    }
    public var h: Double {
        return 0
    }
    public var i: Double {
        return -sin(angle)
    }
    public var j: Double {
        return 0
    }
    public var k: Double {
        return cos(angle)
    }
    public var l: Double {
        return 0
    }
    
    public var inverse : Matrix.RotateY {
        return Matrix.RotateY(-angle)
    }
}

@warn_unused_result
public func == (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
public func != (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
public func * (lhs: Matrix.RotateY, rhs: Matrix.RotateY) -> Matrix.RotateY {
    return Matrix.RotateY(lhs.angle + rhs.angle)
}

public func *= (inout lhs: Matrix.RotateY, rhs: Matrix.RotateY) {
    return lhs.angle += rhs.angle
}

extension Matrix.RotateZ {
    
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
        return 0
    }
    public var e: Double {
        return sin(angle)
    }
    public var f: Double {
        return cos(angle)
    }
    public var g: Double {
        return 0
    }
    public var h: Double {
        return 0
    }
    public var i: Double {
        return 0
    }
    public var j: Double {
        return 0
    }
    public var k: Double {
        return 1
    }
    public var l: Double {
        return 0
    }
    
    public var inverse : Matrix.RotateZ {
        return Matrix.RotateZ(-angle)
    }
}

@warn_unused_result
public func == (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Bool {
    return lhs.angle == rhs.angle
}
@warn_unused_result
public func != (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Bool {
    return lhs.angle != rhs.angle
}

@warn_unused_result
public func * (lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) -> Matrix.RotateZ {
    return Matrix.RotateZ(lhs.angle + rhs.angle)
}

public func *= (inout lhs: Matrix.RotateZ, rhs: Matrix.RotateZ) {
    return lhs.angle += rhs.angle
}

extension Matrix.Scale {
    
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
        return 0
    }
    public var f: Double {
        return y
    }
    public var g: Double {
        return 0
    }
    public var h: Double {
        return 0
    }
    public var i: Double {
        return 0
    }
    public var j: Double {
        return 0
    }
    public var k: Double {
        return z
    }
    public var l: Double {
        return 0
    }
    
    public var inverse : Matrix.Scale {
        return Matrix.Scale(x: 1 / x, y: 1 / y, z: 1 / z)
    }
}

@warn_unused_result
public func == (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@warn_unused_result
public func != (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}

@warn_unused_result
public func * (lhs: Matrix.Scale, rhs: Matrix.Scale) -> Matrix.Scale {
    return Matrix.Scale(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
}

public func *= (inout lhs: Matrix.Scale, rhs: Matrix.Scale) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
    lhs.z *= rhs.z
}

extension Matrix.Translate {
    
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
        return x
    }
    public var e: Double {
        return 0
    }
    public var f: Double {
        return 1
    }
    public var g: Double {
        return 0
    }
    public var h: Double {
        return y
    }
    public var i: Double {
        return 0
    }
    public var j: Double {
        return 0
    }
    public var k: Double {
        return 1
    }
    public var l: Double {
        return z
    }
    
    public var inverse : Matrix.Translate {
        return Matrix.Translate(x: -x, y: -y, z: -z)
    }
}

@warn_unused_result
public func == (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@warn_unused_result
public func != (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}

@warn_unused_result
public func * (lhs: Matrix.Translate, rhs: Matrix.Translate) -> Matrix.Translate {
    return Matrix.Translate(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

public func *= (inout lhs: Matrix.Translate, rhs: Matrix.Translate) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

@warn_unused_result
public func == <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d
        && lhs.e == rhs.e && lhs.f == rhs.f && lhs.g == rhs.g && lhs.h == rhs.h
        && lhs.i == rhs.i && lhs.j == rhs.j && lhs.k == rhs.k && lhs.l == rhs.l
}
@warn_unused_result
public func != <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d
        || lhs.e != rhs.e || lhs.f != rhs.f || lhs.g != rhs.g || lhs.h != rhs.h
        || lhs.i != rhs.i || lhs.j != rhs.j || lhs.k != rhs.k || lhs.l != rhs.l
}

@warn_unused_result
public func * <S: MatrixType, T: MatrixType>(lhs: S, rhs: T) -> Matrix {
    let _a = lhs.a * rhs.a + lhs.b * rhs.e + lhs.c * rhs.i
    let _b = lhs.a * rhs.b + lhs.b * rhs.f + lhs.c * rhs.j
    let _c = lhs.a * rhs.c + lhs.b * rhs.g + lhs.c * rhs.k
    let _d = lhs.a * rhs.d + lhs.b * rhs.h + lhs.c * rhs.l + lhs.d
    let _e = lhs.e * rhs.a + lhs.f * rhs.e + lhs.g * rhs.i
    let _f = lhs.e * rhs.b + lhs.f * rhs.f + lhs.g * rhs.j
    let _g = lhs.e * rhs.c + lhs.f * rhs.g + lhs.g * rhs.k
    let _h = lhs.e * rhs.d + lhs.f * rhs.h + lhs.g * rhs.l + lhs.h
    let _i = lhs.i * rhs.a + lhs.j * rhs.e + lhs.k * rhs.i
    let _j = lhs.i * rhs.b + lhs.j * rhs.f + lhs.k * rhs.j
    let _k = lhs.i * rhs.c + lhs.j * rhs.g + lhs.k * rhs.k
    let _l = lhs.i * rhs.d + lhs.j * rhs.h + lhs.k * rhs.l + lhs.l
    return Matrix(a: _a, b: _b, c: _c, d: _d, e: _e, f: _f, g: _g, h: _h, i: _i, j: _j, k: _k, l: _l)
}

public func *= <T: MatrixType>(inout lhs: Matrix, rhs: T) {
    lhs = lhs * rhs
}

@warn_unused_result
public func * <T: MatrixType>(lhs: T, rhs: Vector) -> Vector {
    return Vector(x: lhs.a * rhs.x + lhs.b * rhs.y + lhs.c * rhs.z + lhs.d, y: lhs.e * rhs.x + lhs.f * rhs.y + lhs.g * rhs.z + lhs.h, z: lhs.i * rhs.x + lhs.j * rhs.y + lhs.k * rhs.z + lhs.l)
}
