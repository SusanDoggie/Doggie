//
//  CMYKColorModel.swift
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

public struct CMYKColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 4
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    public var black: Double
    
    @_transparent
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return cyan
            case 1: return magenta
            case 2: return yellow
            case 3: return black
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: cyan = newValue
            case 1: magenta = newValue
            case 2: yellow = newValue
            case 3: black = newValue
            default: fatalError()
            }
        }
    }
}

extension CMYKColorModel {
    
    @_transparent
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 0
    }
}

extension CMYKColorModel {
    
    @inlinable
    public init(_ gray: GrayColorModel) {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 1 - gray.white
    }
    
    @inlinable
    public init(_ rgb: RGBColorModel) {
        self.init(CMYColorModel(rgb))
    }
    
    @inlinable
    public init(_ cmy: CMYColorModel) {
        self.black = Swift.min(cmy.cyan, cmy.magenta, cmy.yellow)
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
}

extension CMYKColorModel {
    
    @_transparent
    public static var black: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 0, black: 1)
    }
    
    @_transparent
    public static var white: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 0, black: 0)
    }
    
    @_transparent
    public static var red: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 1, yellow: 1, black: 0)
    }
    
    @_transparent
    public static var green: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 0, yellow: 1, black: 0)
    }
    
    @_transparent
    public static var blue: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 1, yellow: 0, black: 0)
    }
    
    @_transparent
    public static var cyan: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 0, yellow: 0, black: 0)
    }
    
    @_transparent
    public static var magenta: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 1, yellow: 0, black: 0)
    }
    
    @_transparent
    public static var yellow: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 1, black: 0)
    }
}

extension CMYKColorModel {
    
    @_transparent
    public func min() -> Double {
        return Swift.min(cyan, magenta, yellow, black)
    }
    
    @_transparent
    public func max() -> Double {
        return Swift.max(cyan, magenta, yellow, black)
    }
    
    @_transparent
    public func map(_ transform: (Double) throws -> Double) rethrows -> CMYKColorModel {
        return try CMYKColorModel(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow), black: transform(black))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, cyan)
        try updateAccumulatingResult(&accumulator, magenta)
        try updateAccumulatingResult(&accumulator, yellow)
        try updateAccumulatingResult(&accumulator, black)
        return accumulator
    }
    
    @_transparent
    public func blended(source: CMYKColorModel, blending: (Double, Double) throws -> Double) rethrows -> CMYKColorModel {
        return try CMYKColorModel(cyan: blending(self.cyan, source.cyan), magenta: blending(self.magenta, source.magenta), yellow: blending(self.yellow, source.yellow), black: blending(self.black, source.black))
    }
}

extension CMYKColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.cyan = Double(floatComponents.cyan)
        self.magenta = Double(floatComponents.magenta)
        self.yellow = Double(floatComponents.yellow)
        self.black = Double(floatComponents.black)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(cyan: Float(self.cyan), magenta: Float(self.magenta), yellow: Float(self.yellow), black: Float(self.black))
        }
        set {
            self.cyan = Double(newValue.cyan)
            self.magenta = Double(newValue.magenta)
            self.yellow = Double(newValue.yellow)
            self.black = Double(newValue.black)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 4
        }
        
        public var cyan: Float
        public var magenta: Float
        public var yellow: Float
        public var black: Float
        
        @_transparent
        public init() {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
            self.black = 0
        }
        
        @_transparent
        public init(cyan: Float, magenta: Float, yellow: Float, black: Float) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
            self.black = black
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return cyan
                case 1: return magenta
                case 2: return yellow
                case 3: return black
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: cyan = newValue
                case 1: magenta = newValue
                case 2: yellow = newValue
                case 3: black = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension CMYKColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return Swift.min(cyan, magenta, yellow, black)
    }
    
    @_transparent
    public func max() -> Float {
        return Swift.max(cyan, magenta, yellow, black)
    }
    
    @_transparent
    public func map(_ transform: (Float) throws -> Float) rethrows -> CMYKColorModel.FloatComponents {
        return try CMYKColorModel.FloatComponents(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow), black: transform(black))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, cyan)
        try updateAccumulatingResult(&accumulator, magenta)
        try updateAccumulatingResult(&accumulator, yellow)
        try updateAccumulatingResult(&accumulator, black)
        return accumulator
    }
    
    @_transparent
    public func blended(source: CMYKColorModel.FloatComponents, blending: (Float, Float) throws -> Float) rethrows -> CMYKColorModel.FloatComponents {
        return try CMYKColorModel.FloatComponents(cyan: blending(self.cyan, source.cyan), magenta: blending(self.magenta, source.magenta), yellow: blending(self.yellow, source.yellow), black: blending(self.black, source.black))
    }
}

