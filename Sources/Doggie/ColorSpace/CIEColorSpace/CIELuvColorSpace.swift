//
//  CIELuvColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

extension ColorSpace where Model == LuvColorModel {
    
    @inlinable
    public static func cieLuv<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: CIELuvColorSpace(colorSpace.base.cieXYZ))
    }
    
    @inlinable
    public static func cieLuv(white: Point) -> ColorSpace {
        return ColorSpace(base: CIELuvColorSpace(CIEXYZColorSpace(white: white)))
    }
}

@_fixed_layout
@usableFromInline
struct CIELuvColorSpace : ColorSpaceBaseProtocol {
    
    typealias Model = LuvColorModel
    
    @usableFromInline
    let cieXYZ: CIEXYZColorSpace
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIELuvColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CIELuvColorSpace")
        hasher.combine(cieXYZ)
    }
}

extension CIELuvColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "Doggie CIE Luv Color Space (white = \(cieXYZ.white.point))"
    }
}

extension CIELuvColorSpace {
    
    @inlinable
    var linearTone: CIELuvColorSpace {
        return self
    }
}

extension CIELuvColorSpace {
    
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
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        let t = 27.0 / 24389.0
        let st = 216.0 / 27.0
        let n = 1 / (_white.x + 15 * _white.y + 3 * _white.z)
        let _uw = 4 * _white.x * n
        let _vw = 9 * _white.y * n
        let fy = (color.lightness + 16) / 116
        let y = color.lightness > st ? fy * fy * fy : t * color.lightness
        let a = 52 * color.lightness / (color.u + 13 * color.lightness * _uw) - 1
        let b = -5 * y
        let d = y * (39 * color.lightness / (color.v + 13 * color.lightness * _vw) - 5)
        let x = (d - b) / (a + 1)
        return XYZColorModel(x: 3 * x, y: y, z: x * a + b) * normalizeMatrix.inverse
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        let color = color * normalizeMatrix
        let s = 216.0 / 24389.0
        let t = 24389.0 / 27.0
        let m = 1 / (color.x + 15 * color.y + 3 * color.z)
        let n = 1 / (_white.x + 15 * _white.y + 3 * _white.z)
        let y = color.y / _white.y
        let _u = 4 * color.x * m
        let _v = 9 * color.y * m
        let _uw = 4 * _white.x * n
        let _vw = 9 * _white.y * n
        let l = y > s ? 116 * cbrt(y) - 16 : t * y
        return LuvColorModel(lightness: l, u: 13 * l * (_u - _uw), v: 13 * l * (_v - _vw))
    }
}
