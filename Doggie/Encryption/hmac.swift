//
//  hmac.swift
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

private func hmac(hash: ([UInt8]) -> [UInt8], _ block_size: Int, var _ key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    if key.count > block_size {
        key = hash(key)
    }
    if key.count < block_size {
        key.appendContentsOf(Repeat(count: block_size - key.count, repeatedValue: 0))
    }
    let o_key = key.map { opad ^ $0 }
    let i_key = key.map { ipad ^ $0 }
    return hash(o_key + hash(i_key + message))
}

@warn_unused_result
public func hmac_md5(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(md5, 64, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_sha1(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(sha1, 64, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_sha224(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(sha224, 64, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_sha256(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(sha256, 64, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_sha384(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(sha384, 128, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_sha512(key: [UInt8], _ message: [UInt8]) -> [UInt8] {
    return hmac(sha512, 128, key, message, opad: 0x5c, ipad: 0x36)
}

@warn_unused_result
public func hmac_md5(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(md5, 64, key, message, opad: opad, ipad: ipad)
}

@warn_unused_result
public func hmac_sha1(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(sha1, 64, key, message, opad: opad, ipad: ipad)
}

@warn_unused_result
public func hmac_sha224(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(sha224, 64, key, message, opad: opad, ipad: ipad)
}

@warn_unused_result
public func hmac_sha256(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(sha256, 64, key, message, opad: opad, ipad: ipad)
}

@warn_unused_result
public func hmac_sha384(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(sha384, 128, key, message, opad: opad, ipad: ipad)
}

@warn_unused_result
public func hmac_sha512(key: [UInt8], _ message: [UInt8], opad: UInt8, ipad: UInt8) -> [UInt8] {
    return hmac(sha512, 128, key, message, opad: opad, ipad: ipad)
}
