//
//  NumberTheoreticTransform.swift
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

private let CooleyTukeyDispatchQueue = dispatch_queue_create("com.SusanDoggie.Algorithm.CooleyTukey", DISPATCH_QUEUE_CONCURRENT)

private func left_shift_mod(a: UInt32, _ s: UInt32, _ m: UInt32) -> UInt32 {
    return UInt32((UInt64(a) << UInt64(s)) % UInt64(m))
}

private func mul_mod(a: UInt32, _ b: UInt32, _ m: UInt32) -> UInt32 {
    return UInt32((UInt64(a) * UInt64(b)) % UInt64(m))
}

public func NumberTheoreticTransform_2(var input: UnsafePointer<UInt32>, _ in_stride: Int, var _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    let a = input.memory % 65537
    input += in_stride
    
    let b = input.memory % 65537
    
    output.memory = (a + b) % 65537
    output += out_stride
    
    output.memory = (a + left_shift_mod(b, 16, 65537)) % 65537
}

public func NumberTheoreticTransform_4(var input: UnsafePointer<UInt32>, _ in_stride: Int, var _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    let a = input.memory % 65537
    input += in_stride
    
    let b = input.memory % 65537
    input += in_stride
    
    let c = input.memory % 65537
    input += in_stride
    
    let d = input.memory % 65537
    
    let e = a + c
    let f = (a + left_shift_mod(c, 16, 65537)) % 65537
    let g = b + d
    let h = (((b + left_shift_mod(d, 16, 65537)) % 65537) << 8) % 65537
    
    output.memory = (e + g) % 65537
    output += out_stride
    
    output.memory = (f + h) % 65537
    output += out_stride
    
    output.memory = (e + left_shift_mod(g, 16, 65537)) % 65537
    output += out_stride
    
    output.memory = (f + left_shift_mod(h, 16, 65537)) % 65537
}

public func NumberTheoreticTransform_8(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 2
    
    NumberTheoreticTransform_4(input, in_stride << 1, op, out_stride)
    NumberTheoreticTransform_4(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<4 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 4
        op += out_stride
        oph += out_stride
    }
}

public func NumberTheoreticTransform_16(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 3
    
    NumberTheoreticTransform_8(input, in_stride << 1, op, out_stride)
    NumberTheoreticTransform_8(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<8 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 2
        op += out_stride
        oph += out_stride
    }
}

public func NumberTheoreticTransform_32(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 4
    
    NumberTheoreticTransform_16(input, in_stride << 1, op, out_stride)
    NumberTheoreticTransform_16(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<16 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 1
        op += out_stride
        oph += out_stride
    }
}

public func DispatchNumberTheoreticTransform_8(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 2
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            NumberTheoreticTransform_4(input, in_stride << 1, op, out_stride)
        default:
            NumberTheoreticTransform_4(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<4 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 4
        op += out_stride
        oph += out_stride
    }
}

public func DispatchNumberTheoreticTransform_16(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 3
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            NumberTheoreticTransform_8(input, in_stride << 1, op, out_stride)
        default:
            NumberTheoreticTransform_8(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<8 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 2
        op += out_stride
        oph += out_stride
    }
}

public func DispatchNumberTheoreticTransform_32(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 4
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            NumberTheoreticTransform_16(input, in_stride << 1, op, out_stride)
        default:
            NumberTheoreticTransform_16(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<16 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha <<= 1
        op += out_stride
        oph += out_stride
    }
}

public func InverseNumberTheoreticTransform_2(var input: UnsafePointer<UInt32>, _ in_stride: Int, var _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    let a = input.memory % 65537
    input += in_stride
    
    let b = input.memory % 65537
    
    output.memory = (a + b) % 65537
    output += out_stride
    
    output.memory = (a + left_shift_mod(b, 16, 65537)) % 65537
}

