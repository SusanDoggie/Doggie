//
//  LinearAlgebra.swift
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
public func vec_op<T1, T2>(_ count: Int,
                           _ input: UnsafePointer<T1>, _ in_stride: Int,
                           _ output: UnsafeMutablePointer<T2>, _ out_stride: Int,
                           _ operation: (T1) -> T2) {
    
    var input = input
    var output = output
    
    for _ in 0..<count {
        output.pointee = operation(input.pointee)
        input += in_stride
        output += out_stride
    }
}

@inlinable
@inline(__always)
public func vec_op<T1, T2, T3>(_ count: Int,
                               _ a: UnsafePointer<T1>, _ a_stride: Int,
                               _ b: UnsafePointer<T2>, _ b_stride: Int,
                               _ output: UnsafeMutablePointer<T3>, _ out_stride: Int,
                               _ operation: (T1, T2) -> T3) {
    
    var a = a
    var b = b
    var output = output
    
    for _ in 0..<count {
        output.pointee = operation(a.pointee, b.pointee)
        a += a_stride
        b += b_stride
        output += out_stride
    }
}

@inlinable
@inline(__always)
public func vec_op<T1, T2, T3, T4>(_ count: Int,
                                   _ a: UnsafePointer<T1>, _ a_stride: Int,
                                   _ b: UnsafePointer<T2>, _ b_stride: Int,
                                   _ c: UnsafePointer<T3>, _ c_stride: Int,
                                   _ output: UnsafeMutablePointer<T4>, _ out_stride: Int,
                                   _ operation: (T1, T2, T3) -> T4) {
    
    var a = a
    var b = b
    var c = c
    var output = output
    
    for _ in 0..<count {
        output.pointee = operation(a.pointee, b.pointee, c.pointee)
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}

@inlinable
@inline(__always)
public func Dot<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int) -> T {
    
    var left = left
    var right = right
    
    var result: T = 0
    for _ in 0..<count {
        result += left.pointee * right.pointee
        left += left_stride
        right += right_stride
    }
    return result
}

@inlinable
@inline(__always)
public func Deconvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var signal = signal
    var kernel = kernel
    var output = output
    
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.pointee
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.pointee = _a * (signal.pointee - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
}
@inlinable
@inline(__always)
public func Deconvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ residue: UnsafeMutablePointer<T>, _ residue_stride: Int) {
    
    var signal = signal
    var kernel = kernel
    var output = output
    var residue = residue
    
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.pointee
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.pointee = _a * (signal.pointee - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
    if residue_size > quotient_size {
        for _ in 0..<residue_size - quotient_size {
            residue.pointee = signal.pointee - Dot(quotient_size, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
        for i in 0..<quotient_size {
            residue.pointee = signal.pointee - Dot(quotient_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    } else {
        for i in 0..<residue_size {
            residue.pointee = signal.pointee - Dot(residue_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    }
}

@inlinable
@inline(__always)
public func MatrixElimination<T: FloatingPoint>(_ column: Int, _ row: Int, _ matrix: UnsafeMutablePointer<T>, _ stride_row: Int, _ stride_col: Int) -> Bool {
    
    let row_offset = stride_row * stride_col * column
    let endptr = matrix + row_offset * row
    
    var current_row = matrix
    var i_offset = 0
    while current_row != endptr {
        var m = (current_row + i_offset).pointee
        if m == 0 {
            var swap_ptr = current_row + row_offset
            repeat {
                if swap_ptr == endptr {
                    return false
                }
                m = (swap_ptr + i_offset).pointee
                if m != 0 {
                    Swap(column, current_row, stride_col, swap_ptr, stride_col)
                    break
                }
                swap_ptr += row_offset
            } while true
        }
        vec_op(column, current_row, stride_col, current_row, stride_col) { $0 / m }
        var scan = matrix
        while scan != endptr {
            if scan != current_row {
                let n = (scan + i_offset).pointee
                vec_op(column, scan, stride_col, current_row, stride_col, scan, stride_col) { $0 - $1 * n }
            }
            scan += row_offset
        }
        i_offset += stride_col
        current_row += row_offset
    }
    return true
}
