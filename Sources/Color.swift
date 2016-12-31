//
//  Color.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public protocol ColorModelProtocol {
    
}

public struct RGBColorModel : ColorModelProtocol {
    
    public var red: Double
    public var green: Double
    public var blue: Double
    
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

extension RGBColorModel : CustomStringConvertible {
    
    public var description: String {
        return "RGBColorModel(red: \(red), green: \(green), blue: \(blue))"
    }
}

extension RGBColorModel {
    
    public init(_ hex: UInt32) {
        self.red = Double((hex >> 16) & 0xFF) / 255
        self.green = Double((hex >> 8) & 0xFF) / 255
        self.blue = Double(hex & 0xFF) / 255
    }
}

extension RGBColorModel {
    
    public init(_ cmyk: CMYKColorModel) {
        let _k = 1 - cmyk.black
        let _cyan = cmyk.cyan * _k + cmyk.black
        let _magenta = cmyk.magenta * _k + cmyk.black
        let _yellow = cmyk.yellow * _k + cmyk.black
        self.red = 1 - _cyan
        self.green = 1 - _magenta
        self.blue = 1 - _yellow
    }
}
extension RGBColorModel {
    
    public init(hue: Double, saturation: Double, brightness: Double) {
        let _hue = positive_mod(hue, 1) * 6
        let __hue = Int(_hue)
        let c = brightness * saturation
        let x = c * (1 - abs(positive_mod(_hue, 2) - 1))
        let m = brightness - c
        switch __hue {
        case 0:
            self.red = c + m
            self.green = x + m
            self.blue = m
        case 1:
            self.red = x + m
            self.green = c + m
            self.blue = m
        case 2:
            self.red = m
            self.green = c + m
            self.blue = x + m
        case 3:
            self.red = m
            self.green = x + m
            self.blue = c + m
        case 4:
            self.red = x + m
            self.green = m
            self.blue = c + m
        default:
            self.red = c + m
            self.green = m
            self.blue = x + m
        }
    }
}

extension RGBColorModel {
    
    public var hue: Double {
        get {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            let c = _max - _min
            if c == 0 {
                return 0
            }
            switch _max {
            case red: return positive_mod((green - blue) / (6 * c), 1)
            case green: return positive_mod((blue - red) / (6 * c) + 2 / 6, 1)
            case blue: return positive_mod((red - green) / (6 * c) + 4 / 6, 1)
            default: return 0
            }
        }
        set {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            self = RGBColorModel(hue: newValue, saturation: _max == 0 ? 0 : (_max - _min) / _max, brightness: _max)
        }
    }
    
    public var saturation: Double {
        get {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            return _max == 0 ? 0 : (_max - _min) / _max
        }
        set {
            self = RGBColorModel(hue: hue, saturation: newValue, brightness: brightness)
        }
    }
    
    public var brightness: Double {
        get {
            return max(red, green, blue)
        }
        set {
            self = RGBColorModel(hue: hue, saturation: saturation, brightness: newValue)
        }
    }
}

public struct CMYKColorModel : ColorModelProtocol {
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    public var black: Double
    
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
    }
}

extension CMYKColorModel : CustomStringConvertible {
    
    public var description: String {
        return "CMYKColorModel(cyan: \(cyan), magenta: \(magenta), yellow: \(yellow), black: \(black))"
    }
}

extension CMYKColorModel {
    
    public init(_ rgb: RGBColorModel) {
        let _cyan = 1 - rgb.red
        let _magenta = 1 - rgb.green
        let _yellow = 1 - rgb.blue
        self.black = min(_cyan, _magenta, _yellow)
        if black == 1 {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        } else {
            let _k = 1 / (1 - black)
            self.cyan = _k * (_cyan - black)
            self.magenta = _k * (_magenta - black)
            self.yellow = _k * (_yellow - black)
        }
    }
}

public struct LabColorModel : ColorModelProtocol {
    
    /// The lightness dimension.
    public var lightness: Double
    /// The a color component.
    public var a: Double
    /// The b color component.
    public var b: Double
    
    public init(lightness: Double, a: Double, b: Double) {
        self.lightness = lightness
        self.a = a
        self.b = b
    }
}

extension LabColorModel : CustomStringConvertible {
    
    public var description: String {
        return "LabColorModel(lightness: \(lightness), a: \(a), b: \(b))"
    }
}

public struct XYZColorModel : ColorModelProtocol {
    
    /// The Y luminance component.
    public var x: Double
    /// The Cb chroma component.
    public var y: Double
    /// The Cr chroma component.
    public var z: Double
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(_ Yxy: YxyColorModel) {
        let _y = 1 / Yxy.y
        self.x = Yxy.x * _y * Yxy.luminance
        self.y = Yxy.luminance
        self.z = (1 - Yxy.x - Yxy.y) * _y * Yxy.luminance
    }
}
extension XYZColorModel : CustomStringConvertible {
    
    public var description: String {
        return "XYZColorModel(x: \(x), y: \(y), z: \(z))"
    }
}

public struct YxyColorModel : ColorModelProtocol {
    
    public var luminance: Double
    public var x: Double
    public var y: Double
    
