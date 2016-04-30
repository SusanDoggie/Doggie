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

extension Vector: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        
        var print = ""
        
        switch x {
        case 0: break
        case 1: "𝒊".writeTo(&print)
        case -1: "-𝒊".writeTo(&print)
        default: String(format: "%.2f𝒊", x).writeTo(&print)
        }
        
        if y != 0 {
            if !print.isEmpty && !y.isSignMinus {
                "+".writeTo(&print)
            }
            switch y {
            case 1: "𝒋".writeTo(&print)
            case -1: "-𝒋".writeTo(&print)
            default: String(format: "%.2f𝒋", x).writeTo(&print)
            }
        }
        
        if z != 0 {
            if !print.isEmpty && !z.isSignMinus {
                "+".writeTo(&print)
            }
            switch z {
            case 1: "𝒌".writeTo(&print)
            case -1: "-𝒌".writeTo(&print)
            default: String(format: "%.2f𝒌", x).writeTo(&print)
            }
        }
        
        if print.isEmpty {
            print = "0.0"
        }
        return print
    }
    
    public var debugDescription: String {
        return self.description
    }
}

extension Vector: Hashable {
    
    public var hashValue: Int {
        return hash_combine(0, x, y, z)
    }
}

@warn_unused_result
public func dot(lhs: Vector, _ rhs:  Vector) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}
@warn_unused_result
public func cross(lhs: Vector, _ rhs:  Vector) -> Vector {
    return Vector(x: lhs.y * rhs.z - lhs.z * rhs.y, y: lhs.z * rhs.x - lhs.x * rhs.z, z: lhs.x * rhs.y - lhs.y * rhs.x)
}

@warn_unused_result
public func norm(value: Vector) -> Double {
    return sqrt(dot(value, value))
}

@warn_unused_result
public prefix func +(val: Vector) -> Vector {
    return val
}
@warn_unused_result
public prefix func -(val: Vector) -> Vector {
    return Vector(x: -val.x, y: -val.y, z: -val.z)
}
@warn_unused_result
public func +(lhs: Vector, rhs:  Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
@warn_unused_result
public func -(lhs: Vector, rhs:  Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

@warn_unused_result
public func *(lhs: Double, rhs:  Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
@warn_unused_result
public func *(lhs: Vector, rhs:  Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

@warn_unused_result
public func /(lhs: Vector, rhs:  Double) -> Vector {
    return Vector(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

public func *= (inout lhs: Vector, rhs:  Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
public func /= (inout lhs: Vector, rhs:  Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
public func += (inout lhs: Vector, rhs:  Vector) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
public func -= (inout lhs: Vector, rhs:  Vector) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
@warn_unused_result
public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@warn_unused_result
public func !=(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}
