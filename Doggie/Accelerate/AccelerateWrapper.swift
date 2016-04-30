//
//  Wrapper.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

import Foundation

public func ToRect(count: Int, _ rho: UnsafePointer<Double>, _ theta: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    ToRect(count, rho, theta, in_stride, _output, _output + 1, out_stride << 1)
}
public func ToPolar(count: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, rho: UnsafeMutablePointer<Double>, theta: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    ToPolar(count, _input, _input + 1, in_stride << 1, rho, theta, out_stride)
}

public func Add(count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Add(count, left, left_stride, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Sub(count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Sub(count, left, left_stride, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Mul(count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Mul(count, left, left_stride, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulAdd(count: Int, _ a: UnsafePointer<Double>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _b = UnsafePointer<Double>(b)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulAdd(count, a, a_stride, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulSub(count: Int, _ a: UnsafePointer<Double>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _b = UnsafePointer<Double>(b)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulSub(count, a, a_stride, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func SubMul(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    SubMul(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Div(count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Div(count, left, left_stride, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}

public func Add(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _output = UnsafeMutablePointer<Double>(output)
    Add(count, _left, _left + 1, left_stride << 1, right, right_stride, _output, _output + 1, out_stride << 1)
}
public func Sub(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _output = UnsafeMutablePointer<Double>(output)
    Sub(count, _left, _left + 1, left_stride << 1, right, right_stride, _output, _output + 1, out_stride << 1)
}
public func Mul(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _output = UnsafeMutablePointer<Double>(output)
    Mul(count, _left, _left + 1, left_stride << 1, right, right_stride, _output, _output + 1, out_stride << 1)
}
public func MulAdd(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulAdd(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulSub(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulSub(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func SubMul(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Double>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _b = UnsafePointer<Double>(b)
    let _output = UnsafeMutablePointer<Double>(output)
    SubMul(count, _a, _a + 1, a_stride << 1, _b, _b + 1, b_stride << 1, c, c_stride, _output, _output + 1, out_stride << 1)
}
public func MulConj(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _output = UnsafeMutablePointer<Double>(output)
    MulConj(count, _left, _left + 1, left_stride << 1, right, right_stride, _output, _output + 1, out_stride << 1)
}
public func Div(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _output = UnsafeMutablePointer<Double>(output)
    Div(count, _left, _left + 1, left_stride << 1, right, right_stride, _output, _output + 1, out_stride << 1)
}

public func Add(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Add(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Sub(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Sub(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Mul(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Mul(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulAdd(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _b = UnsafePointer<Double>(b)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulAdd(count, _a, _a + 1, a_stride << 1, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulSub(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _b = UnsafePointer<Double>(b)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    MulSub(count, _a, _a + 1, a_stride << 1, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func SubMul(count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _a = UnsafePointer<Double>(a)
    let _b = UnsafePointer<Double>(b)
    let _c = UnsafePointer<Double>(c)
    let _output = UnsafeMutablePointer<Double>(output)
    SubMul(count, _a, _a + 1, a_stride << 1, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, _output, _output + 1, out_stride << 1)
}
public func MulConj(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    MulConj(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Div(count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _left = UnsafePointer<Double>(left)
    let _right = UnsafePointer<Double>(right)
    let _output = UnsafeMutablePointer<Double>(output)
    Div(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, _output, _output + 1, out_stride << 1)
}
public func HalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    HalfRadix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func HalfInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    HalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1)
}
public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    Radix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    Radix2CooleyTukey(level, _input, _input + 1, in_stride << 1, _output, _output + 1, out_stride << 1)
}
public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    InverseRadix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    InverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, _output, _output + 1, out_stride << 1)
}
public func DispatchHalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func DispatchHalfInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchHalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1)
}
public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchRadix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, _output, _output + 1, out_stride << 1)
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchInverseRadix2CooleyTukey(level, input, in_stride, _output, _output + 1, out_stride << 1)
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, _output, _output + 1, out_stride << 1)
}
public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    Radix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func InverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    InverseRadix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    Radix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func DispatchInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    InverseRadix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func HalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    HalfRadix2CooleyTukey(levelRow, levelCol, input, in_stride_row, in_stride_col, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func HalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    HalfInverseRadix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, output, out_stride_row, out_stride_col, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func DispatchHalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchHalfRadix2CooleyTukey(levelRow, levelCol, input, in_stride_row, in_stride_col, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func DispatchHalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Complex>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchHalfInverseRadix2CooleyTukey(levelRow, levelCol, _input, _input + 1, in_stride_row, in_stride_col << 1, output, out_stride_row, out_stride_col, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    Radix2CooleyTukey(levelRow, levelCol, input, in_stride_row, in_stride_col, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride_row: Int, _ out_stride_col: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchRadix2CooleyTukey(levelRow, levelCol, input, in_stride_row, in_stride_col, _output, _output + 1, out_stride_row, out_stride_col << 1, _temp, _temp + 1, temp_stride_row, temp_stride_col << 1)
}
public func ParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    ParallelHalfRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func ParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, out_rows_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int, tp_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    ParallelHalfInverseRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, output, out_stride, out_rows_stride, _temp, _temp + 1, tp_stride << 1, tp_rows_stride << 1)
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    ParallelRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    ParallelRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    ParallelInverseRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    ParallelInverseRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func DispatchParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchParallelHalfRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func DispatchParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, out_rows_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int, tp_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchParallelHalfInverseRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, output, out_stride, out_rows_stride, _temp, _temp + 1, tp_stride << 1, tp_rows_stride << 1)
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchParallelRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchParallelRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchParallelInverseRadix2CooleyTukey(rows, level, input, in_stride, in_rows_stride, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, in_rows_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, out_rows_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchParallelInverseRadix2CooleyTukey(rows, level, _input, _input + 1, in_stride << 1, in_rows_stride << 1, _output, _output + 1, out_stride << 1, out_rows_stride << 1)
}
public func Radix2CircularConvolve(level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    let _signal = UnsafePointer<Double>(signal)
    let _kernel = UnsafePointer<Double>(kernel)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    Radix2CircularConvolve(level, _signal, _signal + 1, signal_stride << 1, _kernel, _kernel + 1, kernel_stride << 1, _output, _output + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1)
}
public func DispatchRadix2CircularConvolve(level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    let _signal = UnsafePointer<Double>(signal)
    let _kernel = UnsafePointer<Double>(kernel)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchRadix2CircularConvolve(level, _signal, _signal + 1, signal_stride << 1, _kernel, _kernel + 1, kernel_stride << 1, _output, _output + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1)
}
public func Radix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ n: Double, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    Radix2PowerCircularConvolve(level, _input, _input + 1, in_stride << 1, n, _output, _output + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1)
}
public func DispatchRadix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ n: Double, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchRadix2PowerCircularConvolve(level, _input, _input + 1, in_stride << 1, n, _output, _output + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1)
}
