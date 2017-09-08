//
//  CFFCharStrings.swift
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

extension CFFFontFace {
    
    func fontDICT(glyph: UInt16) -> CFFFontDICT {
        guard let fdSelect = self.fdSelect, let fontDICTArray = self.fontDICTArray else { return self.DICT }
        guard let index = fdSelect.fdIndex(glyph: glyph), index < fontDICTArray.count else { return self.DICT }
        return fontDICTArray[Int(index)]
    }
    
    func subroutineBias(_ subroutine: CFFINDEX) -> Int {
        if self.charstringType == 1 {
            return 0
        } else if subroutine.count < 1240 {
            return 107
        } else if subroutine.count < 33900 {
            return 1131
        } else {
            return 32768
        }
    }
    
    func shape(glyph: Int) -> [Shape.Component] {
        
        guard glyph < charStrings.count else { return [] }
        
        let charString = charStrings[glyph]
        let fontDICT = self.fontDICT(glyph: UInt16(glyph))
        let subroutine = self.subroutine
        
        if let pDICT = fontDICT.pDICT {
            
            let pSubroutine = fontDICT.pSubroutine
            let subroutineBias = self.subroutineBias(subroutine)
            let pSubroutineBias = pSubroutine.map { self.subroutineBias($0) }
            
            print("fontDICT:", fontDICT)
            print("subroutine:", subroutine)
            print("pDICT:", pDICT)
            print("pSubroutine:", pSubroutine)
            print("subroutineBias:", subroutineBias)
            print("pSubroutineBias:", pSubroutineBias)
        }
        
        return []
    }
}
