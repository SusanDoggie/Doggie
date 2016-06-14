//
//  CooleyTukey.swift
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

// MARK: Half Radix-2 Cooley-Tukey

public func HalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        
        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.pointee = -opf_i.pointee
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
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
}
public func HalfInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = real.pointee
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, 1, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, 2, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        var ip_r = real
        var ip_i = imag
        var iph_r = real + half * in_stride
        var iph_i = imag + half * in_stride
        var tp_r = treal
        var tp_i = timag
        var tph_r = treal + half * tp_stride
        var tph_i = timag + half * tp_stride
        
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
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

public func HalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        
        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.pointee = -opf_i.pointee
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
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
}
public func HalfInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = real.pointee
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, 1, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, 2, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        var ip_r = real
        var ip_i = imag
        var iph_r = real + half * in_stride
        var iph_i = imag + half * in_stride
        var tp_r = treal
        var tp_i = timag
        var tph_r = treal + half * tp_stride
        var tph_i = timag + half * tp_stride
        
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
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

// MARK: Radix-2 Cooley-Tukey

public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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

public func Radix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : real.pointee
        _imag.pointee = in_count == 0 ? 0 : imag.pointee
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
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
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, in_count - in_count >> 1, op_r, op_i, out_stride)
        Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, in_count >> 1, oph_r, oph_i, out_stride)
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1: Float = 1.0
        var _sin1: Float = 0.0
        for _ in 0..<half {
            let tpr = op_r.pointee
            let tpi = op_i.pointee
            let tphr = oph_r.pointee
            let tphi = oph_i.pointee
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.pointee = tpr + tphrc - tphis
            op_i.pointee = tpi + tphrs + tphic
            oph_r.pointee = tpr - tphrc + tphis
            oph_i.pointee = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        InverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee
        
        let angle = Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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

public func InverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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

public func Radix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : real.pointee
        _imag.pointee = in_count == 0 ? 0 : imag.pointee
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
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
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, in_count - in_count >> 1, op_r, op_i, out_stride)
        Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, in_count >> 1, oph_r, oph_i, out_stride)
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = 1.0
        var _sin1 = 0.0
        for _ in 0..<half {
            let tpr = op_r.pointee
            let tpi = op_i.pointee
            let tphr = oph_r.pointee
            let tphi = oph_i.pointee
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.pointee = tpr + tphrc - tphis
            op_i.pointee = tpi + tphrs + tphic
            oph_r.pointee = tpr - tphrc + tphis
            oph_i.pointee = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        InverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee
        
        let angle = M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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

public func InverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

// MARK: Dispatch Half Radix-2 Cooley-Tukey

public func DispatchHalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        
        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.pointee = -opf_i.pointee
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
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
}
public func DispatchHalfInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = real.pointee
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, 1, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, 2, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        var ip_r = real
        var ip_i = imag
        var iph_r = real + half * in_stride
        var iph_i = imag + half * in_stride
        var tp_r = treal
        var tp_i = timag
        var tph_r = treal + half * tp_stride
        var tph_i = timag + half * tp_stride
        
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
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

public func DispatchHalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
        let _out_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + _out_stride
        var oph_i = _imag + _out_stride
        
        let tr = op_r.pointee
        let ti = op_i.pointee
        op_r.pointee = tr + ti
        op_i.pointee = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.pointee = -opf_i.pointee
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
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
}
public func DispatchHalfInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = real.pointee
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, 1, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, 2, output, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        var ip_r = real
        var ip_i = imag
        var iph_r = real + half * in_stride
        var iph_i = imag + half * in_stride
        var tp_r = treal
        var tp_i = timag
        var tph_r = treal + half * tp_stride
        var tph_i = timag + half * tp_stride
        
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
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

// MARK: Dispatch Radix-2 Cooley-Tukey

