//
//  ColorSpace.swift
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

import Foundation

@_versioned
protocol _ColorSpaceBaseProtocol {
    
    var iccData: Data? { get }
    
    var localizedName: String? { get }
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    func _convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorModelProtocol
    
    func _convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol
    
    func _convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorModelProtocol
    
    func _convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol
    
    func _convert<S : Sequence, Destination: ColorSpaceBaseProtocol, R>(_ color: S, to other: Destination, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorModelProtocol
    
    func _convert<S : Sequence, Destination: ColorSpaceBaseProtocol, R: ColorPixelProtocol>(_ color: S, to other: Destination, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorPixelProtocol
    
    func _convert<S : Sequence, R>(_ color: S, from other: _ColorSpaceBaseProtocol, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorModelProtocol
    
    func _convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, from other: _ColorSpaceBaseProtocol, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorPixelProtocol
    
    var _linearTone: _ColorSpaceBaseProtocol { get }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var iccData: Data? {
        return nil
    }
}

@_versioned
protocol ColorSpaceBaseProtocol : _ColorSpaceBaseProtocol {
    
    associatedtype Model : ColorModelProtocol
    
    associatedtype LinearTone : _ColorSpaceBaseProtocol = LinearToneColorSpace<Self>
    
    func convertToLinear(_ color: Model) -> Model
    
    func convertFromLinear(_ color: Model) -> Model
    
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model
    
    func convertToXYZ(_ color: Model) -> XYZColorModel
    
    func convertFromXYZ(_ color: XYZColorModel) -> Model
    
    var linearTone: LinearTone { get }
}

extension ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.convertLinearToXYZ(self.convertToLinear(color))
    }
    
    @_versioned
    @_inlineable
    func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertFromLinear(self.convertLinearFromXYZ(color))
    }
}

extension ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func _convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorModelProtocol {
        return color.map { self.convertToLinear($0 as! Model) as! S.Element }
    }
    
    @_versioned
    @_inlineable
    func _convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol {
        return color.map { S.Element(color: self.convertToLinear($0.color as! Model) as! S.Element.Model, opacity: $0.opacity) }
    }
    
    @_versioned
    @_inlineable
    func _convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorModelProtocol {
        return color.map { self.convertFromLinear($0 as! Model) as! S.Element }
    }
    
    @_versioned
    @_inlineable
    func _convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol {
        return color.map { S.Element(color: self.convertFromLinear($0.color as! Model) as! S.Element.Model, opacity: $0.opacity) }
    }
    
    @_versioned
    @_inlineable
    func _convert<S : Sequence, Destination: ColorSpaceBaseProtocol, R>(_ color: S, to other: Destination, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorModelProtocol {
        return intent._convert(color, (self.cieXYZ, other.cieXYZ), algorithm, toXYZ: { self.convertToXYZ($0 as! Model) }, fromXYZ: { xyz, _ in other.convertFromXYZ(xyz) }) as! [R]
    }
    
    @_versioned
    @_inlineable
    func _convert<S : Sequence, Destination: ColorSpaceBaseProtocol, R: ColorPixelProtocol>(_ color: S, to other: Destination, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorPixelProtocol {
        return intent._convert(color, (self.cieXYZ, other.cieXYZ), algorithm, toXYZ: { self.convertToXYZ($0.color as! Model) }, fromXYZ: { xyz, pixel in R(color: other.convertFromXYZ(xyz) as! R.Model, opacity: pixel.opacity) })
    }
    
    @_versioned
    @_inlineable
    func _convert<S : Sequence, R>(_ color: S, from other: _ColorSpaceBaseProtocol, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorModelProtocol {
        return other._convert(color, to: self, intent: intent, algorithm)
    }
    
    @_versioned
    @_inlineable
    func _convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, from other: _ColorSpaceBaseProtocol, intent: RenderingIntent, _ algorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> [R] where S.Element: ColorPixelProtocol {
        return other._convert(color, to: self, intent: intent, algorithm)
    }
    
    @_versioned
    @_inlineable
    var _linearTone: _ColorSpaceBaseProtocol {
        return self.linearTone
    }
}

extension ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
        return x.sign == .plus ? gamma(x) : -gamma(-x)
    }
}

@_fixed_layout
public struct ColorSpace<Model : ColorModelProtocol> {
    
    @_versioned
    let base : _ColorSpaceBaseProtocol
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default
    
    @_versioned
    @_inlineable
    init(base : _ColorSpaceBaseProtocol) {
        self.base = base
    }
}

extension ColorSpace {
    
    @_inlineable
    public var localizedName: String? {
        return base.localizedName
    }
}

extension ColorSpace : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return localizedName.map { "\(ColorSpace.self)(localizedName: \($0))" } ?? "\(ColorSpace.self)"
    }
}

extension ColorSpace {
    
    @_inlineable
    public var iccData: Data? {
        return base.iccData
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convertToLinear(_ color: Model) -> Model {
        return self.convertToLinear(CollectionOfOne(color))[0]
    }
    
    @_inlineable
    public func convertToLinear<S: ColorPixelProtocol>(_ color: S) -> S where S.Model == Model {
        return self.convertToLinear(CollectionOfOne(color))[0]
    }
    
    @_inlineable
    public func convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element == Model {
        return base._convertToLinear(color)
    }
    
    @_inlineable
    public func convertToLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol, S.Element.Model == Model {
        return base._convertToLinear(color)
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return self.convertFromLinear(CollectionOfOne(color))[0]
    }
    
    @_inlineable
    public func convertFromLinear<S: ColorPixelProtocol>(_ color: S) -> S where S.Model == Model {
        return self.convertFromLinear(CollectionOfOne(color))[0]
    }
    
    @_inlineable
    public func convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element == Model {
        return base._convertFromLinear(color)
    }
    
    @_inlineable
    public func convertFromLinear<S : Sequence>(_ color: S) -> [S.Element] where S.Element: ColorPixelProtocol, S.Element.Model == Model {
        return base._convertFromLinear(color)
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> R {
        return self.convert(CollectionOfOne(color), to: other, intent: intent)[0]
    }
    
    @_inlineable
    public func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> R where S.Model == Model {
        return self.convert(CollectionOfOne(color), to: other, intent: intent)[0]
    }
    
    @_inlineable
    public func convert<S : Sequence, R>(_ color: S, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> [R] where S.Element == Model {
        return other.base._convert(color, from: self.base, intent: intent, (self.chromaticAdaptationAlgorithm, other.chromaticAdaptationAlgorithm))
    }
    
    @_inlineable
    public func convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> [R] where S.Element: ColorPixelProtocol, S.Element.Model == Model {
        return other.base._convert(color, from: self.base, intent: intent, (self.chromaticAdaptationAlgorithm, other.chromaticAdaptationAlgorithm))
    }
}

extension ColorSpace {
    
    @_inlineable
    public var linearTone: ColorSpace {
        return ColorSpace(base: base._linearTone)
    }
}

extension ColorSpace {
    
    @_inlineable
    public static var numberOfComponents: Int {
        return Model.numberOfComponents
    }
    
    @_inlineable
    public var numberOfComponents: Int {
        return Model.numberOfComponents
    }
    
    @_inlineable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Model.rangeOfComponent(i)
    }
    
    @_inlineable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Model.rangeOfComponent(i)
    }
}

