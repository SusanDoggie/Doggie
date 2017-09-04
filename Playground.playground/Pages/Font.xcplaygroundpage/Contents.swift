//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let data = try Data(contentsOf: URL(fileURLWithPath: "/Library/Fonts/Arial.ttf"))

let collection = try FontCollection(data: data)

if let font = collection.first?.with(size: 64) {
    
    let string = "Doggie\u{0301}".precomposedStringWithCompatibilityMapping
    
    let glyphs = string.unicodeScalars.map { font.glyph(with: $0) }
    let advances = glyphs.map { font.advanceWidth(forGlyph: $0) }.scan(0, +)
    
    var shape = Shape()
    
    for (advance, glyph) in zip(advances, glyphs) {
        var outline = font.shape(forGlyph: glyph)
        outline.center.x += advance
        shape.append(contentsOf: outline.identity)
    }
    
    shape
}
