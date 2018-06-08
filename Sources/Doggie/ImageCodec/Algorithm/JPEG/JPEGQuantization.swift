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
    
    func write(to stream: ByteOutputStream) {
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
        
        func write(to stream: ByteOutputStream) {
            stream.encode(table.0, table.1, table.2, table.3, table.4, table.5, table.6, table.7)
            stream.encode(table.8, table.9, table.10, table.11, table.12, table.13, table.14, table.15)
            stream.encode(table.16, table.17, table.18, table.19, table.20, table.21, table.22, table.23)
            stream.encode(table.24, table.25, table.26, table.27, table.28, table.29, table.30, table.31)
            stream.encode(table.32, table.33, table.34, table.35, table.36, table.37, table.38, table.39)
            stream.encode(table.40, table.41, table.42, table.43, table.44, table.45, table.46, table.47)
            stream.encode(table.48, table.49, table.50, table.51, table.52, table.53, table.54, table.55)
            stream.encode(table.56, table.57, table.58, table.59, table.60, table.61, table.62, table.63)
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
        
        func write(to stream: ByteOutputStream) {
            stream.encode(table.0, table.1, table.2, table.3, table.4, table.5, table.6, table.7)
            stream.encode(table.8, table.9, table.10, table.11, table.12, table.13, table.14, table.15)
            stream.encode(table.16, table.17, table.18, table.19, table.20, table.21, table.22, table.23)
            stream.encode(table.24, table.25, table.26, table.27, table.28, table.29, table.30, table.31)
            stream.encode(table.32, table.33, table.34, table.35, table.36, table.37, table.38, table.39)
            stream.encode(table.40, table.41, table.42, table.43, table.44, table.45, table.46, table.47)
            stream.encode(table.48, table.49, table.50, table.51, table.52, table.53, table.54, table.55)
            stream.encode(table.56, table.57, table.58, table.59, table.60, table.61, table.62, table.63)
        }
    }
}
