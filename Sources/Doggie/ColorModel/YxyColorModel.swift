//
//  YxyColorModel.swift
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

public struct YxyColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
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
    
    public var luminance: Double
    public var x: Double
    public var y: Double
    
    @_transparent
    public init() {
        self.luminance = 0
        self.x = 0
        self.y = 0
    }
    
    @_transparent
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @_transparent
    public init(luminance: Double, x: Double, y: Double) {
        self.luminance = luminance
        self.x = x
        self.y = y
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return luminance
            case 1: return x
            case 2: return y
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: luminance = newValue
            case 1: x = newValue
            case 2: y = newValue
            default: fatalError()
            }
        }
    }
}

extension YxyColorModel {
    
    @inlinable
    public init(_ xyz: XYZColorModel) {
        self.luminance = xyz.luminance
        let point = xyz.point
        self.x = point.x
        self.y = point.y
    }
}

extension YxyColorModel {
    
    @_transparent
    public var point: Point {
        get {
            return Point(x: x, y: y)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
}

extension YxyColorModel {
    
    @_transparent
    public static var black: YxyColorModel {
        return YxyColorModel()
    }
}

extension YxyColorModel {
    
    @_transparent
    public func min() -> Double {
        return Swift.min(luminance, x, y)
    }
    
    @_transparent
    public func max() -> Double {
        return Swift.max(luminance, x, y)
    }
    
    @_transparent
    public func map(_ transform: (Double) throws -> Double) rethrows -> YxyColorModel {
        return try YxyColorModel(luminance: transform(luminance), x: transform(x), y: transform(y))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, luminance)
        try updateAccumulatingResult(&accumulator, x)
        try updateAccumulatingResult(&accumulator, y)
        return accumulator
    }
    
    @_transparent
    public func blended(source: YxyColorModel, blending: (Double, Double) throws -> Double) rethrows -> YxyColorModel {
        return try YxyColorModel(luminance: blending(self.luminance, source.luminance), x: blending(self.x, source.x), y: blending(self.y, source.y))
    }
}

extension YxyColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.luminance = Double(floatComponents.luminance)
        self.x = Double(floatComponents.x)
        self.y = Double(floatComponents.y)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(luminance: Float(self.luminance), x: Float(self.x), y: Float(self.y))
        }
        set {
            self.luminance = Double(newValue.luminance)
            self.x = Double(newValue.x)
            self.y = Double(newValue.y)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var luminance: Float
        public var x: Float
        public var y: Float
        
        @_transparent
        public init() {
            self.luminance = 0
            self.x = 0
            self.y = 0
        }
        
        @_transparent
        public init(luminance: Float, x: Float, y: Float) {
            self.luminance = luminance
            self.x = x
            self.y = y
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return luminance
                case 1: return x
                case 2: return y
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: luminance = newValue
                case 1: x = newValue
                case 2: y = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension YxyColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return Swift.min(luminance, x, y)
    }
    
    @_transparent
    public func max() -> Float {
        return Swift.max(luminance, x, y)
    }
    
    @_transparent
    public func map(_ transform: (Float) throws -> Float) rethrows -> YxyColorModel.FloatComponents {
        return try YxyColorModel.FloatComponents(luminance: transform(luminance), x: transform(x), y: transform(y))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, luminance)
        try updateAccumulatingResult(&accumulator, x)
        try updateAccumulatingResult(&accumulator, y)
        return accumulator
    }
    
    @_transparent
    public func blended(source: YxyColorModel.FloatComponents, blending: (Float, Float) throws -> Float) rethrows -> YxyColorModel.FloatComponents {
        return try YxyColorModel.FloatComponents(luminance: blending(self.luminance, source.luminance), x: blending(self.x, source.x), y: blending(self.y, source.y))
    }
}

@_transparent
public func * (lhs: YxyColorModel, rhs: Matrix) -> YxyColorModel {
    return YxyColorModel(luminance: lhs.luminance * rhs.a + lhs.x * rhs.b + lhs.y * rhs.c + rhs.d, x: lhs.luminance * rhs.e + lhs.x * rhs.f + lhs.y * rhs.g + rhs.h, y: lhs.luminance * rhs.i + lhs.x * rhs.j + lhs.y * rhs.k + rhs.l)
}
@_transparent
public func *= (lhs: inout YxyColorModel, rhs: Matrix) {
    lhs = lhs * rhs
}

