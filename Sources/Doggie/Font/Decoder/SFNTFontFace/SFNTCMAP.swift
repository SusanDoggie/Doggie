//
//  SFNTCMAP.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

protocol SFNTCMAPTableFormat : ByteDecodable {
    
    subscript(code: UInt32) -> Int { get }
    
    var coveredCharacterSet: CharacterSet { get }
}

struct SFNTCMAP : ByteDecodable {
    
    var version: BEUInt16
    var numTables: BEUInt16
    var table: Table
    var uvs: Format14?
    
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
            case 14: uvs = try Format14(tableData)
            default: break
            }
        }
        
        tables.sort { ($0._platform_ordering, $0._format_ordering) < ($1._platform_ordering, $1._format_ordering) }
        
        if let table = tables.first(where: { $0._platform_ordering != -1 && $0._format_ordering != -1 }) {
            self.table = table
        } else {
            throw FontCollection.Error.Unsupported("Unsupported cmap format.")
        }
    }
}

extension SFNTCMAP {
    
    struct Table {
        
        var platform: SFNTPlatform
        var format: SFNTCMAPTableFormat
    }
}

extension SFNTCMAP.Table {
    
    fileprivate var _platform_ordering: Int {
        switch (self.platform.platform, self.platform.specific) {
        case (0, 4): return 7
        case (0, 3): return 6
        case (0, 2): return 5
        case (0, 1): return 4
        case (0, 0): return 3
        case (3, 10): return 2
        case (3, 1): return 1
        case (3, 0): return 0
        default: return -1
        }
    }
    
    fileprivate var _format_ordering: Int {
        switch self.format {
        case is SFNTCMAP.Format12: return 2
        case is SFNTCMAP.Format4: return 1
        case is SFNTCMAP.Format0: return 0
        default: return -1
        }
    }
}

extension SFNTCMAP : CustomStringConvertible {
    
    var description: String {
        return "SFNTCMAP(version: \(version), numTables: \(numTables))"
    }
}

