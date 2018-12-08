//
//  AccelerateWrapper.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

extension UnsafePointer where Pointee == Complex {
    
    @inlinable
    @inline(__always)
    func _reboundToDouble(body: (UnsafePointer<Double>) throws -> Void) rethrows {
        try self.withMemoryRebound(to: Double.self, capacity: 2, body)
    }
}

extension UnsafeMutablePointer where Pointee == Complex {
    
    @inlinable
    @inline(__always)
    func _reboundToDouble(body: (UnsafeMutablePointer<Double>) throws -> Void) rethrows {
        try self.withMemoryRebound(to: Double.self, capacity: 2, body)
    }
}

@inlinable
@inline(__always)
public func HalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output._reboundToDouble { HalfRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0.successor(), out_stride << 1) }
}
@inlinable
@inline(__always)
public func HalfInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    input._reboundToDouble { _input in HalfInverseRadix2CooleyTukey(level, _input, _input.successor(), in_stride << 1, output, out_stride) }
}
@inlinable
@inline(__always)
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output._reboundToDouble { Radix2CooleyTukey(level, input, in_stride, in_count, $0, $0.successor(), out_stride << 1) }
}
@inlinable
@inline(__always)
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input._reboundToDouble { _input in output._reboundToDouble { Radix2CooleyTukey(level, _input, _input.successor(), in_stride << 1, in_count, $0, $0.successor(), out_stride << 1) } }
}
@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    output._reboundToDouble { InverseRadix2CooleyTukey(level, input, in_stride, in_count, $0, $0.successor(), out_stride << 1) }
}
@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input._reboundToDouble { _input in output._reboundToDouble { InverseRadix2CooleyTukey(level, _input, _input.successor(), in_stride << 1, in_count, $0, $0.successor(), out_stride << 1) } }
}
@inlinable
@inline(__always)
public func Radix2CooleyTukey(_ level: Int, _ buffer: UnsafeMutablePointer<Complex>, _ stride: Int) {
    buffer._reboundToDouble { Radix2CooleyTukey(level, $0, $0.successor(), stride << 1) }
}
@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey(_ level: Int, _ buffer: UnsafeMutablePointer<Complex>, _ stride: Int) {
    buffer._reboundToDouble { InverseRadix2CooleyTukey(level, $0, $0.successor(), stride << 1) }
}

@inlinable
@inline(__always)
public func Radix2CircularConvolve(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Complex>, _ temp_stride: Int) {
    signal._reboundToDouble { _signal in kernel._reboundToDouble { _kernel in temp._reboundToDouble { _temp in output._reboundToDouble { Radix2CircularConvolve(level, _signal, _signal.successor(), signal_stride << 1, signal_count, _kernel, _kernel.successor(), kernel_stride << 1, kernel_count, $0, $0.successor(), out_stride << 1, _temp, _temp.successor(), temp_stride << 1) } } } }
}
@inlinable
@inline(__always)
public func Radix2PowerCircularConvolve(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    input._reboundToDouble { _input in output._reboundToDouble { Radix2PowerCircularConvolve(level, _input, _input.successor(), in_stride << 1, in_count, n, $0, $0.successor(), out_stride << 1) } }
}

@inlinable
@inline(__always)
public func Radix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    kernel._reboundToDouble { Radix2FiniteImpulseFilter(level, signal, signal_stride, signal_count, $0, $0.successor(), kernel_stride << 1, output, out_stride) }
}

@inlinable
@inline(__always)
public func Radix2FiniteImpulseFilter(_ level: Int, _ signal: UnsafePointer<Complex>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Complex>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    signal._reboundToDouble { _signal in kernel._reboundToDouble { _kernel in output._reboundToDouble { Radix2FiniteImpulseFilter(level, _signal, _signal.successor(), signal_stride << 1, signal_count, _kernel, _kernel.successor(), kernel_stride << 1, $0, $0.successor(), out_stride << 1) } } }
}
