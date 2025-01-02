//
//  SFNTMORX.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

struct SFNTMORX {
    
    var version: BEUInt16
    var unused: BEUInt16
    var nChains: BEUInt32
    
    var data: Data
    
    init(_ data: Data) throws {
        
        var data = data
        
        self.version = try data.decode(BEUInt16.self)
        self.unused = try data.decode(BEUInt16.self)
        self.nChains = try data.decode(BEUInt32.self)
        self.data = data
    }
}

extension SFNTMORX {
    
    func chains(_ body: (Chain) throws -> Void) throws {
        
        var data = self.data
        
        for _ in 0..<Int(nChains) {
            
            guard let defaultFlags = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            guard let chainLength = try? data.decode(BEUInt32.self), chainLength >= 16 else { throw ByteDecodeError.endOfData }
            guard let nFeatureEntries = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            guard let nSubtables = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            
            let _data = data.popFirst(Int(chainLength) - 16)
            guard _data.count + 16 == chainLength else { throw ByteDecodeError.endOfData }
            
            let chain = Chain(defaultFlags: defaultFlags, chainLength: chainLength, nFeatureEntries: nFeatureEntries, nSubtables: nSubtables, data: _data)
            try body(chain)
        }
    }
    
    struct FeatureSetting: Hashable {
        
        var type: UInt16
        var setting: UInt16
    }
    
    func substitution(glyphs: [Int], numberOfGlyphs: Int, layout: Font.LayoutSetting, features: Set<FeatureSetting>) -> [Int] {
        
        do {
            
            var glyphs = glyphs
            
            try self.chains { chain in
                
                var flags = UInt32(chain.defaultFlags)
                
                try chain.features { feature in
                    
                    let type = UInt16(feature.featureType)
                    let setting = UInt16(feature.featureSetting)
                    
                    if features.contains(SFNTMORX.FeatureSetting(type: type, setting: setting)) {
                        flags &= UInt32(feature.disableFlags)
                        flags |= UInt32(feature.enableFlags)
                    }
                }
                
                try chain.subtables { glyphs = try $0.substitution(glyphs: glyphs, layout: layout, flags: flags).map { 0..<numberOfGlyphs ~= $0 ? $0 : 0 } }
            }
            
            return glyphs
            
        } catch {
            return glyphs
        }
    }
}

extension SFNTMORX {
    
    struct Chain {
        
        var defaultFlags: BEUInt32
        var chainLength: BEUInt32
        var nFeatureEntries: BEUInt32
        var nSubtables: BEUInt32
        
        var data: Data
    }
    
    struct Feature {
        
        var featureType: BEUInt16
        var featureSetting: BEUInt16
        var enableFlags: BEUInt32
        var disableFlags: BEUInt32
    }
    
    struct Subtable {
        
        var length: BEUInt32
        var coverage: BEUInt32
        var subFeatureFlags: BEUInt32
        
        var data: Data
    }
}

extension SFNTMORX.Chain {
    
    func features(_ body: (SFNTMORX.Feature) throws -> Void) throws {
        
        var data = self.data
        
        for _ in 0..<Int(nFeatureEntries) {
            
            guard let featureType = try? data.decode(BEUInt16.self) else { throw ByteDecodeError.endOfData }
            guard let featureSetting = try? data.decode(BEUInt16.self) else { throw ByteDecodeError.endOfData }
            guard let enableFlags = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            guard let disableFlags = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            
            let feature = SFNTMORX.Feature(featureType: featureType, featureSetting: featureSetting, enableFlags: enableFlags, disableFlags: disableFlags)
            try body(feature)
        }
    }
    
    func subtables(_ body: (SFNTMORX.Subtable) throws -> Void) throws {
        
        var data = self.data.dropFirst(12 * Int(nFeatureEntries))
        
        for _ in 0..<Int(nSubtables) {
            
            guard let length = try? data.decode(BEUInt32.self), length >= 12 else { throw ByteDecodeError.endOfData }
            guard let coverage = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            guard let subFeatureFlags = try? data.decode(BEUInt32.self) else { throw ByteDecodeError.endOfData }
            
            let _data = data.popFirst(Int(length) - 12)
            guard _data.count + 12 == length else { throw ByteDecodeError.endOfData }
            
            let subtable = SFNTMORX.Subtable(length: length, coverage: coverage, subFeatureFlags: subFeatureFlags, data: _data)
            try body(subtable)
        }
    }
}

