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
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get }
    
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertLinearToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    func convertToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel
    
    func convertFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model
    
    func convert<Model: ColorModelProtocol, R : ColorSpaceProtocol>(_ color: Model, to other: R) -> R.Model
    
    var normalized: _ColorSpaceBaseProtocol { get }
    
    var linearTone: _ColorSpaceBaseProtocol { get }
}

@_versioned
@_fixed_layout
struct _ColorSpaceBase<C : ColorSpaceProtocol> : _ColorSpaceBaseProtocol {
    
    @_versioned
    let base: C
    
    @_versioned
    @_inlineable
    init(base: C) {
        self.base = base
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    var cieXYZ: CIEXYZColorSpace {
        return base.cieXYZ
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        return base.chromaticAdaptationAlgorithm
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return base.convertToLinear(color as! C.Model) as! Model
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return base.convertFromLinear(color as! C.Model) as! Model
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel {
        return base.convertLinearToXYZ(color as! C.Model)
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model {
        return base.convertLinearFromXYZ(color) as! Model
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    func convertToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel {
        return base.convertToXYZ(color as! C.Model)
    }
    
    @_versioned
    @_inlineable
    func convertFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model {
        return base.convertFromXYZ(color) as! Model
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    func convert<Model: ColorModelProtocol, R : ColorSpaceProtocol>(_ color: Model, to other: R) -> R.Model {
        return base.convert(color as! C.Model, to: other)
    }
}

extension _ColorSpaceBase {
    
    @_versioned
    @_inlineable
    var normalized: _ColorSpaceBaseProtocol {
        return _ColorSpaceBase<NormalizedColorSpace<C>>(base: base.normalized)
    }
    
    @_versioned
    @_inlineable
    var linearTone: _ColorSpaceBaseProtocol {
        return _ColorSpaceBase<LinearToneColorSpace<C>>(base: base.linearTone)
    }
}

@_fixed_layout
public struct ColorSpace<Model : ColorModelProtocol> : ColorSpaceProtocol {
    
    @_versioned
    let base : _ColorSpaceBaseProtocol
    
    @_versioned
    @_inlineable
    init(base : _ColorSpaceBaseProtocol) {
        self.base = base
    }
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(_ colorSpace: C) where C.Model == Model {
        
        if let colorSpace = colorSpace as? ColorSpace<Model> {
            self.base = colorSpace.base
        } else {
            self.base = _ColorSpaceBase(base: colorSpace)
        }
    }
}

extension ColorSpace {
    
    @_inlineable
    public var cieXYZ: CIEXYZColorSpace {
        return base.cieXYZ
    }
}

extension ColorSpace {
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        return base.chromaticAdaptationAlgorithm
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
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return base.convertLinearToXYZ(color)
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return base.convertLinearFromXYZ(color)
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return base.convertToXYZ(color)
    }
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return base.convertFromXYZ(color)
    }
}

extension ColorSpace {
    
    @_inlineable
    public func convert<R : ColorSpaceProtocol>(_ color: Model, to other: R) -> R.Model {
        return base.convert(color, to: other)
    }
}

extension ColorSpace {
    
    @_versioned
    @_inlineable
    var normalized: ColorSpace {
        return ColorSpace(base: base.normalized)
    }
    
    @_versioned
    @_inlineable
    var linearTone: ColorSpace {
        return ColorSpace(base: base.linearTone)
    }
}
