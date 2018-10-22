//
//  Font.swift
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

public protocol FontFaceBase {
    
    var isVariationSelectors: Bool { get }
    var isGraphic: Bool { get }
    
    func shape(forGlyph glyph: Int) -> [Shape.Component]
    func graphic(forGlyph glyph: Int) -> [Font.Graphic]?
    
    func glyph(with unicode: UnicodeScalar) -> Int
    func glyph(with unicode: UnicodeScalar, _ uvs: UnicodeScalar) -> Int?
    func metric(glyph: Int) -> Font.Metric
    func verticalMetric(glyph: Int) -> Font.Metric
    
    var isVertical: Bool { get }
    
    var numberOfGlyphs: Int { get }
    
    var coveredCharacterSet: CharacterSet { get }
    
    var ascender: Double { get }
    var descender: Double { get }
    var lineGap: Double { get }
    
    var verticalAscender: Double? { get }
    var verticalDescender: Double? { get }
    var verticalLineGap: Double? { get }
    
    var unitsPerEm: Double { get }
    var boundingRectForFont: Rect { get }
    
    var italicAngle: Double { get }
    var weight: Int? { get }
    var stretch: Int? { get }
    var xHeight: Double? { get }
    var capHeight: Double? { get }
    var isFixedPitch: Bool { get }
    var isItalic: Bool { get }
    var isBold: Bool { get }
    var isExpanded: Bool { get }
    var isCondensed: Bool { get }
    var strikeoutPosition: Double? { get }
    var strikeoutThickness: Double? { get }
    var underlinePosition: Double { get }
    var underlineThickness: Double { get }
    
    var fontName: String? { get }
    var displayName: String? { get }
    var uniqueName: String? { get }
    var familyName: String? { get }
    var faceName: String? { get }
    
    var familyClass: Font.FamilyClass? { get }
    
    var designer: String? { get }
    
    var version: String? { get }
    
    var trademark: String? { get }
    var manufacturer: String? { get }
    var license: String? { get }
    var copyright: String? { get }
}

public struct Font {
    
    private let details: Details
    public let base: FontFaceBase
    public var pointSize: Double
    
    private let cache: Cache
    
    public init?(_ base: FontFaceBase) {
        guard base.numberOfGlyphs > 0 else { return nil }
        guard let details = Details(base) else { return nil }
        self.details = details
        self.base = base
        self.pointSize = 0
        self.cache = Cache()
    }
    
    public init(font: Font, size: Double) {
        self.details = font.details
        self.base = font.base
        self.pointSize = size
        self.cache = font.cache
    }
}

extension Font {
    
    private class Cache {
        
        let lck = SDLock()
        
        var coveredCharacterSet: CharacterSet?
        var glyphs: [Int: [Shape.Component]] = [:]
    }
}

extension Font {
    
    private struct Details {
        
        let fontName: String
        let displayName: String?
        let uniqueName: String?
        let familyName: String?
        let faceName: String?
        let familyClass: FamilyClass?
        
        init?(_ base: FontFaceBase) {
            guard let fontName = base.fontName else { return nil }
            self.fontName = fontName
            self.displayName = base.displayName
            self.uniqueName = base.uniqueName
            self.familyName = base.familyName
            self.faceName = base.faceName
            self.familyClass = base.familyClass
        }
    }
}

extension Font {
    
    public enum FamilyClass {
        
        case oldStyleSerifs
        case transitionalSerifs
        case modernSerifs
        case clarendonSerifs
        case slabSerifs
        case freeformSerifs
        case sansSerif
        case ornamentals
        case scripts
        case symbolic
    }
}

extension Font : CustomStringConvertible {
    
    public var description: String {
        return "Font(name: \(self.fontName), pointSize: \(self.pointSize))"
    }
}

extension Font {
    
    public func with(size pointSize: Double) -> Font {
        return Font(font: self, size: pointSize)
    }
}

extension Font {
    
    public struct GraphicType: SignatureProtocol {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let jpeg: GraphicType    = "jpg "
        public static let png: GraphicType     = "png "
        public static let tiff: GraphicType    = "tiff"
        public static let pdf: GraphicType     = "pdf "
        public static let svg: GraphicType     = "svg "
    }
    
    public struct Graphic {
        
        public var type: GraphicType
        
        public var unitsPerEm: Double
        public var resolution: Double
        public var origin: Point
        
        public var data: Data
    }
    
    private func _shape(glyph: Int) -> [Shape.Component] {
        let glyph = 0..<base.numberOfGlyphs ~= glyph ? glyph : 0
        return cache.lck.synchronized {
            if cache.glyphs[glyph] == nil {
                var component = base.shape(forGlyph: glyph).filter { $0.count != 0 }
                component.makeContiguousBuffer()
                cache.glyphs[glyph] = component
            }
            return cache.glyphs[glyph]!
        }
    }
    
    public func shape(forGlyph glyph: Int) -> Shape {
        return Shape(self._shape(glyph: glyph).map { $0 * SDTransform.scale(_pointScale) })
    }
    
    public func graphic(forGlyph glyph: Int) -> [Font.Graphic]? {
        let glyph = 0..<base.numberOfGlyphs ~= glyph ? glyph : 0
        return base.graphic(forGlyph: glyph)
    }
}

extension Font {
    
    public struct Metric {
        
        public var advance: Double
        public var bearing: Double
    }
    
