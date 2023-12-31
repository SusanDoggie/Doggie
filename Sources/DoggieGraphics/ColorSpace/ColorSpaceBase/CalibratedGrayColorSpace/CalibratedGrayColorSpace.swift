//
//  CalibratedGrayColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

extension ColorSpace where Model == GrayColorModel {
    
    @inlinable
    public static func calibratedGray<C>(from colorSpace: ColorSpace<C>, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(colorSpace.base.cieXYZ, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedGray(white: Point, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(CIEXYZColorSpace(white: white), gamma: gamma))
    }
    
    @inlinable
    public static func calibratedGray(white: XYZColorModel, black: XYZColorModel, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(CIEXYZColorSpace(white: white, black: black), gamma: gamma))
    }
    
    @inlinable
    public static func calibratedGray(white: Point, luminance: Double, contrastRatio: Double, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(CIEXYZColorSpace(white: white, luminance: luminance, contrastRatio: contrastRatio), gamma: gamma))
    }
}

@frozen
@usableFromInline
struct CalibratedGrayColorSpace: ColorSpaceBaseProtocol {
    
    @usableFromInline
    typealias Model = GrayColorModel
    
    @usableFromInline
    let cieXYZ: CIEXYZColorSpace
    
    @usableFromInline
    let gamma: Double
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace, gamma: Double) {
        self.cieXYZ = cieXYZ
        self.gamma = gamma
    }
}

extension CalibratedGrayColorSpace {
    
    @inlinable
    func iccCurve() -> iccCurve {
        return .gamma(gamma)
    }
}

extension CalibratedGrayColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "Doggie Gray Gamma \(Decimal(gamma).rounded(scale: 9)) Profile (\(CIE1931(rawValue: cieXYZ.white.point)))"
    }
}

extension CalibratedGrayColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CalibratedGrayColorSpace")
        hasher.combine(cieXYZ)
        hasher.combine(gamma)
    }
}

extension CalibratedGrayColorSpace {
    
    @inlinable
    var linearTone: CalibratedGrayColorSpace {
        return CalibratedGrayColorSpace(cieXYZ, gamma: 1)
    }
}

extension CalibratedGrayColorSpace {
    
    @inlinable
    func convertToLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, gamma) })
    }
    
    @inlinable
    func convertFromLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, 1 / gamma) })
    }
    
    @inlinable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        return XYZColorModel(luminance: color.white, point: _white.point) * normalizeMatrix.inverse
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalized = color * cieXYZ.normalizeMatrix
        return Model(white: normalized.luminance)
    }
}

