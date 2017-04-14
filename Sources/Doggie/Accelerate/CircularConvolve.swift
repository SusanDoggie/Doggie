//
//  CircularConvolve.swift
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
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / T(length)
    _kreal.pointee *= m * _sreal.pointee
    _kimag.pointee *= m * _simag.pointee
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _kreal.pointee = _sr * _kr - _si * _ki
        _kimag.pointee = _sr * _ki + _si * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, output, output + out_stride, k_stride, output, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ treal: UnsafeMutablePointer<T>, _ timag: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.pointee = 0
            _imag.pointee = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    Radix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / T(length)
    for _ in 0..<length {
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _sreal.pointee = _sr * _kr - _si * _ki
        _simag.pointee = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _treal = output
    var _timag = output + out_stride
    let t_stride = out_stride << 1
    HalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / T(length)
    _treal.pointee = m * T.pow(_treal.pointee, n)
    _timag.pointee = m * T.pow(_timag.pointee, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.pointee
        let _i = _timag.pointee
        let _pow = m * T.pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * T.atan2(_i, _r)
        _treal.pointee = _pow * T.cos(_arg)
        _timag.pointee = _pow * T.sin(_arg)
    }
    
    HalfInverseRadix2CooleyTukey(level, output, output + out_stride, t_stride, output, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.pointee = 0
            _imag.pointee = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(level, real, imag, in_stride, in_count, _real, _imag, out_stride)
    
    var _treal = _real
    var _timag = _imag
    let m = 1 / T(length)
    for _ in 0..<length {
        let _r = _treal.pointee
        let _i = _timag.pointee
        let _pow = m * T.pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * T.atan2(_i, _r)
        _treal.pointee = _pow * T.cos(_arg)
        _timag.pointee = _pow * T.sin(_arg)
        _treal += out_stride
        _timag += out_stride
    }
    
    InverseRadix2CooleyTukey(level, _real, _imag, out_stride)
}

@_inlineable
public func Radix2CircularConvolve<U: UnsignedInteger>(_ level: Int, _ signal: UnsafePointer<U>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<U>, _ kernel_stride: Int, _ kernel_count: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int, _ temp: UnsafeMutablePointer<U>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _signal = output
    var _kernel = temp
    
    Radix2CooleyTukey(level, signal, signal_stride, signal_count, alpha, mod, _signal, out_stride)
    Radix2CooleyTukey(level, kernel, kernel_stride, kernel_count, alpha, mod, _kernel, temp_stride)
    
    let _n = modinv(U(UIntMax(length)), mod)
    for _ in 0..<length {
        let _s = _signal.pointee
        let _k = mulmod(_kernel.pointee, _n, mod)
        _kernel.pointee = mulmod(_s, _k, mod)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, temp, temp_stride, length, alpha, mod, output, out_stride)
}

@_inlineable
public func Radix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _treal = output
    var _timag = output + out_stride
    var _kernel = kernel
    
    let t_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _treal, _timag, t_stride)
    
    _treal.pointee *= _kernel.pointee.real
    _timag.pointee *= _kernel.pointee.imag
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kernel += kernel_stride
        let _tr = _treal.pointee
        let _ti = _timag.pointee
        let _kr = _kernel.pointee.real
        let _ki = _kernel.pointee.imag
        _treal.pointee = _tr * _kr - _ti * _ki
        _timag.pointee = _tr * _ki + _ti * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, output, output + out_stride, t_stride, output, out_stride)
}

@_inlineable
public func Radix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = Complex(0)
            output += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(level, signal, signal_stride, signal_count, output, out_stride)
    
    var _output = output
    var _kernel = kernel
    
    for _ in 0..<length {
        let _treal = _output.pointee.real
        let _timag = _output.pointee.imag
        let _kreal = _kernel.pointee.real
        let _kimag = _kernel.pointee.imag
        _output.pointee.real = _treal * _kreal - _timag * _kimag
        _output.pointee.imag = _treal * _kimag + _timag * _kreal
        _output += out_stride
        _kernel += kernel_stride
    }
    
    InverseRadix2CooleyTukey(level, output, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func DispatchRadix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchHalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / T(length)
    _kreal.pointee *= m * _sreal.pointee
    _kimag.pointee *= m * _simag.pointee
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _kreal.pointee = _sr * _kr - _si * _ki
        _kimag.pointee = _sr * _ki + _si * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, output, output + out_stride, k_stride, output, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func DispatchRadix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ treal: UnsafeMutablePointer<T>, _ timag: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.pointee = 0
            _imag.pointee = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    DispatchRadix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchRadix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / T(length)
    for _ in 0..<length {
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _sreal.pointee = _sr * _kr - _si * _ki
        _simag.pointee = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func DispatchRadix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _treal = output
    var _timag = output + out_stride
    let t_stride = out_stride << 1
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / T(length)
    _treal.pointee = m * T.pow(_treal.pointee, n)
    _timag.pointee = m * T.pow(_timag.pointee, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.pointee
        let _i = _timag.pointee
        let _pow = m * T.pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * T.atan2(_i, _r)
        _treal.pointee = _pow * T.cos(_arg)
        _timag.pointee = _pow * T.sin(_arg)
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, output, output + out_stride, t_stride, output, out_stride)
}

@_inlineable
@_specialize(Float) @_specialize(Double)
public func DispatchRadix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.pointee = 0
            _imag.pointee = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    DispatchRadix2CooleyTukey(level, real, imag, in_stride, in_count, _real, _imag, out_stride)
    
    var _treal = _real
    var _timag = _imag
    let m = 1 / T(length)
    for _ in 0..<length {
        let _r = _treal.pointee
        let _i = _timag.pointee
        let _pow = m * T.pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * T.atan2(_i, _r)
        _treal.pointee = _pow * T.cos(_arg)
        _timag.pointee = _pow * T.sin(_arg)
        _treal += out_stride
        _timag += out_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, _real, _imag, out_stride)
}

@_inlineable
public func DispatchRadix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _treal = output
    var _timag = output + out_stride
    var _kernel = kernel
    
    let t_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _treal, _timag, t_stride)
    
    _treal.pointee *= _kernel.pointee.real
    _timag.pointee *= _kernel.pointee.imag
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kernel += kernel_stride
        let _tr = _treal.pointee
        let _ti = _timag.pointee
        let _kr = _kernel.pointee.real
        let _ki = _kernel.pointee.imag
        _treal.pointee = _tr * _kr - _ti * _ki
        _timag.pointee = _tr * _ki + _ti * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, output, output + out_stride, t_stride, output, out_stride)
}

@_inlineable
public func DispatchRadix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 {
        var output = output
        for _ in 0..<length {
            output.pointee = Complex(0)
            output += out_stride
        }
        return
    }
    
    DispatchRadix2CooleyTukey(level, signal, signal_stride, signal_count, output, out_stride)
    
    var _output = output
    var _kernel = kernel
    
    for _ in 0..<length {
        let _treal = _output.pointee.real
        let _timag = _output.pointee.imag
        let _kreal = _kernel.pointee.real
        let _kimag = _kernel.pointee.imag
        _output.pointee.real = _treal * _kreal - _timag * _kimag
        _output.pointee.imag = _treal * _kimag + _timag * _kreal
        _output += out_stride
        _kernel += kernel_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, output, out_stride)
}
