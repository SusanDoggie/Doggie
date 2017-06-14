//
//  LinearToneColorSpace.swift
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
@_fixed_layout
struct LinearToneColorSpace<ColorSpace: _ColorSpaceBaseProtocol> : _ColorSpaceBaseProtocol {
    
    @_versioned
    let base: ColorSpace
    
    @_versioned
    @_inlineable
    init(_ base: ColorSpace) {
        self.base = base
    }
    
    @_versioned
    @_inlineable
    var cieXYZ: CIEXYZColorSpace {
        return base.cieXYZ
    }
    
    @_versioned
    @_inlineable
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ<Model: ColorModelProtocol>(_ color: Model) -> XYZColorModel {
        return base.convertLinearToXYZ(color)
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ<Model: ColorModelProtocol>(_ color: XYZColorModel) -> Model {
        return base.convertLinearFromXYZ(color)
    }
    
    @_versioned
    @_inlineable
    var linearTone: _ColorSpaceBaseProtocol {
        return self
    }
}

extension _ColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var linearTone: _ColorSpaceBaseProtocol {
        return LinearToneColorSpace(self)
    }
}
