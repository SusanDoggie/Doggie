//
//  CooleyTukey.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

// MARK: Half Radix-2 Cooley-Tukey

@inlinable
@inline(__always)
func _HalfRadix2CooleyTukeyTwiddling<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {

    let length = 1 << level
    let half = length >> 1
    let fourth = length >> 2

    let _stride = half * stride
    var op_r = real
    var op_i = imag
    var oph_r = real + _stride
    var oph_i = imag + _stride

    let tr = op_r.pointee
    let ti = op_i.pointee
    op_r.pointee = tr + ti
    op_i.pointee = tr - ti

    let opf_i = imag + fourth * stride
    opf_i.pointee = -opf_i.pointee

    let angle = -T.pi / T(half)
    let _cos = T.cos(angle)
    let _sin = T.sin(angle)
    var _cos1 = _cos
    var _sin1 = _sin
    for _ in 1..<fourth {

        op_r += stride
        op_i += stride
        oph_r -= stride
        oph_i -= stride

        let or = op_r.pointee
        let oi = op_i.pointee
        let ohr = oph_r.pointee
        let ohi = oph_i.pointee

        let evenreal = or + ohr
        let evenim = oi - ohi
        let oddreal = oi + ohi
        let oddim = ohr - or

        let _r = oddreal * _cos1 - oddim * _sin1
        let _i = oddreal * _sin1 + oddim * _cos1

        op_r.pointee = 0.5 * (evenreal + _r)
        op_i.pointee = 0.5 * (_i + evenim)
        oph_r.pointee = 0.5 * (evenreal - _r)
        oph_i.pointee = 0.5 * (_i - evenim)

        let _c1 = _cos * _cos1 - _sin * _sin1
        let _s1 = _cos * _sin1 + _sin * _cos1
        _cos1 = _c1
        _sin1 = _s1
    }
}

@inlinable
@inline(__always)
public func HalfRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0

    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
    case 3:
        HalfRadix2CooleyTukey_8(input, in_stride, in_count, _real, _imag, out_stride)
    case 4:
        HalfRadix2CooleyTukey_16(input, in_stride, in_count, _real, _imag, out_stride)

    default:
        let length = 1 << level
        let half = length >> 1

        if _slowPath(in_count == 0) {
            var _real = _real
            var _imag = _imag
            for _ in 0..<half {
                _real.pointee = 0
                _imag.pointee = 0
                _real += out_stride
                _imag += out_stride
            }
            return
        }

        let _in_count = in_count >> 1
        _Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), _real, _imag, out_stride)
        _HalfRadix2CooleyTukeyTwiddling(level, _real, _imag, out_stride)
    }
}
@inlinable
@inline(__always)
public func HalfRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ buffer: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0: break

    case 1:
        HalfRadix2CooleyTukey_2(buffer, stride, 1, buffer, buffer + stride)
    case 2:
        HalfRadix2CooleyTukey_4(buffer, stride, 2, buffer, buffer + stride, stride << 1)
    case 3:
        HalfRadix2CooleyTukey_8(buffer, stride, 4, buffer, buffer + stride, stride << 1)
    case 4:
        HalfRadix2CooleyTukey_16(buffer, stride, 8, buffer, buffer + stride, stride << 1)

    default:
        Radix2CooleyTukey(level - 1, buffer, buffer + stride, stride << 1)
        _HalfRadix2CooleyTukeyTwiddling(level, buffer, buffer + stride, stride << 1)
    }
}
@inlinable
@inline(__always)
public func HalfInverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0:
        output.pointee = real.pointee

    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, 1, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, 2, output, out_stride)
    case 3:
        HalfInverseRadix2CooleyTukey_8(real, imag, in_stride, 4, output, out_stride)
    case 4:
        HalfInverseRadix2CooleyTukey_16(real, imag, in_stride, 8, output, out_stride)

    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2

        let tp_stride = out_stride << 1

        var ip_r = real
        var ip_i = imag
        var iph_r = real + half * in_stride
        var iph_i = imag + half * in_stride
        var tp_r = output
        var tp_i = output + out_stride
        var tph_r = tp_r + half * tp_stride
        var tph_i = tp_i + half * tp_stride

        let tr = ip_r.pointee
        let ti = ip_i.pointee
        tp_r.pointee = tr + ti
        tp_i.pointee = tr - ti

        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.pointee = ipf_r.pointee * 2.0
        tpf_i.pointee = -ipf_i.pointee * 2.0

        let angle = -T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {

            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride

            let ir = ip_r.pointee
            let ii = ip_i.pointee
            let ihr = iph_r.pointee
            let ihi = iph_i.pointee

            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir

            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1

            tp_r.pointee = evenreal - _r
            tp_i.pointee = _i + evenim
            tph_r.pointee = evenreal + _r
            tph_i.pointee = _i - evenim

            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }

        InverseRadix2CooleyTukey(level - 1, output, output + out_stride, tp_stride)
    }
}
@inlinable
@inline(__always)
public func HalfInverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ buffer: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {
    HalfInverseRadix2CooleyTukey(level, buffer, buffer + stride, stride << 1, buffer, stride)
}

// MARK: Radix-2 Cooley-Tukey

