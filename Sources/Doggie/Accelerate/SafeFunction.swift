//
//  SafeFunction.swift
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

import Foundation

public func addmod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: T) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    AddMod(lhs.count, lhs, 1, rhs, 1, [mod], 0, &result, 1)
    return result
}

public func addmod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    assert(lhs.count == mod.count, "mismatch count of inputs.")
    AddMod(lhs.count, lhs, 1, rhs, 1, mod, 1, &result, 1)
    return result
}
public func negmod<T: UnsignedInteger>(_ a: [T], _ mod: T) -> [T] {
    var result = a
    NegMod(a.count, a, 1, [mod], 0, &result, 1)
    return result
}

public func negmod<T: UnsignedInteger>(_ a: [T], _ mod: [T]) -> [T] {
    var result = a
    assert(a.count == mod.count, "mismatch count of inputs.")
    NegMod(a.count, a, 1, mod, 1, &result, 1)
    return result
}
public func submod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: T) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    SubMod(lhs.count, lhs, 1, rhs, 1, [mod], 0, &result, 1)
    return result
}

public func submod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    assert(lhs.count == mod.count, "mismatch count of inputs.")
    SubMod(lhs.count, lhs, 1, rhs, 1, mod, 1, &result, 1)
    return result
}

public func mulmod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: T) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    MulMod(lhs.count, lhs, 1, rhs, 1, [mod], 0, &result, 1)
    return result
}

public func mulmod<T: UnsignedInteger>(_ lhs: [T], _ rhs: [T], _ mod: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    assert(lhs.count == mod.count, "mismatch count of inputs.")
    MulMod(lhs.count, lhs, 1, rhs, 1, mod, 1, &result, 1)
    return result
}

public func add<T: Integer>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func sub<T: Integer>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mul<T: Integer>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func div<T: Integer>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mod<T: Integer>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func add<T: FloatingPoint>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func sub<T: FloatingPoint>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mul<T: FloatingPoint>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func div<T: FloatingPoint>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mod<T: FloatingPoint>(_ lhs: [T], _ rhs: [T]) -> [T] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mod(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mulAdd<T: FloatingPoint>(_ a: [T], _ b: [T], _ c: [T]) -> [T] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func mulSub<T: FloatingPoint>(_ a: [T], _ b: [T], _ c: [T]) -> [T] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func subMul<T: FloatingPoint>(_ a: [T], _ b: [T], _ c: [T]) -> [T] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func dot<T: FloatingPoint>(_ a: [T], _ b: [T]) -> T {
    assert(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

public func add(_ lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Add(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func sub(_ lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Sub(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mul(_ lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Mul(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func mulAdd(_ a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulAdd(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func mulSub(_ a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    MulSub(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func subMul(_ a: [Complex], _ b: [Complex], _ c: [Complex]) -> [Complex] {
    var result = a
    assert(a.count == b.count && a.count == c.count, "mismatch count of inputs.")
    SubMul(a.count, a, 1, b, 1, c, 1, &result, 1)
    return result
}

public func mulConj(_ lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    MulConj(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func div(_ lhs: [Complex], _ rhs: [Complex]) -> [Complex] {
    var result = lhs
    assert(lhs.count == rhs.count, "mismatch count of inputs.")
    Div(lhs.count, lhs, 1, rhs, 1, &result, 1)
    return result
}

public func transpose<T>(_ row: Int, _ column: Int, _ data: [T]) -> [T] {
    var result = data
    assert(data.count == row * column, "mismatch count of input.")
    Transpose(row, column, data, 1, &result, 1)
    return result
}

public func MatrixElimination<T: FloatingPoint>(_ row: Int, _ matrix: inout [T]) -> Bool {
    let column = matrix.count / row
    assert(matrix.count % row == 0, "count of matrix is not multiples of row.")
    assert(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(row, column, &matrix, 1, 1)
}

public func Radix2CooleyTukey(_ buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, buffer.count, &result, 1)
    return result
}
public func InverseRadix2CooleyTukey(_ buffer: [Complex]) -> [Complex] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchInverseRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, buffer.count, &result, 1)
    return result
}

public func Radix2FiniteImpulseFilter(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = signal
    var temp = signal
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    DispatchRadix2FiniteImpulseFilter(log2(signal.count), signal, 1, signal.count, kernel, 1, &result, 1, &temp, 1)
    return result
}

public func Radix2CircularConvolve(_ signal: [Double], _ kernel: [Double]) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
    return result
}

public func Radix2CircularConvolve(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
    return result
}

public func Radix2PowerCircularConvolve(_ signal: [Double], _ n: Double) -> [Double] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [pow(signal[0], n)]
    }
    var result = signal
    var temp = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, signal.count, n, &result, 1, &temp, 1)
    return result
}

public func Radix2PowerCircularConvolve(_ signal: [Complex], _ n: Double) -> [Complex] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [pow(signal[0], n)]
    }
    var result = signal
    var temp = signal
    DispatchRadix2PowerCircularConvolve(log2(signal.count), signal, 1, signal.count, n, &result, 1, &temp, 1)
    return result
}

public func Radix2CooleyTukey<U: UnsignedInteger>(_ buffer: [U], _ alpha: U, _ mod: U) -> [U] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchRadix2CooleyTukey(log2(buffer.count), buffer, 1, buffer.count, alpha, mod, &result, 1)
    return result
}
public func InverseRadix2CooleyTukey<U: UnsignedInteger>(_ buffer: [U], _ alpha: U, _ mod: U) -> [U] {
    assert(buffer.count.isPower2, "size of buffer must be power of 2.")
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer
    DispatchInverseRadix2CooleyTukey(log2(buffer.count), buffer, 1, buffer.count, alpha, mod, &result, 1)
    return result
}
public func Radix2CircularConvolve<U: UnsignedInteger>(_ signal: [U], _ kernel: [U], _ alpha: U, _ mod: U) -> [U] {
    assert(signal.count.isPower2, "size of signal must be power of 2.")
    assert(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    DispatchRadix2CircularConvolve(log2(signal.count), signal, 1, signal.count, kernel, 1, kernel.count, alpha, mod, &result, 1, &temp, 1)
    return result
}
