//
//  FloatComponentPixel.swift
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

public protocol _FloatComponentPixel : ColorPixelProtocol, ScalarMultiplicative where Scalar : BinaryFloatingPoint {
    
    associatedtype ColorComponents : Tensor where ColorComponents.Scalar == Scalar
    
    init(color: ColorComponents, opacity: Scalar)
    
    var _color: ColorComponents { get set }
    
    var _opacity: Scalar { get set }
    
    var magnitude: Scalar { get set }
    
    var unit: Self { get }
    
    func distance(to: Self) -> Scalar
}

extension ColorPixelProtocol where Self : _FloatComponentPixel, Self.ColorComponents : _FloatColorComponents {
    
    @inlinable
    @inline(__always)
    public init() {
        self.init(color: ColorComponents(), opacity: 0)
    }
    
    @inlinable
    @inline(__always)
    public init<C : ColorPixelProtocol>(_ color: C) where C.Model == Model {
        self.init(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixelProtocol where Self : _FloatComponentPixel, Self.ColorComponents : _FloatColorComponents {
    
    @_transparent
    public var opacity: Double {
        get {
            return Double(_opacity)
        }
        set {
            self._opacity = Scalar(newValue)
        }
    }
    
    @_transparent
    public var isOpaque: Bool {
        return _opacity >= 1
    }
}

extension ColorPixelProtocol where Self : _FloatComponentPixel, Self.ColorComponents : _FloatColorComponents {
    
    @inlinable
    @inline(__always)
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return Double(_color[index])
        } else if index == Model.numberOfComponents {
            return Double(_opacity)
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            _color[index] = Scalar(value)
        } else if index == Model.numberOfComponents {
            _opacity = Scalar(value)
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public func normalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            let range = Model.rangeOfComponent(index)
            return (Double(_color[index]) - range.lowerBound) / (range.upperBound - range.lowerBound)
        } else if index == Model.numberOfComponents {
            return Double(_opacity)
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            let range = Model.rangeOfComponent(index)
            _color[index] = Scalar(value * (range.upperBound - range.lowerBound) + range.lowerBound)
        } else if index == Model.numberOfComponents {
            _opacity = Scalar(value)
        } else {
            fatalError()
        }
    }
}

extension ColorPixelProtocol where Self : _FloatComponentPixel, Self.Scalar : FloatingMathProtocol {
    
    @_transparent
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
    
    @_transparent
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
public prefix func +<Pixel : _FloatComponentPixel>(val: Pixel) -> Pixel {
    return val
}
@inlinable
@inline(__always)
public prefix func -<Pixel : _FloatComponentPixel>(val: Pixel) -> Pixel {
    return Pixel(color: -val._color, opacity: -val._opacity)
}
@inlinable
@inline(__always)
public func +<Pixel : _FloatComponentPixel>(lhs: Pixel, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs._color + rhs._color, opacity: lhs._opacity + rhs._opacity)
}
@inlinable
@inline(__always)
public func -<Pixel : _FloatComponentPixel>(lhs: Pixel, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs._color - rhs._color, opacity: lhs._opacity - rhs._opacity)
}

@inlinable
@inline(__always)
public func *<Pixel : _FloatComponentPixel>(lhs: Pixel.Scalar, rhs: Pixel) -> Pixel {
    return Pixel(color: lhs * rhs._color, opacity: lhs * rhs._opacity)
}
@inlinable
@inline(__always)
public func *<Pixel : _FloatComponentPixel>(lhs: Pixel, rhs: Pixel.Scalar) -> Pixel {
    return Pixel(color: lhs._color * rhs, opacity: lhs._opacity * rhs)
}

@inlinable
@inline(__always)
public func /<Pixel : _FloatComponentPixel>(lhs: Pixel, rhs: Pixel.Scalar) -> Pixel {
    return Pixel(color: lhs._color / rhs, opacity: lhs._opacity / rhs)
}

@inlinable
@inline(__always)
public func *=<Pixel : _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel.Scalar) {
    lhs._color *= rhs
    lhs._opacity *= rhs
}
@inlinable
@inline(__always)
public func /=<Pixel : _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel.Scalar) {
    lhs._color /= rhs
    lhs._opacity /= rhs
}
@inlinable
@inline(__always)
public func +=<Pixel : _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel) {
    lhs._color += rhs._color
    lhs._opacity += rhs._opacity
}
@inlinable
@inline(__always)
public func -=<Pixel : _FloatComponentPixel> (lhs: inout Pixel, rhs: Pixel) {
    lhs._color -= rhs._color
    lhs._opacity -= rhs._opacity
}

