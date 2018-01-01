//
//  PDFASCII85Decode.swift
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

func PDFASCII85Decode(_ data: Data) throws -> Data {
    
    var result = Data()
    var flag = 0
    var t: UInt64 = 0
    
    for (pos, d) in data.enumerated() {
        switch d {
        case 0, 9, 10, 12, 13, 32: break
        case 33...117:
            switch flag % 5 {
            case 0: t = UInt64(d - 33) * 85 * 85 * 85 * 85
            case 1: t += UInt64(d - 33) * 85 * 85 * 85
            case 2: t += UInt64(d - 33) * 85 * 85
            case 3: t += UInt64(d - 33) * 85
            case 4:
                t += UInt64(d - 33)
                if t > UInt64(UInt32.max) {
                    throw PDFFilterError(message: "invalid ASCII85Decode format.")
                }
                result.append(UInt8((t >> 24) & 0xFF))
                result.append(UInt8((t >> 16) & 0xFF))
                result.append(UInt8((t >> 8) & 0xFF))
                result.append(UInt8(t & 0xFF))
            default: fatalError()
            }
            flag += 1
        case 122:
            switch flag % 5 {
            case 0:
                result.append(0)
                result.append(0)
                result.append(0)
                result.append(0)
            default: throw PDFFilterError(message: "invalid ASCII85Decode format.")
            }
        case 126:
            if pos + 1 != data.count && data[pos + 1] == 62 {
                switch flag % 5 {
                case 0: break
                case 2:
                    result.append(UInt8((t >> 24) & 0xFF))
                case 3:
                    result.append(UInt8((t >> 24) & 0xFF))
                    result.append(UInt8((t >> 16) & 0xFF))
                case 4:
                    result.append(UInt8((t >> 24) & 0xFF))
                    result.append(UInt8((t >> 16) & 0xFF))
                    result.append(UInt8((t >> 8) & 0xFF))
                default: throw PDFFilterError(message: "invalid ASCII85Decode format.")
                }
                return result
            }
            throw PDFFilterError(message: "invalid ASCII85Decode format.")
        default: throw PDFFilterError(message: "unknown character: \(d)")
        }
    }
    
    return result
}
