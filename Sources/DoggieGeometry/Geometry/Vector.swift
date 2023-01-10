//
//  Vector.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

@frozen
public struct Vector: Hashable {
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
    
    @inlinable
    @inline(__always)
    public init(x: Int, y: Int, z: Int) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
    @inlinable
    @inline(__always)
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryInteger>(x: T, y: T, z: T) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(x: T, y: T, z: T) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
}

extension Vector {
    
    @inlinable
    @inline(__always)
    public var magnitude: Double {
        get {
            return hypot(hypot(x, y), z)
        }
        set {
            let m = self.magnitude
            let scale = m == 0 ? 0 : newValue / m
            self *= scale
        }
    }
}

extension Vector: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Vector(x: \(x), y: \(y), z: \(z))"
    }
}

extension Vector: Codable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.x = try container.decode(Double.self)
        self.y = try container.decode(Double.self)
        self.z = try container.decode(Double.self)
    }
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Vector: Sendable { }

extension Vector {
    
    @inlinable
    @inline(__always)
    public func offset(dx: Double, dy: Double, dz: Double) -> Vector {
        return Vector(x: self.x + dx, y: self.y + dy, z: self.z + dz)
    }
}

extension Vector: Tensor {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
    public static var numberOfComponents: Int {
        return 3
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Int) -> Double {
        get {
            return withUnsafeTypePunnedPointer(of: self, to: Double.self) { $0[position] }
        }
        set {
            withUnsafeMutableTypePunnedPointer(of: &self, to: Double.self) { $0[position] = newValue }
        }
    }
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Vector {
        return Vector(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Vector, _ transform: (Double, Double) -> Double) -> Vector {
        return Vector(x: transform(self.x, other.x), y: transform(self.y, other.y), z: transform(self.z, other.z))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
}

@inlinable
@inline(__always)
public func dot(_ lhs: Vector, _ rhs: Vector) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}
@inlinable
@inline(__always)
public func cross(_ lhs: Vector, _ rhs: Vector) -> Vector {
    return Vector(x: lhs.y * rhs.z - lhs.z * rhs.y, y: lhs.z * rhs.x - lhs.x * rhs.z, z: lhs.x * rhs.y - lhs.y * rhs.x)
}

@inlinable
@inline(__always)
public prefix func +(val: Vector) -> Vector {
    return val
}
@inlinable
@inline(__always)
public prefix func -(val: Vector) -> Vector {
    return Vector(x: -val.x, y: -val.y, z: -val.z)
}
@inlinable
@inline(__always)
public func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
@inlinable
@inline(__always)
public func -(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

@inlinable
@inline(__always)
public func *(lhs: Double, rhs: Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
@inlinable
@inline(__always)
public func *(lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout Vector, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout Vector, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
@inlinable
@inline(__always)
public func += (lhs: inout Vector, rhs: Vector) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
@inlinable
@inline(__always)
public func -= (lhs: inout Vector, rhs: Vector) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
