//
//  Matrix.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

public struct Matrix {
    public var m00, m01, m02, m03: Double
    public var m10, m11, m12, m13: Double
    public var m20, m21, m22, m23: Double
    public var m30, m31, m32, m33: Double
    
    public init(_ m00: Double, _ m01: Double, _ m02: Double, _ m03: Double,
        _ m10: Double, _ m11: Double, _ m12: Double, _ m13: Double,
        _ m20: Double, _ m21: Double, _ m22: Double, _ m23: Double,
        _ m30: Double, _ m31: Double, _ m32: Double, _ m33: Double) {
            (self.m00, self.m01, self.m02, self.m03) = (m00, m01, m02, m03)
            (self.m10, self.m11, self.m12, self.m13) = (m10, m11, m12, m13)
            (self.m20, self.m21, self.m22, self.m23) = (m20, m21, m22, m23)
            (self.m30, self.m31, self.m32, self.m33) = (m30, m31, m32, m33)
    }
}

extension Matrix: Hashable {
    
    public var hashValue: Int {
        return hash(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33)
    }
}

public let MatrixIdentity = Matrix(
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
)

// MARK: Transformation matrix

@warn_unused_result
public func Rotate(x angle: Double) -> Matrix {
    let _cos = cos(angle)
    let _sin = sin(angle)
    return Matrix(
        1.0, 0.0,  0.0,   0.0,
        0.0, _cos, -_sin, 0.0,
        0.0, _sin, _cos,  0.0,
        0.0, 0.0,  0.0,   1.0
    )
}
@warn_unused_result
public func Rotate(y angle: Double) -> Matrix {
    let _cos = cos(angle)
    let _sin = sin(angle)
    return Matrix(
        _cos,  0.0, _sin, 0.0,
        0.0,   1.0, 0.0,  0.0,
        -_sin, 0.0, _cos, 0.0,
        0.0,   0.0, 0.0,  1.0
    )
}
@warn_unused_result
public func Rotate(z angle: Double) -> Matrix {
    let _cos = cos(angle)
    let _sin = sin(angle)
    return Matrix(
        _cos, -_sin, 0.0, 0.0,
        _sin, _cos,  0.0, 0.0,
        0.0,  0.0,   1.0, 0.0,
        0.0,  0.0,   0.0, 1.0
    )
}
@warn_unused_result
public func Rotate(roll x: Double, pitch y: Double, yaw z: Double) -> Matrix {
    return Rotate(z: z) * Rotate(y: y) * Rotate(x: x)
}
@warn_unused_result
public func Rotate(radian: Double, x: Double, y: Double, z: Double) -> Matrix {
    let _abs = sqrt(x * x + y * y + z * z)
    let vx = x / _abs
    let vy = y / _abs
    let vz = z / _abs
    let _cos = cos(radian)
    let _cosp = 1.0 - _cos
    let _sin = sin(radian)
    return Matrix(
        _cos + _cosp * vx * vx,
        _cosp * vx * vy - vz * _sin,
        _cosp * vx * vz + vy * _sin,
        0.0,
        _cosp * vy * vx + vz * _sin,
        _cos + _cosp * vy * vy,
        _cosp * vy * vz - vx * _sin,
        0.0,
        _cosp * vz * vx - vy * _sin,
        _cosp * vz * vy + vx * _sin,
        _cos + _cosp * vz * vz,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0
    )
}
@warn_unused_result
public func Scale(ratio r: Double) -> Matrix {
    if r > 1 {
        return Matrix(
            1.0 / r, 0.0, 0.0, 0.0,
            0.0,     1.0, 0.0, 0.0,
            0.0,     0.0, 1.0, 0.0,
            0.0,     0.0, 0.0, 1.0
        )
    } else {
        return Matrix(
            1.0, 0.0, 0.0, 0.0,
            0.0, r,   0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        )
    }
}
@warn_unused_result
public func Scale(x: Double, _ y: Double, _ z: Double) -> Matrix {
    return Matrix(
        x,   0.0, 0.0, 0.0,
        0.0, y,   0.0, 0.0,
        0.0, 0.0, z,   0.0,
        0.0, 0.0, 0.0, 1.0
    )
}
@warn_unused_result
public func Translate(x: Double, _ y: Double, _ z: Double) -> Matrix {
    return Matrix(
        1.0, 0.0, 0.0, x,
        0.0, 1.0, 0.0, y,
        0.0, 0.0, 1.0, z,
        0.0, 0.0, 0.0, 1.0
    )
}
@warn_unused_result
public func PerspectiveProject(alpha: Double, aspect: Double, nearZ: Double, farZ: Double) -> Matrix {
    let cotan = 1.0 / tan(alpha * 0.5)
    return Matrix(
        cotan / aspect,
        0.0,
        0.0,
        0.0,
        0.0,
        cotan,
        0.0,
        0.0,
        0.0,
        0.0,
        (farZ + nearZ) / (nearZ - farZ),
        (2.0 * farZ * nearZ) / (nearZ - farZ),
        0.0,
        0.0,
        -1.0,
        0.0
    )
}

