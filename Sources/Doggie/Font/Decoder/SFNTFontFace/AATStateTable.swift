//
//  SFNTMORX.swift
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

protocol AATStateMachine {
    
    var stateHeader: AATStateTable { get }
    
    func perform(glyphs: [Int]) -> [Int]
}

struct AATStateTable : ByteDecodable {
    
    var nClasses: BEUInt32
    var classTable: AATLookupTable
    var stateArray: Data
    var entryTable: AATEntryTable
    
    init(from data: inout Data) throws {
        let copy = data
        self.nClasses = try data.decode(BEUInt32.self)
        let classTableOffset = try data.decode(BEUInt32.self)
        let stateArrayOffset = try data.decode(BEUInt32.self)
        let entryTableOffset = try data.decode(BEUInt32.self)
        self.classTable = try AATLookupTable(copy.dropFirst(Int(classTableOffset)))
        self.stateArray = copy.dropFirst(Int(stateArrayOffset))
        self.entryTable = try AATEntryTable(copy.dropFirst(Int(entryTableOffset)))
    }
}

protocol AATLookupTableFormat : ByteDecodable {
    
    func search(glyph: UInt16) -> UInt16?
}

struct AATLookupTable {
    
    var format: BEUInt16
    var fsHeader: AATLookupTableFormat
    
    init(_ data: Data) throws {
        var data = data
        self.format = try data.decode(BEUInt16.self)
        switch format {
        case 0: self.fsHeader = try data.decode(Format0.self)
        case 2: self.fsHeader = try data.decode(Format2.self)
        case 4: self.fsHeader = try data.decode(Format4.self)
        case 6: self.fsHeader = try data.decode(Format6.self)
        case 8: self.fsHeader = try data.decode(Format8.self)
        default: throw FontCollection.Error.InvalidFormat("Invalid AAT lookup table format.")
        }
    }
    
    func search(glyph: UInt16) -> UInt16? {
        return fsHeader.search(glyph: glyph)
    }
}

extension AATLookupTable {
    
    struct BinSrchHeader : ByteDecodable {
        
        var unitSize: BEUInt16
        var nUnits: BEUInt16
        var searchRange: BEUInt16
        var entrySelector: BEUInt16
        var rangeShift: BEUInt16
        
        init(from data: inout Data) throws {
            self.unitSize = try data.decode(BEUInt16.self)
            self.nUnits = try data.decode(BEUInt16.self)
            self.searchRange = try data.decode(BEUInt16.self)
            self.entrySelector = try data.decode(BEUInt16.self)
            self.rangeShift = try data.decode(BEUInt16.self)
        }
    }
    
    struct Format0 : AATLookupTableFormat {
        
        var data: Data
        
        init(from data: inout Data) throws {
            self.data = data.popFirst(data.count)
        }
        
        func search(glyph: UInt16) -> UInt16? {
            var _data = data.dropFirst(Int(glyph) << 1)
            return try? UInt16(_data.decode(BEUInt16.self))
        }
    }
    
    struct Format2 : AATLookupTableFormat {
        
        var binSrchHeader: BinSrchHeader
        
        var data: Data
        
        init(from data: inout Data) throws {
            self.binSrchHeader = try data.decode(BinSrchHeader.self)
            
            let size = Int(self.binSrchHeader.nUnits) * Int(self.binSrchHeader.unitSize)
            self.data = data.popFirst(size)
            guard self.data.count == size else { throw ByteDecodeError.endOfData }
        }
        
        func search(_ glyph: UInt16, _ range: Range<Int>) -> UInt16? {
            
            var range = range
            
            while range.count != 0 {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                
                var _data = data.dropFirst(mid * Int(self.binSrchHeader.unitSize))
                guard let last_glyph = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                guard let first_glyph = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                guard let value = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                
                if first_glyph <= last_glyph && first_glyph...last_glyph ~= glyph {
                    return value
                }
                
                range = glyph < first_glyph ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
            }
            
            return nil
        }
        
