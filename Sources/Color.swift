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

public struct XYZColorModel : ColorModelProtocol {
    
    /// The Y luminance component.
    public var X: Double
    /// The Cb chroma component.
    public var Y: Double
    /// The Cr chroma component.
    public var Z: Double
    
    public var x: Double {
        get {
            return X / (X + Y + Z)
        }
        set {
            self = XYZColorModel(x: newValue, y: y, luminance: luminance)
        }
    }
    public var y: Double {
        get {
            return Y / (X + Y + Z)
        }
        set {
            self = XYZColorModel(x: x, y: newValue, luminance: luminance)
        }
    }
    
    public var luminance: Double {
        get {
            return Y
        }
        set {
            self.Y = newValue
        }
    }
    
    public init(x: Double, y: Double, z: Double) {
        self.X = x
        self.Y = y
        self.Z = z
    }
    
    public init(x: Double, y: Double, luminance: Double) {
        let _y = 1 / y
        self.X = x * _y * luminance
        self.Y = luminance
        self.Z = (1 - x - y) * _y * luminance
    }
}

public func * <T: MatrixProtocol>(lhs: XYZColorModel, rhs: T) -> XYZColorModel {
    return XYZColorModel(x: lhs.X * rhs.a + lhs.Y * rhs.b + lhs.Z * rhs.c + rhs.d, y: lhs.X * rhs.e + lhs.Y * rhs.f + lhs.Z * rhs.g + rhs.h, z: lhs.X * rhs.i + lhs.Y * rhs.j + lhs.Z * rhs.k + rhs.l)
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
    
    public var white: Point
    
    public init(white: Point) {
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
        let matrix: Matrix
        switch algorithm {
        case .XYZScaling: matrix = Matrix(Matrix.Identity())
        case .VonKries: matrix = Matrix(a: 0.4002400, b: 0.7076000, c: -0.0808100, d: 0,
                                        e: -0.2263000, f: 1.1653200, g: 0.0457000, h: 0,
                                        i: 0.0000000, j: 0.0000000, k: 0.9182200, l: 0)
        case .Bradford: matrix = Matrix(a: 0.8951000, b: 0.2664000, c: -0.1614000, d: 0,
                                        e: -0.7502000, f: 1.7135000, g: 0.0367000, h: 0,
                                        i: 0.0389000, j: -0.0685000, k: 1.0296000, l: 0)
        }
        let _s = XYZColorModel(x: self.white.x, y: self.white.y, luminance: 1) * matrix
        let _d = XYZColorModel(x: self.white.x, y: self.white.y, luminance: 1) * matrix
        return color * matrix * Matrix.Scale(x: _d.X / _s.X, y: _d.Y / _s.Y, z: _d.Z / _s.Z) * matrix.inverse
    }
}

public class CalibratedRGBColorSpace : ColorSpaceProtocol {
    
    public typealias Model = RGBColorModel
    
    public var white: Point
    public var red: Point
    public var green: Point
    public var blue: Point
    public var whiteLuminance: Double
    public var blackLuminance: Double
    
    public init(white: Point, red: Point, green: Point, blue: Point, whiteLuminance: Double = 1, blackLuminance: Double = 0) {
        self.white = white
        self.red = red
        self.green = green
        self.blue = blue
        self.whiteLuminance = whiteLuminance
        self.blackLuminance = blackLuminance
    }
}

extension CalibratedRGBColorSpace {
    
    private var normalizeMatrix: Matrix {
        let _white = XYZColorModel(x: self.white.x, y: self.white.y, luminance: whiteLuminance)
        let _black = XYZColorModel(x: self.white.x, y: self.white.y, luminance: blackLuminance)
        return Matrix.Translate(x: -_black.X, y: -_black.Y, z: -_black.Z) * Matrix.Scale(x: _white.X / (_white.Y * (_white.X - _black.X)), y: 1 / (_white.Y - _black.Y), z: _white.Z / (_white.Y * (_white.Z - _black.Z)))
    }
    
    private var transferMatrix: Matrix {
        let normalizeMatrix = self.normalizeMatrix
        let _red = XYZColorModel(x: self.red.x, y: self.red.y, luminance: whiteLuminance) * normalizeMatrix
        let _green = XYZColorModel(x: self.green.x, y: self.green.y, luminance: whiteLuminance) * normalizeMatrix
        let _blue = XYZColorModel(x: self.blue.x, y: self.blue.y, luminance: whiteLuminance) * normalizeMatrix
        let _white = XYZColorModel(x: self.white.x, y: self.white.y, luminance: whiteLuminance) * normalizeMatrix
        
        let s = _white * Matrix(a: _red.X, b: _green.X, c: _blue.X, d: 0,
                                e: _red.Y, f: _green.Y, g: _blue.Y, h: 0,
                                i: _red.Z, j: _green.Z, k: _blue.Z, l: 0).inverse
        
        return Matrix(a: s.X * _red.X, b: s.Y * _green.X, c: s.Z * _blue.X, d: 0,
                      e: s.X * _red.Y, f: s.Y * _green.Y, g: s.Z * _blue.Y, h: 0,
                      i: s.X * _red.Z, j: s.Y * _green.Z, k: s.Z * _blue.Z, l: 0)
    }
    
    public var cieXYZ: CIEXYZColorSpace {
        let _white = XYZColorModel(x: self.white.x, y: self.white.y, luminance: whiteLuminance) * normalizeMatrix
        return CIEXYZColorSpace(white: Point(x: _white.x, y: _white.y))
    }
    
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        let transferMatrix = self.transferMatrix
        let _color = Vector(x: color.red, y: color.green, z: color.blue) * transferMatrix
        return XYZColorModel(x: _color.x, y: _color.y, z: _color.z)
    }
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        let transferMatrix = self.transferMatrix
        let _color = Vector(x: color.X, y: color.Y, z: color.Z) * transferMatrix.inverse
        return Model(red: _color.x, green: _color.y, blue: _color.z)
    }
}

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    public var alpha: Double
}
