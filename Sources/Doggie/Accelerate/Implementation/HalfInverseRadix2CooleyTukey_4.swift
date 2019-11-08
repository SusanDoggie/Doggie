//
//  HalfInverseRadix2CooleyTukey_4.swift
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
func HalfInverseRadix2CooleyTukey_4<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var output = output
    
    if _slowPath(in_count == 0) {
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }
    
    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0
    
    let e = a + b
    let f = a - b
    let g = c + c
    let h = d + d
    
    output.pointee = e + g
    output += out_stride
    
    output.pointee = f - h
    output += out_stride
    
    output.pointee = e - g
    output += out_stride
    
    output.pointee = f + h
}
