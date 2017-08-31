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
    
    var table: [Signature<BEUInt32>: Data]
    
    var head: SFNTHEAD
    var cmap: SFNTCMAP
    var maxp: SFNTMAXP
    var post: SFNTPOST
    var name: SFNTNAME
    var hhea: SFNTHHEA
    var hmtx: Data
    var vhea: SFNTVHEA?
    var vmtx: Data?
    var loca: SFNTLOCA?
    var glyf: SFNTGLYF?
    
    init(table: [Signature<BEUInt32>: Data]) throws {
        
        print(Array(table.keys))
        
        guard let head = try table["head"].map({ try SFNTHEAD($0) }) else { throw FontCollection.Error.InvalidFormat("head not found.") }
        guard let cmap = try table["cmap"].map({ try SFNTCMAP($0) }) else { throw FontCollection.Error.InvalidFormat("cmap not found.") }
        guard let maxp = try table["maxp"].map({ try SFNTMAXP($0) }) else { throw FontCollection.Error.InvalidFormat("maxp not found.") }
        guard let post = try table["post"].map({ try SFNTPOST($0) }) else { throw FontCollection.Error.InvalidFormat("post not found.") }
        guard let name = try table["name"].map({ try SFNTNAME($0) }) else { throw FontCollection.Error.InvalidFormat("name not found.") }
        guard let hhea = try table["hhea"].map({ try SFNTHHEA($0) }) else { throw FontCollection.Error.InvalidFormat("hhea not found.") }
        guard let hmtx = table["hmtx"] else { throw FontCollection.Error.InvalidFormat("hmtx not found.") }
        guard maxp.numGlyphs >= hhea.numOfLongHorMetrics else { throw DataDecodeError.endOfData }
        
        let hMetricSize = Int(hhea.numOfLongHorMetrics) << 2
        let hBearingSize = (Int(maxp.numGlyphs) - Int(hhea.numOfLongHorMetrics)) << 1
        
        guard hmtx.count >= hMetricSize + hBearingSize else { throw DataDecodeError.endOfData }
        
        self.table = table
        self.head = head
        self.cmap = cmap
        self.maxp = maxp
        self.post = post
        self.name = name
        self.hhea = hhea
        self.hmtx = hmtx
        
        if let loca = table["loca"], let glyf = table["glyf"] {
            
            let locaSize = head.indexToLocFormat == 0 ? Int(maxp.numGlyphs) << 1 : Int(maxp.numGlyphs) << 2
            
            guard loca.count >= locaSize else { throw DataDecodeError.endOfData }
            
            self.loca = SFNTLOCA(loca)
            self.glyf = SFNTGLYF(glyf)
            
        } else if let cff = table["CFF "] {
            
        } else if let cff2 = table["CFF2"] {
            
        } else {
            throw FontCollection.Error.InvalidFormat("outlines not found.")
        }
        
        if let vhea = table["vhea"].flatMap({ try? SFNTVHEA($0) }), maxp.numGlyphs >= vhea.numOfLongVerMetrics, let vmtx = table["vmtx"] {
            
            let vMetricSize = Int(vhea.numOfLongVerMetrics) << 2
            let vBearingSize = (Int(maxp.numGlyphs) - Int(vhea.numOfLongVerMetrics)) << 1
            
            if vmtx.count >= vMetricSize + vBearingSize {
                self.vhea = vhea
                self.vmtx = vmtx
            }
        }
    }
}

extension SFNTFontFace {
    
    var numberOfGlyphs: Int {
        return Int(maxp.numGlyphs)
    }
    
    var coveredCharacterSet: CharacterSet {
        return cmap.table.format.coveredCharacterSet
    }
}

extension SFNTFontFace {
    
    func glyph(unicode: UnicodeScalar) -> Int {
        return cmap.table.format[unicode.value]
    }
}

extension SFNTFontFace {
    
    private struct Metric {
        var advance: BEUInt16
        var bearing: BEInt16
    }
    
    func advanceWidth(glyph: Int) -> Double {
        precondition(glyph < numberOfGlyphs, "Index out of range.")
        let hMetricCount = Int(hhea.numOfLongHorMetrics)
        return hmtx.withUnsafeBytes { (metrics: UnsafePointer<Metric>) in Double(metrics[glyph < hMetricCount ? glyph : hMetricCount - 1].advance.representingValue) }
    }
    
    func advanceHeight(glyph: Int) -> Double {
        precondition(glyph < numberOfGlyphs, "Index out of range.")
        if let vhea = self.vhea, let vmtx = self.vmtx {
            let vMetricCount = Int(vhea.numOfLongVerMetrics)
            return vmtx.withUnsafeBytes { (metrics: UnsafePointer<Metric>) in Double(metrics[glyph < vMetricCount ? glyph : vMetricCount - 1].advance.representingValue) }
        }
        return 0
    }
    
    func bearingX(glyph: Int) -> Double {
        precondition(glyph < numberOfGlyphs, "Index out of range.")
        let hMetricCount = Int(hhea.numOfLongHorMetrics)
        if glyph < hMetricCount {
            return hmtx.withUnsafeBytes { (metrics: UnsafePointer<Metric>) in Double(metrics[glyph].bearing.representingValue) }
        } else {
            return hmtx.dropFirst(hMetricCount << 2).withUnsafeBytes { (metrics: UnsafePointer<BEInt16>) in Double(metrics[glyph - hMetricCount].representingValue) }
        }
    }
    
    func bearingY(glyph: Int) -> Double {
        precondition(glyph < numberOfGlyphs, "Index out of range.")
        if let vhea = self.vhea, let vmtx = self.vmtx {
            let vMetricCount = Int(vhea.numOfLongVerMetrics)
            if glyph < vMetricCount {
                return vmtx.withUnsafeBytes { (metrics: UnsafePointer<Metric>) in Double(metrics[glyph].bearing.representingValue) }
            } else {
                return vmtx.dropFirst(vMetricCount << 2).withUnsafeBytes { (metrics: UnsafePointer<BEInt16>) in Double(metrics[glyph - hMetricCount].representingValue) }
            }
        }
        return 0
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

