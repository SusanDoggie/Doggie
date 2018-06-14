//
//  GrayColorModel.swift
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

public struct GrayColorModel : ColorModelProtocol {

    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 1
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var white: Double
    
    @_transparent
    public init(white: Double) {
        self.white = white
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return white
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: white = newValue
            default: fatalError()
            }
        }
    }
}

extension GrayColorModel {
    
    @_transparent
    public init() {
        self.white = 0
    }
}

extension GrayColorModel {
    
    @_transparent
    public static var black: GrayColorModel {
        return GrayColorModel()
    }
    
    @_transparent
    public static var white: GrayColorModel {
        return GrayColorModel(white: 1)
    }
}

extension GrayColorModel {
    
    @_transparent
    public func min() -> Double {
        return white
    }
    
    @_transparent
    public func max() -> Double {
        return white
    }
    
    @_transparent
    public func map(_ transform: (Double) throws -> Double) rethrows -> GrayColorModel {
        return try GrayColorModel(white: transform(white))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, white)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: GrayColorModel, _ transform: (Double, Double) throws -> Double) rethrows -> GrayColorModel {
        return try GrayColorModel(white: transform(self.white, other.white))
    }
}

extension GrayColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.white = Double(floatComponents.white)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(white: Float(self.white))
        }
        set {
            self.white = Double(newValue.white)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        public var white: Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 1
        }
        
        @_transparent
        public init() {
            self.white = 0
        }
        
        @_transparent
        public init(white: Float) {
            self.white = white
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return white
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: white = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension GrayColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return white
    }
    
    @_transparent
    public func max() -> Float {
        return white
    }
    
    @_transparent
    public func map(_ transform: (Float) throws -> Float) rethrows -> GrayColorModel.FloatComponents {
        return try GrayColorModel.FloatComponents(white: transform(white))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) throws -> ()) rethrows -> Result {
        var accumulator = initialResult
        try updateAccumulatingResult(&accumulator, white)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: GrayColorModel.FloatComponents, _ transform: (Float, Float) throws -> Float) rethrows -> GrayColorModel.FloatComponents {
        return try GrayColorModel.FloatComponents(white: transform(self.white, other.white))
    }
}
