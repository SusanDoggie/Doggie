//
//  JPEGHuffman.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

struct JPEGHuffmanTable : ByteCodable {
    
    var tables: [Table]
    
    init(from data: inout Data) throws {
        self.tables = []
        while !data.isEmpty {
            tables.append(try data.decode(Table.self))
        }
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        for table in tables {
            stream.encode(table)
        }
    }
}

extension JPEGHuffmanTable {
    
    struct Table : ByteCodable {
        
        var info: UInt8
        
        var table: [Key: UInt8] = [:]
        
        init(from data: inout Data) throws {
            
            self.info = try data.decode(UInt8.self)
            
            let count = (
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self)
            )
            
            try withUnsafeBytes(of: count) { count in
                
                guard count.reduce(0, { $0 + Int($1) }) <= 256 else { throw ImageRep.Error.InvalidFormat("Invalid Huffman table.") }
                
                var code: UInt16 = 0
                
                for (i, _count) in count.enumerated() {
                    for _ in 0..<_count {
                        table[Key(length: UInt8(i + 1), code: code)] = try data.decode(UInt8.self)
                        code += 1
                    }
                    code <<= 1
                }
            }
        }
        
        func write<Target: ByteOutputStream>(to stream: inout Target) {
            
            stream.encode(info)
            
            let group = Dictionary(grouping: table) { $0.key.length }
            
            let b1 = group[1]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b2 = group[2]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b3 = group[3]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b4 = group[4]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b5 = group[5]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b6 = group[6]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b7 = group[7]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b8 = group[8]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b9 = group[9]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b10 = group[10]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b11 = group[11]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b12 = group[12]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b13 = group[13]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b14 = group[14]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b15 = group[15]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            let b16 = group[16]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
            
            stream.encode(UInt8(b1.count))
            stream.encode(UInt8(b2.count))
            stream.encode(UInt8(b3.count))
            stream.encode(UInt8(b4.count))
            stream.encode(UInt8(b5.count))
            stream.encode(UInt8(b6.count))
            stream.encode(UInt8(b7.count))
            stream.encode(UInt8(b8.count))
            stream.encode(UInt8(b9.count))
            stream.encode(UInt8(b10.count))
            stream.encode(UInt8(b11.count))
            stream.encode(UInt8(b12.count))
            stream.encode(UInt8(b13.count))
            stream.encode(UInt8(b14.count))
            stream.encode(UInt8(b15.count))
            stream.encode(UInt8(b16.count))
            
            stream.write(b1)
            stream.write(b2)
            stream.write(b3)
            stream.write(b4)
            stream.write(b5)
            stream.write(b6)
            stream.write(b7)
            stream.write(b8)
            stream.write(b9)
            stream.write(b10)
            stream.write(b11)
            stream.write(b12)
            stream.write(b13)
            stream.write(b14)
            stream.write(b15)
            stream.write(b16)
            
        }
    }
}

extension JPEGHuffmanTable {
    
    struct Key : Hashable {
        
        var length: UInt8
        var code: UInt16
    }
}

extension JPEGHuffmanTable.Key : CustomStringConvertible {
    
    var description: String {
        let str = String(code, radix: 2)
        return repeatElement("0", count: Int(length) - str.count).joined() + str
    }
}

extension JPEGHuffmanTable.Table : CustomStringConvertible {
    
    var description: String {
        return "JPEGHuffmanTable(info: \(info), table: [\(table.map { "\($0): \(String($1, radix: 16))" }.joined(separator: ", "))])"
    }
}
