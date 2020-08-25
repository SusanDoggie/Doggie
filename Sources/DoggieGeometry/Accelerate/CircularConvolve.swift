//
//  CircularConvolve.swift
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

@inlinable
public func Radix2CircularConvolveLength<T: FixedWidthInteger>(_ x: T, _ y: T) -> T {
    return (x + y - 2).hibit << 1
}

@inlinable
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ log2n: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) where T: FloatingMathProtocol {
    
    if _slowPath(signal_count == 0 || kernel_count == 0) {
        let length = 1 << log2n
        var output = output
        for _ in 0..<length {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    let _kreal = temp
    let _kimag = temp + temp_stride
    let k_stride = temp_stride << 1
    
    HalfRadix2CooleyTukey(log2n, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    Radix2FiniteImpulseFilter(log2n, signal, signal_stride, signal_count, _kreal, _kimag, k_stride, output, out_stride)
}

@inlinable
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ log2n: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: Int, _ oreal: UnsafeMutablePointer<T>, _ oimag: UnsafeMutablePointer<T>, _ out_stride: Int, _ treal: UnsafeMutablePointer<T>, _ timag: UnsafeMutablePointer<T>, _ temp_stride: Int) where T: FloatingMathProtocol {
    
    if _slowPath(signal_count == 0 || kernel_count == 0) {
        let length = 1 << log2n
        var oreal = oreal
        var oimag = oimag
        for _ in 0..<length {
            oreal.pointee = 0
            oimag.pointee = 0
            oreal += out_stride
            oimag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(log2n, kreal, kimag, kernel_stride, kernel_count, treal, timag, temp_stride)
    Radix2FiniteImpulseFilter(log2n, sreal, simag, signal_stride, signal_count, treal, timag, temp_stride, oreal, oimag, out_stride)
}

@inlinable
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ log2n: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    let length = 1 << log2n
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
    HalfRadix2CooleyTukey(log2n, input, in_stride, in_count, _treal, _timag, t_stride)
    
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
    
    HalfInverseRadix2CooleyTukey(log2n, output, out_stride)
}

@inlinable
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ n: T, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    let length = 1 << log2n
    
    if _slowPath(in_count == 0) {
        var out_real = out_real
        var out_imag = out_imag
        for _ in 0..<length {
            out_real.pointee = 0
            out_imag.pointee = 0
            out_real += out_stride
            out_imag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(log2n, in_real, in_imag, in_stride, in_count, out_real, out_imag, out_stride)
    
    var _treal = out_real
    var _timag = out_imag
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
    
    InverseRadix2CooleyTukey(log2n, out_real, out_imag, out_stride)
}

@inlinable
public func Radix2FiniteImpulseFilter<T: BinaryFloatingPoint>(_ log2n: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    let length = 1 << log2n
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
    
    HalfRadix2CooleyTukey(log2n, signal, signal_stride, signal_count, _treal, _timag, t_stride)
    
    let m = 1 / T(length)
    _treal.pointee *= m * _kreal.pointee
    _timag.pointee *= m * _kimag.pointee
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        _kreal += kernel_stride
        _kimag += kernel_stride
        let _tr = _treal.pointee
        let _ti = _timag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _treal.pointee = _tr * _kr - _ti * _ki
        _timag.pointee = _tr * _ki + _ti * _kr
    }
    
    HalfInverseRadix2CooleyTukey(log2n, output, out_stride)
}

@inlinable
public func Radix2FiniteImpulseFilter<T: BinaryFloatingPoint>(_ log2n: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ oreal: UnsafeMutablePointer<T>, _ oimag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    let length = 1 << log2n
    
    if _slowPath(signal_count == 0) {
        var oreal = oreal
        var oimag = oimag
        for _ in 0..<length {
            oreal.pointee = 0
            oimag.pointee = 0
            oreal += out_stride
            oimag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(log2n, sreal, simag, signal_stride, signal_count, oreal, oimag, out_stride)
    
    var _oreal = oreal
    var _oimag = oimag
    var _kreal = kreal
    var _kimag = kimag
    
    let m = 1 / T(length)
    for _ in 0..<length {
        let _tr = _oreal.pointee
        let _ti = _oimag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _oreal.pointee = _tr * _kr - _ti * _ki
        _oimag.pointee = _tr * _ki + _ti * _kr
        _oreal += out_stride
        _oimag += out_stride
        _kreal += kernel_stride
        _kimag += kernel_stride
    }
    
    InverseRadix2CooleyTukey(log2n, oreal, oimag, out_stride)
}