@inlinable
@inline(__always)
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0

    case 1:
        Radix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
    case 3:
        Radix2CooleyTukey_8(input, in_stride, in_count, _real, _imag, out_stride)
    case 4:
        Radix2CooleyTukey_16(input, in_stride, in_count, _real, _imag, out_stride)

    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2

        if _slowPath(in_count == 0) {
            var _real = _real
            var _imag = _imag
            for _ in 0..<length {
                _real.pointee = 0
                _imag.pointee = 0
                _real += out_stride
                _imag += out_stride
            }
            return
        }

        let _in_count = in_count >> 1
        _Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), _real, _imag, out_stride)

        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        var oph2_r = oph_r
        var oph2_i = oph_i
        var opb_r = _real + length * out_stride
        var opb_i = _imag + length * out_stride

        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = 0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0

        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee

        let angle = -T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {

            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride

            let or = op_r.pointee
            let oi = op_i.pointee
            let ohr = oph_r.pointee
            let ohi = oph_i.pointee

            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or

            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1

            let _r1 = 0.5 * (evenreal + _r)
            let _i1 = 0.5 * (_i + evenim)
            let _r2 = 0.5 * (evenreal - _r)
            let _i2 = 0.5 * (_i - evenim)

            op_r.pointee = _r1
            op_i.pointee = _i1
            oph_r.pointee = _r2
            oph_i.pointee = _i2
            oph2_r.pointee = _r2
            oph2_i.pointee = -_i2
            opb_r.pointee = _r1
            opb_i.pointee = -_i1

            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

@inlinable
@inline(__always)
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    _Radix2CooleyTukey(level, real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}

@inlinable
@inline(__always)
func _Radix2CooleyTukey_Orderd<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {

    let count = 1 << level

    do {
        var _r = real
        var _i = imag
        let m_stride = stride << 4
        for _ in Swift.stride(from: 0, to: count, by: 16) {
            Radix2CooleyTukey_Orderd_16(_r, _i, stride)
            _r += m_stride
            _i += m_stride
        }
    }

    for s in 4..<level {

        let m = 2 << s
        let n = 1 << s

        let angle = -T.pi / T(n)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)

        let m_stride = m * stride
        let n_stride = n * stride

        var r1 = real
        var i1 = imag

        for _ in Swift.stride(from: 0, to: count, by: m) {

            var _cos1 = 1 as T
            var _sin1 = 0 as T

            var _r1 = r1
            var _i1 = i1
            var _r2 = r1 + n_stride
            var _i2 = i1 + n_stride

            for _ in 0..<n {

                let ur = _r1.pointee
                let ui = _i1.pointee
                let vr = _r2.pointee
                let vi = _i2.pointee

                let vrc = vr * _cos1
                let vic = vi * _cos1
                let vrs = vr * _sin1
                let vis = vi * _sin1

                let _c = _cos * _cos1 - _sin * _sin1
                let _s = _cos * _sin1 + _sin * _cos1
                _cos1 = _c
                _sin1 = _s

                _r1.pointee = ur + vrc - vis
                _i1.pointee = ui + vrs + vic
                _r2.pointee = ur - vrc + vis
                _i2.pointee = ui - vrs - vic

                _r1 += stride
                _i1 += stride
                _r2 += stride
                _i2 += stride
            }

            r1 += m_stride
            i1 += m_stride
        }
    }
}

@inlinable
@inline(__always)
func _Radix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0:
        _real.pointee = in_count.0 == 0 ? 0 : real.pointee
        _imag.pointee = in_count.1 == 0 ? 0 : imag.pointee

    case 1:
        _Radix2CooleyTukey_2(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        _Radix2CooleyTukey_4(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 3:
        _Radix2CooleyTukey_8(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 4:
        _Radix2CooleyTukey_16(real, imag, in_stride, in_count, _real, _imag, out_stride)

    default:
        let count = 1 << level

        if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
            var _real = _real
            var _imag = _imag
            for _ in 0..<count {
                _real.pointee = 0
                _imag.pointee = 0
                _real += out_stride
                _imag += out_stride
            }
            return
        }

        let offset = Int.bitWidth - level

        do {
            var real = real
            var imag = imag
            for i in 0..<count {
                let _i = Int(UInt(i).reverse >> offset)
                _real[_i * out_stride] = i < in_count.0 ? real.pointee : 0
                _imag[_i * out_stride] = i < in_count.1 ? imag.pointee : 0
                real += in_stride
                imag += in_stride
            }
        }

        _Radix2CooleyTukey_Orderd(level, _real, _imag, out_stride)
    }
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0

    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
    case 3:
        InverseRadix2CooleyTukey_8(input, in_stride, in_count, _real, _imag, out_stride)
    case 4:
        InverseRadix2CooleyTukey_16(input, in_stride, in_count, _real, _imag, out_stride)

    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2

        if _slowPath(in_count == 0) {
            var _real = _real
            var _imag = _imag
            for _ in 0..<length {
                _real.pointee = 0
                _imag.pointee = 0
                _real += out_stride
                _imag += out_stride
            }
            return
        }

        let _in_count = in_count >> 1
        _InverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, (_in_count + in_count & 1, _in_count), _real, _imag, out_stride)

        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        var oph2_r = oph_r
        var oph2_i = oph_i
        var opb_r = _real + length * out_stride
        var opb_i = _imag + length * out_stride

        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = 0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0

        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee

        let angle = T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {

            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride

            let or = op_r.pointee
            let oi = op_i.pointee
            let ohr = oph_r.pointee
            let ohi = oph_i.pointee

            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or

            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1

            let _r1 = 0.5 * (evenreal + _r)
            let _i1 = 0.5 * (_i + evenim)
            let _r2 = 0.5 * (evenreal - _r)
            let _i2 = 0.5 * (_i - evenim)

            op_r.pointee = _r1
            op_i.pointee = _i1
            oph_r.pointee = _r2
            oph_i.pointee = _i2
            oph2_r.pointee = _r2
            oph2_i.pointee = -_i2
            opb_r.pointee = _r1
            opb_i.pointee = -_i1

            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

@inlinable
@inline(__always)
func _InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    _Radix2CooleyTukey(level, imag, real, in_stride, (in_count.1, in_count.0), _imag, _real, out_stride)
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    Radix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

@inlinable
@inline(__always)
public func Radix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {

    switch level {

    case 0: break

    case 1:
        Radix2CooleyTukey_2(real, imag, stride, 1 << level, real, imag, stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, stride, 1 << level, real, imag, stride)
    case 3:
        Radix2CooleyTukey_8(real, imag, stride, 1 << level, real, imag, stride)
    case 4:
        Radix2CooleyTukey_16(real, imag, stride, 1 << level, real, imag, stride)

    default:
        let count = 1 << level

        do {
            let offset = Int.bitWidth - level
            var _real = real
            var _imag = imag
            for i in 1..<count - 1 {
                let _i = Int(UInt(i).reverse >> offset)
                _real += stride
                _imag += stride
                if i < _i {
                    swap(&_real.pointee, &real[_i * stride])
                    swap(&_imag.pointee, &imag[_i * stride])
                }
            }
        }

        _Radix2CooleyTukey_Orderd(level, real, imag, stride)
    }
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {

    Radix2CooleyTukey(level, imag, real, stride)
}

// MARK: Fixed Length Cooley-Tukey

@inlinable
@inline(__always)
func HalfRadix2CooleyTukey_2<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>) {

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    var input = input

    let a = input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0

    _real.pointee = a + b
    _imag.pointee = a - b
}
@inlinable
@inline(__always)
func HalfRadix2CooleyTukey_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a =  input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c = in_count > 2 ? input.pointee : 0
    input += in_stride

    let d = in_count > 3 ? input.pointee : 0

    let e = a + c
    let f = b + d

    _real.pointee = e + f
    _imag.pointee = e - f
    _real += out_stride
    _imag += out_stride

    _real.pointee = a - c
    _imag.pointee = d - b
}
@inlinable
@inline(__always)
func HalfRadix2CooleyTukey_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let e1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 7 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (f3 + h3)

    _real.pointee = a5 + e5
    _imag.pointee = a5 - e5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 + i
    _imag.pointee = -d3 - j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5
    _imag.pointee = -g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 - i
    _imag.pointee = d3 - j
    _real += out_stride
    _imag += out_stride
}
@inlinable
@inline(__always)
func HalfRadix2CooleyTukey_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let i1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let e1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let m1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let k1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let o1 = in_count > 7 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 8 ? input.pointee : 0
    input += in_stride

    let j1 = in_count > 9 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 10 ? input.pointee : 0
    input += in_stride

    let n1 = in_count > 11 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 12 ? input.pointee : 0
    input += in_stride

    let l1 = in_count > 13 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 14 ? input.pointee : 0
    input += in_stride

    let p1 = in_count > 15 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    let i3 = i1 + j1
    let j3 = i1 - j1
    let k3 = k1 + l1
    let l3 = k1 - l1
    let m3 = m1 + n1
    let n3 = m1 - n1
    let o3 = o1 + p1
    let p3 = o1 - p1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    let i5 = i3 + k3
    let k5 = i3 - k3
    let m5 = m3 + o3
    let o5 = m3 - o3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f3 - h3)
    let r = M_SQRT1_2 * (h3 + f3)
    let w = M_SQRT1_2 * (n3 - p3)
    let x = M_SQRT1_2 * (p3 + n3)

    let a7 = a5 + e5
    let b7 = b3 + q
    let b8 = d3 + r
    let d7 = b3 - q
    let d8 = d3 - r
    let e7 = a5 - e5
    let i7 = i5 + m5
    let p7 = j3 + w
    let j8 = l3 + x
    let l7 = j3 - w
    let l8 = l3 - x
    let m7 = i5 - m5

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k5 - o5)
    let r2 = M_SQRT1_2 * (k5 + o5)
    let w2 = M_COS_22_5 * p7 - M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 + M_SIN_22_5 * p7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7

    _real.pointee = a7 + i7
    _imag.pointee = a7 - i7
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = -b8 - w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + q2
    _imag.pointee = -g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7
    _imag.pointee = -m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = x3 - d8
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - q2
    _imag.pointee = g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
}

