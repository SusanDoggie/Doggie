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
    
    func substitution(glyphs: [Int], layout: Font.LayoutSetting, features: Set<FeatureSetting>) -> [Int] {
        
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
                
                try chain.subtables { glyphs = try $0.substitution(glyphs: glyphs, layout: layout, flags: flags) }
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
        
        let reverse = logical ? backwards : backwards == layout.isLogicalDirection
        
        if reverse {
            glyphs = glyphs.reversed()
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
            glyphs = glyphs.reversed()
        }
        
        return glyphs
    }
}

extension SFNTMORX {
    
    struct RearrangementSubtable : AATStateMachine {
        
        var stateHeader: AATStateTable
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.data = data
        }
        
        func perform(glyphs: [Int]) -> [Int] {
            
            
            return glyphs
        }
    }
    
    struct ContextualSubtable : AATStateMachine {
        
        var stateHeader: AATStateTable
        var substitutionTable: BEUInt32
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.substitutionTable = try data.decode(BEUInt32.self)
            self.data = data
        }
        
        func perform(glyphs: [Int]) -> [Int] {
            
            
            return glyphs
        }
    }
    
    struct LigatureSubtable : AATStateMachine {
        
        var stateHeader: AATStateTable
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
        
        func perform(glyphs: [Int]) -> [Int] {
            
            
            return glyphs
        }
    }
    
    struct NoncontextualSubtable {
        
        var data: Data
        
        init(_ data: Data) throws {
            self.data = data
        }
        
        func perform(glyphs: [Int]) -> [Int] {
            
            
            return glyphs
        }
    }
    
    struct InsertionSubtable : AATStateMachine {
        
        var stateHeader: AATStateTable
        var insertionActionOffset: BEUInt32
        
        var data: Data
        
        init(_ data: Data) throws {
            var data = data
            self.stateHeader = try data.decode(AATStateTable.self)
            self.insertionActionOffset = try data.decode(BEUInt32.self)
            self.data = data
        }
        
        func perform(glyphs: [Int]) -> [Int] {
            
            
            return glyphs
        }
    }
}
