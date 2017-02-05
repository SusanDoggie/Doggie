//
//  AccelerateWrapper.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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


public func Add(_ count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Add(count, left, left_stride, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } }
}
public func Sub(_ count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Sub(count, left, left_stride, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } }
}
public func Mul(_ count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Mul(count, left, left_stride, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } }
}
public func MulAdd(_ count: Int, _ a: UnsafePointer<Double>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    b.withMemoryRebound(to: Double.self, capacity: 2) { _b in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulAdd(count, a, a_stride, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func MulSub(_ count: Int, _ a: UnsafePointer<Double>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    b.withMemoryRebound(to: Double.self, capacity: 2) { _b in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulSub(count, a, a_stride, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func SubMul(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { SubMul(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func Div(_ count: Int, _ left: UnsafePointer<Double>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Div(count, left, left_stride, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } }
}

public func Add(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in output.withMemoryRebound(to: Double.self, capacity: 2) { Add(count, _left, _left + 1, left_stride << 1, right, right_stride, $0, $0 + 1, out_stride << 1) } }
}
public func Sub(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in output.withMemoryRebound(to: Double.self, capacity: 2) { Sub(count, _left, _left + 1, left_stride << 1, right, right_stride, $0, $0 + 1, out_stride << 1) } }
}
public func Mul(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in output.withMemoryRebound(to: Double.self, capacity: 2) { Mul(count, _left, _left + 1, left_stride << 1, right, right_stride, $0, $0 + 1, out_stride << 1) } }
}
public func MulAdd(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulAdd(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func MulSub(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Double>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulSub(count, _a, _a + 1, a_stride << 1, b, b_stride, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func SubMul(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Double>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in b.withMemoryRebound(to: Double.self, capacity: 2) { _b in output.withMemoryRebound(to: Double.self, capacity: 2) { SubMul(count, _a, _a + 1, a_stride << 1, _b, _b + 1, b_stride << 1, c, c_stride, $0, $0 + 1, out_stride << 1) } } }
}
public func MulConj(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in output.withMemoryRebound(to: Double.self, capacity: 2) { MulConj(count, _left, _left + 1, left_stride << 1, right, right_stride, $0, $0 + 1, out_stride << 1) } }
}
public func Div(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Double>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in output.withMemoryRebound(to: Double.self, capacity: 2) { Div(count, _left, _left + 1, left_stride << 1, right, right_stride, $0, $0 + 1, out_stride << 1) } }
}

/// Adds the elements of two complex vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Complex input vector.
///   - left_stride: Stride for `left`.
///   - right: Complex input vector.
///   - right_stride: Stride for `right`.
///   - output: Complex result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] + right[n], 0 <= n < count`
public func Add(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Add(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
/// Subtracts the elements of two complex vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Complex input vector.
///   - left_stride: Stride for `left`.
///   - right: Complex input vector.
///   - right_stride: Stride for `right`.
///   - output: Complex result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] - right[n], 0 <= n < count`
public func Sub(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Sub(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
/// Multiplies the elements of two complex vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Complex input vector.
///   - left_stride: Stride for `left`.
///   - right: Complex input vector.
///   - right_stride: Stride for `right`.
///   - output: Complex result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] * right[n], 0 <= n < count`
public func Mul(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Mul(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
public func MulAdd(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in b.withMemoryRebound(to: Double.self, capacity: 2) { _b in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulAdd(count, _a, _a + 1, a_stride << 1, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } } }
}
public func MulSub(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in b.withMemoryRebound(to: Double.self, capacity: 2) { _b in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { MulSub(count, _a, _a + 1, a_stride << 1, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } } }
}
public func SubMul(_ count: Int, _ a: UnsafePointer<Complex>, _ a_stride: Int, _ b: UnsafePointer<Complex>, _ b_stride: Int, _ c: UnsafePointer<Complex>, _ c_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    a.withMemoryRebound(to: Double.self, capacity: 2) { _a in b.withMemoryRebound(to: Double.self, capacity: 2) { _b in c.withMemoryRebound(to: Double.self, capacity: 2) { _c in output.withMemoryRebound(to: Double.self, capacity: 2) { SubMul(count, _a, _a + 1, a_stride << 1, _b, _b + 1, b_stride << 1, _c, _c + 1, c_stride << 1, $0, $0 + 1, out_stride << 1) } } } }
}
public func MulConj(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { MulConj(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}
/// Divides the elements of two complex vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Complex input vector.
///   - left_stride: Stride for `left`.
///   - right: Complex input vector.
///   - right_stride: Stride for `right`.
///   - output: Complex result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] / right[n], 0 <= n < count`
public func Div(_ count: Int, _ left: UnsafePointer<Complex>, _ left_stride: Int, _ right: UnsafePointer<Complex>, _ right_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    left.withMemoryRebound(to: Double.self, capacity: 2) { _left in right.withMemoryRebound(to: Double.self, capacity: 2) { _right in output.withMemoryRebound(to: Double.self, capacity: 2) { Div(count, _left, _left + 1, left_stride << 1, _right, _right + 1, right_stride << 1, $0, $0 + 1, out_stride << 1) } } }
}

public func ToRect(_ count: Int, _ rho: UnsafePointer<Double>, _ theta: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { ToRect(count, rho, theta, in_stride, $0, $0 + 1, out_stride << 1) }
}
public func ToPolar(_ count: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, rho: UnsafeMutablePointer<Double>, theta: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { ToPolar(count, $0, $0 + 1, in_stride << 1, rho, theta, out_stride) }
}


public func HalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { HalfRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func HalfInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafeMutablePointer<Complex>, tp_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in HalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1) } }
}
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { Radix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { Radix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, $0, $0 + 1, out_stride << 1) } }
}
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { InverseRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { InverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, $0, $0 + 1, out_stride << 1) } }
}

public func DispatchHalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchHalfRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func DispatchHalfInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafeMutablePointer<Complex>, tp_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in DispatchHalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1) } }
}
public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, $0, $0 + 1, out_stride << 1) } }
}
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchInverseRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0 + 1, out_stride << 1) }
}
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, $0, $0 + 1, out_stride << 1) } }
}

