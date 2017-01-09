//
//  Arithmetic.swift
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

public func AddMod<T: UnsignedInteger>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ mod: UnsafePointer<T>, _ mod_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var mod = mod
    var output = output
    
    for _ in 0..<count {
        output.pointee = addmod(left.pointee, right.pointee, mod.pointee)
        left += left_stride
        right += right_stride
        mod += mod_stride
        output += out_stride
    }
}
public func NegMod<T: UnsignedInteger>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ mod: UnsafePointer<T>, _ mod_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var mod = mod
    var output = output
    
    for _ in 0..<count {
        output.pointee = negmod(a.pointee, mod.pointee)
        a += a_stride
        mod += mod_stride
        output += out_stride
    }
}
public func SubMod<T: UnsignedInteger>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ mod: UnsafePointer<T>, _ mod_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var mod = mod
    var output = output
    
    for _ in 0..<count {
        output.pointee = submod(left.pointee, right.pointee, mod.pointee)
        left += left_stride
        right += right_stride
        mod += mod_stride
        output += out_stride
    }
}
public func MulMod<T: UnsignedInteger>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ mod: UnsafePointer<T>, _ mod_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var mod = mod
    var output = output
    
    for _ in 0..<count {
        output.pointee = mulmod(left.pointee, right.pointee, mod.pointee)
        left += left_stride
        right += right_stride
        mod += mod_stride
        output += out_stride
    }
}
/// Adds the elements of two integer vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Integer input vector.
///   - left_stride: Stride for `left`.
///   - right: Integer input vector.
///   - right_stride: Stride for `right`.
///   - output: Integer result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] + right[n], 0 <= n < count`
public func Add<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee + right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Subtracts the elements of two integer vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Integer input vector.
///   - left_stride: Stride for `left`.
///   - right: Integer input vector.
///   - right_stride: Stride for `right`.
///   - output: Integer result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] - right[n], 0 <= n < count`
public func Sub<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee - right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Multiplies the elements of two integer vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Integer input vector.
///   - left_stride: Stride for `left`.
///   - right: Integer input vector.
///   - right_stride: Stride for `right`.
///   - output: Integer result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] * right[n], 0 <= n < count`
public func Mul<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee * right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Divides the elements of two integer vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Integer input vector.
///   - left_stride: Stride for `left`.
///   - right: Integer input vector.
///   - right_stride: Stride for `right`.
///   - output: Integer result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] / right[n], 0 <= n < count`
public func Div<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee / right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mod<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee % right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func QuoRem<T: Integer>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ quo: UnsafeMutablePointer<T>, _ quo_stride: Int, _ rem: UnsafeMutablePointer<T>, _ rem_stride: Int) {
    
    var left = left
    var right = right
    var quo = quo
    var rem = rem
    
    for _ in 0..<count {
        let _left = left.pointee
        let _right = right.pointee
        quo.pointee = _left / _right
        rem.pointee = _left % _right
        left += left_stride
        right += right_stride
        quo += quo_stride
        rem += rem_stride
    }
}

/// Adds the elements of two real vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Real input vector.
///   - left_stride: Stride for `left`.
///   - right: Real input vector.
///   - right_stride: Stride for `right`.
///   - output: Real result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] + right[n], 0 <= n < count`
public func Add<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee + right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Subtracts the elements of two real vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Real input vector.
///   - left_stride: Stride for `left`.
///   - right: Real input vector.
///   - right_stride: Stride for `right`.
///   - output: Real result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] - right[n], 0 <= n < count`
public func Sub<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee - right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Multiplies the elements of two real vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Real input vector.
///   - left_stride: Stride for `left`.
///   - right: Real input vector.
///   - right_stride: Stride for `right`.
///   - output: Real result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] * right[n], 0 <= n < count`
public func Mul<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee * right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
/// Divides the elements of two real vectors.
///
/// - parameters:
///   - count: Number of elements to process in the input and output vectors.
///   - left: Real input vector.
///   - left_stride: Stride for `left`.
///   - right: Real input vector.
///   - right_stride: Stride for `right`.
///   - output: Real result vector.
///   - out_stride: Stride for `output`.
/// - remark: `output[n] = left[n] / right[n], 0 <= n < count`
public func Div<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee / right.pointee
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func Mod<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var right = right
    var output = output
    
    for _ in 0..<count {
        output.pointee = left.pointee.truncatingRemainder(dividingBy: right.pointee)
        left += left_stride
        right += right_stride
        output += out_stride
    }
}
public func MulAdd<T: FloatingPoint>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ c: UnsafePointer<T>, _ c_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var b = b
    var c = c
    var output = output
    
    for _ in 0..<count {
        output.pointee = a.pointee * b.pointee + c.pointee
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func MulSub<T: FloatingPoint>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ c: UnsafePointer<T>, _ c_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var b = b
    var c = c
    var output = output
    
    for _ in 0..<count {
        output.pointee = a.pointee * b.pointee - c.pointee
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}
public func SubMul<T: FloatingPoint>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ c: UnsafePointer<T>, _ c_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var b = b
    var c = c
    var output = output
    
    for _ in 0..<count {
        output.pointee = a.pointee - b.pointee * c.pointee
        a += a_stride
        b += b_stride
        c += c_stride
        output += out_stride
    }
}

