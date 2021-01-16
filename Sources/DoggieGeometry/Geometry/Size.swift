//
//  Size.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
public struct Size: Hashable {
    
    public var width: Double
    public var height: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.width = 0
        self.height = 0
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }
    @inlinable
    @inline(__always)
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryInteger>(width: T, height: T) {
        self.width = Double(width)
        self.height = Double(height)
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(width: T, height: T) {
        self.width = Double(width)
        self.height = Double(height)
    }
}

extension Size: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Size(width: \(width), height: \(height))"
    }
}

extension Size: Codable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.width = try container.decode(Double.self)
        self.height = try container.decode(Double.self)
    }
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(width)
        try container.encode(height)
    }
}

extension Size {
    
    @inlinable
    @inline(__always)
    public func aspectFit(_ bound: Size) -> Size {
        let u = width * bound.height
        let v = bound.width * height
        if u < v {
            return Size(width: u / height, height: bound.height)
        } else {
            return Size(width: bound.width, height: v / width)
        }
    }
    
    @inlinable
    @inline(__always)
    public func aspectFill(_ bound: Size) -> Size {
        let u = width * bound.height
        let v = bound.width * height
        if u < v {
            return Size(width: bound.width, height: v / width)
        } else {
            return Size(width: u / height, height: bound.height)
        }
    }
}

extension Size: ScalarMultiplicative {
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
    public static var zero: Size {
        return Size()
    }
}

@inlinable
@inline(__always)
public prefix func +(val: Size) -> Size {
    return val
}
@inlinable
@inline(__always)
public prefix func -(val: Size) -> Size {
    return Size(width: -val.width, height: -val.height)
}
@inlinable
@inline(__always)
public func +(lhs: Size, rhs: Size) -> Size {
    return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}
@inlinable
@inline(__always)
public func -(lhs: Size, rhs: Size) -> Size {
    return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

@inlinable
@inline(__always)
public func *(lhs: Double, rhs: Size) -> Size {
    return Size(width: lhs * rhs.width, height: lhs * rhs.height)
}
@inlinable
@inline(__always)
public func *(lhs: Size, rhs: Double) -> Size {
    return Size(width: lhs.width * rhs, height: lhs.height * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: Size, rhs: Double) -> Size {
    return Size(width: lhs.width / rhs, height: lhs.height / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout Size, rhs: Double) {
    lhs.width *= rhs
    lhs.height *= rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout Size, rhs: Double) {
    lhs.width /= rhs
    lhs.height /= rhs
}
@inlinable
@inline(__always)
public func += (lhs: inout Size, rhs: Size) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}
@inlinable
@inline(__always)
public func -= (lhs: inout Size, rhs: Size) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}
