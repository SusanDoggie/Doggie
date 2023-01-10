//
//  OTFLookupList.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

struct OTFLookupList: ByteDecodable {
    
    var lookupCount: BEUInt16
    var lookups: [Lookups]
    
    init(from data: inout Data) throws {
        let copy = data
        self.lookupCount = try data.decode(BEUInt16.self)
        self.lookups = try (0..<Int(lookupCount)).map { _ in try Lookups(copy.dropFirst(Int(try data.decode(BEUInt16.self)))) }
    }
    
    struct Lookups: ByteDecodable {
        
        var lookupType: BEUInt16
        var lookupFlag: BEUInt16
        var subTableCount: BEUInt16
        var subtableOffsets: [BEUInt16]
        var markFilteringSet: BEUInt16
        var data: Data
        
        init(from data: inout Data) throws {
            self.data = data
            self.lookupType = try data.decode(BEUInt16.self)
            self.lookupFlag = try data.decode(BEUInt16.self)
            self.subTableCount = try data.decode(BEUInt16.self)
            self.subtableOffsets = try (0..<Int(subTableCount)).map { _ in try data.decode(BEUInt16.self) }
            self.markFilteringSet = try data.decode(BEUInt16.self)
        }
    }
}
