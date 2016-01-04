//
//  md5.swift
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

private let s: [UInt32] = [
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
]

private let k: [UInt32] = [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
]

public func md5(count: Int, _ bytes: UnsafePointer<UInt8>, _ digest: UnsafeMutablePointer<UInt8>) {
    
    var d0: UInt32 = 0x67452301
    var d1: UInt32 = 0xefcdab89
    var d2: UInt32 = 0x98badcfe
    var d3: UInt32 = 0x10325476
    
    var M = hash_prepare(bytes, count, 64)
    M[M.count(UInt64) - 1] = UInt64(count << 3).littleEndian
    
    var offset = 0
    for _ in 0..<M.size >> 6 {
        var A = d0
        var B = d1
        var C = d2
        var D = d3
        for j in 0..<64 {
            var g = 0
            var F: UInt32 = 0
            switch j {
            case 0..<16:
                F = D ^ (B & (C ^ D))
                g = j
            case 16..<32:
                F = C ^ (D & (B ^ C))
                g = (5 * j + 1) % 16
            case 32..<48:
                F = B ^ C ^ D
                g = (3 * j + 5) % 16
            case 48..<64:
                F = C ^ (B | ~D)
                g = (7 * j) % 16
            default: break
            }
            (A, B, C, D) = (D, B &+ left_rotate(A &+ F &+ k[j] &+ M[g + offset], s[j]), B, C)
        }
        d0 = d0 &+ A
        d1 = d1 &+ B
        d2 = d2 &+ C
        d3 = d3 &+ D
        offset += 16
    }
    let d = UnsafeMutablePointer<UInt32>(digest)
    d[0] = d0.littleEndian
    d[1] = d1.littleEndian
    d[2] = d2.littleEndian
    d[3] = d3.littleEndian
}
