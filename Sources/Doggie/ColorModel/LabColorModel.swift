//
//  LabColorModel.swift
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

public struct LabColorModel : ColorModelProtocol {
    
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
    
    @_transparent
    public init() {
        self.lightness = 0
        self.a = 0
        self.b = 0
    }
    
    @_transparent
    public init(lightness: Double, a: Double, b: Double) {
        self.lightness = lightness
        self.a = a
        self.b = b
    }
    @_transparent
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.a = chroma * cos(2 * Double.pi * hue)
        self.b = chroma * sin(2 * Double.pi * hue)
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return lightness
            case 1: return a
            case 2: return b
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: lightness = newValue
            case 1: a = newValue
            case 2: b = newValue
            default: fatalError()
            }
        }
    }
}

extension LabColorModel {
    
    @_transparent
    public static var black: LabColorModel {
        return LabColorModel()
    }
}

extension LabColorModel {
    
    @_transparent
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(b, a) / Double.pi, 1)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @_transparent
    public var chroma: Double {
        get {
            return sqrt(a * a + b * b)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

extension LabColorModel {
    
    @_transparent
    public func min() -> Double {
        return Swift.min(lightness, a, b)
    }
    
    @_transparent
    public func max() -> Double {
        return Swift.max(lightness, a, b)
    }
    
    @_transparent
    public func map(_ transform: (Double) throws -> Double) rethrows -> LabColorModel {
        return try LabColorModel(lightness: transform(lightness), a: transform(a), b: transform(b))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, lightness)
        try updateAccumulatingResult(&accumulator, a)
        try updateAccumulatingResult(&accumulator, b)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: LabColorModel, _ transform: (Double, Double) throws -> Double) rethrows -> LabColorModel {
        return try LabColorModel(lightness: transform(self.lightness, other.lightness), a: transform(self.a, other.a), b: transform(self.b, other.b))
    }
}

extension LabColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.lightness = Double(floatComponents.lightness)
        self.a = Double(floatComponents.a)
        self.b = Double(floatComponents.b)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(lightness: Float(self.lightness), a: Float(self.a), b: Float(self.b))
        }
        set {
            self.lightness = Double(newValue.lightness)
            self.a = Double(newValue.a)
            self.b = Double(newValue.b)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var lightness: Float
        public var a: Float
        public var b: Float
        
        @_transparent
        public init() {
            self.lightness = 0
            self.a = 0
            self.b = 0
        }
        
        @_transparent
        public init(lightness: Float, a: Float, b: Float) {
            self.lightness = lightness
            self.a = a
            self.b = b
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return lightness
                case 1: return a
                case 2: return b
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: lightness = newValue
                case 1: a = newValue
                case 2: b = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension LabColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return Swift.min(lightness, a, b)
    }
    
    @_transparent
    public func max() -> Float {
        return Swift.max(lightness, a, b)
    }
    
    @_transparent
    public func map(_ transform: (Float) throws -> Float) rethrows -> LabColorModel.FloatComponents {
        return try LabColorModel.FloatComponents(lightness: transform(lightness), a: transform(a), b: transform(b))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, lightness)
        try updateAccumulatingResult(&accumulator, a)
        try updateAccumulatingResult(&accumulator, b)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: LabColorModel.FloatComponents, _ transform: (Float, Float) throws -> Float) rethrows -> LabColorModel.FloatComponents {
        return try LabColorModel.FloatComponents(lightness: transform(self.lightness, other.lightness), a: transform(self.a, other.a), b: transform(self.b, other.b))
    }
}
