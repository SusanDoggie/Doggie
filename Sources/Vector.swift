//
//  Vector.swift
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

public struct Vector {
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    public init() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    public init(x: Int, y: Int, z: Int) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
}

extension Vector {
    
    public var magnitude: Double {
        return sqrt(x * x + y * y + z * z)
    }
}

extension Vector {
    
    public var unit: Vector {
        let d = magnitude
        return d == 0 ? Vector() : self / d
    }
}

extension Vector: CustomStringConvertible {
    
    public var description: String {
        return "{x: \(x), y: \(y), z: \(z)}"
    }
}

extension Vector: Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, x, y, z)
    }
}

extension Vector {
    
    public func offset(dx: Double, dy: Double, dz: Double) -> Vector {
        return Vector(x: self.x + dx, y: self.y + dy, z: self.z + dz)
    }
}

extension Vector {
    
    public func distance(to: Vector) -> Double {
        return Vector(x: to.x - self.x, y: to.y - self.y, z: to.z - self.z).magnitude
    }
}

public func dot(_ lhs: Vector, _ rhs:  Vector) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}
public func cross(_ lhs: Vector, _ rhs:  Vector) -> Vector {
    return Vector(x: lhs.y * rhs.z - lhs.z * rhs.y, y: lhs.z * rhs.x - lhs.x * rhs.z, z: lhs.x * rhs.y - lhs.y * rhs.x)
}

public prefix func +(val: Vector) -> Vector {
    return val
}
public prefix func -(val: Vector) -> Vector {
    return Vector(x: -val.x, y: -val.y, z: -val.z)
}
public func +(lhs: Vector, rhs:  Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
public func -(lhs: Vector, rhs:  Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

public func *(lhs: Double, rhs:  Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
public func *(lhs: Vector, rhs:  Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

public func /(lhs: Vector, rhs:  Double) -> Vector {
    return Vector(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

public func *= (lhs: inout Vector, rhs:  Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
public func /= (lhs: inout Vector, rhs:  Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
public func += (lhs: inout Vector, rhs:  Vector) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
public func -= (lhs: inout Vector, rhs:  Vector) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
public func !=(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}
