//
//  SFNTFontFace.swift
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

struct SFNTFontFace : FontFaceBase {
    
    var table: [Signature<BEUInt32>: Data]
    
    var head: SFNTHEAD
    var os2: SFNTOS2?
    var cmap: SFNTCMAP
    var maxp: SFNTMAXP
    var post: SFNTPOST
    var name: SFNTNAME
    var hhea: SFNTHHEA
    var hmtx: Data
    var vhea: SFNTVHEA?
    var vmtx: Data?
    var glyf: SFNTGLYF?
    var sbix: SFNTSBIX?
    var feat: SFNTFEAT?
    var morx: SFNTMORX?
    var gdef: OTFGDEF?
    var gpos: OTFGPOS?
    var gsub: OTFGSUB?
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
        guard maxp.numGlyphs >= hhea.numOfLongHorMetrics else { throw ByteDecodeError.endOfData }
        
        let hMetricSize = Int(hhea.numOfLongHorMetrics) << 2
        let hBearingSize = (Int(maxp.numGlyphs) - Int(hhea.numOfLongHorMetrics)) << 1
        
        guard hmtx.count >= hMetricSize + hBearingSize else { throw ByteDecodeError.endOfData }
        
        self.table = table
        self.head = head
        self.cmap = cmap
        self.maxp = maxp
        self.post = post
        self.name = name
        self.hhea = hhea
        self.hmtx = hmtx
        
        self.os2 = try table["OS/2"].map { try SFNTOS2($0) }
        
        self.feat = try table["feat"].map { try SFNTFEAT($0) }
        self.morx = try table["morx"].map { try SFNTMORX($0) }
        self.gdef = try table["GDEF"].map { try OTFGDEF($0) }
        self.gpos = try table["GPOS"].map { try OTFGPOS($0) }
        self.gsub = try table["GSUB"].map { try OTFGSUB($0) }
        
        if let vhea = try table["vhea"].map({ try SFNTVHEA($0) }), maxp.numGlyphs >= vhea.numOfLongVerMetrics, let vmtx = table["vmtx"] {
            
            let vMetricSize = Int(vhea.numOfLongVerMetrics) << 2
            let vBearingSize = (Int(maxp.numGlyphs) - Int(vhea.numOfLongVerMetrics)) << 1
            
            if vmtx.count >= vMetricSize + vBearingSize {
                self.vhea = vhea
                self.vmtx = vmtx
            }
        }
        
        if let loca = table["loca"], let glyf = table["glyf"] {
            self.glyf = try SFNTGLYF(format: Int(head.indexToLocFormat), numberOfGlyphs: Int(maxp.numGlyphs), loca: loca, glyf: glyf)
        }
        
        self.sbix = try table["sbix"].map { try SFNTSBIX($0) }
        self.cff = try table["CFF "].flatMap { try CFFDecoder($0).faces.first }
        self.cff2 = try table["CFF2"].map { try CFF2Decoder($0) }
        
        if glyf == nil && sbix == nil && cff == nil && cff2 == nil {
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
    
    func shape(forGlyph glyph: Int) -> [Shape.Component] {
        
        if let shape = cff?.shape(glyph: glyph) {
            return shape
        }
        
        if let shape = glyf?.outline(glyph: glyph)?.1 {
            return shape
        }
        
        return []
    }
    
    func graphic(forGlyph glyph: Int) -> [Font.Graphic]? {
        
        if let sbix = sbix {
            
            func fetch(_ strike: SFNTSBIX.Strike, glyph: Int) -> Font.Graphic? {
                
                guard let record = strike.glyph(glyph: glyph) else { return nil }
                
                switch record.graphicType {
                case "dupe": return record.data.count == 2 ? fetch(strike, glyph: Int(record.data.load(as: BEUInt16.self))) : nil
                case "mask": return nil
                default: break
                }
                
                return Font.Graphic(type: Font.GraphicType(record.graphicType), unitsPerEm: Double(strike.ppem), resolution: Double(strike.resolution), origin: Point(x: Double(record.originOffsetX), y: Double(record.originOffsetY)), data: record.data)
            }
            
            return sbix.compactMap { $0.flatMap { fetch($0, glyph: glyph) } }
        }
        
        return nil
    }
}

extension SFNTFontFace {
    
