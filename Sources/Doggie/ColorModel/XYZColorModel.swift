//
//  XYZColorModel.swift
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

public struct XYZColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        switch i {
        case 1: return 0...1
        default: return 0...2
        }
    }
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    @_transparent
    public init() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
    
    @_transparent
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    @_transparent
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @_transparent
    public init(luminance: Double, x: Double, y: Double) {
        if y == 0 {
            self.x = 0
            self.y = 0
            self.z = 0
        } else {
            let _y = 1 / y
            self.x = x * _y * luminance
            self.y = luminance
            self.z = (1 - x - y) * _y * luminance
        }
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return x
            case 1: return y
            case 2: return z
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: fatalError()
            }
        }
    }
}

extension XYZColorModel {
    
    @_transparent
    public var luminance: Double {
        get {
            return y
        }
        set {
            self = XYZColorModel(luminance: newValue, point: point)
        }
    }
    
    @_transparent
    public var point: Point {
        get {
            return Point(x: x, y: y) / (x + y + z)
        }
        set {
            self = XYZColorModel(luminance: luminance, point: newValue)
        }
    }
}

extension XYZColorModel {
    
    @_transparent
    public static var black: XYZColorModel {
        return XYZColorModel()
    }
}

extension XYZColorModel {
    
    @_transparent
    public func min() -> Double {
        return Swift.min(x, y, z)
    }
    
    @_transparent
    public func max() -> Double {
        return Swift.max(x, y, z)
    }
    
    @_transparent
    public func map(_ transform: (Double) throws -> Double) rethrows -> XYZColorModel {
        return try XYZColorModel(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, x)
        try updateAccumulatingResult(&accumulator, y)
        try updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
    
    @_transparent
    public func blended(source: XYZColorModel, blending: (Double, Double) throws -> Double) rethrows -> XYZColorModel {
        return try XYZColorModel(x: blending(self.x, source.x), y: blending(self.y, source.y), z: blending(self.z, source.z))
    }
}

extension XYZColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.x = Double(floatComponents.x)
        self.y = Double(floatComponents.y)
        self.z = Double(floatComponents.z)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(x: Float(self.x), y: Float(self.y), z: Float(self.z))
        }
        set {
            self.x = Double(newValue.x)
            self.y = Double(newValue.y)
            self.z = Double(newValue.z)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var x: Float
        public var y: Float
        public var z: Float
        
        @_transparent
        public init() {
            self.x = 0
            self.y = 0
            self.z = 0
        }
        
        @_transparent
        public init(x: Float, y: Float, z: Float) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return x
                case 1: return y
                case 2: return z
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: x = newValue
                case 1: y = newValue
                case 2: z = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension XYZColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return Swift.min(x, y, z)
    }
    
    @_transparent
    public func max() -> Float {
        return Swift.max(x, y, z)
    }
    
    @_transparent
    public func map(_ transform: (Float) throws -> Float) rethrows -> XYZColorModel.FloatComponents {
        return try XYZColorModel.FloatComponents(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, x)
        try updateAccumulatingResult(&accumulator, y)
        try updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
    
    @_transparent
    public func blended(source: XYZColorModel.FloatComponents, blending: (Float, Float) throws -> Float) rethrows -> XYZColorModel.FloatComponents {
        return try XYZColorModel.FloatComponents(x: blending(self.x, source.x), y: blending(self.y, source.y), z: blending(self.z, source.z))
    }
}

@_transparent
public func * (lhs: XYZColorModel, rhs: Matrix) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}
@_transparent
public func *= (lhs: inout XYZColorModel, rhs: Matrix) {
    lhs = lhs * rhs
}

@_transparent
public prefix func +(val: XYZColorModel) -> XYZColorModel {
    return val
}
@_transparent
public prefix func -(val: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: -val.x, y: -val.y, z: -val.z)
}
@_transparent
public func +(lhs: XYZColorModel, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
@_transparent
public func -(lhs: XYZColorModel, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

@_transparent
public func *(lhs: Double, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
@_transparent
public func *(lhs: XYZColorModel, rhs: Double) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

@_transparent
public func /(lhs: XYZColorModel, rhs: Double) -> XYZColorModel {
    return XYZColorModel(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

@_transparent
public func *= (lhs: inout XYZColorModel, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
@_transparent
public func /= (lhs: inout XYZColorModel, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
@_transparent
public func += (lhs: inout XYZColorModel, rhs: XYZColorModel) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
@_transparent
public func -= (lhs: inout XYZColorModel, rhs: XYZColorModel) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}

@_transparent
public prefix func +(val: XYZColorModel.FloatComponents) -> XYZColorModel.FloatComponents {
    return val
}
@_transparent
public prefix func -(val: XYZColorModel.FloatComponents) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: -val.x, y: -val.y, z: -val.z)
}
@_transparent
public func +(lhs: XYZColorModel.FloatComponents, rhs: XYZColorModel.FloatComponents) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
@_transparent
public func -(lhs: XYZColorModel.FloatComponents, rhs: XYZColorModel.FloatComponents) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

@_transparent
public func *(lhs: Float, rhs: XYZColorModel.FloatComponents) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
@_transparent
public func *(lhs: XYZColorModel.FloatComponents, rhs: Float) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

@_transparent
public func /(lhs: XYZColorModel.FloatComponents, rhs: Float) -> XYZColorModel.FloatComponents {
    return XYZColorModel.FloatComponents(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

@_transparent
public func *= (lhs: inout XYZColorModel.FloatComponents, rhs: Float) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
@_transparent
public func /= (lhs: inout XYZColorModel.FloatComponents, rhs: Float) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
@_transparent
public func += (lhs: inout XYZColorModel.FloatComponents, rhs: XYZColorModel.FloatComponents) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
@_transparent
public func -= (lhs: inout XYZColorModel.FloatComponents, rhs: XYZColorModel.FloatComponents) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
