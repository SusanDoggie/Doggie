//
//  SafeFunction.swift
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

@warn_unused_result
public func add<T: IntegerType>(var lhs: [T], _ rhs: [T]) -> [T] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func sub<T: IntegerType>(var lhs: [T], _ rhs: [T]) -> [T] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mul<T: IntegerType>(var lhs: [T], _ rhs: [T]) -> [T] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func div<T: IntegerType>(var lhs: [T], _ rhs: [T]) -> [T] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mod<T: IntegerType>(var lhs: [T], _ rhs: [T]) -> [T] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func add(var lhs: [Float], _ rhs: [Float]) -> [Float] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func sub(var lhs: [Float], _ rhs: [Float]) -> [Float] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mul(var lhs: [Float], _ rhs: [Float]) -> [Float] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func div(var lhs: [Float], _ rhs: [Float]) -> [Float] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mod(var lhs: [Float], _ rhs: [Float]) -> [Float] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mulAdd(var a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func mulSub(var a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func subMul(var a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func add(var lhs: [Double], _ rhs: [Double]) -> [Double] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func sub(var lhs: [Double], _ rhs: [Double]) -> [Double] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mul(var lhs: [Double], _ rhs: [Double]) -> [Double] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func div(var lhs: [Double], _ rhs: [Double]) -> [Double] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mod(var lhs: [Double], _ rhs: [Double]) -> [Double] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mulAdd(var a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func mulSub(var a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func subMul(var a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func dot(a: [Float], _ b: [Float]) -> Float {
    assert(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

@warn_unused_result
public func dot(a: [Double], _ b: [Double]) -> Double {
    assert(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

@warn_unused_result
public func add(var lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func sub(var lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mul(var lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func mulAdd(var a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func mulSub(var a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func subMul(var a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &a, 1)
    return a
}

@warn_unused_result
public func mulConj(var lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    MulConj(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func div(var lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &lhs, 1)
    return lhs
}

@warn_unused_result
public func transpose<T>(row: Int, _ column: Int, var _ data: [T]) -> [T] {
    assert(data.count == row * column, "mismatch count of input.")
    Transpose(row, column, data, 1, &data, 1)
    return data
}

@warn_unused_result
public func MatrixElimination(row: Int, inout _ matrix: [Float]) -> Bool {
    let column = matrix.count / row
    assert(matrix.count % row == 0, "count of matrix is not multiples of row.")
    assert(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(row, column, &matrix, 1, 1)
}

@warn_unused_result
public func MatrixElimination(row: Int, inout _ matrix: [Double]) -> Bool {
    let column = matrix.count / row
    assert(matrix.count % row == 0, "count of matrix is not multiples of row.")
    assert(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(row, column, &matrix, 1, 1)
}

@warn_unused_result
public func Radix2CooleyTukey(var buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    DispatchRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &buffer, 1)
    return buffer
}
@warn_unused_result
public func InverseRadix2CooleyTukey(var buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    DispatchInverseRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &buffer, 1)
    return buffer
}

@warn_unused_result
public func Radix2FiniteImpulseFilter(var signal: [Complex], var _ kernel: [Complex]) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    DispatchRadix2FiniteImpulseFilter(log2(signal.count), signal, 1, kernel, 1, &signal, 1, &kernel, 1)
    return signal
}

@warn_unused_result
public func Radix2CircularConvolve(var signal: [Double], var _ kernel: [Double]) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return zip(signal, kernel).map(*)
    }
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, kernel, 1, &signal, 1, &kernel, 1)
    return signal
}

@warn_unused_result
public func Radix2CircularConvolve(var signal: [Complex], var _ kernel: [Complex]) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return zip(signal, kernel).map(*)
    }
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, kernel, 1, &signal, 1, &kernel, 1)
    return signal
}

@warn_unused_result
public func Radix2PowerCircularConvolve(var signal: [Double], _ n: Double) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return signal.map { pow($0, n) }
    }
    var result = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, n, &result, 1, &signal, 1)
    return result
}

@warn_unused_result
public func Radix2PowerCircularConvolve(var signal: [Complex], _ n: Double) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return signal.map { pow($0, n) }
    }
    var result = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, n, &result, 1, &signal, 1)
    return result
}

@warn_unused_result
public func NumberTheoreticTransform(var buffer: [UInt32]) -> [UInt32] {
    switch buffer.count {
    case 2:
        NumberTheoreticTransform_2(buffer, 1, &buffer, 1)
        return buffer
    case 4:
        NumberTheoreticTransform_4(buffer, 1, &buffer, 1)
        return buffer
    case 8:
        DispatchNumberTheoreticTransform_8(buffer, 1, &buffer, 1)
        return buffer
    case 16:
        DispatchNumberTheoreticTransform_16(buffer, 1, &buffer, 1)
        return buffer
    case 32:
        DispatchNumberTheoreticTransform_32(buffer, 1, &buffer, 1)
        return buffer
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}

@warn_unused_result
public func InverseNumberTheoreticTransform(var buffer: [UInt32]) -> [UInt32] {
    switch buffer.count {
    case 2:
        InverseNumberTheoreticTransform_2(buffer, 1, &buffer, 1)
        return buffer
    case 4:
        InverseNumberTheoreticTransform_4(buffer, 1, &buffer, 1)
        return buffer
    case 8:
        DispatchInverseNumberTheoreticTransform_8(buffer, 1, &buffer, 1)
        return buffer
    case 16:
        DispatchInverseNumberTheoreticTransform_16(buffer, 1, &buffer, 1)
        return buffer
    case 32:
        DispatchInverseNumberTheoreticTransform_32(buffer, 1, &buffer, 1)
        return buffer
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}

@warn_unused_result
public func Radix2CircularConvolve(var signal: [UInt32], var _ kernel: [UInt32]) -> [UInt32] {
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    switch signal.count {
    case 2:
        Radix2CircularConvolve_2(signal, 1, kernel, 1, &signal, 1, &kernel, 1)
        return signal
    case 4:
        Radix2CircularConvolve_4(signal, 1, kernel, 1, &signal, 1, &kernel, 1)
        return signal
    case 8:
        DispatchRadix2CircularConvolve_8(signal, 1, kernel, 1, &signal, 1, &kernel, 1)
        return signal
    case 16:
        DispatchRadix2CircularConvolve_16(signal, 1, kernel, 1, &signal, 1, &kernel, 1)
        return signal
    case 32:
        DispatchRadix2CircularConvolve_32(signal, 1, kernel, 1, &signal, 1, &kernel, 1)
        return signal
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}
