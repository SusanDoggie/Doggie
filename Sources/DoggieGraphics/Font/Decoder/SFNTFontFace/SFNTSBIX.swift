//
//  SFNTSBIX.swift
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

struct SFNTSBIX: RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    var version: BEUInt16
    var flags: BEUInt16
    var numStrikes: BEUInt32
    var data: Data
    
    init(_ data: Data) throws {
        var data = data
        self.version = try data.decode(BEUInt16.self)
        self.flags = try data.decode(BEUInt16.self)
        self.numStrikes = try data.decode(BEUInt32.self)
        self.data = data
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return Int(numStrikes)
    }
    
    subscript(position: Int) -> Strike? {
        
        assert(0..<count ~= position, "Index out of range.")
        
        guard self.data.count > position << 2 else { return nil }
        let offset = self.data.typed(as: BEUInt32.self)[position]
        
        guard offset >= 8 else { return nil }
        var data = self.data.dropFirst(Int(offset) - 8)
        
        guard let ppem = try? data.decode(BEUInt16.self) else { return nil }
        guard let resolution = try? data.decode(BEUInt16.self) else { return nil }
        
        return Strike(ppem: ppem, resolution: resolution, data: data)
    }
    
}

extension SFNTSBIX {
    
    struct Strike {
        
        var ppem: BEUInt16
        var resolution: BEUInt16
        
        var data: Data
    }
}

extension SFNTSBIX.Strike {
    
    struct Record {
        
        var originOffsetX: BEUInt16
        var originOffsetY: BEUInt16
        var graphicType: Signature<BEUInt32>
        var data: Data
    }
    
    func glyph(glyph: Int) -> Record? {
        
        guard self.data.count > (glyph + 1) << 2 else { return nil }
        
        let startIndex = Int(self.data.typed(as: BEUInt32.self)[glyph]) - 4
        let endIndex = Int(self.data.typed(as: BEUInt32.self)[glyph + 1]) - 4
        
        guard endIndex >= startIndex + 8 else { return nil }
        
        let length = endIndex - startIndex
        var data = self.data.dropFirst(startIndex).prefix(length)
        
        guard data.count == length else { return nil }
        
        guard let originOffsetX = try? data.decode(BEUInt16.self) else { return nil }
        guard let originOffsetY = try? data.decode(BEUInt16.self) else { return nil }
        guard let graphicType = try? data.decode(Signature<BEUInt32>.self) else { return nil }
        
        return Record(originOffsetX: originOffsetX, originOffsetY: originOffsetY, graphicType: graphicType, data: data)
    }
}
