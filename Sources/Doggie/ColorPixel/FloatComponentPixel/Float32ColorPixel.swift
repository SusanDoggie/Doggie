//
//  Float32ColorPixel.swift
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
public struct Float32ColorPixel<Model : ColorModelProtocol> : _FloatComponentPixel {
    
    public typealias Scalar = Float
    
    public var _color: Model.Float32Components
    
    public var _opacity: Float
    
    @inlinable
    @inline(__always)
    public init(color: Model, opacity: Double = 1) {
        self._color = Model.Float32Components(color)
        self._opacity = Float(opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model.Float32Components, opacity: Float = 1) {
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
}
