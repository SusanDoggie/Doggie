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
@_transparent
public func addmod<T: UnsignedIntegerType>(lhs: [T], _ rhs: [T], _ mod: T) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    AddMod(lhs.count, lhs, 1, rhs, 1, [mod], 0, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func addmod<T: UnsignedIntegerType>(lhs: [T], _ rhs: [T], _ mod: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    assert(lhs.count == mod.count, "mismatch count of inputs.")
    AddMod(lhs.count, lhs, 1, rhs, 1, mod, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulmod<T: UnsignedIntegerType>(lhs: [T], _ rhs: [T], _ mod: T) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    MulMod(lhs.count, lhs, 1, rhs, 1, [mod], 0, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulmod<T: UnsignedIntegerType>(lhs: [T], _ rhs: [T], _ mod: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    assert(lhs.count == mod.count, "mismatch count of inputs.")
    MulMod(lhs.count, lhs, 1, rhs, 1, mod, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func add<T: IntegerType>(lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func sub<T: IntegerType>(lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mul<T: IntegerType>(lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func div<T: IntegerType>(lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mod<T: IntegerType>(lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func add(lhs: [Float], _ rhs: [Float]) -> [Float] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func sub(lhs: [Float], _ rhs: [Float]) -> [Float] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mul(lhs: [Float], _ rhs: [Float]) -> [Float] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func div(lhs: [Float], _ rhs: [Float]) -> [Float] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mod(lhs: [Float], _ rhs: [Float]) -> [Float] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulAdd(a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulSub(a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func subMul(a: [Float], _ b: [Float], _ c: [Float]) -> [Float] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func add(lhs: [Double], _ rhs: [Double]) -> [Double] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func sub(lhs: [Double], _ rhs: [Double]) -> [Double] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mul(lhs: [Double], _ rhs: [Double]) -> [Double] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func div(lhs: [Double], _ rhs: [Double]) -> [Double] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mod(lhs: [Double], _ rhs: [Double]) -> [Double] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulAdd(a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulSub(a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func subMul(a: [Double], _ b: [Double], _ c: [Double]) -> [Double] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func dot(a: [Float], _ b: [Float]) -> Float {
    assert(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

@warn_unused_result
@_transparent
public func dot(a: [Double], _ b: [Double]) -> Double {
    assert(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

@warn_unused_result
@_transparent
public func add(lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func sub(lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mul(lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulAdd(a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulSub(a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func subMul(a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func mulConj(lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    MulConj(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func div(lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func transpose<T>(row: Int, _ column: Int,  _ data: [T]) -> [T] {
    var result = data
    assert(data.count == row * column, "mismatch count of input.")
    Transpose(row, column, data, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func MatrixElimination(row: Int, inout _ matrix: [Float]) -> Bool {
    let column = matrix.count / row
    assert(matrix.count % row == 0, "count of matrix is not multiples of row.")
    assert(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(row, column, &matrix, 1, 1)
}

@warn_unused_result
@_transparent
public func MatrixElimination(row: Int, inout _ matrix: [Double]) -> Bool {
    let column = matrix.count / row
    assert(matrix.count % row == 0, "count of matrix is not multiples of row.")
    assert(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(row, column, &matrix, 1, 1)
}

@warn_unused_result
@_transparent
public func Radix2CooleyTukey(buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &result, 1)
    return result
}
@warn_unused_result
@_transparent
public func InverseRadix2CooleyTukey(buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchInverseRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &result, 1)
    return result
}

@warn_unused_result
@_transparent
public func Radix2FiniteImpulseFilter(signal: [Complex],  _ kernel: [Complex]) -> [Complex] {
    var result = signal
    var temp = signal
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    DispatchRadix2FiniteImpulseFilter(log2(signal.count), signal, 1, kernel, 1, &result, 1, &temp, 1)
    return result
}

@warn_unused_result
@_transparent
public func Radix2CircularConvolve(signal: [Double],  _ kernel: [Double]) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, kernel, 1, &result, 1, &temp, 1)
    return result
}

@warn_unused_result
@_transparent
public func Radix2CircularConvolve(signal: [Complex],  _ kernel: [Complex]) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, kernel, 1, &result, 1, &temp, 1)
    return result
}

@warn_unused_result
@_transparent
public func Radix2PowerCircularConvolve(signal: [Double], _ n: Double) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [pow(signal[0], n)]
    }
    var result = signal
    var temp = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, n, &result, 1, &temp, 1)
    return result
}

@warn_unused_result
@_transparent
public func Radix2PowerCircularConvolve(signal: [Complex], _ n: Double) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [pow(signal[0], n)]
    }
    var result = signal
    var temp = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, n, &result, 1, &temp, 1)
    return result
}

@warn_unused_result
@_transparent
public func NumberTheoreticTransform(buffer: [UInt32]) -> [UInt32] {
    var result = buffer
    switch buffer.count {
    case 2:
        NumberTheoreticTransform_2(buffer, 1, &result, 1)
        return result
    case 4:
        NumberTheoreticTransform_4(buffer, 1, &result, 1)
        return result
    case 8:
        DispatchNumberTheoreticTransform_8(buffer, 1, &result, 1)
        return result
    case 16:
        DispatchNumberTheoreticTransform_16(buffer, 1, &result, 1)
        return result
    case 32:
        DispatchNumberTheoreticTransform_32(buffer, 1, &result, 1)
        return result
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}

@warn_unused_result
@_transparent
public func InverseNumberTheoreticTransform(buffer: [UInt32]) -> [UInt32] {
    var result = buffer
    switch buffer.count {
    case 2:
        InverseNumberTheoreticTransform_2(buffer, 1, &result, 1)
        return result
    case 4:
        InverseNumberTheoreticTransform_4(buffer, 1, &result, 1)
        return result
    case 8:
        DispatchInverseNumberTheoreticTransform_8(buffer, 1, &result, 1)
        return result
    case 16:
        DispatchInverseNumberTheoreticTransform_16(buffer, 1, &result, 1)
        return result
    case 32:
        DispatchInverseNumberTheoreticTransform_32(buffer, 1, &result, 1)
        return result
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}

@warn_unused_result
@_transparent
public func Radix2CircularConvolve(signal: [UInt32],  _ kernel: [UInt32]) -> [UInt32] {
    var result = signal
    var temp = signal
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    switch signal.count {
    case 2:
        Radix2CircularConvolve_2(signal, 1, kernel, 1, &result, 1, &temp, 1)
        return result
    case 4:
        Radix2CircularConvolve_4(signal, 1, kernel, 1, &result, 1, &temp, 1)
        return result
    case 8:
        DispatchRadix2CircularConvolve_8(signal, 1, kernel, 1, &result, 1, &temp, 1)
        return result
    case 16:
        DispatchRadix2CircularConvolve_16(signal, 1, kernel, 1, &result, 1, &temp, 1)
        return result
    case 32:
        DispatchRadix2CircularConvolve_32(signal, 1, kernel, 1, &result, 1, &temp, 1)
        return result
    default:
        fatalError("size of buffer must be 2, 4, 8, 16 or 32.")
    }
}
