//
//  cooleytukey_8.swift
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
func cooleytukey_forward_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = input.pointee
    input += in_stride
    
    let e1 = in_count > 1 ? input.pointee : 0
    input += in_stride
    
    let c1 = in_count > 2 ? input.pointee : 0
    input += in_stride
    
    let g1 = in_count > 3 ? input.pointee : 0
    input += in_stride
    
    let b1 = in_count > 4 ? input.pointee : 0
    input += in_stride
    
    let f1 = in_count > 5 ? input.pointee : 0
    input += in_stride
    
    let d1 = in_count > 6 ? input.pointee : 0
    input += in_stride
    
    let h1 = in_count > 7 ? input.pointee : 0
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    
    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (f3 + h3)
    
    out_real.pointee = a5 + e5
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 + i
    out_imag.pointee = -d3 - j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5
    out_imag.pointee = -g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 - i
    out_imag.pointee = d3 - j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a5 - e5
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 - i
    out_imag.pointee = j - d3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5
    out_imag.pointee = g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 + i
    out_imag.pointee = d3 + j
}

@inlinable
@inline(__always)
func cooleytukey_forward_8<T: BinaryFloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = in_real.pointee
    let a2 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let e1 = in_count.0 > 1 ? in_real.pointee : 0
    let e2 = in_count.1 > 1 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let c1 = in_count.0 > 2 ? in_real.pointee : 0
    let c2 = in_count.1 > 2 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let g1 = in_count.0 > 3 ? in_real.pointee : 0
    let g2 = in_count.1 > 3 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let b1 = in_count.0 > 4 ? in_real.pointee : 0
    let b2 = in_count.1 > 4 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let f1 = in_count.0 > 5 ? in_real.pointee : 0
    let f2 = in_count.1 > 5 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let d1 = in_count.0 > 6 ? in_real.pointee : 0
    let d2 = in_count.1 > 6 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let h1 = in_count.0 > 7 ? in_real.pointee : 0
    let h2 = in_count.1 > 7 ? in_imag.pointee : 0
    
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
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f5 + f6)
    let j = M_SQRT1_2 * (f6 - f5)
    let k = M_SQRT1_2 * (h5 - h6)
    let l = M_SQRT1_2 * (h6 + h5)
    
    out_real.pointee = a5 + e5
    out_imag.pointee = a6 + e6
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b5 + i
    out_imag.pointee = b6 + j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + g6
    out_imag.pointee = c6 - g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d5 - k
    out_imag.pointee = d6 - l
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a5 - e5
    out_imag.pointee = a6 - e6
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b5 - i
    out_imag.pointee = b6 - j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - g6
    out_imag.pointee = c6 + g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = d5 + k
    out_imag.pointee = d6 + l
}

@inlinable
@inline(__always)
func cooleytukey_inverse_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = input.pointee
    input += in_stride
    
    let e1 = in_count > 1 ? input.pointee : 0
    input += in_stride
    
    let c1 = in_count > 2 ? input.pointee : 0
    input += in_stride
    
    let g1 = in_count > 3 ? input.pointee : 0
    input += in_stride
    
    let b1 = in_count > 4 ? input.pointee : 0
    input += in_stride
    
    let f1 = in_count > 5 ? input.pointee : 0
    input += in_stride
    
    let d1 = in_count > 6 ? input.pointee : 0
    input += in_stride
    
    let h1 = in_count > 7 ? input.pointee : 0
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    
    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (h3 + f3)
    
    out_real.pointee = a5 + e5
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 + i
    out_imag.pointee = d3 + j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5
    out_imag.pointee = g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 - i
    out_imag.pointee = j - d3
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a5 - e5
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 - i
    out_imag.pointee = d3 - j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5
    out_imag.pointee = -g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 + i
    out_imag.pointee = -d3 - j
}
