//
//  Radix2CooleyTukey.swift
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
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: ElementaryFunctions {
    
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
        cooleytukey_forward_2(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 2:
        cooleytukey_forward_4(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 3:
        cooleytukey_forward_8(input, in_stride, in_count, out_real, out_imag, out_stride)
    case 4:
        cooleytukey_forward_16(input, in_stride, in_count, out_real, out_imag, out_stride)
        
    default:
        let half = length >> 1
        let fourth = length >> 2
        
        let _in_count = in_count >> 1
        cooleytukey_forward(log2n - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), out_real, out_imag, out_stride)
        
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
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee
        
        let angle = -T.pi / T(half)
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
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: ElementaryFunctions {
    
    cooleytukey_forward(log2n, in_real, in_imag, in_stride, (in_count, in_count), out_real, out_imag, out_stride)
}

@inlinable
@inline(__always)
func cooleytukey_forward_reorderd<T: BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T: ElementaryFunctions {
    
    let count = 1 << log2n
    
    do {
        var _r = real
        var _i = imag
        let m_stride = stride << 4
        for _ in Swift.stride(from: 0, to: count, by: 16) {
            cooleytukey_forward_reorderd_16(_r, _i, stride)
            _r += m_stride
            _i += m_stride
        }
    }
    
    for s in 4..<log2n {
        
        let m = 2 << s
        let n = 1 << s
        
        let angle = -T.pi / T(n)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        
        let m_stride = m * stride
        let n_stride = n * stride
        
        var r1 = real
        var i1 = imag
        
        for _ in Swift.stride(from: 0, to: count, by: m) {
            
            var _cos1 = 1 as T
            var _sin1 = 0 as T
            
            var _r1 = r1
            var _i1 = i1
            var _r2 = r1 + n_stride
            var _i2 = i1 + n_stride
            
            for _ in 0..<n {
                
                let ur = _r1.pointee
                let ui = _i1.pointee
                let vr = _r2.pointee
                let vi = _i2.pointee
                
                let vrc = vr * _cos1
                let vic = vi * _cos1
                let vrs = vr * _sin1
                let vis = vi * _sin1
                
                let _c = _cos * _cos1 - _sin * _sin1
                let _s = _cos * _sin1 + _sin * _cos1
                _cos1 = _c
                _sin1 = _s
                
                _r1.pointee = ur + vrc - vis
                _i1.pointee = ui + vrs + vic
                _r2.pointee = ur - vrc + vis
                _i2.pointee = ui - vrs - vic
                
                _r1 += stride
                _i1 += stride
                _r2 += stride
                _i2 += stride
            }
            
            r1 += m_stride
            i1 += m_stride
        }
    }
}

@inlinable
@inline(__always)
func cooleytukey_forward<T: BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T: ElementaryFunctions {
    
    let count = 1 << log2n
    
    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
        var out_real = out_real
        var out_imag = out_imag
        for _ in 0..<count {
            out_real.pointee = 0
            out_imag.pointee = 0
            out_real += out_stride
            out_imag += out_stride
        }
        return
    }
    
    switch log2n {
        
    case 0:
        out_real.pointee = in_count.0 == 0 ? 0 : in_real.pointee
        out_imag.pointee = in_count.1 == 0 ? 0 : in_imag.pointee
        
    case 1:
        cooleytukey_forward_2(in_real, in_imag, in_stride, in_count, out_real, out_imag, out_stride)
    case 2:
        cooleytukey_forward_4(in_real, in_imag, in_stride, in_count, out_real, out_imag, out_stride)
    case 3:
        cooleytukey_forward_8(in_real, in_imag, in_stride, in_count, out_real, out_imag, out_stride)
    case 4:
        cooleytukey_forward_16(in_real, in_imag, in_stride, in_count, out_real, out_imag, out_stride)
        
    default:
        let offset = Int.bitWidth - log2n
        
        do {
            var in_real = in_real
            var in_imag = in_imag
            for i in 0..<count {
                let _i = Int(UInt(i).reverse >> offset)
                out_real[_i * out_stride] = i < in_count.0 ? in_real.pointee : 0
                out_imag[_i * out_stride] = i < in_count.1 ? in_imag.pointee : 0
                in_real += in_stride
                in_imag += in_stride
            }
        }
        
        cooleytukey_forward_reorderd(log2n, out_real, out_imag, out_stride)
    }
}

@inlinable
@inline(__always)
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T: ElementaryFunctions {
    
    let count = 1 << log2n
    
    switch log2n {
        
    case 0: break
        
    case 1:
        cooleytukey_forward_2(real, imag, stride, (count, count), real, imag, stride)
    case 2:
        cooleytukey_forward_4(real, imag, stride, (count, count), real, imag, stride)
    case 3:
        cooleytukey_forward_8(real, imag, stride, (count, count), real, imag, stride)
    case 4:
        cooleytukey_forward_16(real, imag, stride, (count, count), real, imag, stride)
        
    default:
        
        do {
            let offset = Int.bitWidth - log2n
            var _real = real
            var _imag = imag
            for i in 1..<count - 1 {
                let _i = Int(UInt(i).reverse >> offset)
                _real += stride
                _imag += stride
                if i < _i {
                    swap(&_real.pointee, &real[_i * stride])
                    swap(&_imag.pointee, &imag[_i * stride])
                }
            }
        }
        
        cooleytukey_forward_reorderd(log2n, real, imag, stride)
    }
}
