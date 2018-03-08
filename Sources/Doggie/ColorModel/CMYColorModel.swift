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
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    
    @_transparent
    public init(cyan: Double, magenta: Double, yellow: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
    }
    
    @_inlineable
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
    
    @_transparent
    public var hashValue: Int {
        return hash_combine(cyan, magenta, yellow)
    }
}

extension CMYColorModel {
    
    @_transparent
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
    }
}

extension CMYColorModel {
    
    @_inlineable
    public init(_ gray: GrayColorModel) {
        self.cyan = 1 - gray.white
        self.magenta = 1 - gray.white
        self.yellow = 1 - gray.white
    }
    
    @_inlineable
    public init(_ rgb: RGBColorModel) {
        self.cyan = 1 - rgb.red
        self.magenta = 1 - rgb.green
        self.yellow = 1 - rgb.blue
    }
    
    @_inlineable
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
    
    @_transparent
    public func blended(source: CMYColorModel, blending: (Double, Double) -> Double) -> CMYColorModel {
        return CMYColorModel(cyan: blending(self.cyan, source.cyan), magenta: blending(self.magenta, source.magenta), yellow: blending(self.yellow, source.yellow))
    }
}

extension CMYColorModel {
    
    @_transparent
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
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var cyan: Float
        public var magenta: Float
        public var yellow: Float
        
        @_transparent
        public init() {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        }
        
        @_transparent
        public init(cyan: Float, magenta: Float, yellow: Float) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
        }
        
        @_inlineable
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
        
        @_transparent
        public var hashValue: Int {
            return hash_combine(cyan, magenta, yellow)
        }
    }
}

extension CMYColorModel.FloatComponents {
    
    @_transparent
    public func blended(source: CMYColorModel.FloatComponents, blending: (Float, Float) -> Float) -> CMYColorModel.FloatComponents {
        return CMYColorModel.FloatComponents(cyan: blending(self.cyan, source.cyan), magenta: blending(self.magenta, source.magenta), yellow: blending(self.yellow, source.yellow))
    }
}

@_transparent
public prefix func +(val: CMYColorModel) -> CMYColorModel {
    return val
}
@_transparent
public prefix func -(val: CMYColorModel) -> CMYColorModel {
    return CMYColorModel(cyan: -val.cyan, magenta: -val.magenta, yellow: -val.yellow)
}
@_transparent
public func +(lhs: CMYColorModel, rhs: CMYColorModel) -> CMYColorModel {
    return CMYColorModel(cyan: lhs.cyan + rhs.cyan, magenta: lhs.magenta + rhs.magenta, yellow: lhs.yellow + rhs.yellow)
}
@_transparent
public func -(lhs: CMYColorModel, rhs: CMYColorModel) -> CMYColorModel {
    return CMYColorModel(cyan: lhs.cyan - rhs.cyan, magenta: lhs.magenta - rhs.magenta, yellow: lhs.yellow - rhs.yellow)
}

@_transparent
public func *(lhs: Double, rhs: CMYColorModel) -> CMYColorModel {
    return CMYColorModel(cyan: lhs * rhs.cyan, magenta: lhs * rhs.magenta, yellow: lhs * rhs.yellow)
}
@_transparent
public func *(lhs: CMYColorModel, rhs: Double) -> CMYColorModel {
    return CMYColorModel(cyan: lhs.cyan * rhs, magenta: lhs.magenta * rhs, yellow: lhs.yellow * rhs)
}

@_transparent
public func /(lhs: CMYColorModel, rhs: Double) -> CMYColorModel {
    return CMYColorModel(cyan: lhs.cyan / rhs, magenta: lhs.magenta / rhs, yellow: lhs.yellow / rhs)
}

@_transparent
public func *= (lhs: inout CMYColorModel, rhs: Double) {
    lhs.cyan *= rhs
    lhs.magenta *= rhs
    lhs.yellow *= rhs
}
@_transparent
public func /= (lhs: inout CMYColorModel, rhs: Double) {
    lhs.cyan /= rhs
    lhs.magenta /= rhs
    lhs.yellow /= rhs
}
@_transparent
public func += (lhs: inout CMYColorModel, rhs: CMYColorModel) {
    lhs.cyan += rhs.cyan
    lhs.magenta += rhs.magenta
    lhs.yellow += rhs.yellow
}
@_transparent
public func -= (lhs: inout CMYColorModel, rhs: CMYColorModel) {
    lhs.cyan -= rhs.cyan
    lhs.magenta -= rhs.magenta
    lhs.yellow -= rhs.yellow
}
@_transparent
public func ==(lhs: CMYColorModel, rhs: CMYColorModel) -> Bool {
    return lhs.cyan == rhs.cyan && lhs.magenta == rhs.magenta && lhs.yellow == rhs.yellow
}
@_transparent
public func !=(lhs: CMYColorModel, rhs: CMYColorModel) -> Bool {
    return lhs.cyan != rhs.cyan || lhs.magenta != rhs.magenta || lhs.yellow != rhs.yellow
}

@_transparent
public prefix func +(val: CMYColorModel.FloatComponents) -> CMYColorModel.FloatComponents {
    return val
}
@_transparent
public prefix func -(val: CMYColorModel.FloatComponents) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: -val.cyan, magenta: -val.magenta, yellow: -val.yellow)
}
@_transparent
public func +(lhs: CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: lhs.cyan + rhs.cyan, magenta: lhs.magenta + rhs.magenta, yellow: lhs.yellow + rhs.yellow)
}
@_transparent
public func -(lhs: CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: lhs.cyan - rhs.cyan, magenta: lhs.magenta - rhs.magenta, yellow: lhs.yellow - rhs.yellow)
}

@_transparent
public func *(lhs: Float, rhs: CMYColorModel.FloatComponents) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: lhs * rhs.cyan, magenta: lhs * rhs.magenta, yellow: lhs * rhs.yellow)
}
@_transparent
public func *(lhs: CMYColorModel.FloatComponents, rhs: Float) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: lhs.cyan * rhs, magenta: lhs.magenta * rhs, yellow: lhs.yellow * rhs)
}

@_transparent
public func /(lhs: CMYColorModel.FloatComponents, rhs: Float) -> CMYColorModel.FloatComponents {
    return CMYColorModel.FloatComponents(cyan: lhs.cyan / rhs, magenta: lhs.magenta / rhs, yellow: lhs.yellow / rhs)
}

@_transparent
public func *= (lhs: inout CMYColorModel.FloatComponents, rhs: Float) {
    lhs.cyan *= rhs
    lhs.magenta *= rhs
    lhs.yellow *= rhs
}
@_transparent
public func /= (lhs: inout CMYColorModel.FloatComponents, rhs: Float) {
    lhs.cyan /= rhs
    lhs.magenta /= rhs
    lhs.yellow /= rhs
}
@_transparent
public func += (lhs: inout CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) {
    lhs.cyan += rhs.cyan
    lhs.magenta += rhs.magenta
    lhs.yellow += rhs.yellow
}
@_transparent
public func -= (lhs: inout CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) {
    lhs.cyan -= rhs.cyan
    lhs.magenta -= rhs.magenta
    lhs.yellow -= rhs.yellow
}
@_transparent
public func ==(lhs: CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) -> Bool {
    return lhs.cyan == rhs.cyan && lhs.magenta == rhs.magenta && lhs.yellow == rhs.yellow
}
@_transparent
public func !=(lhs: CMYColorModel.FloatComponents, rhs: CMYColorModel.FloatComponents) -> Bool {
    return lhs.cyan != rhs.cyan || lhs.magenta != rhs.magenta || lhs.yellow != rhs.yellow
}

