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

public func HalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            op_r.memory = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            op_i.memory = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            oph_r.memory = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            oph_i.memory = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func HalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, output, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride
            
            let evenreal = ip_r.memory + iph_r.memory
            let evenim = ip_i.memory - iph_i.memory
            let oddreal = ip_i.memory + iph_i.memory
            let oddim = iph_r.memory - ip_r.memory
            
            tp_r.memory = -oddreal * _cos1 - oddim * _sin1 + evenreal
            tp_i.memory = oddreal * _sin1 - oddim * _cos1 + evenim
            tph_r.memory = -oddreal * _cos2 + oddim * _sin2 + evenreal
            tph_i.memory = oddreal * _sin2 + oddim * _cos2 - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, output, output + out_stride, out_stride << 1)
    }
}

public func HalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = (out_stride_col << levelCol) >> 1
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    HalfRadix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _real + out_row_offset, out_row_offset << 1)
    HalfRadix2CooleyTukey(levelRow, timag, temp_row_offset, _imag, _imag + out_row_offset, out_row_offset << 1)
    if col_count > 1 {
        for i in 1..<col_count {
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
}

public func HalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = (in_stride_col << levelCol) >> 1
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    let treal2 = output
    let timag2 = output + out_stride_col
    let temp2_row_offset = (out_row_length * out_stride_row) >> 1
    
    HalfInverseRadix2CooleyTukey(levelRow, real, real + in_row_offset, in_row_offset << 1, treal, temp_row_offset, treal2, treal2 + temp2_row_offset, temp2_row_offset << 1)
    HalfInverseRadix2CooleyTukey(levelRow, imag, imag + in_row_offset, in_row_offset << 1, timag, temp_row_offset, timag2, timag2 + temp2_row_offset, temp2_row_offset << 1)
    if col_count > 1 {
        for i in 1..<col_count {
            let _in_col_offset = i * in_stride_col
            let _temp_col_offset = i * temp_stride_col
            InverseRadix2CooleyTukey(levelRow, real + _in_col_offset, imag + _in_col_offset, in_row_offset, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset)
        }
    }
    
    for i in 0..<row_count {
        let _temp_row_offset = i * temp_row_offset
        let _out_row_offset = i * out_row_offset
        HalfInverseRadix2CooleyTukey(levelCol, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col, output + _out_row_offset, out_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
}

public func HalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            op_r.memory = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            op_i.memory = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            oph_r.memory = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            oph_i.memory = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func HalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, output, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride
            
            let evenreal = ip_r.memory + iph_r.memory
            let evenim = ip_i.memory - iph_i.memory
            let oddreal = ip_i.memory + iph_i.memory
            let oddim = iph_r.memory - ip_r.memory
            
            tp_r.memory = -oddreal * _cos1 - oddim * _sin1 + evenreal
            tp_i.memory = oddreal * _sin1 - oddim * _cos1 + evenim
            tph_r.memory = -oddreal * _cos2 + oddim * _sin2 + evenreal
            tph_i.memory = oddreal * _sin2 + oddim * _cos2 - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
        
        InverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, output, output + out_stride, out_stride << 1)
    }
}

