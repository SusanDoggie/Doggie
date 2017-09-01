//
//  CFFFontFace.swift
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

struct CFFFontFace {
    
    var name: String
    var DICT: CFFDICT
    var string: CFFINDEX
    var subroutine: CFFINDEX
    
    var pDICT: CFFDICT?
    var charstringType: Int
    var charStrings: CFFINDEX
    
    init(_ data: Data, _ name: String, _ DICT: CFFDICT, _ string: CFFINDEX, _ subroutine: CFFINDEX) throws {
        self.name = name
        self.DICT = DICT
        self.string = string
        self.subroutine = subroutine
        
        self.charstringType = DICT.charstringType
        guard let charStringsOffset = DICT.charStringsOffset else { throw FontCollection.Error.InvalidFormat("Invalid CFF format.") }
        self.charStrings = try CFFINDEX(data.dropFirst(charStringsOffset))
        
        if let range = DICT.pDICTRange {
            let _pDICT: Data = data.dropFirst(range.lowerBound).prefix(range.count)
            guard _pDICT.count == range.count else { throw DataDecodeError.endOfData }
            self.pDICT = try CFFDICT(_pDICT)
        }
    }
}