@inlinable
@inline(__always)
func HalfInverseRadix2CooleyTukey_2<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var output = output

    if _slowPath(in_count == 0) {
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }

    let a = real.pointee
    let b = imag.pointee

    output.pointee = a + b
    output += out_stride

    output.pointee = a - b
}
@inlinable
@inline(__always)
func HalfInverseRadix2CooleyTukey_4<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var output = output

    if _slowPath(in_count == 0) {
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }

    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride

    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0

    let e = a + b
    let f = a - b
    let g = c + c
    let h = d + d

    output.pointee = e + g
    output += out_stride

    output.pointee = f - h
    output += out_stride

    output.pointee = e - g
    output += out_stride

    output.pointee = f + h
}
@inlinable
@inline(__always)
func HalfInverseRadix2CooleyTukey_8<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var output = output

    if _slowPath(in_count == 0) {
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }

    let a1 = real.pointee
    let b1 = imag.pointee
    real += in_stride
    imag += in_stride

    let e1 = in_count > 1 ? real.pointee : 0
    let e2 = in_count > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let c1 = in_count > 2 ? real.pointee : 0
    let c2 = in_count > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let g1 = in_count > 3 ? real.pointee : 0
    let g2 = in_count > 3 ? imag.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + c1
    let d4 = c2 + c2
    let e3 = e1 + g1
    let e4 = e2 - g2
    let f3 = e1 - g1
    let f4 = e2 + g2
    let g3 = g1 + e1
    let g4 = g2 - e2
    let h3 = g1 - e1
    let h4 = g2 + e2

    let a5 = a3 + c3
    let b5 = b3 - d4
    let c5 = a3 - c3
    let d5 = b3 + d4
    let e5 = e3 + g3
    let f5 = f3 - h4
    let f6 = f4 + h3
    let g6 = e4 - g4
    let h5 = f3 + h4
    let h6 = f4 - h3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let i = M_SQRT1_2 * (f5 - f6)
    let k = M_SQRT1_2 * (h5 + h6)

    output.pointee = a5 + e5
    output += out_stride

    output.pointee = b5 + i
    output += out_stride

    output.pointee = c5 - g6
    output += out_stride

    output.pointee = d5 - k
    output += out_stride

    output.pointee = a5 - e5
    output += out_stride

    output.pointee = b5 - i
    output += out_stride

    output.pointee = c5 + g6
    output += out_stride

    output.pointee = d5 + k
}
@inlinable
@inline(__always)
func HalfInverseRadix2CooleyTukey_16<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var output = output

    if _slowPath(in_count == 0) {
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        output += out_stride
        output.pointee = 0
        return
    }

    let a1 = real.pointee
    let b1 = imag.pointee
    real += in_stride
    imag += in_stride

    let i1 = in_count > 1 ? real.pointee : 0
    let i2 = in_count > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let e1 = in_count > 2 ? real.pointee : 0
    let e2 = in_count > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let m1 = in_count > 3 ? real.pointee : 0
    let m2 = in_count > 3 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let c1 = in_count > 4 ? real.pointee : 0
    let c2 = in_count > 4 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let k1 = in_count > 5 ? real.pointee : 0
    let k2 = in_count > 5 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let g1 = in_count > 6 ? real.pointee : 0
    let g2 = in_count > 6 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let o1 = in_count > 7 ? real.pointee : 0
    let o2 = in_count > 7 ? imag.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + c1
    let d4 = c2 + c2
    let e3 = e1 + g1
    let e4 = e2 - g2
    let f3 = e1 - g1
    let f4 = e2 + g2
    let g3 = g1 + e1
    let g4 = g2 - e2
    let h3 = g1 - e1
    let h4 = g2 + e2
    let i3 = i1 + o1
    let i4 = i2 - o2
    let j3 = i1 - o1
    let j4 = i2 + o2
    let k3 = k1 + m1
    let k4 = k2 - m2
    let l3 = k1 - m1
    let l4 = k2 + m2
    let m3 = m1 + k1
    let m4 = m2 - k2
    let n3 = m1 - k1
    let n4 = m2 + k2
    let o3 = o1 + i1
    let o4 = o2 - i2
    let p3 = o1 - i1
    let p4 = o2 + i2

    let a5 = a3 + c3
    let b5 = b3 + d4
    let c5 = a3 - c3
    let d5 = b3 - d4
    let e5 = e3 + g3
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3
    let i5 = i3 + k3
    let i6 = i4 + k4
    let j5 = j3 + l4
    let j6 = j4 - l3
    let k5 = i3 - k3
    let k6 = i4 - k4
    let l5 = j3 - l4
    let l6 = j4 + l3
    let m5 = m3 + o3
    let m6 = m4 + o4
    let n5 = n3 + p4
    let n6 = n4 - p3
    let o5 = m3 - o3
    let o6 = m4 - o4
    let p5 = n3 - p4
    let p6 = n4 + p3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f5 + f6)
    let s = M_SQRT1_2 * (h5 - h6)
    let w = M_SQRT1_2 * (n5 + n6)
    let x = M_SQRT1_2 * (n6 - n5)
    let y = M_SQRT1_2 * (p5 - p6)
    let z = M_SQRT1_2 * (p6 + p5)

    let a7 = a5 + e5
    let b7 = d5 + s
    let c7 = c5 - g6
    let d7 = b5 - q
    let e7 = a5 - e5
    let f7 = d5 - s
    let g7 = c5 + g6
    let h7 = b5 + q
    let i7 = i5 + m5
    let j7 = l5 + y
    let j8 = l6 + z
    let k7 = k5 - o6
    let k8 = k6 + o5
    let l7 = j5 - w
    let l8 = j6 - x
    let m8 = i6 - m6
    let n7 = l5 - y
    let n8 = l6 - z
    let o7 = k5 + o6
    let o8 = k6 - o5
    let p7 = j5 + w
    let p8 = j6 + x

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k7 - k8)
    let s2 = M_SQRT1_2 * (o8 + o7)
    let w2 = M_COS_22_5 * j7 - M_SIN_22_5 * j8
    let x2 = M_SIN_22_5 * l7 - M_COS_22_5 * l8
    let y2 = -M_COS_22_5 * n8 - M_SIN_22_5 * n7
    let z2 = -M_SIN_22_5 * p8 - M_COS_22_5 * p7

    output.pointee = a7 + i7
    output += out_stride

    output.pointee = b7 + w2
    output += out_stride

    output.pointee = c7 + q2
    output += out_stride

    output.pointee = d7 + x2
    output += out_stride

    output.pointee = e7 - m8
    output += out_stride

    output.pointee = f7 + y2
    output += out_stride

    output.pointee = g7 - s2
    output += out_stride

    output.pointee = h7 + z2
    output += out_stride

    output.pointee = a7 - i7
    output += out_stride

    output.pointee = b7 - w2
    output += out_stride

    output.pointee = c7 - q2
    output += out_stride

    output.pointee = d7 - x2
    output += out_stride

    output.pointee = e7 + m8
    output += out_stride

    output.pointee = f7 - y2
    output += out_stride

    output.pointee = g7 + s2
    output += out_stride

    output.pointee = h7 - z2
}
@inlinable
@inline(__always)
func Radix2CooleyTukey_2<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0

    _real.pointee = a + b
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = a - b
    _imag.pointee = 0

}
@inlinable
@inline(__always)
func Radix2CooleyTukey_2<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    _Radix2CooleyTukey_2(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_2<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride

    let c = in_count.0 > 1 ? real.pointee : 0
    let d = in_count.1 > 1 ? imag.pointee : 0

    _real.pointee = a + c
    _imag.pointee = b + d
    _real += out_stride
    _imag += out_stride

    _real.pointee = a - c
    _imag.pointee = b - d

}
@inlinable
@inline(__always)
func Radix2CooleyTukey_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c = in_count > 2 ? input.pointee : 0
    input += in_stride

    let d = in_count > 3 ? input.pointee : 0

    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d

    _real.pointee = e + g
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = f
    _imag.pointee = -h
    _real += out_stride
    _imag += out_stride

    _real.pointee = e - g
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = f
    _imag.pointee = h
}

