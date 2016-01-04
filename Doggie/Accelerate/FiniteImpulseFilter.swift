//
//  FiniteImpulseFilter.swift
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

public func Radix2FiniteImpulseFilter(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    var _kernel = kernel
    
    let t_stride = temp_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    _treal.memory *= _kernel.memory.real
    _timag.memory *= _kernel.memory.imag
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kernel += kernel_stride
        let _tr = _treal.memory
        let _ti = _timag.memory
        let _kr = _kernel.memory.real
        let _ki = _kernel.memory.imag
        _treal.memory = _tr * _kr - _ti * _ki
        _timag.memory = _tr * _ki + _ti * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func Radix2FiniteImpulseFilter(level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    
    var _temp = temp
    var _kernel = kernel
    
    Radix2CooleyTukey(level, signal, signal_stride, _temp, out_stride)
    
    let fft_length = 1 << level
    
    for _ in 0..<fft_length {
        let _treal = _temp.memory.real
        let _timag = _temp.memory.imag
        let _kreal = _kernel.memory.real
        let _kimag = _kernel.memory.imag
        _temp.memory.real = _treal * _kreal - _timag * _kimag
        _temp.memory.imag = _treal * _kimag + _timag * _kreal
        _temp += temp_stride
        _kernel += kernel_stride
    }
    
    InverseRadix2CooleyTukey(level, temp, temp_stride, output, out_stride)
}

public func DispatchRadix2FiniteImpulseFilter(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    var _kernel = kernel
    
    let t_stride = temp_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    _treal.memory *= _kernel.memory.real
    _timag.memory *= _kernel.memory.imag
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kernel += kernel_stride
        let _tr = _treal.memory
        let _ti = _timag.memory
        let _kr = _kernel.memory.real
        let _ki = _kernel.memory.imag
        _treal.memory = _tr * _kr - _ti * _ki
        _timag.memory = _tr * _ki + _ti * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func DispatchRadix2FiniteImpulseFilter(level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    
    var _temp = temp
    var _kernel = kernel
    
    DispatchRadix2CooleyTukey(level, signal, signal_stride, _temp, out_stride)
    
    let fft_length = 1 << level
    
    for _ in 0..<fft_length {
        let _treal = _temp.memory.real
        let _timag = _temp.memory.imag
        let _kreal = _kernel.memory.real
        let _kimag = _kernel.memory.imag
        _temp.memory.real = _treal * _kreal - _timag * _kimag
        _temp.memory.imag = _treal * _kimag + _timag * _kreal
        _temp += temp_stride
        _kernel += kernel_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, temp, temp_stride, output, out_stride)
}
