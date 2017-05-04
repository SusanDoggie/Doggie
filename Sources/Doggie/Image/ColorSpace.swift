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

import Foundation

public protocol ColorSpaceProtocol {
    
    associatedtype Model : ColorModelProtocol
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    var white: XYZColorModel { get }
    
    var black: XYZColorModel { get }
    
    func convertToXYZ(_ color: Model) -> XYZColorModel
    
    func convertFromXYZ(_ color: XYZColorModel) -> Model
    
    func convert<C : ColorSpaceProtocol>(_ color: Model, to other: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> C.Model
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public var white: XYZColorModel {
        return cieXYZ.white
    }
    
    @_inlineable
    public var black: XYZColorModel {
        return cieXYZ.black
    }
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public func convert<C : ColorSpaceProtocol>(_ color: Model, to other: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> C.Model {
        return other.convertFromXYZ(self.convertToXYZ(color) * self.cieXYZ.transferMatrix(to: other.cieXYZ, algorithm: algorithm))
    }
}

public protocol GammaColorSpaceProtocol : class, ColorSpaceProtocol {
    
    func convertToLinear(_ color: Model) -> Model
    
    func convertFromLinear(_ color: Model) -> Model
    
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model
}

extension GammaColorSpaceProtocol {
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.convertLinearToXYZ(self.convertToLinear(color))
    }
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertFromLinear(self.convertLinearFromXYZ(color))
    }
}

extension GammaColorSpaceProtocol {
    
    @_versioned
    @_inlineable
    func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
        return x.sign == .plus ? gamma(x) : -gamma(-x)
    }
}

public struct CIEXYZColorSpace : ColorSpaceProtocol {
    
    public typealias Model = XYZColorModel
    
    public var white: Model
    public var black: Model
    
    @_inlineable
    public init(white: Point) {
        self.white = XYZColorModel(luminance: 1, x: white.x, y: white.y)
        self.black = XYZColorModel(x: 0, y: 0, z: 0)
    }
    
    @_inlineable
    public init(white: Model, black: Model = XYZColorModel(x: 0, y: 0, z: 0)) {
        self.white = white
        self.black = black
    }
}

extension CIEXYZColorSpace {
    
    @_inlineable
    public var cieXYZ: CIEXYZColorSpace {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return color
    }
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return color
    }
}

extension CIEXYZColorSpace {
    
    @_inlineable
    public var normalizeMatrix: Matrix {
        return Matrix.Translate(x: -black.x, y: -black.y, z: -black.z) * Matrix.Scale(x: white.x / (white.y * (white.x - black.x)), y: 1 / (white.y - black.y), z: white.z / (white.y * (white.z - black.z)))
    }
    
    @_inlineable
    public var normalized: CIEXYZColorSpace {
        return CIEXYZColorSpace(white: white * normalizeMatrix)
    }
    
    @_versioned
    @_inlineable
    func transferMatrix(to other: CIEXYZColorSpace, algorithm: ChromaticAdaptationAlgorithm = .bradford) -> Matrix {
        let matrix = algorithm.matrix
        let m1 = self.normalizeMatrix * matrix
        let m2 = other.normalizeMatrix * matrix
        let _s = self.white * m1
        let _d = other.white * m2
        return m1 * Matrix.Scale(x: _d.x / _s.x, y: _d.y / _s.y, z: _d.z / _s.z) as Matrix * m2.inverse
    }
    
    public enum ChromaticAdaptationAlgorithm {
        case xyzScaling
        case vonKries
        case bradford
        case other(Matrix)
    }
}

extension CIEXYZColorSpace.ChromaticAdaptationAlgorithm {
    
