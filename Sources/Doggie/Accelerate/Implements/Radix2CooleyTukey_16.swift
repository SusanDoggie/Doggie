//
//  Radix2CooleyTukey_16.swift
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
func Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
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
    _imag.pointee = 0
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
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a7 - i7
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 - w2
    _imag.pointee = w3 - b8
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 - q2
    _imag.pointee = r2 - g5
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 - x2
    _imag.pointee = d8 - x3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = e7
    _imag.pointee = m7
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 + x2
    _imag.pointee = -x3 - d8
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 + q2
    _imag.pointee = g5 + r2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
}
@inlinable
@inline(__always)
func Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    _Radix2CooleyTukey_16(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
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
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }
    
    let a1 = real.pointee
    let a2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let i1 = in_count.0 > 1 ? real.pointee : 0
    let i2 = in_count.1 > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let e1 = in_count.0 > 2 ? real.pointee : 0
    let e2 = in_count.1 > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let m1 = in_count.0 > 3 ? real.pointee : 0
    let m2 = in_count.1 > 3 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let c1 = in_count.0 > 4 ? real.pointee : 0
    let c2 = in_count.1 > 4 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let k1 = in_count.0 > 5 ? real.pointee : 0
    let k2 = in_count.1 > 5 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let g1 = in_count.0 > 6 ? real.pointee : 0
    let g2 = in_count.1 > 6 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let o1 = in_count.0 > 7 ? real.pointee : 0
    let o2 = in_count.1 > 7 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let b1 = in_count.0 > 8 ? real.pointee : 0
    let b2 = in_count.1 > 8 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let j1 = in_count.0 > 9 ? real.pointee : 0
    let j2 = in_count.1 > 9 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let f1 = in_count.0 > 10 ? real.pointee : 0
    let f2 = in_count.1 > 10 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let n1 = in_count.0 > 11 ? real.pointee : 0
    let n2 = in_count.1 > 11 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let d1 = in_count.0 > 12 ? real.pointee : 0
    let d2 = in_count.1 > 12 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let l1 = in_count.0 > 13 ? real.pointee : 0
    let l2 = in_count.1 > 13 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let h1 = in_count.0 > 14 ? real.pointee : 0
    let h2 = in_count.1 > 14 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let p1 = in_count.0 > 15 ? real.pointee : 0
    let p2 = in_count.1 > 15 ? imag.pointee : 0
    
    let a3 = a1 + b1
    let a4 = a2 + b2
    let b3 = a1 - b1
    let b4 = a2 - b2
    let c3 = c1 + d1
    let c4 = c2 + d2
    let d3 = c1 - d1
    let d4 = c2 - d2
    let e3 = e1 + f1
    let e4 = e2 + f2
    let f3 = e1 - f1
    let f4 = e2 - f2
    let g3 = g1 + h1
    let g4 = g2 + h2
    let h3 = g1 - h1
    let h4 = g2 - h2
    let i3 = i1 + j1
    let i4 = i2 + j2
    let j3 = i1 - j1
    let j4 = i2 - j2
    let k3 = k1 + l1
    let k4 = k2 + l2
    let l3 = k1 - l1
    let l4 = k2 - l2
    let m3 = m1 + n1
    let m4 = m2 + n2
    let n3 = m1 - n1
    let n4 = m2 - n2
    let o3 = o1 + p1
    let o4 = o2 + p2
    let p3 = o1 - p1
    let p4 = o2 - p2
    
    let a5 = a3 + c3
    let a6 = a4 + c4
    let b5 = b3 + d4
    let b6 = b4 - d3
    let c5 = a3 - c3
    let c6 = a4 - c4
    let d5 = b3 - d4
    let d6 = b4 + d3
    let e5 = e3 + g3
    let e6 = e4 + g4
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g5 = e3 - g3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3
    let i5 = i3 + k3
    let i6 = i4 + k4
    let j5 = j3 + l4
    let j6 = j4 - l3
    let k5 = i3 - k3
    let k6 = i4 - k4
    let l5 = j3 - l4
    let l6 = j4 + l3
    let m5 = m3 + o3
    let m6 = m4 + o4
    let n5 = n3 + p4
    let n6 = n4 - p3
    let o5 = m3 - o3
    let o6 = m4 - o4
    let p5 = n3 - p4
    let p6 = n4 + p3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let q = M_SQRT1_2 * (f5 + f6)
    let r = M_SQRT1_2 * (f6 - f5)
    let s = M_SQRT1_2 * (h5 - h6)
    let t = M_SQRT1_2 * (h6 + h5)
    let w = M_SQRT1_2 * (n5 + n6)
    let x = M_SQRT1_2 * (n6 - n5)
    let y = M_SQRT1_2 * (p5 - p6)
    let z = M_SQRT1_2 * (p6 + p5)
    
    let a7 = a5 + e5
    let a8 = a6 + e6
    let b7 = b5 + q
    let b8 = b6 + r
    let c7 = c5 + g6
    let c8 = c6 - g5
    let d7 = d5 - s
    let d8 = d6 - t
    let e7 = a5 - e5
    let e8 = a6 - e6
    let f7 = b5 - q
    let f8 = b6 - r
    let g7 = c5 - g6
    let g8 = c6 + g5
    let h7 = d5 + s
    let h8 = d6 + t
    let i7 = i5 + m5
    let i8 = i6 + m6
    let j7 = j5 + w
    let j8 = j6 + x
    let k7 = k5 + o6
    let k8 = k6 - o5
    let l7 = l5 - y
    let l8 = l6 - z
    let m7 = i5 - m5
    let m8 = i6 - m6
    let n7 = j5 - w
    let n8 = j6 - x
    let o7 = k5 - o6
    let o8 = k6 + o5
    let p7 = l5 + y
    let p8 = l6 + z
    
    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T
    
    let q2 = M_SQRT1_2 * (k7 + k8)
    let r2 = M_SQRT1_2 * (k8 - k7)
    let s2 = M_SQRT1_2 * (o8 - o7)
    let t2 = M_SQRT1_2 * (o7 + o8)
    let w2 = M_COS_22_5 * j7 + M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 - M_SIN_22_5 * j7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7
    let y2 = M_COS_22_5 * n8 - M_SIN_22_5 * n7
    let y3 = M_COS_22_5 * n7 + M_SIN_22_5 * n8
    let z2 = M_SIN_22_5 * p8 - M_COS_22_5 * p7
    let z3 = M_SIN_22_5 * p7 + M_COS_22_5 * p8
    
    _real.pointee = a7 + i7
    _imag.pointee = a8 + i8
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c7 + q2
    _imag.pointee = c8 + r2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = e7 + m8
    _imag.pointee = e8 - m7
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = f7 + y2
    _imag.pointee = f8 - y3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = g7 + s2
    _imag.pointee = g8 - t2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = h7 + z2
    _imag.pointee = h8 - z3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a7 - i7
    _imag.pointee = a8 - i8
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c7 - q2
    _imag.pointee = c8 - r2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d7 - x2
    _imag.pointee = d8 - x3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = e7 - m8
    _imag.pointee = e8 + m7
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = f7 - y2
    _imag.pointee = f8 + y3
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = g7 - s2
    _imag.pointee = g8 + t2
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = h7 - z2
    _imag.pointee = h8 + z3
}
