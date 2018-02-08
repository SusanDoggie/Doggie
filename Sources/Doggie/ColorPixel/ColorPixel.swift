//
//  ColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
    
    init(color: Model.FloatComponents, opacity: Float)
    
    init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model
    
    var color: Model { get set }
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    func with(opacity: Double) -> Self
    
    func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blending: (Double, Double) -> Double) -> Self where C.Model == Model
    
    func blended<C : ColorPixelProtocol>(source: C, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> Self where C.Model == Model
}

extension ColorPixelProtocol {
    
    @_transparent
    public init(_ color: Color<Model>) {
        self.init(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public init() {
        self.init(color: Model(), opacity: 0)
    }
    
    @_transparent
    public init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model {
        self = color as? Self ?? Self(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public init(color: Model.FloatComponents, opacity: Float = 1) {
        self.init(color: Model(floatComponents: color), opacity: Double(opacity))
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public func with(opacity: Double) -> Self {
        return Self(color: color, opacity: opacity)
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public static var numberOfComponents: Int {
        return Model.numberOfComponents + 1
    }
    
    @_transparent
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        if i < Model.numberOfComponents {
            return Model.rangeOfComponent(i)
        } else if i == Model.numberOfComponents {
            return 0...1
        } else {
            fatalError()
        }
    }
    
    @_transparent
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Self.rangeOfComponent(i)
    }
    
    @_transparent
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color[index]
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @_transparent
    public mutating func setComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            color[index] = value
        } else if index == Model.numberOfComponents {
            opacity = value
        } else {
            fatalError()
        }
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public func normalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color.normalizedComponent(index)
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @_transparent
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            color.setNormalizedComponent(index, value)
        } else if index == Model.numberOfComponents {
            opacity = value
        } else {
            fatalError()
        }
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public var isOpaque: Bool {
        return opacity >= 1
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(color, opacity)
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public mutating func blend<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blending: (Double, Double) -> Double) where C.Model == Model {
        self = self.blended(source: source, compositingMode: compositingMode, blending: blending)
    }
    @_transparent
    public mutating func blend<C : ColorPixelProtocol>(source: C, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) where C.Model == Model {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}

extension ColorPixelProtocol where Model == GrayColorModel {
    
    @_transparent
    public init(white: Double, opacity: Double = 1) {
        self.init(color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @_transparent
    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @_transparent
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == CMYColorModel {
    
    @_transparent
    public init(cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == CMYKColorModel {
    
    @_transparent
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == GrayColorModel {
    
    @_transparent
    public var white: Double {
        get {
            return color.white
        }
        set {
            color.white = newValue
        }
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @_transparent
    public var red: Double {
        get {
            return color.red
        }
        set {
            color.red = newValue
        }
    }
    
    @_transparent
    public var green: Double {
        get {
            return color.green
        }
        set {
            color.green = newValue
        }
    }
    
    @_transparent
    public var blue: Double {
        get {
            return color.blue
        }
        set {
            color.blue = newValue
        }
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @_transparent
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
    
    @_transparent
    public var saturation: Double {
        get {
            return color.saturation
        }
        set {
            color.saturation = newValue
        }
    }
    
    @_transparent
    public var brightness: Double {
        get {
            return color.brightness
        }
        set {
            color.brightness = newValue
        }
    }
}

extension ColorPixelProtocol where Model == CMYKColorModel {
    
    @_transparent
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @_transparent
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @_transparent
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
    
    @_transparent
    public var black: Double {
        get {
            return color.black
        }
        set {
            color.black = newValue
        }
    }
}

public struct ColorPixel<Model : ColorModelProtocol> : ColorPixelProtocol, ScalarMultiplicative {
    
    public typealias Scalar = Double
    
    public var color: Model
    public var opacity: Double
    
    @_transparent
    public init() {
        self.color = Model()
        self.opacity = 0
    }
    
    @_transparent
    public init(color: Model, opacity: Double = 1) {
        self.color = color
        self.opacity = opacity
    }
}

@_transparent
public prefix func +<Model>(val: ColorPixel<Model>) -> ColorPixel<Model> {
    return val
}
@_transparent
public prefix func -<Model>(val: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: -val.color, opacity: -val.opacity)
}
@_transparent
public func +<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color + rhs.color, opacity: lhs.opacity + rhs.opacity)
}
@_transparent
public func -<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color - rhs.color, opacity: lhs.opacity - rhs.opacity)
}

@_transparent
public func *<Model>(lhs: Double, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs * rhs.color, opacity: lhs * rhs.opacity)
}
@_transparent
public func *<Model>(lhs: ColorPixel<Model>, rhs: Double) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color * rhs, opacity: lhs.opacity * rhs)
}

@_transparent
public func /<Model>(lhs: ColorPixel<Model>, rhs: Double) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color / rhs, opacity: lhs.opacity / rhs)
}

@_transparent
public func *=<Model> (lhs: inout ColorPixel<Model>, rhs: Double) {
    lhs.color *= rhs
    lhs.opacity *= rhs
}
@_transparent
public func /=<Model> (lhs: inout ColorPixel<Model>, rhs: Double) {
    lhs.color /= rhs
    lhs.opacity /= rhs
}
@_transparent
public func +=<Model> (lhs: inout ColorPixel<Model>, rhs: ColorPixel<Model>) {
    lhs.color += rhs.color
    lhs.opacity += rhs.opacity
}
@_transparent
public func -=<Model> (lhs: inout ColorPixel<Model>, rhs: ColorPixel<Model>) {
    lhs.color -= rhs.color
    lhs.opacity -= rhs.opacity
}

@_transparent
public func ==<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> Bool {
    return lhs.color == rhs.color && lhs.opacity == rhs.opacity
}
@_transparent
public func !=<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> Bool {
    return lhs.color != rhs.color || lhs.opacity != rhs.opacity
}

@_fixed_layout
public struct FloatColorPixel<Model : ColorModelProtocol> : ColorPixelProtocol, ScalarMultiplicative {
    