    @_versioned
    @_inlineable
    var matrix: Matrix {
        switch self {
        case .xyzScaling: return Matrix.Identity
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

public struct CIELabColorSpace : ColorSpaceProtocol {
    
    public typealias Model = LabColorModel
    
    public var cieXYZ: CIEXYZColorSpace
    
    @_inlineable
    public var white: XYZColorModel {
        get {
            return cieXYZ.white
        }
        set {
            cieXYZ.white = newValue
        }
    }
    @_inlineable
    public var black: XYZColorModel {
        get {
            return cieXYZ.black
        }
        set {
            cieXYZ.black = newValue
        }
    }
    
    @_inlineable
    public init(white: Point) {
        self.cieXYZ = CIEXYZColorSpace(white: white)
    }
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel = XYZColorModel(x: 0, y: 0, z: 0)) {
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black)
    }
    @_inlineable
    public init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIELabColorSpace {
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
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
        let _white = XYZColorModel(luminance: 1, point: cieXYZ.normalized.white.point)
        return XYZColorModel(x: x * _white.x, y: y * _white.y, z: z * _white.z)
    }
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        let s = 216.0 / 24389.0
        let t = 24389.0 / 27.0
        let _white = XYZColorModel(luminance: 1, point: cieXYZ.normalized.white.point)
        let x = color.x / _white.x
        let y = color.y / _white.y
        let z = color.z / _white.z
        let fx = x > s ? cbrt(x) : (t * x + 16) / 116
        let fy = y > s ? cbrt(y) : (t * y + 16) / 116
        let fz = z > s ? cbrt(z) : (t * z + 16) / 116
        return LabColorModel(lightness: 116 * fy - 16, a: 500 * (fx - fy), b: 200 * (fy - fz))
    }
}

public struct CIELuvColorSpace : ColorSpaceProtocol {
    
    public typealias Model = LuvColorModel
    
    public var cieXYZ: CIEXYZColorSpace
    
    @_inlineable
    public var white: XYZColorModel {
        get {
            return cieXYZ.white
        }
        set {
            cieXYZ.white = newValue
        }
    }
    @_inlineable
    public var black: XYZColorModel {
        get {
            return cieXYZ.black
        }
        set {
            cieXYZ.black = newValue
        }
    }
    
    @_inlineable
    public init(white: Point) {
        self.cieXYZ = CIEXYZColorSpace(white: white)
    }
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel = XYZColorModel(x: 0, y: 0, z: 0)) {
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black)
    }
    @_inlineable
    public init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
}

extension CIELuvColorSpace {
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
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
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
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

public class CalibratedRGBColorSpace : GammaColorSpaceProtocol {
    
    public typealias Model = RGBColorModel
    
    public let cieXYZ: CIEXYZColorSpace
    public let transferMatrix: Matrix
    
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point) {
        
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black)
        
        let normalizeMatrix = CIEXYZColorSpace(white: white, black: black).normalizeMatrix
        let _white = white * normalizeMatrix
        
        let p = Matrix(a: red.x, b: green.x, c: blue.x, d: 0,
                       e: red.y, f: green.y, g: blue.y, h: 0,
                       i: 1 - red.x - red.y, j: 1 - green.x - green.y, k: 1 - blue.x - blue.y, l: 0)
        
        let c = XYZColorModel(x: _white.x / _white.y, y: 1, z: _white.z / _white.y) * p.inverse
        
        self.transferMatrix = Matrix.Scale(x: c.x, y: c.y, z: c.z) * p * normalizeMatrix.inverse
    }
    
    @_inlineable
    public func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return color
    }
}

extension CalibratedRGBColorSpace {
    
    @_inlineable
    public var red: XYZColorModel {
        return XYZColorModel(x: 1, y: 0, z: 0) * transferMatrix
    }
    
    @_inlineable
    public var green: XYZColorModel {
        return XYZColorModel(x: 0, y: 1, z: 0) * transferMatrix
    }
    
    @_inlineable
    public var blue: XYZColorModel {
        return XYZColorModel(x: 0, y: 0, z: 1) * transferMatrix
    }
}

extension CalibratedRGBColorSpace {
    
    @_inlineable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return XYZColorModel(x: color.red, y: color.green, z: color.blue) * transferMatrix
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let c = color * transferMatrix.inverse
        return Model(red: c.x, green: c.y, blue: c.z)
    }
}

