//
//  Move.swift
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
public func Move<T>(_ count: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var output = output
    
    for _ in 0..<count {
        output.pointee = input.pointee
        input += in_stride
        output += out_stride
    }
}
@inlinable
@inline(__always)
public func Move<T: FloatingPoint>(_ count: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        _real.pointee = real.pointee
        _imag.pointee = imag.pointee
        real += in_stride
        imag += in_stride
        _real += out_stride
        _imag += out_stride
    }
}

@inlinable
@inline(__always)
public func Swap<T>(_ count: Int, _ left: UnsafeMutablePointer<T>, _ l_stride: Int, _ right: UnsafeMutablePointer<T>, _ r_stride: Int) {
    
    var left = left
    var right = right
    
    for _ in 0..<count {
        (left.pointee, right.pointee) = (right.pointee, left.pointee)
        left += l_stride
        right += r_stride
    }
}
@inlinable
@inline(__always)
public func Swap<T: FloatingPoint>(_ count: Int, _ lreal: UnsafeMutablePointer<T>, _ limag: UnsafeMutablePointer<T>, _ l_stride: Int, _ rreal: UnsafeMutablePointer<T>, _ rimag: UnsafeMutablePointer<T>, _ r_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    
    for _ in 0..<count {
        (lreal.pointee, rreal.pointee) = (rreal.pointee, lreal.pointee)
        (limag.pointee, rimag.pointee) = (rimag.pointee, limag.pointee)
        lreal += l_stride
        limag += l_stride
        rreal += r_stride
        rimag += r_stride
    }
}

@inlinable
@inline(__always)
public func Transpose<T>(_ column: Int, _ row: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var output = output
    
    let _in_stride = in_stride * column
    let _out_stride = out_stride * row
    for _ in 0..<column {
        Move(row, input, _in_stride, output, out_stride)
        input += in_stride
        output += _out_stride
    }
}

@inlinable
@inline(__always)
public func Transpose<T: FloatingPoint>(_ column: Int, _ row: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let _in_stride = in_stride * column
    let _out_stride = out_stride * row
    for _ in 0..<column {
        Move(row, real, imag, _in_stride, _real, _imag, out_stride)
        real += in_stride
        imag += in_stride
        _real += _out_stride
        _imag += _out_stride
    }
}
