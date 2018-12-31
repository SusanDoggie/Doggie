//
//  ColorSpace.swift
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
protocol _ColorSpaceBaseProtocol: PolymorphicHashable {
    
    var iccData: Data? { get }
    
    var localizedName: String? { get }
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    func _convertToLinear<Model : ColorModelProtocol>(_ color: Model) -> Model
    
    func _convertFromLinear<Model : ColorModelProtocol>(_ color: Model) -> Model
    
    func _convertLinearToXYZ<Model : ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func _convertLinearFromXYZ<Model : ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    func _convertToXYZ<Model : ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func _convertFromXYZ<Model : ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    var _linearTone: _ColorSpaceBaseProtocol { get }
}

extension _ColorSpaceBaseProtocol {
    
    @inlinable
    var iccData: Data? {
        return nil
    }
}

@usableFromInline
protocol ColorSpaceBaseProtocol : _ColorSpaceBaseProtocol, Hashable {
    
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
    
    @inlinable
    func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.convertLinearToXYZ(self.convertToLinear(color))
    }
    
    @inlinable
    func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertFromLinear(self.convertLinearFromXYZ(color))
    }
}

extension ColorSpaceBaseProtocol {
    
    @inlinable
    func _convertToLinear<RModel : ColorModelProtocol>(_ color: RModel) -> RModel {
        return self.convertToLinear(color as! Model) as! RModel
    }
    
    @inlinable
    func _convertFromLinear<RModel : ColorModelProtocol>(_ color: RModel) -> RModel {
        return self.convertFromLinear(color as! Model) as! RModel
    }
    
    @inlinable
    func _convertLinearToXYZ<RModel : ColorModelProtocol>(_ color: RModel) -> XYZColorModel {
        return self.convertLinearToXYZ(color as! Model)
    }
    
    @inlinable
    func _convertLinearFromXYZ<RModel : ColorModelProtocol>(_ color: XYZColorModel) -> RModel {
        return self.convertLinearFromXYZ(color) as! RModel
    }
    
    @inlinable
    func _convertToXYZ<RModel : ColorModelProtocol>(_ color: RModel) -> XYZColorModel {
        return self.convertToXYZ(color as! Model)
    }
    
    @inlinable
    func _convertFromXYZ<RModel : ColorModelProtocol>(_ color: XYZColorModel) -> RModel {
        return self.convertFromXYZ(color) as! RModel
    }
    
    @inlinable
    var _linearTone: _ColorSpaceBaseProtocol {
        return self.linearTone
    }
}

extension ColorSpaceBaseProtocol {
    
    @inlinable
    func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
        return x.sign == .plus ? gamma(x) : -gamma(-x)
    }
}

@_fixed_layout
public struct ColorSpace<Model : ColorModelProtocol> : ColorSpaceProtocol, Hashable {
    
    @usableFromInline
    let base : _ColorSpaceBaseProtocol
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default

    @usableFromInline
    var cache = Cache<String>()
    
    @inlinable
    init(base : _ColorSpaceBaseProtocol) {
        self.base = base
    }
}

extension ColorSpace {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(chromaticAdaptationAlgorithm)
        base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: ColorSpace<Model>, rhs: ColorSpace<Model>) -> Bool {
        return lhs.chromaticAdaptationAlgorithm == rhs.chromaticAdaptationAlgorithm && (lhs.cache.identifier == rhs.cache.identifier || lhs.base.isEqual(rhs.base))
    }
}

extension ColorSpace {
    
    @inlinable
    public var localizedName: String? {
        return base.localizedName
    }
}

extension ColorSpace : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return localizedName.map { "\(ColorSpace.self)(localizedName: \($0))" } ?? "\(ColorSpace.self)"
    }
}

extension ColorSpace {
    
    @inlinable
    public var iccData: Data? {
        return base.iccData
    }
}

extension ColorSpace {
    
