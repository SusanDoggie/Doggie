//
//  WOFFDecoder.swift
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

struct WOFFDecoder : FontDecoder {
    
    var header: WOFFHeader
    var faces: [FontFaceBase]
    
    init?(data: Data) throws {
        var _header = data
        guard let header = try? _header.decode(WOFFHeader.self), header.signature == "wOFF" && (header.flavor == 0x00010000 || header.flavor == 0x4F54544F) else { return nil }
        
        self.header = header
        
        var table: [Signature<BEUInt32>: Data] = [:]
        for _ in 0..<Int(header.numTables) {
            let record = try _header.decode(WOFFTableRecord.self)
            if record.compLength == record.origLength {
                table[record.tag] = data.dropFirst(Int(record.offset)).prefix(Int(record.origLength))
            } else {
                table[record.tag] = try Inflate().process(data.dropFirst(Int(record.offset)).prefix(Int(record.compLength)))
            }
        }
        self.faces = [try SFNTFontFace(table: table)]
    }
}

struct WOFFHeader : ByteDecodable {
    
    var signature: Signature<BEUInt32>
    var flavor: BEUInt32
    var length: BEUInt32
    var numTables: BEUInt16
    var reserved: BEUInt16
    var totalSfntSize: BEUInt32
    var majorVersion: BEUInt16
    var minorVersion: BEUInt16
    var metaOffset: BEUInt32
    var metaLength: BEUInt32
    var metaOrigLength: BEUInt32
    var privOffset: BEUInt32
    var privLength: BEUInt32
    
    init(from data: inout Data) throws {
        self.signature = try data.decode(Signature<BEUInt32>.self)
        self.flavor = try data.decode(BEUInt32.self)
        self.length = try data.decode(BEUInt32.self)
        self.numTables = try data.decode(BEUInt16.self)
        self.reserved = try data.decode(BEUInt16.self)
        self.totalSfntSize = try data.decode(BEUInt32.self)
        self.majorVersion = try data.decode(BEUInt16.self)
        self.minorVersion = try data.decode(BEUInt16.self)
        self.metaOffset = try data.decode(BEUInt32.self)
        self.metaLength = try data.decode(BEUInt32.self)
        self.metaOrigLength = try data.decode(BEUInt32.self)
        self.privOffset = try data.decode(BEUInt32.self)
        self.privLength = try data.decode(BEUInt32.self)
    }
}

struct WOFFTableRecord : ByteDecodable {
    
    var tag: Signature<BEUInt32>
    var offset: BEUInt32
    var compLength: BEUInt32
    var origLength: BEUInt32
    var origChecksum: BEUInt32
    
    init(from data: inout Data) throws {
        self.tag = try data.decode(Signature<BEUInt32>.self)
        self.offset = try data.decode(BEUInt32.self)
        self.compLength = try data.decode(BEUInt32.self)
        self.origLength = try data.decode(BEUInt32.self)
        self.origChecksum = try data.decode(BEUInt32.self)
    }
}

