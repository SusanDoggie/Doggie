//
//  Matrix.swift
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
///     ⎛ a e i 0 ⎞
///     ⎜ b f j 0 ⎟
///     ⎜ c g k 0 ⎟
///     ⎝ d h l 1 ⎠
///
public struct Matrix {
    
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
    
    @_inlineable
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

extension Matrix : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "{a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f), g: \(g), h: \(h), i: \(i), j: \(j), k: \(k), l: \(l)}"
    }
}

extension Matrix {
    
    @_inlineable
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
        return Matrix(a:  _a / det, b: -_b / det, c:  _c / det, d: -_d / det,
                      e: -_e / det, f:  _f / det, g: -_g / det, h:  _h / det,
                      i:  _i / det, j: -_j / det, k:  _k / det, l: -_l / det)
    }
}

extension Matrix {
    
    @_inlineable
    public var tx: Double {
        get {
            return d
        }
        set {
            d = newValue
        }
    }
    
    @_inlineable
    public var ty: Double {
        get {
            return h
        }
        set {
            h = newValue
        }
    }
    
    @_inlineable
    public var tz: Double {
        get {
            return l
        }
        set {
            l = newValue
        }
    }
}

extension Matrix : Hashable {
    
    @_inlineable
    public var hashValue: Int {
        return hash_combine(seed: 0, a, b, c, d, e, f, g, h, i, j, k, l)
    }
}

extension Matrix {
    
