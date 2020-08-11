//
//  Float16ColorPixel.swift
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

#if swift(>=5.3)

@frozen
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public struct Float16ColorPixel<Model: _Float16ColorModelProtocol>: _FloatComponentPixel {
    
    public typealias Scalar = Float16
    
    public var _color: Model.Float16Components
    
    public var _opacity: Float16
    
    @inlinable
    @inline(__always)
    public init(color: Model, opacity: Double = 1) {
        self._color = Model.Float16Components(color)
        self._opacity = Float16(opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model.Float16Components, opacity: Float16 = 1) {
        self._color = color
        self._opacity = opacity
    }
    
    @inlinable
    @inline(__always)
    public var color: Model {
        get {
            return _color.model
        }
        set {
            self._color.model = newValue
        }
    }
    
    @inlinable
    @inline(__always)
    public var opacity: Double {
        get {
            return Double(_opacity)
        }
        set {
            self._opacity = Scalar(newValue)
        }
    }
    
}

#endif
