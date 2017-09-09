//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let Arial = try FontCollection(data: try Data(contentsOf: URL(fileURLWithPath: "/Library/Fonts/Arial.ttf")))

if let font = Arial.first?.with(size: 64) {
    
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

let PingFang = try FontCollection(data: try Data(contentsOf: URL(fileURLWithPath: "/System/Library/Fonts/PingFang.ttc")))

if let font = PingFang.first?.with(size: 64) {
    
    let string = "中文字".precomposedStringWithCompatibilityMapping
    
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

