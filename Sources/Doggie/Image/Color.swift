//
//  Color.swift
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

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    
    public var opacity: Double
    
    public var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    @_inlineable
    public init<C : ColorPixelProtocol>(colorSpace: ColorSpace, color: C, chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where C.Model == ColorSpace.Model {
        self.colorSpace = colorSpace
        self.color = color.color
        self.opacity = color.opacity
        self.chromaticAdaptationAlgorithm = chromaticAdaptationAlgorithm
    }
    
    @_inlineable
    public init(colorSpace: ColorSpace, color: ColorSpace.Model, opacity: Double = 1, chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) {
        self.colorSpace = colorSpace
        self.color = color
        self.opacity = opacity
        self.chromaticAdaptationAlgorithm = chromaticAdaptationAlgorithm
    }
}

extension Color {
    
    @_inlineable
    public func convert<C : ColorSpaceProtocol>(to colorSpace: C) -> Color<C> {
        return Color<C>(colorSpace: colorSpace, color: self.colorSpace.convert(color, to: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm), opacity: opacity, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
}

extension Color {
    
    @_inlineable
    public func blended<C : ColorSpaceProtocol>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> Color {
        let source = source.convert(to: colorSpace)
        let color = ColorPixel(color: self.color, opacity: self.opacity).blended(source: ColorPixel(color: source.color, opacity: source.opacity), blendMode: blendMode, compositingMode: compositingMode)
        return Color(colorSpace: colorSpace, color: color.color, opacity: color.opacity, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public mutating func blend<C : ColorSpaceProtocol>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}
