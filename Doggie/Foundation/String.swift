//
//  String.swift
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

public extension String {
    
    var trim: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

public extension String {
    @warn_unused_result
    static func fromBytes(buffer: [UInt8]) -> String! {
        return String.fromCString(UnsafePointer(buffer + [0]))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt64) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt32) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt16) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: UInt8) -> String! {
        let buffer: [UInt8] = [cs, 0]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int64) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 56) & 0xFF),
            UInt8((cs >> 48) & 0xFF),
            UInt8((cs >> 40) & 0xFF),
            UInt8((cs >> 32) & 0xFF),
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int32) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 24) & 0xFF),
            UInt8((cs >> 16) & 0xFF),
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int16) -> String! {
        let buffer: [UInt8] = [
            UInt8((cs >> 8) & 0xFF),
            UInt8(cs & 0xFF),
            0
        ]
        return String.fromCString(UnsafePointer(buffer))
    }
    @warn_unused_result
    static func fromBytes(cs: Int8) -> String! {
        let buffer: [UInt8] = [UInt8(cs), 0]
        return String.fromCString(UnsafePointer(buffer))
    }
}
