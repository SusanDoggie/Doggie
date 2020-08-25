//
//  ColorPixel.swift
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

public protocol ColorPixel: Hashable {
    
    associatedtype Model: ColorModel
    
    init()
    
    init(color: Model, opacity: Double)
    
    init<C: ColorPixel>(_ color: C) where Model == C.Model
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    var color: Model { get set }
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    func with(opacity: Double) -> Self
    
    func premultiplied() -> Self
    
    func unpremultiplied() -> Self
    
    func blended(source: Self) -> Self
    
    func blended(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self
}

extension ColorPixel where Self: ScalarMultiplicative {
    
    @inlinable
    public static var zero: Self {
        return Self()
    }
}

extension ColorPixel {
    
    @inlinable
    public init(_ color: Color<Model>) {
        self.init(color: color.color, opacity: color.opacity)
    }
    
    @inlinable
    public init<C: ColorPixel>(_ color: C) where Model == C.Model {
        self.init(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixel {
    
    @inlinable
    public init() {
        self.init(color: Model(), opacity: 0)
    }
}

extension ColorPixel {
    
    @inlinable
    public func with(opacity: Double) -> Self {
        var c = self
        c.opacity = opacity
        return c
    }
}

extension ColorPixel {
    
    @inlinable
    public func premultiplied() -> Self {
        return Self(color: color * opacity, opacity: opacity)
    }
    
    @inlinable
    public func unpremultiplied() -> Self {
        guard opacity != 0 else { return self }
        return Self(color: color / opacity, opacity: opacity)
    }
}

extension ColorPixel {
    
    @inlinable
    public static var bitsPerPixel: Int {
        return MemoryLayout<Self>.stride << 3
    }
    
    @inlinable
    public var bitsPerPixel: Int {
        return Self.bitsPerPixel
    }
}

extension ColorPixel {
    
    @inlinable
    public static var numberOfComponents: Int {
        return Model.numberOfComponents + 1
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
}

extension ColorPixel {
    
    @inlinable
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color[index]
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError("Index out of range.")
        }
    }
    
    @inlinable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            color[index] = value
        } else if index == Model.numberOfComponents {
            opacity = value
        } else {
            fatalError("Index out of range.")
        }
    }
}

extension ColorPixel {
    
    @inlinable
    public var isOpaque: Bool {
        return opacity >= 1
    }
}

extension ColorPixel {
    
    @inlinable
    public mutating func blend(source: Self) {
        self = self.blended(source: source)
    }
    
    @inlinable
    public mutating func blend<C: ColorPixel>(source: C) where C.Model == Model {
        self = self.blended(source: source)
    }
    
    @inlinable
    public mutating func blend(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
        self = self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
    
    @inlinable
    public mutating func blend<C: ColorPixel>(source: C, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) where C.Model == Model {
        self = self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
    
    @inlinable
    public func blended(source: Self) -> Self {
        return blended(source: source, compositingMode: .default, blendMode: .default)
    }
    
    @inlinable
    public func blended<C: ColorPixel>(source: C) -> Self where C.Model == Model {
        return blended(source: Self(source))
    }
    
    @inlinable
    public func blended<C: ColorPixel>(source: C, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self where C.Model == Model {
        return blended(source: Self(source), compositingMode: compositingMode, blendMode: blendMode)
    }
}

extension ColorPixel where Model == XYZColorModel {
    
    @inlinable
    public init(x: Double, y: Double, z: Double, opacity: Double = 1) {
        self.init(color: XYZColorModel(x: x, y: y, z: z), opacity: opacity)
    }
    
    @inlinable
    public init(luminance: Double, point: Point, opacity: Double = 1) {
        self.init(color: XYZColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(color: XYZColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension ColorPixel where Model == YxyColorModel {
    
    @inlinable
    public init(luminance: Double, point: Point, opacity: Double = 1) {
        self.init(color: YxyColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(color: YxyColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension ColorPixel where Model == LabColorModel {
    
    @inlinable
    public init(lightness: Double, a: Double, b: Double, opacity: Double = 1) {
        self.init(color: LabColorModel(lightness: lightness, a: a, b: b), opacity: opacity)
    }
    
    @inlinable
    public init(lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(color: LabColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension ColorPixel where Model == LuvColorModel {
    
    @inlinable
    public init(lightness: Double, u: Double, v: Double, opacity: Double = 1) {
        self.init(color: LuvColorModel(lightness: lightness, u: u, v: v), opacity: opacity)
    }
    
    @inlinable
    public init(lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(color: LuvColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension ColorPixel where Model == GrayColorModel {
    
    @inlinable
    public init(white: Double, opacity: Double = 1) {
        self.init(color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension ColorPixel where Model == RGBColorModel {
    
    @inlinable
    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
}

extension ColorPixel where Model == CMYColorModel {
    
    @inlinable
    public init(cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
}

extension ColorPixel where Model == CMYKColorModel {
    
    @inlinable
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension ColorPixel where Model == GrayColorModel {
    
    @inlinable
    public var white: Double {
        get {
            return color.white
        }
        set {
            color.white = newValue
        }
    }
}

extension ColorPixel where Model == RGBColorModel {
    
    @inlinable
    public var red: Double {
        get {
            return color.red
        }
        set {
            color.red = newValue
        }
    }
    
    @inlinable
    public var green: Double {
        get {
            return color.green
        }
        set {
            color.green = newValue
        }
    }
    
    @inlinable
    public var blue: Double {
        get {
            return color.blue
        }
        set {
            color.blue = newValue
        }
    }
}

extension ColorPixel where Model == RGBColorModel {
    
    @inlinable
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
    
    @inlinable
    public var saturation: Double {
        get {
            return color.saturation
        }
        set {
            color.saturation = newValue
        }
    }
    
    @inlinable
    public var brightness: Double {
        get {
            return color.brightness
        }
        set {
            color.brightness = newValue
        }
    }
}

extension ColorPixel where Model == CMYColorModel {
    
    @inlinable
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @inlinable
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @inlinable
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
}

extension ColorPixel where Model == CMYKColorModel {
    
    @inlinable
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @inlinable
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @inlinable
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
    
    @inlinable
    public var black: Double {
        get {
            return color.black
        }
        set {
            color.black = newValue
        }
    }
}
