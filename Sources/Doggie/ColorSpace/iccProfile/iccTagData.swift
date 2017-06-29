//
//  iccTagData.swift
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

extension iccProfile {
    
    @_versioned
    struct TagData {
        
        @_versioned
        let rawData: Data
        
        @_versioned
        init(rawData: Data) {
            self.rawData = rawData
        }
        
        @_versioned
        var type: Type {
            return rawData.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var data: Data {
            return rawData.advanced(by: 8)
        }
    }
}

extension iccProfile.TagData {
    
    private var _obj: Any? {
        
        switch type {
        case .UInt16Array: return uInt16Array
        case .UInt32Array: return uInt32Array
        case .UInt64Array: return uInt64Array
        case .UInt8Array: return uInt8Array
        case .S15Fixed16Array: return s15Fixed16Array
        case .U16Fixed16Array: return u16Fixed16Array
        case .XYZArray: return XYZArray
        case .Curve: return curve
        case .ParametricCurve: return parametricCurve
        case .Text: return text
        case .MultiLocalizedUnicode: return multiLocalizedUnicode
        case .Lut16: return lut16
        case .Lut8: return lut8
        case .LutAtoB: return lutAtoB
        case .LutBtoA: return lutBtoA
        default: return nil
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var uInt16Array: [BEUInt16]? {
        
        return type == .UInt16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt16>.stride)) } : nil
    }
    