    public typealias Scalar = Float
    
    @_versioned
    var _color: Model.FloatComponents
    
    @_versioned
    var _opacity: Float
    
    @_transparent
    public init() {
        self._color = Model.FloatComponents()
        self._opacity = 0
    }
    
    @_transparent
    public init(color: Model.FloatComponents, opacity: Float = 1) {
        self._color = color
        self._opacity = opacity
    }
    
    @_transparent
    public init(color: Model, opacity: Double = 1) {
        self._color = color.floatComponents
        self._opacity = Float(opacity)
    }
    
    @_transparent
    public var color: Model {
        get {
            return Model(floatComponents: _color)
        }
        set {
            self._color = newValue.floatComponents
        }
    }
    
    @_transparent
    public var opacity: Double {
        get {
            return Double(_opacity)
        }
        set {
            self._opacity = Float(newValue)
        }
    }
}

@_transparent
public prefix func +<Model>(val: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return val
}
@_transparent
public prefix func -<Model>(val: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: -val._color, opacity: -val._opacity)
}
@_transparent
public func +<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs._color + rhs._color, opacity: lhs._opacity + rhs._opacity)
}
@_transparent
public func -<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs._color - rhs._color, opacity: lhs._opacity - rhs._opacity)
}

@_transparent
public func *<Model>(lhs: Float, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs * rhs._color, opacity: lhs * rhs._opacity)
}
@_transparent
public func *<Model>(lhs: FloatColorPixel<Model>, rhs: Float) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs._color * rhs, opacity: lhs._opacity * rhs)
}

@_transparent
public func /<Model>(lhs: FloatColorPixel<Model>, rhs: Float) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs._color / rhs, opacity: lhs._opacity / rhs)
}

@_transparent
public func *=<Model> (lhs: inout FloatColorPixel<Model>, rhs: Float) {
    lhs._color *= rhs
    lhs._opacity *= rhs
}
@_transparent
public func /=<Model> (lhs: inout FloatColorPixel<Model>, rhs: Float) {
    lhs._color /= rhs
    lhs._opacity /= rhs
}
@_transparent
public func +=<Model> (lhs: inout FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) {
    lhs._color += rhs._color
    lhs._opacity += rhs._opacity
}
@_transparent
public func -=<Model> (lhs: inout FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) {
    lhs._color -= rhs._color
    lhs._opacity -= rhs._opacity
}

@_transparent
public func ==<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> Bool {
    return lhs._color == rhs._color && lhs._opacity == rhs._opacity
}
@_transparent
public func !=<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> Bool {
    return lhs._color != rhs._color || lhs._opacity != rhs._opacity
}