@inlinable
@inline(__always)
func Radix2CooleyTukey_4<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    _Radix2CooleyTukey_4(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_4<T: FloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride

    let c = in_count.0 > 1 ? real.pointee : 0
    let d = in_count.1 > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let e = in_count.0 > 2 ? real.pointee : 0
    let f = in_count.1 > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let g = in_count.0 > 3 ? real.pointee : 0
    let h = in_count.1 > 3 ? imag.pointee : 0

    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h

    _real.pointee = i + m
    _imag.pointee = j + n
    _real += out_stride
    _imag += out_stride

    _real.pointee = k + p
    _imag.pointee = l - o
    _real += out_stride
    _imag += out_stride

    _real.pointee = i - m
    _imag.pointee = j - n
    _real += out_stride
    _imag += out_stride

    _real.pointee = k - p
    _imag.pointee = l + o
}

@inlinable
@inline(__always)
func Radix2CooleyTukey_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let e1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 7 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (f3 + h3)

    _real.pointee = a5 + e5
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 + i
    _imag.pointee = -d3 - j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5
    _imag.pointee = -g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 - i
    _imag.pointee = d3 - j
    _real += out_stride
    _imag += out_stride

    _real.pointee = a5 - e5
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 - i
    _imag.pointee = j - d3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5
    _imag.pointee = g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 + i
    _imag.pointee = d3 + j
}

