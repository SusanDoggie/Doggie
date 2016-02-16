//
//  Arithmetic.swift
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

public func Add<T: IntegerType>(count: Int, var _ left: UnsafePointer<T>, _ left_stride: Int, var _ right: UnsafePointer<T>, _ right_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory + right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Sub<T: IntegerType>(count: Int, var _ left: UnsafePointer<T>, _ left_stride: Int, var _ right: UnsafePointer<T>, _ right_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory - right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mul<T: IntegerType>(count: Int, var _ left: UnsafePointer<T>, _ left_stride: Int, var _ right: UnsafePointer<T>, _ right_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory * right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Div<T: IntegerType>(count: Int, var _ left: UnsafePointer<T>, _ left_stride: Int, var _ right: UnsafePointer<T>, _ right_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory / right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mod<T: IntegerType>(count: Int, var _ left: UnsafePointer<T>, _ left_stride: Int, var _ right: UnsafePointer<T>, _ right_stride: Int, var _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory % right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}

public func Add(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory + right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Sub(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory - right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mul(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory * right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Div(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory / right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mod(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory % right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func MulAdd(count: Int, var _ a: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ c: UnsafePointer<Float>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory * b.memory + c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func MulSub(count: Int, var _ a: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ c: UnsafePointer<Float>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory * b.memory - c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func SubMul(count: Int, var _ a: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ c: UnsafePointer<Float>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory - b.memory * c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}

public func Add(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal - _rreal
        _imag.memory = -_rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal
        _imag.memory = _lreal * _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ a: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = a.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal + _creal
        _imag.memory = _areal * _bimag + _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ a: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = a.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _creal
        _imag.memory = _areal * _bimag - _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal - _breal * _creal
        _imag.memory = _aimag - _breal * _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal
        let imag = -_lreal * _rimag
        _real.memory = real / norm
        _imag.memory = imag / norm
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal - _rreal
        _imag.memory = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal * _rreal
        _imag.memory = _limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal + _creal
        _imag.memory = _aimag * _breal + _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ b: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _creal
        _imag.memory = _aimag * _breal - _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ c: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = c.memory
        _real.memory = _areal - _breal * _creal
        _imag.memory = _aimag - _bimag * _creal
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        c += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulConj(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal * _rreal
        _imag.memory = -_limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal / _rreal
        _imag.memory = _limag / _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _limag + _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal - _rreal
        _imag.memory = _limag - _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal - _limag * _rimag
        _imag.memory = _lreal * _rimag + _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _aimag * _bimag + _creal
        _imag.memory = _areal * _bimag + _aimag * _breal + _cimag
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _aimag * _bimag - _creal
        _imag.memory = _areal * _bimag + _aimag * _breal - _cimag
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Float>, var _ aimag: UnsafePointer<Float>, _ a_stride: Int, var _ breal: UnsafePointer<Float>, var _ bimag: UnsafePointer<Float>, _ b_stride: Int, var _ creal: UnsafePointer<Float>, var _ cimag: UnsafePointer<Float>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal - (_breal * _creal - _bimag * _cimag)
        _imag.memory = _aimag - (_breal * _cimag + _bimag * _creal)
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulConj(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal + _limag * _rimag
        _imag.memory = _lreal * _rimag - _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ lreal: UnsafePointer<Float>, var _ limag: UnsafePointer<Float>, _ left_stride: Int, var _ rreal: UnsafePointer<Float>, var _ rimag: UnsafePointer<Float>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal + _limag * _rimag
        let imag = _limag * _rreal - _lreal * _rimag
        _real.memory = real / norm
        _imag.memory = imag / norm
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}

public func Add(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory + right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Sub(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory - right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mul(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory * right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Div(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory / right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mod(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = left.memory % right.memory
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func MulAdd(count: Int, var _ a: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ c: UnsafePointer<Double>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory * b.memory + c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func MulSub(count: Int, var _ a: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ c: UnsafePointer<Double>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory * b.memory - c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func SubMul(count: Int, var _ a: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ c: UnsafePointer<Double>, _ c_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        output.memory = a.memory - b.memory * c.memory
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}

public func Add(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal - _rreal
        _imag.memory = -_rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal
        _imag.memory = _lreal * _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ a: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = a.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal + _creal
        _imag.memory = _areal * _bimag + _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ a: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = a.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _creal
        _imag.memory = _areal * _bimag - _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal - _breal * _creal
        _imag.memory = _aimag - _breal * _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = left.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal
        let imag = -_lreal * _rimag
        _real.memory = real / norm
        _imag.memory = imag / norm
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal - _rreal
        _imag.memory = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal * _rreal
        _imag.memory = _limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal + _creal
        _imag.memory = _aimag * _breal + _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ b: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = b.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _creal
        _imag.memory = _aimag * _breal - _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ c: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = c.memory
        _real.memory = _areal - _breal * _creal
        _imag.memory = _aimag - _bimag * _creal
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        c += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulConj(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal * _rreal
        _imag.memory = -_limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = right.memory
        _real.memory = _lreal / _rreal
        _imag.memory = _limag / _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal + _rreal
        _imag.memory = _limag + _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal - _rreal
        _imag.memory = _limag - _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal - _limag * _rimag
        _imag.memory = _lreal * _rimag + _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _aimag * _bimag + _creal
        _imag.memory = _areal * _bimag + _aimag * _breal + _cimag
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal * _breal - _aimag * _bimag - _creal
        _imag.memory = _areal * _bimag + _aimag * _breal - _cimag
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul(count: Int, var _ areal: UnsafePointer<Double>, var _ aimag: UnsafePointer<Double>, _ a_stride: Int, var _ breal: UnsafePointer<Double>, var _ bimag: UnsafePointer<Double>, _ b_stride: Int, var _ creal: UnsafePointer<Double>, var _ cimag: UnsafePointer<Double>, _ c_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _areal = areal.memory
        let _aimag = aimag.memory
        let _breal = breal.memory
        let _bimag = bimag.memory
        let _creal = creal.memory
        let _cimag = cimag.memory
        _real.memory = _areal - (_breal * _creal - _bimag * _cimag)
        _imag.memory = _aimag - (_breal * _cimag + _bimag * _creal)
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulConj(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        _real.memory = _lreal * _rreal + _limag * _rimag
        _imag.memory = _lreal * _rimag - _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div(count: Int, var _ lreal: UnsafePointer<Double>, var _ limag: UnsafePointer<Double>, _ left_stride: Int, var _ rreal: UnsafePointer<Double>, var _ rimag: UnsafePointer<Double>, _ right_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    for _ in 0..<count {
        let _lreal = lreal.memory
        let _limag = limag.memory
        let _rreal = rreal.memory
        let _rimag = rimag.memory
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal + _limag * _rimag
        let imag = _limag * _rreal - _lreal * _rimag
        _real.memory = real / norm
        _imag.memory = imag / norm
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}

public func Dot(count: Int, var _ left: UnsafePointer<Float>, _ left_stride: Int, var _ right: UnsafePointer<Float>, _ right_stride: Int) -> Float {
    var result: Float = 0.0
    for _ in 0..<count {
        result += left.memory * right.memory
        left += left_stride
        right += right_stride
    }
    return result
}

public func Dot(count: Int, var _ left: UnsafePointer<Double>, _ left_stride: Int, var _ right: UnsafePointer<Double>, _ right_stride: Int) -> Double {
    var result: Double = 0.0
    for _ in 0..<count {
        result += left.memory * right.memory
        left += left_stride
        right += right_stride
    }
    return result
}

public func Deconvolve(signal_count: Int, var _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ kernel_count: Int, var _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.memory
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.memory = _a * (signal.memory - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
}
public func Deconvolve(signal_count: Int, var _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel_count: Int, var _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.memory
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.memory = _a * (signal.memory - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
}
public func Deconvolve(signal_count: Int, var _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ kernel_count: Int, var _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, var _ residue: UnsafeMutablePointer<Float>, _ residue_stride: Int) {
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.memory
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.memory = _a * (signal.memory - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
    if residue_size > quotient_size {
        for _ in 0..<residue_size - quotient_size {
            residue.memory = signal.memory - Dot(quotient_size, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
        for i in 0..<quotient_size {
            residue.memory = signal.memory - Dot(quotient_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    } else {
        for i in 0..<residue_size {
            residue.memory = signal.memory - Dot(residue_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    }
}

public func Deconvolve(signal_count: Int, var _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ kernel_count: Int, var _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, var _ residue: UnsafeMutablePointer<Double>, _ residue_stride: Int) {
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.memory
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.memory = _a * (signal.memory - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.memory = _a * (signal.memory - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
    if residue_size > quotient_size {
        for _ in 0..<residue_size - quotient_size {
            residue.memory = signal.memory - Dot(quotient_size, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
        for i in 0..<quotient_size {
            residue.memory = signal.memory - Dot(quotient_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    } else {
        for i in 0..<residue_size {
            residue.memory = signal.memory - Dot(residue_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    }
}

public func MatrixElimination(row: Int, _ column: Int, _ matrix: UnsafeMutablePointer<Float>, _ stride_row: Int, _ stride_col: Int) -> Bool {
    
    let row_offset = stride_row * stride_col * column
    let endptr = matrix + row_offset * row
    
    var current_row = matrix
    var i_offset = 0
    while current_row != endptr {
        var m = (current_row + i_offset).memory
        if m == 0 {
            var swap_ptr = current_row + row_offset
            repeat {
                if swap_ptr == endptr {
                    return false
                }
                swap_ptr += row_offset
                m = (swap_ptr + i_offset).memory
            } while m == 0
            Swap(column, current_row, stride_col, swap_ptr, stride_col)
        }
        Div(column, current_row, stride_col, &m, 0, current_row, stride_col)
        var scan = matrix
        while scan != endptr {
            if scan != current_row {
                var n = (scan + i_offset).memory
                SubMul(column, scan, stride_col, current_row, stride_col, &n, 0, scan, stride_col)
            }
            scan += row_offset
        }
        i_offset += stride_col
        current_row += row_offset
    }
    return true
}

public func MatrixElimination(row: Int, _ column: Int, _ matrix: UnsafeMutablePointer<Double>, _ stride_row: Int, _ stride_col: Int) -> Bool {
    
    let row_offset = stride_row * stride_col * column
    let endptr = matrix + row_offset * row
    
    var current_row = matrix
    var i_offset = 0
    while current_row != endptr {
        var m = (current_row + i_offset).memory
        if m == 0 {
            var swap_ptr = current_row + row_offset
            repeat {
                if swap_ptr == endptr {
                    return false
                }
                swap_ptr += row_offset
                m = (swap_ptr + i_offset).memory
            } while m == 0
            Swap(column, current_row, stride_col, swap_ptr, stride_col)
        }
        Div(column, current_row, stride_col, &m, 0, current_row, stride_col)
        var scan = matrix
        while scan != endptr {
            if scan != current_row {
                var n = (scan + i_offset).memory
                SubMul(column, scan, stride_col, current_row, stride_col, &n, 0, scan, stride_col)
            }
            scan += row_offset
        }
        i_offset += stride_col
        current_row += row_offset
    }
    return true
}
