//
//  LinearToneColorSpace.swift
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

@frozen
@usableFromInline
struct LinearToneColorSpace<ColorSpace: ColorSpaceBaseProtocol>: ColorSpaceBaseProtocol {
    
    @usableFromInline
    let base: ColorSpace
    
    @inlinable
    init(_ base: ColorSpace) {
        self.base = base
    }
    
    @inlinable
    var cieXYZ: CIEXYZColorSpace {
        return base.cieXYZ
    }
    
    @inlinable
    func convertToLinear(_ color: ColorSpace.Model) -> ColorSpace.Model {
        return color
    }
    
    @inlinable
    func convertFromLinear(_ color: ColorSpace.Model) -> ColorSpace.Model {
        return color
    }
    
    @inlinable
    func convertLinearToXYZ(_ color: ColorSpace.Model) -> XYZColorModel {
        return base.convertLinearToXYZ(color)
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> ColorSpace.Model {
        return base.convertLinearFromXYZ(color)
    }
    
    @inlinable
    var linearTone: LinearToneColorSpace {
        return self
    }
}

extension LinearToneColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("LinearToneColorSpace")
        hasher.combine(base)
    }
}

extension LinearToneColorSpace {
    
    @inlinable
    var iccData: Data? {
        return nil
    }
    
    @inlinable
    var localizedName: String? {
        return base.localizedName.map { "LinearToneColorSpace<\($0)>" }
    }
}

extension ColorSpaceBaseProtocol where LinearTone == LinearToneColorSpace<Self> {
    
    @inlinable
    var linearTone: LinearToneColorSpace<Self> {
        return LinearToneColorSpace(self)
    }
}
