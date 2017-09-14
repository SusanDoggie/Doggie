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
    
    func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    func normalizedComponent(_ index: Int) -> Double
    
    mutating func setNormalizedComponent(_ index: Int, _ value: Double)
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    var _colorSpace: AnyColorSpaceBaseProtocol { get }
    
    func _linearTone() -> AnyColorBaseProtocol
    
    func _blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol
    
    func _blendedTo(destination: AnyColorBaseProtocol, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol
    
    func _convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent) -> Color<Model>
    
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyColorBaseProtocol
    
    func _draw<Model>(context: ImageContext<Model>, shape: Shape, winding: Shape.WindingRule)
}

extension Color : AnyColorBaseProtocol {
    
    @_versioned
    @_inlineable
    var _colorSpace: AnyColorSpaceBaseProtocol {
        return self.colorSpace
    }
    
    @_versioned
    @_inlineable
    func _linearTone() -> AnyColorBaseProtocol {
        return self.linearTone()
    }
    
    @_versioned
    @_inlineable
    func _blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol {
        return self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
    
    @_versioned
    @_inlineable
    func _blendedTo(destination: AnyColorBaseProtocol, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> AnyColorBaseProtocol {
        return destination._blended(source: self, blendMode: blendMode, compositingMode: compositingMode)
    }
    
    @_versioned
    @_inlineable
    func _convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent) -> Color<Model> {
        return self.convert(to: colorSpace, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return colorSpace._convert(self, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func _draw<Model>(context: ImageContext<Model>, shape: Shape, winding: Shape.WindingRule) {
        context.draw(shape: shape, winding: winding, color: self)
    }
}

@_fixed_layout
public struct AnyColor {
    
    @_versioned
    var _base: AnyColorBaseProtocol
    
    @_versioned
    @_inlineable
    init(base: AnyColorBaseProtocol) {
        self._base = base
    }
    
    @_inlineable
    public var base: Any {
        return _base
    }
}

extension AnyColor {
    
    @_inlineable
    public init<S : Sequence>(colorSpace: AnyColorSpace, components: S, opacity: Double) where S.Element == Double {
        self.init(base: colorSpace._base._createColor(components: components, opacity: opacity))
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
        return _base.component(index)
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        _base.setComponent(index, value)
    }
    
    @_inlineable
    public func normalizedComponent(_ index: Int) -> Double {
        return _base.normalizedComponent(index)
    }
    
    @_inlineable
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        _base.setNormalizedComponent(index, value)
    }
    
    @_inlineable
    public var opacity: Double {
        get {
            return _base.opacity
        }
        set {
            _base.opacity = newValue
        }
    }
}

extension AnyColor {
    
    @_inlineable
    public var isOpaque: Bool {
        return _base.isOpaque
    }
}

extension AnyColor {
    
    @_inlineable
    public var numberOfComponents: Int {
        return _base.numberOfComponents
    }
    
    @_inlineable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return _base.rangeOfComponent(i)
    }
    
    @_inlineable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
    
    @_inlineable
    public init<Model>(_ color: Color<Model>) {
        self._base = color
    }
    
    @_inlineable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(base: _base._convert(to: colorSpace._base, intent: intent))
    }
    
    @_inlineable
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> Color<Model> {
        return _base._convert(to: colorSpace, intent: intent)
    }
}

extension AnyColor {
    
    @_inlineable
    public func linearTone() -> AnyColor {
        return AnyColor(base: _base._linearTone())
    }
}

extension AnyColor {
    
    @_inlineable
    public func blended<C>(source: Color<C>, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) -> AnyColor {
        return AnyColor(base: _base._blended(source: source, blendMode: blendMode, compositingMode: compositingMode))
    }
    
    @_inlineable
    public func blended(source: AnyColor, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) -> AnyColor {
        return AnyColor(base: source._base._blendedTo(destination: _base, blendMode: blendMode, compositingMode: compositingMode))
    }
    
    @_inlineable
    public mutating func blend<C>(source: Color<C>, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
    
    @_inlineable
    public mutating func blend(source: AnyColor, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}

extension Color {
    
    @_inlineable
    public func blended(source: AnyColor, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) -> Color {
        return source._base._blendedTo(destination: self, blendMode: blendMode, compositingMode: compositingMode) as! Color
    }
    
    @_inlineable
    public mutating func blend(source: AnyColor, blendMode: ColorBlendMode = .default, compositingMode: ColorCompositingMode = .default) {
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

extension ImageContext {
    
    @_inlineable
    public func draw(shape: Shape, winding: Shape.WindingRule, color: AnyColor) {
        color._base._draw(context: self, shape: shape, winding: winding)
    }
}

extension Color {
    
    @_inlineable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(self).convert(to: colorSpace, intent: intent)
    }
}
