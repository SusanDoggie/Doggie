//
//  CIELabColorSpace.swift
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

extension ColorSpace where Model == LabColorModel {
    
    @inlinable
    public static func cieLab<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: CIELabColorSpace(colorSpace.base.cieXYZ))
    }
    
    @inlinable
    public static func cieLab(white: Point) -> ColorSpace {
        return ColorSpace(base: CIELabColorSpace(CIEXYZColorSpace(white: white)))
    }
}

@frozen
@usableFromInline
struct CIELabColorSpace : ColorSpaceBaseProtocol {
    
    @usableFromInline
    typealias Model = LabColorModel
    
    @usableFromInline
    let cieXYZ: CIEXYZColorSpace
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIELabColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CIELabColorSpace")
        hasher.combine(cieXYZ)
    }
}

extension CIELabColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "Doggie Lab Profile (\(CIE1931(rawValue: cieXYZ.white.point)))"
    }
}

extension CIELabColorSpace {
    
    @inlinable
    var linearTone: CIELabColorSpace {
        return self
    }
}

extension CIELabColorSpace {
    
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
        let s = 216.0 / 24389.0
        let t = 27.0 / 24389.0
        let st = 216.0 / 27.0
        let fy = (color.lightness + 16) / 116
        let fx = 0.002 * color.a + fy
        let fz = fy - 0.005 * color.b
        let fx3 = fx * fx * fx
        let fz3 = fz * fz * fz
        let x = fx3 > s ? fx3 : t * (116 * fx - 16)
        let y = color.lightness > st ? fy * fy * fy : t * color.lightness
        let z = fz3 > s ? fz3 : t * (116 * fz - 16)
        return XYZColorModel(x: x * _white.x, y: y * _white.y, z: z * _white.z) * normalizeMatrix.inverse
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        let color = color * normalizeMatrix
        let s = 216.0 / 24389.0
        let t = 24389.0 / 27.0
        let x = color.x / _white.x
        let y = color.y / _white.y
        let z = color.z / _white.z
        let fx = x > s ? cbrt(x) : (t * x + 16) / 116
        let fy = y > s ? cbrt(y) : (t * y + 16) / 116
        let fz = z > s ? cbrt(z) : (t * z + 16) / 116
        return LabColorModel(lightness: 116 * fy - 16, a: 500 * (fx - fy), b: 200 * (fy - fz))
    }
}
