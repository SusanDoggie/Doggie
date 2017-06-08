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

public class CalibratedGrayColorSpace : ColorSpaceProtocol {
    
    public typealias Model = GrayColorModel
    
    public private(set) var cieXYZ: CIEXYZColorSpace
    
    @_inlineable
    public init(white: Point, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.cieXYZ = CIEXYZColorSpace(white: white, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel = XYZColorModel(x: 0, y: 0, z: 0), chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    @_inlineable
    public init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return cieXYZ.chromaticAdaptationAlgorithm
        }
        set {
            cieXYZ.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @_inlineable
    public func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return color
    }
}

extension CalibratedGrayColorSpace {
    
    @_inlineable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = white * normalizeMatrix
        return XYZColorModel(luminance: color.white, point: _white.point) * normalizeMatrix.inverse
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalized = color * cieXYZ.normalizeMatrix
        return Model(white: normalized.luminance)
    }
}

public class CalibratedGammaGrayColorSpace: CalibratedGrayColorSpace {
    
    public let gamma: Double
    
    @_inlineable
    public convenience init(white: Point, gamma: Double, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.init(white: XYZColorModel(luminance: 1, x: white.x, y: white.y), black: XYZColorModel(x: 0, y: 0, z: 0), gamma: gamma, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel, gamma: Double, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.gamma = gamma
        super.init(white: white, black: black, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public override func convertToLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, gamma) })
    }
    
    @_inlineable
    public override func convertFromLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, 1 / gamma) })
    }
}