@inlinable
@inline(__always)
func Radix2CooleyTukey_8<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    _Radix2CooleyTukey_8(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_8<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = real.pointee
    let a2 = imag.pointee
    real += in_stride
    imag += in_stride

    let e1 = in_count.0 > 1 ? real.pointee : 0
    let e2 = in_count.1 > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let c1 = in_count.0 > 2 ? real.pointee : 0
    let c2 = in_count.1 > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let g1 = in_count.0 > 3 ? real.pointee : 0
    let g2 = in_count.1 > 3 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let b1 = in_count.0 > 4 ? real.pointee : 0
    let b2 = in_count.1 > 4 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let f1 = in_count.0 > 5 ? real.pointee : 0
    let f2 = in_count.1 > 5 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let d1 = in_count.0 > 6 ? real.pointee : 0
    let d2 = in_count.1 > 6 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let h1 = in_count.0 > 7 ? real.pointee : 0
    let h2 = in_count.1 > 7 ? imag.pointee : 0

    let a3 = a1 + b1
    let a4 = a2 + b2
    let b3 = a1 - b1
    let b4 = a2 - b2
    let c3 = c1 + d1
    let c4 = c2 + d2
    let d3 = c1 - d1
    let d4 = c2 - d2
    let e3 = e1 + f1
    let e4 = e2 + f2
    let f3 = e1 - f1
    let f4 = e2 - f2
    let g3 = g1 + h1
    let g4 = g2 + h2
    let h3 = g1 - h1
    let h4 = g2 - h2

    let a5 = a3 + c3
    let a6 = a4 + c4
    let b5 = b3 + d4
    let b6 = b4 - d3
    let c5 = a3 - c3
    let c6 = a4 - c4
    let d5 = b3 - d4
    let d6 = b4 + d3
    let e5 = e3 + g3
    let e6 = e4 + g4
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g5 = e3 - g3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let i = M_SQRT1_2 * (f5 + f6)
    let j = M_SQRT1_2 * (f6 - f5)
    let k = M_SQRT1_2 * (h5 - h6)
    let l = M_SQRT1_2 * (h6 + h5)

    _real.pointee = a5 + e5
    _imag.pointee = a6 + e6
    _real += out_stride
    _imag += out_stride

    _real.pointee = b5 + i
    _imag.pointee = b6 + j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + g6
    _imag.pointee = c6 - g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = d5 - k
    _imag.pointee = d6 - l
    _real += out_stride
    _imag += out_stride

    _real.pointee = a5 - e5
    _imag.pointee = a6 - e6
    _real += out_stride
    _imag += out_stride

    _real.pointee = b5 - i
    _imag.pointee = b6 - j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - g6
    _imag.pointee = c6 + g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = d5 + k
    _imag.pointee = d6 + l
}
@inlinable
@inline(__always)
func Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let i1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let e1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let m1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let k1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let o1 = in_count > 7 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 8 ? input.pointee : 0
    input += in_stride

    let j1 = in_count > 9 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 10 ? input.pointee : 0
    input += in_stride

    let n1 = in_count > 11 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 12 ? input.pointee : 0
    input += in_stride

    let l1 = in_count > 13 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 14 ? input.pointee : 0
    input += in_stride

    let p1 = in_count > 15 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    let i3 = i1 + j1
    let j3 = i1 - j1
    let k3 = k1 + l1
    let l3 = k1 - l1
    let m3 = m1 + n1
    let n3 = m1 - n1
    let o3 = o1 + p1
    let p3 = o1 - p1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    let i5 = i3 + k3
    let k5 = i3 - k3
    let m5 = m3 + o3
    let o5 = m3 - o3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f3 - h3)
    let r = M_SQRT1_2 * (h3 + f3)
    let w = M_SQRT1_2 * (n3 - p3)
    let x = M_SQRT1_2 * (p3 + n3)

    let a7 = a5 + e5
    let b7 = b3 + q
    let b8 = d3 + r
    let d7 = b3 - q
    let d8 = d3 - r
    let e7 = a5 - e5
    let i7 = i5 + m5
    let p7 = j3 + w
    let j8 = l3 + x
    let l7 = j3 - w
    let l8 = l3 - x
    let m7 = i5 - m5

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k5 - o5)
    let r2 = M_SQRT1_2 * (k5 + o5)
    let w2 = M_COS_22_5 * p7 - M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 + M_SIN_22_5 * p7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7

    _real.pointee = a7 + i7
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = -b8 - w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + q2
    _imag.pointee = -g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7
    _imag.pointee = -m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = x3 - d8
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - q2
    _imag.pointee = g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = a7 - i7
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = w3 - b8
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - q2
    _imag.pointee = r2 - g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = d8 - x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7
    _imag.pointee = m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = -x3 - d8
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + q2
    _imag.pointee = g5 + r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
}
@inlinable
@inline(__always)
func Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    _Radix2CooleyTukey_16(real, imag, in_stride, (in_count, in_count), _real, _imag, out_stride)
}
@inlinable
@inline(__always)
func _Radix2CooleyTukey_16<T: BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count.0 == 0 && in_count.1 == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = real.pointee
    let a2 = imag.pointee
    real += in_stride
    imag += in_stride

    let i1 = in_count.0 > 1 ? real.pointee : 0
    let i2 = in_count.1 > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let e1 = in_count.0 > 2 ? real.pointee : 0
    let e2 = in_count.1 > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let m1 = in_count.0 > 3 ? real.pointee : 0
    let m2 = in_count.1 > 3 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let c1 = in_count.0 > 4 ? real.pointee : 0
    let c2 = in_count.1 > 4 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let k1 = in_count.0 > 5 ? real.pointee : 0
    let k2 = in_count.1 > 5 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let g1 = in_count.0 > 6 ? real.pointee : 0
    let g2 = in_count.1 > 6 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let o1 = in_count.0 > 7 ? real.pointee : 0
    let o2 = in_count.1 > 7 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let b1 = in_count.0 > 8 ? real.pointee : 0
    let b2 = in_count.1 > 8 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let j1 = in_count.0 > 9 ? real.pointee : 0
    let j2 = in_count.1 > 9 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let f1 = in_count.0 > 10 ? real.pointee : 0
    let f2 = in_count.1 > 10 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let n1 = in_count.0 > 11 ? real.pointee : 0
    let n2 = in_count.1 > 11 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let d1 = in_count.0 > 12 ? real.pointee : 0
    let d2 = in_count.1 > 12 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let l1 = in_count.0 > 13 ? real.pointee : 0
    let l2 = in_count.1 > 13 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let h1 = in_count.0 > 14 ? real.pointee : 0
    let h2 = in_count.1 > 14 ? imag.pointee : 0
    real += in_stride
    imag += in_stride

    let p1 = in_count.0 > 15 ? real.pointee : 0
    let p2 = in_count.1 > 15 ? imag.pointee : 0

    let a3 = a1 + b1
    let a4 = a2 + b2
    let b3 = a1 - b1
    let b4 = a2 - b2
    let c3 = c1 + d1
    let c4 = c2 + d2
    let d3 = c1 - d1
    let d4 = c2 - d2
    let e3 = e1 + f1
    let e4 = e2 + f2
    let f3 = e1 - f1
    let f4 = e2 - f2
    let g3 = g1 + h1
    let g4 = g2 + h2
    let h3 = g1 - h1
    let h4 = g2 - h2
    let i3 = i1 + j1
    let i4 = i2 + j2
    let j3 = i1 - j1
    let j4 = i2 - j2
    let k3 = k1 + l1
    let k4 = k2 + l2
    let l3 = k1 - l1
    let l4 = k2 - l2
    let m3 = m1 + n1
    let m4 = m2 + n2
    let n3 = m1 - n1
    let n4 = m2 - n2
    let o3 = o1 + p1
    let o4 = o2 + p2
    let p3 = o1 - p1
    let p4 = o2 - p2

    let a5 = a3 + c3
    let a6 = a4 + c4
    let b5 = b3 + d4
    let b6 = b4 - d3
    let c5 = a3 - c3
    let c6 = a4 - c4
    let d5 = b3 - d4
    let d6 = b4 + d3
    let e5 = e3 + g3
    let e6 = e4 + g4
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g5 = e3 - g3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3
    let i5 = i3 + k3
    let i6 = i4 + k4
    let j5 = j3 + l4
    let j6 = j4 - l3
    let k5 = i3 - k3
    let k6 = i4 - k4
    let l5 = j3 - l4
    let l6 = j4 + l3
    let m5 = m3 + o3
    let m6 = m4 + o4
    let n5 = n3 + p4
    let n6 = n4 - p3
    let o5 = m3 - o3
    let o6 = m4 - o4
    let p5 = n3 - p4
    let p6 = n4 + p3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f5 + f6)
    let r = M_SQRT1_2 * (f6 - f5)
    let s = M_SQRT1_2 * (h5 - h6)
    let t = M_SQRT1_2 * (h6 + h5)
    let w = M_SQRT1_2 * (n5 + n6)
    let x = M_SQRT1_2 * (n6 - n5)
    let y = M_SQRT1_2 * (p5 - p6)
    let z = M_SQRT1_2 * (p6 + p5)

    let a7 = a5 + e5
    let a8 = a6 + e6
    let b7 = b5 + q
    let b8 = b6 + r
    let c7 = c5 + g6
    let c8 = c6 - g5
    let d7 = d5 - s
    let d8 = d6 - t
    let e7 = a5 - e5
    let e8 = a6 - e6
    let f7 = b5 - q
    let f8 = b6 - r
    let g7 = c5 - g6
    let g8 = c6 + g5
    let h7 = d5 + s
    let h8 = d6 + t
    let i7 = i5 + m5
    let i8 = i6 + m6
    let j7 = j5 + w
    let j8 = j6 + x
    let k7 = k5 + o6
    let k8 = k6 - o5
    let l7 = l5 - y
    let l8 = l6 - z
    let m7 = i5 - m5
    let m8 = i6 - m6
    let n7 = j5 - w
    let n8 = j6 - x
    let o7 = k5 - o6
    let o8 = k6 + o5
    let p7 = l5 + y
    let p8 = l6 + z

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k7 + k8)
    let r2 = M_SQRT1_2 * (k8 - k7)
    let s2 = M_SQRT1_2 * (o8 - o7)
    let t2 = M_SQRT1_2 * (o7 + o8)
    let w2 = M_COS_22_5 * j7 + M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 - M_SIN_22_5 * j7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7
    let y2 = M_COS_22_5 * n8 - M_SIN_22_5 * n7
    let y3 = M_COS_22_5 * n7 + M_SIN_22_5 * n8
    let z2 = M_SIN_22_5 * p8 - M_COS_22_5 * p7
    let z3 = M_SIN_22_5 * p7 + M_COS_22_5 * p8

    _real.pointee = a7 + i7
    _imag.pointee = a8 + i8
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c7 + q2
    _imag.pointee = c8 + r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7 + m8
    _imag.pointee = e8 - m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = f7 + y2
    _imag.pointee = f8 - y3
    _real += out_stride
    _imag += out_stride

    _real.pointee = g7 + s2
    _imag.pointee = g8 - t2
    _real += out_stride
    _imag += out_stride

    _real.pointee = h7 + z2
    _imag.pointee = h8 - z3
    _real += out_stride
    _imag += out_stride

    _real.pointee = a7 - i7
    _imag.pointee = a8 - i8
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c7 - q2
    _imag.pointee = c8 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = d8 - x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7 - m8
    _imag.pointee = e8 + m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = f7 - y2
    _imag.pointee = f8 + y3
    _real += out_stride
    _imag += out_stride

    _real.pointee = g7 - s2
    _imag.pointee = g8 + t2
    _real += out_stride
    _imag += out_stride

    _real.pointee = h7 - z2
    _imag.pointee = h8 + z3
}

