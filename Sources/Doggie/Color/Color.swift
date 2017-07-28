//
//  Color.swift
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

public struct Color<Model : ColorModelProtocol> {
    
    public var colorSpace: ColorSpace<Model>
    
    public var color: Model
    
    public var opacity: Double {
        didSet {
            opacity = opacity.clamped(to: 0...1)
        }
    }
    
    @_inlineable
    public init<P : ColorPixelProtocol>(colorSpace: ColorSpace<Model>, color: P) where P.Model == Model {
        self.colorSpace = colorSpace
        self.color = color.color
        self.opacity = color.opacity
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self.colorSpace = colorSpace
        self.color = color
        self.opacity = opacity
    }
}

extension Color where Model == GrayColorModel {
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension Color where Model == RGBColorModel {
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
}

extension Color where Model == CMYColorModel {
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
}

extension Color where Model == CMYKColorModel {
    
    @_inlineable
    public init(colorSpace: ColorSpace<Model>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension Color where Model == GrayColorModel {
    
    @_inlineable
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
    
    @_inlineable
    public var red: Double {
        get {
            return color.red
        }
        set {
            color.red = newValue
        }
    }
    
    @_inlineable
    public var green: Double {
        get {
            return color.green
        }
        set {
            color.green = newValue
        }
    }
    
    @_inlineable
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
    
    @_inlineable
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
    
    @_inlineable
    public var saturation: Double {
        get {
            return color.saturation
        }
        set {
            color.saturation = newValue
        }
    }
    
    @_inlineable
    public var brightness: Double {
        get {
            return color.brightness
        }
        set {
            color.brightness = newValue
        }
    }
}

extension Color where Model == CMYKColorModel {
    
    @_inlineable
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @_inlineable
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @_inlineable
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
    
    @_inlineable
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
    
    @_inlineable
    public static var numberOfComponents: Int {
        return Model.numberOfComponents + 1
    }
    
    @_inlineable
    public var numberOfComponents: Int {
        return Color.numberOfComponents
    }
    
    @_inlineable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        if i < Model.numberOfComponents {
            return Model.rangeOfComponent(i)
        } else if i == Model.numberOfComponents {
            return 0...1
        } else {
            fatalError()
        }
    }
    
    @_inlineable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Color.rangeOfComponent(i)
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color[index]
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @_inlineable
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
    
    @_inlineable
    public func normalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color.normalizedComponent(index)
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @_inlineable
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
    
    @_inlineable
    public func linearTone() -> Color {
        return Color(colorSpace: colorSpace.linearTone, color: colorSpace.convertToLinear(color), opacity: opacity)
    }
}

extension Color {
    
    @_inlineable
    public var isOpaque: Bool {
        return opacity >= 1
    }
}

extension Color {
    
    @_inlineable
    public func convert<R>(to colorSpace: ColorSpace<R>, intent: RenderingIntent = .default) -> Color<R> {
        return Color<R>(colorSpace: colorSpace, color: self.colorSpace.convert(color, to: colorSpace, intent: intent), opacity: opacity)
    }
}

extension Color {
    
    @_inlineable
    public func blended<C>(source: Color<C>, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) -> Color {
        let source = source.convert(to: colorSpace)
        let color = ColorPixel(color: self.color, opacity: self.opacity).blended(source: ColorPixel(color: source.color, opacity: source.opacity), blendMode: blendMode, compositingMode: compositingMode)
        return Color(colorSpace: colorSpace, color: color.color, opacity: color.opacity)
    }
    
    @_inlineable
    public mutating func blend<C>(source: Color<C>, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}
