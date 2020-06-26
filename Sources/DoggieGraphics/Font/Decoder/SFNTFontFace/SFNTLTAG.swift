//
//  SFNTLTAG.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

struct SFNTLTAG: ByteDecodable, RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    var version: BEUInt32
    var flags: BEUInt32
    var record: [Record]
    var data: Data
    
    struct Record {
        
        var offset: BEUInt16
        var length: BEUInt16
    }
    
    init(from data: inout Data) throws {
        
        self.version = try data.decode(BEUInt32.self)
        self.flags = try data.decode(BEUInt32.self)
        let _count = try data.decode(BEUInt32.self)
        
        self.record = []
        self.record.reserveCapacity(Int(_count))
        
        for _ in 0..<Int(_count) {
            
            let offset = try data.decode(BEUInt16.self)
            let length = try data.decode(BEUInt16.self)
            
            self.record.append(Record(offset: offset, length: length))
        }
        
        self.data = data
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return record.count
    }
    
    subscript(position: Int) -> String? {
        
        assert(0..<count ~= position, "Index out of range.")
        
        let offset = Int(self.record[position].offset)
        let length = Int(self.record[position].length)
        
        let strData: Data = self.data.dropFirst(offset).prefix(length)
        
        guard strData.count == length else { return nil }
        
        return String(data: strData, encoding: .utf8)
    }
    
}

