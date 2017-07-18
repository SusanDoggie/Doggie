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
    
    func _convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func _convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func _convertLinearToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func _convertLinearFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    var _linearTone: _ColorSpaceBaseProtocol { get }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var iccData: Data? {
        return nil
    }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func _convertToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel {
        return self._convertLinearToXYZ(self._convertToLinear(color))
    }
    
    @_versioned
    @_inlineable
    func _convertFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model {
        return self._convertFromLinear(self._convertLinearFromXYZ(color))
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
    
    var linearTone: LinearTone { get }
}

extension ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func _convertToLinear<C: ColorModelProtocol>(_ color: C) -> C {
        return self.convertToLinear(color as! Model) as! C
    }
    
    @_versioned
    @_inlineable
    func _convertFromLinear<C: ColorModelProtocol>(_ color: C) -> C {
        return self.convertFromLinear(color as! Model) as! C
    }
    
    @_versioned
    @_inlineable
    func _convertLinearToXYZ<C: ColorModelProtocol>(_ color: C) -> XYZColorModel {
        return self.convertLinearToXYZ(color as! Model)
    }
    
    @_versioned
    @_inlineable
    func _convertLinearFromXYZ<C: ColorModelProtocol>(_ color: XYZColorModel) -> C {
        return self.convertLinearFromXYZ(color) as! C
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

public enum ChromaticAdaptationAlgorithm {
    case xyzScaling
    case vonKries
    case bradford
    case other(Matrix)
}

extension ChromaticAdaptationAlgorithm {
    
    @_inlineable
    public static var `default` : ChromaticAdaptationAlgorithm {
        return .bradford
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
        return base._convertToLinear(color)
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return base._convertFromLinear(color)
    }
}

extension ChromaticAdaptationAlgorithm {
    
    @_versioned
    @_inlineable
    var matrix: Matrix {
        switch self {
        case .xyzScaling: return Matrix.identity
        case .vonKries: return Matrix(a: 0.4002400, b: 0.7076000, c: -0.0808100, d: 0,
                                      e: -0.2263000, f: 1.1653200, g: 0.0457000, h: 0,
                                      i: 0.0000000, j: 0.0000000, k: 0.9182200, l: 0)
        case .bradford: return Matrix(a: 0.8951000, b: 0.2664000, c: -0.1614000, d: 0,
                                      e: -0.7502000, f: 1.7135000, g: 0.0367000, h: 0,
                                      i: 0.0389000, j: -0.0685000, k: 1.0296000, l: 0)
        case let .other(m): return m
        }
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    func chromaticAdaptationMatrix(to other: CIEXYZColorSpace, _ chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm) -> Matrix {
        return self.chromaticAdaptationMatrix(to: other, (chromaticAdaptationAlgorithm, chromaticAdaptationAlgorithm))
    }
    
    @_versioned
    @_inlineable
    func chromaticAdaptationMatrix(to other: CIEXYZColorSpace, _ chromaticAdaptationAlgorithm: (source: ChromaticAdaptationAlgorithm, destination: ChromaticAdaptationAlgorithm)) -> Matrix {
        let m1 = self.normalizeMatrix * chromaticAdaptationAlgorithm.source.matrix
        let m2 = other.normalizeMatrix * chromaticAdaptationAlgorithm.destination.matrix
        let _s = self.white * m1
        let _d = other.white * m2
        return m1 * Matrix.scale(x: _d.x / _s.x, y: _d.y / _s.y, z: _d.z / _s.z) * m2.inverse
    }
}

extension ColorSpace {
    
    @_versioned
    @_inlineable
    func chromaticAdaptationMatrix<R>(to other: ColorSpace<R>) -> Matrix {
        return self.base.cieXYZ.chromaticAdaptationMatrix(to: other.base.cieXYZ, (self.chromaticAdaptationAlgorithm, other.chromaticAdaptationAlgorithm))
    }
}

public enum RenderingIntent {
    
    case absoluteColorimetric
    case relativeColorimetric
}

extension RenderingIntent {
    
    @_inlineable
    public static var `default` : RenderingIntent {
        return .relativeColorimetric
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> R {
        
        switch intent {
        case .absoluteColorimetric: return other.base._convertFromXYZ(self.base._convertToXYZ(color))
        case .relativeColorimetric: return other.base._convertFromXYZ(self.base._convertToXYZ(color) * self.chromaticAdaptationMatrix(to: other))
        }
    }
    
    @_inlineable
    public func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> R where S.Model == Model {
        
        return R(color: self.convert(color.color, to: other, intent: intent), opacity: color.opacity)
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return base._convertToLinear(color)
    }
    
    @_inlineable
    public func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return base._convertFromLinear(color)
    }
    
    @_inlineable
    public func convert<S : Sequence, R>(_ color: S, to other: ColorSpace<R>, intent: RenderingIntent = .default) -> [R] where S.Element == Model {
        
        switch intent {
        case .absoluteColorimetric: return color.map { other.base._convertFromXYZ(self.base._convertToXYZ($0)) }
        case .relativeColorimetric:
            let matrix = self.chromaticAdaptationMatrix(to: other)
            return color.map { other.base._convertFromXYZ(self.base._convertToXYZ($0) * matrix) }
        }
    }
    
    @_inlineable
    public func convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>, intent: RenderingIntent = .default) -> [R] where S.Element: ColorPixelProtocol, S.Element.Model == Model {
        
        switch intent {
        case .absoluteColorimetric: return color.map { R(color: other.base._convertFromXYZ(self.base._convertToXYZ($0.color) * other.base.cieXYZ.white.y / self.base.cieXYZ.white.y), opacity: $0.opacity) }
        case .relativeColorimetric:
            let matrix = self.chromaticAdaptationMatrix(to: other)
            return color.map { R(color: other.base._convertFromXYZ(self.base._convertToXYZ($0.color) * matrix), opacity: $0.opacity) }
        }
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
}

