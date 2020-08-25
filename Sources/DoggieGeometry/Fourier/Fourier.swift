//
//  Fourier.swift
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

// MARK: Fourier

@inlinable
public func Fourier(_ buffer: [Double], _ result: inout [Complex]) {
    switch buffer.count {
    case 0:
        result = [Complex]()
    case 1:
        result = [Complex(buffer[0])]
    case 2:
        let first = buffer[0] * sqrt(0.5)
        let second = buffer[1] * sqrt(0.5)
        result = [Complex(first + second), Complex(first - second)]
    default:
        if buffer.count.isPower2 {
            Radix2CooleyTukey(buffer, &result)
        } else {
            Bluestein(buffer, &result)
        }
    }
}
@inlinable
public func Fourier(_ buffer: [Complex], _ result: inout [Complex]) {
    switch buffer.count {
    case 0, 1:
        result = buffer
    case 2:
        let first = buffer[0] * sqrt(0.5)
        let second = buffer[1] * sqrt(0.5)
        result = [first + second, first - second]
    default:
        if buffer.count.isPower2 {
            result = Radix2CooleyTukey(buffer)
        } else {
            Bluestein(buffer, &result)
        }
    }
}
@inlinable
public func InverseFourier(_ buffer: [Double], _ result: inout [Complex]) {
    switch buffer.count {
    case 0:
        result = [Complex]()
    case 1:
        result = [Complex(buffer[0])]
    case 2:
        let first = buffer[0] * sqrt(0.5)
        let second = buffer[1] * sqrt(0.5)
        result = [Complex(first + second), Complex(first - second)]
    default:
        if buffer.count.isPower2 {
            InverseRadix2CooleyTukey(buffer, &result)
        } else {
            InverseBluestein(buffer, &result)
        }
    }
}
@inlinable
public func InverseFourier(_ buffer: [Complex], _ result: inout [Complex]) {
    switch buffer.count {
    case 0, 1:
        result = buffer
    case 2:
        let first = buffer[0] * sqrt(0.5)
        let second = buffer[1] * sqrt(0.5)
        result = [first + second, first - second]
    default:
        if buffer.count.isPower2 {
            result = InverseRadix2CooleyTukey(buffer)
        } else {
            InverseBluestein(buffer, &result)
        }
    }
}
@inlinable
public func BluesteinKernel(_ count: Int, _ kernel: inout [Complex]) {
    
    if kernel.count != count {
        kernel.replace(with: repeatElement(Complex(0), count: count))
    }
    kernel[0].real = 1
    kernel[0].imag = 0
    
    let angle = .pi / Double(count)
    var twiddle = cis(angle)
    let twiddleBasis = twiddle * twiddle
    var twiddle2 = twiddle
    for i in 1..<count {
        kernel[i] = twiddle2
        let _r = twiddle.real * twiddleBasis.real - twiddle.imag * twiddleBasis.imag
        let _i = twiddle.real * twiddleBasis.imag + twiddle.imag * twiddleBasis.real
        twiddle.real = _r
        twiddle.imag = _i
        let _r2 = twiddle.real * twiddle2.real - twiddle.imag * twiddle2.imag
        let _i2 = twiddle.real * twiddle2.imag + twiddle.imag * twiddle2.real
        twiddle2.real = _r2
        twiddle2.imag = _i2
    }
}
@inlinable
public func InverseBluesteinKernel(_ count: Int, _ kernel: inout [Complex]) {
    
    if kernel.count != count {
        kernel.replace(with: repeatElement(Complex(0), count: count))
    }
    kernel[0].real = 1
    kernel[0].imag = 0
    
    let angle = -.pi / Double(count)
    var twiddle = cis(angle)
    let twiddleBasis = twiddle * twiddle
    var twiddle2 = twiddle
    for i in 1..<count {
        kernel[i] = twiddle2
        let _r = twiddle.real * twiddleBasis.real - twiddle.imag * twiddleBasis.imag
        let _i = twiddle.real * twiddleBasis.imag + twiddle.imag * twiddleBasis.real
        twiddle.real = _r
        twiddle.imag = _i
        let _r2 = twiddle.real * twiddle2.real - twiddle.imag * twiddle2.imag
        let _i2 = twiddle.real * twiddle2.imag + twiddle.imag * twiddle2.real
        twiddle2.real = _r2
        twiddle2.imag = _i2
    }
}
@inlinable
public func Bluestein(_ buffer: [Double], _ result: inout [Complex]) {
    var _kernel: [Complex] = []
    BluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    vec_op(buffer.count, _kernel, 1, buffer, 1, &result, 1) { conj($0) * $1 }
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    vec_op(buffer.count, _kernel, 1, result, 1, &result, 1) { conj($0) * $1 }
    let _sqrt = 1 / sqrt(Double(buffer.count))
    vec_op(buffer.count, result, 1, &result, 1) { $0 * _sqrt }
}
@inlinable
public func Bluestein(_ buffer: [Complex], _ result: inout [Complex]) {
    var _kernel: [Complex] = []
    BluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    vec_op(buffer.count, _kernel, 1, buffer, 1, &result, 1) { conj($0) * $1 }
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    vec_op(buffer.count, _kernel, 1, result, 1, &result, 1) { conj($0) * $1 }
    let _sqrt = 1 / sqrt(Double(buffer.count))
    vec_op(buffer.count, result, 1, &result, 1) { $0 * _sqrt }
}
@inlinable
public func InverseBluestein(_ buffer: [Double], _ result: inout [Complex]) {
    var _kernel: [Complex] = []
    InverseBluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    vec_op(buffer.count, _kernel, 1, buffer, 1, &result, 1) { conj($0) * $1 }
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    vec_op(buffer.count, _kernel, 1, result, 1, &result, 1) { conj($0) * $1 }
    let _sqrt = 1 / sqrt(Double(buffer.count))
    vec_op(buffer.count, result, 1, &result, 1) { $0 * _sqrt }
}
@inlinable
public func InverseBluestein(_ buffer: [Complex], _ result: inout [Complex]) {
    var _kernel: [Complex] = []
    InverseBluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    vec_op(buffer.count, _kernel, 1, buffer, 1, &result, 1) { conj($0) * $1 }
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    vec_op(buffer.count, _kernel, 1, result, 1, &result, 1) { conj($0) * $1 }
    let _sqrt = 1 / sqrt(Double(buffer.count))
    vec_op(buffer.count, result, 1, &result, 1) { $0 * _sqrt }
}

