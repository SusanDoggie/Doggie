//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let t = Date()

let availableFonts = FontCollection.availableFonts

t.timeIntervalSinceNow

let Arial = availableFonts.filter { $0.familyName == "Arial" }.sorted { $0.fontName }

for font in Arial {
    
    let font = font.with(size: 64)
    
    let string = "Doggie\u{0301}".precomposedStringWithCanonicalMapping
    
    let glyphs = font.glyphs(with: string.unicodeScalars)
    let advances = glyphs.map { font.advance(forGlyph: $0) }.scan(0, +)
    
    var shape = Shape()
    
    for (advance, glyph) in zip(advances, glyphs) {
        var outline = font.shape(forGlyph: glyph)
        outline.center.x += advance
        shape.append(contentsOf: outline.identity)
    }
    
    shape
}

let PingFang = availableFonts.filter { $0.familyName == "PingFang HK" }.sorted { $0.fontName }

for font in PingFang {
    
    let font = font.with(size: 64)
    
    let string = "Doggie\u{0301}".precomposedStringWithCompatibilityMapping
    
    let glyphs = font.glyphs(with: string.unicodeScalars)
    let advances = glyphs.map { font.advance(forGlyph: $0) }.scan(0, +)
    
    var shape = Shape()
    
    for (advance, glyph) in zip(advances, glyphs) {
        var outline = font.shape(forGlyph: glyph)
        outline.center.x += advance
        shape.append(contentsOf: outline.identity)
    }
    
    shape
}
