//
//  Fourier.swift
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

public func FFTConvolveLength(x: Int, _ y: Int) -> Int {
    return (x + y - 2).hibit << 1
}

// MARK: Fourier

public func Fourier(buffer: [Double], inout _ result: [Complex]) {
    switch buffer.count {
    case 0:
        result = [Complex]()
    case 1:
        result = [Complex(buffer[0])]
    case 2:
        let first = buffer[0] * M_SQRT1_2
        let second = buffer[1] * M_SQRT1_2
        result = [Complex(first + second), Complex(first - second)]
    default:
        if buffer.count.isPower2 {
            Radix2CooleyTukey(buffer, &result)
        } else {
            Bluestein(buffer, &result)
        }
    }
}
public func Fourier(buffer: [Complex], inout _ result: [Complex]) {
    switch buffer.count {
    case 0, 1:
        result = buffer
    case 2:
        let first = buffer[0] * M_SQRT1_2
        let second = buffer[1] * M_SQRT1_2
        result = [first + second, first - second]
    default:
        if buffer.count.isPower2 {
            result = Radix2CooleyTukey(buffer)
        } else {
            Bluestein(buffer, &result)
        }
    }
}
public func InverseFourier(buffer: [Double], inout _ result: [Complex]) {
    switch buffer.count {
    case 0:
        result = [Complex]()
    case 1:
        result = [Complex(buffer[0])]
    case 2:
        let first = buffer[0] * M_SQRT1_2
        let second = buffer[1] * M_SQRT1_2
        result = [Complex(first + second), Complex(first - second)]
    default:
        if buffer.count.isPower2 {
            InverseRadix2CooleyTukey(buffer, &result)
        } else {
            InverseBluestein(buffer, &result)
        }
    }
}
public func InverseFourier(buffer: [Complex], inout _ result: [Complex]) {
    switch buffer.count {
    case 0, 1:
        result = buffer
    case 2:
        let first = buffer[0] * M_SQRT1_2
        let second = buffer[1] * M_SQRT1_2
        result = [first + second, first - second]
    default:
        if buffer.count.isPower2 {
            result = InverseRadix2CooleyTukey(buffer)
        } else {
            InverseBluestein(buffer, &result)
        }
    }
}
public func BluesteinKernel(count: Int, inout _ kernel: [Complex]) {
    
    if kernel.count != count {
        kernel.replace(with: Repeat(count: count, repeatedValue: Complex(0)))
    }
    kernel[0].real = 1
    kernel[0].imag = 0
    
    let angle = M_PI / Double(count)
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
public func InverseBluesteinKernel(count: Int, inout _ kernel: [Complex]) {
    
    if kernel.count != count {
        kernel.replace(with: Repeat(count: count, repeatedValue: Complex(0)))
    }
    kernel[0].real = 1
    kernel[0].imag = 0
    
    let angle = -M_PI / Double(count)
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
public func Bluestein(buffer: [Double], inout _ result: [Complex]) {
    var _kernel: [Complex] = []
    BluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    MulConj(buffer.count, _kernel, 1, buffer, 1, &result, 1)
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    MulConj(buffer.count, _kernel, 1, result, 1, &result, 1)
    var _sqrt = sqrt(Double(buffer.count))
    Div(buffer.count, result, 1, &_sqrt, 0, &result, 1)
}
public func Bluestein(buffer: [Complex], inout _ result: [Complex]) {
    var _kernel: [Complex] = []
    BluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    MulConj(buffer.count, _kernel, 1, buffer, 1, &result, 1)
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    MulConj(buffer.count, _kernel, 1, result, 1, &result, 1)
    var _sqrt = sqrt(Double(buffer.count))
    Div(buffer.count, result, 1, &_sqrt, 0, &result, 1)
}
public func InverseBluestein(buffer: [Double], inout _ result: [Complex]) {
    var _kernel: [Complex] = []
    InverseBluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    MulConj(buffer.count, _kernel, 1, buffer, 1, &result, 1)
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    MulConj(buffer.count, _kernel, 1, result, 1, &result, 1)
    var _sqrt = sqrt(Double(buffer.count))
    Div(buffer.count, result, 1, &_sqrt, 0, &result, 1)
}
public func InverseBluestein(buffer: [Complex], inout _ result: [Complex]) {
    var _kernel: [Complex] = []
    InverseBluesteinKernel(buffer.count, &_kernel)
    
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    MulConj(buffer.count, _kernel, 1, buffer, 1, &result, 1)
    
    if buffer.count & 1 == 0 {
        CircularConvolve(result, _kernel, &result)
    } else {
        NegacyclicConvolve(result, _kernel, &result)
    }
    
    MulConj(buffer.count, _kernel, 1, result, 1, &result, 1)
    var _sqrt = sqrt(Double(buffer.count))
    Div(buffer.count, result, 1, &_sqrt, 0, &result, 1)
}

// MARK: Radix-2 Cooley-Tukey

public func Radix2CooleyTukey(var buffer: [Double], inout _ result: [Complex]) {
    switch buffer.count {
    case 0:
        result = []
    case 1:
        result = [Complex(buffer[0])]
    default:
        assert(buffer.count.isPower2, "size of buffer must be power of 2.")
        if result.count != buffer.count {
            result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
        }
        let _sqrt = sqrt(Double(buffer.count))
        DispatchRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &result, 1)
    }
}
public func InverseRadix2CooleyTukey(var buffer: [Double], inout _ result: [Complex]) {
    switch buffer.count {
    case 0:
        result = []
    case 1:
        result = [Complex(buffer[0])]
    default:
        assert(buffer.count.isPower2, "size of buffer must be power of 2.")
        if result.count != buffer.count {
            result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
        }
        let _sqrt = sqrt(Double(buffer.count))
        DispatchInverseRadix2CooleyTukey(log2(buffer.count), buffer.map { $0 / _sqrt }, 1, &result, 1)
    }
}

// MARK: Convolution

public func Convolve(signal: [Double], _ kernel: [Double], inout _ result: [Double]) {
    FFTConvolve(signal, kernel, &result)
}
public func Convolve(signal: [Complex], _ kernel: [Complex], inout _ result: [Complex]) {
    FFTConvolve(signal, kernel, &result)
}
public func CircularConvolve(signal: [Double], _ kernel: [Double], inout _ result: [Double]) {
    if signal.count == 0 || kernel.count == 0 {
        result.removeAll(keepCapacity: true)
    }
    if signal.count >= kernel.count && signal.count.isPower2 {
        
        var temp = [Double](count: signal.count, repeatedValue: 0.0)
        
        if result.count != signal.count {
            result.replace(with: Repeat(count: signal.count, repeatedValue: 0))
        }
        
        let lv = log2(signal.count)
        
        if signal.count == kernel.count {
            DispatchRadix2CircularConvolve(lv, signal, 1, kernel, 1, &result, 1, &temp, 1)
        } else {
            DispatchRadix2CircularConvolve(lv, signal, 1, kernel + Repeat(count: signal.count - kernel.count, repeatedValue: 0), 1, &result, 1, &temp, 1)
        }
        
    } else {
        Convolve(signal, kernel, &result)
        let block = signal.count
        let count = result.count / block
        for idx in 1..<count {
            Add(block, result, 1, UnsafePointer(result) + idx * block, 1, &result, 1)
        }
        Add(result.count % block, result, 1, UnsafePointer(result) + count * block, 1, &result, 1)
        result.removeRange(block..<result.count)
    }
}
public func CircularConvolve(signal: [Complex], _ kernel: [Complex], inout _ result: [Complex]) {
    if signal.count == 0 || kernel.count == 0 {
        result.removeAll(keepCapacity: true)
    }
    if signal.count >= kernel.count && signal.count.isPower2 {
        
        var temp = [Complex](count: signal.count, repeatedValue: Complex(0))
        
        if result.count != signal.count {
            result.replace(with: Repeat(count: signal.count, repeatedValue: Complex(0)))
        }
        
        let lv = log2(signal.count)
        
        if signal.count == kernel.count {
            DispatchRadix2CircularConvolve(lv, signal, 1, kernel, 1, &result, 1, &temp, 1)
        } else {
            DispatchRadix2CircularConvolve(lv, signal, 1, kernel + Repeat(count: signal.count - kernel.count, repeatedValue: Complex(0)), 1, &result, 1, &temp, 1)
        }
        
    } else {
        Convolve(signal, kernel, &result)
        let block = signal.count
        let count = result.count / block
        for idx in 1..<count {
            Add(block, result, 1, UnsafePointer<Complex>(result) + idx * block, 1, &result, 1)
        }
        Add(result.count % block, result, 1, UnsafePointer<Complex>(result) + count * block, 1, &result, 1)
        result.removeRange(block..<result.count)
    }
}
public func NegacyclicConvolve(signal: [Double], _ kernel: [Double], inout _ result: [Double]) {
    Convolve(signal, kernel, &result)
    let count = signal.count
    for idx in 0..<kernel.count - 1 {
        result[idx] -= result[idx + count]
    }
    result.removeRange(signal.count..<result.count)
}
public func NegacyclicConvolve(signal: [Complex], _ kernel: [Complex], inout _ result: [Complex]) {
    Convolve(signal, kernel, &result)
    let count = signal.count
    for idx in 0..<kernel.count - 1 {
        result[idx].real -= result[idx + count].real
        result[idx].imag -= result[idx + count].imag
    }
    result.removeRange(signal.count..<result.count)
}

public func FFTConvolve(signal: [Double], _ kernel: [Double], inout _ result: [Double]) {
    
    let convolve_length = signal.count + kernel.count - 1
    let fft_length = FFTConvolveLength(signal.count, kernel.count)
    let lv = log2(fft_length)
    
    let buffer = [Double](count: fft_length << 1, repeatedValue: 0.0)
    let _output = UnsafeMutablePointer<Double>(buffer)
    let _temp = UnsafeMutablePointer<Double>(buffer) + fft_length
    
    DispatchRadix2CircularConvolve(lv, signal + Repeat(count: fft_length - signal.count, repeatedValue: 0.0), 1, kernel + Repeat(count: fft_length - kernel.count, repeatedValue: 0.0), 1, _output, 1, _temp, 1)
    
    result.replace(with: buffer.prefix(convolve_length))
}
public func FFTConvolve(signal: [Complex], _ kernel: [Complex], inout _ result: [Complex]) {
    
    let convolve_length = signal.count + kernel.count - 1
    let fft_length = FFTConvolveLength(signal.count, kernel.count)
    let lv = log2(fft_length)
    
    let buffer = [Complex](count: fft_length << 1, repeatedValue: Complex(0))
    let _output = UnsafeMutablePointer<Complex>(buffer)
    let _temp = UnsafeMutablePointer<Complex>(buffer) + fft_length
    
    DispatchRadix2CircularConvolve(lv, signal + Repeat(count: fft_length - signal.count, repeatedValue: Complex(0)), 1, kernel + Repeat(count: fft_length - kernel.count, repeatedValue: Complex(0)), 1, _output, 1, _temp, 1)
    
    result.replace(with: buffer.prefix(convolve_length))
}
public func OverlapConvolve(signal signal: [Double], kernel: [Double], inout _ overlap: [Double], inout _ result: [Double]) {
    FFTConvolve(signal, kernel, &result)
    let count = min(result.count, overlap.count)
    Add(count, result, 1, overlap, 1, &result, 1)
    overlap.replace(with: result[signal.count..<result.count].concat(overlap[count..<overlap.count]))
    result.removeRange(signal.count..<result.count)
}
public func OverlapConvolve(signal signal: [Complex], kernel: [Complex], inout _ overlap: [Complex], inout _ result: [Complex]) {
    FFTConvolve(signal, kernel, &result)
    let count = min(result.count, overlap.count)
    Add(count, result, 1, overlap, 1, &result, 1)
    overlap.replace(with: result[signal.count..<result.count].concat(overlap[count..<overlap.count]))
    result.removeRange(signal.count..<result.count)
}

// MARK: Discrete function

public func DiscreteFourier(buffer: [Double], inout _ result: [Complex]) {
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    let angle: Double = -2 * M_PI / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += polar(rho: buffer[i], theta: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
public func DiscreteFourier(buffer: [Complex], inout _ result: [Complex]) {
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    let angle: Double = -2 * M_PI / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += buffer[i] * polar(rho: 1, theta: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
public func InverseDiscreteFourier(buffer: [Double], inout _ result: [Complex]) {
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    let angle: Double = 2 * M_PI / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += polar(rho: buffer[i], theta: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
public func InverseDiscreteFourier(buffer: [Complex], inout _ result: [Complex]) {
    if result.count != buffer.count {
        result.replace(with: Repeat(count: buffer.count, repeatedValue: Complex(0)))
    }
    let angle: Double = 2 * M_PI / Double(buffer.count)
    let sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        var tp = Complex(0)
        for i in buffer.indices {
            tp += buffer[i] * polar(rho: 1, theta: angle * Double(k * i))
        }
        result[k] = tp / sqrt_length
    }
}
public func DiscreteConvolve(signal: [Double], _ kernel: [Double], inout _ result: [Double]) {
    let size = signal.count + kernel.count - 1
    if result.count != size {
        result.replace(with: Repeat(count: size, repeatedValue: 0))
    }
    DiscreteConvolve(signal.count, signal, 1, kernel.count, kernel, 1, &result, 1)
}
public func DiscreteConvolve(signal: [Complex], _ kernel: [Complex], inout _ result: [Complex]) {
    let size = signal.count + kernel.count - 1
    if result.count != size {
        result.replace(with: Repeat(count: size, repeatedValue: Complex(0)))
    }
    DiscreteConvolve(signal.count, signal, 1, kernel.count, kernel, 1, &result, 1)
}

// MARK: Other Transform

public func DCTII(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        temp[i] = buffer[i << 1]
        temp[N - i - 1] = buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = buffer[N - 1]
    }
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    result = [Double](count: N, repeatedValue: 0)
    result[0] = _temp[0].real
    let _angle = -M_PI_2 / Double(N)
    for i in 1..<N {
        result[i] = (_temp[i] * polar(rho: M_SQRT2, theta: _angle * Double(i))).real
    }
}
public func DCTIII(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Complex](count: N, repeatedValue: Complex(0))
    temp[0] = Complex(buffer[0])
    let _angle = -M_PI_2 / Double(N)
    for i in 1..<N {
        temp[i] = buffer[i] * polar(rho: M_SQRT2, theta: _angle * Double(i))
    }
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    result = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        result[i << 1] = _temp[i].real
        result[(i << 1) + 1] = _temp[N - i - 1].real
    }
    if N & 1 == 1 {
        result[N - 1] = _temp[N >> 1].real
    }
}
public func DCTIV(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        temp[i] = buffer[i << 1]
        temp[N - i - 1] = -buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = buffer[N - 1]
    }
    var _temp = [Complex](count: N, repeatedValue: Complex(0))
    _temp[0] = Complex(temp[0])
    let _angle = -M_PI / Double(N)
    for i in 1..<N {
        _temp[i] = polar(rho: temp[i], theta: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](count: N, repeatedValue: 0)
    let _angle2 = -M_PI_4 / Double(N)
    for i in 0..<N {
        result[i] = (_temp[i] * polar(rho: M_SQRT2, theta: _angle2 * Double((i << 1) + 1))).real
    }
}
public func DSTII(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        temp[i] = -buffer[i << 1]
        temp[N - i - 1] = buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = -buffer[N - 1]
    }
    var _temp = [Complex](count: N, repeatedValue: Complex(0))
    _temp[0] = Complex(temp[0])
    let _angle: Double = -2 * M_PI / Double(N)
    for i in 1..<N {
        _temp[i] = polar(rho: temp[i], theta: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](count: N, repeatedValue: 0)
    let _angle2 = -M_PI_2 / Double(N)
    for i in 0..<N - 1 {
        result[i] = (_temp[i] * polar(rho: M_SQRT2, theta: _angle2 * Double(i + 1))).imag
    }
    result[N - 1] = (_temp[N - 1] * polar(rho: 1, theta: -M_PI_2)).imag
}
public func DSTIII(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Complex](count: N, repeatedValue: Complex(0))
    temp[0] = Complex(buffer[0])
    let _angle = -M_PI_2 / Double(N)
    for i in 0..<N - 1 {
        temp[i] = polar(rho: buffer[i] * M_SQRT2, theta: _angle * Double(i + 1))
    }
    temp[N - 1] = polar(rho: buffer[N - 1], theta: -M_PI_2)
    var _temp = [Complex]()
    Fourier(temp, &_temp)
    let _angle2: Double = -2 * M_PI / Double(N)
    for i in 1..<N {
        _temp[i] *= polar(rho: 1, theta: _angle2 * Double(i))
    }
    result = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        result[i << 1] = -_temp[i].imag
        result[(i << 1) + 1] = _temp[N - i - 1].imag
    }
    if N & 1 == 1 {
        result[N - 1] = -_temp[N >> 1].imag
    }
}
public func DSTIV(buffer: [Double], inout _ result: [Double]) {
    let N = buffer.count
    var temp = [Double](count: N, repeatedValue: 0)
    for i in 0..<N >> 1 {
        temp[i] = -buffer[i << 1]
        temp[N - i - 1] = -buffer[(i << 1) + 1]
    }
    if N & 1 == 1 {
        temp[N >> 1] = -buffer[N - 1]
    }
    var _temp = [Complex](count: N, repeatedValue: Complex(0))
    _temp[0] = Complex(temp[0])
    let _angle = -M_PI / Double(N)
    for i in 1..<N {
        _temp[i] = polar(rho: temp[i], theta: _angle * Double(i))
    }
    Fourier(_temp, &_temp)
    result = [Double](count: N, repeatedValue: 0)
    let _angle2 = -M_PI_4 / Double(N)
    for i in 0..<N {
        result[i] = (_temp[i] * polar(rho: M_SQRT2, theta: _angle2 * Double((i << 1) + 1))).imag
    }
}

// MARK: Signal Processing

public func Resampling(count: Int, inout _ buffer: [Double]) {
    var _freq = Fourier(buffer)
    if count > _freq.count {
        let half = _freq.count >> 1
        if _freq.count & 1 == 0 {
            _freq[0..<half].append(_freq[half])
        }
        if count > _freq.count {
            _freq[0...half].appendContentsOf(Repeat(count: count - _freq.count, repeatedValue: Complex(0)))
        }
    } else if count < _freq.count {
        let half = count >> 1
        let start = half + 1
        let end = _freq.count - half
        if count & 1 == 0 {
            _freq.removeRange(start...end)
        } else {
            _freq.removeRange(start..<end)
        }
    }
    InverseFourier(_freq, &_freq)
    buffer.replace(with: _freq.lazy.map { $0.real * sqrt(Double(_freq.count) / Double(buffer.count)) })
}

// MARK: Wrapper Function


public func DiscreteFourier(buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    DiscreteFourier(buffer, &result)
    return result
}
public func DiscreteFourier(buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    DiscreteFourier(buffer, &result)
    return result
}
public func InverseDiscreteFourier(buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    InverseDiscreteFourier(buffer, &result)
    return result
}
public func InverseDiscreteFourier(buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    InverseDiscreteFourier(buffer, &result)
    return result
}
public func Fourier(buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    Fourier(buffer, &result)
    return result
}
public func Fourier(buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    Fourier(buffer, &result)
    return result
}
public func InverseFourier(buffer: [Double]) -> [Complex] {
    var result: [Complex] = []
    InverseFourier(buffer, &result)
    return result
}
public func InverseFourier(buffer: [Complex]) -> [Complex] {
    var result: [Complex] = []
    InverseFourier(buffer, &result)
    return result
}
public func Convolve(signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    Convolve(signal, kernel, &result)
    return result
}
public func Convolve(signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    Convolve(signal, kernel, &result)
    return result
}
public func CircularConvolve(signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    CircularConvolve(signal, kernel, &result)
    return result
}
public func CircularConvolve(signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    CircularConvolve(signal, kernel, &result)
    return result
}
public func NegacyclicConvolve(signal: [Double], _ kernel: [Double]) -> [Double] {
    var result = [Double]()
    NegacyclicConvolve(signal, kernel, &result)
    return result
}
public func NegacyclicConvolve(signal: [Complex], _ kernel: [Complex]) -> [Complex] {
    var result = [Complex]()
    NegacyclicConvolve(signal, kernel, &result)
    return result
}
public func OverlapConvolve(signal signal: [Double], kernel: [Double], inout _ overlap: [Double]) -> [Double] {
    var result = [Double]()
    OverlapConvolve(signal: signal, kernel: kernel, &overlap, &result)
    return result
}
public func OverlapConvolve(signal signal: [Complex], kernel: [Complex], inout _ overlap: [Complex]) -> [Complex] {
    var result = [Complex]()
    OverlapConvolve(signal: signal, kernel: kernel, &overlap, &result)
    return result
}

public func DCTII(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTII(buffer, &result)
    return result
}
public func DCTIII(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTIII(buffer, &result)
    return result
}
public func DCTIV(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DCTIV(buffer, &result)
    return result
}
public func DSTII(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTII(buffer, &result)
    return result
}
public func DSTIII(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTIII(buffer, &result)
    return result
}
public func DSTIV(buffer: [Double]) -> [Double] {
    var result = [Double]()
    DSTIV(buffer, &result)
    return result
}
