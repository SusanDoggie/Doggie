//
//  PDFASCIIHexFilter.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

func PDFASCIIHexEncode(_ data: Data) -> Data {
    
    var result = Data()
    
    for d in data {
        let high = d >> 4
        let low = d & 15
        switch high {
        case 0...9: result.append(48 + high)
        case 10...15: result.append(65 + (high - 10))
        default: fatalError()
        }
        switch low {
        case 0...9: result.append(48 + high)
        case 10...15: result.append(65 + (high - 10))
        default: fatalError()
        }
        if result.count % 255 == 254 {
            result.append(10)
        }
    }
    
    result.append(62)
    return result
}

func PDFASCIIHexDecode(_ data: Data) throws -> Data {
    
    var result = Data()
    var flag = 0
    var t: UInt8 = 0
    
    for d in data {
        switch d {
        case 0, 9, 10, 12, 13, 32: break
        case 48...57:
            if flag & 1 == 0 {
                t = d - 48
            } else {
                result.append(t * 0x10 + (d - 48))
            }
            flag += 1
        case 65...70:
            if flag & 1 == 0 {
                t = d - 65 + 0xA
            } else {
                result.append(t * 0x10 + (d - 65 + 0xA))
            }
            flag += 1
        case 97...102:
            if flag & 1 == 0 {
                t = d - 97 + 0xA
            } else {
                result.append(t * 0x10 + (d - 97 + 0xA))
            }
            flag += 1
        case 62:
            if flag & 1 == 1 {
                result.append(t * 0x10)
            }
            return result
        default: throw PDFFilterError(message: "unknown character: \(d)")
        }
    }
    
    return result
}
