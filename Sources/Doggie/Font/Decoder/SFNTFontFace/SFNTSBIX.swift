//
//  SFNTSBIX.swift
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

struct SFNTSBIX : RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    var numberOfGlyphs: Int
    
    var version: BEUInt16
    var flags: BEUInt16
    var numStrikes: BEUInt32
    var data: Data
    
    init(numberOfGlyphs: Int, data: Data) throws {
        var data = data
        self.numberOfGlyphs = numberOfGlyphs
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
    
    subscript(position: Int) -> Strike {
        precondition(position < count, "Index out of range.")
        
        let offset = self.data.withUnsafeBytes { $0[position] as BEUInt32 }
        var data = self.data.dropFirst(Int(offset) - 8)
        
        let ppem = data.popFirst(2).withUnsafeBytes { $0.pointee as BEUInt16 }
        let resolution = data.popFirst(2).withUnsafeBytes { $0.pointee as BEUInt16 }
        
        return Strike(numberOfGlyphs: numberOfGlyphs, ppem: ppem, resolution: resolution, data: data)
    }
    
}

extension SFNTSBIX {
    
    struct Strike {
        
        var numberOfGlyphs: Int
        
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
        
        guard 0..<numberOfGlyphs ~= glyph else { return nil }
        
        let startIndex = Int(self.data.withUnsafeBytes { $0[glyph] as BEUInt32 }) - 4
        let endIndex = Int(self.data.withUnsafeBytes { $0[glyph + 1] as BEUInt32 }) - 4
        
        guard endIndex >= startIndex + 8 else { return nil }
        
        var data = self.data.dropFirst(startIndex).prefix(endIndex - startIndex)
        
        guard data.count == endIndex - startIndex else { return nil }
        
        let originOffsetX = data.popFirst(2).withUnsafeBytes { $0.pointee as BEUInt16 }
        let originOffsetY = data.popFirst(2).withUnsafeBytes { $0.pointee as BEUInt16 }
        let graphicType = data.popFirst(4).withUnsafeBytes { $0.pointee as Signature<BEUInt32> }
        
        return Record(originOffsetX: originOffsetX, originOffsetY: originOffsetY, graphicType: graphicType, data: data)
    }
}
