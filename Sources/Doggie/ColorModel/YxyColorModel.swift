//
//  YxyColorModel.swift
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
public struct YxyColorModel : ColorModelProtocol {
    
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
    
    public var luminance: Double
    public var x: Double
    public var y: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.luminance = 0
        self.x = 0
        self.y = 0
    }
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public static var black: YxyColorModel {
        return YxyColorModel()
    }
}

extension YxyColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> YxyColorModel {
        return YxyColorModel(luminance: transform(luminance), x: transform(x), y: transform(y))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, luminance)
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: YxyColorModel, _ transform: (Double, Double) -> Double) -> YxyColorModel {
        return YxyColorModel(luminance: transform(self.luminance, other.luminance), x: transform(self.x, other.x), y: transform(self.y, other.y))
    }
}

extension YxyColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.luminance = Double(floatComponents.luminance)
        self.x = Double(floatComponents.x)
        self.y = Double(floatComponents.y)
    }
    
    @inlinable
    @inline(__always)
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = YxyColorModel(floatComponents: newValue)
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
        
        public var luminance: Scalar
        public var x: Scalar
        public var y: Scalar
        
        @inline(__always)
        public init() {
            self.luminance = 0
            self.x = 0
            self.y = 0
        }
        
        @inline(__always)
        public init(luminance: Scalar, x: Scalar, y: Scalar) {
            self.luminance = luminance
            self.x = x
            self.y = y
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: YxyColorModel) {
            self.luminance = Scalar(color.luminance)
            self.x = Scalar(color.x)
            self.y = Scalar(color.y)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.luminance = Scalar(floatComponents.luminance)
            self.x = Scalar(floatComponents.x)
            self.y = Scalar(floatComponents.y)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> YxyColorModel.FloatComponents<Scalar> {
        return YxyColorModel.FloatComponents(luminance: transform(luminance), x: transform(x), y: transform(y))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, luminance)
        updateAccumulatingResult(&accumulator, x)
        updateAccumulatingResult(&accumulator, y)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: YxyColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> YxyColorModel.FloatComponents<Scalar> {
        return YxyColorModel.FloatComponents(luminance: transform(self.luminance, other.luminance), x: transform(self.x, other.x), y: transform(self.y, other.y))
    }
}
