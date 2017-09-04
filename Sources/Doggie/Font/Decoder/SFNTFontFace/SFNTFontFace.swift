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
    var loca: Data?
    var glyf: Data?
    var cff: CFFFontFace?
    var cff2: CFF2Decoder?
    
    init(table: [Signature<BEUInt32>: Data]) throws {
        
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
        
        if let vhea = table["vhea"].flatMap({ try? SFNTVHEA($0) }), maxp.numGlyphs >= vhea.numOfLongVerMetrics, let vmtx = table["vmtx"] {
            
            let vMetricSize = Int(vhea.numOfLongVerMetrics) << 2
            let vBearingSize = (Int(maxp.numGlyphs) - Int(vhea.numOfLongVerMetrics)) << 1
            
            if vmtx.count >= vMetricSize + vBearingSize {
                self.vhea = vhea
                self.vmtx = vmtx
            }
        }
        
        if let cff2 = table["CFF2"] {
            
            self.cff2 = try CFF2Decoder(cff2)
            
        } else if let cff = try table["CFF "].flatMap({ try CFFDecoder($0).faces.first }) {
            
            self.cff = cff
            
        } else if let loca = table["loca"], let glyf = table["glyf"] {
            
            let locaSize = head.indexToLocFormat == 0 ? (Int(maxp.numGlyphs) + 1) << 1 : (Int(maxp.numGlyphs) + 1) << 2
            
            guard loca.count >= locaSize else { throw DataDecodeError.endOfData }
            
            self.loca = loca
            self.glyf = glyf
            
        } else {
            throw FontCollection.Error.InvalidFormat("outlines not found.")
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
    
    private func _glyfData(glyph: Int) -> Data? {
        precondition(glyph < numberOfGlyphs, "Index out of range.")
        guard let loca = self.loca, let glyf = self.glyf else { return nil }
        if head.indexToLocFormat == 0 {
            let startIndex = loca.withUnsafeBytes { $0[glyph] as BEUInt16 }
            let endIndex = loca.withUnsafeBytes { $0[glyph + 1] as BEUInt16 }
            return glyf.dropFirst(Int(startIndex)).prefix(Int(endIndex) - Int(startIndex))
        } else {
            let startIndex = loca.withUnsafeBytes { $0[glyph] as BEUInt32 }
            let endIndex = loca.withUnsafeBytes { $0[glyph + 1] as BEUInt32 }
            return glyf.dropFirst(Int(startIndex)).prefix(Int(endIndex) - Int(startIndex))
        }
    }
    
    func boundary(glyph: Int) -> Rect {
        
        if var data = _glyfData(glyph: glyph) {
            
            guard let _ = try? data.decode(BEInt16.self) else { return Rect() }
            guard let xMin = try? data.decode(BEInt16.self) else { return Rect() }
            guard let yMin = try? data.decode(BEInt16.self) else { return Rect() }
            guard let xMax = try? data.decode(BEInt16.self) else { return Rect() }
            guard let yMax = try? data.decode(BEInt16.self) else { return Rect() }
            
            let minX = Double(xMin.representingValue)
            let minY = Double(yMin.representingValue)
            let maxX = Double(xMax.representingValue)
            let maxY = Double(yMax.representingValue)
            return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
        
        return Rect()
    }
    
    private func _glyfOutline(_ glyph: Int) -> ([Point], Shape.Component)? {
        
        guard var data = _glyfData(glyph: glyph) else { return nil }
        
        guard let numberOfContours = try? data.decode(BEInt16.self), numberOfContours > 0 else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        
        let count = Int(numberOfContours)
        
        var endPtsOfContours = [BEUInt16]()
        endPtsOfContours.reserveCapacity(count)
        
        for _ in 0..<count {
            guard let i = try? data.decode(BEUInt16.self) else { return nil }
            endPtsOfContours.append(i)
        }
        
        guard let instructionLength = try? data.decode(BEUInt16.self) else { return nil }
        
        var instructions = [UInt8]()
        instructions.reserveCapacity(Int(instructionLength))
        
        for _ in 0..<Int(instructionLength) {
            guard let i = try? data.decode(UInt8.self) else { return nil }
            instructions.append(i)
        }
        
        var flags = [UInt8]()
        flags.reserveCapacity(count)
        while flags.count < count {
            guard let flag = try? data.decode(UInt8.self) else { return nil }
            flags.append(flag)
            if flag & 8 != 0 {
                guard let _repeat = try? data.decode(UInt8.self) else { return nil }
                for _ in 0..<_repeat {
                    flags.append(flag)
                }
            }
        }
        guard flags.count == count else { return nil }
        
        func coordinate(_ flag: UInt8, _ previousValue: Int16, _ bitMask: (UInt8, UInt8)) throws -> Int16 {
            var code: Int16
            if flag & bitMask.0 != 0 {
                code = Int16(try data.decode(Int8.self))
                if flag & bitMask.1 == 0 {
                    code = -code
                }
                code = previousValue + code
            } else {
                if flag & bitMask.1 != 0 {
                    code = previousValue
                } else {
                    code = try previousValue + data.decode(Int16.self)
                }
            }
            return code
        }
        
        var x_coordinate: [Int16] = []
        var y_coordinate: [Int16] = []
        x_coordinate.reserveCapacity(count)
        y_coordinate.reserveCapacity(count)
        
        for flag in flags {
            guard let _x = try? coordinate(flag, x_coordinate.last ?? 0, (2, 16)) else { return nil }
            x_coordinate.append(_x)
        }
        
        for flag in flags {
            guard let _y = try? coordinate(flag, y_coordinate.last ?? 0, (4, 32)) else { return nil }
            y_coordinate.append(_y)
        }
        
        let points = zip(x_coordinate, y_coordinate).map { Point(x: Double($0), y: Double($1)) }
        
        var component = Shape.Component(start: Point(), closed: true, segments: [])
        
        if flags[count - 1] & 1 == 1 {
            component.start = points[count - 1]
        } else if flags[0] & 1 == 1 {
            component.start = points[0]
        } else {
            component.start = 0.5 * (points[count - 1] + points[0])
        }
        
        var record = (flags[count - 1], points[count - 1])
        
        for (f, p) in zip(zip(flags, flags.rotated(1)), zip(points, points.rotated(1))) {
            
            if f.0 & 1 == 0 {
                if f.1 & 1 == 1 {
                    component.append(.quad(p.0, p.1))
                } else {
                    component.append(.quad(p.0, 0.5 * (p.0 + p.1)))
                }
            } else {
                if record.0 & 1 == 0 {
                    component.append(.quad(0.5 * (p.0 + record.1), p.0))
                } else {
                    component.append(.line(p.0))
                }
            }
            
            record = (f.0, p.0)
        }
        
        return (points, component)
    }
    
    func shape(glyph: Int) -> [Shape.Component] {
        
        if var data = _glyfData(glyph: glyph) {
            
            guard let numberOfContours = try? BEInt16(data), numberOfContours != 0 else { return [] }
            
            if numberOfContours > 0 {
                
                print("data:", data)
                print("numberOfContours:", numberOfContours)
                
                return self._glyfOutline(glyph).map { [$0.1] } ?? []
                
            } else {
                
                var components = [Shape.Component]()
                
                var _continue = true
                
                var points = [Point]()
                
                while _continue {
                    
                    guard let flags = try? data.decode(BEUInt16.self) else { return [] }
                    guard let glyphIndex = try? data.decode(BEUInt16.self), glyphIndex != glyph else { return [] }
                    
                    guard let (_points, component) = self._glyfOutline(Int(glyphIndex)) else { return [] }
                    
                    var transform = SDTransform.identity
                    
                    if flags & 1 != 0 {
                        
                        if flags & 2 != 0 {
                            
                            guard let dx = try? data.decode(BEInt16.self) else { return [] }
                            guard let dy = try? data.decode(BEInt16.self) else { return [] }
                            
                            transform.c = Double(dx.representingValue)
                            transform.f = Double(dy.representingValue)
                            
                        } else {
                            
                            guard let m0 = try? data.decode(BEUInt16.self), m0 < points.count else { return [] }
                            guard let m1 = try? data.decode(BEUInt16.self), m1 < _points.count else { return [] }
                            
                            let offset = points[Int(m0)] - _points[Int(m1)]
                            
                            transform.c = offset.x
                            transform.f = offset.y
                        }
                    } else {
                        
                        if flags & 2 != 0 {
                            
                            guard let dx = try? data.decode(Int8.self) else { return [] }
                            guard let dy = try? data.decode(Int8.self) else { return [] }
                            
                            transform.c = Double(dx)
                            transform.f = Double(dy)
                            
                        } else {
                            
                            guard let m0 = try? data.decode(UInt8.self), m0 < points.count else { return [] }
                            guard let m1 = try? data.decode(UInt8.self), m1 < _points.count else { return [] }
                            
                            let offset = points[Int(m0)] - _points[Int(m1)]
                            
                            transform.c = offset.x
                            transform.f = offset.y
                        }
                    }
                    
                    if flags & 8 != 0 {
                        
                        guard let scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        
                        transform.a = scale.representingValue
                        transform.e = scale.representingValue
                        
                    } else if flags & 64 != 0 {
                        
                        guard let x_scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        guard let y_scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        
                        transform.a = x_scale.representingValue
                        transform.e = y_scale.representingValue
                        
                    } else if flags & 128 != 0 {
                        
                        guard let m00 = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        guard let m01 = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        guard let m10 = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        guard let m11 = try? data.decode(Fixed14Number<BEInt16>.self) else { return [] }
                        
                        transform.a = m00.representingValue
                        transform.b = m01.representingValue
                        transform.d = m10.representingValue
                        transform.e = m11.representingValue
                    }
                    
                    points.append(contentsOf: _points)
                    components.append(component * transform)
                    _continue = flags & 32 != 0
                }
                
                return components
            }
        }
        
        return []
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

