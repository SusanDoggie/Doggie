//
//  TTFCmap.swift
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

protocol TTFCmapTableFormat : DataDecodable {
    
    func parse(_ body: (UInt32, Int) -> Void)
}

struct TTFCmap : DataDecodable {
    
    var version: BEUInt16
    var numTables: BEUInt16
    var table: [Character: Int]
    
    init(from data: inout Data) throws {
        let copy = data
        self.version = try data.decode(BEUInt16.self)
        self.numTables = try data.decode(BEUInt16.self)
        self.table = [:]
        
        var tables: [Table] = []
        for _ in 0..<Int(numTables) {
            let platformID = try data.decode(BEUInt16.self)
            let platformSpecificID = try data.decode(BEUInt16.self)
            let offset = try data.decode(BEUInt32.self)
            let tableData = copy.advanced(by: Int(offset))
            switch Int(try BEUInt16(tableData)) {
            case 0: tables.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format0(tableData)))
            case 4: tables.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format4(tableData)))
            case 12: tables.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format12(tableData)))
            case 13: tables.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format13(tableData)))
            default: break
            }
        }
        
        let _table: Table
        
        if let table = tables.lazy.filter({ $0.platformID == 0 && $0.platformSpecificID <= 4 }).max(by: { $0.platformSpecificID }) {
            _table = table
        } else if let table = tables.first(where: { $0.platformID == 3 && $0.platformSpecificID == 10 }) {
            _table = table
        } else if let table = tables.first(where: { $0.platformID == 3 && $0.platformSpecificID == 1 }) {
            _table = table
        } else if let table = tables.first(where: { $0.platformID == 3 && $0.platformSpecificID == 0 }) {
            _table = table
        } else {
            throw Font.Error.Unsupported("Unsupported cmap format.")
        }
        
        _table.format.parse { char, index in
            if let scalar = UnicodeScalar(char) {
                self.table[Character(scalar)] = index
            }
        }
    }
    
    subscript(char: Character) -> Int {
        return table[char] ?? 0
    }
}

extension TTFCmap {
    
    struct Table {
        
        var platformID: BEUInt16
        var platformSpecificID: BEUInt16
        var format: TTFCmapTableFormat
    }
    
    struct Format0 : TTFCmapTableFormat {
        
        var format: BEUInt16
        var length: BEUInt16
        var language: BEUInt16
        var glyphIndexArray: [UInt8]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.glyphIndexArray = []
            self.glyphIndexArray.reserveCapacity(256)
            for _ in 0..<256 {
                self.glyphIndexArray.append(try data.decode(UInt8.self))
            }
        }
        
        func parse(_ body: (UInt32, Int) -> Void) {
            
            for (code, index) in glyphIndexArray.enumerated() {
                body(UInt32(code), Int(index))
            }
        }
    }
    
    struct Format4 : TTFCmapTableFormat {
        
        var format: BEUInt16
        var length: BEUInt16
        var language: BEUInt16
        var segCountX2: BEUInt16
        var searchRange: BEUInt16
        var entrySelector: BEUInt16
        var rangeShift: BEUInt16
        var endCode: [BEUInt16]
        var reservedPad: BEUInt16
        var startCode: [BEUInt16]
        var idDelta: [BEInt16]
        var idRangeOffset: [BEUInt16]
        var glyphIndexArray: [BEUInt16]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.segCountX2 = try data.decode(BEUInt16.self)
            self.searchRange = try data.decode(BEUInt16.self)
            self.entrySelector = try data.decode(BEUInt16.self)
            self.rangeShift = try data.decode(BEUInt16.self)
            
            let segCount = Int(segCountX2) >> 1
            
            self.endCode = []
            self.startCode = []
            self.idDelta = []
            self.idRangeOffset = []
            self.glyphIndexArray = []
            self.endCode.reserveCapacity(segCount)
            self.startCode.reserveCapacity(segCount)
            self.idDelta.reserveCapacity(segCount)
            self.idRangeOffset.reserveCapacity(segCount)
            
            for _ in 0..<segCount {
                self.endCode.append(try data.decode(BEUInt16.self))
            }
            
            self.reservedPad = try data.decode(BEUInt16.self)
            
            for _ in 0..<segCount {
                self.startCode.append(try data.decode(BEUInt16.self))
            }
            for _ in 0..<segCount {
                self.idDelta.append(try data.decode(BEInt16.self))
            }
            for _ in 0..<segCount {
                self.idRangeOffset.append(try data.decode(BEUInt16.self))
            }
        }
        
        func parse(_ body: (UInt32, Int) -> Void) {
            
        }
    }
    
    struct Format12 : TTFCmapTableFormat {
        
        var format: Fixed16Number<BEUInt32>
        var length: BEUInt32
        var language: BEUInt32
        var nGroups: BEUInt32
        var groups: [Group]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEUInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.nGroups = try data.decode(BEUInt32.self)
            self.groups = []
            self.groups.reserveCapacity(Int(nGroups))
            for _ in 0..<Int(nGroups) {
                self.groups.append(try data.decode(Group.self))
            }
        }
        
        func parse(_ body: (UInt32, Int) -> Void) {
            
            for group in groups {
                var index = Int(group.startGlyphCode)
                for code in UInt32(group.startCharCode)...UInt32(group.endCharCode) {
                    body(code, index)
                    index += 1
                }
            }
        }
    }
    
    struct Format13 : TTFCmapTableFormat {
        
        var format: Fixed16Number<BEUInt32>
        var length: BEUInt32
        var language: BEUInt32
        var nGroups: BEUInt32
        var groups: [Group]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEUInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.nGroups = try data.decode(BEUInt32.self)
            self.groups = []
            self.groups.reserveCapacity(Int(nGroups))
            for _ in 0..<Int(nGroups) {
                self.groups.append(try data.decode(Group.self))
            }
        }
        
        func parse(_ body: (UInt32, Int) -> Void) {
            
            for group in groups {
                let index = Int(group.startGlyphCode)
                for code in UInt32(group.startCharCode)...UInt32(group.endCharCode) {
                    body(code, index)
                }
            }
        }
    }
    
    struct Group : DataDecodable {
        
        var startCharCode: BEUInt32
        var endCharCode: BEUInt32
        var startGlyphCode: BEUInt32
        
        init(from data: inout Data) throws {
            self.startCharCode = try data.decode(BEUInt32.self)
            self.endCharCode = try data.decode(BEUInt32.self)
            self.startGlyphCode = try data.decode(BEUInt32.self)
        }
    }
}
