//
//  CIEXYZColorSpace.swift
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

public struct CIEXYZColorSpace : ColorSpaceProtocol {
    
    public typealias Model = XYZColorModel
    
    public let white: Model
    public let black: Model
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    @_inlineable
    public init(white: Point, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.init(white: XYZColorModel(luminance: 1, x: white.x, y: white.y), chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public init(white: Model, black: Model = XYZColorModel(x: 0, y: 0, z: 0), chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.white = white
        self.black = black
        self.chromaticAdaptationAlgorithm = chromaticAdaptationAlgorithm
    }
}

extension CIEXYZColorSpace {
    
    @_inlineable
    public var cieXYZ: CIEXYZColorSpace {
        return self
    }
    
    @_inlineable
    public func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return color
    }
    
    @_inlineable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return color
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return color
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    var normalizeMatrix: Matrix {
        return Matrix.translate(x: -black.x, y: -black.y, z: -black.z) * Matrix.scale(x: white.x / (white.y * (white.x - black.x)), y: 1 / (white.y - black.y), z: white.z / (white.y * (white.z - black.z)))
    }
    
    @_versioned
    @_inlineable
    func transferMatrix(to other: CIEXYZColorSpace, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm) -> Matrix {
        let matrix = chromaticAdaptationAlgorithm.matrix
        let m1 = self.normalizeMatrix * matrix
        let m2 = other.normalizeMatrix * matrix
        let _s = self.white * m1
        let _d = other.white * m2
        return m1 * Matrix.scale(x: _d.x / _s.x, y: _d.y / _s.y, z: _d.z / _s.z) as Matrix * m2.inverse
    }
}

extension ChromaticAdaptationAlgorithm {
    
    @_versioned
    @_inlineable
    var matrix: Matrix {
        switch self {
        case .xyzScaling: return Matrix.identity
        case .vonKries: return Matrix(a: 0.4002400, b: 0.7076000, c: -0.0808100, d: 0,
                                      e: -0.2263000, f: 1.1653200, g: 0.0457000, h: 0,
                                      i: 0.0000000, j: 0.0000000, k: 0.9182200, l: 0)
        case .bradford: return Matrix(a: 0.8951000, b: 0.2664000, c: -0.1614000, d: 0,
                                      e: -0.7502000, f: 1.7135000, g: 0.0367000, h: 0,
                                      i: 0.0389000, j: -0.0685000, k: 1.0296000, l: 0)
        case let .other(m): return m
        }
    }
}