public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
public func DispatchRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : real.pointee
        _imag.pointee = in_count == 0 ? 0 : imag.pointee
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
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
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        DispatchQueue.concurrentPerform(iterations: 2) {
            switch $0 {
            case 0:
                Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, in_count - in_count >> 1, op_r, op_i, out_stride)
            default:
                Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, in_count >> 1, oph_r, oph_i, out_stride)
            }
        }
        
        let angle = -Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1: Float = 1.0
        var _sin1: Float = 0.0
        for _ in 0..<half {
            let tpr = op_r.pointee
            let tpi = op_i.pointee
            let tphr = oph_r.pointee
            let tphi = oph_i.pointee
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.pointee = tpr + tphrc - tphis
            op_i.pointee = tpi + tphrs + tphic
            oph_r.pointee = tpr - tphrc + tphis
            oph_i.pointee = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchInverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee
        
        let angle = Float(M_PI) / Float(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = opf_i.pointee
        opf_i.pointee = -opf_i.pointee
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
public func DispatchRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : real.pointee
        _imag.pointee = in_count == 0 ? 0 : imag.pointee
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
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
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        DispatchQueue.concurrentPerform(iterations: 2) {
            switch $0 {
            case 0:
                Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, in_count - in_count >> 1, op_r, op_i, out_stride)
            default:
                Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, in_count >> 1, oph_r, oph_i, out_stride)
            }
        }
        
        let angle = -M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = 1.0
        var _sin1 = 0.0
        for _ in 0..<half {
            let tpr = op_r.pointee
            let tpi = op_i.pointee
            let tphr = oph_r.pointee
            let tphi = oph_i.pointee
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.pointee = tpr + tphrc - tphis
            op_i.pointee = tpi + tphrs + tphic
            oph_r.pointee = tpr - tphrc + tphis
            oph_i.pointee = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.pointee = in_count == 0 ? 0 : input.pointee
        _imag.pointee = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, in_count, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, in_count, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        if in_count == 0 {
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
        
        assert(in_count & 1 == 0, "size of input must be multiple of 2.")
        
        DispatchInverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, in_count >> 1, _real, _imag, out_stride)
        
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
        op_i.pointee = 0.0
        oph_r.pointee = tr - ti
        oph_i.pointee = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.pointee = opf_r.pointee
        optf_i.pointee = -opf_i.pointee
        
        let angle = M_PI / Double(half)
        let _cos = cos(angle)
        let _sin = sin(angle)
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
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

// MARK: Number Theoretic Transform

public func Radix2CooleyTukey<U: UnsignedInteger>(_ level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = in_count == 0 ? 0 : mod(input.pointee, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.pointee = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        Radix2CooleyTukey(level - 1, input, in_stride << 1, in_count - in_count >> 1, _alpha_2, m, op, out_stride)
        Radix2CooleyTukey(level - 1, input + in_stride, in_stride << 1, in_count >> 1, _alpha_2, m, oph, out_stride)
        
        var _alpha: U = 1
        let _alpha_k = pow(alpha, U(UIntMax(half)), m)
        for _ in 0..<half {
            let tpr = op.pointee
            let tphr = mulmod(_alpha, oph.pointee, m)
            op.pointee = addmod(tpr, tphr, m)
            oph.pointee = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchRadix2CooleyTukey<U: UnsignedInteger>(_ level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = in_count == 0 ? 0 : mod(input.pointee, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.pointee = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        DispatchQueue.concurrentPerform(iterations: 2) {
            switch $0 {
            case 0:
                Radix2CooleyTukey(level - 1, input, in_stride << 1, in_count - in_count >> 1, _alpha_2, m, op, out_stride)
            default:
                Radix2CooleyTukey(level - 1, input + in_stride, in_stride << 1, in_count >> 1, _alpha_2, m, oph, out_stride)
            }
        }
        
        var _alpha: U = 1
        let _alpha_k = pow(alpha, U(UIntMax(half)), m)
        for _ in 0..<half {
            let tpr = op.pointee
            let tphr = mulmod(_alpha, oph.pointee, m)
            op.pointee = addmod(tpr, tphr, m)
            oph.pointee = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey<U: UnsignedInteger>(_ level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = in_count == 0 ? 0 : mod(input.pointee, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.pointee = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        InverseRadix2CooleyTukey(level - 1, input, in_stride << 1, in_count - in_count >> 1, _alpha_2, m, op, out_stride)
        InverseRadix2CooleyTukey(level - 1, input + in_stride, in_stride << 1, in_count >> 1, _alpha_2, m, oph, out_stride)
        
        let _inverse_alpha = modinv(alpha, m)
        var _alpha: U = 1
        let _alpha_k = modinv(pow(alpha, U(UIntMax(half)), m), m)
        for _ in 0..<half {
            let tpr = op.pointee
            let tphr = mulmod(_alpha, oph.pointee, m)
            op.pointee = addmod(tpr, tphr, m)
            oph.pointee = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, _inverse_alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey<U: UnsignedInteger>(_ level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.pointee = in_count == 0 ? 0 : mod(input.pointee, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.pointee = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        DispatchQueue.concurrentPerform(iterations: 2) {
            switch $0 {
            case 0:
                InverseRadix2CooleyTukey(level - 1, input, in_stride << 1, in_count - in_count >> 1, _alpha_2, m, op, out_stride)
            default:
                InverseRadix2CooleyTukey(level - 1, input + in_stride, in_stride << 1, in_count >> 1, _alpha_2, m, oph, out_stride)
            }
        }
        
        let _inverse_alpha = modinv(alpha, m)
        var _alpha: U = 1
        let _alpha_k = modinv(pow(alpha, U(UIntMax(half)), m), m)
        for _ in 0..<half {
            let tpr = op.pointee
            let tphr = mulmod(_alpha, oph.pointee, m)
            op.pointee = addmod(tpr, tphr, m)
            oph.pointee = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, _inverse_alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

// MARK: Fixed Length Cooley-Tukey

private func HalfRadix2CooleyTukey_2(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>) {
    
    if in_count == 0 {
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
private func HalfRadix2CooleyTukey_4(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
private func HalfInverseRadix2CooleyTukey_2(_ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var output = output
    
    if in_count == 0 {
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
private func HalfInverseRadix2CooleyTukey_4(_ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var output = output
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_2(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_2(_ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
    
    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0
    
    _real.pointee = a + c
    _imag.pointee = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - c
    _imag.pointee = b - d
    
}
private func InverseRadix2CooleyTukey_2(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_4(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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

private func Radix2CooleyTukey_4(_ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
    
    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let e = in_count > 2 ? real.pointee : 0
    let f = in_count > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let g = in_count > 3 ? real.pointee : 0
    let h = in_count > 3 ? imag.pointee : 0
    
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

private func InverseRadix2CooleyTukey_4(_ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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

private func HalfRadix2CooleyTukey_2(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>) {
    
    var input = input
    
    if in_count == 0 {
        _real.pointee = 0
        _imag.pointee = 0
        return
    }
    
    let a = input.pointee
    input += in_stride
    
    let b = in_count > 1 ? input.pointee : 0
    
    _real.pointee = a + b
    _imag.pointee = a - b
}
private func HalfRadix2CooleyTukey_4(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
    let f = b + d
    
    _real.pointee = e + f
    _imag.pointee = e - f
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - c
    _imag.pointee = d - b
}
private func HalfInverseRadix2CooleyTukey_2(_ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var output = output
    
    if in_count == 0 {
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
private func HalfInverseRadix2CooleyTukey_4(_ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var output = output
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_2(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_2(_ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
    
    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0
    
    _real.pointee = a + c
    _imag.pointee = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - c
    _imag.pointee = b - d
    
}
private func InverseRadix2CooleyTukey_2(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
private func Radix2CooleyTukey_4(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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

private func Radix2CooleyTukey_4(_ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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
    
    let c = in_count > 1 ? real.pointee : 0
    let d = in_count > 1 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let e = in_count > 2 ? real.pointee : 0
    let f = in_count > 2 ? imag.pointee : 0
    real += in_stride
    imag += in_stride
    
    let g = in_count > 3 ? real.pointee : 0
    let h = in_count > 3 ? imag.pointee : 0
    
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

private func InverseRadix2CooleyTukey_4(_ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
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

// MARK: Wrapper

public func HalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    HalfRadix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func HalfInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    HalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1)
}
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    Radix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func Radix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    Radix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, _output, _output + 1, out_stride << 1)
}
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    InverseRadix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func InverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    InverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, _output, _output + 1, out_stride << 1)
}
public func DispatchHalfRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func DispatchHalfInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, temp: UnsafePointer<Complex>, tp_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _temp = UnsafeMutablePointer<Double>(temp)
    DispatchHalfInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, output, out_stride, _temp, _temp + 1, tp_stride << 1)
}
public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchRadix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func DispatchRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, _output, _output + 1, out_stride << 1)
}
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchInverseRadix2CooleyTukey(level, input, in_stride, in_count, _output, _output + 1, out_stride << 1)
}
public func DispatchInverseRadix2CooleyTukey(_ level: Int, _ input: UnsafePointer<Complex>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Complex>, _ out_stride: Int) {
    let _input = UnsafePointer<Double>(input)
    let _output = UnsafeMutablePointer<Double>(output)
    DispatchInverseRadix2CooleyTukey(level, _input, _input + 1, in_stride << 1, in_count, _output, _output + 1, out_stride << 1)
}
