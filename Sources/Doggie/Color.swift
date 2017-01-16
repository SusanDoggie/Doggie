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

private protocol ColorBaseProtocol {
    
    var color: ColorModelProtocol { get }
    
    func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
}

private struct ColorBase<ColorSpace : ColorSpaceProtocol> : ColorBaseProtocol {
    
    var colorSpace: ColorSpace
    
    var _color: ColorSpace.Model
    var color: ColorModelProtocol {
        return _color
    }
    
    init(colorSpace: ColorSpace, color: ColorSpace.Model) {
        self.colorSpace = colorSpace
        self._color = color
    }
}

extension ColorBase {
    
    func convert<C : ColorSpaceProtocol>(to colorSpace: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<C> {
        return ColorBase<C>(colorSpace: colorSpace, color: self.colorSpace.convert(_color, to: colorSpace, algorithm: algorithm))
    }
    
    func convert<C : LinearColorSpaceProtocol>(to colorSpace: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<C> {
        return ColorBase<C>(colorSpace: colorSpace, color: self.colorSpace.convert(_color, to: colorSpace, algorithm: algorithm))
    }
}

public struct Color {
    
    public var alpha: Double
    fileprivate var base: ColorBaseProtocol
    
    fileprivate init(alpha: Double, base: ColorBaseProtocol) {
        self.alpha = alpha
        self.base = base
    }
    
    public init<ColorSpace : ColorSpaceProtocol>(colorSpace: ColorSpace, color: ColorSpace.Model, alpha: Double = 1) {
        self.alpha = alpha
        self.base = ColorBase(colorSpace: colorSpace, color: color)
    }
}

extension Color {
    
    public var color: ColorModelProtocol {
        return self.base.color
    }
}

extension Color {
    
    public func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(alpha: self.alpha, base: self.base.convert(to: colorSpace, algorithm: algorithm))
    }
    
    public func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(alpha: self.alpha, base: self.base.convert(to: colorSpace, algorithm: algorithm))
    }
}
