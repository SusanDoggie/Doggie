//
//  Vector.swift
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

public struct Vector2D {
    public var x, y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

extension Point {
    
    public init(_ point: Vector2D) {
        self.x = point.x
        self.y = point.y
    }
}

extension Vector2D {
    
    public init(_ point: Point) {
        self.x = point.x
        self.y = point.y
    }
}

public struct Vector3D {
    public var x, y, z: Double
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector2D: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return tensorFormatter((self.x, "𝒊"), (self.y, "𝒋"))
    }
    public var debugDescription: String {
        return tensorFormatter((self.x, "𝒊"), (self.y, "𝒋"))
    }
}
extension Vector3D: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return tensorFormatter((self.x, "𝒊"), (self.y, "𝒋"), (self.z, "𝒌"))
    }
    public var debugDescription: String {
        return tensorFormatter((self.x, "𝒊"), (self.y, "𝒋"), (self.z, "𝒌"))
    }
}

extension Vector2D: Hashable {
    
    public var hashValue: Int {
        return hash(x, y)
    }
}
extension Vector3D: Hashable {
    
    public var hashValue: Int {
        return hash(x, y, z)
    }
}

public func dot(lhs: Vector2D, _ rhs:  Vector2D) -> Double {
    return fma(lhs.x, rhs.x, lhs.y * rhs.y)
}
public func dot(lhs: Vector3D, _ rhs:  Vector3D) -> Double {
    return fma(lhs.x, rhs.x, fma(lhs.y, rhs.y, lhs.z * rhs.z))
}
public func direction(lhs: Vector2D, _ rhs:  Vector2D) -> Double {
    return fma(lhs.x, rhs.y, -lhs.y * rhs.x)
}
public func direction(a: Vector2D, _ b: Vector2D, _ c: Vector2D) -> Double {
    return direction(b - a, c - a)
}
public func cross(lhs: Vector3D, _ rhs:  Vector3D) -> Vector3D {
    return Vector3D(x: fma(lhs.y, rhs.z, -lhs.z * rhs.y), y: fma(lhs.z, rhs.x, -lhs.x * rhs.z), z: fma(lhs.x, rhs.y, -lhs.y * rhs.x))
}

public func norm(value: Vector2D) -> Double {
    return sqrt(dot(value, value))
}

public func norm(value: Vector3D) -> Double {
    return sqrt(dot(value, value))
}

public prefix func +(val: Vector2D) -> Vector2D {
    return val
}
public prefix func +(val: Vector3D) -> Vector3D {
    return val
}
public prefix func -(val: Vector2D) -> Vector2D {
    return Vector2D(x: -val.x, y: -val.y)
}
public prefix func -(val: Vector3D) -> Vector3D {
    return Vector3D(x: -val.x, y: -val.y, z: -val.z)
}
public func +(lhs: Vector2D, rhs:  Vector2D) -> Vector2D {
    return Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
public func +(lhs: Vector3D, rhs:  Vector3D) -> Vector3D {
    return Vector3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
public func -(lhs: Vector2D, rhs:  Vector2D) -> Vector2D {
    return Vector2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
public func -(lhs: Vector3D, rhs:  Vector3D) -> Vector3D {
    return Vector3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

public func *(lhs: Double, rhs:  Vector2D) -> Vector2D {
    return Vector2D(x: lhs * rhs.x, y: lhs * rhs.y)
}
public func *(lhs: Double, rhs:  Vector3D) -> Vector3D {
    return Vector3D(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
public func *(lhs: Vector2D, rhs:  Double) -> Vector2D {
    return Vector2D(x: lhs.x * rhs, y: lhs.y * rhs)
}
public func *(lhs: Vector3D, rhs:  Double) -> Vector3D {
    return Vector3D(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

public func /(lhs: Vector2D, rhs:  Double) -> Vector2D {
    return Vector2D(x: lhs.x / rhs, y: lhs.y / rhs)
}
public func /(lhs: Vector3D, rhs:  Double) -> Vector3D {
    return Vector3D(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

public func *= (inout lhs: Vector2D, rhs:  Double) {
    lhs.x *= rhs
    lhs.y *= rhs
}
public func *= (inout lhs: Vector3D, rhs:  Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
public func /= (inout lhs: Vector2D, rhs:  Double) {
    lhs.x /= rhs
    lhs.y /= rhs
}
public func /= (inout lhs: Vector3D, rhs:  Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
public func += (inout lhs: Vector2D, rhs:  Vector2D) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
public func -= (inout lhs: Vector2D, rhs:  Vector2D) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}
public func += (inout lhs: Vector3D, rhs:  Vector3D) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
public func -= (inout lhs: Vector3D, rhs:  Vector3D) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
public func ==(lhs: Vector2D, rhs: Vector2D) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
public func ==(lhs: Vector3D, rhs: Vector3D) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
