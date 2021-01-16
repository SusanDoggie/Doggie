//
//  cooleytukey_4.swift
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
func cooleytukey_forward_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
    let a = input.pointee
    input += in_stride
    
    let b = in_count > 1 ? input.pointee : 0
    input += in_stride
    
    let c = in_count > 2 ? input.pointee : 0
    input += in_stride
    
    let d = in_count > 3 ? input.pointee : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    out_real.pointee = e + g
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f
    out_imag.pointee = -h
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e - g
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f
    out_imag.pointee = h
}

@inlinable
@inline(__always)
func cooleytukey_forward_4<T: FloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a = in_real.pointee
    let b = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let c = in_count.0 > 1 ? in_real.pointee : 0
    let d = in_count.1 > 1 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let e = in_count.0 > 2 ? in_real.pointee : 0
    let f = in_count.1 > 2 ? in_imag.pointee : 0
    in_real += in_stride
    in_imag += in_stride
    
    let g = in_count.0 > 3 ? in_real.pointee : 0
    let h = in_count.1 > 3 ? in_imag.pointee : 0
    
    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h
    
    out_real.pointee = i + m
    out_imag.pointee = j + n
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = k + p
    out_imag.pointee = l - o
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = i - m
    out_imag.pointee = j - n
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = k - p
    out_imag.pointee = l + o
}

@inlinable
@inline(__always)
func cooleytukey_inverse_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
    let a = input.pointee
    input += in_stride
    
    let b = in_count > 1 ? input.pointee : 0
    input += in_stride
    
    let c = in_count > 2 ? input.pointee : 0
    input += in_stride
    
    let d = in_count > 3 ? input.pointee : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    out_real.pointee = e + g
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f
    out_imag.pointee = h
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = e - g
    out_imag.pointee = 0
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = f
    out_imag.pointee = -h
}
