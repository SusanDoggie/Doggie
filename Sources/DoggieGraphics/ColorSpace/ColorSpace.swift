//
//  ColorSpace.swift
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

@usableFromInline
protocol _ColorSpaceBaseProtocol: PolymorphicHashable {
    
    var iccData: Data? { get }
    
    var localizedName: String? { get }
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    func _convertToLinear<Model: ColorModel>(_ color: Model) -> Model
    
    func _convertFromLinear<Model: ColorModel>(_ color: Model) -> Model
    
    func _convertLinearToXYZ<Model: ColorModel>(_ color: Model) -> XYZColorModel
    
    func _convertLinearFromXYZ<Model: ColorModel>(_ color: XYZColorModel) -> Model
    
    func _convertToXYZ<Model: ColorModel>(_ color: Model) -> XYZColorModel
    
    func _convertFromXYZ<Model: ColorModel>(_ color: XYZColorModel) -> Model
    
    var _linearTone: _ColorSpaceBaseProtocol { get }
    
    func isStorageEqual(_ other: _ColorSpaceBaseProtocol) -> Bool
}

extension _ColorSpaceBaseProtocol {
    
    @inlinable
    var iccData: Data? {
        return nil
    }
}

@usableFromInline
protocol ColorSpaceBaseProtocol: _ColorSpaceBaseProtocol, Hashable {
    
    associatedtype Model: ColorModel
    
    associatedtype LinearTone: _ColorSpaceBaseProtocol = LinearToneColorSpace<Self>
    
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
    func _convertToLinear<RModel: ColorModel>(_ color: RModel) -> RModel {
        return self.convertToLinear(color as! Model) as! RModel
    }
    
    @inlinable
    func _convertFromLinear<RModel: ColorModel>(_ color: RModel) -> RModel {
        return self.convertFromLinear(color as! Model) as! RModel
    }
    
    @inlinable
    func _convertLinearToXYZ<RModel: ColorModel>(_ color: RModel) -> XYZColorModel {
        return self.convertLinearToXYZ(color as! Model)
    }
    
    @inlinable
    func _convertLinearFromXYZ<RModel: ColorModel>(_ color: XYZColorModel) -> RModel {
        return self.convertLinearFromXYZ(color) as! RModel
    }
    
    @inlinable
    func _convertToXYZ<RModel: ColorModel>(_ color: RModel) -> XYZColorModel {
        return self.convertToXYZ(color as! Model)
    }
    
    @inlinable
    func _convertFromXYZ<RModel: ColorModel>(_ color: XYZColorModel) -> RModel {
        return self.convertFromXYZ(color) as! RModel
    }
    
    @inlinable
    var _linearTone: _ColorSpaceBaseProtocol {
        return self.linearTone
    }
    
    @inlinable
    func isStorageEqual(_ other: _ColorSpaceBaseProtocol) -> Bool {
        return self.isEqual(other)
    }
}

extension ColorSpaceBaseProtocol {
    
    @inlinable
    func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
        return x.sign == .plus ? gamma(x) : -gamma(-x)
    }
}

@frozen
public struct ColorSpace<Model: ColorModel>: ColorSpaceProtocol, Hashable {
    
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
        return lhs.chromaticAdaptationAlgorithm == rhs.chromaticAdaptationAlgorithm && lhs.base.isEqual(rhs.base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: ColorSpace<Model>) -> Bool {
        return self.chromaticAdaptationAlgorithm == other.chromaticAdaptationAlgorithm && self.base.isStorageEqual(other.base)
    }
}

extension ColorSpace {
    
    @inlinable
    public var localizedName: String? {
        return base.localizedName
    }
}

extension ColorSpace: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return localizedName.map { "\(ColorSpace.self)(localizedName: \($0))" } ?? "\(ColorSpace.self)"
    }
}

extension ColorSpace {
    
    @inlinable
    public var model: _ColorModel.Type {
        return Model.self
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
    public func convertToLinear<S: ColorPixel>(_ color: S) -> S where S.Model == Model {
        return S(color: self.convertToLinear(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertFromLinear<S: ColorPixel>(_ color: S) -> S where S.Model == Model {
        return S(color: self.convertFromLinear(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertLinearToXYZ<S: ColorPixel, T: ColorPixel>(_ color: S) -> T where S.Model == Model, T.Model == XYZColorModel {
        return T(color: self.convertLinearToXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertLinearFromXYZ<S: ColorPixel, T: ColorPixel>(_ color: T) -> S where S.Model == Model, T.Model == XYZColorModel {
        return S(color: self.convertLinearFromXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertToXYZ<S: ColorPixel, T: ColorPixel>(_ color: S) -> T where S.Model == Model, T.Model == XYZColorModel {
        return T(color: self.convertToXYZ(color.color), opacity: color.opacity)
    }
    
    @inlinable
    public func convertFromXYZ<S: ColorPixel, T: ColorPixel>(_ color: T) -> S where S.Model == Model, T.Model == XYZColorModel {
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
        guard self != other as? ColorSpace else { return color as! R }
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return matrix.almostEqual(.identity) ? other.convertFromXYZ(self.convertToXYZ(color)) : other.convertFromXYZ(self.convertToXYZ(color) * matrix)
    }
    
    @inlinable
    public func convert<S: ColorPixel, R: ColorPixel>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> R where S.Model == Model {
        return R(color: self.convert(color.color, to: other, intent: intent), opacity: color.opacity)
    }
}

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func convert<S, R>(_ color: MappedBuffer<S>, to other: ColorSpace<R.Model>, intent: RenderingIntent) -> MappedBuffer<R> where S: ColorPixel, S.Model == Model, R: ColorPixel {
        guard self != other as? ColorSpace else { return color as? MappedBuffer<R> ?? color.map { R(color: $0.color as! R.Model, opacity: $0.opacity) } }
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return matrix.almostEqual(.identity) ? color.map { R(color: other.convertFromXYZ(self.convertToXYZ($0.color)), opacity: $0.opacity) } : color.map { R(color: other.convertFromXYZ(self.convertToXYZ($0.color) * matrix), opacity: $0.opacity) }
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

