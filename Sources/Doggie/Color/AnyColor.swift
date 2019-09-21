//
//  AnyColor.swift
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

@usableFromInline
protocol AnyColorBaseProtocol: PolymorphicHashable {
    
    var _colorSpace: AnyColorSpaceBaseProtocol { get }
    
    func _linearTone() -> AnyColorBaseProtocol
    
    var cieXYZ: Color<XYZColorModel> { get }
    
    func _with(opacity: Double) -> AnyColorBaseProtocol
    
    var numberOfComponents: Int { get }
    
    func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    func normalizedComponent(_ index: Int) -> Double
    
    mutating func setNormalizedComponent(_ index: Int, _ value: Double)
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent) -> Color<Model>
    
    func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent) -> AnyColor
    
    func _blended<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> AnyColorBaseProtocol
}

extension Color : AnyColorBaseProtocol {
    
    @inlinable
    var _colorSpace: AnyColorSpaceBaseProtocol {
        return self.colorSpace
    }
    
    @inlinable
    func _linearTone() -> AnyColorBaseProtocol {
        return self.linearTone()
    }
    
    @inlinable
    func _with(opacity: Double) -> AnyColorBaseProtocol {
        return self.with(opacity: opacity)
    }
    
    @inlinable
    func _blended<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> AnyColorBaseProtocol {
        return self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
}

@frozen
public struct AnyColor : ColorProtocol, Hashable {
    
    @usableFromInline
    var _base: AnyColorBaseProtocol
    
    @inlinable
    init(base: AnyColorBaseProtocol) {
        self._base = base
    }
    
    @inlinable
    public var base: Any {
        return _base
    }
}

extension AnyColor {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyColor, rhs: AnyColor) -> Bool {
        return lhs._base.isEqual(rhs._base)
    }
}

extension AnyColor {
    
    @inlinable
    public init<S : Sequence>(colorSpace: AnyColorSpace, components: S, opacity: Double = 1) where S.Element == Double {
        self.init(base: colorSpace._base._create_color(components: components, opacity: opacity))
    }
    
    @inlinable
    public init<P : ColorPixelProtocol>(colorSpace: Doggie.ColorSpace<P.Model>, color: P) {
        self.init(Color(colorSpace: colorSpace, color: color))
    }
    
    @inlinable
    public init<Model>(colorSpace: Doggie.ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self.init(Color(colorSpace: colorSpace, color: color, opacity: opacity))
    }
    
    @inlinable
    public init<Model>(_ color: Color<Model>) {
        self._base = color
    }
    
    @inlinable
    public init(_ color: AnyColor) {
        self = color
    }
}

extension AnyColor {
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<GrayColorModel> = .default, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<RGBColorModel> = .default, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<RGBColorModel> = .default, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<CMYColorModel>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: Doggie.ColorSpace<CMYKColorModel>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension AnyColor {
    
    @inlinable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
    
    @inlinable
    public func linearTone() -> AnyColor {
        return AnyColor(base: _base._linearTone())
    }
    
    @inlinable
    public var cieXYZ: Color<XYZColorModel> {
        return _base.cieXYZ
    }
    
    @inlinable
    public func with(opacity: Double) -> AnyColor {
        return AnyColor(base: _base._with(opacity: opacity))
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return _base.numberOfComponents
    }
    
    @inlinable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return _base.rangeOfComponent(i)
    }
    
    @inlinable
    public func component(_ index: Int) -> Double {
        return _base.component(index)
    }
    
    @inlinable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        return _base.setComponent(index, value)
    }
    
    @inlinable
    public func normalizedComponent(_ index: Int) -> Double {
        return _base.normalizedComponent(index)
    }
    
    @inlinable
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        return _base.setNormalizedComponent(index, value)
    }
    
    @inlinable
    public var opacity: Double {
        get {
            return _base.opacity
        }
        set {
            _base.opacity = newValue
        }
    }
    
    @inlinable
    public var isOpaque: Bool {
        return _base.isOpaque
    }
    
    @inlinable
    public func convert<Model>(to colorSpace: Color<Model>.ColorSpace, intent: RenderingIntent = .default) -> Color<Model> {
        return _base.convert(to: colorSpace, intent: intent)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return _base.convert(to: colorSpace, intent: intent)
    }
}

extension AnyColor {
    
    @inlinable
    public func blended<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) -> AnyColor {
        return AnyColor(base: _base._blended(source: source, compositingMode: compositingMode, blendMode: blendMode))
    }
    
    @inlinable
    public mutating func blend<C: ColorProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
}

extension Color {
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(base: colorSpace._base._convert(color: self, intent: intent))
    }
}

