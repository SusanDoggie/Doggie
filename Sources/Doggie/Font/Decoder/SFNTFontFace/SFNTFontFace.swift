//
//  SFNTFontFace.swift
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

struct SFNTFontFace : FontFaceBase {
    
    let table: [Signature<BEUInt32>: Data]
    
    let head: SFNTHEAD
    let cmap: SFNTCMAP
    let maxp: SFNTMAXP
    let post: SFNTPOST
    let name: SFNTNAME
    let hhea: SFNTHHEA
    let hmtx: SFNTHMTX
    let vhea: SFNTVHEA?
    let vmtx: SFNTVMTX?
    
    init(table: [Signature<BEUInt32>: Data]) throws {
        
        guard let head = try table["head"].map({ try SFNTHEAD($0) }) else { throw FontCollection.Error.InvalidFormat("head not found.") }
        guard let cmap = try table["cmap"].map({ try SFNTCMAP($0) }) else { throw FontCollection.Error.InvalidFormat("cmap not found.") }
        guard let maxp = try table["maxp"].map({ try SFNTMAXP($0) }) else { throw FontCollection.Error.InvalidFormat("maxp not found.") }
        guard let post = try table["post"].map({ try SFNTPOST($0) }) else { throw FontCollection.Error.InvalidFormat("post not found.") }
        guard let name = try table["name"].map({ try SFNTNAME($0) }) else { throw FontCollection.Error.InvalidFormat("name not found.") }
        guard let hhea = try table["hhea"].map({ try SFNTHHEA($0) }) else { throw FontCollection.Error.InvalidFormat("hhea not found.") }
        guard let hmtx = try table["hmtx"].map({ try SFNTHMTX($0) }) else { throw FontCollection.Error.InvalidFormat("hmtx not found.") }
        
        self.table = table
        self.head = head
        self.cmap = cmap
        self.maxp = maxp
        self.post = post
        self.name = name
        self.hhea = hhea
        self.hmtx = hmtx
        self.vhea = try table["vhea"].map({ try SFNTVHEA($0) })
        self.vmtx = try table["vmtx"].map({ try SFNTVMTX($0) })
    }
}

extension SFNTFontFace {
    
    var coveredCharacterSet: CharacterSet {
        return cmap.coveredCharacterSet
    }
}

extension SFNTFontFace {
    
    var ascender: Double {
        return Double(hhea.ascent.representingValue)
    }
    var descender: Double {
        return Double(hhea.descent.representingValue)
    }
    var lineGap: Double {
        return Double(hhea.lineGap.representingValue)
    }
    
    var verticalAscender: Double? {
        return (vhea?.vertTypoAscender.representingValue).map(Double.init)
    }
    var verticalDescender: Double? {
        return (vhea?.vertTypoDescender.representingValue).map(Double.init)
    }
    var verticalLineGap: Double? {
        return (vhea?.vertTypoLineGap.representingValue).map(Double.init)
    }
    
    var unitsPerEm: Double {
        return Double(head.unitsPerEm.representingValue)
    }
    
    var boundingRectForFont: Rect {
        let minX = Double(head.xMin.representingValue)
        let minY = Double(head.yMin.representingValue)
        let maxX = Double(head.xMax.representingValue)
        let maxY = Double(head.yMax.representingValue)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var italicAngle: Double {
        return post.italicAngle.representingValue
    }
    
    var isFixedPitch: Bool {
        return post.isFixedPitch != 0
    }
    
    var underlinePosition: Double {
        return Double(post.underlinePosition.representingValue)
    }
    var underlineThickness: Double {
        return Double(post.underlineThickness.representingValue)
    }
}

extension SFNTFontFace {
    
    func queryName(_ id: Int) -> String? {
        let macOSRoman = name.name.lazy.filter { $0.platform.platform == 1 && $0.platform.specific == 0 && $0.name == id }
        let unicode = name.name.lazy.filter { $0.platform.platform == 0 && $0.name == id }
        return macOSRoman.map { $0.value }.first ?? unicode.map { $0.value }.first
    }
    
    var copyright: String? {
        return queryName(0)
    }
    
    var fontName: String? {
        return queryName(6)
    }
    
    var familyName: String? {
        return queryName(1)
    }
    
    var faceName: String? {
        return queryName(2)
    }
    
    var uniqueName: String? {
        return queryName(3)
    }
    
    var displayName: String? {
        return queryName(4)
    }
    
    var version: String? {
        return queryName(5)
    }
    
    var trademark: String? {
        return queryName(7)
    }
    
    var manufacturer: String? {
        return queryName(8)
    }
    
    var designer: String? {
        return queryName(9)
    }
    
    var license: String? {
        return queryName(13)
    }
}

