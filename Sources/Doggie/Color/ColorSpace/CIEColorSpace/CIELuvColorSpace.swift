//
//  CIELuvColorSpace.swift
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

import Foundation

extension ColorSpace where Model == LuvColorModel {
    
    @_inlineable
    public static func cieLuv<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: CIELuvColorSpace(colorSpace.base.cieXYZ))
    }
    
    @_inlineable
    public static func cieLuv(white: Point) -> ColorSpace {
        return cieLuv(white: XYZColorModel(luminance: 1, x: white.x, y: white.y))
    }
    
    @_inlineable
    public static func cieLuv(white: XYZColorModel, black: XYZColorModel = XYZColorModel(x: 0, y: 0, z: 0)) -> ColorSpace {
        return ColorSpace(base: CIELuvColorSpace(CIEXYZColorSpace(white: white, black: black)))
    }
}

@_versioned
@_fixed_layout
struct CIELuvColorSpace : ColorSpaceBaseProtocol {
    
    typealias Model = LuvColorModel
    
    @_versioned
    let cieXYZ: CIEXYZColorSpace
    
    @_versioned
    @_inlineable
    init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIELuvColorSpace {
    
    @_versioned
    @_inlineable
    func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: Model) -> Model {
        return color
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let t = 27.0 / 24389.0
        let st = 216.0 / 27.0
        let _white = XYZColorModel(luminance: 1, point: cieXYZ.normalized.white.point)
        let n = 1 / (_white.x + 15 * _white.y + 3 * _white.z)
        let _uw = 4 * _white.x * n
        let _vw = 9 * _white.y * n
        let fy = (color.lightness + 16) / 116
        let y = color.lightness > st ? fy * fy * fy : t * color.lightness
        let a = 52 * color.lightness / (color.u + 13 * color.lightness * _uw) - 1
        let b = -5 * y
        let d = y * (39 * color.lightness / (color.v + 13 * color.lightness * _vw) - 5)
        let x = (d - b) / (a + 1)
        return XYZColorModel(x: 3 * x, y: y, z: x * a + b)
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let s = 216.0 / 24389.0
        let t = 24389.0 / 27.0
        let _white = XYZColorModel(luminance: 1, point: cieXYZ.normalized.white.point)
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