extension SFNTMORX.Subtable {
    
    func substitution(glyphs: [Int], layout: Font.LayoutSetting, flags: UInt32) throws -> [Int] {
        
        var glyphs = glyphs
        
        guard flags & UInt32(subFeatureFlags) != 0 else { return glyphs }
        guard UInt32(coverage) & 0x20000000 != 0 || (layout.isVertical == (UInt32(coverage) & 0x80000000 != 0)) else { return glyphs }
        
        let backwards = UInt32(coverage) & 0x40000000 != 0
        let logical = UInt32(coverage) & 0x10000000 != 0
        let type = UInt32(coverage) & 0x000000FF
        
        let reverse = logical ? backwards : backwards == (layout.direction == .leftToRight)
        
        if reverse {
            glyphs.reverse()
        }
        
        switch type {
        case 0:    //Rearrangement
            
            guard let subtable = try? SFNTMORX.RearrangementSubtable(data) else { return glyphs }
            glyphs = subtable.perform(glyphs: glyphs)
            
        case 1:    //Contextual
            
            guard let subtable = try? SFNTMORX.ContextualSubtable(data) else { return glyphs }
            glyphs = subtable.perform(glyphs: glyphs)
            
        case 2:    //Ligature
            
            guard let subtable = try? SFNTMORX.LigatureSubtable(data) else { return glyphs }
            glyphs = subtable.perform(glyphs: glyphs)
            
        case 4:    //Noncontextual
            
            guard let subtable = try? SFNTMORX.NoncontextualSubtable(data) else { return glyphs }
            glyphs = subtable.perform(glyphs: glyphs)
            
        case 5:    //Insertion
            
            guard let subtable = try? SFNTMORX.InsertionSubtable(data) else { return glyphs }
            glyphs = subtable.perform(glyphs: glyphs)
            
        default: break
        }
        
        if reverse {
            glyphs.reverse()
        }
        
        return glyphs
    }
}

extension SFNTMORX {
    
    struct RearrangementSubtable: AATStateMachine {
        
        struct EntryData: AATStateMachineEntryData {
            
            static var size: Int {
                return 0
            }
            
            init(from data: inout Data) throws {
            }
        }
        
        struct Context: AATStateMachineContext {
            
            var start: Int?
            var end: Int?
            
            init(_ machine: RearrangementSubtable) throws {
                
            }
            
            mutating func transform(_ index: Int, _ entry: Entry, _ buffer: inout [Int]) -> Bool {
                
                let flags = UInt16(entry.flags)
                
                if flags & 0x8000 != 0 {
                    start = index
                }
                if flags & 0x2000 != 0 {
                    end = min(index + 1, buffer.endIndex)
                }
                if flags & 0x000F != 0, let start = start, let end = end, start < end && buffer.indices ~= start {
                    
                    let m: (Int, Int)
                    
                    switch flags & 0x000F {
                    case 1: m = (1, 0)
                    case 2: m = (0, 1)
                    case 3: m = (1, 1)
                    case 4: m = (2, 0)
                    case 5: m = (3, 0)
                    case 6: m = (0, 2)
                    case 7: m = (0, 3)
                    case 8: m = (1, 2)
                    case 9: m = (1, 3)
                    case 10: m = (2, 1)
                    case 11: m = (3, 1)
                    case 12: m = (2, 2)
                    case 13: m = (3, 2)
                    case 14: m = (2, 3)
                    case 15: m = (3, 3)
                    default: return false
                    }
                    
                    let l = min(2, m.0)
                    let r = min(2, m.1)
                    
                    guard end - start >= l + r else { return true }
                    
                    let _l: (Int, Int)
                    let _r: (Int, Int)
                    
                    switch m.0 {
                    case 1: _l = (buffer[start], 0)
                    case 2: _l = (buffer[start], buffer[start + 1])
                    case 3: _l = (buffer[start + 1], buffer[start])
                    default: return false
                    }
                    switch m.1 {
                    case 1: _r = (buffer[end - 1], 0)
                    case 2: _r = (buffer[end - 2], buffer[end - 1])
                    case 3: _r = (buffer[end - 1], buffer[end - 2])
                    default: return false
                    }
                    
                    if l != r {
                        let count = (end - start - l - r) * MemoryLayout<Int>.stride
                        buffer.withUnsafeMutableBytes { _ = memmove($0.baseAddress! + start + r, $0.baseAddress! + start + l, count) }
                    }
                    
                    switch m.1 {
                    case 1:
                        buffer[start] = _r.0
                    case 2, 3:
                        buffer[start] = _r.0
                        buffer[start + 1] = _r.1
                    default: return false
                    }
                    switch m.0 {
                    case 1:
                        buffer[end - 1] = _l.0
                    case 2, 3:
                        buffer[end - 2] = _l.0
                        buffer[end - 1] = _l.1
                    default: return false
                    }
                }
                
                return true
            }
        }
        