extension CalibratedRGBColorSpace {
    
    private class _adobeRGB: CalibratedRGBColorSpace {
        
        init() {
            super.init(white: XYZColorModel(luminance: 160.00, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0.5557, x: 0.3127, y: 0.3290), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.2100, y: 0.7100), blue: Point(x: 0.1500, y: 0.0600))
        }
    }
    
    public static var adobeRGB: CalibratedRGBColorSpace {
        
        class adobeRGB: _adobeRGB {
            
            override func convertToLinear(_ color: RGBColorModel) -> RGBColorModel {
                
                return RGBColorModel(red: exteneded(color.red) { pow($0, 2.19921875) }, green: exteneded(color.green) { pow($0, 2.19921875) }, blue: exteneded(color.blue) { pow($0, 2.19921875) })
            }
            
            override func convertFromLinear(_ color: RGBColorModel) -> RGBColorModel {
                
                return RGBColorModel(red: exteneded(color.red) { pow($0, 1 / 2.19921875) }, green: exteneded(color.green) { pow($0, 1 / 2.19921875) }, blue: exteneded(color.blue) { pow($0, 1 / 2.19921875) })
            }
        }
        return adobeRGB()
    }
    
    public static var linearAdobeRGB: CalibratedRGBColorSpace {
        
        return _adobeRGB()
    }
    
}

extension CalibratedRGBColorSpace {
    
    private class _sRGB: CalibratedRGBColorSpace {
        
        init() {
            super.init(white: XYZColorModel(luminance: 1, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0, x: 0.3127, y: 0.3290), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.3000, y: 0.6000), blue: Point(x: 0.1500, y: 0.0600))
        }
    }
    
    public static var sRGB: CalibratedRGBColorSpace {
        
        class sRGB: _sRGB {
            
            override func convertToLinear(_ color: RGBColorModel) -> RGBColorModel {
                
                func toLinear(_ x: Double) -> Double {
                    if x > 0.04045 {
                        return pow((x + 0.055) / 1.055, 2.4)
                    }
                    return x / 12.92
                }
                return RGBColorModel(red: exteneded(color.red, toLinear), green: exteneded(color.green, toLinear), blue: exteneded(color.blue, toLinear))
            }
            
            override func convertFromLinear(_ color: RGBColorModel) -> RGBColorModel {
                
                func toGamma(_ x: Double) -> Double {
                    if x > 0.0031308 {
                        return 1.055 * pow(x, 1 / 2.4) - 0.055
                    }
                    return 12.92 * x
                }
                return RGBColorModel(red: exteneded(color.red, toGamma), green: exteneded(color.green, toGamma), blue: exteneded(color.blue, toGamma))
            }
        }
        return sRGB()
    }
    
    public static var linearSRGB: CalibratedRGBColorSpace {
        
        return _sRGB()
    }
    
}

public class CalibratedGrayColorSpace : GammaColorSpaceProtocol {
    
    public typealias Model = GrayColorModel
    
    public let cieXYZ: CIEXYZColorSpace
    
    @_inlineable
    public init(white: Point) {
        self.cieXYZ = CIEXYZColorSpace(white: white)
    }
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel = XYZColorModel(x: 0, y: 0, z: 0)) {
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black)
    }
    @_inlineable
    public init(_ cieXYZ: CIEXYZColorSpace) {
        self.cieXYZ = cieXYZ
    }
    
    @_inlineable
    public func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @_inlineable
    public func convertFromLinear(_ color: Model) -> Model {
        return color
    }
}

extension CalibratedGrayColorSpace {
    
    @_inlineable
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = white * normalizeMatrix
        return XYZColorModel(luminance: color.white, point: _white.point) * normalizeMatrix.inverse
    }
    
    @_inlineable
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalized = color * cieXYZ.normalizeMatrix
        return Model(white: normalized.luminance)
    }
}
