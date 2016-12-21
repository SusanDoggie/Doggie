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
    
    public init(_ cmy: CMYColorModel) {
        self.red = 1 - cmy.cyan
        self.green = 1 - cmy.magenta
        self.blue = 1 - cmy.yellow
    }
    public init(_ cmyk: CMYKColorModel) {
        self.init(CMYColorModel(cmyk))
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
    
    private var _alpha_beta: (alpha: Double, beta: Double) {
        return (0.5 * (2 * red - green - blue), 0.5 * M_SQRT3 * (green - blue))
    }
    private var _hue_chroma: (hue: Double, chroma: Double) {
        let (alpha, beta) = self._alpha_beta
        return (positive_mod(0.5 * M_1_PI * atan2(beta, alpha), 1), sqrt(alpha * alpha + beta * beta))
    }
    private var _hue_saturation: (hue: Double, saturation: Double) {
        let (hue, chroma) = self._hue_chroma
        let brightness = self.brightness
        return (hue, brightness == 0 ? 0 : chroma / brightness)
    }
    
    public var hue: Double {
        get {
            let (alpha, beta) = self._alpha_beta
            return positive_mod(0.5 * M_1_PI * atan2(beta, alpha), 1)
        }
        set {
            let saturation = self.saturation
            let brightness = self.brightness
            self = RGBColorModel(hue: newValue, saturation: saturation, brightness: brightness)
        }
    }
    
    public var saturation: Double {
        get {
            let (alpha, beta) = self._alpha_beta
            let brightness = self.brightness
            return brightness == 0 ? 0 : sqrt(alpha * alpha + beta * beta) / brightness
        }
        set {
            let hue = self.hue
            let brightness = self.brightness
            self = RGBColorModel(hue: hue, saturation: newValue, brightness: brightness)
        }
    }
    
    public var brightness: Double {
        get {
            return max(red, green, blue)
        }
        set {
            let (hue, saturation) = self._hue_saturation
            self = RGBColorModel(hue: hue, saturation: saturation, brightness: newValue)
        }
    }
}

public struct CMYColorModel : ColorModelProtocol {
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    
    public init(cyan: Double, magenta: Double, yellow: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
    }
}

extension CMYColorModel {
    
    public init(_ cmyk: CMYKColorModel) {
        let _k = 1 - cmyk.black
        self.cyan = cmyk.cyan * _k + cmyk.black
        self.magenta = cmyk.magenta * _k + cmyk.black
        self.yellow = cmyk.yellow * _k + cmyk.black
    }
    public init(_ rgb: RGBColorModel) {
        self.cyan = 1 - rgb.red
        self.magenta = 1 - rgb.green
        self.yellow = 1 - rgb.blue
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
    
    public init(_ cmy: CMYColorModel) {
        self.black = min(cmy.cyan, cmy.magenta, cmy.yellow)
        if black == 1 {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        } else {
            let _k = 1 / (1 - black)
            self.cyan = _k * (cmy.cyan - black)
            self.magenta = _k * (cmy.magenta - black)
            self.yellow = _k * (cmy.yellow - black)
        }
    }
    public init(_ rgb: RGBColorModel) {
        self.init(CMYColorModel(rgb))
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

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    public var alpha: Double
}
