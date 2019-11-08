//
//  Radix2CooleyTukey_2.swift
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
func Radix2CooleyTukey_2<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
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
        return
    }
    
    let a = input.pointee
    input += in_stride
    
    let b = in_count > 1 ? input.pointee : 0
    
    _real.pointee = a + b
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - b
    _imag.pointee = 0
    
}
@inlinable
@inline(__always)
func Radix2CooleyTukey_2<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    _Radix2CooleyTukey_2(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_2<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
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
        return
    }
    
    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride
    
    let c = in_count.0 > 1 ? real.pointee : 0
    let d = in_count.1 > 1 ? imag.pointee : 0
    
    _real.pointee = a + c
    _imag.pointee = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - c
    _imag.pointee = b - d
    
}
