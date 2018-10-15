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
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var red: Double
    public var green: Double
    public var blue: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    @inlinable
    @inline(__always)
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public init(_ hex: UInt32) {
        self.red = Double((hex >> 16) & 0xFF) / 255
        self.green = Double((hex >> 8) & 0xFF) / 255
        self.blue = Double(hex & 0xFF) / 255
    }
}

extension RGBColorModel {
    
    @inlinable
    public init(_ gray: GrayColorModel) {
        self.red = gray.white
        self.green = gray.white
        self.blue = gray.white
    }
    
    @inlinable
    public init(_ cmy: CMYColorModel) {
        self.red = 1 - cmy.cyan
        self.green = 1 - cmy.magenta
        self.blue = 1 - cmy.yellow
    }
    
    @inlinable
    public init(_ cmyk: CMYKColorModel) {
        self.init(CMYColorModel(cmyk))
    }
}

extension RGBColorModel {
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public func min() -> Double {
        return Swift.min(red, green, blue)
    }
    
    @inlinable
    @inline(__always)
    public func max() -> Double {
        return Swift.max(red, green, blue)
    }
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> RGBColorModel {
        return RGBColorModel(red: transform(red), green: transform(green), blue: transform(blue))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, red)
        updateAccumulatingResult(&accumulator, green)
        updateAccumulatingResult(&accumulator, blue)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: RGBColorModel, _ transform: (Double, Double) -> Double) -> RGBColorModel {
        return RGBColorModel(red: transform(self.red, other.red), green: transform(self.green, other.green), blue: transform(self.blue, other.blue))
    }
}

extension RGBColorModel {
    
    @inlinable
    @inline(__always)
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
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var red: Float
        public var green: Float
        public var blue: Float
        
        @inline(__always)
        public init() {
            self.red = 0
            self.green = 0
            self.blue = 0
        }
        
        @inline(__always)
        public init(red: Float, green: Float, blue: Float) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        @inlinable
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
    }
}

extension RGBColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func min() -> Float {
        return Swift.min(red, green, blue)
    }
    
    @inlinable
    @inline(__always)
    public func max() -> Float {
        return Swift.max(red, green, blue)
    }
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Float) -> Float) -> RGBColorModel.FloatComponents {
        return RGBColorModel.FloatComponents(red: transform(red), green: transform(green), blue: transform(blue))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, red)
        updateAccumulatingResult(&accumulator, green)
        updateAccumulatingResult(&accumulator, blue)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: RGBColorModel.FloatComponents, _ transform: (Float, Float) -> Float) -> RGBColorModel.FloatComponents {
        return RGBColorModel.FloatComponents(red: transform(self.red, other.red), green: transform(self.green, other.green), blue: transform(self.blue, other.blue))
    }
}
