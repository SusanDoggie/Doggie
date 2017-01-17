//
//  DiscreteConvolve.swift
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

public func DiscreteConvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var output = output
    
    let size = signal_count + kernel_count - 1
    var _kp = kernel
    for t in 0..<size {
        var temp: T = 0
        let begin = max(t - kernel_count + 1, 0)
        let end = min(signal_count, t + 1)
        var _sp = signal + begin * signal_stride
        var _kp2 = _kp - begin * kernel_stride
        for _ in begin..<end {
            temp += _sp.pointee * _kp2.pointee
            _sp += signal_stride
            _kp2 -= kernel_stride
        }
        output.pointee = temp
        output += out_stride
        _kp += kernel_stride
    }
}

public func DiscreteConvolve(_ signal_count: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    
    var output = output
    
    let size = signal_count + kernel_count - 1
    var _kp = kernel
    for t in 0..<size {
        var temp = Complex(0)
        let begin = max(t - kernel_count + 1, 0)
        let end = min(signal_count, t + 1)
        var _sp = signal + begin * signal_stride
        var _kp2 = _kp - begin * kernel_stride
        for _ in begin..<end {
            temp += _sp.pointee * _kp2.pointee
            _sp += signal_stride
            _kp2 -= kernel_stride
        }
        output.pointee = temp
        output += out_stride
        _kp += kernel_stride
    }
}
