//
//  RGBColorModel.swift
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

public struct RGBColorModel : ColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var red: Double
    public var green: Double
    public var blue: Double
    
    @_transparent
    public init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    @_transparent
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return red
            case 1: return green
            case 2: return blue
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: red = newValue
            case 1: green = newValue
            case 2: blue = newValue
            default: fatalError()
            }
        }
    }
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(seed: 0, red, green, blue)
    }
}

extension RGBColorModel {
    
    @_transparent
    public static var black: RGBColorModel {
        return RGBColorModel()
    }
    
    @_transparent
    public static var white: RGBColorModel {
        return RGBColorModel(red: 1, green: 1, blue: 1)
    }
    
    @_transparent
    public static var red: RGBColorModel {
        return RGBColorModel(red: 1, green: 0, blue: 0)
    }
    
    @_transparent
    public static var green: RGBColorModel {
        return RGBColorModel(red: 0, green: 1, blue: 0)
    }
    
    @_transparent
    public static var blue: RGBColorModel {
        return RGBColorModel(red: 0, green: 0, blue: 1)
    }
    
    @_transparent
    public static var cyan: RGBColorModel {
        return RGBColorModel(red: 0, green: 1, blue: 1)
    }
    
    @_transparent
    public static var magenta: RGBColorModel {
        return RGBColorModel(red: 1, green: 0, blue: 1)
    }
    
    @_transparent
    public static var yellow: RGBColorModel {
        return RGBColorModel(red: 1, green: 1, blue: 0)
    }
}

extension RGBColorModel {
    
    @_transparent
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
    
    @_transparent
    public init(hue: Double, saturation: Double, brightness: Double) {
        let _hue = positive_mod(hue, 1) * 6
        let __hue = Int(_hue)
        let c = brightness * saturation
        let _mod = positive_mod(_hue, 2)
        let x = c * (1 - abs(_mod - 1))
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
    
    @_transparent
    public var hue: Double {
        get {
            let _max = Swift.max(red, green, blue)
            let _min = Swift.min(red, green, blue)
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
            let _max = Swift.max(red, green, blue)
            let _min = Swift.min(red, green, blue)
            self = RGBColorModel(hue: newValue, saturation: _max == 0 ? 0 : (_max - _min) / _max, brightness: _max)
        }
    }
    
    @_transparent
    public var saturation: Double {
        get {
            let _max = Swift.max(red, green, blue)
            let _min = Swift.min(red, green, blue)
            return _max == 0 ? 0 : (_max - _min) / _max
        }
        set {
            self = RGBColorModel(hue: hue, saturation: newValue, brightness: brightness)
        }
    }
    
    @_transparent
    public var brightness: Double {
        get {
            return Swift.max(red, green, blue)
        }
        set {
            self = RGBColorModel(hue: hue, saturation: saturation, brightness: newValue)
        }
    }
}

extension RGBColorModel {
    
    @_transparent
    public func blended(source: RGBColorModel, blending: (Double, Double) -> Double) -> RGBColorModel {
        return RGBColorModel(red: blending(self.red, source.red), green: blending(self.green, source.green), blue: blending(self.blue, source.blue))
    }
}

extension RGBColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.red = Double(floatComponents.red)
        self.green = Double(floatComponents.green)
        self.blue = Double(floatComponents.blue)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(red: Float(self.red), green: Float(self.green), blue: Float(self.blue))
        }
        set {
            self.red = Double(newValue.red)
            self.green = Double(newValue.green)
            self.blue = Double(newValue.blue)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var red: Float
        public var green: Float
        public var blue: Float
        
        @_transparent
        public init() {
            self.red = 0
            self.green = 0
            self.blue = 0
        }
        
        @_transparent
        public init(red: Float, green: Float, blue: Float) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        @_inlineable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return red
                case 1: return green
                case 2: return blue
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: red = newValue
                case 1: green = newValue
                case 2: blue = newValue
                default: fatalError()
                }
            }
        }
        
        @_transparent
        public var hashValue: Int {
            return hash_combine(seed: 0, red, green, blue)
        }
    }
}

extension RGBColorModel.FloatComponents {
    
    @_transparent
    public func blended(source: RGBColorModel.FloatComponents, blending: (Float, Float) -> Float) -> RGBColorModel.FloatComponents {
        return RGBColorModel.FloatComponents(red: blending(self.red, source.red), green: blending(self.green, source.green), blue: blending(self.blue, source.blue))
    }
}