public func HalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = (out_stride_col << levelCol) >> 1
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    HalfRadix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _real + out_row_offset, out_row_offset << 1)
    HalfRadix2CooleyTukey(levelRow, timag, temp_row_offset, _imag, _imag + out_row_offset, out_row_offset << 1)
    if col_count > 1 {
        for i in 1..<col_count {
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
}

public func HalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = (in_stride_col << levelCol) >> 1
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    let treal2 = output
    let timag2 = output + out_stride_col
    let temp2_row_offset = (out_row_length * out_stride_row) >> 1
    
    HalfInverseRadix2CooleyTukey(levelRow, real, real + in_row_offset, in_row_offset << 1, treal, temp_row_offset, treal2, treal2 + temp2_row_offset, temp2_row_offset << 1)
    HalfInverseRadix2CooleyTukey(levelRow, imag, imag + in_row_offset, in_row_offset << 1, timag, temp_row_offset, timag2, timag2 + temp2_row_offset, temp2_row_offset << 1)
    if col_count > 1 {
        for i in 1..<col_count {
            let _in_col_offset = i * in_stride_col
            let _temp_col_offset = i * temp_stride_col
            InverseRadix2CooleyTukey(levelRow, real + _in_col_offset, imag + _in_col_offset, in_row_offset, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset)
        }
    }
    
    for i in 0..<row_count {
        let _temp_row_offset = i * temp_row_offset
        let _out_row_offset = i * out_row_offset
        HalfInverseRadix2CooleyTukey(levelCol, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col, output + _out_row_offset, out_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
}

// MARK: Radix-2 Cooley-Tukey

public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}

public func Radix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = real.memory
        _imag.memory = imag.memory
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, op_r, op_i, out_stride)
        Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
        
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

public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        InverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = 2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, _imag, _real, out_stride)
}

public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    let out_row_offset_2 = out_row_offset >> 1
    
    Radix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _imag, out_row_offset)
    Radix2CooleyTukey(levelRow, timag, temp_row_offset, _real + out_row_offset_2, _imag + out_row_offset_2, out_row_offset)
    if col_count > 1 {
        for i in 1..<col_count {
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
    
    let block = row_count * out_row_offset
    
    var op_r = _real
    var op_i = _imag
    var opb_r = _real + out_row_length
    var opb_i = _imag + out_row_length
    for _ in 0..<col_count - 1 {
        op_r += out_stride_col
        op_i += out_stride_col
        opb_r -= out_stride_col
        opb_i -= out_stride_col
        opb_r.memory = op_r.memory
        opb_i.memory = -op_i.memory
        var _op_r = op_r
        var _op_i = op_i
        var _opb_r = opb_r + block
        var _opb_i = opb_i + block
        for _ in 0..<row_count - 1 {
            _op_r += out_row_offset
            _op_i += out_row_offset
            _opb_r -= out_row_offset
            _opb_i -= out_row_offset
            _opb_r.memory = _op_r.memory
            _opb_i.memory = -_op_i.memory
        }
    }
}

public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        Radix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    for i in 0..<col_count {
        let _temp_col_offset = i * temp_stride_col
        let _out_col_offset = i * out_stride_col
        Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func InverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        InverseRadix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    for i in 0..<col_count {
        let _temp_col_offset = i * temp_stride_col
        let _out_col_offset = i * out_stride_col
        InverseRadix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func Radix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        Radix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}

public func Radix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = real.memory
        _imag.memory = imag.memory
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, op_r, op_i, out_stride)
        Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
        
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

public func InverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        InverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = 2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}

public func InverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    Radix2CooleyTukey(level, imag, real, in_stride, _imag, _real, out_stride)
}

