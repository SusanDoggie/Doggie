//
//  sha224.swift
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

private let k: [UInt32] = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

public func sha224(count: Int, _ bytes: UnsafePointer<UInt8>, _ digest: UnsafeMutablePointer<UInt8>) {
    
    var d0: UInt32 = 0xc1059ed8
    var d1: UInt32 = 0x367cd507
    var d2: UInt32 = 0x3070dd17
    var d3: UInt32 = 0xf70e5939
    var d4: UInt32 = 0xffc00b31
    var d5: UInt32 = 0x68581511
    var d6: UInt32 = 0x64f98fa7
    var d7: UInt32 = 0xbefa4fa4
    
    var buf = hash_prepare(bytes, count, 64)
    buf[buf.count(UInt64) - 1] = UInt64(count << 3).bigEndian
    
    var offset = 0
    var M = SecureBuffer(size: 256)
    for _ in 0..<buf.size >> 6 {
        for x in 0..<64 {
            switch (x) {
            case 0..<16:
                M[x] = buf[x + offset].bigEndian as UInt32
            default:
                let s0: UInt32 = right_rotate(M[x - 15], 7) ^ right_rotate(M[x - 15], 18) ^ (M[x - 15] >> 3)
                let s1: UInt32 = right_rotate(M[x - 2], 17) ^ right_rotate(M[x - 2], 19) ^ (M[x - 2] >> 10)
                M[x] = M[x-16] &+ s0 &+ M[x-7] &+ s1
            }
        }
        
        var A = d0
        var B = d1
        var C = d2
        var D = d3
        var E = d4
        var F = d5
        var G = d6
        var H = d7
        for j in 0..<64 {
            
            let s0 = right_rotate(A, 2) ^ right_rotate(A, 13) ^ right_rotate(A, 22)
            let maj = (A & B) ^ (A & C) ^ (B & C)
            let t2 = s0 &+ maj
            
            let s1 = right_rotate(E, 6) ^ right_rotate(E, 11) ^ right_rotate(E, 25)
            let ch = (E & F) ^ ((~E) & G)
            let t1 = H &+ s1 &+ ch &+ k[j] &+ M[j]
            
            H = G
            G = F
            F = E
            E = D &+ t1
            D = C
            C = B
            B = A
            A = t1 &+ t2
        }
        d0 = d0 &+ A
        d1 = d1 &+ B
        d2 = d2 &+ C
        d3 = d3 &+ D
        d4 = d4 &+ E
        d5 = d5 &+ F
        d6 = d6 &+ G
        d7 = d7 &+ H
        offset += 16
    }
    let d = UnsafeMutablePointer<UInt32>(digest)
    d[0] = d0.bigEndian
    d[1] = d1.bigEndian
    d[2] = d2.bigEndian
    d[3] = d3.bigEndian
    d[4] = d4.bigEndian
    d[5] = d5.bigEndian
    d[6] = d6.bigEndian
}
