//
//  CFFDecoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

struct CFFDecoder {
    
    var header: CFFHeader
    
    var faces: [CFFFontFace] = []
    
    init(_ data: Data) throws {
        self.header = try CFFHeader(data)
        
        var copy = data.dropFirst(Int(header.headerSize))
        
        let name = try copy.decode(CFFINDEX.self)
        let DICT = try copy.decode(CFFINDEX.self)
        let string = try copy.decode(CFFINDEX.self)
        let subroutine = try copy.decode(CFFINDEX.self)
        
        for (name, dict) in zip(name, DICT) {
            if let name = String(data: name, encoding: .ascii) {
                faces.append(try CFFFontFace(data, name, try CFFDICT(dict), string, subroutine))
            }
        }
    }
}

struct CFFHeader: ByteDecodable {
    
    var majorVersion: UInt8
    var minorVersion: UInt8
    var headerSize: UInt8
    var offSize: UInt8
    
    init(from data: inout Data) throws {
        self.majorVersion = try data.decode(UInt8.self)
        self.minorVersion = try data.decode(UInt8.self)
        self.headerSize = try data.decode(UInt8.self)
        self.offSize = try data.decode(UInt8.self)
    }
}

