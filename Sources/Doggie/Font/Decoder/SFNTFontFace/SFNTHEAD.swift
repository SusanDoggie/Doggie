//
//  SFNTHEAD.swift
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

struct SFNTHEAD : DataDecodable {
    
    var version: Fixed16Number<BEInt32>
    var fontRevision: Fixed16Number<BEInt32>
    var checkSumAdjustment: BEUInt32
    var magicNumber: BEUInt32
    var flags: BEUInt16
    var unitsPerEm: BEUInt16
    var created: BEInt64
    var modified: BEInt64
    var xMin: BEInt16
    var yMin: BEInt16
    var xMax: BEInt16
    var yMax: BEInt16
    var macStyle: BEUInt16
    var lowestRecPPEM: BEUInt16
    var fontDirectionHint: BEInt16
    var indexToLocFormat: BEInt16
    var glyphDataFormat: BEInt16
    
    init(from data: inout Data) throws {
        self.version = try data.decode(Fixed16Number<BEInt32>.self)
        self.fontRevision = try data.decode(Fixed16Number<BEInt32>.self)
        self.checkSumAdjustment = try data.decode(BEUInt32.self)
        self.magicNumber = try data.decode(BEUInt32.self)
        self.flags = try data.decode(BEUInt16.self)
        self.unitsPerEm = try data.decode(BEUInt16.self)
        self.created = try data.decode(BEInt64.self)
        self.modified = try data.decode(BEInt64.self)
        self.xMin = try data.decode(BEInt16.self)
        self.yMin = try data.decode(BEInt16.self)
        self.xMax = try data.decode(BEInt16.self)
        self.yMax = try data.decode(BEInt16.self)
        self.macStyle = try data.decode(BEUInt16.self)
        self.lowestRecPPEM = try data.decode(BEUInt16.self)
        self.fontDirectionHint = try data.decode(BEInt16.self)
        self.indexToLocFormat = try data.decode(BEInt16.self)
        self.glyphDataFormat = try data.decode(BEInt16.self)
    }
}
