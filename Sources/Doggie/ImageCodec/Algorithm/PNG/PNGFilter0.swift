//
//  PNGFilter0.swift
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

private func average(_ a: UInt8, _ b: UInt8) -> UInt8 {
    return UInt8((UInt16(a) &+ UInt16(b)) >> 1)
}

private func paeth(_ a: UInt8, _ b: UInt8, _ c: UInt8) -> UInt8 {
    let _a = Int16(a)
    let _b = Int16(b)
    let _c = Int16(c)
    let p = _a &+ _b &- _c
    let pa = abs(p - _a)
    let pb = abs(p - _b)
    let pc = abs(p - _c)
    if pa <= pb && pa <= pc {
        return a
    } else if pb <= pc {
        return b
    } else {
        return c
    }
}

struct png_filter0_encoder {

    private let row_length: Int
    private let stride: Int
    private var buffer: [UInt8]
    private var index: Int
    private var flag: Bool

    init(row_length: Int, bitsPerPixel: UInt8) {
        self.row_length = row_length
        self.stride = max(1, Int(bitsPerPixel >> 3))
        self.buffer = Array(zeros: row_length + (row_length + 1) * 5)
        self.index = 0
        self.flag = true
    }
}

extension png_filter0_encoder {

    mutating func encode(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) rethrows {

        precondition(flag)

        let row_length = self.row_length
        let stride = self.stride
        var index = self.index

        try buffer.withUnsafeMutableBufferPointer { buf in

            let _b0 = buf.dropFirst(row_length)
            let _b1 = _b0.dropFirst(row_length + 1)
            let _b2 = _b1.dropFirst(row_length + 1)
            let _b3 = _b2.dropFirst(row_length + 1)
            let _b4 = _b3.dropFirst(row_length + 1)

            let a0 = UnsafeMutableBufferPointer(rebasing: buf.prefix(row_length))
            let b0 = UnsafeMutableBufferPointer(rebasing: _b0.prefix(row_length + 1))
            let b1 = UnsafeMutableBufferPointer(rebasing: _b1.prefix(row_length + 1))
            let b2 = UnsafeMutableBufferPointer(rebasing: _b2.prefix(row_length + 1))
            let b3 = UnsafeMutableBufferPointer(rebasing: _b3.prefix(row_length + 1))
            let b4 = UnsafeMutableBufferPointer(rebasing: _b4.prefix(row_length + 1))

            b0[0] = 0
            b1[0] = 1
            b2[0] = 2
            b3[0] = 3
            b4[0] = 4

            for x in source {

                if index == row_length {

                    let s0 = b0.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                    let s1 = b1.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                    let s2 = b2.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                    let s3 = b3.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                    let s4 = b4.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }

                    var t = s0
                    var p = b0

                    if s1 < t {
                        t = s1
                        p = b1
                    }
                    if s2 < t {
                        t = s2
                        p = b2
                    }
                    if s3 < t {
                        t = s3
                        p = b3
                    }
                    if s4 < t {
                        t = s4
                        p = b4
                    }

                    try callback(UnsafeBufferPointer(p))
                    memcpy(a0.baseAddress!, b0.baseAddress! + 1, a0.count)
                    index = 0
                }

                if index < stride {
                    let b = a0[index]
                    b0[index + 1] = x
                    b1[index + 1] = x
                    b2[index + 1] = x &- b
                    b3[index + 1] = x &- average(0, b)
                    b4[index + 1] = x &- paeth(0, b, 0)
                } else {
                    let a = b0[index - stride + 1]
                    let b = a0[index]
                    let c = a0[index - stride]
                    b0[index + 1] = x
                    b1[index + 1] = x &- a
                    b2[index + 1] = x &- b
                    b3[index + 1] = x &- average(a, b)
                    b4[index + 1] = x &- paeth(a, b, c)
                }

                index += 1
            }
        }

        self.index = index
    }

    mutating func final(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) rethrows {

        precondition(flag)

        if index != 0 {
            try buffer.withUnsafeBufferPointer { buf in

                let _b0 = buf.dropFirst(row_length)
                let _b1 = _b0.dropFirst(row_length + 1)
                let _b2 = _b1.dropFirst(row_length + 1)
                let _b3 = _b2.dropFirst(row_length + 1)
                let _b4 = _b3.dropFirst(row_length + 1)

                let b0 = UnsafeBufferPointer(rebasing: _b0.prefix(row_length + 1))
                let b1 = UnsafeBufferPointer(rebasing: _b1.prefix(row_length + 1))
                let b2 = UnsafeBufferPointer(rebasing: _b2.prefix(row_length + 1))
                let b3 = UnsafeBufferPointer(rebasing: _b3.prefix(row_length + 1))
                let b4 = UnsafeBufferPointer(rebasing: _b4.prefix(row_length + 1))

                let s0 = b0.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                let s1 = b1.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                let s2 = b2.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                let s3 = b3.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
                let s4 = b4.dropFirst().reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }

                var t = s0
                var p = b0

                if s1 < t {
                    t = s1
                    p = b1
                }
                if s2 < t {
                    t = s2
                    p = b2
                }
                if s3 < t {
                    t = s3
                    p = b3
                }
                if s4 < t {
                    t = s4
                    p = b4
                }

                try callback(UnsafeBufferPointer(rebasing: p.prefix(index + 1)))
            }
        }

        flag = false
    }
}

struct png_filter0_decoder {

    private let row_length: Int
    private let stride: Int
    private var buffer: [UInt8]
    private var type: UInt8?
    private var index: Int
    private var flag: Bool

    init(row_length: Int, bitsPerPixel: UInt8) {
        self.row_length = row_length
        self.stride = max(1, Int(bitsPerPixel >> 3))
        self.buffer = Array(zeros: row_length << 1)
        self.index = 0
        self.flag = true
    }
}

extension png_filter0_decoder {

    mutating func decode(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) rethrows {

        precondition(flag)

        let row_length = self.row_length
        let stride = self.stride
        var type = self.type
        var index = self.index

        try buffer.withUnsafeMutableBufferPointer { buf in

            let b0 = UnsafeMutableBufferPointer(rebasing: buf.prefix(row_length))
            let b1 = UnsafeMutableBufferPointer(rebasing: buf.suffix(row_length))

            for x in source {
                if type == nil {
                    type = x
                    index = 0
                } else {
                    if index < stride {
                        switch type {
                        case 0: b1[index] = x
                        case 1: b1[index] = x
                        case 2: b1[index] = x &+ b0[index]
                        case 3: b1[index] = x &+ average(0, b0[index])
                        case 4: b1[index] = x &+ paeth(0, b0[index], 0)
                        default: break
                        }
                    } else {
                        switch type {
                        case 0: b1[index] = x
                        case 1: b1[index] = x &+ b1[index - stride]
                        case 2: b1[index] = x &+ b0[index]
                        case 3: b1[index] = x &+ average(b1[index - stride], b0[index])
                        case 4: b1[index] = x &+ paeth(b1[index - stride], b0[index], b0[index - stride])
                        default: break
                        }
                    }

                    index += 1

                    if index == row_length {
                        try callback(UnsafeBufferPointer(b1))
                        memcpy(b0.baseAddress!, b1.baseAddress!, b0.count)
                        type = nil
                        index = 0
                    }
                }
            }
        }

        self.type = type
        self.index = index
    }

    mutating func final(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) rethrows {

        precondition(flag)

        if index != 0 {
            try buffer.withUnsafeBufferPointer { try callback(UnsafeBufferPointer(rebasing: $0.suffix(row_length).prefix(index))) }
        }

        flag = false
    }
}
