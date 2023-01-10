//
//  SFNTFEAT.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

struct SFNTFEAT: RandomAccessCollection {
    
    var version: BEUInt32
    var featureNameCount: BEUInt16
    var reserved1: BEUInt16
    var reserved2: BEUInt32
    
    var data: Data
    
    init(_ data: Data) throws {
        
        var data = data
        
        self.version = try data.decode(BEUInt32.self)
        self.featureNameCount = try data.decode(BEUInt16.self)
        self.reserved1 = try data.decode(BEUInt16.self)
        self.reserved2 = try data.decode(BEUInt32.self)
        self.data = data
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return Int(featureNameCount)
    }
    
    subscript(position: Int) -> Name? {
        
        assert(0..<count ~= position, "Index out of range.")
        
        var data = self.data.dropFirst(12 * position)
        
        guard let feature = try? data.decode(BEUInt16.self) else { return nil }
        guard let nSettings = try? data.decode(BEUInt16.self) else { return nil }
        guard let settingTable = try? data.decode(BEUInt32.self), settingTable >= 12 else { return nil }
        guard let featureFlags = try? data.decode(BEUInt16.self) else { return nil }
        guard let nameIndex = try? data.decode(BEInt16.self) else { return nil }
        
        return Name(feature: feature, nSettings: nSettings, settingTable: settingTable, featureFlags: featureFlags, nameIndex: nameIndex, data: self.data.dropFirst(Int(settingTable) - 12))
    }
}

extension SFNTFEAT {
    
    struct Name {
        
        var feature: BEUInt16
        var nSettings: BEUInt16
        var settingTable: BEUInt32
        var featureFlags: BEUInt16
        var nameIndex: BEInt16
        
        var data: Data
    }
}

extension SFNTFEAT.Name {
    
    var isExclusive: Bool {
        return featureFlags & 0x8000 != 0
    }
    
    var defaultSetting: Int {
        let index = featureFlags & 0x4000 == 0 ? 0 : Int(featureFlags & 0xff)
        return index < nSettings ? index : 0
    }
}

extension SFNTFEAT.Name: RandomAccessCollection {
    
    struct Setting {
        
        var setting: BEUInt16
        var nameIndex: BEInt16
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return Int(nSettings)
    }
    
    subscript(position: Int) -> Setting? {
        
        assert(0..<count ~= position, "Index out of range.")
        
        var data = self.data.dropFirst(4 * position)
        
        guard let setting = try? data.decode(BEUInt16.self) else { return nil }
        guard let nameIndex = try? data.decode(BEInt16.self) else { return nil }
        
        return Setting(setting: setting, nameIndex: nameIndex)
    }
}
