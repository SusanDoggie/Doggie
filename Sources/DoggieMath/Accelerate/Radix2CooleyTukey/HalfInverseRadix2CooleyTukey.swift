//
//  HalfInverseRadix2CooleyTukey.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
public func HalfInverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T: ElementaryFunctions {
    
    switch log2n {
        
    case 0:
        output.pointee = in_real.pointee
        
    case 1:
        half_cooleytukey_inverse_2(in_real, in_imag, 1, output, out_stride)
    case 2:
        half_cooleytukey_inverse_4(in_real, in_imag, in_stride, 2, output, out_stride)
    case 3:
        half_cooleytukey_inverse_8(in_real, in_imag, in_stride, 4, output, out_stride)
    case 4:
        half_cooleytukey_inverse_16(in_real, in_imag, in_stride, 8, output, out_stride)
        
    default:
        let length = 1 << log2n
        let half = length >> 1
        let fourth = length >> 2
        
        let tp_stride = out_stride << 1
        
        var ip_r = in_real
        var ip_i = in_imag
        var iph_r = in_real + half * in_stride
        var iph_i = in_imag + half * in_stride
        var tp_r = output
        var tp_i = output + out_stride
        var tph_r = tp_r + half * tp_stride
        var tph_i = tp_i + half * tp_stride
        
        let tr = ip_r.pointee
        let ti = ip_i.pointee
        tp_r.pointee = tr + ti
        tp_i.pointee = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.pointee = ipf_r.pointee * 2.0
        tpf_i.pointee = -ipf_i.pointee * 2.0
        
        let angle = -T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride
            
            let ir = ip_r.pointee
            let ii = ip_i.pointee
            let ihr = iph_r.pointee
            let ihi = iph_i.pointee
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.pointee = evenreal - _r
            tp_i.pointee = _i + evenim
            tph_r.pointee = evenreal + _r
            tph_i.pointee = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        InverseRadix2CooleyTukey(log2n - 1, output, output + out_stride, tp_stride)
    }
}
@inlinable
@inline(__always)
public func HalfInverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ buffer: UnsafeMutablePointer<T>, _ stride: Int) where T: ElementaryFunctions {
    HalfInverseRadix2CooleyTukey(log2n, buffer, buffer + stride, stride << 1, buffer, stride)
}
