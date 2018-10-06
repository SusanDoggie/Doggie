//
//  YCbCrColorModel.swift
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

public struct YCbCrColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var y: Double
    public var cb: Double
    public var cr: Double
    
    @_transparent
    public init() {
        self.y = 0
        self.cb = 0
        self.cr = 0
    }
    
    @_transparent
    public init(y: Double, cb: Double, cr: Double) {
        self.y = y
        self.cb = cb
        self.cr = cr
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return y
            case 1: return cb
            case 2: return cr
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: y = newValue
            case 1: cb = newValue
            case 2: cr = newValue
            default: fatalError()
            }
        }
    }
}

extension YCbCrColorModel {
    
    @_transparent
    public func min() -> Double {
        return Swift.min(y, cb, cr)
    }
    
    @_transparent
    public func max() -> Double {
        return Swift.max(y, cb, cr)
    }
    
    @_transparent
    public func map(_ transform: (Double) -> Double) -> YCbCrColorModel {
        return YCbCrColorModel(y: transform(y), cb: transform(cb), cr: transform(cr))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, cb)
        updateAccumulatingResult(&accumulator, cr)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: YCbCrColorModel, _ transform: (Double, Double) -> Double) -> YCbCrColorModel {
        return YCbCrColorModel(y: transform(self.y, other.y), cb: transform(self.cb, other.cb), cr: transform(self.cr, other.cr))
    }
}

extension YCbCrColorModel {
    
    @_transparent
    public init(floatComponents: FloatComponents) {
        self.y = Double(floatComponents.y)
        self.cb = Double(floatComponents.cb)
        self.cr = Double(floatComponents.cr)
    }
    
    @_transparent
    public var floatComponents: FloatComponents {
        get {
            return FloatComponents(y: Float(self.y), cb: Float(self.cb), cr: Float(self.cr))
        }
        set {
            self.y = Double(newValue.y)
            self.cb = Double(newValue.cb)
            self.cr = Double(newValue.cr)
        }
    }
    
    public struct FloatComponents : FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        public typealias Scalar = Float
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var y: Float
        public var cb: Float
        public var cr: Float
        
        @_transparent
        public init() {
            self.y = 0
            self.cb = 0
            self.cr = 0
        }
        
        @_transparent
        public init(y: Float, cb: Float, cr: Float) {
            self.y = y
            self.cb = cb
            self.cr = cr
        }
        
        @inlinable
        public subscript(position: Int) -> Float {
            get {
                switch position {
                case 0: return y
                case 1: return cb
                case 2: return cr
                default: fatalError()
                }
            }
            set {
                switch position {
                case 0: y = newValue
                case 1: cb = newValue
                case 2: cr = newValue
                default: fatalError()
                }
            }
        }
    }
}

extension YCbCrColorModel.FloatComponents {
    
    @_transparent
    public func min() -> Float {
        return Swift.min(y, cb, cr)
    }
    
    @_transparent
    public func max() -> Float {
        return Swift.max(y, cb, cr)
    }
    
    @_transparent
    public func map(_ transform: (Float) -> Float) -> YCbCrColorModel.FloatComponents {
        return YCbCrColorModel.FloatComponents(y: transform(y), cb: transform(cb), cr: transform(cr))
    }
    
    @_transparent
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Float) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, cb)
        updateAccumulatingResult(&accumulator, cr)
        return accumulator
    }
    
    @_transparent
    public func combined(_ other: YCbCrColorModel.FloatComponents, _ transform: (Float, Float) -> Float) -> YCbCrColorModel.FloatComponents {
        return YCbCrColorModel.FloatComponents(y: transform(self.y, other.y), cb: transform(self.cb, other.cb), cr: transform(self.cr, other.cr))
    }
}
