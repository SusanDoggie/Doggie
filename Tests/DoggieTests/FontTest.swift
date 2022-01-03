//
//  FontTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Doggie
import XCTest

class FontTest: XCTestCase {
    
    func testLoadingFont() {
        
        let availableFonts = FontCollection.availableFonts
        
        print("Fonts:", availableFonts.count)
        for font in availableFonts {
            print(font.fontName)
        }
        
        for font in availableFonts {
            
            let font = font.with(size: 64)
            
            let string = "Doggie\u{0301}".precomposedStringWithCanonicalMapping
            
            let glyphs = font.glyphs(with: string)
            let advances = glyphs.map { font.advance(forGlyph: $0) }.reductions(0, +)
            
            var shape = Shape()
            
            for (advance, glyph) in zip(advances, glyphs) {
                var outline = font.shape(forGlyph: glyph)
                outline.center.x += advance
                shape.append(contentsOf: outline.identity)
            }
        }
        
    }
    
}
