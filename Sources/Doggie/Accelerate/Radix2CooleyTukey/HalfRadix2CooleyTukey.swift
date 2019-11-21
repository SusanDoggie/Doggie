//
//  HalfRadix2CooleyTukey.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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
func _HalfRadix2CooleyTukeyTwiddling<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {
    
    let length = 1 << level
    let half = length >> 1
    let fourth = length >> 2
    
    let _stride = half * stride
    var op_r = real
    var op_i = imag
    var oph_r = real + _stride
    var oph_i = imag + _stride
    
    let tr = op_r.pointee
    let ti = op_i.pointee
    op_r.pointee = tr + ti
    op_i.pointee = tr - ti
    
    let opf_i = imag + fourth * stride
    opf_i.pointee = -opf_i.pointee
    
    let angle = -T.pi / T(half)
    let _cos = T.cos(angle)
    let _sin = T.sin(angle)
    var _cos1 = _cos
    var _sin1 = _sin
    for _ in 1..<fourth {
        
        op_r += stride
        op_i += stride
        oph_r -= stride
        oph_i -= stride
        
        let or = op_r.pointee
        let oi = op_i.pointee
        let ohr = oph_r.pointee
        let ohi = oph_i.pointee
        
        let evenreal = or + ohr
        let evenim = oi - ohi
        let oddreal = oi + ohi
        let oddim = ohr - or
        
        let _r = oddreal * _cos1 - oddim * _sin1
        let _i = oddreal * _sin1 + oddim * _cos1
        
        op_r.pointee = 0.5 * (evenreal + _r)
        op_i.pointee = 0.5 * (_i + evenim)
        oph_r.pointee = 0.5 * (evenreal - _r)
        oph_i.pointee = 0.5 * (_i - evenim)
        
        let _c1 = _cos * _cos1 - _sin * _sin1
        let _s1 = _cos * _sin1 + _sin * _cos1
        _cos1 = _c1
        _sin1 = _s1
    }
}

@inlinable
@inline(__always)
public func HalfRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {
    
    switch level {
        
    case 0:
        out_real.pointee = in_count == 0 ? 0 : input.pointee
        out_imag.pointee = 0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, out_real, out_imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 3:
        HalfRadix2CooleyTukey_8(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 4:
        HalfRadix2CooleyTukey_16(input, in_stride, in_count, out_real, out_imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if _slowPath(in_count == 0) {
            var out_real = out_real
            var out_imag = out_imag
            for _ in 0..<half {
                out_real.pointee = 0
                out_imag.pointee = 0
                out_real += out_stride
                out_imag += out_stride
            }
            return
        }
        
        let _in_count = in_count >> 1
        _Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), out_real, out_imag, out_stride)
        _HalfRadix2CooleyTukeyTwiddling(level, out_real, out_imag, out_stride)
    }
}
@inlinable
@inline(__always)
public func HalfRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ buffer: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {
    
    switch level {
        
    case 0: break
        
    case 1:
        HalfRadix2CooleyTukey_2(buffer, stride, 1, buffer, buffer + stride)
    case 2:
        HalfRadix2CooleyTukey_4(buffer, stride, 2, buffer, buffer + stride, stride << 1)
    case 3:
        HalfRadix2CooleyTukey_8(buffer, stride, 4, buffer, buffer + stride, stride << 1)
    case 4:
        HalfRadix2CooleyTukey_16(buffer, stride, 8, buffer, buffer + stride, stride << 1)
        
    default:
        Radix2CooleyTukey(level - 1, buffer, buffer + stride, stride << 1)
        _HalfRadix2CooleyTukeyTwiddling(level, buffer, buffer + stride, stride << 1)
    }
}
