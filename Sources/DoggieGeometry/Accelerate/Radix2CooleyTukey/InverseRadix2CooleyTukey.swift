//
//  InverseRadix2CooleyTukey.swift
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
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
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
    
    switch log2n {
        
    case 0:
        out_real.pointee = in_count == 0 ? 0 : input.pointee
        out_imag.pointee = 0
        
    case 1:
        cooleytukey_inverse_2(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 2:
        cooleytukey_inverse_4(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 3:
        cooleytukey_inverse_8(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 4:
        cooleytukey_inverse_16(input, in_stride, in_count, out_real, out_imag, out_stride)
        
    default:
        let half = length >> 1
        let fourth = length >> 2
        
        
        let _in_count = in_count >> 1
        cooleytukey_inverse(log2n - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), out_real, out_imag, out_stride)
        
        let _out_stride = half * out_stride
        var op_r = out_real
        var op_i = out_imag
        var oph_r = out_real + _out_stride
        var oph_i = out_imag + _out_stride
        var oph2_r = oph_r
        var oph2_i = oph_i
        var opb_r = out_real + length * out_stride
        var opb_i = out_imag + length * out_stride
        
        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = 0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee
        
        let angle = T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
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
            
            let _r1 = 0.5 * (evenreal + _r)
            let _i1 = 0.5 * (_i + evenim)
            let _r2 = 0.5 * (evenreal - _r)
            let _i2 = 0.5 * (_i - evenim)
            
            op_r.pointee = _r1
            op_i.pointee = _i1
            oph_r.pointee = _r2
            oph_i.pointee = _i2
            oph2_r.pointee = _r2
            oph2_i.pointee = -_i2
            opb_r.pointee = _r1
            opb_i.pointee = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

@inlinable
@inline(__always)
func cooleytukey_inverse<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    cooleytukey_forward(log2n, in_imag, in_real, in_stride, (in_count.1, in_count.0), out_imag, out_real, out_stride)
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: FloatingMathProtocol {
    
    Radix2CooleyTukey(log2n, in_imag, in_real, in_stride, in_count, out_imag, out_real, out_stride)
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T: FloatingMathProtocol {
    
    Radix2CooleyTukey(log2n, imag, real, stride)
}