// MARK: Radix-2 Cooley-Tukey

@inlinable
public func Radix2CooleyTukey(_ buffer: [Double], _ result: inout [Complex]) {
    switch buffer.count {
    case 0:
        result = []
    case 1:
        result = [Complex(buffer[0])]
    default:
        precondition(buffer.count.isPower2, "size of buffer must be power of 2.")
        if result.count != buffer.count {
            result.replace(with: repeatElement(Complex(0), count: buffer.count))
        }
        let _sqrt = sqrt(Double(buffer.count))
        Radix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, buffer.count, &result, 1)
    }
}
@inlinable
public func InverseRadix2CooleyTukey(_ buffer: [Double], _ result: inout [Complex]) {
    switch buffer.count {
    case 0:
        result = []
    case 1:
        result = [Complex(buffer[0])]
    default:
        precondition(buffer.count.isPower2, "size of buffer must be power of 2.")
        if result.count != buffer.count {
            result.replace(with: repeatElement(Complex(0), count: buffer.count))
        }
        let _sqrt = sqrt(Double(buffer.count))
        InverseRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, buffer.count, &result, 1)
    }
}

// MARK: Convolution

@inlinable
public func Convolve(_ signal: [Double], _ kernel: [Double], _ result: inout [Double]) {
    FFTConvolve(signal, kernel, &result)
}
@inlinable
public func Convolve(_ signal: [Complex], _ kernel: [Complex], _ result: inout [Complex]) {
    FFTConvolve(signal, kernel, &result)
}
@inlinable
public func CircularConvolve(_ signal: [Double], _ kernel: [Double], _ result: inout [Double]) {
    if signal.isEmpty || kernel.isEmpty {
        result.removeAll(keepingCapacity: true)
    }
    if signal.count >= kernel.count && signal.count.isPower2 {
        
        var temp = [Double](repeating: 0, count: signal.count)
        
        if result.count != signal.count {
            result.replace(with: repeatElement(0, count: signal.count))
        }
        
        let lv = log2(signal.count)
        
        if signal.count == kernel.count {
            Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
        } else {
            Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
        }
        
    } else {
        Convolve(signal, kernel, &result)
        let block = signal.count
        let count = result.count / block
        for idx in 1..<count {
            result.withUnsafeMutableBufferPointer { vec_op(block, $0.baseAddress!, 1, $0.baseAddress! + idx * block, 1, $0.baseAddress!, 1) { $0 + $1 } }
        }
        result.withUnsafeMutableBufferPointer { vec_op($0.count % block, $0.baseAddress!, 1, $0.baseAddress! + count * block, 1, $0.baseAddress!, 1) { $0 + $1 } }
        result.removeSubrange(block..<result.count)
    }
}
@inlinable
public func CircularConvolve(_ signal: [Complex], _ kernel: [Complex], _ result: inout [Complex]) {
    if signal.isEmpty || kernel.isEmpty {
        result.removeAll(keepingCapacity: true)
    }
    if signal.count >= kernel.count && signal.count.isPower2 {
        
        var temp = [Complex](repeating: Complex(0), count: signal.count)
        
        if result.count != signal.count {
            result.replace(with: repeatElement(Complex(0), count: signal.count))
        }
        
        let lv = log2(signal.count)
        
        if signal.count == kernel.count {
            Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
        } else {
            Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, &result, 1, &temp, 1)
        }
        
    } else {
        Convolve(signal, kernel, &result)
        let block = signal.count
        let count = result.count / block
        for idx in 1..<count {
            result.withUnsafeMutableBufferPointer { vec_op(block, $0.baseAddress!, 1, $0.baseAddress! + idx * block, 1, $0.baseAddress!, 1) { $0 + $1 } }
        }
        result.withUnsafeMutableBufferPointer { vec_op($0.count % block, $0.baseAddress!, 1, $0.baseAddress! + count * block, 1, $0.baseAddress!, 1) { $0 + $1 } }
        result.removeSubrange(block..<result.count)
    }
}
@inlinable
public func NegacyclicConvolve(_ signal: [Double], _ kernel: [Double], _ result: inout [Double]) {
    Convolve(signal, kernel, &result)
    let count = signal.count
    for idx in 0..<kernel.count - 1 {
        result[idx] -= result[idx + count]
    }
    result.removeSubrange(signal.count..<result.count)
}
@inlinable
public func NegacyclicConvolve(_ signal: [Complex], _ kernel: [Complex], _ result: inout [Complex]) {
    Convolve(signal, kernel, &result)
    let count = signal.count
    for idx in 0..<kernel.count - 1 {
        result[idx].real -= result[idx + count].real
        result[idx].imag -= result[idx + count].imag
    }
    result.removeSubrange(signal.count..<result.count)
}

