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

@_versioned
protocol _ColorSpaceBaseProtocol {
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertLinearToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    var normalized: _ColorSpaceBaseProtocol { get }
    
    var linearTone: _ColorSpaceBaseProtocol { get }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var white: XYZColorModel {
        return cieXYZ.white
    }
    
    @_versioned
    @_inlineable
    var black: XYZColorModel {
        return cieXYZ.black
    }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func convertToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel {
        return self.convertLinearToXYZ(self.convertToLinear(color))
    }
    
    @_versioned
    @_inlineable
    func convertFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model {
        return self.convertFromLinear(self.convertLinearFromXYZ(color))
    }
}

@_versioned
protocol ColorSpaceBaseProtocol : _ColorSpaceBaseProtocol {
    
    associatedtype Model : ColorModelProtocol
    
    func convertToLinear(_ color: Model) -> Model
    
    func convertFromLinear(_ color: Model) -> Model
    
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model
}

extension ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    func convertToLinear<C: ColorModelProtocol>(_ color: C) -> C {
        return self.convertToLinear(color as! Model) as! C
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear<C: ColorModelProtocol>(_ color: C) -> C {
        return self.convertFromLinear(color as! Model) as! C
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ<C: ColorModelProtocol>(_ color: C) -> XYZColorModel {
        return self.convertLinearToXYZ(color as! Model)
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ<C: ColorModelProtocol>(_ color: XYZColorModel) -> C {
        return self.convertLinearFromXYZ(color) as! C
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
    public func convertToLinear(_ color: Model) -> Model {
        return base.convertToLinear(color)
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return base.convertFromLinear(color)
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

extension ColorSpace {
    
    @_versioned
    @_inlineable
    func chromaticTransferMatrix<R>(to other: ColorSpace<R>) -> Matrix {
        let m1 = self.base.cieXYZ.normalizeMatrix * self.chromaticAdaptationAlgorithm.matrix
        let m2 = other.base.cieXYZ.normalizeMatrix * other.chromaticAdaptationAlgorithm.matrix
        let _s = self.white * m1
        let _d = other.white * m2
        return m1 * Matrix.scale(x: _d.x / _s.x, y: _d.y / _s.y, z: _d.z / _s.z) * m2.inverse
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>) -> R {
        return other.base.convertFromXYZ(self.base.convertToXYZ(color) * self.chromaticTransferMatrix(to: other))
    }
    
    @_inlineable
    public func convert<S : Sequence, R>(_ color: S, to other: ColorSpace<R>) -> [R] where S.Iterator.Element == Model {
        let matrix = self.chromaticTransferMatrix(to: other)
        return color.map { other.base.convertFromXYZ(self.base.convertToXYZ($0) * matrix) }
    }
    
    @_inlineable
    public func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>) -> R where S.Model == Model {
        return R(color: other.base.convertFromXYZ(self.base.convertToXYZ(color.color) * self.chromaticTransferMatrix(to: other)), opacity: color.opacity)
    }
    
    @_inlineable
    public func convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>) -> [R] where S.Iterator.Element: ColorPixelProtocol, S.Iterator.Element.Model == Model {
        let matrix = self.chromaticTransferMatrix(to: other)
        return color.map { R(color: other.base.convertFromXYZ(self.base.convertToXYZ($0.color) * matrix), opacity: $0.opacity) }
    }
}

extension ColorSpace {
    
    @_inlineable
    public var normalized: ColorSpace {
        return ColorSpace(base: base.normalized)
    }
    
    @_inlineable
    public var linearTone: ColorSpace {
        return ColorSpace(base: base.linearTone)
    }
}

extension ColorSpace {
    
    @_inlineable
    public var white: XYZColorModel {
        return base.white
    }
    
    @_inlineable
    public var black: XYZColorModel {
        return base.black
    }
}