    public init(luminance: Double, x: Double, y: Double) {
        self.luminance = luminance
        self.x = x
        self.y = y
    }
    
    public init(_ xyz: XYZColorModel) {
        let _s = 1 / (xyz.x + xyz.y + xyz.z)
        self.luminance = xyz.y
        self.x = _s * xyz.x
        self.y = _s * xyz.y
    }
}

extension YxyColorModel : CustomStringConvertible {
    
    public var description: String {
        return "YxyColorModel(luminance: \(luminance), x: \(x), y: \(y))"
    }
}

public func * <T: MatrixProtocol>(lhs: XYZColorModel, rhs: T) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}

public func *= <T: MatrixProtocol>(lhs: inout XYZColorModel, rhs: T) {
    lhs = lhs * rhs
}

public struct GrayColorModel : ColorModelProtocol {
    
    public var white: Double
    
    public init(white: Double) {
        self.white = white
    }
}

public protocol ColorSpaceProtocol {
    
    associatedtype Model : ColorModelProtocol
    
}

public struct CIEXYZColorSpace : ColorSpaceProtocol {
    
    public typealias Model = XYZColorModel
    public typealias ConnectionSpace = CIEXYZColorSpace
    
    public var white: Model
    
    public init(white: Model) {
        self.white = white
    }
}

extension CIEXYZColorSpace {
    
    public enum ChromaticAdaptationAlgorithm {
        case XYZScaling
        case VonKries
        case Bradford
    }
    
    public func convert(_ color: Model, to other: CIEXYZColorSpace, algorithm: ChromaticAdaptationAlgorithm = .Bradford) -> Model {
        let matrix = algorithm.matrix
        let _s = self.white * matrix
        let _d = other.white * matrix
        return color * matrix * Matrix.Scale(x: _d.x / _s.x, y: _d.y / _s.y, z: _d.z / _s.z) * matrix.inverse
    }
}

extension CIEXYZColorSpace.ChromaticAdaptationAlgorithm {
    
    fileprivate var matrix: Matrix {
        switch self {
        case .XYZScaling: return Matrix(Matrix.Identity())
        case .VonKries: return Matrix(a: 0.4002400, b: 0.7076000, c: -0.0808100, d: 0,
                                      e: -0.2263000, f: 1.1653200, g: 0.0457000, h: 0,
                                      i: 0.0000000, j: 0.0000000, k: 0.9182200, l: 0)
        case .Bradford: return Matrix(a: 0.8951000, b: 0.2664000, c: -0.1614000, d: 0,
                                      e: -0.7502000, f: 1.7135000, g: 0.0367000, h: 0,
                                      i: 0.0389000, j: -0.0685000, k: 1.0296000, l: 0)
        }
    }
}

public class CalibratedRGBColorSpace : ColorSpaceProtocol {
    
    public typealias Model = RGBColorModel
    
    public var white: XYZColorModel
    public var black: XYZColorModel
    public var red: XYZColorModel
    public var green: XYZColorModel
    public var blue: XYZColorModel
    public var gamma: Double
    
    public init(white: XYZColorModel, black: XYZColorModel, red: XYZColorModel, green: XYZColorModel, blue: XYZColorModel, gamma: Double) {
        self.white = white
        self.black = black
        self.red = red
        self.green = green
        self.blue = blue
        self.gamma = gamma
    }
}

extension CalibratedRGBColorSpace {
    
    private var normalizeMatrix: Matrix {
        return Matrix.Translate(x: -black.z, y: -black.y, z: -black.z) * Matrix.Scale(x: white.x / (white.y * (white.x - black.x)), y: 1 / (white.y - black.y), z: white.z / (white.y * (white.z - black.z)))
    }
    
    private var transferMatrix: Matrix {
        let normalizeMatrix = self.normalizeMatrix
        let _red = red * normalizeMatrix
        let _green = green * normalizeMatrix
        let _blue = blue * normalizeMatrix
        let _white = white * normalizeMatrix
        
        let s = _white * Matrix(a: _red.x, b: _green.x, c: _blue.x, d: 0,
                                e: _red.y, f: _green.y, g: _blue.y, h: 0,
                                i: _red.z, j: _green.z, k: _blue.z, l: 0).inverse
        
        return Matrix(a: s.x * _red.x, b: s.y * _green.x, c: s.z * _blue.x, d: 0,
                      e: s.x * _red.y, f: s.y * _green.y, g: s.z * _blue.y, h: 0,
                      i: s.x * _red.z, j: s.y * _green.z, k: s.z * _blue.z, l: 0)
    }
    
    public var cieXYZ: CIEXYZColorSpace {
        return CIEXYZColorSpace(white: white * normalizeMatrix)
    }
    
    public func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let transferMatrix = self.transferMatrix
        let _color = Vector(x: color.red, y: color.green, z: color.blue) * transferMatrix
        return XYZColorModel(x: _color.x, y: _color.y, z: _color.z)
    }
    public func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let transferMatrix = self.transferMatrix
        let _color = Vector(x: color.x, y: color.y, z: color.z) * transferMatrix.inverse
        return Model(red: _color.x, green: _color.y, blue: _color.z)
    }
}

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    public var alpha: Double
}