@inlinable
public func FFTConvolve(_ signal: [Double], _ kernel: [Double], _ result: inout [Double]) {
    
    let convolve_length = signal.count + kernel.count - 1
    let fft_length = Radix2CircularConvolveLength(signal.count, kernel.count)
    let lv = log2(fft_length)
    
    var buffer = [Double](repeating: 0, count: fft_length << 1)
    buffer.withUnsafeMutableBufferPointer { _buffer in
        let _output = _buffer.baseAddress!
        let _temp = _output + fft_length
        Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, _output, 1, _temp, 1)
    }
    
    result.replace(with: buffer.prefix(convolve_length))
}
@inlinable
public func FFTConvolve(_ signal: [Complex], _ kernel: [Complex], _ result: inout [Complex]) {
    
    let convolve_length = signal.count + kernel.count - 1
    let fft_length = Radix2CircularConvolveLength(signal.count, kernel.count)
    let lv = log2(fft_length)
    
    var buffer = [Complex](repeating: Complex(0), count: fft_length << 1)
    buffer.withUnsafeMutableBufferPointer { _buffer in
        let _output = _buffer.baseAddress!
        let _temp = _output + fft_length
        Radix2CircularConvolve(lv, signal, 1, signal.count, kernel, 1, kernel.count, _output, 1, _temp, 1)
    }
    
    result.replace(with: buffer.prefix(convolve_length))
}
@inlinable
public func OverlapConvolve(signal: [Double], kernel: [Double], _ overlap: inout [Double], _ result: inout [Double]) {
    FFTConvolve(signal, kernel, &result)
    let count = min(result.count, overlap.count)
    vec_op(count, result, 1, overlap, 1, &result, 1) { $0 + $1 }
    overlap.replaceSubrange(0..<count, with: result[signal.count..<result.count])
    result.removeSubrange(signal.count..<result.count)
}
@inlinable
public func OverlapConvolve(signal: [Complex], kernel: [Complex], _ overlap: inout [Complex], _ result: inout [Complex]) {
    FFTConvolve(signal, kernel, &result)
    let count = min(result.count, overlap.count)
    vec_op(count, result, 1, overlap, 1, &result, 1) { $0 + $1 }
    overlap.replaceSubrange(0..<count, with: result[signal.count..<result.count])
    result.removeSubrange(signal.count..<result.count)
}

// MARK: Discrete function

