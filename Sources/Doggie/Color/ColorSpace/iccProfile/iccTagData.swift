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
    
    public struct TagData {
        
        let rawData: Data
        
        init(rawData: Data) {
            self.rawData = rawData
        }
        
        public var type: Type {
            return rawData.withUnsafeBytes { $0.pointee }
        }
        
        public var data: Data {
            return rawData.advanced(by: 8)
        }
    }
}

extension iccProfile.TagData : CustomStringConvertible {
    
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
        case .MultiLocalizedUnicode: return multiLocalizedUnicode
        case .Lut16: return lut16
        case .Lut8: return lut8
        case .LutAtoB: return lutAtoB
        case .LutBtoA: return lutBtoA
        default: return nil
        }
    }
    
    public var description: String {
        return _obj.map { "\($0)" } ?? "TagData(type: \(type), data: \(data))"
    }
}

extension iccProfile.TagData {
    
    public var uInt16Array: [BEUInt16]? {
        
        return type == .UInt16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt16>.stride)) } : nil
    }
    
    public var uInt32Array: [BEUInt32]? {
        
        return type == .UInt32Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt32>.stride)) } : nil
    }
    
    public var uInt64Array: [BEUInt64]? {
        
        return type == .UInt64Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<BEUInt64>.stride)) } : nil
    }
    
    public var uInt8Array: [UInt8]? {
        
        return type == .UInt8Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<UInt8>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public var s15Fixed16Array: [iccProfile.S15Fixed16Number]? {
        
        return type == .S15Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.S15Fixed16Number>.stride)) } : nil
    }
    
    public var u16Fixed16Array: [iccProfile.U16Fixed16Number]? {
        
        return type == .U16Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.U16Fixed16Number>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public var XYZArray: [iccProfile.XYZNumber]? {
        
        return type == .XYZArray ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.XYZNumber>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public var multiLocalizedUnicode: MultiLocalizedUnicodeView? {
        
        return type == .MultiLocalizedUnicode ? MultiLocalizedUnicodeView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public var curve: CurveView? {
        
        return type == .Curve ? CurveView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public struct CurveView : RandomAccessCollection, CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var startIndex: Int {
            return 0
        }
        
        public var endIndex: Int {
            return Int(data.withUnsafeBytes { $0.pointee as BEUInt32 })
        }
        
        public func point(position: Int) -> BEUInt16 {
            let offset = 4 + 2 * position
            return data[offset..<offset + 2].withUnsafeBytes { $0.pointee }
        }
        
        public subscript(position: Int) -> Double {
            return Double(point(position: position).representingValue) / 65535
        }
        
        public var isGamma: Bool {
            return self.count == 1
        }
        
        public var gamma: iccProfile.U8Fixed8Number? {
            
            return isGamma ? iccProfile.U8Fixed8Number(rawValue: point(position: 0)) : nil
        }
        
        public var description: String {
            if let gamma = gamma {
                return "CurveView(gamma: \(gamma))"
            }
            return "CurveView(curve: \(Array(self)))"
        }
    }
}

extension iccProfile.TagData {
    
    public var parametricCurve: iccProfile.ParametricCurve? {
        
        if type == .ParametricCurve {
            var data = self.data
            data.count = MemoryLayout<iccProfile.ParametricCurve>.stride
            return data.withUnsafeBytes { $0.pointee }
        }
        return nil
    }
}

extension iccProfile.TagData {
    
    public struct MultiLocalizedUnicodeView : RandomAccessCollection, CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var header: iccProfile.MultiLocalizedUnicode {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var startIndex: Int {
            return 0
        }
        
        public var endIndex: Int {
            return Int(header.count)
        }
        
        public subscript(position: Int) -> (language: iccProfile.LanguageCode, country: iccProfile.CountryCode, String) {
            
            let entry = self.entry(position: position)
            
            let offset = Int(entry.offset) - 8
            let strData = data[offset..<offset + Int(entry.length)]
            
            return (entry.language, entry.country, String(bytes: strData, encoding: .utf16BigEndian) ?? "")
        }
        
        public func entry(position: Int) -> iccProfile.MultiLocalizedUnicodeEntry {
            
            let size = Int(header.size)
            let offset = 8 + size * position
            
            return data[offset..<offset + size].withUnsafeBytes { $0.pointee }
        }
        
        public var description: String {
            return "\(Array(self))"
        }
    }
}

extension iccProfile.TagData {
    
    public var lut16: Lut16View? {
        
        return type == .Lut16 ? Lut16View(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public struct Lut16View : CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var header: iccProfile.Lut16 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var inputChannels: Int {
            return Int(header.inputChannels)
        }
        public var outputChannels: Int {
            return Int(header.outputChannels)
        }
        public var inputEntries: Int {
            return Int(header.inputEntries)
        }
        public var outputEntries: Int {
            return Int(header.outputEntries)
        }
        public var grids: Int {
            return Int(header.grids)
        }
        
        public var inputTableSize: Int {
            return 2 * inputEntries * inputChannels
        }
        public var outputTableSize: Int {
            return 2 * outputEntries * outputChannels
        }
        public var clutTableSize: Int {
            return 2 * Int(pow(UInt(grids), UInt(inputChannels))) * outputChannels
        }
        
        public var inputTable: [Double] {
            let start = 44
            let end = start + inputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: inputTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
        
        public var clutTable: [Double] {
            let start = 44 + inputTableSize
            let end = start + clutTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: clutTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
        
        public var outputTable: [Double] {
            let start = 44 + inputTableSize + clutTableSize
            let end = start + outputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: outputTableSize >> 1).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
        }
        
        public var description: String {
            return "Lut16View(header: \(header), inputTable: \(inputTable), clutTable: \(clutTable), outputTable: \(outputTable))"
        }
    }
}

extension iccProfile.TagData {
    
    public var lut8: Lut8View? {
        
        return type == .Lut8 ? Lut8View(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public struct Lut8View : CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var header: iccProfile.Lut8 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var inputChannels: Int {
            return Int(header.inputChannels)
        }
        public var outputChannels: Int {
            return Int(header.outputChannels)
        }
        public var grids: Int {
            return Int(header.grids)
        }
        
        public var inputTableSize: Int {
            return 256 * inputChannels
        }
        public var outputTableSize: Int {
            return 256 * outputChannels
        }
        public var clutTableSize: Int {
            return Int(pow(UInt(grids), UInt(inputChannels))) * outputChannels
        }
        
        public var inputTable: [Double] {
            let start = 40
            let end = start + inputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: inputTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
        
        public var clutTable: [Double] {
            let start = 40 + inputTableSize
            let end = start + clutTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: clutTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
        
        public var outputTable: [Double] {
            let start = 40 + inputTableSize + clutTableSize
            let end = start + outputTableSize
            return data[start..<end].withUnsafeBytes { UnsafeBufferPointer(start: $0, count: outputTableSize).map { (v: UInt8) in Double(v) / 255 } }
        }
        
        public var description: String {
            return "Lut8View(header: \(header), inputTable: \(inputTable), clutTable: \(clutTable), outputTable: \(outputTable))"
        }
    }
}

extension iccProfile.TagData {
    
    public struct CLUTTableView : CustomStringConvertible {
        
        public let inputChannels: Int
        public let outputChannels: Int
        
        fileprivate let data: Data
        
        fileprivate init(inputChannels: Int, outputChannels: Int, data: Data) {
            self.inputChannels = inputChannels
            self.outputChannels = outputChannels
            self.data = data
        }
        
        public var header: iccProfile.CLUTStruct {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var table: [Double] {
            
            var grids = header.grids
            
            let count: Int = withUnsafeBytes(of: &grids) {
                
                if let ptr = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                    return UnsafeBufferPointer(start: ptr, count: 16).prefix(inputChannels).reduce(outputChannels) { $0 * Int($1) }
                }
                return 0
            }
            
            let table = data[20..<20 + count * Int(header.precision)]
            
            switch header.precision {
            case 1: return table.withUnsafeBytes { UnsafeBufferPointer(start: $0, count: count).map { (v: UInt8) in Double(v) / 255 } }
            case 2: return table.withUnsafeBytes { UnsafeBufferPointer(start: $0, count: count).map { (v: BEUInt16) in Double(v.representingValue) / 65535 } }
            default: return []
            }
        }
        
        public var description: String {
            return "CLUTTableView(\(table.count))"
        }
    }
}

extension iccProfile.TagData {
    
    public var lutAtoB: LutAtoBView? {
        
        return type == .LutAtoB ? LutAtoBView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public struct LutAtoBView : CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var header: iccProfile.LutAtoB {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var inputChannels: Int {
            return Int(header.inputChannels)
        }
        public var outputChannels: Int {
            return Int(header.outputChannels)
        }
        
        public var A: iccProfile.TagData {
            let offset = Int(header.offsetA) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var B: iccProfile.TagData {
            let offset = Int(header.offsetB) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var M: iccProfile.TagData {
            let offset = Int(header.offsetM) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var matrix: iccProfile.Matrix3x4 {
            let offset = Int(header.offsetMatrix) - 8
            return data[offset...].withUnsafeBytes { $0.pointee }
        }
        
        public var clutTable: iccProfile.TagData.CLUTTableView {
            let offset = Int(header.offsetCLUT) - 8
            return iccProfile.TagData.CLUTTableView(inputChannels: inputChannels, outputChannels: outputChannels, data: data.advanced(by: offset))
        }
        
        public var description: String {
            return "LutAtoBView(A: \(A), M: \(M), B: \(B), matrix: \(matrix), clutTable: \(clutTable))"
        }
    }
}

extension iccProfile.TagData {
    
    public var lutBtoA: LutBtoAView? {
        
        return type == .LutBtoA ? LutBtoAView(data: data) : nil
    }
}

extension iccProfile.TagData {
    
    public struct LutBtoAView : CustomStringConvertible {
        
        fileprivate let data: Data
        
        fileprivate init(data: Data) {
            self.data = data
        }
        
        public var header: iccProfile.LutBtoA {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        public var inputChannels: Int {
            return Int(header.inputChannels)
        }
        public var outputChannels: Int {
            return Int(header.outputChannels)
        }
        
        public var A: iccProfile.TagData {
            let offset = Int(header.offsetA) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var B: iccProfile.TagData {
            let offset = Int(header.offsetB) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var M: iccProfile.TagData {
            let offset = Int(header.offsetM) - 8
            return iccProfile.TagData(rawData: data[offset...])
        }
        
        public var matrix: iccProfile.Matrix3x4 {
            let offset = Int(header.offsetMatrix) - 8
            return data[offset...].withUnsafeBytes { $0.pointee }
        }
        
        public var clutTable: iccProfile.TagData.CLUTTableView {
            let offset = Int(header.offsetCLUT) - 8
            return iccProfile.TagData.CLUTTableView(inputChannels: inputChannels, outputChannels: outputChannels, data: data.advanced(by: offset))
        }
        
        public var description: String {
            return "LutBtoAView(A: \(A), M: \(M), B: \(B), matrix: \(matrix), clutTable: \(clutTable))"
        }
    }
}
