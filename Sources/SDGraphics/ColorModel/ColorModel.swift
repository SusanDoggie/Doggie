//
//  ColorModel.swift
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

public protocol _ColorModel {
    
}

public protocol ColorModel: _ColorModel, Hashable, Tensor where Scalar == Double {
    
    associatedtype Float32Components: ColorComponents where Float32Components.Model == Self, Float32Components.Scalar == Float
    
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    init<T: ColorComponents>(_ components: T) where T.Model == Self
    
    var float32Components: Float32Components { get set }
}

public protocol ColorComponents: Hashable, Tensor {
    
    associatedtype Model: ColorModel
    
    init(_ model: Model)
    
    var model: Model { get set }
}

extension ColorModel {
    
    @inlinable
    @inline(__always)
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Self.rangeOfComponent(i)
    }
}

extension ColorModel {
    
    @inlinable
    @inline(__always)
    public func normalizedComponent(_ index: Int) -> Double {
        let range = Self.rangeOfComponent(index)
        return (self[index] - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    @inlinable
    @inline(__always)
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        let range = Self.rangeOfComponent(index)
        self[index] = value * (range.upperBound - range.lowerBound) + range.lowerBound
    }
}

extension ColorModel {
    
    @inlinable
    @inline(__always)
    public init<T: ColorComponents>(_ components: T) where T.Model == Self {
        self = components.model
    }
    
    @inlinable
    @inline(__always)
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = newValue.model
        }
    }
}
