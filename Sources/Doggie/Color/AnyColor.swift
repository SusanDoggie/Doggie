//
//  AnyColor.swift
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

@_versioned
protocol AnyColorBaseProtocol {
    
    var numberOfComponents: Int { get }
    
    var colorSpace: AnyColorSpaceBaseProtocol { get }
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    var opacity: Double { get set }
    
    func blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol
    
    func blendedTo(destination: AnyColorBaseProtocol, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol
    
    func convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyColorBaseProtocol
    
    func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent) -> Color<Model>
}

@_versioned
@_fixed_layout
struct AnyColorBase<Model : ColorModelProtocol> : AnyColorBaseProtocol {
    
    @_versioned
    var base : Color<Model>
    
    @_versioned
    @_inlineable
    init(base: Color<Model>) {
        self.base = base
    }
    
    @_versioned
    @_inlineable
    func component(_ index: Int) -> Double {
        return base.color.component(index)
    }
    
    @_versioned
    @_inlineable
    mutating func setComponent(_ index: Int, _ value: Double) {
        base.color.setComponent(index, value)
    }
    
    @_versioned
    @_inlineable
    var opacity: Double {
        get {
            return base.opacity
        }
        set {
            base.opacity = newValue
        }
    }
    
    @_versioned
    @_inlineable
    var numberOfComponents: Int {
        return Model.numberOfComponents
    }
    
    @_versioned
    @_inlineable
    func blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol {
        return AnyColorBase(base: base.blended(source: source, blendMode: blendMode, compositingMode: compositingMode))
    }
    
    @_versioned
    @_inlineable
    func blendedTo(destination: AnyColorBaseProtocol, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol {
        return destination.blended(source: base, blendMode: blendMode, compositingMode: compositingMode)
    }
    
    @_versioned
    @_inlineable
    var colorSpace: AnyColorSpaceBaseProtocol {
        return AnyColorSpaceBase(base: base.colorSpace)
    }
    
    @_versioned
    @_inlineable
    func convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return colorSpace.convert(base, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent) -> Color<Model> {
        return base.convert(to: colorSpace, intent: intent)
    }
}

@_fixed_layout
public struct AnyColor {
    
    @_versioned
    var base: AnyColorBaseProtocol
    
    @_versioned
    @_inlineable
    init(base: AnyColorBaseProtocol) {
        self.base = base
    }
}

extension AnyColor {
    
    @_inlineable
    public init<S : Sequence>(colorSpace: AnyColorSpace, components: S, opacity: Double) where S.Element == Double {
        self.init(base: colorSpace.base.createColor(components: components, opacity: opacity))
    }
    
    @_inlineable
    public init<P : ColorPixelProtocol>(colorSpace: ColorSpace<P.Model>, color: P) {
        self.init(Color(colorSpace: colorSpace, color: color))
    }
    
    @_inlineable
    public init<Model>(colorSpace: ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self.init(Color(colorSpace: colorSpace, color: color, opacity: opacity))
    }
}

extension AnyColor {
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        return base.component(index)
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        base.setComponent(index, value)
    }
    
    @_inlineable
    public var opacity: Double {
        get {
            return base.opacity
        }
        set {
            base.opacity = newValue
        }
    }
}

extension AnyColor {
    
    @_inlineable
    public var numberOfComponents: Int {
        return base.numberOfComponents
    }
    
    @_inlineable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: base.colorSpace)
    }
    
    @_inlineable
    public init<Model>(_ color: Color<Model>) {
        self.base = AnyColorBase(base: color)
    }
    
    @_inlineable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(base: base.convert(to: colorSpace.base, intent: intent))
    }
    
    @_inlineable
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> Color<Model> {
        return base.convert(to: colorSpace, intent: intent)
    }
}

extension AnyColor {
    
    @_inlineable
    public func blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColor {
        return AnyColor(base: base.blended(source: source, blendMode: blendMode, compositingMode: compositingMode))
    }
    
    @_inlineable
    public func blended(source: AnyColor, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColor {
        return AnyColor(base: source.base.blendedTo(destination: base, blendMode: blendMode, compositingMode: compositingMode))
    }
    
    @_inlineable
    public mutating func blend<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
    
    @_inlineable
    public mutating func blend(source: AnyColor, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}

extension AnyColor {
    
    @_inlineable
    public init(colorSpace: ColorSpace<GrayColorModel>, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<RGBColorModel>, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<RGBColorModel>, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<CMYColorModel>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace<CMYKColorModel>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension Color {
    
    @_inlineable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(self).convert(to: colorSpace, intent: intent)
    }
}
