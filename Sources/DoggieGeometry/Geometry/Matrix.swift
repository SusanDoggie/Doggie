//
//  Matrix.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

///
/// Transformation Matrix:
///
///     ⎛ a e i 0 ⎞
///     ⎜ b f j 0 ⎟
///     ⎜ c g k 0 ⎟
///     ⎝ d h l 1 ⎠
///
@frozen
public struct Matrix: Hashable {
    
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
    
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(a: T, b: T, c: T, d: T, e: T, f: T, g: T, h: T, i: T, j: T, k: T, l: T) {
        self.a = Double(a)
        self.b = Double(b)
        self.c = Double(c)
        self.d = Double(d)
        self.e = Double(e)
        self.f = Double(f)
        self.g = Double(g)
        self.h = Double(h)
        self.i = Double(i)
        self.j = Double(j)
        self.k = Double(k)
        self.l = Double(l)
    }
}

extension Matrix: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Matrix(a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f), g: \(g), h: \(h), i: \(i), j: \(j), k: \(k), l: \(l))"
    }
}

extension Matrix: Codable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.a = try container.decode(Double.self)
        self.e = try container.decode(Double.self)
        self.i = try container.decode(Double.self)
        self.b = try container.decode(Double.self)
        self.f  = try container.decode(Double.self)
        self.j  = try container.decode(Double.self)
        self.c = try container.decode(Double.self)
        self.g  = try container.decode(Double.self)
        self.k  = try container.decode(Double.self)
        self.d = try container.decode(Double.self)
        self.h  = try container.decode(Double.self)
        self.l  = try container.decode(Double.self)
    }
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.a)
        try container.encode(self.e)
        try container.encode(self.i)
        try container.encode(self.b)
        try container.encode(self.f)
        try container.encode(self.j)
        try container.encode(self.c)
        try container.encode(self.g)
        try container.encode(self.k)
        try container.encode(self.d)
        try container.encode(self.h)
        try container.encode(self.l)
    }
}

extension Matrix {
    
