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

extension ColorSpace {
    
    @_inlineable
    public func convert<R>(_ color: Model, to other: ColorSpace<R>) -> R {
        return other.base.convertFromXYZ(self.base.convertToXYZ(color) * self.base.cieXYZ.transferMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm))
    }
    
    @_inlineable
    public func convert<S : Sequence, R>(_ color: S, to other: ColorSpace<R>) -> [R] where S.Iterator.Element == Model {
        let matrix = self.base.cieXYZ.transferMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
        return color.map { other.base.convertFromXYZ(self.base.convertToXYZ($0) * matrix) }
    }
    
    @_inlineable
    public func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>) -> R where S.Model == Model {
        return R(color: other.base.convertFromXYZ(self.base.convertToXYZ(color.color) * self.base.cieXYZ.transferMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)), opacity: color.opacity)
    }
    
    @_inlineable
    public func convert<S : Sequence, R: ColorPixelProtocol>(_ color: S, to other: ColorSpace<R.Model>) -> [R] where S.Iterator.Element: ColorPixelProtocol, S.Iterator.Element.Model == Model {
        let matrix = self.base.cieXYZ.transferMatrix(to: other.base.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
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
