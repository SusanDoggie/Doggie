//
//  ColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public protocol ColorPixelProtocol : Hashable {
    
    associatedtype Model : ColorModelProtocol
    
    init()
    
    init(color: Model, opacity: Double)
    
    var color: Model { get set }
    
    var opacity: Double { get set }
    
    var hashValue: Int { get }
}

extension ColorPixelProtocol {
    
    @_inlineable
    public var hashValue: Int {
        return hash_combine(seed: 0, self.opacity.hashValue, self.color.hashValue)
    }
}

@_inlineable
public prefix func +<Pixel : ColorPixelProtocol>(val: Pixel) -> Pixel {
    
    return val
}
@_inlineable
public prefix func -<Pixel : ColorPixelProtocol>(val: Pixel) -> Pixel {
    
    return Pixel(color: -val.color, opacity: -val.opacity)
}
@_inlineable
public func +<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs:  Pixel) -> Pixel {
    
    return Pixel(color: lhs.color + rhs.color, opacity: lhs.opacity + rhs.opacity)
}
@_inlineable
public func -<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs:  Pixel) -> Pixel {
    
    return Pixel(color: lhs.color - rhs.color, opacity: lhs.opacity - rhs.opacity)
}

@_inlineable
public func *<Pixel : ColorPixelProtocol>(lhs: Double, rhs:  Pixel) -> Pixel {
    
    return Pixel(color: lhs * rhs.color, opacity: lhs * rhs.opacity)
}
@_inlineable
public func *<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs:  Double) -> Pixel {
    
    return Pixel(color: lhs.color * rhs, opacity: lhs.opacity * rhs)
}

@_inlineable
public func /<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs:  Double) -> Pixel {
    
    return Pixel(color: lhs.color / rhs, opacity: lhs.opacity / rhs)
}

@_inlineable
public func *=<Pixel : ColorPixelProtocol> (lhs: inout Pixel, rhs:  Double) {
    lhs.color *= rhs
    lhs.opacity *= rhs
}
@_inlineable
public func /=<Pixel : ColorPixelProtocol> (lhs: inout Pixel, rhs:  Double) {
    lhs.color /= rhs
    lhs.opacity /= rhs
}
@_inlineable
public func +=<Pixel : ColorPixelProtocol> (lhs: inout Pixel, rhs:  Pixel) {
    lhs.color += rhs.color
    lhs.opacity += rhs.opacity
}
@_inlineable
public func -=<Pixel : ColorPixelProtocol> (lhs: inout Pixel, rhs:  Pixel) {
    lhs.color -= rhs.color
    lhs.opacity -= rhs.opacity
}
@_inlineable
public func ==<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs: Pixel) -> Bool {
    
    return lhs.color == rhs.color && lhs.opacity == rhs.opacity
}
@_inlineable
public func !=<Pixel : ColorPixelProtocol>(lhs: Pixel, rhs: Pixel) -> Bool {
    
    return lhs.color != rhs.color || lhs.opacity != rhs.opacity
}

extension ColorPixelProtocol {
    
    @_inlineable
    public init() {
        self.init(color: Model(), opacity: 0)
    }
    
    @_inlineable
    public func with(opacity: Double) -> Self {
        return Self(color: color, opacity: opacity)
    }
}

public struct ColorPixel<Model : ColorModelProtocol> : ColorPixelProtocol {
    
    public var color: Model
    public var opacity: Double
    
    @_inlineable
    public init(color: Model, opacity: Double) {
        self.color = color
        self.opacity = opacity
    }
}

extension ColorPixel {
    
    @_inlineable
    public init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model {
        self.color = color.color
        self.opacity = color.opacity
    }
}

extension ColorPixelProtocol {
    
    @_inlineable
    public init(_ color: ColorPixel<Model>) {
        self.init(color: color.color, opacity: color.opacity)
    }
}

public struct ARGB32ColorPixel : ColorPixelProtocol {
    
    public var a: UInt8
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    @_inlineable
    public init(red: UInt8, green: UInt8, blue: UInt8, opacity: UInt8) {
        self.a = opacity
        self.r = red
        self.g = green
        self.b = blue
    }
    @_inlineable
    public init(_ hex: UInt32) {
        self.a = UInt8((hex >> 24) & 0xFF)
        self.r = UInt8((hex >> 16) & 0xFF)
        self.g = UInt8((hex >> 8) & 0xFF)
        self.b = UInt8(hex & 0xFF)
    }
    @_inlineable
    public init(color: RGBColorModel, opacity: Double) {
        self.a = UInt8((opacity * 255).clamped(to: 0...255))
        self.r = UInt8((color.red * 255).clamped(to: 0...255))
        self.g = UInt8((color.green * 255).clamped(to: 0...255))
        self.b = UInt8((color.blue * 255).clamped(to: 0...255))
    }
    
    @_inlineable
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        }
        set {
            self.r = UInt8((newValue.red * 255).clamped(to: 0...255))
            self.g = UInt8((newValue.green * 255).clamped(to: 0...255))
            self.b = UInt8((newValue.blue * 255).clamped(to: 0...255))
        }
    }
    @_inlineable
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255))
        }
    }
}
