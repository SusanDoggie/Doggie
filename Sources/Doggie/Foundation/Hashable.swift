//
//  Hashable.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

@_versioned
let _hash_magic = Int(bitPattern: UInt(round(0.6180339887498948482045868343656381177203091798057628 * Double(UInt.max))))

@_versioned
@_transparent
func _hash_combine(_ lhs: Int, _ rhs: Int) -> Int {
    let a = lhs << 6
    let b = lhs >> 2
    let c = rhs &+ _hash_magic &+ a &+ b
    return lhs ^ c
}

@_inlineable
public func hash_combine<S: Sequence>(_ values: S) -> Int where S.Element : Hashable {
    return values.reduce(0) { _hash_combine($0, $1.hashValue) }
}

@_inlineable
public func hash_combine(_ firstValue: AnyHashable, _ secondValue: AnyHashable, _ remains: AnyHashable ...) -> Int {
    return remains.reduce(_hash_combine(firstValue.hashValue, secondValue.hashValue)) { _hash_combine($0, $1.hashValue) }
}