    @inlinable
    @inline(__always)
    public var inverse: Matrix {
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
    
    @inlinable
    @inline(__always)
    public var tx: Double {
        get {
            return d
        }
        set {
            d = newValue
        }
    }
    
    @inlinable
    @inline(__always)
    public var ty: Double {
        get {
            return h
        }
        set {
            h = newValue
        }
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public var determinant: Double {
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
    @inlinable
    @inline(__always)
    public static var identity: Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1    0      0    0 ⎞
    ///     ⎜ 0  cos(a) sin(a) 0 ⎟
    ///     ⎜ 0 -sin(a) cos(a) 0 ⎟
    ///     ⎝ 0    0      0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateX(_ angle: Double) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: cos(angle), g: -sin(angle), h: 0,
                      i: 0, j: sin(angle), k: cos(angle), l: 0)
    }
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1    0      0    0 ⎞
    ///     ⎜ 0  cos(a) sin(a) 0 ⎟
    ///     ⎜ 0 -sin(a) cos(a) 0 ⎟
    ///     ⎝ 0    0      0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateX<T: BinaryFloatingPoint>(_ angle: T) -> Matrix {
        return .rotateX(Double(angle))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ cos(a) 0 -sin(a) 0 ⎞
    ///     ⎜   0    1    0    0 ⎟
    ///     ⎜ sin(a) 0  cos(a) 0 ⎟
    ///     ⎝   0    0    0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateY(_ angle: Double) -> Matrix {
        
        return Matrix(a: cos(angle), b: 0, c: sin(angle), d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: -sin(angle), j: 0, k: cos(angle), l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ cos(a) 0 -sin(a) 0 ⎞
    ///     ⎜   0    1    0    0 ⎟
    ///     ⎜ sin(a) 0  cos(a) 0 ⎟
    ///     ⎝   0    0    0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateY<T: BinaryFloatingPoint>(_ angle: T) -> Matrix {
        return .rotateY(Double(angle))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 0 ⎟
    ///     ⎜    0      0    1 0 ⎟
    ///     ⎝    0      0    0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateZ(_ angle: Double) -> Matrix {
        
        return Matrix(a: cos(angle), b: -sin(angle), c: 0, d: 0,
                      e: sin(angle), f: cos(angle), g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 0 ⎟
    ///     ⎜    0      0    1 0 ⎟
    ///     ⎝    0      0    0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotateZ<T: BinaryFloatingPoint>(_ angle: T) -> Matrix {
        return .rotateZ(Double(angle))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
    public static func scale(_ scale: Int) -> Matrix {
        return .scale(Double(scale))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryInteger>(_ scale: T) -> Matrix {
        return .scale(Double(scale))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryFloatingPoint>(_ scale: T) -> Matrix {
        return .scale(Double(scale))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale(x: Double = 1, y: Double = 1, z: Double = 1) -> Matrix {
        
        return Matrix(a: x, b: 0, c: 0, d: 0,
                      e: 0, f: y, g: 0, h: 0,
                      i: 0, j: 0, k: z, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale(x: Int = 1, y: Int = 1, z: Int = 1) -> Matrix {
        return .scale(x: Double(x), y: Double(y), z: Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryInteger>(x: T = 1, y: T = 1, z: T = 1) -> Matrix {
        return .scale(x: Double(x), y: Double(y), z: Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 0 ⎞
    ///     ⎜ 0 y 0 0 ⎟
    ///     ⎜ 0 0 z 0 ⎟
    ///     ⎝ 0 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryFloatingPoint>(x: T = 1, y: T = 1, z: T = 1) -> Matrix {
        return .scale(x: Double(x), y: Double(y), z: Double(z))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate(x: Double = 0, y: Double = 0, z: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: x,
                      e: 0, f: 1, g: 0, h: y,
                      i: 0, j: 0, k: 1, l: z)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate(x: Int = 0, y: Int = 0, z: Int = 0) -> Matrix {
        return .translate(x: Double(x), y: Double(y), z: Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate<T: BinaryInteger>(x: T = 0, y: T = 0, z: T = 0) -> Matrix {
        return .translate(x: Double(x), y: Double(y), z: Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 0 ⎞
    ///     ⎜ 0 1 0 0 ⎟
    ///     ⎜ 0 0 1 0 ⎟
    ///     ⎝ x y z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate<T: BinaryFloatingPoint>(x: T = 0, y: T = 0, z: T = 0) -> Matrix {
        return .translate(x: Double(x), y: Double(y), z: Double(z))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 0 ⎞
    ///     ⎜  0 1 0 0 ⎟
    ///     ⎜  0 0 1 0 ⎟
    ///     ⎝ 2x 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX(_ x: Double = 0) -> Matrix {
        
        return Matrix(a: -1, b: 0, c: 0, d: 2 * x,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: 1, l: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 0 ⎞
    ///     ⎜  0 1 0 0 ⎟
    ///     ⎜  0 0 1 0 ⎟
    ///     ⎝ 2x 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX(_ x: Int) -> Matrix {
        return .reflectX(Double(x))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 0 ⎞
    ///     ⎜  0 1 0 0 ⎟
    ///     ⎜  0 0 1 0 ⎟
    ///     ⎝ 2x 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX<T: BinaryInteger>(_ x: T) -> Matrix {
        return .reflectX(Double(x))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 0 ⎞
    ///     ⎜  0 1 0 0 ⎟
    ///     ⎜  0 0 1 0 ⎟
    ///     ⎝ 2x 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX<T: BinaryFloatingPoint>(_ x: T) -> Matrix {
        return .reflectX(Double(x))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 0 ⎞
    ///     ⎜ 0 -1 0 0 ⎟
    ///     ⎜ 0  0 1 0 ⎟
    ///     ⎝ 0 2y 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY(_ y: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: -1, g: 0, h: 2 * y,
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
    @inlinable
    @inline(__always)
    public static func reflectY(_ y: Int) -> Matrix {
        return .reflectY(Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 0 ⎞
    ///     ⎜ 0 -1 0 0 ⎟
    ///     ⎜ 0  0 1 0 ⎟
    ///     ⎝ 0 2y 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY<T: BinaryInteger>(_ y: T) -> Matrix {
        return .reflectY(Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 0 ⎞
    ///     ⎜ 0 -1 0 0 ⎟
    ///     ⎜ 0  0 1 0 ⎟
    ///     ⎝ 0 2y 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY<T: BinaryFloatingPoint>(_ y: T) -> Matrix {
        return .reflectY(Double(y))
    }
}

extension Matrix {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0  0 0 ⎞
    ///     ⎜ 0 1  0 0 ⎟
    ///     ⎜ 0 0 -1 0 ⎟
    ///     ⎝ 0 0 2z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectZ(_ z: Double = 0) -> Matrix {
        
        return Matrix(a: 1, b: 0, c: 0, d: 0,
                      e: 0, f: 1, g: 0, h: 0,
                      i: 0, j: 0, k: -1, l: 2 * z)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0  0 0 ⎞
    ///     ⎜ 0 1  0 0 ⎟
    ///     ⎜ 0 0 -1 0 ⎟
    ///     ⎝ 0 0 2z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectZ(_ z: Int) -> Matrix {
        return .reflectZ(Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0  0 0 ⎞
    ///     ⎜ 0 1  0 0 ⎟
    ///     ⎜ 0 0 -1 0 ⎟
    ///     ⎝ 0 0 2z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectZ<T: BinaryInteger>(_ z: T) -> Matrix {
        return .reflectZ(Double(z))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0  0 0 ⎞
    ///     ⎜ 0 1  0 0 ⎟
    ///     ⎜ 0 0 -1 0 ⎟
    ///     ⎝ 0 0 2z 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectZ<T: BinaryFloatingPoint>(_ z: T) -> Matrix {
        return .reflectZ(Double(z))
    }
}

extension Matrix {
    
    @inlinable
    @inline(__always)
    public static func rotate(roll x: Double, pitch y: Double, yaw z: Double) -> Matrix {
        return rotateX(x) * rotateY(y) * rotateZ(z)
    }
    @inlinable
    @inline(__always)
    public static func rotate<T: BinaryFloatingPoint>(roll x: T, pitch y: T, yaw z: T) -> Matrix {
        return .rotate(roll: Double(x), pitch: Double(y), yaw: Double(z))
    }
}

extension Matrix {
    
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
    public static func rotate<T: BinaryFloatingPoint>(radian: T, x: T, y: T, z: T) -> Matrix {
        return .rotate(radian: Double(radian), x: Double(x), y: Double(y), z: Double(z))
    }
}

extension Matrix {
    
    @inlinable
    @inline(__always)
    public static func camera(position tx: Double, _ ty: Double, _ tz: Double, rotate ax: Double, _ ay: Double, _ az: Double) -> Matrix {
        return translate(x: -tx, y: -ty, z: -tz) * rotateZ(-az) * rotateY(-ay) * rotateX(-ax)
    }
    @inlinable
    @inline(__always)
    public static func camera<T: BinaryFloatingPoint>(position tx: T, _ ty: T, _ tz: T, rotate ax: T, _ ay: T, _ az: T) -> Matrix {
        return .camera(position: Double(tx), Double(ty), Double(tz), rotate: Double(ax), Double(ay), Double(az))
    }
}

extension Matrix: Multiplicative {
    
}

@inlinable
@inline(__always)
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

@inlinable
@inline(__always)
public func *=(lhs: inout Matrix, rhs: Matrix) {
    lhs = lhs * rhs
}

@inlinable
@inline(__always)
public func *(lhs: Vector, rhs: Matrix) -> Vector {
    return Vector(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}

@inlinable
@inline(__always)
public func *=(lhs: inout Vector, rhs: Matrix) {
    lhs = lhs * rhs
}
