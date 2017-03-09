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
    
    var count: Int { get }
    
    var colorModel: ColorModelProtocol.Type { get }
    
    var color: ColorModelProtocol { get }
    
    func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    
    func component(_ index: Int) -> Double
    mutating func setComponent(_ index: Int, _ value: Double)
}

private struct ColorBase<ColorSpace : ColorSpaceProtocol> : ColorBaseProtocol {
    
    var count: Int {
        return ColorSpace.Model.count
    }
    
    var colorSpace: ColorSpace
    
    var _color: ColorSpace.Model
    var color: ColorModelProtocol {
        return _color
    }
    
    init(colorSpace: ColorSpace, color: ColorSpace.Model) {
        self.colorSpace = colorSpace
        self._color = color
    }
    
    func component(_ index: Int) -> Double {
        return _color.component(index)
    }
    mutating func setComponent(_ index: Int, _ value: Double) {
        _color.setComponent(index, value)
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

public struct Color {
    
    fileprivate var base: ColorBaseProtocol
    public var opacity: Double
    
    fileprivate init(base: ColorBaseProtocol, opacity: Double) {
        self.base = base
        self.opacity = opacity
    }
    
    public init<ColorSpace : ColorSpaceProtocol>(colorSpace: ColorSpace, color: ColorSpace.Model, opacity: Double = 1) {
        self.base = ColorBase(colorSpace: colorSpace, color: color)
        self.opacity = opacity
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
    
    public func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(base: self.base.convert(to: colorSpace, algorithm: algorithm), opacity: self.opacity)
    }
    
    public func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(base: self.base.convert(to: colorSpace, algorithm: algorithm), opacity: self.opacity)
    }
}

extension Color {
    
    public var componentCount: Int {
        return base.count
    }
    
    public func component(_ index: Int) -> Double {
        return base.component(index)
    }
    public mutating func setComponent(_ index: Int, _ value: Double) {
        base.setComponent(index, value)
    }
}
