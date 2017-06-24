//
//  CalibratedGrayColorSpace.swift
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

extension ColorSpace where Model == GrayColorModel {
    
    @_inlineable
    public static func calibratedGray<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(colorSpace.base.cieXYZ))
    }
    
    @_inlineable
    public static func calibratedGray(white: Point) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(CIEXYZColorSpace(white: white)))
    }
    
    @_inlineable
    public static func calibratedGray(white: Point, gamma: Double) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaGrayColorSpace(CIEXYZColorSpace(white: white), gamma: gamma))
    }
}

@_versioned
@_fixed_layout
class CalibratedGrayColorSpace : ColorSpaceBaseProtocol {
    
    typealias Model = GrayColorModel
    
    @_versioned
    let cieXYZ: CIEXYZColorSpace
    
    @_versioned
    @_inlineable
    init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
    
    @_versioned
    @_inlineable
    func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func iccParametricCurve() -> iccProfile.ParametricCurve {
        return iccProfile.ParametricCurve(funcType: 0, gamma: 1, a: 0, b: 0, c: 0, d: 0, e: 0, f: 0)
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    var linearTone: CalibratedGrayColorSpace {
        return CalibratedGrayColorSpace(cieXYZ)
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = white * normalizeMatrix
        return XYZColorModel(luminance: color.white, point: _white.point) * normalizeMatrix.inverse
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalized = color * cieXYZ.normalizeMatrix
        return Model(white: normalized.luminance)
    }
}

@_versioned
@_fixed_layout
class CalibratedGammaGrayColorSpace: CalibratedGrayColorSpace {
    
    @_versioned
    let gamma: Double
    
    @_versioned
    @_inlineable
    init(_ cieXYZ: CIEXYZColorSpace, gamma: Double) {
        self.gamma = gamma
        super.init(cieXYZ)
    }
    
    @_versioned
    @_inlineable
    override func convertToLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, gamma) })
    }
    
    @_versioned
    @_inlineable
    override func convertFromLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, 1 / gamma) })
    }
    
    @_versioned
    @_inlineable
    override func iccParametricCurve() -> iccProfile.ParametricCurve {
        return iccProfile.ParametricCurve(funcType: 0, gamma: iccProfile.S15Fixed16Number(value: gamma), a: 0, b: 0, c: 0, d: 0, e: 0, f: 0)
    }
}
