//
//  CFF2INDEX.swift
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

struct CFF2INDEX : ByteDecodable, RandomAccessCollection {
    
    var _count: BEUInt32
    var offSize: UInt8
    var offset: Data
    var data: Data
    
    init(from data: inout Data) throws {
        self._count = try data.decode(BEUInt32.self)
        if _count == 0 {
            self.offSize = 0
            self.offset = Data()
            self.data = Data()
        } else {
            
            self.offSize = try data.decode(UInt8.self)
            
            let offsetSize = Int(offSize) * Int(_count + 1)
            self.offset = data.popFirst(offsetSize)
            guard offset.count == offsetSize else { throw ByteDecodeError.endOfData }
            
            let dataSize = CFF2INDEX._offset(Int(_count) - 1, offSize, offset).upperBound
            self.data = data.popFirst(dataSize)
            guard self.data.count == dataSize else { throw ByteDecodeError.endOfData }
        }
    }
    
    static func _offset(_ index: Int, _ offSize: UInt8, _ offset: Data) -> CountableRange<Int> {
        
        return offset.withUnsafeBytes { (offset: UnsafePointer<UInt8>) in
            
            let offSize = Int(offSize)
            
            var start = offset + index * offSize
            var end = start + offSize
            
            var startIndex = 0
            var endIndex = 0
            
            for _ in 0..<offSize {
                startIndex = (startIndex << 8) | Int(start.pointee)
                endIndex = (endIndex << 8) | Int(end.pointee)
                start += 1
                end += 1
            }
            
            startIndex -= 1
            endIndex -= 1
            
            return startIndex..<endIndex
        }
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return Int(_count)
    }
    
    subscript(position: Int) -> Data {
        precondition(position < count, "Index out of range.")
        let range = CFF2INDEX._offset(position, offSize, offset)
        let lowerBound = data.startIndex + range.lowerBound
        let upperBound = data.startIndex + range.upperBound
        return data[lowerBound..<upperBound]
    }
}
