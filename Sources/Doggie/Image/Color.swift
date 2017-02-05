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
    
    var colorModel: ColorModelProtocol.Type { get }
    
    var color: ColorModelProtocol { get }
    
    func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    
    func blend(operation: (Double) -> Double) -> ColorBaseProtocol
    func blend(source: ColorBaseProtocol, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm, operation: (Double, Double) -> Double) -> ColorBaseProtocol
}

private struct ColorBase<ColorSpace : ColorSpaceProtocol> : ColorBaseProtocol where ColorSpace.Model : ColorBlendProtocol {
    
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
    
    var colorModel: ColorModelProtocol.Type {
        return ColorSpace.Model.self
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

extension ColorBase {
    
    func blend(operation: (Double) -> Double) -> ColorBaseProtocol {
        return ColorBase(colorSpace: colorSpace, color: _color.blend(operation: operation))
    }
    func blend(source: ColorBaseProtocol, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm, operation: (Double, Double) -> Double) -> ColorBaseProtocol {
        let _source = source.convert(to: colorSpace, algorithm: algorithm)
        return ColorBase(colorSpace: colorSpace, color: _color.blend(source: _source._color, operation: operation))
    }
}

public struct Color {
    
    public var alpha: Double
    fileprivate var base: ColorBaseProtocol
    
    fileprivate init(alpha: Double, base: ColorBaseProtocol) {
        self.alpha = alpha
        self.base = base
    }
    
    public init<ColorSpace : ColorSpaceProtocol>(colorSpace: ColorSpace, color: ColorSpace.Model, alpha: Double = 1) where ColorSpace.Model : ColorBlendProtocol {
        self.alpha = alpha
        self.base = ColorBase(colorSpace: colorSpace, color: color)
    }
}

extension Color {
    
    public var colorModel: ColorModelProtocol.Type {
        return self.base.colorModel
    }
    public var color: ColorModelProtocol {
        return self.base.color
    }
}

extension Color {
    
    public func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color where ColorSpace.Model : ColorBlendProtocol {
        return Color(alpha: self.alpha, base: self.base.convert(to: colorSpace, algorithm: algorithm))
    }
    
    public func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color where ColorSpace.Model : ColorBlendProtocol {
        return Color(alpha: self.alpha, base: self.base.convert(to: colorSpace, algorithm: algorithm))
    }
}

extension Color {
    
    func blend(operation: (Double) -> Double) -> Color {
        return Color(alpha: operation(self.alpha), base: self.base.blend(operation: operation))
    }
    func blend(source: Color, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford, operation: (Double, Double) -> Double) -> Color {
        return Color(alpha: operation(self.alpha, source.alpha), base: self.base.blend(source: source.base, algorithm: algorithm, operation: operation))
    }
}
