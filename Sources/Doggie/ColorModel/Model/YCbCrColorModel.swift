//
//  YCbCrColorModel.swift
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
public struct YCbCrColorModel : ColorModelProtocol {
    
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
    
    public var y: Double
    public var cb: Double
    public var cr: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.y = 0
        self.cb = 0
        self.cr = 0
    }
    
    @inlinable
    @inline(__always)
    public init(y: Double, cb: Double, cr: Double) {
        self.y = y
        self.cb = cb
        self.cr = cr
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

extension YCbCrColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> YCbCrColorModel {
        return YCbCrColorModel(y: transform(y), cb: transform(cb), cr: transform(cr))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, cb)
        updateAccumulatingResult(&accumulator, cr)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: YCbCrColorModel, _ transform: (Double, Double) -> Double) -> YCbCrColorModel {
        return YCbCrColorModel(y: transform(self.y, other.y), cb: transform(self.cb, other.cb), cr: transform(self.cr, other.cr))
    }
}

extension YCbCrColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @frozen
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var y: Scalar
        public var cb: Scalar
        public var cr: Scalar
        
        @inline(__always)
        public init() {
            self.y = 0
            self.cb = 0
            self.cr = 0
        }
        
        @inline(__always)
        public init(y: Scalar, cb: Scalar, cr: Scalar) {
            self.y = y
            self.cb = cb
            self.cr = cr
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: YCbCrColorModel) {
            self.y = Scalar(color.y)
            self.cb = Scalar(color.cb)
            self.cr = Scalar(color.cr)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(_ components: FloatComponents<T>) {
            self.y = Scalar(components.y)
            self.cb = Scalar(components.cb)
            self.cr = Scalar(components.cr)
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
        public var model: YCbCrColorModel {
            get {
                return YCbCrColorModel(y: Double(y), cb: Double(cb), cr: Double(cr))
            }
            set {
                self = FloatComponents(newValue)
            }
        }
    }
}

extension YCbCrColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> YCbCrColorModel.FloatComponents<Scalar> {
        return YCbCrColorModel.FloatComponents(y: transform(y), cb: transform(cb), cr: transform(cr))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, y)
        updateAccumulatingResult(&accumulator, cb)
        updateAccumulatingResult(&accumulator, cr)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: YCbCrColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> YCbCrColorModel.FloatComponents<Scalar> {
        return YCbCrColorModel.FloatComponents(y: transform(self.y, other.y), cb: transform(self.cb, other.cb), cr: transform(self.cr, other.cr))
    }
}
