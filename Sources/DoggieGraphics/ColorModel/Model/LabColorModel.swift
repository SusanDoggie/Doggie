//
//  LabColorModel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct LabColorModel: ColorModel {
    
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
        case 0: return 0...100
        default: return -128...128
        }
    }
    
    /// The lightness dimension.
    public var lightness: Double
    /// The a color component.
    public var a: Double
    /// The b color component.
    public var b: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.lightness = 0
        self.a = 0
        self.b = 0
    }
    
    @inlinable
    @inline(__always)
    public init(lightness: Double, a: Double, b: Double) {
        self.lightness = lightness
        self.a = a
        self.b = b
    }
    @inlinable
    @inline(__always)
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.a = chroma * cos(2 * .pi * hue)
        self.b = chroma * sin(2 * .pi * hue)
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            return withUnsafeTypePunnedPointer(of: self, to: Double.self) { $0[position] }
        }
        set {
            withUnsafeMutableTypePunnedPointer(of: &self, to: Double.self) { $0[position] = newValue }
        }
    }
}

extension LabColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: LabColorModel {
        return LabColorModel()
    }
}

extension LabColorModel {
    
    @inlinable
    @inline(__always)
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(b, a) / .pi, 1)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    public var chroma: Double {
        get {
            return hypot(a, b)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

extension LabColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> LabColorModel {
        return LabColorModel(lightness: transform(lightness), a: transform(a), b: transform(b))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, lightness)
        updateAccumulatingResult(&accumulator, a)
        updateAccumulatingResult(&accumulator, b)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: LabColorModel, _ transform: (Double, Double) -> Double) -> LabColorModel {
        return LabColorModel(lightness: transform(self.lightness, other.lightness), a: transform(self.a, other.a), b: transform(self.b, other.b))
    }
}

@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension LabColorModel: _Float16ColorModelProtocol {
    
    public typealias Float16Components = FloatComponents<Float16>
    
}

extension LabColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var lightness: Scalar
        public var a: Scalar
        public var b: Scalar
        
        @inline(__always)
        public init() {
            self.lightness = 0
            self.a = 0
            self.b = 0
        }
        
        @inline(__always)
        public init(lightness: Scalar, a: Scalar, b: Scalar) {
            self.lightness = lightness
            self.a = a
            self.b = b
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: LabColorModel) {
            self.lightness = Scalar(color.lightness)
            self.a = Scalar(color.a)
            self.b = Scalar(color.b)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.lightness = Scalar(components.lightness)
            self.a = Scalar(components.a)
            self.b = Scalar(components.b)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return withUnsafeTypePunnedPointer(of: self, to: Scalar.self) { $0[position] }
            }
            set {
                withUnsafeMutableTypePunnedPointer(of: &self, to: Scalar.self) { $0[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: LabColorModel {
            get {
                return LabColorModel(lightness: Double(lightness), a: Double(a), b: Double(b))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension LabColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> LabColorModel.FloatComponents<Scalar> {
        return LabColorModel.FloatComponents(lightness: transform(lightness), a: transform(a), b: transform(b))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, lightness)
        updateAccumulatingResult(&accumulator, a)
        updateAccumulatingResult(&accumulator, b)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: LabColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> LabColorModel.FloatComponents<Scalar> {
        return LabColorModel.FloatComponents(lightness: transform(self.lightness, other.lightness), a: transform(self.a, other.a), b: transform(self.b, other.b))
    }
}