@_transparent
public prefix func +(val: CMYKColorModel) -> CMYKColorModel {
    return val
}
@_transparent
public prefix func -(val: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: -val.cyan, magenta: -val.magenta, yellow: -val.yellow, black: -val.black)
}
@_transparent
public func +(lhs: CMYKColorModel, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan + rhs.cyan, magenta: lhs.magenta + rhs.magenta, yellow: lhs.yellow + rhs.yellow, black: lhs.black + rhs.black)
}
@_transparent
public func -(lhs: CMYKColorModel, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan - rhs.cyan, magenta: lhs.magenta - rhs.magenta, yellow: lhs.yellow - rhs.yellow, black: lhs.black - rhs.black)
}

@_transparent
public func *(lhs: Double, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs * rhs.cyan, magenta: lhs * rhs.magenta, yellow: lhs * rhs.yellow, black: lhs * rhs.black)
}
@_transparent
public func *(lhs: CMYKColorModel, rhs: Double) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan * rhs, magenta: lhs.magenta * rhs, yellow: lhs.yellow * rhs, black: lhs.black * rhs)
}

@_transparent
public func /(lhs: CMYKColorModel, rhs: Double) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan / rhs, magenta: lhs.magenta / rhs, yellow: lhs.yellow / rhs, black: lhs.black / rhs)
}

@_transparent
public func *= (lhs: inout CMYKColorModel, rhs: Double) {
    lhs.cyan *= rhs
    lhs.magenta *= rhs
    lhs.yellow *= rhs
    lhs.black *= rhs
}
@_transparent
public func /= (lhs: inout CMYKColorModel, rhs: Double) {
    lhs.cyan /= rhs
    lhs.magenta /= rhs
    lhs.yellow /= rhs
    lhs.black /= rhs
}
@_transparent
public func += (lhs: inout CMYKColorModel, rhs: CMYKColorModel) {
    lhs.cyan += rhs.cyan
    lhs.magenta += rhs.magenta
    lhs.yellow += rhs.yellow
    lhs.black += rhs.black
}
@_transparent
public func -= (lhs: inout CMYKColorModel, rhs: CMYKColorModel) {
    lhs.cyan -= rhs.cyan
    lhs.magenta -= rhs.magenta
    lhs.yellow -= rhs.yellow
    lhs.black -= rhs.black
}

@_transparent
public prefix func +(val: CMYKColorModel.FloatComponents) -> CMYKColorModel.FloatComponents {
    return val
}
@_transparent
public prefix func -(val: CMYKColorModel.FloatComponents) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: -val.cyan, magenta: -val.magenta, yellow: -val.yellow, black: -val.black)
}
@_transparent
public func +(lhs: CMYKColorModel.FloatComponents, rhs: CMYKColorModel.FloatComponents) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: lhs.cyan + rhs.cyan, magenta: lhs.magenta + rhs.magenta, yellow: lhs.yellow + rhs.yellow, black: lhs.black + rhs.black)
}
@_transparent
public func -(lhs: CMYKColorModel.FloatComponents, rhs: CMYKColorModel.FloatComponents) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: lhs.cyan - rhs.cyan, magenta: lhs.magenta - rhs.magenta, yellow: lhs.yellow - rhs.yellow, black: lhs.black - rhs.black)
}

@_transparent
public func *(lhs: Float, rhs: CMYKColorModel.FloatComponents) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: lhs * rhs.cyan, magenta: lhs * rhs.magenta, yellow: lhs * rhs.yellow, black: lhs * rhs.black)
}
@_transparent
public func *(lhs: CMYKColorModel.FloatComponents, rhs: Float) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: lhs.cyan * rhs, magenta: lhs.magenta * rhs, yellow: lhs.yellow * rhs, black: lhs.black * rhs)
}

@_transparent
public func /(lhs: CMYKColorModel.FloatComponents, rhs: Float) -> CMYKColorModel.FloatComponents {
    return CMYKColorModel.FloatComponents(cyan: lhs.cyan / rhs, magenta: lhs.magenta / rhs, yellow: lhs.yellow / rhs, black: lhs.black / rhs)
}

@_transparent
public func *= (lhs: inout CMYKColorModel.FloatComponents, rhs: Float) {
    lhs.cyan *= rhs
    lhs.magenta *= rhs
    lhs.yellow *= rhs
    lhs.black *= rhs
}
@_transparent
public func /= (lhs: inout CMYKColorModel.FloatComponents, rhs: Float) {
    lhs.cyan /= rhs
    lhs.magenta /= rhs
    lhs.yellow /= rhs
    lhs.black /= rhs
}
@_transparent
public func += (lhs: inout CMYKColorModel.FloatComponents, rhs: CMYKColorModel.FloatComponents) {
    lhs.cyan += rhs.cyan
    lhs.magenta += rhs.magenta
    lhs.yellow += rhs.yellow
    lhs.black += rhs.black
}
@_transparent
public func -= (lhs: inout CMYKColorModel.FloatComponents, rhs: CMYKColorModel.FloatComponents) {
    lhs.cyan -= rhs.cyan
    lhs.magenta -= rhs.magenta
    lhs.yellow -= rhs.yellow
    lhs.black -= rhs.black
}