    var isVariationSelectors: Bool {
        return cmap.uvs != nil
    }
    var isGraphic: Bool {
        return sbix != nil
    }
    
    func glyph(with unicode: UnicodeScalar) -> Int {
        return cmap.table.format[unicode.value]
    }
    
    func glyph(with unicode: UnicodeScalar, _ uvs: UnicodeScalar) -> Int? {
        if let result = cmap.uvs?.mapping(unicode.value, uvs.value) {
            switch result {
            case .none: return nil
            case .default: return self.glyph(with: unicode)
            case let .glyph(id): return Int(id)
            }
        }
        return nil
    }
    
    func substitution(glyphs: [Int], layout: Font.LayoutSetting, features: [FontFeature: Int]) -> [Int] {
        
        if let morx = morx {
            
            var _features: [SFNTMORX.FeatureSetting] = []
            
            for (feature, value) in features {
                
                guard let feature = feature.base as? AATFontFeatureBase else { continue }
                guard let value = UInt16(exactly: value) else { continue }
                
                if let setting = feature.setting {
                    
                    switch value {
                    case 0: _features.append(SFNTMORX.FeatureSetting(type: feature.feature, setting: setting | 1))
                    case 1: _features.append(SFNTMORX.FeatureSetting(type: feature.feature, setting: setting & ~1))
                    default: break
                    }
                    
                } else {
                    
                    _features.append(SFNTMORX.FeatureSetting(type: feature.feature, setting: value))
                }
            }
            
            return morx.substitution(glyphs: glyphs, numberOfGlyphs: numberOfGlyphs, layout: layout, features: Set(_features))
        }
        
        return glyphs
    }
}

struct AATFontFeatureBase: FontFeatureBase, Hashable {
    
    var feature: UInt16
    var setting: UInt16?
    
    var name: String?
    var settingNames: [Int: String]
    
    var defaultSetting: Int
    var availableSettings: Set<Int>
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(feature)
        hasher.combine(setting)
    }
    
    static func ==(lhs: AATFontFeatureBase, rhs: AATFontFeatureBase) -> Bool {
        return lhs.feature == rhs.feature && lhs.setting == rhs.setting
    }
    
    var description: String {
        return name ?? "unkonwn"
    }
    
    func name(for setting: Int) -> String? {
        return settingNames[setting]
    }
}

extension SFNTFontFace {
    
    func availableFeatures() -> Set<FontFeature> {
        
        if let feat = feat {
            
            var result: [AATFontFeatureBase] = []
            
            for feature in feat {
                
                guard let feature = feature else { continue }
                
                if feature.isExclusive {
                    
                    let name = queryName(Int(feature.nameIndex))
                    let defaultSetting = feature[feature.defaultSetting]?.setting
                    
                    var settingNames: [Int: String] = [:]
                    var availableSettings: [Int] = []
                    
                    for setting in feature {
                        
                        guard let setting = setting else { continue }
                        
                        availableSettings.append(Int(setting.setting))
                        settingNames[Int(setting.setting)] = queryName(Int(setting.nameIndex))
                    }
                    
                    result.append(AATFontFeatureBase(
                        feature: UInt16(feature.feature),
                        setting: nil,
                        name: name,
                        settingNames: settingNames,
                        defaultSetting: defaultSetting.map { Int($0) } ?? 0,
                        availableSettings: Set(availableSettings))
                    )
                    
                } else {
                    
                    for setting in feature {
                        
                        guard let setting = setting else { continue }
                        
                        let name = queryName(Int(setting.nameIndex))
                        
                        result.append(AATFontFeatureBase(
                            feature: UInt16(feature.feature),
                            setting: UInt16(setting.setting),
                            name: name,
                            settingNames: [0: "Disable", 1: "Enable"],
                            defaultSetting: 0,
                            availableSettings: [0, 1])
                        )
                    }
                }
            }
            
            return Set(result.map(FontFeature.init))
        }
        
        return []
    }
}

extension SFNTFontFace {
    
    private struct Metric {
        
