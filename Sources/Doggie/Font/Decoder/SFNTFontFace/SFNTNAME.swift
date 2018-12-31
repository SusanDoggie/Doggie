//
//  SFNTNAME.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

struct SFNTNAME : ByteDecodable, RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    var format: BEUInt16
    var record: [Record]
    var data: Data
    
    struct Record {
        
        var platform: SFNTPlatform
        var language: BEUInt16
        var name: BEUInt16
        var length: BEUInt16
        var offset: BEUInt16
    }
    
    init(from data: inout Data) throws {
        
        let copy = data
        
        self.format = try data.decode(BEUInt16.self)
        let _count = try data.decode(BEUInt16.self)
        let _stringOffset = try data.decode(BEUInt16.self)
        
        self.data = copy.dropFirst(Int(_stringOffset))
        
        self.record = []
        self.record.reserveCapacity(Int(_count))
        
        for _ in 0..<Int(_count) {
            
            let platform = try data.decode(SFNTPlatform.self)
            let language = try data.decode(BEUInt16.self)
            let name = try data.decode(BEUInt16.self)
            let length = try data.decode(BEUInt16.self)
            let offset = try data.decode(BEUInt16.self)
            
            self.record.append(Record(platform: platform, language: language, name: name, length: length, offset: offset))
        }
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return record.count
    }
    
    subscript(position: Int) -> String? {
        
        precondition(position < count, "Index out of range.")
        
        guard let encoding = self.record[position].platform.encoding else { return nil }
        
        let offset = Int(self.record[position].offset)
        let length = Int(self.record[position].length)
        
        let strData: Data = self.data.dropFirst(offset).prefix(length)
        
        guard strData.count == length else { return "" }
        
        return String(data: strData, encoding: encoding)
    }
    
}