@warn_unused_result
public func CameraTransform(position tx: Double, _ ty: Double, _ tz: Double, rotate ax: Double, _ ay: Double, _ az: Double) -> Matrix {
    return Rotate(x: -ax) * Rotate(y: -ay) * Rotate(z: -az) * Translate(-tx, -ty, -tz)
}

@warn_unused_result
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    return Matrix(
        lhs.m00 + rhs.m00, lhs.m01 + rhs.m01, lhs.m02 + rhs.m02, lhs.m03 + rhs.m03,
        lhs.m10 + rhs.m10, lhs.m11 + rhs.m11, lhs.m12 + rhs.m12, lhs.m13 + rhs.m13,
        lhs.m20 + rhs.m20, lhs.m21 + rhs.m21, lhs.m22 + rhs.m22, lhs.m23 + rhs.m23,
        lhs.m30 + rhs.m30, lhs.m31 + rhs.m31, lhs.m32 + rhs.m32, lhs.m33 + rhs.m33
    )
}
@warn_unused_result
public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    return Matrix(
        lhs.m00 - rhs.m00, lhs.m01 - rhs.m01, lhs.m02 - rhs.m02, lhs.m03 - rhs.m03,
        lhs.m10 - rhs.m10, lhs.m11 - rhs.m11, lhs.m12 - rhs.m12, lhs.m13 - rhs.m13,
        lhs.m20 - rhs.m20, lhs.m21 - rhs.m21, lhs.m22 - rhs.m22, lhs.m23 - rhs.m23,
        lhs.m30 - rhs.m30, lhs.m31 - rhs.m31, lhs.m32 - rhs.m32, lhs.m33 - rhs.m33
    )
}
@warn_unused_result
public func * (lhs: Double, rhs: Matrix) -> Matrix {
    return Matrix(
        lhs * rhs.m00, lhs * rhs.m01, lhs * rhs.m02, lhs * rhs.m03,
        lhs * rhs.m10, lhs * rhs.m11, lhs * rhs.m12, lhs * rhs.m13,
        lhs * rhs.m20, lhs * rhs.m21, lhs * rhs.m22, lhs * rhs.m23,
        lhs * rhs.m30, lhs * rhs.m31, lhs * rhs.m32, lhs * rhs.m33
    )
}
@warn_unused_result
public func * (lhs: Matrix, rhs: Double) -> Matrix {
    return Matrix(
        lhs.m00 * rhs, lhs.m01 * rhs, lhs.m02 * rhs, lhs.m03 * rhs,
        lhs.m10 * rhs, lhs.m11 * rhs, lhs.m12 * rhs, lhs.m13 * rhs,
        lhs.m20 * rhs, lhs.m21 * rhs, lhs.m22 * rhs, lhs.m23 * rhs,
        lhs.m30 * rhs, lhs.m31 * rhs, lhs.m32 * rhs, lhs.m33 * rhs
    )
}
@warn_unused_result
public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return Matrix(
        lhs.m00 * rhs.m00 + lhs.m01 * rhs.m10 + lhs.m02 * rhs.m20 + lhs.m03 * rhs.m30,
        lhs.m00 * rhs.m01 + lhs.m01 * rhs.m11 + lhs.m02 * rhs.m21 + lhs.m03 * rhs.m31,
        lhs.m00 * rhs.m02 + lhs.m01 * rhs.m12 + lhs.m02 * rhs.m22 + lhs.m03 * rhs.m32,
        lhs.m00 * rhs.m03 + lhs.m01 * rhs.m13 + lhs.m02 * rhs.m23 + lhs.m03 * rhs.m33,
        lhs.m10 * rhs.m00 + lhs.m11 * rhs.m10 + lhs.m12 * rhs.m20 + lhs.m13 * rhs.m30,
        lhs.m10 * rhs.m01 + lhs.m11 * rhs.m11 + lhs.m12 * rhs.m21 + lhs.m13 * rhs.m31,
        lhs.m10 * rhs.m02 + lhs.m11 * rhs.m12 + lhs.m12 * rhs.m22 + lhs.m13 * rhs.m32,
        lhs.m10 * rhs.m03 + lhs.m11 * rhs.m13 + lhs.m12 * rhs.m23 + lhs.m13 * rhs.m33,
        lhs.m20 * rhs.m00 + lhs.m21 * rhs.m10 + lhs.m22 * rhs.m20 + lhs.m23 * rhs.m30,
        lhs.m20 * rhs.m01 + lhs.m21 * rhs.m11 + lhs.m22 * rhs.m21 + lhs.m23 * rhs.m31,
        lhs.m20 * rhs.m02 + lhs.m21 * rhs.m12 + lhs.m22 * rhs.m22 + lhs.m23 * rhs.m32,
        lhs.m20 * rhs.m03 + lhs.m21 * rhs.m13 + lhs.m22 * rhs.m23 + lhs.m23 * rhs.m33,
        lhs.m30 * rhs.m00 + lhs.m31 * rhs.m10 + lhs.m32 * rhs.m20 + lhs.m33 * rhs.m30,
        lhs.m30 * rhs.m01 + lhs.m31 * rhs.m11 + lhs.m32 * rhs.m21 + lhs.m33 * rhs.m31,
        lhs.m30 * rhs.m02 + lhs.m31 * rhs.m12 + lhs.m32 * rhs.m22 + lhs.m33 * rhs.m32,
        lhs.m30 * rhs.m03 + lhs.m31 * rhs.m13 + lhs.m32 * rhs.m23 + lhs.m33 * rhs.m33
    )
}
public func += (inout lhs: Matrix, rhs:  Matrix) {
    lhs = lhs + rhs
}
public func -= (inout lhs: Matrix, rhs:  Matrix) {
    lhs = lhs - rhs
}
public func *= (inout lhs: Matrix, rhs:  Double) {
    lhs = lhs * rhs
}
public func *= (inout lhs: Matrix, rhs:  Matrix) {
    lhs = lhs * rhs
}
@warn_unused_result
public func ==(lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.m00 == rhs.m00 && lhs.m01 == rhs.m01 && lhs.m02 == rhs.m02 && lhs.m03 == rhs.m03
        && lhs.m10 == rhs.m10 && lhs.m11 == rhs.m11 && lhs.m12 == rhs.m12 && lhs.m13 == rhs.m13
        && lhs.m20 == rhs.m20 && lhs.m21 == rhs.m21 && lhs.m22 == rhs.m22 && lhs.m23 == rhs.m23
        && lhs.m30 == rhs.m30 && lhs.m31 == rhs.m31 && lhs.m32 == rhs.m32 && lhs.m33 == rhs.m33
}
