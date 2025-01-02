//
//  SDTransform.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
///     ⎛ a d 0 ⎞
///     ⎜ b e 0 ⎟
///     ⎝ c f 1 ⎠
///
@frozen
public struct SDTransform: Hashable {
    
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double
    
    @inlinable
    @inline(__always)
    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(a: T, b: T, c: T, d: T, e: T, f: T) {
        self.a = Double(a)
        self.b = Double(b)
        self.c = Double(c)
        self.d = Double(d)
        self.e = Double(e)
        self.f = Double(f)
    }
}

extension SDTransform: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "SDTransform(a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f))"
    }
}

extension SDTransform: Codable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.a = try container.decode(Double.self)
        self.d = try container.decode(Double.self)
        self.b = try container.decode(Double.self)
        self.e = try container.decode(Double.self)
        self.c  = try container.decode(Double.self)
        self.f  = try container.decode(Double.self)
    }
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.a)
        try container.encode(self.d)
        try container.encode(self.b)
        try container.encode(self.e)
        try container.encode(self.c)
        try container.encode(self.f)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension SDTransform: Sendable { }

extension SDTransform {
    
    @inlinable
    @inline(__always)
    public var determinant: Double {
        return a * e - b * d
    }
}

extension SDTransform {
    
    @inlinable
    @inline(__always)
    public var invertible: Bool {
        let determinant = self.determinant
        return determinant.isFinite && !determinant.almostZero()
    }
    
    @inlinable
    @inline(__always)
    public var inverse: SDTransform {
        let det = self.determinant
        return SDTransform(a: e / det, b: -b / det, c: (b * f - c * e) / det, d: -d / det, e: a / det, f: (c * d - a * f) / det)
    }
}

extension SDTransform {
    
    @inlinable
    @inline(__always)
    public var tx: Double {
        get {
            return c
        }
        set {
            c = newValue
        }
    }
    
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
    public static var identity: SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: 0, e: 1, f: 0)
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 ⎟
    ///     ⎝    0      0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotate(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: cos(angle), b: -sin(angle), c: 0,
                           d: sin(angle), e: cos(angle), f: 0)
    }
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 ⎟
    ///     ⎝    0      0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func rotate<T: BinaryFloatingPoint>(_ angle: T) -> SDTransform {
        return .rotate(Double(angle))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛   1    0 0 ⎞
    ///     ⎜ tan(a) 1 0 ⎟
    ///     ⎝   0    0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func skewX(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: 1, b: tan(angle), c: 0,
                           d: 0, e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛   1    0 0 ⎞
    ///     ⎜ tan(a) 1 0 ⎟
    ///     ⎝   0    0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func skewX<T: BinaryFloatingPoint>(_ angle: T) -> SDTransform {
        return .skewX(Double(angle))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 tan(a) 0 ⎞
    ///     ⎜ 0   1    0 ⎟
    ///     ⎝ 0   0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func skewY(_ angle: Double) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: tan(angle), e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 tan(a) 0 ⎞
    ///     ⎜ 0   1    0 ⎟
    ///     ⎝ 0   0    1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func skewY<T: BinaryFloatingPoint>(_ angle: T) -> SDTransform {
        return .skewY(Double(angle))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
    public static func scale(_ scale: Int) -> SDTransform {
        return .scale(Double(scale))
    }
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryInteger>(_ scale: T) -> SDTransform {
        return .scale(Double(scale))
    }
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryFloatingPoint>(_ scale: T) -> SDTransform {
        return .scale(Double(scale))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale(x: Double = 1, y: Double = 1) -> SDTransform {
        
        return SDTransform(a: x, b: 0, c: 0,
                           d: 0, e: y, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale(x: Int = 1, y: Int = 1) -> SDTransform {
        return .scale(x: Double(x), y: Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryInteger>(x: T = 1, y: T = 1) -> SDTransform {
        return .scale(x: Double(x), y: Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func scale<T: BinaryFloatingPoint>(x: T = 1, y: T = 1) -> SDTransform {
        return .scale(x: Double(x), y: Double(y))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate(x: Double = 0, y: Double = 0) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: x,
                           d: 0, e: 1, f: y)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate(x: Int = 0, y: Int = 0) -> SDTransform {
        return .translate(x: Double(x), y: Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate<T: BinaryInteger>(x: T = 0, y: T = 0) -> SDTransform {
        return .translate(x: Double(x), y: Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func translate<T: BinaryFloatingPoint>(x: T = 0, y: T = 0) -> SDTransform {
        return .translate(x: Double(x), y: Double(y))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX(_ x: Double = 0) -> SDTransform {
        
        return SDTransform(a: -1, b: 0, c: 2 * x,
                           d: 0, e: 1, f: 0)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX(_ x: Int) -> SDTransform {
        return .reflectX(Double(x))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX<T: BinaryInteger>(_ x: T) -> SDTransform {
        return .reflectX(Double(x))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectX<T: BinaryFloatingPoint>(_ x: T) -> SDTransform {
        return .reflectX(Double(x))
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY(_ y: Double = 0) -> SDTransform {
        
        return SDTransform(a: 1, b: 0, c: 0,
                           d: 0, e: -1, f: 2 * y)
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY(_ y: Int) -> SDTransform {
        return .reflectY(Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY<T: BinaryInteger>(_ y: T) -> SDTransform {
        return .reflectY(Double(y))
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    @inlinable
    @inline(__always)
    public static func reflectY<T: BinaryFloatingPoint>(_ y: T) -> SDTransform {
        return .reflectY(Double(y))
    }
}

extension SDTransform: Multiplicative {
    
}

@inlinable
@inline(__always)
public func *(lhs: SDTransform, rhs: SDTransform) -> SDTransform {
    let a = lhs.a * rhs.a + lhs.d * rhs.b
    let b = lhs.b * rhs.a + lhs.e * rhs.b
    let c = lhs.c * rhs.a + lhs.f * rhs.b + rhs.c
    let d = lhs.a * rhs.d + lhs.d * rhs.e
    let e = lhs.b * rhs.d + lhs.e * rhs.e
    let f = lhs.c * rhs.d + lhs.f * rhs.e + rhs.f
    return SDTransform(a: a, b: b, c: c, d: d, e: e, f: f)
}

@inlinable
@inline(__always)
public func *=(lhs: inout SDTransform, rhs: SDTransform) {
    lhs = lhs * rhs
}

@inlinable
@inline(__always)
public func *(lhs: Point, rhs: SDTransform) -> Point {
    return Point(x: lhs.x * rhs.a + lhs.y * rhs.b + rhs.c, y: lhs.x * rhs.d + lhs.y * rhs.e + rhs.f)
}

@inlinable
@inline(__always)
public func *=(lhs: inout Point, rhs: SDTransform) {
    lhs = lhs * rhs
}
