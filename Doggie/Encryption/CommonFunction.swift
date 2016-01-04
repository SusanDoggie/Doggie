//
//  CommonFunction.swift
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

func left_rotate(v: UInt8, _ n: UInt8) -> UInt8 {
    return (v << n) | (v >> (8 - n))
}

func left_rotate(v: UInt16, _ n: UInt16) -> UInt16 {
    return (v << n) | (v >> (16 - n))
}

func left_rotate(v: UInt32, _ n: UInt32) -> UInt32 {
    return (v << n) | (v >> (32 - n))
}

func left_rotate(x: UInt64, _ n: UInt64) -> UInt64 {
    return (x << n) | (x >> (64 - n))
}

func right_rotate(x: UInt16, _ n: UInt16) -> UInt16 {
    return (x >> n) | (x << (16 - n))
}

func right_rotate(x: UInt32, _ n: UInt32) -> UInt32 {
    return (x >> n) | (x << (32 - n))
}

func right_rotate(x: UInt64, _ n: UInt64) -> UInt64 {
    return (x >> n) | (x << (64 - n))
}

func hash_prepare(msg: UnsafePointer<UInt8>, _ len: Int, _ block: Int) -> SecureBuffer {
    let len_mod = len % block
    let count: Int
    if block > len_mod + 8 {
        count = block - len_mod
    } else if block < len_mod + 8 {
        count = block + 64 - len_mod
    } else {
        count = 8
    }
    var d = SecureBuffer(size: len + count)
    d.copyFrom(msg, count: len)
    d[len] = UInt8(0x80)
    return d
}
