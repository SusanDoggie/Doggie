//
//  HalfInverseRadix2CooleyTukey_8.swift
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
func HalfInverseRadix2CooleyTukey_8<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
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
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }
    
    let a1 = real.pointee
    let b1 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let e1 = in_count > 1 ? real.pointee : 0
    let e2 = in_count > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let c1 = in_count > 2 ? real.pointee : 0
    let c2 = in_count > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let g1 = in_count > 3 ? real.pointee : 0
    let g2 = in_count > 3 ? imag.pointee : 0
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + c1
    let d4 = c2 + c2
    let e3 = e1 + g1
    let e4 = e2 - g2
    let f3 = e1 - g1
    let f4 = e2 + g2
    let g3 = g1 + e1
    let g4 = g2 - e2
    let h3 = g1 - e1
    let h4 = g2 + e2
    
    let a5 = a3 + c3
    let b5 = b3 - d4
    let c5 = a3 - c3
    let d5 = b3 + d4
    let e5 = e3 + g3
    let f5 = f3 - h4
    let f6 = f4 + h3
    let g6 = e4 - g4
    let h5 = f3 + h4
    let h6 = f4 - h3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f5 - f6)
    let k = M_SQRT1_2 * (h5 + h6)
    
    output.pointee = a5 + e5
    output += out_stride
    
    output.pointee = b5 + i
    output += out_stride
    
    output.pointee = c5 - g6
    output += out_stride
    
    output.pointee = d5 - k
    output += out_stride
    
    output.pointee = a5 - e5
    output += out_stride
    
    output.pointee = b5 - i
    output += out_stride
    
    output.pointee = c5 + g6
    output += out_stride
    
    output.pointee = d5 + k
}
