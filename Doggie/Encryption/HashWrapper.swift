//
//  Wrapper.swift
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

@warn_unused_result
public func md5(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 16, repeatedValue: 0)
    md5(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func sha1(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 20, repeatedValue: 0)
    sha1(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func sha224(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 28, repeatedValue: 0)
    sha224(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func sha256(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 32, repeatedValue: 0)
    sha256(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func sha384(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 48, repeatedValue: 0)
    sha384(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func sha512(bytes: [UInt8]) -> [UInt8] {
    var digest = [UInt8](count: 64, repeatedValue: 0)
    sha512(bytes.count, bytes, &digest)
    return digest
}

@warn_unused_result
public func md5(str: String) -> [UInt8] {
    return md5([UInt8](str.utf8))
}

@warn_unused_result
public func sha1(str: String) -> [UInt8] {
    return sha1([UInt8](str.utf8))
}

@warn_unused_result
public func sha224(str: String) -> [UInt8] {
    return sha224([UInt8](str.utf8))
}

@warn_unused_result
public func sha256(str: String) -> [UInt8] {
    return sha256([UInt8](str.utf8))
}

@warn_unused_result
public func sha384(str: String) -> [UInt8] {
    return sha384([UInt8](str.utf8))
}

@warn_unused_result
public func sha512(str: String) -> [UInt8] {
    return sha512([UInt8](str.utf8))
}

@warn_unused_result
public func hmac_md5(key: String, _ message: String) -> [UInt8] {
    return hmac_md5([UInt8](key.utf8), [UInt8](message.utf8))
}

@warn_unused_result
public func hmac_sha1(key: String, _ message: String) -> [UInt8] {
    return hmac_sha1([UInt8](key.utf8), [UInt8](message.utf8))
}

@warn_unused_result
public func hmac_sha224(key: String, _ message: String) -> [UInt8] {
    return hmac_sha224([UInt8](key.utf8), [UInt8](message.utf8))
}

@warn_unused_result
public func hmac_sha256(key: String, _ message: String) -> [UInt8] {
    return hmac_sha256([UInt8](key.utf8), [UInt8](message.utf8))
}

@warn_unused_result
public func hmac_sha384(key: String, _ message: String) -> [UInt8] {
    return hmac_sha384([UInt8](key.utf8), [UInt8](message.utf8))
}

@warn_unused_result
public func hmac_sha512(key: String, _ message: String) -> [UInt8] {
    return hmac_sha512([UInt8](key.utf8), [UInt8](message.utf8))
}