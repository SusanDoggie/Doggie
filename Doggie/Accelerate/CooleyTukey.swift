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

private let CooleyTukeyDispatchQueue = dispatch_queue_create("com.SusanDoggie.Algorithm.CooleyTukey", DISPATCH_QUEUE_CONCURRENT)

// MARK: Half Radix-2 Cooley-Tukey

public func HalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or
            
            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1
            
            op_r.memory = 0.5 * (evenreal + _r)
            op_i.memory = 0.5 * (_i + evenim)
            oph_r.memory = 0.5 * (evenreal - _r)
            oph_i.memory = 0.5 * (_i - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func HalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
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
        
        let tr = ip_r.memory
        let ti = ip_i.memory
        tp_r.memory = tr + ti
        tp_i.memory = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.memory = ipf_r.memory * 2.0
        tpf_i.memory = -ipf_i.memory * 2.0
        
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
            
            let ir = ip_r.memory
            let ii = ip_i.memory
            let ihr = iph_r.memory
            let ihi = iph_i.memory
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.memory = evenreal - _r
            tp_i.memory = _i + evenim
            tph_r.memory = evenreal + _r
            tph_i.memory = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

public func HalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or
            
            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1
            
            op_r.memory = 0.5 * (evenreal + _r)
            op_i.memory = 0.5 * (_i + evenim)
            oph_r.memory = 0.5 * (evenreal - _r)
            oph_i.memory = 0.5 * (_i - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func HalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
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
        
        let tr = ip_r.memory
        let ti = ip_i.memory
        tp_r.memory = tr + ti
        tp_i.memory = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.memory = ipf_r.memory * 2.0
        tpf_i.memory = -ipf_i.memory * 2.0
        
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
            
            let ir = ip_r.memory
            let ii = ip_i.memory
            let ihr = iph_r.memory
            let ihi = iph_i.memory
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.memory = evenreal - _r
            tp_i.memory = _i + evenim
            tph_r.memory = evenreal + _r
            tph_i.memory = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

// MARK: Radix-2 Cooley-Tukey

public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = opf_i.memory
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

public func Radix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : real.memory
        _imag.memory = in_count == 0 ? 0 : imag.memory
        
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
                _real.memory = 0
                _imag.memory = 0
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
            let tpr = op_r.memory
            let tpi = op_i.memory
            let tphr = oph_r.memory
            let tphi = oph_i.memory
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.memory = tpr + tphrc - tphis
            op_i.memory = tpi + tphrs + tphic
            oph_r.memory = tpr - tphrc + tphis
            oph_i.memory = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = opf_i.memory
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

public func Radix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : real.memory
        _imag.memory = in_count == 0 ? 0 : imag.memory
        
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
                _real.memory = 0
                _imag.memory = 0
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
            let tpr = op_r.memory
            let tpi = op_i.memory
            let tphr = oph_r.memory
            let tphi = oph_i.memory
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.memory = tpr + tphrc - tphis
            op_i.memory = tpi + tphrs + tphic
            oph_r.memory = tpr - tphrc + tphis
            oph_i.memory = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

// MARK: Dispatch Half Radix-2 Cooley-Tukey

public func DispatchHalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or
            
            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1
            
            op_r.memory = 0.5 * (evenreal + _r)
            op_i.memory = 0.5 * (_i + evenim)
            oph_r.memory = 0.5 * (evenreal - _r)
            oph_i.memory = 0.5 * (_i - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchHalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
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
        
        let tr = ip_r.memory
        let ti = ip_i.memory
        tp_r.memory = tr + ti
        tp_i.memory = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.memory = ipf_r.memory * 2.0
        tpf_i.memory = -ipf_i.memory * 2.0
        
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
            
            let ir = ip_r.memory
            let ii = ip_i.memory
            let ihr = iph_r.memory
            let ihi = iph_i.memory
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.memory = evenreal - _r
            tp_i.memory = _i + evenim
            tph_r.memory = evenreal + _r
            tph_i.memory = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

public func DispatchHalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = tr - ti
        
        let opf_i = _imag + fourth * out_stride
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
            let evenreal = or + ohr
            let evenim = oi - ohi
            let oddreal = oi + ohi
            let oddim = ohr - or
            
            let _r = oddreal * _cos1 - oddim * _sin1
            let _i = oddreal * _sin1 + oddim * _cos1
            
            op_r.memory = 0.5 * (evenreal + _r)
            op_i.memory = 0.5 * (_i + evenim)
            oph_r.memory = 0.5 * (evenreal - _r)
            oph_i.memory = 0.5 * (_i - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchHalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
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
        
        let tr = ip_r.memory
        let ti = ip_i.memory
        tp_r.memory = tr + ti
        tp_i.memory = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * tp_stride
        let tpf_i = tp_i + fourth * tp_stride
        tpf_r.memory = ipf_r.memory * 2.0
        tpf_i.memory = -ipf_i.memory * 2.0
        
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
            
            let ir = ip_r.memory
            let ii = ip_i.memory
            let ihr = iph_r.memory
            let ihi = iph_i.memory
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.memory = evenreal - _r
            tp_i.memory = _i + evenim
            tph_r.memory = evenreal + _r
            tph_i.memory = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, length, output, output + out_stride, out_stride << 1)
    }
}

// MARK: Dispatch Radix-2 Cooley-Tukey

public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = opf_i.memory
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : real.memory
        _imag.memory = in_count == 0 ? 0 : imag.memory
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
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
            let tpr = op_r.memory
            let tpi = op_i.memory
            let tphr = oph_r.memory
            let tphi = oph_i.memory
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.memory = tpr + tphrc - tphis
            op_i.memory = tpi + tphrs + tphic
            oph_r.memory = tpr - tphrc + tphis
            oph_i.memory = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = opf_i.memory
        opf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : real.memory
        _imag.memory = in_count == 0 ? 0 : imag.memory
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
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
            let tpr = op_r.memory
            let tpi = op_i.memory
            let tphr = oph_r.memory
            let tphi = oph_i.memory
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.memory = tpr + tphrc - tphis
            op_i.memory = tpi + tphrs + tphic
            oph_r.memory = tpr - tphrc + tphis
            oph_i.memory = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = in_count == 0 ? 0 : input.memory
        _imag.memory = 0.0
        
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
                _real.memory = 0
                _imag.memory = 0
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
        
        let tr = op_r.memory
        let ti = op_i.memory
        op_r.memory = tr + ti
        op_i.memory = 0.0
        oph_r.memory = tr - ti
        oph_i.memory = 0.0
        
        let opf_r = op_r + fourth * out_stride
        let opf_i = op_i + fourth * out_stride
        let optf_r = oph_r + fourth * out_stride
        let optf_i = oph_i + fourth * out_stride
        optf_r.memory = opf_r.memory
        optf_i.memory = -opf_i.memory
        
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
            
            let or = op_r.memory
            let oi = op_i.memory
            let ohr = oph_r.memory
            let ohi = oph_i.memory
            
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
            
            op_r.memory = _r1
            op_i.memory = _i1
            oph_r.memory = _r2
            oph_i.memory = _i2
            oph2_r.memory = _r2
            oph2_i.memory = -_i2
            opb_r.memory = _r1
            opb_i.memory = -_i1
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
    }
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, in_count, _imag, _real, out_stride)
}