public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    let out_row_offset_2 = out_row_offset >> 1
    
    Radix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _imag, out_row_offset)
    Radix2CooleyTukey(levelRow, timag, temp_row_offset, _real + out_row_offset_2, _imag + out_row_offset_2, out_row_offset)
    if col_count > 1 {
        for i in 1..<col_count {
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
    
    let block = row_count * out_row_offset
    
    var op_r = _real
    var op_i = _imag
    var opb_r = _real + out_row_length
    var opb_i = _imag + out_row_length
    for _ in 0..<col_count - 1 {
        op_r += out_stride_col
        op_i += out_stride_col
        opb_r -= out_stride_col
        opb_i -= out_stride_col
        opb_r.memory = op_r.memory
        opb_i.memory = -op_i.memory
        var _op_r = op_r
        var _op_i = op_i
        var _opb_r = opb_r + block
        var _opb_i = opb_i + block
        for _ in 0..<row_count - 1 {
            _op_r += out_row_offset
            _op_i += out_row_offset
            _opb_r -= out_row_offset
            _opb_i -= out_row_offset
            _opb_r.memory = _op_r.memory
            _opb_i.memory = -_op_i.memory
        }
    }
}

public func Radix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        Radix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    for i in 0..<col_count {
        let _temp_col_offset = i * temp_stride_col
        let _out_col_offset = i * out_stride_col
        Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func InverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    for i in 0..<row_count {
        let _in_row_offset = i * in_row_offset
        let _temp_row_offset = i * temp_row_offset
        InverseRadix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    for i in 0..<col_count {
        let _temp_col_offset = i * temp_stride_col
        let _out_col_offset = i * out_stride_col
        InverseRadix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

// MARK: Dispatch Half Radix-2 Cooley-Tukey

public func DispatchHalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            op_r.memory = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            op_i.memory = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            oph_r.memory = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            oph_i.memory = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchHalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, output, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride
            
            let evenreal = ip_r.memory + iph_r.memory
            let evenim = ip_i.memory - iph_i.memory
            let oddreal = ip_i.memory + iph_i.memory
            let oddim = iph_r.memory - ip_r.memory
            
            tp_r.memory = -oddreal * _cos1 - oddim * _sin1 + evenreal
            tp_i.memory = oddreal * _sin1 - oddim * _cos1 + evenim
            tph_r.memory = -oddreal * _cos2 + oddim * _sin2 + evenreal
            tph_i.memory = oddreal * _sin2 + oddim * _cos2 - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, output, output + out_stride, out_stride << 1)
    }
}

public func DispatchHalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = (out_stride_col << levelCol) >> 1
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            HalfRadix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _real + out_row_offset, out_row_offset << 1)
        default:
            HalfRadix2CooleyTukey(levelRow, timag, temp_row_offset, _imag, _imag + out_row_offset, out_row_offset << 1)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
}

public func DispatchHalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = (in_stride_col << levelCol) >> 1
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    let treal2 = output
    let timag2 = output + out_stride_col
    let temp2_row_offset = (out_row_length * out_stride_row) >> 1
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            HalfInverseRadix2CooleyTukey(levelRow, real, real + in_row_offset, in_row_offset << 1, treal, temp_row_offset, treal2, treal2 + temp2_row_offset, temp2_row_offset << 1)
        default:
            HalfInverseRadix2CooleyTukey(levelRow, imag, imag + in_row_offset, in_row_offset << 1, timag, temp_row_offset, timag2, timag2 + temp2_row_offset, temp2_row_offset << 1)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _in_col_offset = i * in_stride_col
            let _temp_col_offset = i * temp_stride_col
            InverseRadix2CooleyTukey(levelRow, real + _in_col_offset, imag + _in_col_offset, in_row_offset, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset)
        }
    }
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _temp_row_offset = $0 * temp_row_offset
        let _out_row_offset = $0 * out_row_offset
        HalfInverseRadix2CooleyTukey(levelCol, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col, output + _out_row_offset, out_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
}

public func DispatchHalfRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        HalfRadix2CooleyTukey_2(input, in_stride, _real, _imag)
    case 2:
        HalfRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            op_r.memory = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            op_i.memory = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            oph_r.memory = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            oph_i.memory = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchHalfInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int) {
    
    switch level {
        
    case 0:
        output.memory = real.memory
        
    case 1:
        HalfInverseRadix2CooleyTukey_2(real, imag, output, out_stride)
    case 2:
        HalfInverseRadix2CooleyTukey_4(real, imag, in_stride, output, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += tp_stride
            tp_i += tp_stride
            tph_r -= tp_stride
            tph_i -= tp_stride
            
            let evenreal = ip_r.memory + iph_r.memory
            let evenim = ip_i.memory - iph_i.memory
            let oddreal = ip_i.memory + iph_i.memory
            let oddim = iph_r.memory - ip_r.memory
            
            tp_r.memory = -oddreal * _cos1 - oddim * _sin1 + evenreal
            tp_i.memory = oddreal * _sin1 - oddim * _cos1 + evenim
            tph_r.memory = -oddreal * _cos2 + oddim * _sin2 + evenreal
            tph_i.memory = oddreal * _sin2 + oddim * _cos2 - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
        
        DispatchInverseRadix2CooleyTukey(level - 1, treal, timag, tp_stride, output, output + out_stride, out_stride << 1)
    }
}

public func DispatchHalfRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = (out_stride_col << levelCol) >> 1
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            HalfRadix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _real + out_row_offset, out_row_offset << 1)
        default:
            HalfRadix2CooleyTukey(levelRow, timag, temp_row_offset, _imag, _imag + out_row_offset, out_row_offset << 1)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
}

