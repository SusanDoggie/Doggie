//
//  DirectConvolve.swift
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
public func DirectConvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    let size = signal_count + kernel_count - 1
    
    var output = output
    
    for t in 0..<size {
        var temp: T = 0
        let range = max(t - kernel_count + 1, 0)..<min(t + 1, signal_count)
        var _sp = signal + range.lowerBound * signal_stride
        var _kp = kernel + (t - range.lowerBound) * kernel_stride
        for _ in range {
            temp += _sp.pointee * _kp.pointee
            _sp += signal_stride
            _kp -= kernel_stride
        }
        output.pointee = temp
        output += out_stride
    }
}

@inlinable
@inline(__always)
public func DirectConvolve(_ signal_count: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    
    let size = signal_count + kernel_count - 1
    
    var output = output
    
    for t in 0..<size {
        var temp = Complex(0)
        let range = max(t - kernel_count + 1, 0)..<min(t + 1, signal_count)
        var _sp = signal + range.lowerBound * signal_stride
        var _kp = kernel + (t - range.lowerBound) * kernel_stride
        for _ in range {
            temp += _sp.pointee * _kp.pointee
            _sp += signal_stride
            _kp -= kernel_stride
        }
        output.pointee = temp
        output += out_stride
    }
}

@inlinable
@inline(__always)
public func DirectConvolve2D<T: FloatingPoint>(_ signal_count: (Int, Int), _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: (Int, Int), _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    let width = signal_count.0 + kernel_count.0 - 1
    let height = signal_count.1 + kernel_count.1 - 1
    
    let _signal_stride = signal_count.0 * signal_stride
    let _kernel_stride = kernel_count.0 * kernel_stride
    
    var output = output
    
    for s in 0..<height {
        for t in 0..<width {
            
            var temp: T = 0
            
            let range1 = max(t - kernel_count.0 + 1, 0)..<min(t + 1, signal_count.0)
            let range2 = max(s - kernel_count.1 + 1, 0)..<min(s + 1, signal_count.1)
            
            var _sp = signal + (range2.lowerBound * signal_count.0 + range1.lowerBound) * signal_stride
            var _kp = kernel + ((s - range2.lowerBound) * kernel_count.0 + (t - range1.lowerBound)) * kernel_stride
            
            for _ in range2 {
                
                var _sp2 = _sp
                var _kp2 = _kp
                
                for _ in range1 {
                    temp += _sp2.pointee * _kp2.pointee
                    _sp2 += signal_stride
                    _kp2 -= kernel_stride
                }
                
                _sp += _signal_stride
                _kp -= _kernel_stride
            }
            
            output.pointee = temp
            output += out_stride
        }
    }
}
