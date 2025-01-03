//
//  Color.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
public struct Color<Model: ColorModel>: ColorProtocol, _ColorProtocol {
    
    public var colorSpace: DoggieGraphics.ColorSpace<Model>
    
    public var color: Model
    
    public var opacity: Double {
        didSet {
            opacity = opacity.clamped(to: 0...1)
        }
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self.colorSpace = colorSpace
        self.color = color
        self.opacity = opacity
    }
}

extension Color where Model == XYZColorModel {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, x: Double, y: Double, z: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(x: x, y: y, z: z), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, luminance: Double, point: Point, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: XYZColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension Color where Model == YxyColorModel {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, luminance: Double, point: Point, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: YxyColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: YxyColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension Color where Model == LabColorModel {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, lightness: Double, a: Double, b: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LabColorModel(lightness: lightness, a: a, b: b), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LabColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
    
    @inlinable
    public var lightness: Double {
        get {
            return color.lightness
        }
        set {
            color.lightness = newValue
        }
    }
    
    @inlinable
    public var a: Double {
        get {
            return color.a
        }
        set {
            color.a = newValue
        }
    }
    
    @inlinable
    public var b: Double {
        get {
            return color.b
        }
        set {
            color.b = newValue
        }
    }
    
    @inlinable
    public var chroma: Double {
        get {
            return color.chroma
        }
        set {
            color.chroma = newValue
        }
    }
    
    @inlinable
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
}

extension Color where Model == LuvColorModel {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, lightness: Double, u: Double, v: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LuvColorModel(lightness: lightness, u: u, v: v), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LuvColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
    
    @inlinable
    public var lightness: Double {
        get {
            return color.lightness
        }
        set {
            color.lightness = newValue
        }
    }
    
    @inlinable
    public var u: Double {
        get {
            return color.u
        }
        set {
            color.u = newValue
        }
    }
    
    @inlinable
    public var v: Double {
        get {
            return color.v
        }
        set {
            color.v = newValue
        }
    }
    
    @inlinable
    public var chroma: Double {
        get {
            return color.chroma
        }
        set {
            color.chroma = newValue
        }
    }
    
    @inlinable
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
}

extension Color where Model == GrayColorModel {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
    
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
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<Model> = .default, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
    
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
    public init(colorSpace: DoggieGraphics.ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
    
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
    public init(colorSpace: DoggieGraphics.ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
    
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
    public var cieXYZ: Color<XYZColorModel> {
        let _colorSpace = colorSpace.cieXYZ
        let _color = colorSpace.convertToXYZ(color)
        return Color<XYZColorModel>(colorSpace: _colorSpace, color: _color, opacity: opacity)
    }
}

extension Color {
    
    @inlinable
    public func linearTone() -> Color {
        let _colorSpace = colorSpace.linearTone
        let _color = colorSpace.convertToLinear(color)
        return Color(colorSpace: _colorSpace, color: _color, opacity: opacity)
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
    public func convert<Model>(to colorSpace: DoggieGraphics.ColorSpace<Model>, intent: RenderingIntent = .default) -> Color<Model> {
        let _color = self.colorSpace.convert(self.color, to: colorSpace, intent: intent)
        return Color<Model>(colorSpace: colorSpace, color: _color, opacity: self.opacity)
    }
}