public func DispatchHalfInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = (in_stride_col << levelCol) >> 1
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = (temp_stride_col << levelCol) >> 1
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    let treal2 = output
    let timag2 = output + out_stride_col
    let temp2_row_offset = (out_row_length * out_stride_row) >> 1
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            HalfInverseRadix2CooleyTukey(levelRow, real, real + in_row_offset, in_row_offset << 1, treal, temp_row_offset, treal2, treal2 + temp2_row_offset, temp2_row_offset << 1)
        default:
            HalfInverseRadix2CooleyTukey(levelRow, imag, imag + in_row_offset, in_row_offset << 1, timag, temp_row_offset, timag2, timag2 + temp2_row_offset, temp2_row_offset << 1)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _in_col_offset = i * in_stride_col
            let _temp_col_offset = i * temp_stride_col
            InverseRadix2CooleyTukey(levelRow, real + _in_col_offset, imag + _in_col_offset, in_row_offset, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset)
        }
    }
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _temp_row_offset = $0 * temp_row_offset
        let _out_row_offset = $0 * out_row_offset
        HalfInverseRadix2CooleyTukey(levelCol, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col, output + _out_row_offset, out_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
}

// MARK: Dispatch Radix-2 Cooley-Tukey

public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = real.memory
        _imag.memory = imag.memory
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
            switch $0 {
            case 0:
                Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, op_r, op_i, out_stride)
            default:
                Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
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

public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchInverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = 2.0 * Float(M_PI) / Float(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Float(half - 1) * angle)
        var _sin2 = sin(Float(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, _imag, _real, out_stride)
}

public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    let out_row_offset_2 = out_row_offset >> 1
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            Radix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _imag, out_row_offset)
        default:
            Radix2CooleyTukey(levelRow, timag, temp_row_offset, _real + out_row_offset_2, _imag + out_row_offset_2, out_row_offset)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
    
    let block = row_count * out_row_offset
    
    var op_r = _real
    var op_i = _imag
    var opb_r = _real + out_row_length
    var opb_i = _imag + out_row_length
    for _ in 0..<col_count - 1 {
        op_r += out_stride_col
        op_i += out_stride_col
        opb_r -= out_stride_col
        opb_i -= out_stride_col
        opb_r.memory = op_r.memory
        opb_i.memory = -op_i.memory
        var _op_r = op_r
        var _op_i = op_i
        var _opb_r = opb_r + block
        var _opb_i = opb_i + block
        for _ in 0..<row_count - 1 {
            _op_r += out_row_offset
            _op_i += out_row_offset
            _opb_r -= out_row_offset
            _opb_i -= out_row_offset
            _opb_r.memory = _op_r.memory
            _opb_i.memory = -_op_i.memory
        }
    }
}

