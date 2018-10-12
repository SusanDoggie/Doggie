//
//  CMYColorModel.swift
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

public struct CMYColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    
    @inline(__always)
    public init(cyan: Double, magenta: Double, yellow: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return cyan
            case 1: return magenta
            case 2: return yellow
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: cyan = newValue
            case 1: magenta = newValue
            case 2: yellow = newValue
            default: fatalError()
            }
        }
    }
}

extension CMYColorModel {
    
    @inline(__always)
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
    }
}

extension CMYColorModel {
    
    @inlinable
    public init(_ gray: GrayColorModel) {
        self.cyan = 1 - gray.white
        self.magenta = 1 - gray.white
        self.yellow = 1 - gray.white
    }
    
    @inlinable
    public init(_ rgb: RGBColorModel) {
        self.cyan = 1 - rgb.red
        self.magenta = 1 - rgb.green
        self.yellow = 1 - rgb.blue
    }
    
    @inlinable
    public init(_ cmyk: CMYKColorModel) {
        let _k = 1 - cmyk.black
        self.cyan = cmyk.cyan * _k + cmyk.black
        self.magenta = cmyk.magenta * _k + cmyk.black
        self.yellow = cmyk.yellow * _k + cmyk.black
    }
}

extension CMYColorModel {
    
    @_transparent
    public static var black: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 1, yellow: 1)
    }
    
    @_transparent
    public static var white: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 0, yellow: 0)
    }
    
    @_transparent
    public static var red: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 1, yellow: 1)
    }
    
    @_transparent
    public static var green: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 0, yellow: 1)
    }
    
    @_transparent
    public static var blue: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 1, yellow: 0)
    }
    
    @_transparent
    public static var cyan: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 0, yellow: 0)
    }
    
    @_transparent
    public static var magenta: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 1, yellow: 0)
    }
    
    @_transparent
    public static var yellow: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 0, yellow: 1)
    }
}

extension CMYColorModel {
    
    @inline(__always)
    public func min() -> Double {
        return Swift.min(cyan, magenta, yellow)
    }
    
    @inline(__always)
    public func max() -> Double {
        return Swift.max(cyan, magenta, yellow)
    }
    
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> CMYColorModel {
        return CMYColorModel(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow))
    }
    
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        return accumulator
    }
    
    @inline(__always)
    public func combined(_ other: CMYColorModel, _ transform: (Double, Double) -> Double) -> CMYColorModel {
        return CMYColorModel(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow))
    }
}

extension CMYColorModel {
    
    @inline(__always)
    public init(floatComponents: FloatComponents) {
        self.cyan = Double(floatComponents.cyan)
        self.magenta = Double(floatComponents.magenta)
        self.yellow = Double(floatComponents.yellow)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(cyan: Float(self.cyan), magenta: Float(self.magenta), yellow: Float(self.yellow))
        }
        set {
            self.cyan = Double(newValue.cyan)
            self.magenta = Double(newValue.magenta)
            self.yellow = Double(newValue.yellow)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var cyan: Float
        public var magenta: Float
        public var yellow: Float
        
        @inline(__always)
        public init() {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        }
        
        @inline(__always)
        public init(cyan: Float, magenta: Float, yellow: Float) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return cyan
                case 1: return magenta
                case 2: return yellow
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: cyan = newValue
                case 1: magenta = newValue
                case 2: yellow = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension CMYColorModel.FloatComponents {
    
    @inline(__always)
    public func min() -> Float {
        return Swift.min(cyan, magenta, yellow)
    }
    
    @inline(__always)
    public func max() -> Float {
        return Swift.max(cyan, magenta, yellow)
    }
    
    @inline(__always)
    public func map(_ transform: (Float) -> Float) -> CMYColorModel.FloatComponents {
        return CMYColorModel.FloatComponents(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow))
    }
    
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        return accumulator
    }
    
    @inline(__always)
    public func combined(_ other: CMYColorModel.FloatComponents, _ transform: (Float, Float) -> Float) -> CMYColorModel.FloatComponents {
        return CMYColorModel.FloatComponents(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow))
    }
}
