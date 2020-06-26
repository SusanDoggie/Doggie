//
//  CalibratedRGBColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

extension ColorSpace where Model == RGBColorModel {
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point) -> ColorSpace {
        return ColorSpace(base: CalibratedRGBColorSpace(CIEXYZColorSpace(white: white), red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point, gamma: Double) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white), red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma)))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white), red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point) -> ColorSpace {
        return ColorSpace(base: CalibratedRGBColorSpace(CIEXYZColorSpace(white: white, black: black), red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: Double) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white, black: black), red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma)))
    }
    
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white, black: black), red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point) -> ColorSpace {
        return ColorSpace(base: CalibratedRGBColorSpace(CIEXYZColorSpace(white: white, luminance: luminance, contrastRatio: contrastRatio), red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point, gamma: Double) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white, luminance: luminance, contrastRatio: contrastRatio), red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma)))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> ColorSpace {
        return ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: white, luminance: luminance, contrastRatio: contrastRatio), red: red, green: green, blue: blue, gamma: gamma))
    }
}

@usableFromInline
class CalibratedRGBColorSpace: ColorSpaceBaseProtocol {
    
    @usableFromInline
    typealias Model = RGBColorModel
    
    @usableFromInline
    let cieXYZ: CIEXYZColorSpace
    
    @usableFromInline
    let transferMatrix: Matrix
    
    @inlinable
    init(cieXYZ: CIEXYZColorSpace, transferMatrix: Matrix) {
        self.cieXYZ = cieXYZ
        self.transferMatrix = transferMatrix
    }
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace, red: Point, green: Point, blue: Point) {
        
        self.cieXYZ = cieXYZ
        
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        
        let p = Matrix(a: red.x, b: green.x, c: blue.x, d: 0,
                       e: red.y, f: green.y, g: blue.y, h: 0,
                       i: 1 - red.x - red.y, j: 1 - green.x - green.y, k: 1 - blue.x - blue.y, l: 0)
        
        let c = XYZColorModel(x: _white.x / _white.y, y: 1, z: _white.z / _white.y) * p.inverse
        
        self.transferMatrix = Matrix.scale(x: c.x, y: c.y, z: c.z) * p * normalizeMatrix.inverse
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
    func iccCurve(_ index: Int) -> iccCurve {
        return .identity
    }
    
    @inlinable
    var localizedName: String? {
        return "Doggie RGB Profile (\(CIE1931(rawValue: cieXYZ.white.point)))"
    }
    
    @inlinable
    func __equalTo(_ other: CalibratedRGBColorSpace) -> Bool {
        guard type(of: other) == CalibratedRGBColorSpace.self else { return false }
        return self.cieXYZ == other.cieXYZ && self.transferMatrix == other.transferMatrix
    }
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("CalibratedRGBColorSpace")
        hasher.combine(cieXYZ)
        hasher.combine(transferMatrix)
    }
    
    @inlinable
    static func ==(lhs: CalibratedRGBColorSpace, rhs: CalibratedRGBColorSpace) -> Bool {
        return lhs.__equalTo(rhs)
    }
}

extension CalibratedRGBColorSpace {
    
    @inlinable
    var linearTone: CalibratedRGBColorSpace {
        return CalibratedRGBColorSpace(cieXYZ: cieXYZ, transferMatrix: transferMatrix)
    }
}

extension CalibratedRGBColorSpace {
    
    @inlinable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return XYZColorModel(x: color.red, y: color.green, z: color.blue) * transferMatrix
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let c = color * transferMatrix.inverse
        return Model(red: c.x, green: c.y, blue: c.z)
    }
}

@usableFromInline
class CalibratedGammaRGBColorSpace: CalibratedRGBColorSpace {
    
    @usableFromInline
    let gamma: (Double, Double, Double)
    
    @inlinable
    init(_ cieXYZ: CIEXYZColorSpace, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) {
        self.gamma = gamma
        super.init(cieXYZ, red: red, green: green, blue: blue)
    }
    
    @inlinable
    override func convertToLinear(_ color: RGBColorModel) -> RGBColorModel {
        return RGBColorModel(red: exteneded(color.red) { pow($0, gamma.0) }, green: exteneded(color.green) { pow($0, gamma.1) }, blue: exteneded(color.blue) { pow($0, gamma.2) })
    }
    
    @inlinable
    override func convertFromLinear(_ color: RGBColorModel) -> RGBColorModel {
        return RGBColorModel(red: exteneded(color.red) { pow($0, 1 / gamma.0) }, green: exteneded(color.green) { pow($0, 1 / gamma.1) }, blue: exteneded(color.blue) { pow($0, 1 / gamma.2) })
    }
    
    @inlinable
    override func iccCurve(_ index: Int) -> iccCurve {
        switch index {
        case 0: return .gamma(gamma.0)
        case 1: return .gamma(gamma.1)
        case 2: return .gamma(gamma.2)
        default: fatalError()
        }
    }
    
    @inlinable
    override var localizedName: String? {
        let _gamma = gamma.0 == gamma.1 && gamma.0 == gamma.2 ? "\(Decimal(gamma.0).rounded(scale: 9))" : "\(gamma)"
        return "Doggie RGB Gamma \(_gamma) Profile (\(CIE1931(rawValue: cieXYZ.white.point)))"
    }
    
    @inlinable
    override func __equalTo(_ other: CalibratedRGBColorSpace) -> Bool {
        guard type(of: other) == CalibratedGammaRGBColorSpace.self else { return false }
        guard let other = other as? CalibratedGammaRGBColorSpace else { return false }
        return self.cieXYZ == other.cieXYZ && self.transferMatrix == other.transferMatrix && self.gamma == other.gamma
    }
    
    @inlinable
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(gamma.0)
        hasher.combine(gamma.1)
        hasher.combine(gamma.2)
    }
}