public func ParallelHalfRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { ParallelHalfRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func ParallelHalfInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_interleaved: Bool, temp: UnsafeMutablePointer<Complex>, tp_stride: Int, _ tp_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in ParallelHalfInverseRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_interleaved, output, out_stride, out_interleaved, _temp, _temp + 1, tp_stride << 1, tp_interleaved) } }
}
public func ParallelRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { ParallelRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func ParallelRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { ParallelRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) } }
}
public func ParallelInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { ParallelInverseRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func ParallelInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { ParallelInverseRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) } }
}

public func DispatchParallelHalfRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchParallelHalfRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func DispatchParallelHalfInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_interleaved: Bool, _ temp: UnsafeMutablePointer<Complex>, _ tp_stride: Int, _ tp_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in DispatchParallelHalfInverseRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_interleaved, output, out_stride, out_interleaved, _temp, _temp + 1, tp_stride << 1, tp_interleaved) } }
}
public func DispatchParallelRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchParallelRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func DispatchParallelRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchParallelRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) } }
}
public func DispatchParallelInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchParallelInverseRadix2CooleyTukey(level, row, input, in_stride, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) }
}
public func DispatchParallelInverseRadix2CooleyTukey(_ level: Int, row: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ in_total: Int, _ in_interleaved: Bool, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ out_interleaved: Bool) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchParallelInverseRadix2CooleyTukey(level, row, _input, _input + 1, in_stride << 1, in_count, in_total, in_interleaved, $0, $0 + 1, out_stride << 1, out_interleaved) } }
}

public func Radix2CircularConvolve(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    signal.withMemoryRebound(to: Double.self, capacity: 2) { _signal in kernel.withMemoryRebound(to: Double.self, capacity: 2) { _kernel in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in output.withMemoryRebound(to: Double.self, capacity: 2) { Radix2CircularConvolve(level, _signal, _signal + 1, signal_stride << 1, signal_count, _kernel, _kernel + 1, kernel_stride << 1, kernel_count, $0, $0 + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1) } } } }
}
public func Radix2PowerCircularConvolve(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in output.withMemoryRebound(to: Double.self, capacity: 2) { Radix2PowerCircularConvolve(level, _input, _input + 1, in_stride << 1, in_count, n, $0, $0 + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1) } } }
}

public func DispatchRadix2CircularConvolve(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    signal.withMemoryRebound(to: Double.self, capacity: 2) { _signal in kernel.withMemoryRebound(to: Double.self, capacity: 2) { _kernel in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchRadix2CircularConvolve(level, _signal, _signal + 1, signal_stride << 1, signal_count, _kernel, _kernel + 1, kernel_stride << 1, kernel_count, $0, $0 + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1) } } } }
}
public func DispatchRadix2PowerCircularConvolve(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    input.withMemoryRebound(to: Double.self, capacity: 2) { _input in temp.withMemoryRebound(to: Double.self, capacity: 2) { _temp in output.withMemoryRebound(to: Double.self, capacity: 2) { DispatchRadix2PowerCircularConvolve(level, _input, _input + 1, in_stride << 1, in_count, n, $0, $0 + 1, out_stride << 1, _temp, _temp + 1, temp_stride << 1) } } }
}