        func search(glyph: UInt16) -> UInt16? {
            return search(glyph, 0..<Int(self.binSrchHeader.nUnits))
        }
    }
    
    struct Format4 : AATLookupTableFormat {
        
        var binSrchHeader: BinSrchHeader
        
        var data: Data
        
        init(from data: inout Data) throws {
            self.binSrchHeader = try data.decode(BinSrchHeader.self)
            
            let size = Int(self.binSrchHeader.nUnits) * Int(self.binSrchHeader.unitSize)
            self.data = data.popFirst(data.count)
            guard self.data.count >= size else { throw ByteDecodeError.endOfData }
        }
        
        func search(_ glyph: UInt16, _ range: Range<Int>) -> UInt16? {
            
            var range = range
            
            while range.count != 0 {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                
                var _data = data.dropFirst(mid * Int(self.binSrchHeader.unitSize))
                guard let last_glyph = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                guard let first_glyph = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                guard let offset = try? Int(_data.decode(BEUInt16.self)) else { return nil }
                
                if first_glyph <= last_glyph && first_glyph...last_glyph ~= glyph {
                    guard offset >= 12 else { return nil }
                    var _data = data.dropFirst(offset - 12).dropFirst(Int(glyph - first_glyph) << 1)
                    return try? UInt16(_data.decode(BEUInt16.self))
                }
                
                range = glyph < first_glyph ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
            }
            
            return nil
        }
        
        func search(glyph: UInt16) -> UInt16? {
            return search(glyph, 0..<Int(self.binSrchHeader.nUnits))
        }
    }
    
    struct Format6 : AATLookupTableFormat {
        
        var binSrchHeader: BinSrchHeader
        
        var data: Data
        
        init(from data: inout Data) throws {
            self.binSrchHeader = try data.decode(BinSrchHeader.self)
            
            let size = Int(self.binSrchHeader.nUnits) * Int(self.binSrchHeader.unitSize)
            self.data = data.popFirst(size)
            guard self.data.count == size else { throw ByteDecodeError.endOfData }
        }
        
        func search(_ glyph: UInt16, _ range: Range<Int>) -> UInt16? {
            
            var range = range
            
            while range.count != 0 {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                
                var _data = data.dropFirst(mid * Int(self.binSrchHeader.unitSize))
                guard let _glyph = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                guard let value = try? UInt16(_data.decode(BEUInt16.self)) else { return nil }
                
                if _glyph == glyph {
                    return value
                }
                
                range = glyph < _glyph ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
            }
            
            return nil
        }
        
        func search(glyph: UInt16) -> UInt16? {
            return search(glyph, 0..<Int(self.binSrchHeader.nUnits))
        }
    }
    
    struct Format8 : AATLookupTableFormat {
        
        var firstGlyph: BEUInt16
        var glyphCount: BEUInt16
        
        var data: Data
        
        init(from data: inout Data) throws {
            self.firstGlyph = try data.decode(BEUInt16.self)
            self.glyphCount = try data.decode(BEUInt16.self)
            
            let size = Int(glyphCount) << 1
            self.data = data.popFirst(size)
            guard self.data.count == size else { throw ByteDecodeError.endOfData }
        }
        
        func search(glyph: UInt16) -> UInt16? {
            let index = Int(glyph) - Int(firstGlyph)
            guard 0..<Int(glyphCount) ~= index else { return nil }
            var _data = data.dropFirst((Int(glyph) - Int(firstGlyph)) << 1)
            return try? UInt16(_data.decode(BEUInt16.self))
        }
    }
    
}

struct AATEntryTable {
    
    var newState: BEUInt16
    var flags: BEUInt16
    
    var data: Data
    
    init(_ data: Data) throws {
        var data = data
        self.newState = try data.decode(BEUInt16.self)
        self.flags = try data.decode(BEUInt16.self)
        self.data = data
    }
    
}
