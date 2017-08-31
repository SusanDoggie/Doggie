//
//  SFNTCMAP.swift
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

protocol SFNTCMAPTableFormat : DataDecodable {
    
    subscript(code: UInt32) -> Int { get }
    
    var coveredCharacterSet: CharacterSet { get }
}

struct SFNTCMAP : DataDecodable {
    
    var version: BEUInt16
    var numTables: BEUInt16
    var table: Table
    
    init(from data: inout Data) throws {
        let copy = data
        self.version = try data.decode(BEUInt16.self)
        self.numTables = try data.decode(BEUInt16.self)
        
        var tables: [Table] = []
        for _ in 0..<Int(numTables) {
            let platform = try data.decode(SFNTPlatform.self)
            let offset = try data.decode(BEUInt32.self)
            let tableData = copy.dropFirst(Int(offset))
            switch Int(try BEUInt16(tableData)) {
            case 0: tables.append(Table(platform: platform, format: try Format0(tableData)))
            case 4: tables.append(Table(platform: platform, format: try Format4(tableData)))
            case 12: tables.append(Table(platform: platform, format: try Format12(tableData)))
            case 13: tables.append(Table(platform: platform, format: try Format13(tableData)))
            default: break
            }
        }
        
        if let table = tables.lazy.filter({ $0.platform.platform == 0 && $0.platform.specific <= 4 }).max(by: { $0.platform.specific }) {
            self.table = table
        } else if let table = tables.first(where: { $0.platform.platform == 3 && $0.platform.specific == 10 }) {
            self.table = table
        } else if let table = tables.first(where: { $0.platform.platform == 3 && $0.platform.specific == 1 }) {
            self.table = table
        } else if let table = tables.first(where: { $0.platform.platform == 3 && $0.platform.specific == 0 }) {
            self.table = table
        } else {
            throw FontCollection.Error.Unsupported("Unsupported cmap format.")
        }
    }
}

extension SFNTCMAP : CustomStringConvertible {
    
    var description: String {
        return "SFNTCMAP(version: \(version), numTables: \(numTables))"
    }
}

extension SFNTCMAP {
    
    struct Table {
        
        var platform: SFNTPlatform
        var format: SFNTCMAPTableFormat
    }
    
    struct Format0 : SFNTCMAPTableFormat {
        
        var format: BEUInt16
        var length: BEUInt16
        var language: BEUInt16
        var data: Data
        
        init(from data: inout Data) throws {
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.data = data.popFirst(256)
        }
        
        subscript(code: UInt32) -> Int {
            guard code < 256 else { return 0 }
            return Int(data[Int(code)])
        }
        
        var coveredCharacterSet: CharacterSet {
            return CharacterSet(data.enumerated().flatMap { $1 != 0 ? UnicodeScalar($0) : nil })
        }
    }
    
    struct Format4 : SFNTCMAPTableFormat {
        
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
        
        subscript(code: UInt32) -> Int {
            return 0
        }
        
        var coveredCharacterSet: CharacterSet {
            return CharacterSet()
        }
    }
    
    struct Format12 : SFNTCMAPTableFormat {
        
        var format: Fixed16Number<BEInt32>
        var length: BEUInt32
        var language: BEUInt32
        var nGroups: BEUInt32
        var groups: Data
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.nGroups = try data.decode(BEUInt32.self)
            guard data.count >= Int(nGroups) * MemoryLayout<Group>.stride else { throw DataDecodeError.endOfData }
            self.groups = data.popFirst(Int(nGroups))
        }
        
        func search(_ code: UInt32, _ groups: UnsafePointer<Group>, _ range: CountableRange<Int>) -> Int {
            
            guard range.count != 0 else { return 0 }
            
            if range.count == 1 {
                
                let startCharCode = UInt32(groups[range.startIndex].startCharCode)
                let endCharCode = UInt32(groups[range.startIndex].endCharCode)
                return startCharCode <= endCharCode && startCharCode...endCharCode ~= code ? Int(code - startCharCode) + Int(groups[range.startIndex].startGlyphCode) : 0
                
            } else {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                
                let startCharCode = UInt32(groups[range.startIndex + mid].startCharCode)
                let endCharCode = UInt32(groups[range.startIndex + mid].endCharCode)
                if startCharCode <= endCharCode && startCharCode...endCharCode ~= code {
                    return Int(code - startCharCode) + Int(groups[range.startIndex].startGlyphCode)
                }
                return code < startCharCode ? search(code, groups, range.prefix(upTo: mid)) : search(code, groups, range.suffix(from: mid).dropFirst())
            }
        }
        
