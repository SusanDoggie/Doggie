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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol _ColorModel: PolymorphicHashable {
    
}

public protocol ColorModel: _ColorModel, Hashable, Tensor where Scalar == Double {
    
    associatedtype Float32Components: ColorComponents where Float32Components.Model == Self, Float32Components.Scalar == Float
    
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    init<T: ColorComponents>(_ components: T) where T.Model == Self
    
    var float32Components: Float32Components { get set }
    
    func normalized() -> Self
    
    func denormalized() -> Self
}

#if swift(>=5.3)

@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public protocol _Float16ColorModelProtocol {
    
    associatedtype Float16Components: ColorComponents where Float16Components.Model == Self, Float16Components.Scalar == Float16
    
    var float16Components: Float16Components { get set }
    
}

#endif

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
    public func normalized() -> Self {
        var color = self
        for i in 0..<Self.numberOfComponents {
            let range = Self.rangeOfComponent(i)
            guard range != 0...1 else { continue }
            color[i] = (color[i] - range.lowerBound) / (range.upperBound - range.lowerBound)
        }
        return color
    }
    
    @inlinable
    @inline(__always)
    public func denormalized() -> Self {
        var color = self
        for i in 0..<Self.numberOfComponents {
            let range = Self.rangeOfComponent(i)
            guard range != 0...1 else { continue }
            color[i] = color[i] * (range.upperBound - range.lowerBound) + range.lowerBound
        }
        return color
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

#if swift(>=5.3)

@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension _Float16ColorModelProtocol {
    
    @inlinable
    @inline(__always)
    public var float16Components: Float16Components {
        get {
            return Float16Components(self)
        }
        set {
            self = newValue.model
        }
    }
}

#endif
