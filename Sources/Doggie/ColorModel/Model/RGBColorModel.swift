//
//  RGBColorModel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@frozen
public struct RGBColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
        }
    }
}

extension RGBColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: RGBColorModel {
        return RGBColorModel()
    }
    
    @inlinable
    @inline(__always)
    public static var white: RGBColorModel {
        return RGBColorModel(red: 1, green: 1, blue: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var red: RGBColorModel {
        return RGBColorModel(red: 1, green: 0, blue: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var green: RGBColorModel {
        return RGBColorModel(red: 0, green: 1, blue: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var blue: RGBColorModel {
        return RGBColorModel(red: 0, green: 0, blue: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var cyan: RGBColorModel {
        return RGBColorModel(red: 0, green: 1, blue: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var magenta: RGBColorModel {
        return RGBColorModel(red: 1, green: 0, blue: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var yellow: RGBColorModel {
        return RGBColorModel(red: 1, green: 1, blue: 0)
    }
}

extension RGBColorModel {
    
    @inlinable
    @inline(__always)
    public init?<S : StringProtocol>(_ hex: S) {
        
        if hex.hasPrefix("#") {
            self.init(hex.dropFirst())
            return
        }
        
        guard let color = UInt32(hex, radix: 16) else { return nil }
        
        switch hex.count {
        case 3:
            
            let red = color & 0xF00
            let green = color & 0xF0
            let blue = color & 0xF
            
            self.init(red: Double((red >> 4) | (red >> 8)) / 255,
                      green: Double(green | (green >> 4)) / 255,
                      blue: Double((blue << 4) | blue) / 255)
            
        case 6:
            
            self.init(red: Double((color >> 16) & 0xFF) / 255,
                      green: Double((color >> 8) & 0xFF) / 255,
                      blue: Double(color & 0xFF) / 255)
            
        default: return nil
        }
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var red: Scalar
        public var green: Scalar
        public var blue: Scalar
        
        @inline(__always)
        public init() {
            self.red = 0
            self.green = 0
            self.blue = 0
        }
        
        @inline(__always)
        public init(red: Scalar, green: Scalar, blue: Scalar) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: RGBColorModel) {
            self.red = Scalar(color.red)
            self.green = Scalar(color.green)
            self.blue = Scalar(color.blue)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.red = Scalar(components.red)
            self.green = Scalar(components.green)
            self.blue = Scalar(components.blue)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: RGBColorModel {
            get {
                return RGBColorModel(red: Double(red), green: Double(green), blue: Double(blue))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension RGBColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> RGBColorModel.FloatComponents<Scalar> {
        return RGBColorModel.FloatComponents(red: transform(red), green: transform(green), blue: transform(blue))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, red)
        updateAccumulatingResult(&accumulator, green)
        updateAccumulatingResult(&accumulator, blue)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: RGBColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> RGBColorModel.FloatComponents<Scalar> {
        return RGBColorModel.FloatComponents(red: transform(self.red, other.red), green: transform(self.green, other.green), blue: transform(self.blue, other.blue))
    }
}
