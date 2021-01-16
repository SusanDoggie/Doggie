//
//  cooleytukey_16.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
func cooleytukey_forward_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
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
    
    out_real.pointee = a7 + i7
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = -b8 - w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + q2
    out_imag.pointee = -g5 - r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = d8 + x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7
    out_imag.pointee = -m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = x3 - d8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - q2
    out_imag.pointee = g5 - r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = b8 - w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a7 - i7
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = w3 - b8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - q2
    out_imag.pointee = r2 - g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = d8 - x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7
    out_imag.pointee = m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = -x3 - d8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + q2
    out_imag.pointee = g5 + r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = b8 + w3
}
@inlinable
@inline(__always)
func cooleytukey_forward_16<T: BinaryFloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = in_real.pointee
    let a2 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let i1 = in_count.0 > 1 ? in_real.pointee : 0
    let i2 = in_count.1 > 1 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let e1 = in_count.0 > 2 ? in_real.pointee : 0
    let e2 = in_count.1 > 2 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let m1 = in_count.0 > 3 ? in_real.pointee : 0
    let m2 = in_count.1 > 3 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let c1 = in_count.0 > 4 ? in_real.pointee : 0
    let c2 = in_count.1 > 4 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let k1 = in_count.0 > 5 ? in_real.pointee : 0
    let k2 = in_count.1 > 5 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let g1 = in_count.0 > 6 ? in_real.pointee : 0
    let g2 = in_count.1 > 6 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let o1 = in_count.0 > 7 ? in_real.pointee : 0
    let o2 = in_count.1 > 7 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let b1 = in_count.0 > 8 ? in_real.pointee : 0
    let b2 = in_count.1 > 8 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let j1 = in_count.0 > 9 ? in_real.pointee : 0
    let j2 = in_count.1 > 9 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let f1 = in_count.0 > 10 ? in_real.pointee : 0
    let f2 = in_count.1 > 10 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let n1 = in_count.0 > 11 ? in_real.pointee : 0
    let n2 = in_count.1 > 11 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let d1 = in_count.0 > 12 ? in_real.pointee : 0
    let d2 = in_count.1 > 12 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let l1 = in_count.0 > 13 ? in_real.pointee : 0
    let l2 = in_count.1 > 13 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let h1 = in_count.0 > 14 ? in_real.pointee : 0
    let h2 = in_count.1 > 14 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let p1 = in_count.0 > 15 ? in_real.pointee : 0
    let p2 = in_count.1 > 15 ? in_imag.pointee : 0
    
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
    
    out_real.pointee = a7 + i7
    out_imag.pointee = a8 + i8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = b8 + w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c7 + q2
    out_imag.pointee = c8 + r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = d8 + x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7 + m8
    out_imag.pointee = e8 - m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f7 + y2
    out_imag.pointee = f8 - y3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = g7 + s2
    out_imag.pointee = g8 - t2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = h7 + z2
    out_imag.pointee = h8 - z3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a7 - i7
    out_imag.pointee = a8 - i8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = b8 - w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c7 - q2
    out_imag.pointee = c8 - r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = d8 - x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7 - m8
    out_imag.pointee = e8 + m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f7 - y2
    out_imag.pointee = f8 + y3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = g7 - s2
    out_imag.pointee = g8 + t2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = h7 - z2
    out_imag.pointee = h8 + z3
}

@inlinable
@inline(__always)
func cooleytukey_inverse_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
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
    let j7 = j3 + w
    let j8 = l3 + x
    let l7 = j3 - w
    let l8 = l3 - x
    let m7 = i5 - m5
    
    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T
    
    let q2 = M_SQRT1_2 * (k5 - o5)
    let r2 = M_SQRT1_2 * (o5 + k5)
    let w2 = M_COS_22_5 * j7 - M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 + M_SIN_22_5 * j7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_COS_22_5 * l7 - M_SIN_22_5 * l8
    
    out_real.pointee = a7 + i7
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = b8 + w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + q2
    out_imag.pointee = g5 + r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = x3 - d8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7
    out_imag.pointee = m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = d8 + x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - q2
    out_imag.pointee = r2 - g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = w3 - b8
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a7 - i7
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = b8 - w3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - q2
    out_imag.pointee = g5 - r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = -d8 - x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e7
    out_imag.pointee = -m7
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = d8 - x3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + q2
    out_imag.pointee = -g5 - r2
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = -b8 - w3
}

@inlinable
@inline(__always)
func cooleytukey_forward_reorderd_16<T: BinaryFloatingPoint>(_ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    var in_real = real
    var in_imag = imag
    var out_real = real
    var out_imag = imag
    
    let a1 = in_real.pointee
    let a2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let b1 = in_real.pointee
    let b2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let c1 = in_real.pointee
    let c2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let d1 = in_real.pointee
    let d2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let e1 = in_real.pointee
    let e2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let f1 = in_real.pointee
    let f2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let g1 = in_real.pointee
    let g2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let h1 = in_real.pointee
    let h2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let i1 = in_real.pointee
    let i2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let j1 = in_real.pointee
    let j2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let k1 = in_real.pointee
    let k2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let l1 = in_real.pointee
    let l2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let m1 = in_real.pointee
    let m2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let n1 = in_real.pointee
    let n2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let o1 = in_real.pointee
    let o2 = in_imag.pointee
    in_real += stride
    in_imag += stride
    
    let p1 = in_real.pointee
    let p2 = in_imag.pointee
    
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
    
    out_real.pointee = a7 + i7
    out_imag.pointee = a8 + i8
    out_real += stride
    out_imag += stride
    
    out_real.pointee = b7 + w2
    out_imag.pointee = b8 + w3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = c7 + q2
    out_imag.pointee = c8 + r2
    out_real += stride
    out_imag += stride
    
    out_real.pointee = d7 + x2
    out_imag.pointee = d8 + x3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = e7 + m8
    out_imag.pointee = e8 - m7
    out_real += stride
    out_imag += stride
    
    out_real.pointee = f7 + y2
    out_imag.pointee = f8 - y3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = g7 + s2
    out_imag.pointee = g8 - t2
    out_real += stride
    out_imag += stride
    
    out_real.pointee = h7 + z2
    out_imag.pointee = h8 - z3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = a7 - i7
    out_imag.pointee = a8 - i8
    out_real += stride
    out_imag += stride
    
    out_real.pointee = b7 - w2
    out_imag.pointee = b8 - w3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = c7 - q2
    out_imag.pointee = c8 - r2
    out_real += stride
    out_imag += stride
    
    out_real.pointee = d7 - x2
    out_imag.pointee = d8 - x3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = e7 - m8
    out_imag.pointee = e8 + m7
    out_real += stride
    out_imag += stride
    
    out_real.pointee = f7 - y2
    out_imag.pointee = f8 + y3
    out_real += stride
    out_imag += stride
    
    out_real.pointee = g7 - s2
    out_imag.pointee = g8 + t2
    out_real += stride
    out_imag += stride
    
    out_real.pointee = h7 - z2
    out_imag.pointee = h8 + z3
}
