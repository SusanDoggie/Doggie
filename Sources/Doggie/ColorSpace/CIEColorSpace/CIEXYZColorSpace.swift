//
//  CIEXYZColorSpace.swift
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

extension ColorSpace where Model == XYZColorModel {
    
    @_inlineable
    public static func cieXYZ<C>(from colorSpace: ColorSpace<C>) -> ColorSpace {
        return ColorSpace(base: colorSpace.base.cieXYZ)
    }
    
    @_inlineable
    public static func cieXYZ(white: Point) -> ColorSpace {
        return ColorSpace(base: CIEXYZColorSpace(white: white))
    }
}

@_versioned
@_fixed_layout
struct CIEXYZColorSpace : ColorSpaceBaseProtocol {
    
    typealias Model = XYZColorModel
    
    @_versioned
    let white: Model
    
    @_versioned
    let black: Model
    
    @_versioned
    let luminance: Double
    
    @_versioned
    @_inlineable
    init(white: Model, black: Model = XYZColorModel(), luminance: Double = 1) {
        self.white = white
        self.black = black
        self.luminance = luminance
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var hashValue: Int {
        return hash_combine("CIEXYZColorSpace", white, black, luminance)
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    init(white: Point) {
        self.init(white: XYZColorModel(luminance: 1, point: white))
    }
    
    @_versioned
    @_inlineable
    init(white: Point, luminance: Double, contrastRatio: Double) {
        self.init(white: XYZColorModel(luminance: 1, point: white), black: XYZColorModel(luminance: 1 / contrastRatio, point: white), luminance: luminance)
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var localizedName: String? {
        return "Doggie CIE XYZ Color Space (white = \(white.point))"
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var linearTone: CIEXYZColorSpace {
        return self
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var cieXYZ: CIEXYZColorSpace {
        return self
    }
    
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
        return color
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return color
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var normalizeMatrix: Matrix {
        return Matrix.translate(x: -black.x, y: -black.y, z: -black.z) * Matrix.scale(x: white.x / (white.y * (white.x - black.x)), y: 1 / (white.y - black.y), z: white.z / (white.y * (white.z - black.z)))
    }
}

