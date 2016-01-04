//
//  ComplexConversion.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

import Foundation

//
// MARK: Fast Operations
//
// Swift with optimization Level -Ofast can be much more faster than any Accelerate framework.
// Just do it in simple looping.
//
//

public func ToRect(count: Int, var _ rho: UnsafePointer<Float>, var _ theta: UnsafePointer<Float>, _ in_stride: Int, var _ real: UnsafeMutablePointer<Float>, var _ imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _rho = rho.memory
        let _theta = theta.memory
        real.memory = _rho * cos(_theta)
        imag.memory = _rho * sin(_theta)
        rho += in_stride
        theta += in_stride
        real += out_stride
        imag += out_stride
    }
}
public func ToPolar(count: Int, var _ real: UnsafePointer<Float>, var _ imag: UnsafePointer<Float>, _ in_stride: Int, var _ rho: UnsafeMutablePointer<Float>, var _ theta: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _real = real.memory
        let _imag = imag.memory
        rho.memory = sqrt(_real * _real + _imag * _imag)
        theta.memory = atan2(_imag, _real)
        real += in_stride
        imag += in_stride
        rho += out_stride
        theta += out_stride
    }
}

public func ToRect(count: Int, var _ rho: UnsafePointer<Double>, var _ theta: UnsafePointer<Double>, _ in_stride: Int, var _ real: UnsafeMutablePointer<Double>, var _ imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _rho = rho.memory
        let _theta = theta.memory
        real.memory = _rho * cos(_theta)
        imag.memory = _rho * sin(_theta)
        rho += in_stride
        theta += in_stride
        real += out_stride
        imag += out_stride
    }
}
public func ToPolar(count: Int, var _ real: UnsafePointer<Double>, var _ imag: UnsafePointer<Double>, _ in_stride: Int, var _ rho: UnsafeMutablePointer<Double>, var _ theta: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _real = real.memory
        let _imag = imag.memory
        rho.memory = sqrt(_real * _real + _imag * _imag)
        theta.memory = atan2(_imag, _real)
        real += in_stride
        imag += in_stride
        rho += out_stride
        theta += out_stride
    }
}
