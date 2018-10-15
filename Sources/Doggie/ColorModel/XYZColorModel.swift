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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public init() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
    
    @inlinable
    @inline(__always)
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    public init(_ Yxy: YxyColorModel) {
        self.init(luminance: Yxy.luminance, x: Yxy.x, y: Yxy.y)
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
    
    @inlinable
    @inline(__always)
    public func min() -> Double {
        return Swift.min(x, y, z)
    }
    
    @inlinable
    @inline(__always)
    public func max() -> Double {
        return Swift.max(x, y, z)
    }
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> XYZColorModel {
        return XYZColorModel(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: XYZColorModel, _ transform: (Double, Double) -> Double) -> XYZColorModel {
        return XYZColorModel(x: transform(self.x, other.x), y: transform(self.y, other.y), z: transform(self.z, other.z))
    }
}

extension XYZColorModel {
    
    @inlinable
    @inline(__always)
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
        
        @inline(__always)
        public init() {
            self.x = 0
            self.y = 0
            self.z = 0
        }
        
        @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public func min() -> Float {
        return Swift.min(x, y, z)
    }
    
    @inlinable
    @inline(__always)
    public func max() -> Float {
        return Swift.max(x, y, z)
    }
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Float) -> Float) -> XYZColorModel.FloatComponents {
        return XYZColorModel.FloatComponents(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: XYZColorModel.FloatComponents, _ transform: (Float, Float) -> Float) -> XYZColorModel.FloatComponents {
        return XYZColorModel.FloatComponents(x: transform(self.x, other.x), y: transform(self.y, other.y), z: transform(self.z, other.z))
    }
}

@inlinable
@inline(__always)
public func * (lhs: XYZColorModel, rhs: Matrix) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}
@inlinable
@inline(__always)
public func *= (lhs: inout XYZColorModel, rhs: Matrix) {
    lhs = lhs * rhs
}