@_transparent
public prefix func +(val: YxyColorModel) -> YxyColorModel {
    return val
}
@_transparent
public prefix func -(val: YxyColorModel) -> YxyColorModel {
    return YxyColorModel(luminance: -val.luminance, x: -val.x, y: -val.y)
}
@_transparent
public func +(lhs: YxyColorModel, rhs: YxyColorModel) -> YxyColorModel {
    return YxyColorModel(luminance: lhs.luminance + rhs.luminance, x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
@_transparent
public func -(lhs: YxyColorModel, rhs: YxyColorModel) -> YxyColorModel {
    return YxyColorModel(luminance: lhs.luminance - rhs.luminance, x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@_transparent
public func *(lhs: Double, rhs: YxyColorModel) -> YxyColorModel {
    return YxyColorModel(luminance: lhs * rhs.luminance, x: lhs * rhs.x, y: lhs * rhs.y)
}
@_transparent
public func *(lhs: YxyColorModel, rhs: Double) -> YxyColorModel {
    return YxyColorModel(luminance: lhs.luminance * rhs, x: lhs.x * rhs, y: lhs.y * rhs)
}

@_transparent
public func /(lhs: YxyColorModel, rhs: Double) -> YxyColorModel {
    return YxyColorModel(luminance: lhs.luminance / rhs, x: lhs.x / rhs, y: lhs.y / rhs)
}

@_transparent
public func *= (lhs: inout YxyColorModel, rhs: Double) {
    lhs.luminance *= rhs
    lhs.x *= rhs
    lhs.y *= rhs
}
@_transparent
public func /= (lhs: inout YxyColorModel, rhs: Double) {
    lhs.luminance /= rhs
    lhs.x /= rhs
    lhs.y /= rhs
}
@_transparent
public func += (lhs: inout YxyColorModel, rhs: YxyColorModel) {
    lhs.luminance += rhs.luminance
    lhs.x += rhs.x
    lhs.y += rhs.y
}
@_transparent
public func -= (lhs: inout YxyColorModel, rhs: YxyColorModel) {
    lhs.luminance -= rhs.luminance
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

@_transparent
public prefix func +(val: YxyColorModel.FloatComponents) -> YxyColorModel.FloatComponents {
    return val
}
@_transparent
public prefix func -(val: YxyColorModel.FloatComponents) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: -val.luminance, x: -val.x, y: -val.y)
}
@_transparent
public func +(lhs: YxyColorModel.FloatComponents, rhs: YxyColorModel.FloatComponents) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: lhs.luminance + rhs.luminance, x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
@_transparent
public func -(lhs: YxyColorModel.FloatComponents, rhs: YxyColorModel.FloatComponents) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: lhs.luminance - rhs.luminance, x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@_transparent
public func *(lhs: Float, rhs: YxyColorModel.FloatComponents) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: lhs * rhs.luminance, x: lhs * rhs.x, y: lhs * rhs.y)
}
@_transparent
public func *(lhs: YxyColorModel.FloatComponents, rhs: Float) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: lhs.luminance * rhs, x: lhs.x * rhs, y: lhs.y * rhs)
}

@_transparent
public func /(lhs: YxyColorModel.FloatComponents, rhs: Float) -> YxyColorModel.FloatComponents {
    return YxyColorModel.FloatComponents(luminance: lhs.luminance / rhs, x: lhs.x / rhs, y: lhs.y / rhs)
}

@_transparent
public func *= (lhs: inout YxyColorModel.FloatComponents, rhs: Float) {
    lhs.luminance *= rhs
    lhs.x *= rhs
    lhs.y *= rhs
}
@_transparent
public func /= (lhs: inout YxyColorModel.FloatComponents, rhs: Float) {
    lhs.luminance /= rhs
    lhs.x /= rhs
    lhs.y /= rhs
}
@_transparent
public func += (lhs: inout YxyColorModel.FloatComponents, rhs: YxyColorModel.FloatComponents) {
    lhs.luminance += rhs.luminance
    lhs.x += rhs.x
    lhs.y += rhs.y
}
@_transparent
public func -= (lhs: inout YxyColorModel.FloatComponents, rhs: YxyColorModel.FloatComponents) {
    lhs.luminance -= rhs.luminance
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}