@inlinable
@inline(__always)
func Radix2CooleyTukey_Orderd_16<T: BinaryFloatingPoint>(_ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {

    var real = real
    var imag = imag
    var _real = real
    var _imag = imag

    let a1 = real.pointee
    let a2 = imag.pointee
    real += stride
    imag += stride

    let b1 = real.pointee
    let b2 = imag.pointee
    real += stride
    imag += stride

    let c1 = real.pointee
    let c2 = imag.pointee
    real += stride
    imag += stride

    let d1 = real.pointee
    let d2 = imag.pointee
    real += stride
    imag += stride

    let e1 = real.pointee
    let e2 = imag.pointee
    real += stride
    imag += stride

    let f1 = real.pointee
    let f2 = imag.pointee
    real += stride
    imag += stride

    let g1 = real.pointee
    let g2 = imag.pointee
    real += stride
    imag += stride

    let h1 = real.pointee
    let h2 = imag.pointee
    real += stride
    imag += stride

    let i1 = real.pointee
    let i2 = imag.pointee
    real += stride
    imag += stride

    let j1 = real.pointee
    let j2 = imag.pointee
    real += stride
    imag += stride

    let k1 = real.pointee
    let k2 = imag.pointee
    real += stride
    imag += stride

    let l1 = real.pointee
    let l2 = imag.pointee
    real += stride
    imag += stride

    let m1 = real.pointee
    let m2 = imag.pointee
    real += stride
    imag += stride

    let n1 = real.pointee
    let n2 = imag.pointee
    real += stride
    imag += stride

    let o1 = real.pointee
    let o2 = imag.pointee
    real += stride
    imag += stride

    let p1 = real.pointee
    let p2 = imag.pointee

    let a3 = a1 + b1
    let a4 = a2 + b2
    let b3 = a1 - b1
    let b4 = a2 - b2
    let c3 = c1 + d1
    let c4 = c2 + d2
    let d3 = c1 - d1
    let d4 = c2 - d2
    let e3 = e1 + f1
    let e4 = e2 + f2
    let f3 = e1 - f1
    let f4 = e2 - f2
    let g3 = g1 + h1
    let g4 = g2 + h2
    let h3 = g1 - h1
    let h4 = g2 - h2
    let i3 = i1 + j1
    let i4 = i2 + j2
    let j3 = i1 - j1
    let j4 = i2 - j2
    let k3 = k1 + l1
    let k4 = k2 + l2
    let l3 = k1 - l1
    let l4 = k2 - l2
    let m3 = m1 + n1
    let m4 = m2 + n2
    let n3 = m1 - n1
    let n4 = m2 - n2
    let o3 = o1 + p1
    let o4 = o2 + p2
    let p3 = o1 - p1
    let p4 = o2 - p2

    let a5 = a3 + c3
    let a6 = a4 + c4
    let b5 = b3 + d4
    let b6 = b4 - d3
    let c5 = a3 - c3
    let c6 = a4 - c4
    let d5 = b3 - d4
    let d6 = b4 + d3
    let e5 = e3 + g3
    let e6 = e4 + g4
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g5 = e3 - g3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3
    let i5 = i3 + k3
    let i6 = i4 + k4
    let j5 = j3 + l4
    let j6 = j4 - l3
    let k5 = i3 - k3
    let k6 = i4 - k4
    let l5 = j3 - l4
    let l6 = j4 + l3
    let m5 = m3 + o3
    let m6 = m4 + o4
    let n5 = n3 + p4
    let n6 = n4 - p3
    let o5 = m3 - o3
    let o6 = m4 - o4
    let p5 = n3 - p4
    let p6 = n4 + p3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f5 + f6)
    let r = M_SQRT1_2 * (f6 - f5)
    let s = M_SQRT1_2 * (h5 - h6)
    let t = M_SQRT1_2 * (h6 + h5)
    let w = M_SQRT1_2 * (n5 + n6)
    let x = M_SQRT1_2 * (n6 - n5)
    let y = M_SQRT1_2 * (p5 - p6)
    let z = M_SQRT1_2 * (p6 + p5)

    let a7 = a5 + e5
    let a8 = a6 + e6
    let b7 = b5 + q
    let b8 = b6 + r
    let c7 = c5 + g6
    let c8 = c6 - g5
    let d7 = d5 - s
    let d8 = d6 - t
    let e7 = a5 - e5
    let e8 = a6 - e6
    let f7 = b5 - q
    let f8 = b6 - r
    let g7 = c5 - g6
    let g8 = c6 + g5
    let h7 = d5 + s
    let h8 = d6 + t
    let i7 = i5 + m5
    let i8 = i6 + m6
    let j7 = j5 + w
    let j8 = j6 + x
    let k7 = k5 + o6
    let k8 = k6 - o5
    let l7 = l5 - y
    let l8 = l6 - z
    let m7 = i5 - m5
    let m8 = i6 - m6
    let n7 = j5 - w
    let n8 = j6 - x
    let o7 = k5 - o6
    let o8 = k6 + o5
    let p7 = l5 + y
    let p8 = l6 + z

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k7 + k8)
    let r2 = M_SQRT1_2 * (k8 - k7)
    let s2 = M_SQRT1_2 * (o8 - o7)
    let t2 = M_SQRT1_2 * (o7 + o8)
    let w2 = M_COS_22_5 * j7 + M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 - M_SIN_22_5 * j7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_SIN_22_5 * l8 - M_COS_22_5 * l7
    let y2 = M_COS_22_5 * n8 - M_SIN_22_5 * n7
    let y3 = M_COS_22_5 * n7 + M_SIN_22_5 * n8
    let z2 = M_SIN_22_5 * p8 - M_COS_22_5 * p7
    let z3 = M_SIN_22_5 * p7 + M_COS_22_5 * p8

    _real.pointee = a7 + i7
    _imag.pointee = a8 + i8
    _real += stride
    _imag += stride

    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
    _real += stride
    _imag += stride

    _real.pointee = c7 + q2
    _imag.pointee = c8 + r2
    _real += stride
    _imag += stride

    _real.pointee = d7 + x2
    _imag.pointee = d8 + x3
    _real += stride
    _imag += stride

    _real.pointee = e7 + m8
    _imag.pointee = e8 - m7
    _real += stride
    _imag += stride

    _real.pointee = f7 + y2
    _imag.pointee = f8 - y3
    _real += stride
    _imag += stride

    _real.pointee = g7 + s2
    _imag.pointee = g8 - t2
    _real += stride
    _imag += stride

    _real.pointee = h7 + z2
    _imag.pointee = h8 - z3
    _real += stride
    _imag += stride

    _real.pointee = a7 - i7
    _imag.pointee = a8 - i8
    _real += stride
    _imag += stride

    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
    _real += stride
    _imag += stride

    _real.pointee = c7 - q2
    _imag.pointee = c8 - r2
    _real += stride
    _imag += stride

    _real.pointee = d7 - x2
    _imag.pointee = d8 - x3
    _real += stride
    _imag += stride

    _real.pointee = e7 - m8
    _imag.pointee = e8 + m7
    _real += stride
    _imag += stride

    _real.pointee = f7 - y2
    _imag.pointee = f8 + y3
    _real += stride
    _imag += stride

    _real.pointee = g7 - s2
    _imag.pointee = g8 + t2
    _real += stride
    _imag += stride

    _real.pointee = h7 - z2
    _imag.pointee = h8 + z3
}

