//
//  Transpose.swift
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

public func Transpose<T>(row: Int, _ column: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var output = output
    
    let _in_stride = in_stride * column
    let _out_stride = out_stride * column
    for _ in 0..<row {
        Move(column, input, _in_stride, output, out_stride)
        input += in_stride
        output += _out_stride
    }
}

public func Transpose(row: Int, _ column: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let _in_stride = in_stride * column
    let _out_stride = out_stride * column
    for _ in 0..<row {
        Move(column, real, imag, _in_stride, _real, _imag, out_stride)
        real += in_stride
        imag += in_stride
        _real += _out_stride
        _imag += _out_stride
    }
}

public func Transpose(row: Int, _ column: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let _in_stride = in_stride * column
    let _out_stride = out_stride * column
    for _ in 0..<row {
        Move(column, real, imag, _in_stride, _real, _imag, out_stride)
        real += in_stride
        imag += in_stride
        _real += _out_stride
        _imag += _out_stride
    }
}