public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        Radix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(col_count, CooleyTukeyDispatchQueue) {
        let _temp_col_offset = $0 * temp_stride_col
        let _out_col_offset = $0 * out_stride_col
        Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func DispatchInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        InverseRadix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(col_count, CooleyTukeyDispatchQueue) {
        let _temp_col_offset = $0 * temp_stride_col
        let _out_col_offset = $0 * out_stride_col
        InverseRadix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func DispatchRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        Radix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = -2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = real.memory
        _imag.memory = imag.memory
        
    case 1:
        Radix2CooleyTukey_2(real, imag, in_stride, _real, _imag, out_stride)
    case 2:
        Radix2CooleyTukey_4(real, imag, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = _real
        var op_i = _imag
        var oph_r = _real + oph_stride
        var oph_i = _imag + oph_stride
        
        dispatch_apply(2, CooleyTukeyDispatchQueue) {
            switch $0 {
            case 0:
                Radix2CooleyTukey(level - 1, real, imag, in_stride << 1, op_r, op_i, out_stride)
            default:
                Radix2CooleyTukey(level - 1, real + in_stride, imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
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

public func DispatchInverseRadix2CooleyTukey(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    switch level {
        
    case 0:
        _real.memory = input.memory
        _imag.memory = 0.0
        
    case 1:
        InverseRadix2CooleyTukey_2(input, in_stride, _real, _imag, out_stride)
    case 2:
        InverseRadix2CooleyTukey_4(input, in_stride, _real, _imag, out_stride)
        
    default:
        let length = 1 << level
        let half = length >> 1
        let fourth = length >> 2
        
        DispatchInverseRadix2CooleyTukey(level - 1, input, input + in_stride, in_stride << 1, _real, _imag, out_stride)
        
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
        
        let angle = 2.0 * M_PI / Double(length)
        let _cos = cos(angle)
        let _sin = sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        var _cos2 = cos(Double(half - 1) * angle)
        var _sin2 = sin(Double(half - 1) * angle)
        for _ in 1..<fourth {
            
            op_r += out_stride
            op_i += out_stride
            oph_r -= out_stride
            oph_i -= out_stride
            oph2_r += out_stride
            oph2_i += out_stride
            opb_r -= out_stride
            opb_i -= out_stride
            
            let evenreal = op_r.memory + oph_r.memory
            let evenim = op_i.memory - oph_i.memory
            let oddreal = op_i.memory + oph_i.memory
            let oddim = oph_r.memory - op_r.memory
            
            let _r1 = 0.5 * (oddreal * _cos1 - oddim * _sin1 + evenreal)
            let _i1 = 0.5 * (oddreal * _sin1 + oddim * _cos1 + evenim)
            let _r2 = 0.5 * (oddreal * _cos2 + oddim * _sin2 + evenreal)
            let _i2 = 0.5 * (oddreal * _sin2 - oddim * _cos2 - evenim)
            
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
            let _c2 = _cos2 * _cos + _sin2 * _sin
            let _s2 = _sin2 * _cos - _cos2 * _sin
            _cos1 = _c1
            _sin1 = _s1
            _cos2 = _c2
            _sin2 = _s2
        }
    }
}
public func DispatchInverseRadix2CooleyTukey(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    DispatchRadix2CooleyTukey(level, imag, real, in_stride, _imag, _real, out_stride)
}

public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ input: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = (1 << levelCol) >> 1
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        HalfRadix2CooleyTukey(levelCol, input + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    let out_row_offset_2 = out_row_offset >> 1
    
    dispatch_apply(2, CooleyTukeyDispatchQueue) {
        switch $0 {
        case 0:
            Radix2CooleyTukey(levelRow, treal, temp_row_offset, _real, _imag, out_row_offset)
        default:
            Radix2CooleyTukey(levelRow, timag, temp_row_offset, _real + out_row_offset_2, _imag + out_row_offset_2, out_row_offset)
        }
    }
    if col_count > 1 {
        dispatch_apply(col_count - 1, CooleyTukeyDispatchQueue) {
            let i = $0 + 1
            let _temp_col_offset = i * temp_stride_col
            let _out_col_offset = i * out_stride_col
            Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
        }
    }
    
    let block = row_count * out_row_offset
    
    var op_r = _real
    var op_i = _imag
    var opb_r = _real + out_row_length
    var opb_i = _imag + out_row_length
    for _ in 0..<col_count - 1 {
        op_r += out_stride_col
        op_i += out_stride_col
        opb_r -= out_stride_col
        opb_i -= out_stride_col
        opb_r.memory = op_r.memory
        opb_i.memory = -op_i.memory
        var _op_r = op_r
        var _op_i = op_i
        var _opb_r = opb_r + block
        var _opb_i = opb_i + block
        for _ in 0..<row_count - 1 {
            _op_r += out_row_offset
            _op_i += out_row_offset
            _opb_r -= out_row_offset
            _opb_i -= out_row_offset
            _opb_r.memory = _op_r.memory
            _opb_i.memory = -_op_i.memory
        }
    }
}

public func DispatchRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        Radix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(col_count, CooleyTukeyDispatchQueue) {
        let _temp_col_offset = $0 * temp_stride_col
        let _out_col_offset = $0 * out_stride_col
        Radix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

public func DispatchInverseRadix2CooleyTukey(levelRow: Int, _ levelCol: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride_row: Int, _ in_stride_col: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride_row: Int, _ out_stride_col: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride_row: Int, _ temp_stride_col: Int) {
    
    let row_count = 1 << levelRow
    let col_count = 1 << levelCol
    
    let in_row_length = in_stride_col << levelCol
    let out_row_length = out_stride_col << levelCol
    let temp_row_length = temp_stride_col << levelCol
    
    let in_row_offset = in_row_length * in_stride_row
    let out_row_offset = out_row_length * out_stride_row
    let temp_row_offset = temp_row_length * temp_stride_row
    
    dispatch_apply(row_count, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_row_offset
        let _temp_row_offset = $0 * temp_row_offset
        InverseRadix2CooleyTukey(levelCol, real + _in_row_offset, imag + _in_row_offset, in_stride_col, treal + _temp_row_offset, timag + _temp_row_offset, temp_stride_col)
    }
    
    dispatch_apply(col_count, CooleyTukeyDispatchQueue) {
        let _temp_col_offset = $0 * temp_stride_col
        let _out_col_offset = $0 * out_stride_col
        InverseRadix2CooleyTukey(levelRow, treal + _temp_col_offset, timag + _temp_col_offset, temp_row_offset, _real + _out_col_offset, _imag + _out_col_offset, out_row_offset)
    }
}

// MARK: Parallel

private let CooleyTukeyDispatchQueue = dispatch_queue_create("com.SusanDoggie.Algorithm.CooleyTukey", DISPATCH_QUEUE_CONCURRENT)

public func ParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        HalfRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int, _ tp_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _tp_row_offset = i * tp_rows_stride
        let _out_row_offset = i * out_rows_stride
        HalfInverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, output + _out_row_offset, out_stride, treal + _tp_row_offset, timag + _tp_row_offset, tp_stride)
    }
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        Radix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        Radix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        InverseRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        InverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        HalfRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ tp_stride: Int, _ tp_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _tp_row_offset = $0 * tp_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        HalfInverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, output + _out_row_offset, out_stride, treal + _tp_row_offset, timag + _tp_row_offset, tp_stride)
    }
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        Radix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        Radix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        InverseRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        InverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}

public func ParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        HalfRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int, _ tp_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _tp_row_offset = i * tp_rows_stride
        let _out_row_offset = i * out_rows_stride
        HalfInverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, output + _out_row_offset, out_stride, treal + _tp_row_offset, timag + _tp_row_offset, tp_stride)
    }
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        Radix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        Radix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        InverseRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func ParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    for i in 0..<rows {
        let _in_row_offset = i * in_rows_stride
        let _out_row_offset = i * out_rows_stride
        InverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelHalfRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        HalfRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelHalfInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ tp_stride: Int, _ tp_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _tp_row_offset = $0 * tp_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        HalfInverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, output + _out_row_offset, out_stride, treal + _tp_row_offset, timag + _tp_row_offset, tp_stride)
    }
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        Radix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        Radix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        InverseRadix2CooleyTukey(level, input + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}
public func DispatchParallelInverseRadix2CooleyTukey(rows: Int, _ level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_rows_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ out_rows_stride: Int) {
    
    dispatch_apply(rows, CooleyTukeyDispatchQueue) {
        let _in_row_offset = $0 * in_rows_stride
        let _out_row_offset = $0 * out_rows_stride
        InverseRadix2CooleyTukey(level, real + _in_row_offset, imag + _in_row_offset, in_stride, _real + _out_row_offset, _imag + _out_row_offset, out_stride)
    }
}

