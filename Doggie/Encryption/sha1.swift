//
//  sha1.swift
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

public func sha1(count: Int, _ bytes: UnsafePointer<UInt8>, _ digest: UnsafeMutablePointer<UInt8>) {
    
    var d0: UInt32 = 0x67452301
    var d1: UInt32 = 0xefcdab89
    var d2: UInt32 = 0x98badcfe
    var d3: UInt32 = 0x10325476
    var d4: UInt32 = 0xc3d2e1f0
    
    var buf = hash_prepare(bytes, count, 64)
    buf[buf.count(UInt64) - 1] = UInt64(count << 3).bigEndian
    
    var offset = 0
    var M = SecureBuffer(size: 320)
    for _ in 0..<buf.size >> 6 {
        for x in 0..<80 {
            switch (x) {
            case 0..<16:
                M[x] = buf[x + offset].bigEndian as UInt32
            default:
                M[x] = left_rotate(M[x - 3] ^ M[x - 8] ^ M[x - 14] ^ M[x - 16], 1) as UInt32
            }
        }
        
        var A = d0
        var B = d1
        var C = d2
        var D = d3
        var E = d4
        for j in 0..<80 {
            var k: UInt32 = 0
            var F: UInt32 = 0
            switch j {
            case 0..<20:
                F = D ^ (B & (C ^ D))
                k = 0x5a827999
            case 20..<40:
                F = B ^ C ^ D
                k = 0x6ed9eba1
            case 40..<60:
                F = (B & C) | (B & D) | (C & D)
                k = 0x8f1bbcdc
            case 60..<80:
                F = B ^ C ^ D
                k = 0xca62c1d6
            default: break
            }
            (A, B, C, D, E) = (left_rotate(A, 5) &+ F &+ E &+ M[j] &+ k, A, left_rotate(B, 30), C, D)
        }
        d0 = d0 &+ A
        d1 = d1 &+ B
        d2 = d2 &+ C
        d3 = d3 &+ D
        d4 = d4 &+ E
        offset += 16
    }
    let d = UnsafeMutablePointer<UInt32>(digest)
    d[0] = d0.bigEndian
    d[1] = d1.bigEndian
    d[2] = d2.bigEndian
    d[3] = d3.bigEndian
    d[4] = d4.bigEndian
}
