//
//  PDFLZWDecode.swift
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

func PDFLZWDecode(_ data: Data) throws -> Data {
    
    var t: UInt32 = 0
    var flag: UInt32 = 0
    var sequence: [UInt8] = []
    var s: UInt32 = 9
    
    var result = Data()
    var table: [[UInt8]] = [] {
        didSet {
            switch table.count {
            case 0...254: s = 9
            case 255...766: s = 10
            case 767...1790: s = 11
            case 1791...3838: s = 12
            default: fatalError()
            }
        }
    }
    
    func write_buf() throws -> Bool {
        let shift = flag - s
        let m = ((1 << s) - 1) << shift
        let code = (t & m) >> shift
        switch code {
        case 0...255:
            result.append(UInt8(code))
            if table.count >= 3838 {
                table.removeAll(keepingCapacity: true)
            }
            if sequence.count == 0 {
                table.append([UInt8(code), UInt8(code)])
                sequence = [UInt8(code), UInt8(code)]
            } else {
                table.append(sequence + CollectionOfOne(UInt8(code)))
                sequence = [UInt8(code)]
            }
        case 258...4095:
            if sequence.count == 0 {
                throw PDFFilterError(message: "invalid LZWDecode format.")
            }
            let idx = Int(code) - 258
            if idx >= table.count {
                throw PDFFilterError(message: "invalid LZWDecode format.")
            }
            let record = table[idx]
            result.append(contentsOf: record)
            if table.count >= 3838 {
                table.removeAll(keepingCapacity: true)
            }
            table.append(sequence + CollectionOfOne(record[0]))
            sequence = record
        case 256: table.removeAll(keepingCapacity: true)
        case 257: return true
        default: throw PDFFilterError(message: "invalid LZWDecode format.")
        }
        flag -= s
        return false
    }
    
    table.reserveCapacity(3838)
    for d in data {
        t = ((t & ((1 << flag) - 1)) << 8) | UInt32(d)
        flag += 8
        while flag >= s {
            if try write_buf() {
                return result
            }
        }
    }
    while flag >= s {
        if try write_buf() {
            return result
        }
    }
    
    throw PDFFilterError(message: "invalid LZWDecode format.")
}