@_transparent
public prefix func +(val: RGBColorModel) -> RGBColorModel {
    return val
}
@_transparent
public prefix func -(val: RGBColorModel) -> RGBColorModel {
    return RGBColorModel(red: -val.red, green: -val.green, blue: -val.blue)
}
@_transparent
public func +(lhs: RGBColorModel, rhs: RGBColorModel) -> RGBColorModel {
    return RGBColorModel(red: lhs.red + rhs.red, green: lhs.green + rhs.green, blue: lhs.blue + rhs.blue)
}
@_transparent
public func -(lhs: RGBColorModel, rhs: RGBColorModel) -> RGBColorModel {
    return RGBColorModel(red: lhs.red - rhs.red, green: lhs.green - rhs.green, blue: lhs.blue - rhs.blue)
}

@_transparent
public func *(lhs: Double, rhs: RGBColorModel) -> RGBColorModel {
    return RGBColorModel(red: lhs * rhs.red, green: lhs * rhs.green, blue: lhs * rhs.blue)
}
@_transparent
public func *(lhs: RGBColorModel, rhs: Double) -> RGBColorModel {
    return RGBColorModel(red: lhs.red * rhs, green: lhs.green * rhs, blue: lhs.blue * rhs)
}

@_transparent
public func /(lhs: RGBColorModel, rhs: Double) -> RGBColorModel {
    return RGBColorModel(red: lhs.red / rhs, green: lhs.green / rhs, blue: lhs.blue / rhs)
}

@_transparent
public func *= (lhs: inout RGBColorModel, rhs: Double) {
    lhs.red *= rhs
    lhs.green *= rhs
    lhs.blue *= rhs
}
@_transparent
public func /= (lhs: inout RGBColorModel, rhs: Double) {
    lhs.red /= rhs
    lhs.green /= rhs
    lhs.blue /= rhs
}
@_transparent
public func += (lhs: inout RGBColorModel, rhs: RGBColorModel) {
    lhs.red += rhs.red
    lhs.green += rhs.green
    lhs.blue += rhs.blue
}
@_transparent
public func -= (lhs: inout RGBColorModel, rhs: RGBColorModel) {
    lhs.red -= rhs.red
    lhs.green -= rhs.green
    lhs.blue -= rhs.blue
}
@_transparent
public func ==(lhs: RGBColorModel, rhs: RGBColorModel) -> Bool {
    return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
}
@_transparent
public func !=(lhs: RGBColorModel, rhs: RGBColorModel) -> Bool {
    return lhs.red != rhs.red || lhs.green != rhs.green || lhs.blue != rhs.blue
}

@_transparent
public prefix func +(val: RGBColorModel.FloatComponents) -> RGBColorModel.FloatComponents {
    return val
}
@_transparent
public prefix func -(val: RGBColorModel.FloatComponents) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: -val.red, green: -val.green, blue: -val.blue)
}
@_transparent
public func +(lhs: RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: lhs.red + rhs.red, green: lhs.green + rhs.green, blue: lhs.blue + rhs.blue)
}
@_transparent
public func -(lhs: RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: lhs.red - rhs.red, green: lhs.green - rhs.green, blue: lhs.blue - rhs.blue)
}

@_transparent
public func *(lhs: Float, rhs: RGBColorModel.FloatComponents) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: lhs * rhs.red, green: lhs * rhs.green, blue: lhs * rhs.blue)
}
@_transparent
public func *(lhs: RGBColorModel.FloatComponents, rhs: Float) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: lhs.red * rhs, green: lhs.green * rhs, blue: lhs.blue * rhs)
}

@_transparent
public func /(lhs: RGBColorModel.FloatComponents, rhs: Float) -> RGBColorModel.FloatComponents {
    return RGBColorModel.FloatComponents(red: lhs.red / rhs, green: lhs.green / rhs, blue: lhs.blue / rhs)
}

@_transparent
public func *= (lhs: inout RGBColorModel.FloatComponents, rhs: Float) {
    lhs.red *= rhs
    lhs.green *= rhs
    lhs.blue *= rhs
}
@_transparent
public func /= (lhs: inout RGBColorModel.FloatComponents, rhs: Float) {
    lhs.red /= rhs
    lhs.green /= rhs
    lhs.blue /= rhs
}
@_transparent
public func += (lhs: inout RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) {
    lhs.red += rhs.red
    lhs.green += rhs.green
    lhs.blue += rhs.blue
}
@_transparent
public func -= (lhs: inout RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) {
    lhs.red -= rhs.red
    lhs.green -= rhs.green
    lhs.blue -= rhs.blue
}
@_transparent
public func ==(lhs: RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) -> Bool {
    return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
}
@_transparent
public func !=(lhs: RGBColorModel.FloatComponents, rhs: RGBColorModel.FloatComponents) -> Bool {
    return lhs.red != rhs.red || lhs.green != rhs.green || lhs.blue != rhs.blue
}

