//
//  sha512.swift
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

private let k: [UInt64] = [
    0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538,
    0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe,
    0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
    0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
    0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab,
    0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
    0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed,
    0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
    0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
    0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53,
    0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373,
    0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
    0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c,
    0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6,
    0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
    0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
]

public func sha512(count: Int, _ bytes: UnsafePointer<UInt8>, _ digest: UnsafeMutablePointer<UInt8>) {
    
    var d0: UInt64 = 0x6a09e667f3bcc908
    var d1: UInt64 = 0xbb67ae8584caa73b
    var d2: UInt64 = 0x3c6ef372fe94f82b
    var d3: UInt64 = 0xa54ff53a5f1d36f1
    var d4: UInt64 = 0x510e527fade682d1
    var d5: UInt64 = 0x9b05688c2b3e6c1f
    var d6: UInt64 = 0x1f83d9abfb41bd6b
    var d7: UInt64 = 0x5be0cd19137e2179
    
    var buf = hash_prepare(bytes, count, 128)
    buf[buf.count(UInt64) - 1] = UInt64(count << 3).bigEndian
    
    var offset = 0
    var M = SecureBuffer(size: 640)
    for _ in 0..<buf.size >> 7 {
        for x in 0..<80 {
            switch (x) {
            case 0..<16:
                M[x] = buf[x + offset].bigEndian as UInt64
            default:
                let s0: UInt64 = right_rotate(M[x - 15], 1) ^ right_rotate(M[x - 15], 8) ^ (M[x - 15] >> 7)
                let s1: UInt64 = right_rotate(M[x - 2], 19) ^ right_rotate(M[x - 2], 61) ^ (M[x - 2] >> 6)
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
        for j in 0..<80 {
            
            let s0 = right_rotate(A, 28) ^ right_rotate(A, 34) ^ right_rotate(A, 39)
            let maj = (A & B) ^ (A & C) ^ (B & C)
            let t2 = s0 &+ maj
            
            let s1 = right_rotate(E, 14) ^ right_rotate(E, 18) ^ right_rotate(E, 41)
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
    let d = UnsafeMutablePointer<UInt64>(digest)
    d[0] = d0.bigEndian
    d[1] = d1.bigEndian
    d[2] = d2.bigEndian
    d[3] = d3.bigEndian
    d[4] = d4.bigEndian
    d[5] = d5.bigEndian
    d[6] = d6.bigEndian
    d[7] = d7.bigEndian
}
