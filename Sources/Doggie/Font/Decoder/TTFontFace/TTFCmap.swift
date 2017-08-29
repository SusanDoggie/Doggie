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
    
}

struct TTFCmap : DataDecodable {
    
    var version: BEUInt16
    var numTables: BEUInt16
    var table: [Table]
    
    init(from data: inout Data) throws {
        let copy = data
        self.version = try data.decode(BEUInt16.self)
        self.numTables = try data.decode(BEUInt16.self)
        self.table = []
        for _ in 0..<Int(numTables) {
            let platformID = try data.decode(BEUInt16.self)
            let platformSpecificID = try data.decode(BEUInt16.self)
            let offset = try data.decode(BEUInt32.self)
            let tableData = copy.advanced(by: Int(offset))
            switch Int(try BEUInt16(tableData)) {
            case 0: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format0(tableData)))
            case 2: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format2(tableData)))
            case 4: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format4(tableData)))
            case 6: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format6(tableData)))
            case 8: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format8(tableData)))
            case 10: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format10(tableData)))
            case 12: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format12(tableData)))
            case 14: table.append(Table(platformID: platformID, platformSpecificID: platformSpecificID, format: try Format14(tableData)))
            default: throw Font.Error.Unsupported("Unsupported cmap format.")
            }
        }
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
    }
    
    struct Format2 : TTFCmapTableFormat {
        
        var format: BEUInt16
        var length: BEUInt16
        var language: BEUInt16
        var subHeaderKeys: [BEUInt16]
        var subHeaders: [SubHeader]
        var glyphIndexArray: [BEUInt16]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.subHeaderKeys = []
            self.subHeaders = []
            self.glyphIndexArray = []
            self.subHeaderKeys.reserveCapacity(256)
            for _ in 0..<256 {
                self.subHeaderKeys.append(try data.decode(BEUInt16.self))
            }
        }
        
        struct SubHeader : DataDecodable {
            
            var firstCode: BEUInt16
            var entryCount: BEUInt16
            var idDelta: BEInt16
            var idRangeOffset: BEUInt16
            
            init(from data: inout Data) throws {
                self.firstCode = try data.decode(BEUInt16.self)
                self.entryCount = try data.decode(BEUInt16.self)
                self.idDelta = try data.decode(BEInt16.self)
                self.idRangeOffset = try data.decode(BEUInt16.self)
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
    }
    
    struct Format6 : TTFCmapTableFormat {
        
        var format: BEUInt16
        var length: BEUInt16
        var language: BEUInt16
        var firstCode: BEUInt16
        var entryCount: BEUInt16
        var glyphIndexArray: [BEUInt16]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.firstCode = try data.decode(BEUInt16.self)
            self.entryCount = try data.decode(BEUInt16.self)
            self.glyphIndexArray = []
            self.glyphIndexArray.reserveCapacity(Int(entryCount))
            for _ in 0..<Int(entryCount) {
                self.glyphIndexArray.append(try data.decode(BEUInt16.self))
            }
        }
    }
    
    struct Format8 : TTFCmapTableFormat {
        
        var format: Fixed16Number<BEUInt32>
        var length: BEUInt32
        var language: BEUInt32
        var is32: [UInt8]
        var nGroups: BEUInt32
        var groups: [Group]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEUInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.is32 = []
            self.is32.reserveCapacity(65536)
            for _ in 0..<65536 {
                self.is32.append(try data.decode(UInt8.self))
            }
            self.nGroups = try data.decode(BEUInt32.self)
            self.groups = []
            self.groups.reserveCapacity(Int(nGroups))
            for _ in 0..<Int(nGroups) {
                self.groups.append(try data.decode(Group.self))
            }
        }
    }
    
    struct Format10 : TTFCmapTableFormat {
        
        var format: Fixed16Number<BEUInt32>
        var length: BEUInt32
        var language: BEUInt32
        var startCharCode: BEUInt32
        var numChars: BEUInt32
        var glyphs: [BEUInt16]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEUInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.startCharCode = try data.decode(BEUInt32.self)
            self.numChars = try data.decode(BEUInt32.self)
            self.glyphs = []
            self.glyphs.reserveCapacity(Int(numChars))
            for _ in 0..<Int(numChars) {
                self.glyphs.append(try data.decode(BEUInt16.self))
            }
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
    }
    
    struct Format14 : TTFCmapTableFormat {
        
        var format: BEUInt16
        var length: BEUInt32
        var numVarSelectorRecords: BEUInt32
        var records: [Record]
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt32.self)
            self.numVarSelectorRecords = try data.decode(BEUInt32.self)
            self.records = []
            self.records.reserveCapacity(Int(numVarSelectorRecords))
            for _ in 0..<Int(numVarSelectorRecords) {
                self.records.append(try data.decode(Record.self))
            }
        }
        
        struct Record : DataDecodable {
            
            var varSelector: (UInt8, UInt8, UInt8)
            var defaultUVSOffset: BEUInt32
            var nonDefaultUVSOffset: BEUInt32
            
            init(from data: inout Data) throws {
                self.varSelector = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
                self.defaultUVSOffset = try data.decode(BEUInt32.self)
                self.nonDefaultUVSOffset = try data.decode(BEUInt32.self)
            }
        }
        
        struct DefaultUVS : DataDecodable {
            
            var numUnicodeValueRanges: BEUInt32
            var ranges: [UnicodeValueRange]
            
            init(from data: inout Data) throws {
                self.numUnicodeValueRanges = try data.decode(BEUInt32.self)
                self.ranges = []
                self.ranges.reserveCapacity(Int(numUnicodeValueRanges))
                for _ in 0..<Int(numUnicodeValueRanges) {
                    self.ranges.append(try data.decode(UnicodeValueRange.self))
                }
            }
        }
        
        struct NonDefaultUVS : DataDecodable {
            
            var numUVSMappings: BEUInt32
            var mappings: [UVSMapping]
            
            init(from data: inout Data) throws {
                self.numUVSMappings = try data.decode(BEUInt32.self)
                self.mappings = []
                self.mappings.reserveCapacity(Int(numUVSMappings))
                for _ in 0..<Int(numUVSMappings) {
                    self.mappings.append(try data.decode(UVSMapping.self))
                }
            }
        }
        
        struct UnicodeValueRange : DataDecodable {
            
            var startUnicodeValue: (UInt8, UInt8, UInt8)
            var additionalCount: UInt8
            
            init(from data: inout Data) throws {
                self.startUnicodeValue = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
                self.additionalCount = try data.decode(UInt8.self)
            }
        }
        
        struct UVSMapping : DataDecodable {
            
            var unicodeValue: (UInt8, UInt8, UInt8)
            var glyphID: BEUInt16
            
            init(from data: inout Data) throws {
                self.unicodeValue = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
                self.glyphID = try data.decode(BEUInt16.self)
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
