//
//  iccMatrix.swift
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

struct iccMatrix3x3 : ByteCodable {
    
    var e00: Fixed16Number<BEInt32>
    var e01: Fixed16Number<BEInt32>
    var e02: Fixed16Number<BEInt32>
    var e10: Fixed16Number<BEInt32>
    var e11: Fixed16Number<BEInt32>
    var e12: Fixed16Number<BEInt32>
    var e20: Fixed16Number<BEInt32>
    var e21: Fixed16Number<BEInt32>
    var e22: Fixed16Number<BEInt32>
    
    init(_ matrix: Matrix) {
        self.e00 = Fixed16Number(matrix.a)
        self.e01 = Fixed16Number(matrix.b)
        self.e02 = Fixed16Number(matrix.c)
        self.e10 = Fixed16Number(matrix.e)
        self.e11 = Fixed16Number(matrix.f)
        self.e12 = Fixed16Number(matrix.g)
        self.e20 = Fixed16Number(matrix.i)
        self.e21 = Fixed16Number(matrix.j)
        self.e22 = Fixed16Number(matrix.k)
    }
    
    var matrix: Matrix {
        return Matrix(a: e00.representingValue, b: e01.representingValue, c: e02.representingValue, d: 0,
                      e: e10.representingValue, f: e11.representingValue, g: e12.representingValue, h: 0,
                      i: e20.representingValue, j: e21.representingValue, k: e22.representingValue, l: 0)
    }
    
    init(from data: inout Data) throws {
        self.e00 = try data.decode(Fixed16Number.self)
        self.e01 = try data.decode(Fixed16Number.self)
        self.e02 = try data.decode(Fixed16Number.self)
        self.e10 = try data.decode(Fixed16Number.self)
        self.e11 = try data.decode(Fixed16Number.self)
        self.e12 = try data.decode(Fixed16Number.self)
        self.e20 = try data.decode(Fixed16Number.self)
        self.e21 = try data.decode(Fixed16Number.self)
        self.e22 = try data.decode(Fixed16Number.self)
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(e00)
        stream.encode(e01)
        stream.encode(e02)
        stream.encode(e10)
        stream.encode(e11)
        stream.encode(e12)
        stream.encode(e20)
        stream.encode(e21)
        stream.encode(e22)
    }
}

struct iccMatrix3x4 : ByteCodable {
    
    var m: iccMatrix3x3
    
    var e03: Fixed16Number<BEInt32>
    var e13: Fixed16Number<BEInt32>
    var e23: Fixed16Number<BEInt32>
    
    init(_ matrix: Matrix) {
        self.m = iccMatrix3x3(matrix)
        self.e03 = Fixed16Number(matrix.d)
        self.e13 = Fixed16Number(matrix.h)
        self.e23 = Fixed16Number(matrix.l)
    }
    
    var matrix: Matrix {
        return Matrix(a: m.e00.representingValue, b: m.e01.representingValue, c: m.e02.representingValue, d: e03.representingValue,
                      e: m.e10.representingValue, f: m.e11.representingValue, g: m.e12.representingValue, h: e13.representingValue,
                      i: m.e20.representingValue, j: m.e21.representingValue, k: m.e22.representingValue, l: e23.representingValue)
    }
    
    init(from data: inout Data) throws {
        self.m = try data.decode(iccMatrix3x3.self)
        self.e03 = try data.decode(Fixed16Number.self)
        self.e13 = try data.decode(Fixed16Number.self)
        self.e23 = try data.decode(Fixed16Number.self)
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(m)
        stream.encode(e03)
        stream.encode(e13)
        stream.encode(e23)
    }
}
