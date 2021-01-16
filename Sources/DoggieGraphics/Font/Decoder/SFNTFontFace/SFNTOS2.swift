//
//  SFNTOS2.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

struct SFNTOS2: ByteDecodable {
    
    var version: BEUInt16
    var xAvgCharWidth: BEInt16
    var usWeightClass: BEUInt16
    var usWidthClass: BEUInt16
    var fsType: BEInt16
    var ySubscriptXSize: BEInt16
    var ySubscriptYSize: BEInt16
    var ySubscriptXOffset: BEInt16
    var ySubscriptYOffset: BEInt16
    var ySuperscriptXSize: BEInt16
    var ySuperscriptYSize: BEInt16
    var ySuperscriptXOffset: BEInt16
    var ySuperscriptYOffset: BEInt16
    var yStrikeoutSize: BEInt16
    var yStrikeoutPosition: BEInt16
    var sFamilyClass: BEInt16
    var panose: PANOSE
    var ulCharRange: (BEUInt32, BEUInt32, BEUInt32, BEUInt32)
    var achVendID: Signature<BEUInt32>
    var fsSelection: BEUInt16
    var fsFirstCharIndex: BEUInt16
    var fsLastCharIndex: BEUInt16
    
    var sTypoAscender: BEInt16?
    var sTypoDescender: BEInt16?
    var sTypoLineGap: BEInt16?
    var usWinAscent: BEUInt16?
    var usWinDescent: BEUInt16?
    var ulCodePageRange1: BEUInt32?
    var ulCodePageRange2: BEUInt32?
    var sxHeight: BEInt16?
    var sCapHeight: BEInt16?
    var usDefaultChar: BEUInt16?
    var usBreakChar: BEUInt16?
    var usMaxContext: BEUInt16?
    
    init(from data: inout Data) throws {
        self.version = try data.decode(BEUInt16.self)
        self.xAvgCharWidth = try data.decode(BEInt16.self)
        self.usWeightClass = try data.decode(BEUInt16.self)
        self.usWidthClass = try data.decode(BEUInt16.self)
        self.fsType = try data.decode(BEInt16.self)
        self.ySubscriptXSize = try data.decode(BEInt16.self)
        self.ySubscriptYSize = try data.decode(BEInt16.self)
        self.ySubscriptXOffset = try data.decode(BEInt16.self)
        self.ySubscriptYOffset = try data.decode(BEInt16.self)
        self.ySuperscriptXSize = try data.decode(BEInt16.self)
        self.ySuperscriptYSize = try data.decode(BEInt16.self)
        self.ySuperscriptXOffset = try data.decode(BEInt16.self)
        self.ySuperscriptYOffset = try data.decode(BEInt16.self)
        self.yStrikeoutSize = try data.decode(BEInt16.self)
        self.yStrikeoutPosition = try data.decode(BEInt16.self)
        self.sFamilyClass = try data.decode(BEInt16.self)
        self.panose = try data.decode(PANOSE.self)
        self.ulCharRange = (try data.decode(BEUInt32.self), try data.decode(BEUInt32.self), try data.decode(BEUInt32.self), try data.decode(BEUInt32.self))
        self.achVendID = try data.decode(Signature<BEUInt32>.self)
        self.fsSelection = try data.decode(BEUInt16.self)
        self.fsFirstCharIndex = try data.decode(BEUInt16.self)
        self.fsLastCharIndex = try data.decode(BEUInt16.self)
        
        self.sTypoAscender = try? data.decode(BEInt16.self)
        self.sTypoDescender = try? data.decode(BEInt16.self)
        self.sTypoLineGap = try? data.decode(BEInt16.self)
        self.usWinAscent = try? data.decode(BEUInt16.self)
        self.usWinDescent = try? data.decode(BEUInt16.self)
        self.ulCodePageRange1 = try? data.decode(BEUInt32.self)
        self.ulCodePageRange2 = try? data.decode(BEUInt32.self)
        self.sxHeight = try? data.decode(BEInt16.self)
        self.sCapHeight = try? data.decode(BEInt16.self)
        self.usDefaultChar = try? data.decode(BEUInt16.self)
        self.usBreakChar = try? data.decode(BEUInt16.self)
        self.usMaxContext = try? data.decode(BEUInt16.self)
    }
    
    struct PANOSE: ByteDecodable {
        
        var bFamilyType: UInt8
        var bSerifStyle: UInt8
        var bWeight: UInt8
        var bProportion: UInt8
        var bContrast: UInt8
        var bStrokeVariation: UInt8
        var bArmStyle: UInt8
        var bLetterform: UInt8
        var bMidline: UInt8
        var bXHeight: UInt8
        
        init(from data: inout Data) throws {
            self.bFamilyType = try data.decode(UInt8.self)
            self.bSerifStyle = try data.decode(UInt8.self)
            self.bWeight = try data.decode(UInt8.self)
            self.bProportion = try data.decode(UInt8.self)
            self.bContrast = try data.decode(UInt8.self)
            self.bStrokeVariation = try data.decode(UInt8.self)
            self.bArmStyle = try data.decode(UInt8.self)
            self.bLetterform = try data.decode(UInt8.self)
            self.bMidline = try data.decode(UInt8.self)
            self.bXHeight = try data.decode(UInt8.self)
        }
        
    }
}
