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

@_versioned
protocol ColorBaseProtocol {
    
    @_versioned
    var count: Int { get }
    
    @_versioned
    var colorModel: ColorModelProtocol.Type { get }
    
    @_versioned
    var color: ColorModelProtocol { get }
    
    @_versioned
    func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    
    @_versioned
    func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<ColorSpace>
    
    @_versioned
    func component(_ index: Int) -> Double
    
    @_versioned
    mutating func setComponent(_ index: Int, _ value: Double)
}

@_versioned
@_fixed_layout
struct ColorBase<ColorSpace : ColorSpaceProtocol> : ColorBaseProtocol {
    
    @_versioned
    @_inlineable
    var count: Int {
        return ColorSpace.Model.count
    }
    
    @_versioned
    @_inlineable
    var colorSpace: ColorSpace
    
    @_versioned
    @_inlineable
    var _color: ColorSpace.Model
    
    @_versioned
    @_inlineable
    var color: ColorModelProtocol {
        return _color
    }
    
    @_versioned
    @_inlineable
    init(colorSpace: ColorSpace, color: ColorSpace.Model) {
        self.colorSpace = colorSpace
        self._color = color
    }
    
    @_versioned
    @_inlineable
    func component(_ index: Int) -> Double {
        return _color.component(index)
    }
    @_versioned
    @_inlineable
    mutating func setComponent(_ index: Int, _ value: Double) {
        _color.setComponent(index, value)
    }
}

extension ColorBase {
    
    @_versioned
    @_inlineable
    var colorModel: ColorModelProtocol.Type {
        return ColorSpace.Model.self
    }
}

extension ColorBase {
    
    @_versioned
    @_inlineable
    func convert<C : ColorSpaceProtocol>(to colorSpace: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<C> {
        return ColorBase<C>(colorSpace: colorSpace, color: self.colorSpace.convert(_color, to: colorSpace, algorithm: algorithm))
    }
    
    @_versioned
    @_inlineable
    func convert<C : LinearColorSpaceProtocol>(to colorSpace: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ColorBase<C> {
        return ColorBase<C>(colorSpace: colorSpace, color: self.colorSpace.convert(_color, to: colorSpace, algorithm: algorithm))
    }
}

@_fixed_layout
public struct Color {
    
    @_versioned
    var base: ColorBaseProtocol
    
    public var opacity: Double
    
    @_versioned
    @_inlineable
    init(base: ColorBaseProtocol, opacity: Double) {
        self.base = base
        self.opacity = opacity
    }
    
    @_inlineable
    public init<ColorSpace : ColorSpaceProtocol>(colorSpace: ColorSpace, color: ColorSpace.Model, opacity: Double = 1) {
        self.base = ColorBase(colorSpace: colorSpace, color: color)
        self.opacity = opacity
    }
}

extension Color {
    
    @_inlineable
    public var colorModel: ColorModelProtocol.Type {
        return self.base.colorModel
    }
    @_inlineable
    public var color: ColorModelProtocol {
        return self.base.color
    }
}

extension Color {
    
    @_inlineable
    public func convert<ColorSpace : ColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(base: self.base.convert(to: colorSpace, algorithm: algorithm), opacity: self.opacity)
    }
    
    @_inlineable
    public func convert<ColorSpace : LinearColorSpaceProtocol>(to colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color {
        return Color(base: self.base.convert(to: colorSpace, algorithm: algorithm), opacity: self.opacity)
    }
}

extension Color {
    
    @_inlineable
    public var componentCount: Int {
        return base.count
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        return base.component(index)
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        base.setComponent(index, value)
    }
}
