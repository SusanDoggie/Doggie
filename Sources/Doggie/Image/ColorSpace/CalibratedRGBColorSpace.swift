//
//  CalibratedRGBColorSpace.swift
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

public class CalibratedRGBColorSpace : ColorSpaceProtocol {
    
    public typealias Model = RGBColorModel
    
    public private(set) var cieXYZ: CIEXYZColorSpace
    public let transferMatrix: Matrix
    
    @_inlineable
    public convenience init(white: Point, red: Point, green: Point, blue: Point, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.init(white: XYZColorModel(luminance: 1, x: white.x, y: white.y), black: XYZColorModel(x: 0, y: 0, z: 0), red: red, green: green, blue: blue, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        
        self.cieXYZ = CIEXYZColorSpace(white: white, black: black, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
        
        let normalizeMatrix = CIEXYZColorSpace(white: white, black: black).normalizeMatrix
        let _white = white * normalizeMatrix
        
        let p = Matrix(a: red.x, b: green.x, c: blue.x, d: 0,
                       e: red.y, f: green.y, g: blue.y, h: 0,
                       i: 1 - red.x - red.y, j: 1 - green.x - green.y, k: 1 - blue.x - blue.y, l: 0)
        
        let c = XYZColorModel(x: _white.x / _white.y, y: 1, z: _white.z / _white.y) * p.inverse
        
        self.transferMatrix = Matrix.scale(x: c.x, y: c.y, z: c.z) * p * normalizeMatrix.inverse
    }
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return cieXYZ.chromaticAdaptationAlgorithm
        }
        set {
            cieXYZ.chromaticAdaptationAlgorithm = newValue
        }
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

public class CalibratedGammaRGBColorSpace: CalibratedRGBColorSpace {
    
    public let gamma: (Double, Double, Double)
    
    @_inlineable
    public convenience init(white: Point, red: Point, green: Point, blue: Point, gamma: Double, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.init(white: XYZColorModel(luminance: 1, x: white.x, y: white.y), black: XYZColorModel(x: 0, y: 0, z: 0), red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma), chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public convenience init(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: Double, chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.init(white: white, black: black, red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma), chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public init(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double), chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default) {
        self.gamma = gamma
        super.init(white: white, black: black, red: red, green: green, blue: blue, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public override func convertToLinear(_ color: RGBColorModel) -> RGBColorModel {
        return RGBColorModel(red: exteneded(color.red) { pow($0, gamma.0) }, green: exteneded(color.green) { pow($0, gamma.1) }, blue: exteneded(color.blue) { pow($0, gamma.2) })
    }
    
    @_inlineable
    public override func convertFromLinear(_ color: RGBColorModel) -> RGBColorModel {
        return RGBColorModel(red: exteneded(color.red) { pow($0, 1 / gamma.0) }, green: exteneded(color.green) { pow($0, 1 / gamma.1) }, blue: exteneded(color.blue) { pow($0, 1 / gamma.2) })
    }
}

extension CalibratedRGBColorSpace {
    
    public static var adobeRGB: CalibratedRGBColorSpace {
        
        return CalibratedGammaRGBColorSpace(white: XYZColorModel(luminance: 160.00, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0.5557, x: 0.3127, y: 0.3290), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.2100, y: 0.7100), blue: Point(x: 0.1500, y: 0.0600), gamma: 2.19921875)
    }
}

extension CalibratedRGBColorSpace {
    
    public static var sRGB: CalibratedRGBColorSpace {
        
        class sRGB: CalibratedRGBColorSpace {
            
            init() {
                super.init(white: XYZColorModel(luminance: 1, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0, x: 0.3127, y: 0.3290), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.3000, y: 0.6000), blue: Point(x: 0.1500, y: 0.0600))
            }
            
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
}

extension CalibratedRGBColorSpace {
    
    public static var displayP3: CalibratedRGBColorSpace {
        
        class displayP3: CalibratedRGBColorSpace {
            
            init() {
                super.init(white: XYZColorModel(luminance: 1, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0, x: 0.3127, y: 0.3290), red: Point(x: 0.6800, y: 0.3200), green: Point(x: 0.2650, y: 0.6900), blue: Point(x: 0.1500, y: 0.0600))
            }
            
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
        
        return displayP3()
    }
}
