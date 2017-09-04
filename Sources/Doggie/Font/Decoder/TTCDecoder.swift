//
//  TTCDecoder.swift
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

struct TTCDecoder : FontDecoder {
    
    var header: TTCHeader
    var collection: [OpenTypeDecoder] = []
    
    init?(data: Data) throws {
        
        guard let header = try? TTCHeader(data), header.tag == "ttcf" else { return nil }
        
        self.header = header
        
        for offset in header.offsetTable where offset != 0 {
            guard let font = try OpenTypeDecoder(data: data, entry: Int(offset)) else { throw FontCollection.Error.InvalidFormat("Invalid font.") }
            self.collection.append(font)
        }
    }
    
    var faces: [FontFaceBase] {
        return collection.flatMap { $0.faces }
    }
}

struct TTCHeader : DataDecodable {
    
    var tag: Signature<BEUInt32>
    var majorVersion: BEUInt16
    var minorVersion: BEUInt16
    var numFonts: BEUInt32
    var offsetTable: [BEUInt32]
    
    init(from data: inout Data) throws {
        self.tag = try data.decode(Signature<BEUInt32>.self)
        self.majorVersion = try data.decode(BEUInt16.self)
        self.minorVersion = try data.decode(BEUInt16.self)
        self.numFonts = try data.decode(BEUInt32.self)
        self.offsetTable = try (0..<Int(numFonts)).map { _ in try data.decode(BEUInt32.self) }
    }
}

