//
//  CircularConvolve2D.swift
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
public func Radix2CircularConvolve2D<T: BinaryFloatingPoint>(_ log2n: (Int, Int), _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_count: (Int, Int), _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_count: (Int, Int), _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) where T: FloatingMathProtocol {
    
    let width = 1 << log2n.0
    let height = 1 << log2n.1
    let half_width = width >> 1
    let half_height = height >> 1
    
    if _slowPath(signal_count.0 == 0 || signal_count.1 == 0 || kernel_count.0 == 0 || kernel_count.1 == 0) {
        var output = output
        for _ in 0..<width * height {
            output.pointee = 0
            output += out_stride
        }
        return
    }
    
    let _sreal = temp
    let _simag = temp + temp_stride
    let _kreal = output
    let _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey2D(log2n, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey2D(log2n, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / T(width * height)
    let s_row_stride = s_stride * half_width
    let k_row_stride = k_stride * half_width
    
    func _multiply_complex(_ length: Int, _ sreal: UnsafeMutablePointer<T>, _ simag: UnsafeMutablePointer<T>, _ s_stride: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ k_stride: Int) {
        
        var sreal = sreal
        var simag = simag
        var kreal = kreal
        var kimag = kimag
        
        for _ in 1..<length {
            sreal += s_stride
            simag += s_stride
            kreal += k_stride
            kimag += k_stride
            let _sr = sreal.pointee
            let _si = simag.pointee
            let _kr = m * kreal.pointee
            let _ki = m * kimag.pointee
            sreal.pointee = _sr * _kr - _si * _ki
            simag.pointee = _sr * _ki + _si * _kr
        }
    }
    
    do {
        
        var _sreal = _sreal
        var _simag = _simag
        var _kreal = _kreal
        var _kimag = _kimag
        
        _sreal.pointee *= m * _kreal.pointee
        _simag.pointee *= m * _kimag.pointee
        
        _sreal += s_row_stride
        _simag += s_row_stride
        _kreal += k_row_stride
        _kimag += k_row_stride
        
        _sreal.pointee *= m * _kreal.pointee
        _simag.pointee *= m * _kimag.pointee
    }
    
    _multiply_complex(half_height, _sreal, _sreal + s_row_stride, s_row_stride << 1, _kreal, _kreal + k_row_stride, k_row_stride << 1)
    _multiply_complex(half_height, _simag, _simag + s_row_stride, s_row_stride << 1, _kimag, _kimag + k_row_stride, k_row_stride << 1)
    
    do {
        
        var _sreal = _sreal
        var _simag = _simag
        var _kreal = _kreal
        var _kimag = _kimag
        
        let s_row_stride = s_stride * half_width
        let k_row_stride = k_stride * half_width
        
        for _ in 0..<height {
            _multiply_complex(half_width, _sreal, _simag, s_stride, _kreal, _kimag, k_stride)
            _sreal += s_row_stride
            _simag += s_row_stride
            _kreal += k_row_stride
            _kimag += k_row_stride
        }
    }
    
    HalfInverseRadix2CooleyTukey2D(log2n, _sreal, _simag, s_stride, output, out_stride)
}
