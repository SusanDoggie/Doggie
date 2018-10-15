//
//  CircularConvolve.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

@inlinable
@inline(__always)
public func Radix2CircularConvolveLength<T: FixedWidthInteger>(_ x: T, _ y: T) -> T {
    return (x + y - 2).hibit << 1
}

@inlinable
@inline(__always)
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if _slowPath(signal_count == 0 || kernel_count == 0) {
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

@inlinable
@inline(__always)
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ treal: UnsafeMutablePointer<T>, _ timag: UnsafeMutablePointer<T>, _ temp_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if _slowPath(signal_count == 0 || kernel_count == 0) {
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

@inlinable
@inline(__always)
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if _slowPath(in_count == 0) {
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

@inlinable
@inline(__always)
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if _slowPath(in_count == 0) {
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

@inlinable
@inline(__always)
public func Radix2FiniteImpulseFilter<T: BinaryFloatingPoint>(_ level: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    
    if _slowPath(signal_count == 0) {
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    var _treal = output
    var _timag = output + out_stride
    var _kreal = kreal
    var _kimag = kimag
    
    let t_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _treal, _timag, t_stride)
    
    _treal.pointee *= _kreal.pointee
    _timag.pointee *= _kimag.pointee
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kreal += kernel_stride
        _kimag += kernel_stride
        let _tr = _treal.pointee
        let _ti = _timag.pointee
        let _kr = _kreal.pointee
        let _ki = _kimag.pointee
        _treal.pointee = _tr * _kr - _ti * _ki
        _timag.pointee = _tr * _ki + _ti * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, output, output + out_stride, t_stride, output, out_stride)
}

@inlinable
@inline(__always)
public func Radix2FiniteImpulseFilter<T: BinaryFloatingPoint>(_ level: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    
    if _slowPath(signal_count == 0) {
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
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _real, _imag, out_stride)
    
    var _oreal = _real
    var _oimag = _imag
    var _kreal = kreal
    var _kimag = kimag
    
    for _ in 0..<length {
        let _tr = _oreal.pointee
        let _ti = _oimag.pointee
        let _kr = _kreal.pointee
        let _ki = _kimag.pointee
        _oreal.pointee = _tr * _kr - _ti * _ki
        _oimag.pointee = _tr * _ki + _ti * _kr
        _oreal += out_stride
        _oimag += out_stride
        _kreal += kernel_stride
        _kimag += kernel_stride
    }
    
    InverseRadix2CooleyTukey(level, _real, _imag, out_stride)
}
