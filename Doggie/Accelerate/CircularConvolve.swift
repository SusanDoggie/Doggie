//
//  CircularConvolve.swift
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

public func Radix2CircularConvolve(level: Int, _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey(level, kernel, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Float(fft_length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func Radix2CircularConvolve(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey(level, kernel, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Double(fft_length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func Radix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Float>, _ simag: UnsafePointer<Float>, _ signal_stride: Int, _ kreal: UnsafePointer<Float>, _ kimag: UnsafePointer<Float>, _ kernel_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, _sreal, _simag, s_stride)
    Radix2CooleyTukey(level, kreal, kimag, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    
    let m = 1 / Float(fft_length)
    for _ in 0..<fft_length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func Radix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Double>, _ simag: UnsafePointer<Double>, _ signal_stride: Int, _ kreal: UnsafePointer<Double>, _ kimag: UnsafePointer<Double>, _ kernel_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, _sreal, _simag, s_stride)
    Radix2CooleyTukey(level, kreal, kimag, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    
    let m = 1 / Double(fft_length)
    for _ in 0..<fft_length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, _sreal, _simag, s_stride)
    DispatchHalfRadix2CooleyTukey(level, kernel, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Float(fft_length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, _sreal, _simag, s_stride)
    DispatchHalfRadix2CooleyTukey(level, kernel, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Double(fft_length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Float>, _ simag: UnsafePointer<Float>, _ signal_stride: Int, _ kreal: UnsafePointer<Float>, _ kimag: UnsafePointer<Float>, _ kernel_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    DispatchRadix2CooleyTukey(level, sreal, simag, signal_stride, _sreal, _simag, s_stride)
    DispatchRadix2CooleyTukey(level, kreal, kimag, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    
    let m = 1 / Float(fft_length)
    for _ in 0..<fft_length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Double>, _ simag: UnsafePointer<Double>, _ signal_stride: Int, _ kreal: UnsafePointer<Double>, _ kimag: UnsafePointer<Double>, _ kernel_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    DispatchRadix2CooleyTukey(level, sreal, simag, signal_stride, _sreal, _simag, s_stride)
    DispatchRadix2CooleyTukey(level, kreal, kimag, kernel_stride, _kreal, _kimag, k_stride)
    
    let fft_length = 1 << level
    
    let m = 1 / Double(fft_length)
    for _ in 0..<fft_length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ n: Float, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    HalfRadix2CooleyTukey(level, input, in_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Float(fft_length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ n: Double, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    HalfRadix2CooleyTukey(level, input, in_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Double(fft_length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ n: Float, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    Radix2CooleyTukey(level, real, imag, in_stride, treal, timag, temp_stride)
    
    let fft_length = 1 << level
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Float(fft_length)
    for _ in 0..<fft_length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ n: Double, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    Radix2CooleyTukey(level, real, imag, in_stride, treal, timag, temp_stride)
    
    let fft_length = 1 << level
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Double(fft_length)
    for _ in 0..<fft_length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ n: Float, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Float(fft_length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ n: Double, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, _treal, _timag, t_stride)
    
    let fft_length = 1 << level
    let half = fft_length >> 1
    
    let m = 1 / Double(fft_length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ n: Float, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, real, imag, in_stride, treal, timag, temp_stride)
    
    let fft_length = 1 << level
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Float(fft_length)
    for _ in 0..<fft_length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ n: Double, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, real, imag, in_stride, treal, timag, temp_stride)
    
    let fft_length = 1 << level
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Double(fft_length)
    for _ in 0..<fft_length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, _real, _imag, out_stride)
}