// MARK: Fixed Length Cooley-Tukey

public func HalfRadix2CooleyTukey_2(var input: UnsafePointer<Float>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = a - b
}
public func HalfRadix2CooleyTukey_4(var input: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
    let e = a + c
    let f = b + d
    
    _real.memory = e + f
    _imag.memory = e - f
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = d - b
}
public func HalfInverseRadix2CooleyTukey_2(real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    
    output.memory = a + b
    output += out_stride
    
    output.memory = a - b
}
public func HalfInverseRadix2CooleyTukey_4(var real: UnsafePointer<Float>, var _ imag: UnsafePointer<Float>, _ in_stride: Int, var _ output: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    
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
public func Radix2CooleyTukey_2(var input: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
public func Radix2CooleyTukey_2(var real: UnsafePointer<Float>, var _ imag: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    
    _real.memory = a + c
    _imag.memory = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = b - d
    
}
public func InverseRadix2CooleyTukey_2(var input: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
public func Radix2CooleyTukey_4(var input: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
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

public func Radix2CooleyTukey_4(var real: UnsafePointer<Float>, var _ imag: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    real += in_stride
    imag += in_stride
    
    let e = real.memory
    let f = imag.memory
    real += in_stride
    imag += in_stride
    
    let g = real.memory
    let h = imag.memory
    
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

public func InverseRadix2CooleyTukey_4(var input: UnsafePointer<Float>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Float>, var _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
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

public func HalfRadix2CooleyTukey_2(var input: UnsafePointer<Double>, _ in_stride: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = a - b
}
public func HalfRadix2CooleyTukey_4(var input: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
    let e = a + c
    let f = b + d
    
    _real.memory = e + f
    _imag.memory = e - f
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = d - b
}
public func HalfInverseRadix2CooleyTukey_2(real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    
    output.memory = a + b
    output += out_stride
    
    output.memory = a - b
}
public func HalfInverseRadix2CooleyTukey_4(var real: UnsafePointer<Double>, var _ imag: UnsafePointer<Double>, _ in_stride: Int, var _ output: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    
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
public func Radix2CooleyTukey_2(var input: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
public func Radix2CooleyTukey_2(var real: UnsafePointer<Double>, var _ imag: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    
    _real.memory = a + c
    _imag.memory = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - c
    _imag.memory = b - d
    
}
public func InverseRadix2CooleyTukey_2(var input: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    
    _real.memory = a + b
    _imag.memory = 0
    _real += out_stride
    _imag += out_stride
    
    _real.memory = a - b
    _imag.memory = 0
    
}
public func Radix2CooleyTukey_4(var input: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
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

public func Radix2CooleyTukey_4(var real: UnsafePointer<Double>, var _ imag: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = real.memory
    let b = imag.memory
    real += in_stride
    imag += in_stride
    
    let c = real.memory
    let d = imag.memory
    real += in_stride
    imag += in_stride
    
    let e = real.memory
    let f = imag.memory
    real += in_stride
    imag += in_stride
    
    let g = real.memory
    let h = imag.memory
    
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

public func InverseRadix2CooleyTukey_4(var input: UnsafePointer<Double>, _ in_stride: Int, var _ _real: UnsafeMutablePointer<Double>, var _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int) {
    
    let a = input.memory
    input += in_stride
    
    let b = input.memory
    input += in_stride
    
    let c = input.memory
    input += in_stride
    
    let d = input.memory
    
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
