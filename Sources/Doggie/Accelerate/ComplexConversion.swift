//
//  ComplexConversion.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

@_inlineable
@_specialize(Float) @_specialize(Double)
public func ToRect<T: FloatingMathProtocol>(_ count: Int, _ rho: UnsafePointer<T>, _ theta: UnsafePointer<T>, _ in_stride: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var rho = rho
    var theta = theta
    var real = real
    var imag = imag
    
    for _ in 0..<count {
        let _rho = rho.pointee
        let _theta = theta.pointee
        real.pointee = _rho * T.cos(_theta)
        imag.pointee = _rho * T.sin(_theta)
        rho += in_stride
        theta += in_stride
        real += out_stride
        imag += out_stride
    }
}
@_inlineable
@_specialize(Float) @_specialize(Double)
public func ToPolar<T: FloatingMathProtocol>(_ count: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ rho: UnsafeMutablePointer<T>, _ theta: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var rho = rho
    var theta = theta
    
    for _ in 0..<count {
        let _real = real.pointee
        let _imag = imag.pointee
        rho.pointee = T.sqrt(_real * _real + _imag * _imag)
        theta.pointee = T.atan2(_imag, _real)
        real += in_stride
        imag += in_stride
        rho += out_stride
        theta += out_stride
    }
}