// MARK: Number Theoretic Transform

public func Radix2CooleyTukey<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = in_count == 0 ? 0 : mod(input.memory, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.memory = 0
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
            let tpr = op.memory
            let tphr = mulmod(_alpha, oph.memory, m)
            op.memory = addmod(tpr, tphr, m)
            oph.memory = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchRadix2CooleyTukey<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = in_count == 0 ? 0 : mod(input.memory, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.memory = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
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
            let tpr = op.memory
            let tphr = mulmod(_alpha, oph.memory, m)
            op.memory = addmod(tpr, tphr, m)
            oph.memory = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func InverseRadix2CooleyTukey<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = in_count == 0 ? 0 : mod(input.memory, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.memory = 0
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
            let tpr = op.memory
            let tphr = mulmod(_alpha, oph.memory, m)
            op.memory = addmod(tpr, tphr, m)
            oph.memory = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, _inverse_alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

public func DispatchInverseRadix2CooleyTukey<U: UnsignedIntegerType>(level: Int, _ input: UnsafePointer<U>, _ in_stride: Int, _ in_count: Int, _ alpha: U, _ m: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = in_count == 0 ? 0 : mod(input.memory, m)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        if in_count == 0 {
            var output = output
            for _ in 0..<length {
                output.memory = 0
                output += out_stride
            }
            return
        }
        
        var op = output
        var oph = output + half * out_stride
        
        let _alpha_2 = alpha * alpha
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
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
            let tpr = op.memory
            let tphr = mulmod(_alpha, oph.memory, m)
            op.memory = addmod(tpr, tphr, m)
            oph.memory = addmod(tpr, mulmod(_alpha_k, tphr, m), m)
            _alpha = mulmod(_alpha, _inverse_alpha, m)
            op += out_stride
            oph += out_stride
        }
    }
}

// MARK: Fixed Length Cooley-Tukey

private func HalfRadix2CooleyTukey_2(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>) {
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    var input = input
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = a - b
}
private func HalfRadix2CooleyTukey_4(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a =  input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = b + d
    
    _real.memory = e + f
    _imag.memory = e - f
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = d - b
}
private func HalfInverseRadix2CooleyTukey_2(real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var output = output
    
    if in_count == 0 {
        output.memory = 0
        output += out_stride
        output.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    
    output.memory = a + b
    output += out_stride
    
    output.memory = a - b
}
private func HalfInverseRadix2CooleyTukey_4(real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var output = output
    
    if in_count == 0 {
        output.memory = 0
        output += out_stride
        output.memory = 0
        output += out_stride
        output.memory = 0
        output += out_stride
        output.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    
    let e = a + b
    let f = a - b
    let g = c + c
    let h = d + d
    
    output.memory = e + g
    output += out_stride
    
    output.memory = f - h
    output += out_stride
    
    output.memory = e - g
    output += out_stride
    
    output.memory = f + h
}
private func Radix2CooleyTukey_2(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
private func Radix2CooleyTukey_2(real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    
    _real.memory = a + c
    _imag.memory = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = b - d
    
}
private func InverseRadix2CooleyTukey_2(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
private func Radix2CooleyTukey_4(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    _real.memory = e + g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = -h
    _real += out_stride
    _imag += out_stride
    
    _real.memory = e - g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = h
}

private func Radix2CooleyTukey_4(real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    real += in_stride
    imag += in_stride
    
    let e = in_count > 2 ? real.memory : 0
    let f = in_count > 2 ? imag.memory : 0
    real += in_stride
    imag += in_stride
    
    let g = in_count > 3 ? real.memory : 0
    let h = in_count > 3 ? imag.memory : 0
    
    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h
    
    _real.memory = i + m
    _imag.memory = j + n
    _real += out_stride
    _imag += out_stride
    
    _real.memory = k + p
    _imag.memory = l - o
    _real += out_stride
    _imag += out_stride
    
    _real.memory = i - m
    _imag.memory = j - n
    _real += out_stride
    _imag += out_stride
    
    _real.memory = k - p
    _imag.memory = l + o
}

private func InverseRadix2CooleyTukey_4(input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    _real.memory = e + g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = h
    _real += out_stride
    _imag += out_stride
    
    _real.memory = e - g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = -h
}

private func HalfRadix2CooleyTukey_2(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>) {
    
    var input = input
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = a - b
}
private func HalfRadix2CooleyTukey_4(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = b + d
    
    _real.memory = e + f
    _imag.memory = e - f
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = d - b
}
private func HalfInverseRadix2CooleyTukey_2(real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var output = output
    
    if in_count == 0 {
        output.memory = 0
        output += out_stride
        output.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    
    output.memory = a + b
    output += out_stride
    
    output.memory = a - b
}
private func HalfInverseRadix2CooleyTukey_4(real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var output = output
    
    if in_count == 0 {
        output.memory = 0
        output += out_stride
        output.memory = 0
        output += out_stride
        output.memory = 0
        output += out_stride
        output.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    
    let e = a + b
    let f = a - b
    let g = c + c
    let h = d + d
    
    output.memory = e + g
    output += out_stride
    
    output.memory = f - h
    output += out_stride
    
    output.memory = e - g
    output += out_stride
    
    output.memory = f + h
}
private func Radix2CooleyTukey_2(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
private func Radix2CooleyTukey_2(real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    
    _real.memory = a + c
    _imag.memory = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = b - d
    
}
private func InverseRadix2CooleyTukey_2(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
private func Radix2CooleyTukey_4(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    _real.memory = e + g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = -h
    _real += out_stride
    _imag += out_stride
    
    _real.memory = e - g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = h
}

private func Radix2CooleyTukey_4(real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = in_count > 1 ? real.memory : 0
    let d = in_count > 1 ? imag.memory : 0
    real += in_stride
    imag += in_stride
    
    let e = in_count > 2 ? real.memory : 0
    let f = in_count > 2 ? imag.memory : 0
    real += in_stride
    imag += in_stride
    
    let g = in_count > 3 ? real.memory : 0
    let h = in_count > 3 ? imag.memory : 0
    
    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h
    
    _real.memory = i + m
    _imag.memory = j + n
    _real += out_stride
    _imag += out_stride
    
    _real.memory = k + p
    _imag.memory = l - o
    _real += out_stride
    _imag += out_stride
    
    _real.memory = i - m
    _imag.memory = j - n
    _real += out_stride
    _imag += out_stride
    
    _real.memory = k - p
    _imag.memory = l + o
}

private func InverseRadix2CooleyTukey_4(input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    if in_count == 0 {
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        _real += out_stride
        _imag += out_stride
        _real.memory = 0
        _imag.memory = 0
        return
    }
    
    let a = input.memory
    input += in_stride
    
    let b = in_count > 1 ? input.memory : 0
    input += in_stride
    
    let c = in_count > 2 ? input.memory : 0
    input += in_stride
    
    let d = in_count > 3 ? input.memory : 0
    
    let e = a + c
    let f = a - c
    let g = b + d
    let h = b - d
    
    _real.memory = e + g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = h
    _real += out_stride
    _imag += out_stride
    
    _real.memory = e - g
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = f
    _imag.memory = -h
}
