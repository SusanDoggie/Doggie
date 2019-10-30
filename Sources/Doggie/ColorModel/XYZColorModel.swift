//
//  XYZColorModel.swift
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
public struct XYZColorModel : ColorModelProtocol {
    
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
        }
    }
}

extension XYZColorModel {
    
    @inlinable
    @inline(__always)
    public init(_ Yxy: YxyColorModel) {
        self.init(luminance: Yxy.luminance, x: Yxy.x, y: Yxy.y)
    }
}

extension XYZColorModel {
    
    @inlinable
    @inline(__always)
    public var luminance: Double {
        get {
            return y
        }
        set {
            self = XYZColorModel(luminance: newValue, point: point)
        }
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public static var black: XYZColorModel {
        return XYZColorModel()
    }
}

extension XYZColorModel {
    
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
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.x = Double(floatComponents.x)
        self.y = Double(floatComponents.y)
        self.z = Double(floatComponents.z)
    }
    
    @inlinable
    @inline(__always)
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = XYZColorModel(floatComponents: newValue)
        }
    }
    
    @frozen
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var x: Scalar
        public var y: Scalar
        public var z: Scalar
        
        @inline(__always)
        public init() {
            self.x = 0
            self.y = 0
            self.z = 0
        }
        
        @inline(__always)
        public init(x: Scalar, y: Scalar, z: Scalar) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: XYZColorModel) {
            self.x = Scalar(color.x)
            self.y = Scalar(color.y)
            self.z = Scalar(color.z)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.x = Scalar(floatComponents.x)
            self.y = Scalar(floatComponents.y)
            self.z = Scalar(floatComponents.z)
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
    }
}

extension XYZColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> XYZColorModel.FloatComponents<Scalar> {
        return XYZColorModel.FloatComponents(x: transform(x), y: transform(y), z: transform(z))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, z)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: XYZColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> XYZColorModel.FloatComponents<Scalar> {
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
