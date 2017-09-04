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
        var idRangeOffset: Data
        
        init(from data: inout Data) throws {
            
            let record = data.count
            
            self.format = try data.decode(BEUInt16.self)
            self.length = try data.decode(BEUInt16.self)
            self.language = try data.decode(BEUInt16.self)
            self.segCountX2 = try data.decode(BEUInt16.self)
            self.searchRange = try data.decode(BEUInt16.self)
            self.entrySelector = try data.decode(BEUInt16.self)
            self.rangeShift = try data.decode(BEUInt16.self)
            
            let segCount = Int(segCountX2) >> 1
            
            self.endCode = try (0..<segCount).map { _ in try data.decode(BEUInt16.self) }
            
            guard self.endCode.last == 0xFFFF else { throw FontCollection.Error.InvalidFormat("Invalid cmap format.") }
            
            self.reservedPad = try data.decode(BEUInt16.self)
            
            self.startCode = try (0..<segCount).map { _ in try data.decode(BEUInt16.self) }
            self.idDelta = try (0..<segCount).map { _ in try data.decode(BEInt16.self) }
            
            let ramainSize = Int(self.length) - (record - data.count)
            guard ramainSize > 0 else { throw FontCollection.Error.InvalidFormat("Invalid cmap format.") }
            guard data.count >= ramainSize else { throw DataDecodeError.endOfData }
            
            self.idRangeOffset = data.popFirst(ramainSize)
        }
        
        func search(_ code: UInt32, _ startCode: UnsafePointer<BEUInt16>, _ endCode: UnsafePointer<BEUInt16>, _ range: CountableRange<Int>) -> Int? {
            
            var range = range
            
            while range.count != 0 {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                let startCharCode = UInt32(startCode[mid])
                let endCharCode = UInt32(endCode[mid])
                if startCharCode <= endCharCode && startCharCode...endCharCode ~= code {
                    return mid
                }
                range = code < startCharCode ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
            }
            
            return nil
        }
        
        subscript(code: UInt32) -> Int {
            
            if let i = search(code, startCode, endCode, 0..<startCode.count) {
                
                let glyphIndex: Int
                
                let _idRangeOffset: BEUInt16 = self.idRangeOffset.withUnsafeBytes { $0[i] }
                
                if _idRangeOffset == 0 {
                    glyphIndex = Int(code)
                } else {
                    let offset = i + (Int(_idRangeOffset) >> 1) + (Int(code) - Int(startCode[i]))
                    guard offset < idRangeOffset.count >> 1 else { return 0 }
                    glyphIndex = Int(self.idRangeOffset.withUnsafeBytes { $0[offset] as BEUInt16 })
                }
                
                return glyphIndex == 0 ? 0 : (Int(idDelta[i]) + glyphIndex) % 0xFFFF
            }
            
            return 0
        }
        
        var coveredCharacterSet: CharacterSet {
            
            var result = CharacterSet()
            
            for (startCode, endCode) in zip(startCode, endCode) {
                
                guard let startCharCode = UnicodeScalar(startCode == 0 ? UInt32(startCode) + 1 : UInt32(startCode)) else { continue }
                guard let endCharCode = UnicodeScalar(endCode == 0xFFFF ? UInt32(endCode) - 1 : UInt32(endCode)) else { continue }
                
                if startCharCode <= endCharCode {
                    result.formUnion(CharacterSet(charactersIn: startCharCode...endCharCode))
                }
            }
            
            return result
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
            
            var range = range
            
            while range.count != 0 {
                
                let mid = (range.lowerBound + range.upperBound) >> 1
                let startCharCode = UInt32(groups[mid].startCharCode)
                let endCharCode = UInt32(groups[mid].endCharCode)
                if startCharCode <= endCharCode && startCharCode...endCharCode ~= code {
                    return Int(code - startCharCode) + Int(groups[mid].startGlyphCode)
                }
                range = code < startCharCode ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
            }
            
            return 0
        }
        
        subscript(code: UInt32) -> Int {
            return groups.withUnsafeBytes { search(code, $0, 0..<Int(self.nGroups)) }
        }
        
        var coveredCharacterSet: CharacterSet {
            
            var result = CharacterSet()
            
            groups.withUnsafeBytes { (groups: UnsafePointer<Group>) in
                
                for group in UnsafeBufferPointer(start: groups, count: Int(self.nGroups)) {
                    
                    guard let startCharCode = UnicodeScalar(group.startGlyphCode == 0 ? UInt32(group.startCharCode) + 1 : UInt32(group.startCharCode)) else { continue }
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
