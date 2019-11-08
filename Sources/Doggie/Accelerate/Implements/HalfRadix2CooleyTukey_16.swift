//
//  HalfRadix2CooleyTukey_16.swift
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
func HalfRadix2CooleyTukey_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }
    
    let a1 = input.pointee
    input += in_stride
    
    let i1 = in_count > 1 ? input.pointee : 0
    input += in_stride
    
    let e1 = in_count > 2 ? input.pointee : 0
    input += in_stride
    
    let m1 = in_count > 3 ? input.pointee : 0
    input += in_stride
    
    let c1 = in_count > 4 ? input.pointee : 0
    input += in_stride
    
    let k1 = in_count > 5 ? input.pointee : 0
    input += in_stride
    
    let g1 = in_count > 6 ? input.pointee : 0
    input += in_stride
    
    let o1 = in_count > 7 ? input.pointee : 0
    input += in_stride
    
    let b1 = in_count > 8 ? input.pointee : 0
    input += in_stride
    
    let j1 = in_count > 9 ? input.pointee : 0
    input += in_stride
    
    let f1 = in_count > 10 ? input.pointee : 0
    input += in_stride
    
    let n1 = in_count > 11 ? input.pointee : 0
    input += in_stride
    
    let d1 = in_count > 12 ? input.pointee : 0
    input += in_stride
    
    let l1 = in_count > 13 ? input.pointee : 0
    input += in_stride
    
    let h1 = in_count > 14 ? input.pointee : 0
    input += in_stride
    
    let p1 = in_count > 15 ? input.pointee : 0
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    let i3 = i1 + j1
    let j3 = i1 - j1
    let k3 = k1 + l1
    let l3 = k1 - l1
    let m3 = m1 + n1
    let n3 = m1 - n1
    let o3 = o1 + p1
    let p3 = o1 - p1
    
    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    let i5 = i3 + k3
    let k5 = i3 - k3
    let m5 = m3 + o3
    let o5 = m3 - o3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let q = M_SQRT1_2 * (f3 - h3)
    let r = M_SQRT1_2 * (h3 + f3)
    let w = M_SQRT1_2 * (n3 - p3)
    let x = M_SQRT1_2 * (p3 + n3)
    
    let a7 = a5 + e5
    let b7 = b3 + q
    let b8 = d3 + r
    let d7 = b3 - q
    let d8 = d3 - r
    let e7 = a5 - e5
    let i7 = i5 + m5
    let p7 = j3 + w
    let j8 = l3 + x
    let l7 = j3 - w
    let l8 = l3 - x
    let m7 = i5 - m5
    
    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T
    
    let q2 = M_SQRT1_2 * (k5 - o5)
    let r2 = M_SQRT1_2 * (k5 + o5)
    let w2 = M_COS_22_5 * p7 - M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 + M_SIN_22_5 * p7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7
    
    _real.pointee = a7 + i7
    _imag.pointee = a7 - i7
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 + w2
    _imag.pointee = -b8 - w3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 + q2
    _imag.pointee = -g5 - r2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = e7
    _imag.pointee = -m7
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 - x2
    _imag.pointee = x3 - d8
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 - q2
    _imag.pointee = g5 - r2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
}
