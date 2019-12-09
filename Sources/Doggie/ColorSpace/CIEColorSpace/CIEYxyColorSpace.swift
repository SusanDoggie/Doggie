//
//  CIEYxyColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

extension ColorSpace where Model == YxyColorModel {
    
    @inlinable
    public static func cieYxy<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: CIEYxyColorSpace(colorSpace.base.cieXYZ))
    }
    
    @inlinable
    public static func cieYxy(white: Point) -> ColorSpace {
        return ColorSpace(base: CIEYxyColorSpace(CIEXYZColorSpace(white: white)))
    }
}

@frozen
@usableFromInline
struct CIEYxyColorSpace : ColorSpaceBaseProtocol {
    
    @usableFromInline
    typealias Model = YxyColorModel
    
    @usableFromInline
    let cieXYZ: CIEXYZColorSpace
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIEYxyColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CIEYxyColorSpace")
        hasher.combine(cieXYZ)
    }
}

extension CIEYxyColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "Doggie Yxy Profile (\(CIE1931(rawValue: cieXYZ.white.point)))"
    }
}

extension CIEYxyColorSpace {
    
    @inlinable
    var linearTone: CIEYxyColorSpace {
        return self
    }
}

extension CIEYxyColorSpace {
    
    @inlinable
    func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @inlinable
    func convertFromLinear(_ color: Model) -> Model {
        return color
    }
    
    @inlinable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return XYZColorModel(color)
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return Model(color)
    }
}