        var advance: BEUInt16
        var bearing: BEInt16
        
        func _font_metric() -> Font.Metric {
            return Font.Metric(advance: Double(advance), bearing: Double(bearing))
        }
    }
    
    func metric(glyph: Int) -> Font.Metric {
        let hMetricCount = Int(hhea.numOfLongHorMetrics)
        return hmtx.withUnsafeBytes { $0.bindMemory(to: Metric.self)[glyph < hMetricCount ? glyph : hMetricCount - 1]._font_metric() }
    }
    
    func verticalMetric(glyph: Int) -> Font.Metric {
        if let vhea = self.vhea, let vmtx = self.vmtx {
            let vMetricCount = Int(vhea.numOfLongVerMetrics)
            return vmtx.withUnsafeBytes { $0.bindMemory(to: Metric.self)[glyph < vMetricCount ? glyph : vMetricCount - 1]._font_metric() }
        }
        return Font.Metric(advance: 0, bearing: 0)
    }
}

extension SFNTFontFace {
    
    var isVertical: Bool {
        return self.vhea != nil && self.vmtx != nil
    }
    
    var ascender: Double {
        return Double(hhea.ascent)
    }
    var descender: Double {
        return Double(hhea.descent)
    }
    var lineGap: Double {
        return Double(hhea.lineGap)
    }
    
    var verticalAscender: Double? {
        return (vhea?.vertTypoAscender).map(Double.init)
    }
    var verticalDescender: Double? {
        return (vhea?.vertTypoDescender).map(Double.init)
    }
    var verticalLineGap: Double? {
        return (vhea?.vertTypoLineGap).map(Double.init)
    }
    
    var unitsPerEm: Double {
        return Double(head.unitsPerEm)
    }
    
    var boundingRectForFont: Rect {
        let minX = Double(head.xMin)
        let minY = Double(head.yMin)
        let maxX = Double(head.xMax)
        let maxY = Double(head.yMax)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var italicAngle: Double {
        return post.italicAngle.representingValue
    }
    var weight: Int? {
        return (os2?.usWeightClass).map(Int.init)
    }
    var stretch: Int? {
        return (os2?.usWidthClass).map(Int.init)
    }
    var xHeight: Double? {
        return (os2?.sxHeight).map(Double.init)
    }
    var capHeight: Double? {
        return (os2?.sCapHeight).map(Double.init)
    }
    
    var familyClass: Font.FamilyClass? {
        switch Int(os2?.sFamilyClass ?? 0) >> 8 {
        case 1: return .oldStyleSerifs
        case 2: return .transitionalSerifs
        case 3: return .modernSerifs
        case 4: return .clarendonSerifs
        case 5: return .slabSerifs
        case 7: return .freeformSerifs
        case 8: return .sansSerif
        case 9: return .ornamentals
        case 10: return .scripts
        case 12: return .symbolic
        default: return nil
        }
    }
    
    var isFixedPitch: Bool {
        return post.isFixedPitch != 0
    }
    var isItalic: Bool {
        return head.macStyle & 2 != 0
    }
    var isBold: Bool {
        return head.macStyle & 1 != 0
    }
    var isExpanded: Bool {
        return head.macStyle & 64 != 0
    }
    var isCondensed: Bool {
        return head.macStyle & 32 != 0
    }
    
    var strikeoutPosition: Double? {
        return (os2?.yStrikeoutPosition).map(Double.init)
    }
    var strikeoutThickness: Double? {
        return (os2?.yStrikeoutSize).map(Double.init)
    }
    
    var underlinePosition: Double {
        return Double(post.underlinePosition)
    }
    var underlineThickness: Double {
        return Double(post.underlineThickness)
    }
}

extension SFNTFontFace {
    
    func queryName(_ id: Int) -> String? {
        
        if let macOSRoman = name.record.firstIndex(where: { $0.platform.platform == 1 && $0.platform.specific == 0 && $0.name == id }) {
            return self.name[macOSRoman]
        }
        if let unicode = name.record.firstIndex(where: { $0.platform.platform == 0 && $0.name == id }) {
            return self.name[unicode]
        }
        return nil
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

