//
//  CMYColorModel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
public struct CMYColorModel: ColorModel {
    
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
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    
    @inlinable
    @inline(__always)
    public init(cyan: Double, magenta: Double, yellow: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
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

extension CMYColorModel {
    
    @inlinable
    @inline(__always)
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
    }
}

extension CMYColorModel {
    
    @inlinable
    public init(_ gray: GrayColorModel) {
        self.cyan = 1 - gray.white
        self.magenta = 1 - gray.white
        self.yellow = 1 - gray.white
    }
    
    @inlinable
    public init(_ rgb: RGBColorModel) {
        self.cyan = 1 - rgb.red
        self.magenta = 1 - rgb.green
        self.yellow = 1 - rgb.blue
    }
    
    @inlinable
    public init(_ cmyk: CMYKColorModel) {
        let _k = 1 - cmyk.black
        self.cyan = cmyk.cyan * _k + cmyk.black
        self.magenta = cmyk.magenta * _k + cmyk.black
        self.yellow = cmyk.yellow * _k + cmyk.black
    }
}

extension CMYColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 1, yellow: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var white: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 0, yellow: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var red: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 1, yellow: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var green: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 0, yellow: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var blue: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 1, yellow: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var cyan: CMYColorModel {
        return CMYColorModel(cyan: 1, magenta: 0, yellow: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var magenta: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 1, yellow: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var yellow: CMYColorModel {
        return CMYColorModel(cyan: 0, magenta: 0, yellow: 1)
    }
}

extension CMYColorModel {
    
    @inlinable
    @inline(__always)
    public func normalized() -> CMYColorModel {
        return self
    }
    
    @inlinable
    @inline(__always)
    public func denormalized() -> CMYColorModel {
        return self
    }
}

extension CMYColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> CMYColorModel {
        return CMYColorModel(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: CMYColorModel, _ transform: (Double, Double) -> Double) -> CMYColorModel {
        return CMYColorModel(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow))
    }
}

extension CMYColorModel {
    
    public typealias Float16Components = FloatComponents<float16>
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var cyan: Scalar
        public var magenta: Scalar
        public var yellow: Scalar
        
        @inline(__always)
        public init() {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        }
        
        @inline(__always)
        public init(cyan: Scalar, magenta: Scalar, yellow: Scalar) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: CMYColorModel) {
            self.cyan = Scalar(color.cyan)
            self.magenta = Scalar(color.magenta)
            self.yellow = Scalar(color.yellow)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.cyan = Scalar(components.cyan)
            self.magenta = Scalar(components.magenta)
            self.yellow = Scalar(components.yellow)
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
        public var model: CMYColorModel {
            get {
                return CMYColorModel(cyan: Double(cyan), magenta: Double(magenta), yellow: Double(yellow))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension CMYColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> CMYColorModel.FloatComponents<Scalar> {
        return CMYColorModel.FloatComponents(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: CMYColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> CMYColorModel.FloatComponents<Scalar> {
        return CMYColorModel.FloatComponents(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow))
    }
}