        subscript(code: UInt32) -> Int {
            return groups.withUnsafeBytes { search(code, $0, 0..<Int(self.nGroups)) }
        }
        
        var coveredCharacterSet: CharacterSet {
            
            var result = CharacterSet()
            
            groups.withUnsafeBytes { (groups: UnsafePointer<Group>) in
                
                for group in UnsafeBufferPointer(start: groups, count: Int(self.nGroups)) {
                    
                    let startCharCode: UnicodeScalar
                    let endCharCode: UnicodeScalar
                    
                    if group.startGlyphCode == 0 {
                        
                        guard let _startCharCode = UnicodeScalar(UInt32(group.startCharCode) + 1) else { continue }
                        guard let _endCharCode = UnicodeScalar(UInt32(group.endCharCode)) else { continue }
                        
                        startCharCode = _startCharCode
                        endCharCode = _endCharCode
                        
                    } else {
                        
                        guard let _startCharCode = UnicodeScalar(UInt32(group.startCharCode)) else { continue }
                        guard let _endCharCode = UnicodeScalar(UInt32(group.endCharCode)) else { continue }
                        
                        startCharCode = _startCharCode
                        endCharCode = _endCharCode
                    }
                    
                    if startCharCode <= endCharCode {
                        result.formUnion(CharacterSet(charactersIn: startCharCode...endCharCode))
                    }
                }
            }
            
            return result
        }
    }
    
    struct Format13 : SFNTCMAPTableFormat {
        
        var format: Fixed16Number<BEInt32>
        var length: BEUInt32
        var language: BEUInt32
        var nGroups: BEUInt32
        var groups: Data
        
        init(from data: inout Data) throws {
            self.format = try data.decode(Fixed16Number<BEInt32>.self)
            self.length = try data.decode(BEUInt32.self)
            self.language = try data.decode(BEUInt32.self)
            self.nGroups = try data.decode(BEUInt32.self)
            guard data.count >= Int(nGroups) * MemoryLayout<Group>.stride else { throw DataDecodeError.endOfData }
            self.groups = data.popFirst(Int(nGroups))
        }
        
        func search(_ code: UInt32, _ groups: UnsafePointer<Group>, _ range: CountableRange<Int>) -> Int {
            
            guard range.count != 0 else { return 0 }
            
            if range.count == 1 {
                
                let startCharCode = UInt32(groups[range.startIndex].startCharCode)
                let endCharCode = UInt32(groups[range.startIndex].endCharCode)
                return startCharCode <= endCharCode && startCharCode...endCharCode ~= code ? Int(groups[range.startIndex].startGlyphCode) : 0
                
            } else {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                
                let startCharCode = UInt32(groups[range.startIndex + mid].startCharCode)
                let endCharCode = UInt32(groups[range.startIndex + mid].endCharCode)
                if startCharCode <= endCharCode && startCharCode...endCharCode ~= code {
                    return Int(groups[range.startIndex].startGlyphCode)
                }
                return code < startCharCode ? search(code, groups, range.prefix(upTo: mid)) : search(code, groups, range.suffix(from: mid).dropFirst())
            }
        }
        
        subscript(code: UInt32) -> Int {
            return groups.withUnsafeBytes { search(code, $0, 0..<Int(self.nGroups)) }
        }
        
        var coveredCharacterSet: CharacterSet {
            
            var result = CharacterSet()
            
            groups.withUnsafeBytes { (groups: UnsafePointer<Group>) in
                
                for group in UnsafeBufferPointer(start: groups, count: Int(self.nGroups)) {
                    
                    guard group.startGlyphCode != 0 else { continue }
                    guard let startCharCode = UnicodeScalar(UInt32(group.startCharCode)) else { continue }
                    guard let endCharCode = UnicodeScalar(UInt32(group.endCharCode)) else { continue }
                    
                    if startCharCode <= endCharCode {
                        result.formUnion(CharacterSet(charactersIn: startCharCode...endCharCode))
                    }
                }
            }
            
            return result
        }
    }
    
    struct Group {
        
        var startCharCode: BEUInt32
        var endCharCode: BEUInt32
        var startGlyphCode: BEUInt32
    }
}
