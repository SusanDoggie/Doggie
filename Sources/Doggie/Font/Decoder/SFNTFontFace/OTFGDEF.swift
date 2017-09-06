//
//  OTFGDEF.swift
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

struct OTFGDEF : DataDecodable {
    
    var version: Fixed16Number<BEInt32>
    var glyphClassDefOffset: BEUInt16
    var attachListOffset: BEUInt16
    var ligCaretListOffset: BEUInt16
    var markAttachClassDefOffset: BEUInt16
    
    init(from data: inout Data) throws {
        self.version = try data.decode(Fixed16Number<BEInt32>.self)
        self.glyphClassDefOffset = try data.decode(BEUInt16.self)
        self.attachListOffset = try data.decode(BEUInt16.self)
        self.ligCaretListOffset = try data.decode(BEUInt16.self)
        self.markAttachClassDefOffset = try data.decode(BEUInt16.self)
    }
    
    struct ClassDefTable : DataDecodable {
        
        var classFormat: BEUInt16
        
        var startGlyphID: BEUInt16
        var glyphCount: BEUInt16
        var classRangeCount: BEUInt16
        var data: Data
        
        init(from data: inout Data) throws {
            
            self.classFormat = try data.decode(BEUInt16.self)
            
            self.startGlyphID = 0
            self.glyphCount = 0
            self.classRangeCount = 0
            self.data = Data()
            
            switch classFormat {
            case 1:
                
                self.startGlyphID = try data.decode(BEUInt16.self)
                self.glyphCount = try data.decode(BEUInt16.self)
                self.data = data.popFirst(Int(glyphCount) << 1)
                guard self.data.count == Int(glyphCount) << 1 else { throw DataDecodeError.endOfData }
                
            case 2:
                
                self.classRangeCount = try data.decode(BEUInt16.self)
                self.data = data.popFirst(Int(classRangeCount) * 6)
                guard self.data.count == Int(classRangeCount) * 6 else { throw DataDecodeError.endOfData }
                
            default: throw FontCollection.Error.InvalidFormat("Invalid GDEF format.")
            }
        }
    }
}

