//
//  OpenTypeDecoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

struct OpenTypeDecoder: FontDecoder {
    
    var header: OTFHeader
    var faces: [FontFaceBase]
    
    init?(data: Data, entry: Int) throws {
        var _header = data.dropFirst(entry)
        guard let header = try? _header.decode(OTFHeader.self) else { return nil }
        
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

struct OTFHeader: ByteCodable {
    
    var version: Signature<BEUInt32>
    var numTables: BEUInt16
    var searchRange: BEUInt16
    var entrySelector: BEUInt16
    var rangeShift: BEUInt16
    
    init(version: Signature<BEUInt32>, numTables: Int) {
        self.version = version
        self.numTables = BEUInt16(numTables)
        self.searchRange = BEUInt16(numTables.hibit * 16)
        self.entrySelector = BEUInt16(log2(numTables))
        self.rangeShift = BEUInt16(numTables * 16) - searchRange
    }
    
    init(from data: inout Data) throws {
        self.version = try data.decode(Signature<BEUInt32>.self)
        self.numTables = try data.decode(BEUInt16.self)
        self.searchRange = try data.decode(BEUInt16.self)
        self.entrySelector = try data.decode(BEUInt16.self)
        self.rangeShift = try data.decode(BEUInt16.self)
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(version)
        stream.encode(numTables)
        stream.encode(searchRange)
        stream.encode(entrySelector)
        stream.encode(rangeShift)
    }
}

struct OTFTableRecord: ByteCodable {
    
    var tag: Signature<BEUInt32>
    var checkSum: BEUInt32
    var offset: BEUInt32
    var length: BEUInt32
    
    init(tag: Signature<BEUInt32>,
         checkSum: BEUInt32,
         offset: BEUInt32,
         length: BEUInt32) {
        self.tag = tag
        self.checkSum = checkSum
        self.offset = offset
        self.length = length
    }
    
    init(from data: inout Data) throws {
        self.tag = try data.decode(Signature<BEUInt32>.self)
        self.checkSum = try data.decode(BEUInt32.self)
        self.offset = try data.decode(BEUInt32.self)
        self.length = try data.decode(BEUInt32.self)
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(tag)
        stream.encode(checkSum)
        stream.encode(offset)
        stream.encode(length)
    }
}

