//
//  WOFFEncoder.swift
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

struct WOFFEncoder: FontFaceEncoder {
    
    static func encode(table: [Signature<BEUInt32>: Data], properties: [Font.PropertyKey: Any]) -> Data? {
        
        let deflate_level = properties[.deflateLevel] as? Deflate.Level ?? .default
        
        let _table = table.sorted { $0.key.rawValue }
        
        let sfnt_version: Signature<BEUInt32> = table.keys.contains("CFF ") || table.keys.contains("CFF2") ? "OTTO" : 0x00010000
        let sfnt_header = OTFHeader(version: sfnt_version, numTables: table.count)
        
        var sfnt_offset = 12 + 16 * table.count
        var sfnt_buffer = Data(capacity: sfnt_offset)
        sfnt_buffer.encode(sfnt_header)
        
        var sfnt_bodies: [Data] = []
        var sfnt_checkSum: [UInt32] = []
        
        for (tag, var data) in _table {
            
            let length = data.count
            data.count = data.count.align(4)
            
            if tag == "head" {
                guard data.count >= 54 else { return nil }
                data[data.startIndex + 8] = 0
                data[data.startIndex + 9] = 0
                data[data.startIndex + 10] = 0
                data[data.startIndex + 11] = 0
            }
            
            let checkSum = OTFEncoder.CalcTableChecksum(data)
            let record = OTFTableRecord(tag: tag, checkSum: BEUInt32(checkSum), offset: BEUInt32(sfnt_offset), length: BEUInt32(length))
            
            sfnt_buffer.encode(record)
            sfnt_bodies.append(data)
            sfnt_checkSum.append(checkSum)
            sfnt_offset += data.count
        }
        
        let offset = 44 + 20 * table.count
        var records = Data(capacity: 20 * table.count)
        var body = Data()
        
        for ((tag, var data), checkSum) in zip(_table, sfnt_checkSum) {
            
            let origLength = data.count
            data.count = data.count.align(4)
            
            if tag == "head" {
                let checksum = 0xB1B0AFBA &- sfnt_bodies.reduce(OTFEncoder.CalcTableChecksum(sfnt_buffer)) { OTFEncoder.CalcTableChecksum($1, $0) }
                data[data.startIndex + 8] = UInt8((checksum >> 24) & 0xFF)
                data[data.startIndex + 9] = UInt8((checksum >> 16) & 0xFF)
                data[data.startIndex + 10] = UInt8((checksum >> 8) & 0xFF)
                data[data.startIndex + 11] = UInt8(checksum & 0xFF)
            }
            
            let compressed: Data
            let compLength: Int
            
            switch deflate_level {
            case .none:
                compressed = data
                compLength = origLength
            default:
                if let _compressed = try? Deflate(level: deflate_level, windowBits: 15).process(data), _compressed.count < origLength {
                    compressed = _compressed
                    compLength = _compressed.count
                } else {
                    compressed = data
                    compLength = origLength
                }
            }
            
            let record = WOFFTableRecord(tag: tag, offset: BEUInt32(offset + body.count), compLength: BEUInt32(compLength), origLength: BEUInt32(origLength), origChecksum: BEUInt32(checkSum))
            
            records.encode(record)
            body.append(compressed)
            body.count = body.count.align(4)
        }
        
        let header = WOFFHeader(
            signature: "wOFF",
            flavor: sfnt_version,
            length: BEUInt32(offset + body.count),
            numTables: BEUInt16(table.count),
            reserved: 0,
            totalSfntSize: BEUInt32(sfnt_offset),
            majorVersion: 1,
            minorVersion: 0,
            metaOffset: 0,
            metaLength: 0,
            metaOrigLength: 0,
            privOffset: 0,
            privLength: 0
        )
        
        var buffer = Data(capacity: offset + body.count)
        buffer.encode(header)
        buffer.append(records)
        buffer.append(body)
        
        return buffer
    }
}
