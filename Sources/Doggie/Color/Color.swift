//
//  Color.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct Color<Model: ColorModelProtocol>: ColorProtocol, Hashable {
    
    public var colorSpace: Doggie.ColorSpace<Model>
    
    public var color: Model
    
    public var opacity: Double {
        didSet {
            opacity = opacity.clamped(to: 0...1)
        }
    }
    
    @inlinable
    public init<P: ColorPixelProtocol>(colorSpace: Doggie.ColorSpace<Model>, color: P) where P.Model == Model {
        self.colorSpace = colorSpace
        self.color = color.color
        self.opacity = color.opacity
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self.colorSpace = colorSpace
        self.color = color
        self.opacity = opacity
    }
}

extension Color where Model == XYZColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, x: Double, y: Double, z: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(x: x, y: y, z: z), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, luminance: Double, point: Point, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension Color where Model == YxyColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, luminance: Double, point: Point, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: YxyColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: YxyColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension Color where Model == LabColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, lightness: Double, a: Double, b: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LabColorModel(lightness: lightness, a: a, b: b), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LabColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension Color where Model == LuvColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, lightness: Double, u: Double, v: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LuvColorModel(lightness: lightness, u: u, v: v), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LuvColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension Color where Model == GrayColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension Color where Model == RGBColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model> = .default, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
}

extension Color where Model == CMYColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
}

extension Color where Model == CMYKColorModel {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension Color where Model == GrayColorModel {
    
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

extension Color where Model == RGBColorModel {
    
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

extension Color where Model == RGBColorModel {
    
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

extension Color where Model == CMYColorModel {
    
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

extension Color where Model == CMYKColorModel {
    
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

extension Color {
    
    @inlinable
    public func with(opacity: Double) -> Color {
        return Color(colorSpace: colorSpace, color: color, opacity: opacity)
    }
}

extension Color {
    
    @inlinable
    public static var numberOfComponents: Int {
        return Model.numberOfComponents + 1
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return Color.numberOfComponents
    }
    
    @inlinable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        if i < Model.numberOfComponents {
            return Model.rangeOfComponent(i)
        } else if i == Model.numberOfComponents {
            return 0...1
        } else {
            fatalError()
        }
    }
    
    @inlinable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Color.rangeOfComponent(i)
    }
    
    @inlinable
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color[index]
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @inlinable
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

extension Color {
    
    @inlinable
    public func normalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color.normalizedComponent(index)
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @inlinable
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

extension Color {
    
    @inlinable
    public var cieXYZ: Color<XYZColorModel> {
        return Color<XYZColorModel>(colorSpace: colorSpace.cieXYZ, color: colorSpace.convertToXYZ(color), opacity: opacity)
    }
}

extension Color {
    
    @inlinable
    public func linearTone() -> Color {
        return Color(colorSpace: colorSpace.linearTone, color: colorSpace.convertToLinear(color), opacity: opacity)
    }
}

extension Color {
    
    @inlinable
    public var isOpaque: Bool {
        return opacity >= 1
    }
}

extension Color {
    
    @inlinable
    public func convert<Model>(to colorSpace: Doggie.ColorSpace<Model>, intent: RenderingIntent = .default) -> Color<Model> {
        return Color<Model>(colorSpace: colorSpace, color: self.colorSpace.convert(self.color, to: colorSpace, intent: intent), opacity: self.opacity)
    }
}

extension Color {
    
    @inlinable
    public func blended<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) -> Color {
        let source = source.convert(to: colorSpace, intent: .default)
        let color = Float64ColorPixel(color: self.color, opacity: self.opacity).blended(source: Float64ColorPixel(color: source.color, opacity: source.opacity), compositingMode: compositingMode, blendMode: blendMode)
        return Color(colorSpace: colorSpace, color: color.color, opacity: color.opacity)
    }
    
    @inlinable
    public mutating func blend<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
}

