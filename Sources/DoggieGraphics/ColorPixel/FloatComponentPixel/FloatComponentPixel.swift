//
//  FloatComponentPixel.swift
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

public protocol _FloatComponentPixel: ColorPixel, ScalarMultiplicative {
    
    associatedtype ColorComponents: Tensor where ColorComponents.Scalar == Scalar
    
    init(color: ColorComponents, opacity: Scalar)
    
    var _color: ColorComponents { get set }
    
    var _opacity: Scalar { get set }
    
    var magnitude: Scalar { get set }
    
    var unit: Self { get }
    
    func distance(to: Self) -> Scalar
}

extension ColorPixel where Self: _FloatComponentPixel, ColorComponents: DoggieGraphics.ColorComponents {
    
    @inlinable
    @inline(__always)
    public init() {
        self.init(color: ColorComponents(), opacity: 0)
    }
}

extension ColorPixel where Self: _FloatComponentPixel {
    
    @inlinable
    @inline(__always)
    public static var bitsPerComponent: Int {
        return MemoryLayout<Scalar>.stride << 3
    }
    
    @inlinable
    @inline(__always)
    public var bitsPerComponent: Int {
        return Self.bitsPerComponent
    }
}

extension ColorPixel where Self: _FloatComponentPixel {
    
    @inlinable
    @inline(__always)
    public func component(_ index: Int) -> Double {
        return withUnsafeTypePunnedPointer(of: self, to: Scalar.self) { Double($0[index]) }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setComponent(_ index: Int, _ value: Double) {
        withUnsafeMutableTypePunnedPointer(of: &self, to: Scalar.self) { $0[index] = Scalar(value) }
    }
    
    @inlinable
    @inline(__always)
    public var isOpaque: Bool {
        return _opacity >= 1
    }
}

extension ColorPixel where Self: _FloatComponentPixel, Scalar: FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    public var magnitude: Scalar {
        get {
            return Scalar.hypot(_color.magnitude, _opacity)
        }
        set {
            let m = self.magnitude
            let scale = m == 0 ? 0 : newValue / m
            self *= scale
        }
    }
    
    @inlinable
    @inline(__always)
    public var unit: Self {
        let m = self.magnitude
        return m == 0 ? Self() : self / m
    }
    
    @inlinable
    @inline(__always)
    public func distance(to: Self) -> Scalar {
        return (to - self).magnitude
    }
}

@inlinable
@inline(__always)
public prefix func +<Pixel: _FloatComponentPixel>(val: Pixel) -> Pixel {
    return val
}
@inlinable
@inline(__always)
public prefix func -<Pixel: _FloatComponentPixel>(val: Pixel) -> Pixel {
    return Pixel(color: -val._color, opacity: -val._opacity)
}
@inlinable
@inline(__always)
public func +<Pixel: _FloatComponentPixel>(lhs: Pixel, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs._color + rhs._color, opacity: lhs._opacity + rhs._opacity)
}
@inlinable
@inline(__always)
public func -<Pixel: _FloatComponentPixel>(lhs: Pixel, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs._color - rhs._color, opacity: lhs._opacity - rhs._opacity)
}

@inlinable
@inline(__always)
public func *<Pixel: _FloatComponentPixel>(lhs: Pixel.Scalar, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs * rhs._color, opacity: lhs * rhs._opacity)
}
@inlinable
@inline(__always)
public func *<Pixel: _FloatComponentPixel>(lhs: Pixel, rhs: Pixel.Scalar) -> Pixel {
    return Pixel(color: lhs._color * rhs, opacity: lhs._opacity * rhs)
}

@inlinable
@inline(__always)
public func /<Pixel: _FloatComponentPixel>(lhs: Pixel, rhs: Pixel.Scalar) -> Pixel {
    return Pixel(color: lhs._color / rhs, opacity: lhs._opacity / rhs)
}

@inlinable
@inline(__always)
public func *=<Pixel: _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel.Scalar) {
    lhs._color *= rhs
    lhs._opacity *= rhs
}
@inlinable
@inline(__always)
public func /=<Pixel: _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel.Scalar) {
    lhs._color /= rhs
    lhs._opacity /= rhs
}
@inlinable
@inline(__always)
public func +=<Pixel: _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel) {
    lhs._color += rhs._color
    lhs._opacity += rhs._opacity
}
@inlinable
@inline(__always)
public func -=<Pixel: _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel) {
    lhs._color -= rhs._color
    lhs._opacity -= rhs._opacity
}