    @inlinable
    public var cieXYZ: ColorSpace<XYZColorModel> {
        return ColorSpace<XYZColorModel>(base: self.base.cieXYZ)
    }
    
    @inlinable
    public func convertToLinear(_ color: Model) -> Model {
        return self.base._convertToLinear(color)
    }
    
    @inlinable
    public func convertFromLinear(_ color: Model) -> Model {
        return self.base._convertFromLinear(color)
    }
    
    @inlinable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return self.base._convertLinearToXYZ(color)
    }
    
    @inlinable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return self.base._convertLinearFromXYZ(color)
    }
    
    @inlinable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.base._convertToXYZ(color)
    }
    
    @inlinable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.base._convertFromXYZ(color)
    }
}

extension ColorSpace {
    
    @inlinable
    public func convertToLinear<S: ColorPixelProtocol>(_ color: S) -> S where S.Model == Model {
        return S(color: self.convertToLinear(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertFromLinear<S: ColorPixelProtocol>(_ color: S) -> S where S.Model == Model {
        return S(color: self.convertFromLinear(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertLinearToXYZ<S: ColorPixelProtocol, T: ColorPixelProtocol>(_ color: S) -> T where S.Model == Model, T.Model == XYZColorModel {
        return T(color: self.convertLinearToXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertLinearFromXYZ<S: ColorPixelProtocol, T: ColorPixelProtocol>(_ color: T) -> S where S.Model == Model, T.Model == XYZColorModel {
        return S(color: self.convertLinearFromXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertToXYZ<S: ColorPixelProtocol, T: ColorPixelProtocol>(_ color: S) -> T where S.Model == Model, T.Model == XYZColorModel {
        return T(color: self.convertToXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertFromXYZ<S: ColorPixelProtocol, T: ColorPixelProtocol>(_ color: T) -> S where S.Model == Model, T.Model == XYZColorModel {
        return S(color: self.convertFromXYZ(color.color), opacity: color.opacity)
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    @inline(__always)
    func _intentMatrix(to other: CIEXYZColorSpace, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm, intent: RenderingIntent) -> Matrix {
        switch intent {
        case .perceptual: return self.chromaticAdaptationMatrix(to: other, chromaticAdaptationAlgorithm)
        case .absoluteColorimetric: return Matrix.identity
        case .relativeColorimetric: return CIEXYZColorSpace(white: self.white).chromaticAdaptationMatrix(to: CIEXYZColorSpace(white: other.white), chromaticAdaptationAlgorithm)
        }
    }
}

extension ColorSpace {
    
    @inlinable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> R {
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return other.convertFromXYZ(self.convertToXYZ(color) * matrix)
    }
    
    @inlinable
    public func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> R where S.Model == Model {
        return R(color: self.convert(color.color, to: other, intent: intent), opacity: color.opacity)
    }
}

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func convert<S, R>(_ color: MappedBuffer<S>, to other: ColorSpace<R.Model>, intent: RenderingIntent) -> MappedBuffer<R> where S: ColorPixelProtocol, S.Model == Model, R: ColorPixelProtocol {
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return color.map { R(color: other.convertFromXYZ(self.convertToXYZ($0.color) * matrix), opacity: $0.opacity) }
    }
}

extension ColorSpace {
    
    @inlinable
    public var linearTone: ColorSpace {
        return ColorSpace(base: base._linearTone)
    }
    
    @inlinable
    public var referenceWhite: XYZColorModel {
        return base.cieXYZ.white
    }
    
    @inlinable
    public var referenceBlack: XYZColorModel {
        return base.cieXYZ.black
    }
    
    @inlinable
    public var luminance: Double {
        return base.cieXYZ.luminance
    }
}

extension ColorSpace {
    
    @inlinable
    public static var numberOfComponents: Int {
        return Model.numberOfComponents
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return Model.numberOfComponents
    }
    
    @inlinable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Model.rangeOfComponent(i)
    }
    
    @inlinable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Model.rangeOfComponent(i)
    }
}

