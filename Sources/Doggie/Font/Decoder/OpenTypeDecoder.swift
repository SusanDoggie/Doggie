//
//  OpenTypeDecoder.swift
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

struct OpenTypeDecoder : FontDecoder {
    
    var header: OTFHeader
    var faces: [FontFaceBase]
    
    init?(data: Data, entry: Int) throws {
        var _header = data.dropFirst(entry)
        guard let header = try? _header.decode(OTFHeader.self), header.version == 0x00010000 || header.version == 0x4F54544F else { return nil }
        
        self.header = header
        
        var table: [Signature<BEUInt32>: Data] = [:]
        for _ in 0..<Int(header.numTables) {
            let record = try _header.decode(OTFTableRecord.self)
            table[record.tag] = data.dropFirst(Int(record.offset)).prefix(Int(record.length))
        }
        self.faces = [try SFNTFontFace(table: table)]
    }
    
    init?(data: Data) throws {
        try self.init(data: data, entry: 0)
    }
}

struct OTFHeader : ByteDecodable {
    
    var version: BEUInt32
    var numTables: BEUInt16
    var searchRange: BEUInt16
    var entrySelector: BEUInt16
    var rangeShift: BEUInt16
    
    init(from data: inout Data) throws {
        self.version = try data.decode(BEUInt32.self)
        self.numTables = try data.decode(BEUInt16.self)
        self.searchRange = try data.decode(BEUInt16.self)
        self.entrySelector = try data.decode(BEUInt16.self)
        self.rangeShift = try data.decode(BEUInt16.self)
    }
}

struct OTFTableRecord : ByteDecodable {
    
    var tag: Signature<BEUInt32>
    var checkSum: BEUInt32
    var offset: BEUInt32
    var length: BEUInt32
    
    init(from data: inout Data) throws {
        self.tag = try data.decode(Signature<BEUInt32>.self)
        self.checkSum = try data.decode(BEUInt32.self)
        self.offset = try data.decode(BEUInt32.self)
        self.length = try data.decode(BEUInt32.self)
    }
}