public func InverseNumberTheoreticTransform_4(var input: UnsafePointer<UInt32>, _ in_stride: Int, var _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    let a = input.memory % 65537
    input += in_stride
    
    let b = input.memory % 65537
    input += in_stride
    
    let c = input.memory % 65537
    input += in_stride
    
    let d = input.memory % 65537
    
    let e = a + c
    let f = (a + left_shift_mod(c, 16, 65537)) % 65537
    let g = b + d
    let h = (((b + left_shift_mod(d, 16, 65537)) % 65537) * 65281) % 65537
    
    output.memory = (e + g) % 65537
    output += out_stride
    
    output.memory = (f + h) % 65537
    output += out_stride
    
    output.memory = (e + left_shift_mod(g, 16, 65537)) % 65537
    output += out_stride
    
    output.memory = (f + left_shift_mod(h, 16, 65537)) % 65537
}

public func InverseNumberTheoreticTransform_8(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 2
    
    InverseNumberTheoreticTransform_4(input, in_stride << 1, op, out_stride)
    InverseNumberTheoreticTransform_4(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<4 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 61441) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func InverseNumberTheoreticTransform_16(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 3
    
    InverseNumberTheoreticTransform_8(input, in_stride << 1, op, out_stride)
    InverseNumberTheoreticTransform_8(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<8 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 49153) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func InverseNumberTheoreticTransform_32(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 4
    
    InverseNumberTheoreticTransform_16(input, in_stride << 1, op, out_stride)
    InverseNumberTheoreticTransform_16(input + in_stride, in_stride << 1, oph, out_stride)
    
    var _alpha: UInt32 = 1
    for _ in 0..<16 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 32769) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func DispatchInverseNumberTheoreticTransform_8(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 2
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            InverseNumberTheoreticTransform_4(input, in_stride << 1, op, out_stride)
        default:
            InverseNumberTheoreticTransform_4(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<4 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 61441) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func DispatchInverseNumberTheoreticTransform_16(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 3
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            InverseNumberTheoreticTransform_8(input, in_stride << 1, op, out_stride)
        default:
            InverseNumberTheoreticTransform_8(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<8 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 49153) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func DispatchInverseNumberTheoreticTransform_32(input: UnsafePointer<UInt32>, _ in_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int) {
    
    var op = output
    var oph = output + out_stride << 4
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            InverseNumberTheoreticTransform_16(input, in_stride << 1, op, out_stride)
        default:
            InverseNumberTheoreticTransform_16(input + in_stride, in_stride << 1, oph, out_stride)
        }
    }
    
    var _alpha: UInt32 = 1
    for _ in 0..<16 {
        let tpr = op.memory
        let tphr = (_alpha * oph.memory) % 65537
        op.memory = (tpr + tphr) % 65537
        oph.memory = (tpr + left_shift_mod(tphr, 16, 65537)) % 65537
        _alpha = (_alpha * 32769) % 65537
        op += out_stride
        oph += out_stride
    }
}

public func Radix2CircularConvolve_2(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform_2(signal, signal_stride, _signal, out_stride)
    NumberTheoreticTransform_2(kernel, kernel_stride, _kernel, temp_stride)
    
    var _s = _signal.memory
    var _k = (_kernel.memory * 32769) % 65537
    _kernel.memory = mul_mod(_s, _k, 65537)
    _signal += out_stride
    _kernel += temp_stride
    
    _s = _signal.memory
    _k = (_kernel.memory * 32769) % 65537
    _kernel.memory = mul_mod(_s, _k, 65537)
    
    InverseNumberTheoreticTransform_2(temp, temp_stride, output, out_stride)
}

public func Radix2CircularConvolve_4(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform_4(signal, signal_stride, _signal, out_stride)
    NumberTheoreticTransform_4(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<4 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 49153) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseNumberTheoreticTransform_4(temp, temp_stride, output, out_stride)
}

public func Radix2CircularConvolve_8(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform_8(signal, signal_stride, _signal, out_stride)
    NumberTheoreticTransform_8(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<8 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 57345) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseNumberTheoreticTransform_8(temp, temp_stride, output, out_stride)
}

public func Radix2CircularConvolve_16(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform_16(signal, signal_stride, _signal, out_stride)
    NumberTheoreticTransform_16(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<16 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 61441) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseNumberTheoreticTransform_16(temp, temp_stride, output, out_stride)
}

public func Radix2CircularConvolve_32(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform_32(signal, signal_stride, _signal, out_stride)
    NumberTheoreticTransform_32(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<32 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 63489) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseNumberTheoreticTransform_32(temp, temp_stride, output, out_stride)
}

public func DispatchRadix2CircularConvolve_8(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    DispatchNumberTheoreticTransform_8(signal, signal_stride, _signal, out_stride)
    DispatchNumberTheoreticTransform_8(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<8 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 57345) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    DispatchInverseNumberTheoreticTransform_8(temp, temp_stride, output, out_stride)
}

public func DispatchRadix2CircularConvolve_16(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    DispatchNumberTheoreticTransform_16(signal, signal_stride, _signal, out_stride)
    DispatchNumberTheoreticTransform_16(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<16 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 61441) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    DispatchInverseNumberTheoreticTransform_16(temp, temp_stride, output, out_stride)
}

public func DispatchRadix2CircularConvolve_32(signal: UnsafePointer<UInt32>, _ signal_stride: Int, _ kernel: UnsafePointer<UInt32>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<UInt32>, _ out_stride: Int, _ temp: UnsafeMutablePointer<UInt32>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    DispatchNumberTheoreticTransform_32(signal, signal_stride, _signal, out_stride)
    DispatchNumberTheoreticTransform_32(kernel, kernel_stride, _kernel, temp_stride)
    
    for _ in 0..<32 {
        let _s = _signal.memory
        let _k = (_kernel.memory * 63489) % 65537
        _kernel.memory = mul_mod(_s, _k, 65537)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    DispatchInverseNumberTheoreticTransform_32(temp, temp_stride, output, out_stride)
}

public func NumberTheoreticTransform_2<U: UnsignedIntegerType>(var input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, var _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    let a = input.memory % mod
    input += in_stride
    
    let b = input.memory % mod
    
    output.memory = (a + b) % mod
    output += out_stride
    
    output.memory = (a + ((alpha % mod) * b) % mod) % mod
}

public func NumberTheoreticTransform<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = input.memory % mod
        
    case 1:
        NumberTheoreticTransform_2(input, in_stride, alpha, mod, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        NumberTheoreticTransform(level - 1, input, in_stride << 1, _alpha_2, mod, op, out_stride)
        NumberTheoreticTransform(level - 1, input + in_stride, in_stride << 1, _alpha_2, mod, oph, out_stride)
        
        var _alpha: U = 1
        let _alpha_k = pow(alpha, U(UIntMax(half)), mod)
        for _ in 0..<half {
            let tpr = op.memory
            let tphr = (_alpha * oph.memory) % mod
            op.memory = (tpr + tphr) % mod
            oph.memory = (tpr + (_alpha_k * tphr) % mod) % mod
            _alpha = (_alpha * alpha) % mod
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchNumberTheoreticTransform<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = input.memory % mod
        
    case 1:
        NumberTheoreticTransform_2(input, in_stride, alpha, mod, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
            switch $0 {
            case 0:
                NumberTheoreticTransform(level - 1, input, in_stride << 1, _alpha_2, mod, op, out_stride)
            default:
                NumberTheoreticTransform(level - 1, input + in_stride, in_stride << 1, _alpha_2, mod, oph, out_stride)
            }
        }
        
        var _alpha: U = 1
        let _alpha_k = pow(alpha, U(UIntMax(half)), mod)
        for _ in 0..<half {
            let tpr = op.memory
            let tphr = (_alpha * oph.memory) % mod
            op.memory = (tpr + tphr) % mod
            oph.memory = (tpr + (_alpha_k * tphr) % mod) % mod
            _alpha = (_alpha * alpha) % mod
            op += out_stride
            oph += out_stride
        }
    }
}

public func InverseNumberTheoreticTransform_2<U: UnsignedIntegerType>(var input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, var _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    let a = input.memory % mod
    input += in_stride
    
    let b = input.memory % mod
    
    output.memory = (a + b) % mod
    output += out_stride
    
    output.memory = (a + (modinv(alpha, mod) * b) % mod) % mod
}

public func InverseNumberTheoreticTransform<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = input.memory % mod
        
    case 1:
        InverseNumberTheoreticTransform_2(input, in_stride, alpha, mod, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        InverseNumberTheoreticTransform(level - 1, input, in_stride << 1, _alpha_2, mod, op, out_stride)
        InverseNumberTheoreticTransform(level - 1, input + in_stride, in_stride << 1, _alpha_2, mod, oph, out_stride)
        
        let _inverse_alpha = modinv(alpha, mod)
        var _alpha: U = 1
        let _alpha_k = modinv(pow(alpha, U(UIntMax(half)), mod), mod)
        for _ in 0..<half {
            let tpr = op.memory
            let tphr = (_alpha * oph.memory) % mod
            op.memory = (tpr + tphr) % mod
            oph.memory = (tpr + (_alpha_k * tphr) % mod) % mod
            _alpha = (_alpha * _inverse_alpha) % mod
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchInverseNumberTheoreticTransform<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = input.memory % mod
        
    case 1:
        InverseNumberTheoreticTransform_2(input, in_stride, alpha, mod, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
            switch $0 {
            case 0:
                InverseNumberTheoreticTransform(level - 1, input, in_stride << 1, _alpha_2, mod, op, out_stride)
            default:
                InverseNumberTheoreticTransform(level - 1, input + in_stride, in_stride << 1, _alpha_2, mod, oph, out_stride)
            }
        }
        
        let _inverse_alpha = modinv(alpha, mod)
        var _alpha: U = 1
        let _alpha_k = modinv(pow(alpha, U(UIntMax(half)), mod), mod)
        for _ in 0..<half {
            let tpr = op.memory
            let tphr = (_alpha * oph.memory) % mod
            op.memory = (tpr + tphr) % mod
            oph.memory = (tpr + (_alpha_k * tphr) % mod) % mod
            _alpha = (_alpha * _inverse_alpha) % mod
            op += out_stride
            oph += out_stride
        }
    }
}

public func Radix2CircularConvolve<U: UnsignedIntegerType>(level: Int, _ signal: UnsafePointer<U>, _ signal_stride: Int, _ kernel: UnsafePointer<U>, _ kernel_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int, _ temp: UnsafeMutablePointer<U>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    NumberTheoreticTransform(level, signal, signal_stride, alpha, mod, _signal, out_stride)
    NumberTheoreticTransform(level, kernel, kernel_stride, alpha, mod, _kernel, temp_stride)
    
    let fft_length = 1 << level
    
    let _n = modinv(U(UIntMax(fft_length)), mod)
    for _ in 0..<fft_length {
        let _s = _signal.memory
        let _k = (_kernel.memory * _n) % mod
        _kernel.memory = (_s * _k) % mod
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseNumberTheoreticTransform(level, temp, temp_stride, alpha, mod, output, out_stride)
}

public func DispatchRadix2CircularConvolve<U: UnsignedIntegerType>(level: Int, _ signal: UnsafePointer<U>, _ signal_stride: Int, _ kernel: UnsafePointer<U>, _ kernel_stride: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int, _ temp: UnsafeMutablePointer<U>, _ temp_stride: Int) {
    
    var _signal = output
    var _kernel = temp
    
    DispatchNumberTheoreticTransform(level, signal, signal_stride, alpha, mod, _signal, out_stride)
    DispatchNumberTheoreticTransform(level, kernel, kernel_stride, alpha, mod, _kernel, temp_stride)
    
    let fft_length = 1 << level
    
    let _n = modinv(U(UIntMax(fft_length)), mod)
    for _ in 0..<fft_length {
        let _s = _signal.memory
        let _k = (_kernel.memory * _n) % mod
        _kernel.memory = (_s * _k) % mod
        _signal += out_stride
        _kernel += temp_stride
    }
    
    DispatchInverseNumberTheoreticTransform(level, temp, temp_stride, alpha, mod, output, out_stride)
}
