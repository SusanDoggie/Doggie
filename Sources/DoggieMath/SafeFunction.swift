//
//  SafeFunction.swift
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
@inline(__always)
public func dot<T: FloatingPoint>(_ a: [T], _ b: [T]) -> T {
    precondition(a.count == b.count, "mismatch count of inputs.")
    return Dot(a.count, a, 1, b, 1)
}

@inlinable
@inline(__always)
public func transpose<T>(_ column: Int, _ row: Int, _ data: [T]) -> [T] {
    var result = data
    precondition(data.count == row * column, "mismatch count of input.")
    Transpose(column, row, data, 1, &result, 1)
    return result
}

@inlinable
@inline(__always)
public func MatrixElimination<T: FloatingPoint>(_ row: Int, _ matrix: inout [T]) -> Bool {
    let column = matrix.count / row
    precondition(matrix.count % row == 0, "count of matrix is not multiples of row.")
    precondition(column > row, "count of column of matrix is less than or equal to row.")
    return MatrixElimination(column, row, &matrix, 1, 1)
}

@inlinable
@inline(__always)
public func Radix2CooleyTukey(_ buffer: [Complex]) -> [Complex] {
    precondition(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer.map { $0 / _sqrt }
    Radix2CooleyTukey(log2(buffer.count), &result, 1)
    return result
}
@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey(_ buffer: [Complex]) -> [Complex] {
    precondition(buffer.count.isPower2, "size of buffer must be power of 2.")
    let _sqrt = sqrt(Double(buffer.count))
    if buffer.count == 1 {
        return buffer
    }
    var result = buffer.map { $0 / _sqrt }
    InverseRadix2CooleyTukey(log2(buffer.count), &result, 1)
    return result
}

@inlinable
@inline(__always)
public func Radix2FiniteImpulseFilter(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = signal
    precondition(signal.count.isPower2, "size of signal must be power of 2.")
    precondition(signal.count == kernel.count, "mismatch count of inputs.")
    Radix2FiniteImpulseFilter(log2(signal.count), signal, 1, signal.count, kernel, 1, &result, 1)
    return result
}

@inlinable
@inline(__always)
public func Radix2CircularConvolve<T: BinaryFloatingPoint>(_ signal: [T], _ kernel: [T]) -> [T] where T: ElementaryFunctions {
    precondition(signal.count.isPower2, "size of signal must be power of 2.")
    precondition(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    Radix2CircularConvolve(log2(signal.count), signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
    return result
}

@inlinable
@inline(__always)
public func Radix2CircularConvolve(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    precondition(signal.count.isPower2, "size of signal must be power of 2.")
    precondition(signal.count == kernel.count, "mismatch count of inputs.")
    if signal.count == 1 {
        return [signal[0] * kernel[0]]
    }
    var result = signal
    var temp = signal
    Radix2CircularConvolve(log2(signal.count), signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
    return result
}

@inlinable
@inline(__always)
public func Radix2PowerCircularConvolve<T: BinaryFloatingPoint>(_ signal: [T], _ n: T) -> [T] where T: RealFunctions {
    precondition(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [T.pow(signal[0], n)]
    }
    var result = signal
    Radix2PowerCircularConvolve(log2(signal.count), signal, 1, signal.count, n, &result, 1)
    return result
}

@inlinable
@inline(__always)
public func Radix2PowerCircularConvolve(_ signal: [Complex], _ n: Double) -> [Complex] {
    precondition(signal.count.isPower2, "size of signal must be power of 2.")
    if signal.count == 1 {
        return [pow(signal[0], n)]
    }
    var result = signal
    Radix2PowerCircularConvolve(log2(signal.count), signal, 1, signal.count, n, &result, 1)
    return result
}

