//
//  CMYKColorModel.swift
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
public struct CMYKColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
    public static var numberOfComponents: Int {
        return 4
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
    public var black: Double
    
    @inlinable
    @inline(__always)
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
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

extension CMYKColorModel {
    
    @inlinable
    @inline(__always)
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 0
    }
}

extension CMYKColorModel {
    
    @inlinable
    public init(_ gray: GrayColorModel) {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 1 - gray.white
    }
    
    @inlinable
    public init(_ rgb: RGBColorModel) {
        self.init(CMYColorModel(rgb))
    }
    
    @inlinable
    public init(_ cmy: CMYColorModel) {
        self.black = Swift.min(cmy.cyan, cmy.magenta, cmy.yellow)
        if black == 1 {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        } else {
            let _k = 1 / (1 - black)
            self.cyan = _k * (cmy.cyan - black)
            self.magenta = _k * (cmy.magenta - black)
            self.yellow = _k * (cmy.yellow - black)
        }
    }
}

extension CMYKColorModel {
    
    @inlinable
    @inline(__always)
    public static var black: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 0, black: 1)
    }
    
    @inlinable
    @inline(__always)
    public static var white: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 0, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var red: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 1, yellow: 1, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var green: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 0, yellow: 1, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var blue: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 1, yellow: 0, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var cyan: CMYKColorModel {
        return CMYKColorModel(cyan: 1, magenta: 0, yellow: 0, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var magenta: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 1, yellow: 0, black: 0)
    }
    
    @inlinable
    @inline(__always)
    public static var yellow: CMYKColorModel {
        return CMYKColorModel(cyan: 0, magenta: 0, yellow: 1, black: 0)
    }
}

extension CMYKColorModel {
    
    @inlinable
    @inline(__always)
    public func normalized() -> CMYKColorModel {
        return self
    }
    
    @inlinable
    @inline(__always)
    public func denormalized() -> CMYKColorModel {
        return self
    }
}

extension CMYKColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> CMYKColorModel {
        return CMYKColorModel(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow), black: transform(black))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        updateAccumulatingResult(&accumulator, black)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: CMYKColorModel, _ transform: (Double, Double) -> Double) -> CMYKColorModel {
        return CMYKColorModel(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow), black: transform(self.black, other.black))
    }
}

@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension CMYKColorModel: _Float16ColorModelProtocol {
    
    public typealias Float16Components = FloatComponents<Float16>
    
}

extension CMYKColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 4
        }
        
        public var cyan: Scalar
        public var magenta: Scalar
        public var yellow: Scalar
        public var black: Scalar
        
        @inline(__always)
        public init() {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
            self.black = 0
        }
        
        @inline(__always)
        public init(cyan: Scalar, magenta: Scalar, yellow: Scalar, black: Scalar) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
            self.black = black
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: CMYKColorModel) {
            self.cyan = Scalar(color.cyan)
            self.magenta = Scalar(color.magenta)
            self.yellow = Scalar(color.yellow)
            self.black = Scalar(color.black)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.cyan = Scalar(components.cyan)
            self.magenta = Scalar(components.magenta)
            self.yellow = Scalar(components.yellow)
            self.black = Scalar(components.black)
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
        public var model: CMYKColorModel {
            get {
                return CMYKColorModel(cyan: Double(cyan), magenta: Double(magenta), yellow: Double(yellow), black: Double(black))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension CMYKColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> CMYKColorModel.FloatComponents<Scalar> {
        return CMYKColorModel.FloatComponents(cyan: transform(cyan), magenta: transform(magenta), yellow: transform(yellow), black: transform(black))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, cyan)
        updateAccumulatingResult(&accumulator, magenta)
        updateAccumulatingResult(&accumulator, yellow)
        updateAccumulatingResult(&accumulator, black)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: CMYKColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> CMYKColorModel.FloatComponents<Scalar> {
        return CMYKColorModel.FloatComponents(cyan: transform(self.cyan, other.cyan), magenta: transform(self.magenta, other.magenta), yellow: transform(self.yellow, other.yellow), black: transform(self.black, other.black))
    }
}