        var stateHeader: AATStateTable<EntryData>
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.data = data
        }
    }
    
    struct ContextualSubtable: AATStateMachine {
        
        struct EntryData: AATStateMachineEntryData {
            
            static var size: Int {
                return 4
            }
            
            var markIndex: BEUInt16
            var currentIndex: BEUInt16
            
            init(from data: inout Data) throws {
                self.markIndex = try data.decode(BEUInt16.self)
                self.currentIndex = try data.decode(BEUInt16.self)
            }
        }
        
        struct Context: AATStateMachineContext {
            
            var mark: Int?
            
            var data: Data
            
            init(_ machine: ContextualSubtable) throws {
                self.data = machine.data
            }
            
            mutating func transform(_ index: Int, _ entry: Entry, _ buffer: inout [Int]) -> Bool {
                
                let flags = UInt16(entry.flags)
                
                guard index != buffer.endIndex else { return true }
                
                if entry.data.markIndex != 0xFFFF, let mark = mark {
                    
                    var _offset = self.data.dropFirst(Int(entry.data.markIndex) << 2)
                    guard let offset = try? Int(_offset.decode(BEUInt32.self)) else { return false }
                    guard let lookup = try? AATLookupTable(self.data.dropFirst(offset)) else { return false }
                    
                    if let glyph = UInt16(exactly: buffer[mark]), let replace = lookup.search(glyph: glyph) {
                        buffer[mark] = Int(replace)
                    }
                }
                
                if entry.data.currentIndex != 0xFFFF {
                    
                    var _offset = self.data.dropFirst(Int(entry.data.currentIndex) << 2)
                    guard let offset = try? Int(_offset.decode(BEUInt32.self)) else { return false }
                    guard let lookup = try? AATLookupTable(self.data.dropFirst(offset)) else { return false }
                    
                    if let glyph = UInt16(exactly: buffer[index]), let replace = lookup.search(glyph: glyph) {
                        buffer[index] = Int(replace)
                    }
                }
                
                if flags & 0x8000 != 0 {
                    mark = index
                }
                
                return true
            }
        }
        
        var stateHeader: AATStateTable<EntryData>
        var substitutionTable: BEUInt32
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.substitutionTable = try data.decode(BEUInt32.self)
            guard self.substitutionTable >= 20 else { throw ByteDecodeError.endOfData }
            self.data = data.dropFirst(Int(self.substitutionTable) - 20)
        }
    }
    
    struct LigatureSubtable: AATStateMachine {
        
        struct EntryData: AATStateMachineEntryData {
            
            static var size: Int {
                return 2
            }
            
            var ligActionIndex: BEUInt16
            
            init(from data: inout Data) throws {
                self.ligActionIndex = try data.decode(BEUInt16.self)
            }
        }
        
        struct Context: AATStateMachineContext {
            
            var ligActionTable: Data
            var componentTable: Data
            var ligatureTable: Data
            
            var stack: [Int] = []
            
            init(_ machine: LigatureSubtable) throws {
                guard machine.ligActionOffset >= 28 else { throw ByteDecodeError.endOfData }
                guard machine.componentOffset >= 28 else { throw ByteDecodeError.endOfData }
                guard machine.ligatureOffset >= 28 else { throw ByteDecodeError.endOfData }
                self.ligActionTable = machine.data.dropFirst(Int(machine.ligActionOffset) - 28)
                self.componentTable = machine.data.dropFirst(Int(machine.componentOffset) - 28)
                self.ligatureTable = machine.data.dropFirst(Int(machine.ligatureOffset) - 28)
            }
            
            mutating func transform(_ index: Int, _ entry: Entry, _ buffer: inout [Int]) -> Bool {
                
                let flags = UInt16(entry.flags)
                
                guard index != buffer.endIndex else { return true }
                
                if flags & 0x8000 != 0 && stack.last != index {
                    stack.append(index)
                }
                
                if flags & 0x2000 != 0 && !stack.isEmpty {
                    
                    var _action = ligActionTable.dropFirst(Int(entry.data.ligActionIndex) << 2)
                    var ligature_idx = 0
                    
                    var _stack: [Int] = []
                    
                    while let cursor = stack.popLast() {
                        
                        guard let action = try? UInt32(_action.decode(BEUInt32.self)) else { return false }
                        
                        let _offset = Int32(bitPattern: action & 0x20000000 == 0 ? action & 0x3FFFFFFF : action | 0xC0000000)
                        let _component_idx = buffer[cursor] + Int(_offset)
                        guard _component_idx > 0 else { return false }
                        
                        var _component = componentTable.dropFirst(_component_idx << 1)
                        guard let component = try? Int(_component.decode(BEUInt16.self)) else { return false }
                        
                        ligature_idx += component
                        _stack.append(cursor)
                        
                        if action & 0xC0000000 != 0 {
                            
                            var _ligature = ligatureTable.dropFirst(ligature_idx << 1)
                            guard let ligature = try? Int(_ligature.decode(BEUInt16.self)) else { return false }
                            
                            buffer[_stack.last!] = ligature
                            for idx in _stack.dropLast() {
                                buffer.remove(at: idx)
                            }
                            
                            if action & 0x80000000 != 0 {
                                stack.removeAll(keepingCapacity: true)
                                break
                            }
                            
                            _stack.removeAll(keepingCapacity: true)
                        }
                    }
                }
                
                return true
            }
        }
        
        var stateHeader: AATStateTable<EntryData>
        var ligActionOffset: BEUInt32
        var componentOffset: BEUInt32
        var ligatureOffset: BEUInt32
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.ligActionOffset = try data.decode(BEUInt32.self)
            self.componentOffset = try data.decode(BEUInt32.self)
            self.ligatureOffset = try data.decode(BEUInt32.self)
            self.data = data
        }
    }
    
    struct NoncontextualSubtable {
        
        var table: AATLookupTable
        
        init(_ data: Data) throws {
            self.table = try AATLookupTable(data)
        }
        
        func perform(glyphs: [Int]) -> [Int] {
            return glyphs.map { UInt16(exactly: $0).flatMap { table.search(glyph: $0).map(Int.init) } ?? $0 }
        }
    }
    
    struct InsertionSubtable: AATStateMachine {
        
        struct EntryData: AATStateMachineEntryData {
            
            static var size: Int {
                return 4
            }
            
            var currentInsertIndex: BEUInt16
            var markedInsertIndex: BEUInt16
            
            init(from data: inout Data) throws {
                self.currentInsertIndex = try data.decode(BEUInt16.self)
                self.markedInsertIndex = try data.decode(BEUInt16.self)
            }
        }
        
        struct Context: AATStateMachineContext {
            
            init(_ machine: InsertionSubtable) throws {
                
            }
            
            mutating func transform(_ index: Int, _ entry: Entry, _ buffer: inout [Int]) -> Bool {
                
                return true
            }
        }
        
        var stateHeader: AATStateTable<EntryData>
        var insertionActionOffset: BEUInt32
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.insertionActionOffset = try data.decode(BEUInt32.self)
            self.data = data
        }
    }
}