    @_versioned
    var uInt32Array: [BEUInt32]? {
        
        return type == .UInt32Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt32>.stride)) } : nil
    }
    
    @_versioned
    var uInt64Array: [BEUInt64]? {
        
        return type == .UInt64Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt64>.stride)) } : nil
    }
    
    @_versioned
    var uInt8Array: [UInt8]? {
        
        return type == .UInt8Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<UInt8>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var s15Fixed16Array: [iccProfile.S15Fixed16Number]? {
        
        return type == .S15Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.S15Fixed16Number>.stride)) } : nil
    }
    
    @_versioned
    var u16Fixed16Array: [iccProfile.U16Fixed16Number]? {
        
        return type == .U16Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.U16Fixed16Number>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var XYZArray: [iccProfile.XYZNumber]? {
        
        return type == .XYZArray ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.XYZNumber>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var multiLocalizedUnicode: MultiLocalizedUnicodeView? {
        
        return type == .MultiLocalizedUnicode ? MultiLocalizedUnicodeView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var curve: CurveView? {
        
        return type == .Curve ? CurveView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct CurveView : RandomAccessCollection {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var startIndex: Int {
            return 0
        }
        
        @_versioned
        var endIndex: Int {
            return Int(data.withUnsafeBytes { $0.pointee as BEUInt32 })
        }
        
        @_versioned
        func point(position: Int) -> BEUInt16 {
            let offset = 4 + 2 * position
            return data[offset..<offset + 2].withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        subscript(position: Int) -> Double {
            return Double(point(position: position).representingValue) / 65535
        }
        
        @_versioned
        var isGamma: Bool {
            return self.count == 1
        }
        
        @_versioned
        var gamma: iccProfile.U8Fixed8Number? {
            
            return isGamma ? iccProfile.U8Fixed8Number(rawValue: point(position: 0)) : nil
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var parametricCurve: iccProfile.ParametricCurve? {
        
        if type == .ParametricCurve {
            var data = self.data
            data.count = MemoryLayout<iccProfile.ParametricCurve>.stride
            return data.withUnsafeBytes { $0.pointee }
        }
        return nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var text: String? {
        
        return type == .Text ? String(bytes: data, encoding: .ascii) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct MultiLocalizedUnicodeView : RandomAccessCollection {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.MultiLocalizedUnicode {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var startIndex: Int {
            return 0
        }
        
        @_versioned
        var endIndex: Int {
            return Int(header.count)
        }
        
        @_versioned
        subscript(position: Int) -> (language: iccProfile.LanguageCode, country: iccProfile.CountryCode, String) {
            
            let entry = self.entry(position: position)
            
            let offset = Int(entry.offset) - 8
            let strData = data[offset..<offset + Int(entry.length)]
            
            return (entry.language, entry.country, String(bytes: strData, encoding: .utf16BigEndian) ?? "")
        }
        
        @_versioned
        func entry(position: Int) -> iccProfile.MultiLocalizedUnicodeEntry {
            
            let size = Int(header.size)
            let offset = 8 + size * position
            
            return data[offset..<offset + size].withUnsafeBytes { $0.pointee }
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var lut16: Lut16View? {
        
        return type == .Lut16 ? Lut16View(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct Lut16View {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.Lut16 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var inputChannels: Int {
            return Int(header.inputChannels)
        }
        @_versioned
        var outputChannels: Int {
            return Int(header.outputChannels)
        }
        @_versioned
        var inputEntries: Int {
            return Int(header.inputEntries)
        }
        @_versioned
        var outputEntries: Int {
            return Int(header.outputEntries)
        }
        @_versioned
        var grids: Int {
            return Int(header.grids)
        }
        
        @_versioned
        var inputTableSize: Int {
            return 2 * inputEntries * inputChannels
        }
        @_versioned
        var outputTableSize: Int {
            return 2 * outputEntries * outputChannels
        }
        @_versioned
        var clutTableSize: Int {
            return 2 * Int(pow(UInt(grids), UInt(inputChannels))) * outputChannels
        }
        
        @_versioned
        var inputTable: [Double] {
            let start = 44
            let end = start + inputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: inputTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
        
        @_versioned
        var clutTable: [Double] {
            let start = 44 + inputTableSize
            let end = start + clutTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: clutTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
        
        @_versioned
        var outputTable: [Double] {
            let start = 44 + inputTableSize + clutTableSize
            let end = start + outputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: outputTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var lut8: Lut8View? {
        
        return type == .Lut8 ? Lut8View(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct Lut8View {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.Lut8 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var inputChannels: Int {
            return Int(header.inputChannels)
        }
        @_versioned
        var outputChannels: Int {
            return Int(header.outputChannels)
        }
        @_versioned
        var grids: Int {
            return Int(header.grids)
        }
        
        @_versioned
        var inputTableSize: Int {
            return 256 * inputChannels
        }
        @_versioned
        var outputTableSize: Int {
            return 256 * outputChannels
        }
        @_versioned
        var clutTableSize: Int {
            return Int(pow(UInt(grids), UInt(inputChannels))) * outputChannels
        }
        
        @_versioned
        var inputTable: [Double] {
            let start = 40
            let end = start + inputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: inputTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
        
        @_versioned
        var clutTable: [Double] {
            let start = 40 + inputTableSize
            let end = start + clutTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: clutTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
        
        @_versioned
        var outputTable: [Double] {
            let start = 40 + inputTableSize + clutTableSize
            let end = start + outputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: outputTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct CLUTTableView {
        
        @_versioned
        let inputChannels: Int
        
        @_versioned
        let outputChannels: Int
        
        fileprivate let data: Data
        
        fileprivate init(inputChannels: Int, outputChannels: Int, data: Data) {
            self.inputChannels = inputChannels
            self.outputChannels = outputChannels
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.CLUTStruct {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var grids: [Int] {
            var grids = header.grids
            return withUnsafeBytes(of: &grids) { UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: UInt8.self), count: 16).prefix(inputChannels).map(Int.init) }
        }
        
        @_versioned
        var table: [Double] {
            
            let count = grids.reduce(outputChannels, *)
            
            let table = data[20..<20 + count * Int(header.precision)]
            
            switch header.precision {
            case 1: return table.withUnsafeBytes { UnsafeBufferPointer(start: $0, count: count).map { (v: UInt8) in Double(v) / 255 } }
            case 2: return table.withUnsafeBytes { UnsafeBufferPointer(start: $0, count: count).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
            default: return []
            }
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var lutAtoB: LutAtoBView? {
        
        return type == .LutAtoB ? LutAtoBView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct LutAtoBView {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.LutAtoB {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var inputChannels: Int {
            return Int(header.inputChannels)
        }
        @_versioned
        var outputChannels: Int {
            return Int(header.outputChannels)
        }
        
        @_versioned
        func readCurves(_ data: Data, count: Int) -> [iccProfile.TagData]? {
            
            var result: [iccProfile.TagData] = []
            
            var data = data
            
            for _ in 0..<count {
                
                let tag = iccProfile.TagData(rawData: data)
                
                switch tag.type {
                case .Curve:
                    
                    let count: BEUInt32 = tag.data.withUnsafeBytes { $0.pointee }
                    
                    let size = 2 * Int(count) + 12
                    
                    result.append(iccProfile.TagData(rawData: data.prefix(size)))
                    
                    data = data.dropFirst(size.align(4))
                    
                case .ParametricCurve:
                    
                    let funcType: BEUInt16 = tag.data.withUnsafeBytes { $0.pointee }
                    
                    let size: Int
                    
                    switch funcType {
                    case 0: size = 12 + 4
                    case 1: size = 12 + 12
                    case 2: size = 12 + 16
                    case 3: size = 12 + 20
                    case 4: size = 12 + 28
                    default: return nil
                    }
                    
                    result.append(iccProfile.TagData(rawData: data.prefix(size)))
                    
                    data = data.dropFirst(size.align(4))
                    
                default: return nil
                }
            }
            return result
        }
        
        @_versioned
        var A: [iccProfile.TagData]? {
            if header.offsetA == 0 {
                return nil
            }
            let offset = Int(header.offsetA) - 8
            return readCurves(data[offset...], count: Int(header.inputChannels))
        }
        
        @_versioned
        var B: [iccProfile.TagData]? {
            let offset = Int(header.offsetB) - 8
            return readCurves(data[offset...], count: Int(header.outputChannels))
        }
        
        @_versioned
        var M: [iccProfile.TagData]? {
            if header.offsetM == 0 {
                return nil
            }
            let offset = Int(header.offsetM) - 8
            return readCurves(data[offset...], count: Int(header.outputChannels))
        }
        
        @_versioned
        var matrix: iccProfile.Matrix3x4? {
            if header.offsetMatrix == 0 {
                return nil
            }
            let offset = Int(header.offsetMatrix) - 8
            return data[offset...].withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var clutTable: iccProfile.TagData.CLUTTableView? {
            if header.offsetCLUT == 0 {
                return nil
            }
            let offset = Int(header.offsetCLUT) - 8
            return iccProfile.TagData.CLUTTableView(inputChannels: inputChannels, outputChannels: outputChannels, data: data.advanced(by: offset))
        }
    }
}

extension iccProfile.TagData {
    
    @_versioned
    var lutBtoA: LutBtoAView? {
        
        return type == .LutBtoA ? LutBtoAView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct LutBtoAView {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        @_versioned
        var header: iccProfile.LutBtoA {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var inputChannels: Int {
            return Int(header.inputChannels)
        }
        @_versioned
        var outputChannels: Int {
            return Int(header.outputChannels)
        }
        
        @_versioned
        func readCurves(_ data: Data, count: Int) -> [iccProfile.TagData]? {
            
            var result: [iccProfile.TagData] = []
            
            var data = data
            
            for _ in 0..<count {
                
                let tag = iccProfile.TagData(rawData: data)
                switch tag.type {
                case .Curve:
                    
                    let count: BEUInt32 = tag.data.withUnsafeBytes { $0.pointee }
                    
                    let size = 2 * Int(count) + 12
                    
                    result.append(iccProfile.TagData(rawData: data.prefix(size)))
                    
                    data = data.dropFirst(size.align(4))
                    
                case .ParametricCurve:
                    
                    let funcType: BEUInt16 = tag.data.withUnsafeBytes { $0.pointee }
                    
                    let size: Int
                    
                    switch funcType {
                    case 0: size = 12 + 4
                    case 1: size = 12 + 12
                    case 2: size = 12 + 16
                    case 3: size = 12 + 20
                    case 4: size = 12 + 28
                    default: return nil
                    }
                    
                    result.append(iccProfile.TagData(rawData: data.prefix(size)))
                    
                    data = data.dropFirst(size.align(4))
                    
                default: return nil
                }
            }
            return result
        }
        
        @_versioned
        var A: [iccProfile.TagData]? {
            if header.offsetA == 0 {
                return nil
            }
            let offset = Int(header.offsetA) - 8
            return readCurves(data[offset...], count: Int(header.outputChannels))
        }
        
        @_versioned
        var B: [iccProfile.TagData]? {
            let offset = Int(header.offsetB) - 8
            return readCurves(data[offset...], count: Int(header.inputChannels))
        }
        
        @_versioned
        var M: [iccProfile.TagData]? {
            if header.offsetM == 0 {
                return nil
            }
            let offset = Int(header.offsetM) - 8
            return readCurves(data[offset...], count: Int(header.inputChannels))
        }
        
        @_versioned
        var matrix: iccProfile.Matrix3x4? {
            if header.offsetMatrix == 0 {
                return nil
            }
            let offset = Int(header.offsetMatrix) - 8
            return data[offset...].withUnsafeBytes { $0.pointee }
        }
        
        @_versioned
        var clutTable: iccProfile.TagData.CLUTTableView? {
            if header.offsetCLUT == 0 {
                return nil
            }
            let offset = Int(header.offsetCLUT) - 8
            return iccProfile.TagData.CLUTTableView(inputChannels: inputChannels, outputChannels: outputChannels, data: data.advanced(by: offset))
        }
    }
}