public func Add<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = left.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal + _rreal
        _imag.pointee = _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = left.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal - _rreal
        _imag.pointee = -_rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = left.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal * _rreal
        _imag.pointee = _lreal * _rimag
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd<T: FloatingPoint>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var breal = breal
    var bimag = bimag
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = a.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal + _creal
        _imag.pointee = _areal * _bimag + _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub<T: FloatingPoint>(_ count: Int, _ a: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var a = a
    var breal = breal
    var bimag = bimag
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = a.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal - _creal
        _imag.pointee = _areal * _bimag - _cimag
        a += a_stride
        breal += b_stride
        bimag += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var b = b
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = b.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal - _breal * _creal
        _imag.pointee = _aimag - _breal * _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var left = left
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = left.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal
        let imag = -_lreal * _rimag
        _real.pointee = real / norm
        _imag.pointee = imag / norm
        left += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var right = right
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = right.pointee
        _real.pointee = _lreal + _rreal
        _imag.pointee = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var right = right
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = right.pointee
        _real.pointee = _lreal - _rreal
        _imag.pointee = _limag
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var right = right
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = right.pointee
        _real.pointee = _lreal * _rreal
        _imag.pointee = _limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var b = b
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = b.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal + _creal
        _imag.pointee = _aimag * _breal + _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulSub<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ b: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var b = b
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = b.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal - _creal
        _imag.pointee = _aimag * _breal - _cimag
        areal += a_stride
        aimag += a_stride
        b += b_stride
        creal += c_stride
        cimag += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func SubMul<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ c: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var breal = breal
    var bimag = bimag
    var c = c
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = c.pointee
        _real.pointee = _areal - _breal * _creal
        _imag.pointee = _aimag - _bimag * _creal
        areal += a_stride
        aimag += a_stride
        breal += b_stride
        bimag += b_stride
        c += c_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulConj<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var right = right
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = right.pointee
        _real.pointee = _lreal * _rreal
        _imag.pointee = -_limag * _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var right = right
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = right.pointee
        _real.pointee = _lreal / _rreal
        _imag.pointee = _limag / _rreal
        lreal += left_stride
        limag += left_stride
        right += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Add<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal + _rreal
        _imag.pointee = _limag + _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Sub<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal - _rreal
        _imag.pointee = _limag - _rimag
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Mul<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal * _rreal - _limag * _rimag
        _imag.pointee = _lreal * _rimag + _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func MulAdd<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var breal = breal
    var bimag = bimag
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal - _aimag * _bimag + _creal
        _imag.pointee = _areal * _bimag + _aimag * _breal + _cimag
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
public func MulSub<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var breal = breal
    var bimag = bimag
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal * _breal - _aimag * _bimag - _creal
        _imag.pointee = _areal * _bimag + _aimag * _breal - _cimag
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
public func SubMul<T: FloatingPoint>(_ count: Int, _ areal: UnsafePointer<T>, _ aimag: UnsafePointer<T>, _ a_stride: Int, _ breal: UnsafePointer<T>, _ bimag: UnsafePointer<T>, _ b_stride: Int, _ creal: UnsafePointer<T>, _ cimag: UnsafePointer<T>, _ c_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var areal = areal
    var aimag = aimag
    var breal = breal
    var bimag = bimag
    var creal = creal
    var cimag = cimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _areal = areal.pointee
        let _aimag = aimag.pointee
        let _breal = breal.pointee
        let _bimag = bimag.pointee
        let _creal = creal.pointee
        let _cimag = cimag.pointee
        _real.pointee = _areal - (_breal * _creal - _bimag * _cimag)
        _imag.pointee = _aimag - (_breal * _cimag + _bimag * _creal)
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
public func MulConj<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        _real.pointee = _lreal * _rreal + _limag * _rimag
        _imag.pointee = _lreal * _rimag - _limag * _rreal
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}
public func Div<T: FloatingPoint>(_ count: Int, _ lreal: UnsafePointer<T>, _ limag: UnsafePointer<T>, _ left_stride: Int, _ rreal: UnsafePointer<T>, _ rimag: UnsafePointer<T>, _ right_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var lreal = lreal
    var limag = limag
    var rreal = rreal
    var rimag = rimag
    var _real = _real
    var _imag = _imag
    
    for _ in 0..<count {
        let _lreal = lreal.pointee
        let _limag = limag.pointee
        let _rreal = rreal.pointee
        let _rimag = rimag.pointee
        let norm = _rreal * _rreal + _rimag * _rimag
        let real = _lreal * _rreal + _limag * _rimag
        let imag = _limag * _rreal - _lreal * _rimag
        _real.pointee = real / norm
        _imag.pointee = imag / norm
        lreal += left_stride
        limag += left_stride
        rreal += right_stride
        rimag += right_stride
        _real += out_stride
        _imag += out_stride
    }
}

public func Dot<T: FloatingPoint>(_ count: Int, _ left: UnsafePointer<T>, _ left_stride: Int, _ right: UnsafePointer<T>, _ right_stride: Int) -> T {
    
    var left = left
    var right = right
    
    var result: T = 0
    for _ in 0..<count {
        result += left.pointee * right.pointee
        left += left_stride
        right += right_stride
    }
    return result
}

public func Deconvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var signal = signal
    var kernel = kernel
    var output = output
    
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.pointee
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.pointee = _a * (signal.pointee - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
}
public func Deconvolve<T: FloatingPoint>(_ signal_count: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel_count: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ residue: UnsafeMutablePointer<T>, _ residue_stride: Int) {
    
    var signal = signal
    var kernel = kernel
    var output = output
    var residue = residue
    
    let residue_size = kernel_count - 1
    let quotient_size = signal_count - residue_size
    let _a = 1 / kernel.pointee
    kernel += kernel_stride
    if quotient_size > kernel_count {
        for i in 0..<kernel_count {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
        for _ in 0..<quotient_size - kernel_count {
            output.pointee = _a * (signal.pointee - Dot(residue_size, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    } else {
        for i in 0..<quotient_size {
            output.pointee = _a * (signal.pointee - Dot(i, output - out_stride, -out_stride, kernel, kernel_stride))
            signal += signal_stride
            output += out_stride
        }
    }
    if residue_size > quotient_size {
        for _ in 0..<residue_size - quotient_size {
            residue.pointee = signal.pointee - Dot(quotient_size, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
        for i in 0..<quotient_size {
            residue.pointee = signal.pointee - Dot(quotient_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    } else {
        for i in 0..<residue_size {
            residue.pointee = signal.pointee - Dot(residue_size - i, output - out_stride, -out_stride, kernel, kernel_stride)
            signal += signal_stride
            kernel += kernel_stride
            residue += residue_stride
        }
    }
}

public func MatrixElimination<T: FloatingPoint>(_ row: Int, _ column: Int, _ matrix: UnsafeMutablePointer<T>, _ stride_row: Int, _ stride_col: Int) -> Bool {
    
    let row_offset = stride_row * stride_col * column
    let endptr = matrix + row_offset * row
    
    var current_row = matrix
    var i_offset = 0
    while current_row != endptr {
        var m = (current_row + i_offset).pointee
        if m == 0 {
            var swap_ptr = current_row + row_offset
            repeat {
                if swap_ptr == endptr {
                    return false
                }
                m = (swap_ptr + i_offset).pointee
                if m != 0 {
                    Swap(column, current_row, stride_col, swap_ptr, stride_col)
                    break
                }
                swap_ptr += row_offset
            } while true
        }
        Div(column, current_row, stride_col, &m, 0, current_row, stride_col)
        var scan = matrix
        while scan != endptr {
            if scan != current_row {
                var n = (scan + i_offset).pointee
                SubMul(column, scan, stride_col, current_row, stride_col, &n, 0, scan, stride_col)
            }
            scan += row_offset
        }
        i_offset += stride_col
        current_row += row_offset
    }
    return true
}
