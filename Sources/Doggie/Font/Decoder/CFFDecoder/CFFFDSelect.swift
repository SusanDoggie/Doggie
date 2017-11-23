//
//  CFFFDSelect.swift
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

struct CFFFDSelect {
    
    var nGlyphs: Int
    var format: UInt8
    
    var fds: Data
    
    var nRanges: BEUInt16
    var range: Data
    var sentinel: BEUInt16
    
    init(_ data: Data, _ nGlyphs: Int) throws {
        
        var data = data
        
        self.nGlyphs = nGlyphs
        self.format = try data.decode(UInt8.self)
        
        fds = Data()
        nRanges = 0
        range = Data()
        sentinel = 0
        
        switch format {
        case 0:
            
            self.fds = data.popFirst(nGlyphs)
            guard self.fds.count == nGlyphs else { throw ByteDecodeError.endOfData }
            
        case 3:
            
            self.nRanges = try data.decode(BEUInt16.self)
            
            self.range = data.popFirst(Int(nRanges) * 3)
            guard self.range.count == Int(nRanges) * 3 else { throw ByteDecodeError.endOfData }
            
            self.sentinel = try data.decode(BEUInt16.self)
            
        default: throw FontCollection.Error.InvalidFormat("Invalid CFF FDSelect format.")
        }
    }
    
    func fdIndex(glyph: UInt16) -> UInt8? {
        
        switch format {
        case 0:
            if glyph < nGlyphs {
                return self.fds[Int(glyph)]
            }
        case 3:
            
            let limit = min(UInt16(sentinel), UInt16(nGlyphs))
            
            if glyph < limit {
                
                let rangeCount = Int(nRanges)
                var _range = 0..<rangeCount
                
                while _range.count != 0 {
                    
                    let mid = (_range.lowerBound + _range.upperBound) >> 1
                    var records = self.range.dropFirst(mid * 3)
                    
                    guard let _startGlyphID = try? records.decode(BEUInt16.self) else { return nil }
                    guard let fd = try? records.decode(UInt8.self) else { return nil }
                    
                    let startGlyphID = UInt16(_startGlyphID)
                    let endGlyphID: UInt16
                    
                    if mid + 1 < rangeCount {
                        guard let _endGlyphID = try? records.decode(BEUInt16.self) else { return nil }
                        endGlyphID = UInt16(_endGlyphID)
                    } else {
                        endGlyphID = limit - 1
                    }
                    
                    if startGlyphID <= endGlyphID && startGlyphID...endGlyphID ~= glyph {
                        return fd
                    }
                    
                    _range = glyph < startGlyphID ? _range.prefix(upTo: mid) : _range.suffix(from: mid).dropFirst()
                }
                
                return nil
            }
            
        default: break
        }
        return nil
    }
}
