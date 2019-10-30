//
//  GrayColorModel.swift
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

public struct GrayColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
    public static var numberOfComponents: Int {
        return 1
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var white: Double
    
    @inlinable
    @inline(__always)
    public init(white: Double) {
        self.white = white
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

extension GrayColorModel {
    
    @inlinable
    @inline(__always)
    public init() {
        self.white = 0
    }
}

extension GrayColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: GrayColorModel {
        return GrayColorModel()
    }
    
    @inlinable
    @inline(__always)
    public static var white: GrayColorModel {
        return GrayColorModel(white: 1)
    }
}

extension GrayColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> GrayColorModel {
        return GrayColorModel(white: transform(white))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, white)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: GrayColorModel, _ transform: (Double, Double) -> Double) -> GrayColorModel {
        return GrayColorModel(white: transform(self.white, other.white))
    }
}

extension GrayColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.white = Double(floatComponents.white)
    }
    
    @inlinable
    @inline(__always)
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = GrayColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 1
        }
        
        public var white: Scalar
        
        @inline(__always)
        public init() {
            self.white = 0
        }
        
        @inline(__always)
        public init(white: Scalar) {
            self.white = white
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: GrayColorModel) {
            self.white = Scalar(color.white)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.white = Scalar(floatComponents.white)
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

extension GrayColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> GrayColorModel.FloatComponents<Scalar> {
        return GrayColorModel.FloatComponents(white: transform(white))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, white)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: GrayColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> GrayColorModel.FloatComponents<Scalar> {
        return GrayColorModel.FloatComponents(white: transform(self.white, other.white))
    }
}
