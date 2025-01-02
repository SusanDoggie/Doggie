//
//  AnyColor.swift
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
public struct AnyColor: ColorProtocol {
    
    @usableFromInline
    var _base: any _ColorProtocol
    
    @inlinable
    init(base color: any _ColorProtocol) {
        self._base = color
    }
    
    @inlinable
    public init(_ color: AnyColor) {
        self = color
    }
    
    @inlinable
    public init<Model>(_ color: Color<Model>) {
        self._base = color
    }
}

extension _ColorSpaceProtocol {
    
    @inlinable
    func _create_color<S>(components: S, opacity: Double) -> any _ColorProtocol where S: Sequence, S.Element == Double {
        var color = Model()
        var counter = 0
        for (i, v) in components.enumerated() {
            precondition(i < Model.numberOfComponents, "invalid count of components.")
            color[i] = v
            counter = i
        }
        precondition(counter == Model.numberOfComponents - 1, "invalid count of components.")
        return Color(colorSpace: self as! ColorSpace<Model>, color: color, opacity: opacity)
    }
}

extension AnyColor {
    
    @inlinable
    public init<S: Sequence>(colorSpace: AnyColorSpace, components: S, opacity: Double = 1) where S.Element == Double {
        self._base = colorSpace._base._create_color(components: components, opacity: opacity)
    }
    
    @inlinable
    public init<Model: ColorModel>(colorSpace: DoggieGraphics.ColorSpace<Model>, color: Model, opacity: Double = 1) {
        self._base = Color(colorSpace: colorSpace, color: color, opacity: opacity)
    }
}

extension AnyColor {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyColor, rhs: AnyColor) -> Bool {
        return lhs._base._equalTo(rhs._base)
    }
}

extension AnyColor {
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<LabColorModel> = .default, lightness: Double, a: Double, b: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LabColorModel(lightness: lightness, a: a, b: b), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<LuvColorModel> = .default, lightness: Double, u: Double, v: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: LuvColorModel(lightness: lightness, u: u, v: v), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<GrayColorModel> = .default, white: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<RGBColorModel> = .default, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<RGBColorModel> = .default, hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<CMYColorModel>, cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
    
    @inlinable
    public init(colorSpace: DoggieGraphics.ColorSpace<CMYKColorModel>, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension _ColorProtocol {
    
    @inlinable
    var _colorSpace: any _ColorSpaceProtocol {
        return colorSpace
    }
}

extension AnyColor {
    
    @inlinable
    public var base: any ColorProtocol {
        return self._base
    }
    
    @inlinable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
    
    @inlinable
    public func linearTone() -> AnyColor {
        return AnyColor(base: _base.linearTone())
    }
    
    @inlinable
    public var cieXYZ: Color<XYZColorModel> {
        return _base.cieXYZ
    }
    
    @inlinable
    public func with(opacity: Double) -> AnyColor {
        return AnyColor(base: _base.with(opacity: opacity))
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

extension _ColorSpaceProtocol {
    
    @inlinable
    func _convert<Model>(color: Color<Model>, intent: RenderingIntent) -> any _ColorProtocol {
        return color.convert(to: self as! ColorSpace<Model>, intent: intent)
    }
}

extension Color {
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyColor {
        return AnyColor(base: colorSpace._base._convert(color: self, intent: intent))
    }
}
