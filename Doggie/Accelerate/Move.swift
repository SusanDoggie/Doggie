//
//  Move.swift
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

//
// MARK: Fast Operations
//
// Swift with optimization Level -Ofast can be much more faster than any Accelerate framework.
// Just do it in simple looping.
//
//

public func Move<T>(count: Int, var _ input: UnsafePointer<T>, _ in_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    for _ in 0..<count {
        output.memory = input.memory
        input += in_stride
        output += out_stride
    }
}
public func Move(count: Int, var _ real: UnsafePointer<Float>, var _ imag: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    for _ in 0..<count {
        _real.memory = real.memory
        _imag.memory = imag.memory
        real += in_stride
        imag += in_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Move(count: Int, var _ real: UnsafePointer<Double>, var _ imag: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    for _ in 0..<count {
        _real.memory = real.memory
        _imag.memory = imag.memory
        real += in_stride
        imag += in_stride
        _real += out_stride
        _imag += out_stride
    }
}

public func Swap<T>(count: Int, var _ left: UnsafeMutablePointer<T>, _ l_stride: Int, var _ right: UnsafeMutablePointer<T>, _ r_stride: Int) {
    
    for _ in 0..<count {
        (left.memory, right.memory) = (right.memory, left.memory)
        left += l_stride
        right += r_stride
    }
}
public func Swap(count: Int, var _ lreal: UnsafeMutablePointer<Float>, var _ limag: UnsafeMutablePointer<Float>, _ l_stride: Int, var _ rreal: UnsafeMutablePointer<Float>, var _ rimag: UnsafeMutablePointer<Float>, _ r_stride: Int) {
    
    for _ in 0..<count {
        (lreal.memory, rreal.memory) = (rreal.memory, lreal.memory)
        (limag.memory, rimag.memory) = (rimag.memory, limag.memory)
        lreal += l_stride
        limag += l_stride
        rreal += r_stride
        rimag += r_stride
    }
}
public func Swap(count: Int, var _ lreal: UnsafeMutablePointer<Double>, var _ limag: UnsafeMutablePointer<Double>, _ l_stride: Int, var _ rreal: UnsafeMutablePointer<Double>, var _ rimag: UnsafeMutablePointer<Double>, _ r_stride: Int) {
    
    for _ in 0..<count {
        (lreal.memory, rreal.memory) = (rreal.memory, lreal.memory)
        (limag.memory, rimag.memory) = (rimag.memory, limag.memory)
        lreal += l_stride
        limag += l_stride
        rreal += r_stride
        rimag += r_stride
    }
}