@inlinable
@inline(__always)
func InverseRadix2CooleyTukey_2<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0

    _real.pointee = a + b
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = a - b
    _imag.pointee = 0

}
@inlinable
@inline(__always)
func InverseRadix2CooleyTukey_4<T: FloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a = input.pointee
    input += in_stride

    let b = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c = in_count > 2 ? input.pointee : 0
    input += in_stride

    let d = in_count > 3 ? input.pointee : 0

    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d

    _real.pointee = e + g
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = f
    _imag.pointee = h
    _real += out_stride
    _imag += out_stride

    _real.pointee = e - g
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = f
    _imag.pointee = -h
}

@inlinable
@inline(__always)
func InverseRadix2CooleyTukey_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let e1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 7 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (h3 + f3)

    _real.pointee = a5 + e5
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 + i
    _imag.pointee = d3 + j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5
    _imag.pointee = g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 - i
    _imag.pointee = j - d3
    _real += out_stride
    _imag += out_stride

    _real.pointee = a5 - e5
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 - i
    _imag.pointee = d3 - j
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5
    _imag.pointee = -g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b3 + i
    _imag.pointee = -d3 - j
}

@inlinable
@inline(__always)
func InverseRadix2CooleyTukey_16<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {

    var input = input
    var _real = _real
    var _imag = _imag

    if _slowPath(in_count == 0) {
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        _real += out_stride
        _imag += out_stride
        _real.pointee = 0
        _imag.pointee = 0
        return
    }

    let a1 = input.pointee
    input += in_stride

    let i1 = in_count > 1 ? input.pointee : 0
    input += in_stride

    let e1 = in_count > 2 ? input.pointee : 0
    input += in_stride

    let m1 = in_count > 3 ? input.pointee : 0
    input += in_stride

    let c1 = in_count > 4 ? input.pointee : 0
    input += in_stride

    let k1 = in_count > 5 ? input.pointee : 0
    input += in_stride

    let g1 = in_count > 6 ? input.pointee : 0
    input += in_stride

    let o1 = in_count > 7 ? input.pointee : 0
    input += in_stride

    let b1 = in_count > 8 ? input.pointee : 0
    input += in_stride

    let j1 = in_count > 9 ? input.pointee : 0
    input += in_stride

    let f1 = in_count > 10 ? input.pointee : 0
    input += in_stride

    let n1 = in_count > 11 ? input.pointee : 0
    input += in_stride

    let d1 = in_count > 12 ? input.pointee : 0
    input += in_stride

    let l1 = in_count > 13 ? input.pointee : 0
    input += in_stride

    let h1 = in_count > 14 ? input.pointee : 0
    input += in_stride

    let p1 = in_count > 15 ? input.pointee : 0

    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    let i3 = i1 + j1
    let j3 = i1 - j1
    let k3 = k1 + l1
    let l3 = k1 - l1
    let m3 = m1 + n1
    let n3 = m1 - n1
    let o3 = o1 + p1
    let p3 = o1 - p1

    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    let i5 = i3 + k3
    let k5 = i3 - k3
    let m5 = m3 + o3
    let o5 = m3 - o3

    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T

    let q = M_SQRT1_2 * (f3 - h3)
    let r = M_SQRT1_2 * (h3 + f3)
    let w = M_SQRT1_2 * (n3 - p3)
    let x = M_SQRT1_2 * (p3 + n3)

    let a7 = a5 + e5
    let b7 = b3 + q
    let b8 = d3 + r
    let d7 = b3 - q
    let d8 = d3 - r
    let e7 = a5 - e5
    let i7 = i5 + m5
    let j7 = j3 + w
    let j8 = l3 + x
    let l7 = j3 - w
    let l8 = l3 - x
    let m7 = i5 - m5

    let M_SIN_22_5 = 0.3826834323650897717284599840303988667613445624856270 as T
    let M_COS_22_5 = 0.9238795325112867561281831893967882868224166258636424 as T

    let q2 = M_SQRT1_2 * (k5 - o5)
    let r2 = M_SQRT1_2 * (o5 + k5)
    let w2 = M_COS_22_5 * j7 - M_SIN_22_5 * j8
    let w3 = M_COS_22_5 * j8 + M_SIN_22_5 * j7
    let x2 = M_SIN_22_5 * l7 + M_COS_22_5 * l8
    let x3 = M_COS_22_5 * l7 - M_SIN_22_5 * l8

    _real.pointee = a7 + i7
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = b8 + w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + q2
    _imag.pointee = g5 + r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = x3 - d8
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7
    _imag.pointee = m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = d8 + x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - q2
    _imag.pointee = r2 - g5
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = w3 - b8
    _real += out_stride
    _imag += out_stride

    _real.pointee = a7 - i7
    _imag.pointee = 0
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 - w2
    _imag.pointee = b8 - w3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 - q2
    _imag.pointee = g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 - x2
    _imag.pointee = -d8 - x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = e7
    _imag.pointee = -m7
    _real += out_stride
    _imag += out_stride

    _real.pointee = d7 + x2
    _imag.pointee = d8 - x3
    _real += out_stride
    _imag += out_stride

    _real.pointee = c5 + q2
    _imag.pointee = -g5 - r2
    _real += out_stride
    _imag += out_stride

    _real.pointee = b7 + w2
    _imag.pointee = -b8 - w3
}
