//
//  Float64ColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
public struct Float64ColorPixel<Model : ColorModelProtocol> : _FloatComponentPixel {
    
    public typealias Scalar = Double
    
    public var color: Model
    public var opacity: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.color = Model()
        self.opacity = 0
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model, opacity: Double = 1) {
        self.color = color
        self.opacity = opacity
    }
}

@inlinable
@inline(__always)
public prefix func +<Model>(val: Float64ColorPixel<Model>) -> Float64ColorPixel<Model> {
    return val
}
@inlinable
@inline(__always)
public prefix func -<Model>(val: Float64ColorPixel<Model>) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: -val.color, opacity: -val.opacity)
}
@inlinable
@inline(__always)
public func +<Model>(lhs: Float64ColorPixel<Model>, rhs: Float64ColorPixel<Model>) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: lhs.color + rhs.color, opacity: lhs.opacity + rhs.opacity)
}
@inlinable
@inline(__always)
public func -<Model>(lhs: Float64ColorPixel<Model>, rhs: Float64ColorPixel<Model>) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: lhs.color - rhs.color, opacity: lhs.opacity - rhs.opacity)
}

@inlinable
@inline(__always)
public func *<Model>(lhs: Double, rhs: Float64ColorPixel<Model>) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: lhs * rhs.color, opacity: lhs * rhs.opacity)
}
@inlinable
@inline(__always)
public func *<Model>(lhs: Float64ColorPixel<Model>, rhs: Double) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: lhs.color * rhs, opacity: lhs.opacity * rhs)
}

@inlinable
@inline(__always)
public func /<Model>(lhs: Float64ColorPixel<Model>, rhs: Double) -> Float64ColorPixel<Model> {
    return Float64ColorPixel(color: lhs.color / rhs, opacity: lhs.opacity / rhs)
}

@inlinable
@inline(__always)
public func *=<Model> (lhs: inout Float64ColorPixel<Model>, rhs: Double) {
    lhs.color *= rhs
    lhs.opacity *= rhs
}
@inlinable
@inline(__always)
public func /=<Model> (lhs: inout Float64ColorPixel<Model>, rhs: Double) {
    lhs.color /= rhs
    lhs.opacity /= rhs
}
@inlinable
@inline(__always)
public func +=<Model> (lhs: inout Float64ColorPixel<Model>, rhs: Float64ColorPixel<Model>) {
    lhs.color += rhs.color
    lhs.opacity += rhs.opacity
}
@inlinable
@inline(__always)
public func -=<Model> (lhs: inout Float64ColorPixel<Model>, rhs: Float64ColorPixel<Model>) {
    lhs.color -= rhs.color
    lhs.opacity -= rhs.opacity
}
