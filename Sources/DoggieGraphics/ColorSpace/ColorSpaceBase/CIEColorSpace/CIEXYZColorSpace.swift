//
//  CIEXYZColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension ColorSpace where Model == XYZColorModel {
    
    @inlinable
    public static func cieXYZ<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: colorSpace.base.cieXYZ)
    }
    
    @inlinable
    public static func cieXYZ(white: Point) -> ColorSpace {
        return ColorSpace(base: CIEXYZColorSpace(white: white))
    }
    
    @inlinable
    public static func cieXYZ(white: XYZColorModel, black: XYZColorModel) -> ColorSpace {
        return ColorSpace(base: CIEXYZColorSpace(white: white, black: black))
    }
    
    @inlinable
    public static func cieXYZ(white: Point, luminance: Double, contrastRatio: Double) -> ColorSpace {
        return ColorSpace(base: CIEXYZColorSpace(white: white, luminance: luminance, contrastRatio: contrastRatio))
    }
}

@frozen
@usableFromInline
struct CIEXYZColorSpace: ColorSpaceBaseProtocol {
    
    @usableFromInline
    typealias Model = XYZColorModel
    
    @usableFromInline
    let white: Model
    
    @usableFromInline
    let black: Model
    
    @usableFromInline
    let luminance: Double
    
    @inlinable
    init(white: Model) {
        self.white = white
        self.black = XYZColorModel()
        self.luminance = 1
    }
    
    @inlinable
    init(white: Model, black: Model, luminance: Double) {
        self.white = white
        self.black = black
        self.luminance = luminance
    }
    
    @inlinable
    init(white: Point) {
        self.white = XYZColorModel(luminance: 1, point: white)
        self.black = XYZColorModel()
        self.luminance = 1
    }
    
    @inlinable
    init(white: Model, black: Model) {
        self.white = XYZColorModel(luminance: 1, point: white.point)
        self.black = XYZColorModel(luminance: black.luminance / white.luminance, point: black.point)
        self.luminance = white.luminance
    }
    
    @inlinable
    init(white: Point, luminance: Double, contrastRatio: Double) {
        self.white = XYZColorModel(luminance: 1, point: white)
        self.black = XYZColorModel(luminance: 1 / contrastRatio, point: white)
        self.luminance = luminance
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CIEXYZColorSpace")
        hasher.combine(white)
        hasher.combine(black)
        hasher.combine(luminance)
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "Doggie XYZ Profile (\(CIE1931(rawValue: white.point)))"
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    var linearTone: CIEXYZColorSpace {
        return self
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    var cieXYZ: CIEXYZColorSpace {
        return self
    }
    
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
        return color
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return color
    }
}

extension CIEXYZColorSpace {
    
    @inlinable
    var normalizeMatrix: Matrix {
        return Matrix.translate(x: -black.x, y: -black.y, z: -black.z) * Matrix.scale(x: white.x / (white.y * (white.x - black.x)), y: 1 / (white.y - black.y), z: white.z / (white.y * (white.z - black.z)))
    }
}

