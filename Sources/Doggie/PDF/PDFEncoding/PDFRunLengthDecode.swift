//
//  PDFRunLengthDecode.swift
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

func PDFRunLengthDecode(_ data: Data) throws -> Data {
    
    var result = Data()
    var length1: UInt8 = 0
    var length2: UInt8 = 0
    
    for d in data {
        if length1 == 0 && length2 == 0 {
            switch d {
            case 0...127: length1 = d
            case 129...255: length2 = 1 &- d
            case 128: return result
            default: fatalError()
            }
        } else if length1 != 0 {
            result.append(d)
            length1 -= 1
        } else {
            for _ in 0..<length2 {
                result.append(d)
            }
            length2 = 0
        }
    }
    throw PDFFilterError(message: "invalid RunLengthDecode format.")
}
