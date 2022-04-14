//
//  ColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
public struct ColorSpace<Model: ColorModel>: ColorSpaceProtocol, _ColorSpaceProtocol {
    
    @usableFromInline
    let base : any ColorSpaceBaseProtocol
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default

    @usableFromInline
    var cache = Cache<String>()
    
    @inlinable
    init(base : any ColorSpaceBaseProtocol) {
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
        return lhs.chromaticAdaptationAlgorithm == rhs.chromaticAdaptationAlgorithm && lhs.base._equalTo(rhs.base)
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
    public var model: any ColorModel.Type {
        return Model.self
    }
}

extension ColorSpace {
    
    @inlinable
    public var iccData: Data? {
        return base.iccData
    }
}

extension ColorSpaceBaseProtocol {
    
    @inlinable
    func _convertToLinear(_ color: any ColorModel) -> any ColorModel {
        return self.convertToLinear(color as! Model)
    }
    
    @inlinable
    func _convertFromLinear(_ color: any ColorModel) -> any ColorModel {
        return self.convertFromLinear(color as! Model)
    }
    
    @inlinable
    func _convertLinearToXYZ(_ color: any ColorModel) -> XYZColorModel {
        return self.convertLinearToXYZ(color as! Model)
    }
    
    @inlinable
    func _convertToXYZ(_ color: any ColorModel) -> XYZColorModel {
        return self.convertToXYZ(color as! Model)
    }
}

extension ColorSpace {
    
    @inlinable
    public var cieXYZ: ColorSpace<XYZColorModel> {
        return ColorSpace<XYZColorModel>(base: self.base.cieXYZ)
    }
    
    @inlinable
    public func convertToLinear(_ color: Model) -> Model {
        return self.base._convertToLinear(color) as! Model
    }
    
    @inlinable
    public func convertFromLinear(_ color: Model) -> Model {
        return self.base._convertFromLinear(color) as! Model
    }
    
    @inlinable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return self.base._convertLinearToXYZ(color)
    }
    
    @inlinable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return self.base.convertLinearFromXYZ(color) as! Model
    }
    
    @inlinable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.base._convertToXYZ(color)
    }
    
    @inlinable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.base.convertFromXYZ(color) as! Model
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
    func _convert<R>(_ color: Model, to other: ColorSpace<R>, matrix: Matrix) -> R {
        return matrix.almostEqual(.identity) ? other.convertFromXYZ(self.convertToXYZ(color)) : other.convertFromXYZ(self.convertToXYZ(color) * matrix)
    }
    
    @inlinable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> R {
        guard self != other as? ColorSpace else { return color as! R }
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return self._convert(color, to: other, matrix: matrix)
    }
}

extension ColorSpace {
    
    @inlinable
    func _convert<S: ColorPixel, R: ColorPixel>(_ pixel: S, to other: ColorSpace<R.Model>) -> R where S.Model == Model {
        return R(color: other.convertFromXYZ(self.convertToXYZ(pixel.color)), opacity: pixel.opacity)
    }
    
    @inlinable
    func _convert<S: ColorPixel, R: ColorPixel>(_ pixel: S, to other: ColorSpace<R.Model>, matrix: Matrix) -> R where S.Model == Model {
        return R(color: other.convertFromXYZ(self.convertToXYZ(pixel.color) * matrix), opacity: pixel.opacity)
    }
    
    @inlinable
    func convert_buffer<S: ColorPixel, R: ColorPixel>(_ color: MappedBuffer<S>, to other: ColorSpace<R.Model>, intent: RenderingIntent) -> MappedBuffer<R> where S.Model == Model {
        guard self != other as? ColorSpace else { return color as? MappedBuffer<R> ?? color.map { R(color: $0.color as! R.Model, opacity: $0.opacity) } }
        let matrix = self.base.cieXYZ._intentMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm, intent: intent)
        return matrix.almostEqual(.identity) ? color.map { self._convert($0, to: other) } : color.map { self._convert($0, to: other, matrix: matrix) }
    }
}

extension ColorSpace {
    
    @inlinable
    public var linearTone: ColorSpace {
        return ColorSpace(base: base.linearTone)
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

