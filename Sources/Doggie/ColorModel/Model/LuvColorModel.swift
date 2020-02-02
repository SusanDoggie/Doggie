//
//  LuvColorModel.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct LuvColorModel : ColorModelProtocol {
    
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
    /// The u color component.
    public var u: Double
    /// The v color component.
    public var v: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.lightness = 0
        self.u = 0
        self.v = 0
    }
    @inlinable
    @inline(__always)
    public init(lightness: Double, u: Double, v: Double) {
        self.lightness = lightness
        self.u = u
        self.v = v
    }
    @inlinable
    @inline(__always)
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.u = chroma * cos(2 * .pi * hue)
        self.v = chroma * sin(2 * .pi * hue)
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

extension LuvColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: LuvColorModel {
        return LuvColorModel()
    }
}

extension LuvColorModel {
    
    @inlinable
    @inline(__always)
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(v, u) / .pi, 1)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    public var chroma: Double {
        get {
            return hypot(u, v)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

extension LuvColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> LuvColorModel {
        return LuvColorModel(lightness: transform(lightness), u: transform(u), v: transform(v))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, lightness)
        updateAccumulatingResult(&accumulator, u)
        updateAccumulatingResult(&accumulator, v)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: LuvColorModel, _ transform: (Double, Double) -> Double) -> LuvColorModel {
        return LuvColorModel(lightness: transform(self.lightness, other.lightness), u: transform(self.u, other.u), v: transform(self.v, other.v))
    }
}

extension LuvColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var lightness: Scalar
        public var u: Scalar
        public var v: Scalar
        
        @inline(__always)
        public init() {
            self.lightness = 0
            self.u = 0
            self.v = 0
        }
        
        @inline(__always)
        public init(lightness: Scalar, u: Scalar, v: Scalar) {
            self.lightness = lightness
            self.u = u
            self.v = v
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: LuvColorModel) {
            self.lightness = Scalar(color.lightness)
            self.u = Scalar(color.u)
            self.v = Scalar(color.v)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.lightness = Scalar(components.lightness)
            self.u = Scalar(components.u)
            self.v = Scalar(components.v)
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
        
        @inlinable
        @inline(__always)
        public var model: LuvColorModel {
            get {
                return LuvColorModel(lightness: Double(lightness), u: Double(u), v: Double(v))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension LuvColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> LuvColorModel.FloatComponents<Scalar> {
        return LuvColorModel.FloatComponents(lightness: transform(lightness), u: transform(u), v: transform(v))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, lightness)
        updateAccumulatingResult(&accumulator, u)
        updateAccumulatingResult(&accumulator, v)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: LuvColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> LuvColorModel.FloatComponents<Scalar> {
        return LuvColorModel.FloatComponents(lightness: transform(self.lightness, other.lightness), u: transform(self.u, other.u), v: transform(self.v, other.v))
    }
}
