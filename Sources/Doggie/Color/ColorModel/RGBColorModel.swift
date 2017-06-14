//
//  RGBColorModel.swift
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

public struct RGBColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    public var red: Double
    public var green: Double
    public var blue: Double
    
    @_inlineable
    public init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    @_inlineable
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return red
        case 1: return green
        case 2: return blue
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: red = value
        case 1: green = value
        case 2: blue = value
        default: fatalError()
        }
    }
}

extension RGBColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "RGBColorModel(red: \(red), green: \(green), blue: \(blue))"
    }
}

extension RGBColorModel {
    
    @_inlineable
    public init(_ hex: UInt32) {
        self.red = Double((hex >> 16) & 0xFF) / 255
        self.green = Double((hex >> 8) & 0xFF) / 255
        self.blue = Double(hex & 0xFF) / 255
    }
}

extension RGBColorModel {
    
    @_inlineable
    public init(_ gray: GrayColorModel) {
        self.red = gray.white
        self.green = gray.white
        self.blue = gray.white
    }
    
    @_inlineable
    public init(_ cmy: CMYColorModel) {
        self.red = 1 - cmy.cyan
        self.green = 1 - cmy.magenta
        self.blue = 1 - cmy.yellow
    }
    
    @_inlineable
    public init(_ cmyk: CMYKColorModel) {
        self.init(CMYColorModel(cmyk))
    }
}

extension RGBColorModel {
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
    public var brightness: Double {
        get {
            return max(red, green, blue)
        }
        set {
            self = RGBColorModel(hue: hue, saturation: saturation, brightness: newValue)
        }
    }
}