extension SFNTCMAP {
    
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
            guard self.data.count == 256 else { throw ByteDecodeError.endOfData }
        }
        
        subscript(code: UInt32) -> Int {
            guard code < 256 else { return 0 }
            return Int(data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in bytes[Int(code)] })
        }
        
        var coveredCharacterSet: CharacterSet {
            return CharacterSet(data.enumerated().compactMap { $1 != 0 ? UnicodeScalar($0) : nil })
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
            guard data.count >= ramainSize else { throw ByteDecodeError.endOfData }
            
            self.idRangeOffset = data.popFirst(ramainSize)
        }
        
        func search(_ code: UInt32, _ startCode: UnsafePointer<BEUInt16>, _ endCode: UnsafePointer<BEUInt16>, _ range: Range<Int>) -> Int? {
            
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
                
                let _idRangeOffset = self.idRangeOffset.withUnsafeBytes { $0.bindMemory(to: BEUInt16.self)[i] }
                
                if _idRangeOffset == 0 {
                    glyphIndex = Int(code)
                } else {
                    let offset = i + (Int(_idRangeOffset) >> 1) + (Int(code) - Int(startCode[i]))
                    guard offset < idRangeOffset.count >> 1 else { return 0 }
                    glyphIndex = Int(self.idRangeOffset.withUnsafeBytes { $0.bindMemory(to: BEUInt16.self)[offset] })
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
            guard data.count >= Int(nGroups) * MemoryLayout<Group>.stride else { throw ByteDecodeError.endOfData }
            self.groups = data.popFirst(Int(nGroups))
        }
        
        func search(_ code: UInt32, _ groups: UnsafePointer<Group>, _ range: Range<Int>) -> Int {
            
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
            return groups.withUnsafeBytes { search(code, $0.bindMemory(to: Group.self).baseAddress!, 0..<Int(self.nGroups)) }
        }
        
        var coveredCharacterSet: CharacterSet {
            
            var result = CharacterSet()
            
            groups.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                
                guard let groups = bytes.bindMemory(to: Group.self).baseAddress else { return }
                
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
        
        struct Group {
            
            var startCharCode: BEUInt32
            var endCharCode: BEUInt32
            var startGlyphCode: BEUInt32
        }
    }
    
    struct Format14 {
        
        var format: BEInt16
        var length: BEUInt32
        var numVarSelectorRecords: BEUInt32
        var varSelectorRecords: Data
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            let copy = data
            self.format = try data.decode(BEInt16.self)
            self.length = try data.decode(BEUInt32.self)
            self.numVarSelectorRecords = try data.decode(BEUInt32.self)
            guard data.count >= Int(numVarSelectorRecords) * MemoryLayout<VariationSelector>.stride else { throw ByteDecodeError.endOfData }
            self.varSelectorRecords = data.popFirst(Int(numVarSelectorRecords) * MemoryLayout<VariationSelector>.stride)
            self.data = copy.prefix(Int(length))
        }
        
        struct VariationSelector {
            
            var _varSelector: (UInt8, UInt8, UInt8)
            var _defaultUVSOffset: (UInt8, UInt8, UInt8, UInt8)
            var _nonDefaultUVSOffset: (UInt8, UInt8, UInt8, UInt8)
            
            var varSelector: UInt32 {
                return (UInt32(_varSelector.0) << 16) | (UInt32(_varSelector.1) << 8) | UInt32(_varSelector.2)
            }
            
            var defaultUVSOffset: UInt32 {
                return (UInt32(_defaultUVSOffset.0) << 24) | (UInt32(_defaultUVSOffset.1) << 16) | (UInt32(_defaultUVSOffset.2) << 8) | UInt32(_defaultUVSOffset.3)
            }
            var nonDefaultUVSOffset: UInt32 {
                return (UInt32(_nonDefaultUVSOffset.0) << 24) | (UInt32(_nonDefaultUVSOffset.1) << 16) | (UInt32(_nonDefaultUVSOffset.2) << 8) | UInt32(_nonDefaultUVSOffset.3)
            }
        }
        
        func search(_ varSelector: UInt32, _ range: Range<Int>) -> VariationSelector? {
            
            return varSelectorRecords.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> VariationSelector? in
                
                guard let buf = bytes.bindMemory(to: VariationSelector.self).baseAddress else { return nil }
                
                var range = range
                
                while range.count != 0 {
                    
                    let mid = (range.lowerBound + range.upperBound) >> 1
                    let _mid = buf[mid]
                    if varSelector == _mid.varSelector {
                        return _mid
                    }
                    range = varSelector < _mid.varSelector ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
                }
                
                return nil
            }
        }
        
        enum MappedValue {
            
            case none
            case `default`
            case glyph(UInt16)
        }
        
        func mapping(_ code: UInt32, _ varSelector: UInt32) -> MappedValue {
            
            guard let varSelector = self.search(varSelector, 0..<Int(self.numVarSelectorRecords)) else { return .none }
            
            let defaultUVSOffset = Int(varSelector.defaultUVSOffset)
            let nonDefaultUVSOffset = Int(varSelector.nonDefaultUVSOffset)
            
            if defaultUVSOffset != 0 {
                var data = self.data.dropFirst(defaultUVSOffset)
                
                guard let count = try? data.decode(BEInt32.self) else { return .none }
                
                let result = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> UnicodeValueRange? in
                    
                    guard let buf = bytes.bindMemory(to: UnicodeValueRange.self).baseAddress else { return nil }
                    
                    var range = 0..<Int(count)
                    
                    while range.count != 0 {
                        
                        let mid = (range.lowerBound + range.upperBound) >> 1
                        let _mid = buf[mid]
                        let startUnicodeValue = _mid.startUnicodeValue
                        let endUnicodeValue = startUnicodeValue + UInt32(_mid.additionalCount)
                        if startUnicodeValue <= endUnicodeValue && startUnicodeValue...endUnicodeValue ~= code {
                            return _mid
                        }
                        range = code < startUnicodeValue ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
                    }
                    
                    return nil
                }
                
                if result != nil {
                    return .default
                }
            }
            
            if nonDefaultUVSOffset != 0 {
                var data = self.data.dropFirst(nonDefaultUVSOffset)
                
                guard let count = try? data.decode(BEInt32.self) else { return .none }
                
                let result = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> UVSMapping? in
                    
                    guard let buf = bytes.bindMemory(to: UVSMapping.self).baseAddress else { return nil }
                    
                    var range = 0..<Int(count)
                    
                    while range.count != 0 {
                        
                        let mid = (range.lowerBound + range.upperBound) >> 1
                        let _mid = buf[mid]
                        if code == _mid.unicodeValue {
                            return _mid
                        }
                        range = code < _mid.unicodeValue ? range.prefix(upTo: mid) : range.suffix(from: mid).dropFirst()
                    }
                    
                    return nil
                }
                
                if let result = result {
                    return .glyph(result.glyphID)
                }
            }
            
            return .none
        }
        
        struct UnicodeValueRange {
            
            var _startUnicodeValue: (UInt8, UInt8, UInt8)
            var additionalCount: UInt8
            
            var startUnicodeValue: UInt32 {
                return (UInt32(_startUnicodeValue.0) << 16) | (UInt32(_startUnicodeValue.1) << 8) | UInt32(_startUnicodeValue.2)
            }
        }
        
        struct UVSMapping {
            
            var _unicodeValue: (UInt8, UInt8, UInt8)
            var _glyphID: (UInt8, UInt8)
            
            var unicodeValue: UInt32 {
                return (UInt32(_unicodeValue.0) << 16) | (UInt32(_unicodeValue.1) << 8) | UInt32(_unicodeValue.2)
            }
            
            var glyphID: UInt16 {
                return (UInt16(_glyphID.0) << 8) | UInt16(_glyphID.1)
            }
        }
    }
}
