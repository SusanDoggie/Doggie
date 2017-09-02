//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let data = try Data(contentsOf: URL(fileURLWithPath: "/Library/Fonts/Arial.ttf"))

let collection = try FontCollection(data: data)

if let font = collection.first?.with(size: 14) {
    
    font.fontName
    font.displayName
    font.uniqueName
    font.familyName
    font.faceName
    
    font.designer
    
    font.version
    
    font.trademark
    font.manufacturer
    font.license
    font.copyright
    
    font.ascender
    font.descender
    font.lineGap
    
    font.verticalAscender
    font.verticalDescender
    font.verticalLineGap
    
    font.unitsPerEm
    
    font.boundingRectForFont
    
    font.italicAngle
    font.isFixedPitch
    
    font.underlinePosition
    font.underlineThickness
    
    let glyph = font.glyph(with: "a")
    
    font.boundary(forGlyph: glyph)
    
    font.shape(forGlyph: glyph).encode()
    
    font.shape(forGlyph: glyph)
    
}