    @_inlineable
    public var determinant : Double {
        let _c = c * f - b * g
        let _g = c * e - a * g
        let _k = b * e - a * f
        return _c * i - _g * j + _k * k
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
    @_inlineable
    public static var identity : Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1    0      0    0 ⎞
    ///     ⎜ 0  cos(a) sin(a) 0 ⎟
    ///     ⎜ 0 -sin(a) cos(a) 0 ⎟
    ///     ⎝ 0    0      0    1 ⎠
    ///
    @_inlineable
    public static func rotateX(_ angle: Double) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: cos(angle), g: -sin(angle), h: 0,
                      i: 0, j: sin(angle), k: cos(angle), l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ cos(a) 0 -sin(a) 0 ⎞
    ///     ⎜   0    1    0    0 ⎟
    ///     ⎜ sin(a) 0  cos(a) 0 ⎟
    ///     ⎝   0    0    0    1 ⎠
    ///
    @_inlineable
    public static func rotateY(_ angle: Double) -> Matrix {
        
        return Matrix(a: cos(angle), b: 0, c: sin(angle), d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: -sin(angle), j: 0, k: cos(angle), l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 0 ⎟
    ///     ⎜    0      0    1 0 ⎟
    ///     ⎝    0      0    0 1 ⎠
    ///
    @_inlineable
    public static func rotateZ(_ angle: Double) -> Matrix {
        
        return Matrix(a: cos(angle), b: -sin(angle), c: 0, d: 0,
                      e: sin(angle), f: cos(angle), g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @_inlineable
    public static func scale(_ scale: Double) -> Matrix {
        
        return Matrix(a: scale, b: 0, c: 0, d: 0,
                      e: 0, f: scale, g: 0, h: 0,
                      i: 0, j: 0, k: scale, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @_inlineable
    public static func scale(x: Double = 1, y: Double = 1, z: Double = 1) -> Matrix {
        
        return Matrix(a: x, b: 0, c: 0, d: 0,
                      e: 0, f: y, g: 0, h: 0,
                      i: 0, j: 0, k: z, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    @_inlineable
    public static func translate(x: Double = 0, y: Double = 0, z: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: x,
                      e: 0, f: 1, g: 0, h: y,
                      i: 0, j: 0, k: 1, l: z)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 0 ⎞
    ///     ⎜  0 1 0 0 ⎟
    ///     ⎜  0 0 1 0 ⎟
    ///     ⎝ 2x 0 0 1 ⎠
    ///
    @_inlineable
    public static func reflectX(_ x: Double = 0) -> Matrix {
        
        return Matrix(a: -1, b: 0, c: 0, d: 2 * x,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 0 ⎞
    ///     ⎜ 0 -1 0 0 ⎟
    ///     ⎜ 0  0 1 0 ⎟
    ///     ⎝ 0 2y 0 1 ⎠
    ///
    @_inlineable
    public static func reflectY(_ y: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: -1, g: 0, h: 2 * y,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0  0 0 ⎞
    ///     ⎜ 0 1  0 0 ⎟
    ///     ⎜ 0 0 -1 0 ⎟
    ///     ⎝ 0 0 2z 1 ⎠
    ///
    @_inlineable
    public static func reflectZ(_ z: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: -1, l: 2 * z)
    }
    
    @_inlineable
    public static func rotate(roll x: Double, pitch y: Double, yaw z: Double) -> Matrix {
        return rotateX(x) * rotateY(y) * rotateZ(z)
    }
    @_inlineable
    public static func rotate(radian: Double, x: Double, y: Double, z: Double) -> Matrix {
        let _abs = sqrt(x * x + y * y + z * z)
        let vx = x / _abs
        let vy = y / _abs
        let vz = z / _abs
        let _cos = cos(radian)
        let _cosp = 1.0 - _cos
        let _sin = sin(radian)
        return Matrix(a: _cos + _cosp * vx * vx,
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
                      l: 0.0)
    }
    
    @_inlineable
    public static func camera(position tx: Double, _ ty: Double, _ tz: Double, rotate ax: Double, _ ay: Double, _ az: Double) -> Matrix {
        return translate(x: -tx, y: -ty, z: -tz) * rotateZ(-az) * rotateY(-ay) * rotateX(-ax)
    }
}

// column major
@_inlineable
public func PerspectiveProjectMatrix(alpha: Double, aspect: Double, nearZ: Double, farZ: Double) -> [Double] {
    let cotan = 1.0 / tan(alpha * 0.5)
    return [
        cotan / aspect, 0.0, 0.0, 0.0,
        0.0, cotan, 0.0, 0.0,
        0.0, 0.0, (farZ + nearZ) / (nearZ - farZ), -1.0,
        0.0, 0.0, (2.0 * farZ * nearZ) / (nearZ - farZ), 0.0
    ]
}

@_inlineable
public func ==(lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d
        && lhs.e == rhs.e && lhs.f == rhs.f && lhs.g == rhs.g && lhs.h == rhs.h
        && lhs.i == rhs.i && lhs.j == rhs.j && lhs.k == rhs.k && lhs.l == rhs.l
}
@_inlineable
public func !=(lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d
        || lhs.e != rhs.e || lhs.f != rhs.f || lhs.g != rhs.g || lhs.h != rhs.h
        || lhs.i != rhs.i || lhs.j != rhs.j || lhs.k != rhs.k || lhs.l != rhs.l
}

@_inlineable
public func *(lhs: Matrix, rhs: Matrix) -> Matrix {
    let a = lhs.a * rhs.a + lhs.e * rhs.b + lhs.i * rhs.c
    let b = lhs.b * rhs.a + lhs.f * rhs.b + lhs.j * rhs.c
    let c = lhs.c * rhs.a + lhs.g * rhs.b + lhs.k * rhs.c
    let d = lhs.d * rhs.a + lhs.h * rhs.b + lhs.l * rhs.c + rhs.d
    let e = lhs.a * rhs.e + lhs.e * rhs.f + lhs.i * rhs.g
    let f = lhs.b * rhs.e + lhs.f * rhs.f + lhs.j * rhs.g
    let g = lhs.c * rhs.e + lhs.g * rhs.f + lhs.k * rhs.g
    let h = lhs.d * rhs.e + lhs.h * rhs.f + lhs.l * rhs.g + rhs.h
    let i = lhs.a * rhs.i + lhs.e * rhs.j + lhs.i * rhs.k
    let j = lhs.b * rhs.i + lhs.f * rhs.j + lhs.j * rhs.k
    let k = lhs.c * rhs.i + lhs.g * rhs.j + lhs.k * rhs.k
    let l = lhs.d * rhs.i + lhs.h * rhs.j + lhs.l * rhs.k + rhs.l
    return Matrix(a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h, i: i, j: j, k: k, l: l)
}

@_inlineable
public func *=(lhs: inout Matrix, rhs: Matrix) {
    lhs = lhs * rhs
}

@_inlineable
public func *(lhs: Vector, rhs: Matrix) -> Vector {
    return Vector(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}

@_inlineable
public func *=(lhs: inout Vector, rhs: Matrix) {
    lhs = lhs * rhs
}
