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
func _Radix2CooleyTukey_Reorderd<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {
    
    let count = 1 << level
    
    do {
        var _r = real
        var _i = imag
        let m_stride = stride << 4
        for _ in Swift.stride(from: 0, to: count, by: 16) {
            Radix2CooleyTukey_Reorderd_16(_r, _i, stride)
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
        
        _Radix2CooleyTukey_Reorderd(level, _real, _imag, out_stride)
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
        
        _Radix2CooleyTukey_Reorderd(level, real, imag, stride)
    }
}

@inlinable
@inline(__always)
public func InverseRadix2CooleyTukey<T: BinaryFloatingPoint>(_ level: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) where T : FloatingMathProtocol {
    
    Radix2CooleyTukey(level, imag, real, stride)
}
