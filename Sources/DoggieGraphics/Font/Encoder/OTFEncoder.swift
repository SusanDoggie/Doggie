//
//  OTFEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

struct OTFEncoder: FontFaceEncoder {
    
    static func encode(table: [Signature<BEUInt32>: Data], properties: [Font.PropertyKey: Any]) -> Data? {
        
        let _table = table.sorted { $0.key.rawValue }
        
        let version: Signature<BEUInt32> = table.keys.contains("CFF ") || table.keys.contains("CFF2") ? "OTTO" : 0x00010000
        let header = OTFHeader(version: version, numTables: table.count)
        
        var offset = 12 + 16 * table.count
        let body_size = table.values.reduce(0) { $0 + $1.count.align(4) }
        
        var buffer = Data(capacity: offset + body_size)
        buffer.encode(header)
        
        var bodies: [Data] = []
        var head_index: Int?
        
        for (tag, var data) in _table {
            
            let length = data.count
            data.count = data.count.align(4)
            
            if tag == "head" {
                guard data.count >= 54 else { return nil }
                head_index = bodies.count
                data[data.startIndex + 8] = 0
                data[data.startIndex + 9] = 0
                data[data.startIndex + 10] = 0
                data[data.startIndex + 11] = 0
            }
            
            let record = OTFTableRecord(tag: tag, checkSum: BEUInt32(CalcTableChecksum(data)), offset: BEUInt32(offset), length: BEUInt32(length))
            
            buffer.encode(record)
            bodies.append(data)
            offset += data.count
        }
        
        if let idx = head_index {
            
            var data = bodies[idx]
            
            let checksum = 0xB1B0AFBA &- bodies.reduce(CalcTableChecksum(buffer)) { CalcTableChecksum($1, $0) }
            
            data[data.startIndex + 8] = UInt8((checksum >> 24) & 0xFF)
            data[data.startIndex + 9] = UInt8((checksum >> 16) & 0xFF)
            data[data.startIndex + 10] = UInt8((checksum >> 8) & 0xFF)
            data[data.startIndex + 11] = UInt8(checksum & 0xFF)
            
            bodies[idx] = data
        }
        
        bodies.forEach { buffer.append($0) }
        
        return buffer
    }
}

extension OTFEncoder {
    
    static func CalcTableChecksum(_ data: Data, _ sum: UInt32 = 0) -> UInt32 {
        
        return data.withUnsafeBufferPointer(as: BEUInt32.self) { source in
            
            guard var ptr = source.baseAddress else { return sum }
            
            var sum = sum
            
            for _ in 0..<source.count {
                sum = sum &+ UInt32(ptr.pointee)
                ptr += 1
            }
            
            return sum
        }
    }
}
