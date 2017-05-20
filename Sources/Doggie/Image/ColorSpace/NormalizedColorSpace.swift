//
//  NormalizedColorSpace.swift
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

@_fixed_layout
public struct NormalizedColorSpace<ColorSpace: ColorSpaceProtocol> : ColorSpaceProtocol {
    
    @_versioned
    let base: ColorSpace
    
    @_versioned
    @_inlineable
    init(_ base: ColorSpace) {
        self.base = base
    }
    
    @_inlineable
    public var cieXYZ: CIEXYZColorSpace {
        return CIEXYZColorSpace(white: base.cieXYZ.white * base.cieXYZ.normalizeMatrix, chromaticAdaptationAlgorithm: base.chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        return base.chromaticAdaptationAlgorithm
    }
    
    @_inlineable
    public func convertToLinear(_ color: ColorSpace.Model) -> ColorSpace.Model {
        return base.convertToLinear(color)
    }
    
    @_inlineable
    public func convertFromLinear(_ color: ColorSpace.Model) -> ColorSpace.Model {
        return base.convertFromLinear(color)
    }
    
    @_inlineable
    public func convertLinearToXYZ(_ color: ColorSpace.Model) -> XYZColorModel {
        return base.convertLinearToXYZ(color) * base.cieXYZ.normalizeMatrix
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> ColorSpace.Model {
        return base.convertLinearFromXYZ(color * base.cieXYZ.normalizeMatrix.inverse)
    }
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public var normalized: NormalizedColorSpace<Self> {
        return NormalizedColorSpace(self)
    }
}
