//
//  InverseRadix2CooleyTukey_4.swift
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
func InverseRadix2CooleyTukey_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var out_real = out_real
    var out_imag = out_imag
    
    if _slowPath(in_count == 0) {
        out_real.pointee = 0
        out_imag.pointee = 0
        out_real += out_stride
        out_imag += out_stride
        out_real.pointee = 0
        out_imag.pointee = 0
        out_real += out_stride
        out_imag += out_stride
        out_real.pointee = 0
        out_imag.pointee = 0
        out_real += out_stride
        out_imag += out_stride
        out_real.pointee = 0
        out_imag.pointee = 0
        return
    }
    
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