    public var numberOfGlyphs: Int {
        return base.numberOfGlyphs
    }
    
    public func glyph(with unicode: UnicodeScalar) -> Int {
        return base.glyph(with: unicode)
    }
    
    public func glyphs<S: Sequence>(with unicodes: S) -> [Int] where S.Element == UnicodeScalar {
        
        guard base.isVariationSelectors else { return unicodes.map { base.glyph(with: $0) } }
        
        var last: UnicodeScalar?
        var result: [Int] = []
        result.reserveCapacity(unicodes.underestimatedCount)
        
        for unicode in unicodes {
            
            if let _last = last {
                if let glyph = base.glyph(with: _last, unicode) {
                    result.append(glyph)
                    last = nil
                } else {
                    result.append(base.glyph(with: _last))
                    last = unicode
                }
            } else {
                last = unicode
            }
        }
        
        if let last = last {
            result.append(base.glyph(with: last))
        }
        
        return result
    }
    
    public func metric(forGlyph glyph: Int) -> Metric {
        let glyph = 0..<base.numberOfGlyphs ~= glyph ? glyph : 0
        let metric = base.metric(glyph: glyph)
        return Metric(advance: metric.advance * _pointScale, bearing: metric.bearing * _pointScale)
    }
    
    public func verticalMetric(forGlyph glyph: Int) -> Metric {
        let glyph = 0..<base.numberOfGlyphs ~= glyph ? glyph : 0
        let metric = base.verticalMetric(glyph: glyph)
        return Metric(advance: metric.advance * _pointScale, bearing: metric.bearing * _pointScale)
    }
    
    public func advance(forGlyph glyph: Int) -> Double {
        return metric(forGlyph: glyph).advance
    }
    
    public func verticalAdvance(forGlyph glyph: Int) -> Double {
        return verticalMetric(forGlyph: glyph).advance
    }
    
    public func bearing(forGlyph glyph: Int) -> Double {
        return metric(forGlyph: glyph).bearing
    }
    
    public func verticalBearing(forGlyph glyph: Int) -> Double {
        return verticalMetric(forGlyph: glyph).bearing
    }
    
    public var coveredCharacterSet: CharacterSet {
        return cache.lck.synchronized {
            if cache.coveredCharacterSet == nil {
                cache.coveredCharacterSet = base.coveredCharacterSet
            }
            return cache.coveredCharacterSet!
        }
    }
}

extension Font {
    
    private var _pointScale: Double {
        return pointSize / unitsPerEm
    }
    
    public var isVariationSelectors: Bool {
        return base.isVariationSelectors
    }
    
    public var isGraphic: Bool {
        return base.isGraphic
    }
    
    public var ascender: Double {
        return base.ascender * _pointScale
    }
    public var descender: Double {
        return base.descender * _pointScale
    }
    public var lineGap: Double {
        return base.lineGap * _pointScale
    }
    
    public var verticalAscender: Double? {
        return base.verticalAscender.map { $0 * _pointScale }
    }
    public var verticalDescender: Double? {
        return base.verticalDescender.map { $0 * _pointScale }
    }
    public var verticalLineGap: Double? {
        return base.verticalLineGap.map { $0 * _pointScale }
    }
    
    public var unitsPerEm: Double {
        return base.unitsPerEm
    }
    
    public var boundingRectForFont: Rect {
        let _pointScale = self._pointScale
        let bound = base.boundingRectForFont
        return bound * _pointScale
    }
    
    public var italicAngle: Double {
        return base.italicAngle
    }
    public var weight: Int? {
        return base.weight
    }
    public var stretch: Int? {
        return base.stretch
    }
    public var xHeight: Double? {
        return base.xHeight.map { $0 * _pointScale }
    }
    public var capHeight: Double? {
        return base.capHeight.map { $0 * _pointScale }
    }
    
    public var isVertical: Bool {
        return base.isVertical
    }
    
    public var isFixedPitch: Bool {
        return base.isFixedPitch
    }
    public var isItalic: Bool {
        return base.isItalic
    }
    public var isBold: Bool {
        return base.isBold
    }
    public var isExpanded: Bool {
        return base.isExpanded
    }
    public var isCondensed: Bool {
        return base.isCondensed
    }
    public var strikeoutPosition: Double? {
        return base.strikeoutPosition.map { $0 * _pointScale }
    }
    public var strikeoutThickness: Double? {
        return base.strikeoutThickness.map { $0 * _pointScale }
    }
    public var underlinePosition: Double {
        return base.underlinePosition * _pointScale
    }
    public var underlineThickness: Double {
        return base.underlineThickness * _pointScale
    }
}

extension Font {
    
    public var fontName: String {
        return details.fontName
    }
    public var displayName: String? {
        return details.displayName
    }
    public var uniqueName: String? {
        return details.uniqueName
    }
    public var familyName: String? {
        return details.familyName
    }
    public var faceName: String? {
        return details.faceName
    }
    
    public var familyClass: FamilyClass? {
        return details.familyClass
    }
    
    public var designer: String? {
        return base.designer
    }
    
    public var version: String? {
        return base.version
    }
    
    public var trademark: String? {
        return base.trademark
    }
    public var manufacturer: String? {
        return base.manufacturer
    }
    public var license: String? {
        return base.license
    }
    public var copyright: String? {
        return base.copyright
    }
    
}
