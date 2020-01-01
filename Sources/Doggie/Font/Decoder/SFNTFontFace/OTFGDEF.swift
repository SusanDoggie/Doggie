//
//  OTFGDEF.swift
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

struct OTFGDEF : ByteDecodable {
    
    var version: Fixed16Number<BEInt32>
    var glyphClassDefOffset: BEUInt16
    var attachListOffset: BEUInt16
    var ligCaretListOffset: BEUInt16
    var markAttachClassDefOffset: BEUInt16
    
    var glyphClassDef: GlyphClassDef
    
    init(from data: inout Data) throws {
        let copy = data
        self.version = try data.decode(Fixed16Number<BEInt32>.self)
        self.glyphClassDefOffset = try data.decode(BEUInt16.self)
        self.attachListOffset = try data.decode(BEUInt16.self)
        self.ligCaretListOffset = try data.decode(BEUInt16.self)
        self.markAttachClassDefOffset = try data.decode(BEUInt16.self)
        self.glyphClassDef = try GlyphClassDef(copy.dropFirst(Int(glyphClassDefOffset)))
    }
    
    struct GlyphClassDef : ByteDecodable {
        
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
                guard self.data.count == Int(glyphCount) << 1 else { throw ByteDecodeError.endOfData }
                
            case 2:
                
                self.classRangeCount = try data.decode(BEUInt16.self)
                self.data = data.popFirst(Int(classRangeCount) * 6)
                guard self.data.count == Int(classRangeCount) * 6 else { throw ByteDecodeError.endOfData }
                
            default: throw FontCollection.Error.InvalidFormat("Invalid GDEF format.")
            }
        }
        
        func classOf(glyph: BEUInt16) -> BEUInt16 {
            
            let glyph = UInt16(glyph)
            
            switch classFormat {
            case 1:
                let startGlyphID = UInt16(self.startGlyphID)
                if glyph >= startGlyphID {
                    let offset = Int(glyph - startGlyphID)
                    if offset < glyphCount {
                        return data.typed(as: BEUInt16.self)[offset]
                    }
                }
            case 2:
                
                var range = 0..<Int(classRangeCount)
                
                let record = data.typed(as: ClassRangeRecord.self)
                
                while range.count != 0 {
                    
                    let mid = (range.lowerBound + range.upperBound) >> 1
                    let startGlyphID = UInt16(record[mid].startGlyphID)
                    let endGlyphID = UInt16(record[mid].endGlyphID)
                    if startGlyphID <= endGlyphID && startGlyphID...endGlyphID ~= glyph {
                        return record[mid]._class
                    }
                    range = glyph < startGlyphID ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
                }
                
                return 0
                
            default: break
            }
            return 0
        }
        
        struct ClassRangeRecord {
            
            var startGlyphID: BEUInt16
            var endGlyphID: BEUInt16
            var _class: BEUInt16
        }
    }
}