@inlinable
public func DiscreteFourier(_ buffer: [Double], _ result: inout [Complex]) {
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    let angle: Double = -2 * .pi / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += Complex(magnitude: buffer[i], phase: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
@inlinable
public func DiscreteFourier(_ buffer: [Complex], _ result: inout [Complex]) {
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    let angle: Double = -2 * .pi / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += buffer[i] * Complex(magnitude: 1, phase: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
@inlinable
public func InverseDiscreteFourier(_ buffer: [Double], _ result: inout [Complex]) {
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    let angle: Double = 2 * .pi / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += Complex(magnitude: buffer[i], phase: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
@inlinable
public func InverseDiscreteFourier(_ buffer: [Complex], _ result: inout [Complex]) {
    if result.count != buffer.count {
        result.replace(with: repeatElement(Complex(0), count: buffer.count))
    }
    let angle: Double = 2 * .pi / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += buffer[i] * Complex(magnitude: 1, phase: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
@inlinable
public func DirectConvolve(_ signal: [Double], _ kernel: [Double], _ result: inout [Double]) {
    let size = signal.count + kernel.count - 1
    if result.count != size {
        result.replace(with: repeatElement(0, count: size))
    }
    DirectConvolve(signal.count, signal, 1, kernel.count, kernel, 1, &result, 1)
}
@inlinable
public func DirectConvolve(_ signal: [Complex], _ kernel: [Complex], _ result: inout [Complex]) {
    let size = signal.count + kernel.count - 1
    if result.count != size {
        result.replace(with: repeatElement(Complex(0), count: size))
    }
    DirectConvolve(signal.count, signal, 1, kernel.count, kernel, 1, &result, 1)
}

// MARK: Other Transform

@inlinable
public func DCTII(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        temp[i] = buffer[i << 1]
        temp[N - i - 1] = buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = buffer[N - 1]
    }
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    result = [Double](repeating: 0, count: N)
    result[0] = _temp[0].real
    let _angle = -0.5 * .pi / Double(N)
    for i in 1..<N {
        result[i] = (_temp[i] * Complex(magnitude: sqrt(2), phase: _angle * Double(i))).real
    }
}
@inlinable
public func DCTIII(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Complex](repeating: Complex(0), count: N)
    temp[0] = Complex(buffer[0])
    let _angle = -0.5 * .pi / Double(N)
    for i in 1..<N {
        temp[i] = buffer[i] * Complex(magnitude: sqrt(2), phase: _angle * Double(i))
    }
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    result = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        result[i << 1] = _temp[i].real
        result[(i << 1) + 1] = _temp[N - i - 1].real
    }
    if N & 1 == 1 {
        result[N - 1] = _temp[N >> 1].real
    }
}
@inlinable
public func DCTIV(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        temp[i] = buffer[i << 1]
        temp[N - i - 1] = -buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = buffer[N - 1]
    }
    var _temp = [Complex](repeating: Complex(0), count: N)
    _temp[0] = Complex(temp[0])
    let _angle = -.pi / Double(N)
    for i in 1..<N {
        _temp[i] = Complex(magnitude: temp[i], phase: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](repeating: 0, count: N)
    let _angle2 = -0.25 * .pi / Double(N)
    for i in 0..<N {
        result[i] = (_temp[i] * Complex(magnitude: sqrt(2), phase: _angle2 * Double((i << 1) + 1))).real
    }
}
@inlinable
public func DSTII(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        temp[i] = -buffer[i << 1]
        temp[N - i - 1] = buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = -buffer[N - 1]
    }
    var _temp = [Complex](repeating: Complex(0), count: N)
    _temp[0] = Complex(temp[0])
    let _angle: Double = -2 * .pi / Double(N)
    for i in 1..<N {
        _temp[i] = Complex(magnitude: temp[i], phase: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](repeating: 0, count: N)
    let _angle2 = -0.5 * .pi / Double(N)
    for i in 0..<N - 1 {
        result[i] = (_temp[i] * Complex(magnitude: sqrt(2), phase: _angle2 * Double(i + 1))).imag
    }
    result[N - 1] = (_temp[N - 1] * Complex(magnitude: 1, phase: -0.5 * .pi)).imag
}
@inlinable
public func DSTIII(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Complex](repeating: Complex(0), count: N)
    temp[0] = Complex(buffer[0])
    let _angle = -0.5 * .pi / Double(N)
    for i in 0..<N - 1 {
        temp[i] = Complex(magnitude: buffer[i] * sqrt(2), phase: _angle * Double(i + 1))
    }
    temp[N - 1] = Complex(magnitude: buffer[N - 1], phase: -0.5 * .pi)
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    let _angle2: Double = -2 * .pi / Double(N)
    for i in 1..<N {
        _temp[i] *= Complex(magnitude: 1, phase: _angle2 * Double(i))
    }
    result = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        result[i << 1] = -_temp[i].imag
        result[(i << 1) + 1] = _temp[N - i - 1].imag
    }
    if N & 1 == 1 {
        result[N - 1] = -_temp[N >> 1].imag
    }
}
@inlinable
public func DSTIV(_ buffer: [Double], _ result: inout [Double]) {
    let N = buffer.count
    var temp = [Double](repeating: 0, count: N)
    for i in 0..<N >> 1 {
        temp[i] = -buffer[i << 1]
        temp[N - i - 1] = -buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = -buffer[N - 1]
    }
    var _temp = [Complex](repeating: Complex(0), count: N)
    _temp[0] = Complex(temp[0])
    let _angle = -.pi / Double(N)
    for i in 1..<N {
        _temp[i] = Complex(magnitude: temp[i], phase: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](repeating: 0, count: N)
    let _angle2 = -0.25 * .pi / Double(N)
    for i in 0..<N {
        result[i] = (_temp[i] * Complex(magnitude: sqrt(2), phase: _angle2 * Double((i << 1) + 1))).imag
    }
}

// MARK: Signal Processing

@inlinable
public func Resampling(_ count: Int, _ buffer: inout [Double]) {
    var _freq = Fourier(buffer)
    if count > _freq.count {
        let half = _freq.count >> 1
        if _freq.count & 1 == 0 {
            _freq[0..<half].append(_freq[half])
        }
        if count > _freq.count {
            _freq[0...half].append(contentsOf: repeatElement(Complex(0), count: count - _freq.count))
        }
    } else if count < _freq.count {
        let half = count >> 1
        let start = half + 1
        let end = _freq.count - half
        if count & 1 == 0 {
            _freq.removeSubrange(start...end)
        } else {
            _freq.removeSubrange(start..<end)
        }
    }
    InverseFourier(_freq, &_freq)
    let _count = buffer.count
    buffer.replace(with: _freq.lazy.map { $0.real * sqrt(Double(_freq.count) / Double(_count)) })
}

// MARK: Wrapper Function


@inlinable
public func DiscreteFourier(_ buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    DiscreteFourier(buffer, &result)
    return result
}
@inlinable
public func DiscreteFourier(_ buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    DiscreteFourier(buffer, &result)
    return result
}
@inlinable
public func InverseDiscreteFourier(_ buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    InverseDiscreteFourier(buffer, &result)
    return result
}
@inlinable
public func InverseDiscreteFourier(_ buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    InverseDiscreteFourier(buffer, &result)
    return result
}
@inlinable
public func Fourier(_ buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    Fourier(buffer, &result)
    return result
}
@inlinable
public func Fourier(_ buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    Fourier(buffer, &result)
    return result
}
@inlinable
public func InverseFourier(_ buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    InverseFourier(buffer, &result)
    return result
}
@inlinable
public func InverseFourier(_ buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    InverseFourier(buffer, &result)
    return result
}
@inlinable
public func Convolve(_ signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    Convolve(signal, kernel, &result)
    return result
}
@inlinable
public func Convolve(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    Convolve(signal, kernel, &result)
    return result
}
@inlinable
public func CircularConvolve(_ signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    CircularConvolve(signal, kernel, &result)
    return result
}
@inlinable
public func CircularConvolve(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    CircularConvolve(signal, kernel, &result)
    return result
}
@inlinable
public func NegacyclicConvolve(_ signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    NegacyclicConvolve(signal, kernel, &result)
    return result
}
@inlinable
public func NegacyclicConvolve(_ signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    NegacyclicConvolve(signal, kernel, &result)
    return result
}
@inlinable
public func OverlapConvolve(signal: [Double], kernel: [Double], _ overlap: inout [Double]) -> [Double] {
    var result = [Double]()
    OverlapConvolve(signal: signal, kernel: kernel, &overlap, &result)
    return result
}
@inlinable
public func OverlapConvolve(signal: [Complex], kernel: [Complex], _ overlap: inout [Complex]) -> [Complex] {
    var result = [Complex]()
    OverlapConvolve(signal: signal, kernel: kernel, &overlap, &result)
    return result
}

@inlinable
public func DCTII(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTII(buffer, &result)
    return result
}
@inlinable
public func DCTIII(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTIII(buffer, &result)
    return result
}
@inlinable
public func DCTIV(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTIV(buffer, &result)
    return result
}
@inlinable
public func DSTII(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTII(buffer, &result)
    return result
}
@inlinable
public func DSTIII(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTIII(buffer, &result)
    return result
}
@inlinable
public func DSTIV(_ buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTIV(buffer, &result)
    return result
}
