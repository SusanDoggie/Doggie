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
    
    struct Table {
        
        var s: UInt32 = 9
        var table: [[UInt8]] = [] {
            didSet {
                switch table.count {
                case 0...254: s = 9
                case 255...766: s = 10
                case 767...1790: s = 11
                case 1791...3838: s = 12
                default: s = 0
                }
            }
        }
        
        subscript(code: UInt32) -> [UInt8]? {
            switch code {
            case 0...255: return [UInt8(code)]
            case 258...4095:
                let idx = Int(code) - 258
                return idx < table.count ? table[idx] : nil
            default: return nil
            }
        }
    }
    
    var t: UInt32 = 0
    var flag: UInt32 = 0
    var code: UInt32 = 256
    
    var result = Data()
    var table = Table()
    
    func write_buf() throws -> Bool {
        let s = table.s
        if s == 0 {
            throw PDFFilterError(message: "invalid LZWDecode format.")
        }
        flag -= s
        let m = ((1 << s) - 1) << flag
        let _code = code
        code = (t & m) >> flag
        switch code {
        case 256: table.table.removeAll(keepingCapacity: true)
        case 257: return true
        default:
            if _code == 256 {
                if let record = table[code] {
                    result.append(contentsOf: record)
                } else {
                    throw PDFFilterError(message: "invalid LZWDecode format.")
                }
            } else if let _record = table[_code] {
                if let record = table[code] {
                    result.append(contentsOf: record)
                    if table.table.count != 3838 {
                        table.table.append(_record + CollectionOfOne(record[0]))
                    }
                } else {
                    result.append(contentsOf: _record + CollectionOfOne(_record[0]))
                    table.table.append(_record + CollectionOfOne(_record[0]))
                }
            } else {
                throw PDFFilterError(message: "invalid LZWDecode format.")
            }
        }
        return false
    }
    
    table.table.reserveCapacity(3838)
    for d in data {
        t = ((t & ((1 << flag) - 1)) << 8) | UInt32(d)
        flag += 8
        while flag >= table.s {
            if try write_buf() {
                return result
            }
        }
    }
    while flag >= table.s {
        if try write_buf() {
            return result
        }
    }
    
    throw PDFFilterError(message: "invalid LZWDecode format.")
}
