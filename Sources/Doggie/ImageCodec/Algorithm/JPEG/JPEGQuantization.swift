//
//  JPEGQuantization.swift
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

struct JPEGQuantizationTable : ByteCodable {
    
    var tables: [(UInt8, Table)]
    
    init(from data: inout Data) throws {
        self.tables = []
        while data.count != 0 {
            let byte = try data.decode(UInt8.self)
            if byte & 0xF0 == 0 {
                tables.append((byte, .table8(try data.decode(Table8.self))))
            } else {
                tables.append((byte, .table16(try data.decode(Table16.self))))
            }
        }
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        for table in tables {
            stream.encode(table.0)
            switch table.1 {
            case let .table8(table): stream.encode(table)
            case let .table16(table): stream.encode(table)
            }
        }
    }
    
    enum Table {
        case table8(Table8)
        case table16(Table16)
    }
}

extension JPEGQuantizationTable {
    
    struct Table8 : ByteCodable {
        
        var table: (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )
        
        init(from data: inout Data) throws {
            self.table = (
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self)
            )
        }
        
        func write<Target: ByteOutputStream>(to stream: inout Target) {
            stream.encode(table.0)
            stream.encode(table.1)
            stream.encode(table.2)
            stream.encode(table.3)
            stream.encode(table.4)
            stream.encode(table.5)
            stream.encode(table.6)
            stream.encode(table.7)
            stream.encode(table.8)
            stream.encode(table.9)
            stream.encode(table.10)
            stream.encode(table.11)
            stream.encode(table.12)
            stream.encode(table.13)
            stream.encode(table.14)
            stream.encode(table.15)
            stream.encode(table.16)
            stream.encode(table.17)
            stream.encode(table.18)
            stream.encode(table.19)
            stream.encode(table.20)
            stream.encode(table.21)
            stream.encode(table.22)
            stream.encode(table.23)
            stream.encode(table.24)
            stream.encode(table.25)
            stream.encode(table.26)
            stream.encode(table.27)
            stream.encode(table.28)
            stream.encode(table.29)
            stream.encode(table.30)
            stream.encode(table.31)
            stream.encode(table.32)
            stream.encode(table.33)
            stream.encode(table.34)
            stream.encode(table.35)
            stream.encode(table.36)
            stream.encode(table.37)
            stream.encode(table.38)
            stream.encode(table.39)
            stream.encode(table.40)
            stream.encode(table.41)
            stream.encode(table.42)
            stream.encode(table.43)
            stream.encode(table.44)
            stream.encode(table.45)
            stream.encode(table.46)
            stream.encode(table.47)
            stream.encode(table.48)
            stream.encode(table.49)
            stream.encode(table.50)
            stream.encode(table.51)
            stream.encode(table.52)
            stream.encode(table.53)
            stream.encode(table.54)
            stream.encode(table.55)
            stream.encode(table.56)
            stream.encode(table.57)
            stream.encode(table.58)
            stream.encode(table.59)
            stream.encode(table.60)
            stream.encode(table.61)
            stream.encode(table.62)
            stream.encode(table.63)
        }
    }
}

extension JPEGQuantizationTable {
    
    struct Table16 : ByteCodable {
        
        var table: (
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16
        )
        
        init(from data: inout Data) throws {
            self.table = (
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)),
                UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self)), UInt16(try data.decode(BEUInt16.self))
            )
        }
        
        func write<Target: ByteOutputStream>(to stream: inout Target) {
            stream.encode(table.0)
            stream.encode(table.1)
            stream.encode(table.2)
            stream.encode(table.3)
            stream.encode(table.4)
            stream.encode(table.5)
            stream.encode(table.6)
            stream.encode(table.7)
            stream.encode(table.8)
            stream.encode(table.9)
            stream.encode(table.10)
            stream.encode(table.11)
            stream.encode(table.12)
            stream.encode(table.13)
            stream.encode(table.14)
            stream.encode(table.15)
            stream.encode(table.16)
            stream.encode(table.17)
            stream.encode(table.18)
            stream.encode(table.19)
            stream.encode(table.20)
            stream.encode(table.21)
            stream.encode(table.22)
            stream.encode(table.23)
            stream.encode(table.24)
            stream.encode(table.25)
            stream.encode(table.26)
            stream.encode(table.27)
            stream.encode(table.28)
            stream.encode(table.29)
            stream.encode(table.30)
            stream.encode(table.31)
            stream.encode(table.32)
            stream.encode(table.33)
            stream.encode(table.34)
            stream.encode(table.35)
            stream.encode(table.36)
            stream.encode(table.37)
            stream.encode(table.38)
            stream.encode(table.39)
            stream.encode(table.40)
            stream.encode(table.41)
            stream.encode(table.42)
            stream.encode(table.43)
            stream.encode(table.44)
            stream.encode(table.45)
            stream.encode(table.46)
            stream.encode(table.47)
            stream.encode(table.48)
            stream.encode(table.49)
            stream.encode(table.50)
            stream.encode(table.51)
            stream.encode(table.52)
            stream.encode(table.53)
            stream.encode(table.54)
            stream.encode(table.55)
            stream.encode(table.56)
            stream.encode(table.57)
            stream.encode(table.58)
            stream.encode(table.59)
            stream.encode(table.60)
            stream.encode(table.61)
            stream.encode(table.62)
            stream.encode(table.63)
        }
    }
}
