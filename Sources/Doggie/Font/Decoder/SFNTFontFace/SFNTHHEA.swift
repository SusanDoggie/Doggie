//
//  SFNTHHEA.swift
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

struct SFNTHHEA : DataDecodable {
    
    var version: Fixed16Number<BEInt32>
    var ascent: BEInt16
    var descent: BEInt16
    var lineGap: BEInt16
    var advanceWidthMax: BEUInt16
    var minLeftSideBearing: BEInt16
    var minRightSideBearing: BEInt16
    var xMaxExtent: BEInt16
    var caretSlopeRise: BEInt16
    var caretSlopeRun: BEInt16
    var caretOffset: BEInt16
    var reserved1: BEInt16
    var reserved2: BEInt16
    var reserved3: BEInt16
    var reserved4: BEInt16
    var metricDataFormat: BEInt16
    var numOfLongHorMetrics: BEUInt16
    
    init(from data: inout Data) throws {
        self.version = try data.decode(Fixed16Number<BEInt32>.self)
        self.ascent = try data.decode(BEInt16.self)
        self.descent = try data.decode(BEInt16.self)
        self.lineGap = try data.decode(BEInt16.self)
        self.advanceWidthMax = try data.decode(BEUInt16.self)
        self.minLeftSideBearing = try data.decode(BEInt16.self)
        self.minRightSideBearing = try data.decode(BEInt16.self)
        self.xMaxExtent = try data.decode(BEInt16.self)
        self.caretSlopeRise = try data.decode(BEInt16.self)
        self.caretSlopeRun = try data.decode(BEInt16.self)
        self.caretOffset = try data.decode(BEInt16.self)
        self.reserved1 = try data.decode(BEInt16.self)
        self.reserved2 = try data.decode(BEInt16.self)
        self.reserved3 = try data.decode(BEInt16.self)
        self.reserved4 = try data.decode(BEInt16.self)
        self.metricDataFormat = try data.decode(BEInt16.self)
        self.numOfLongHorMetrics = try data.decode(BEUInt16.self)
    }
}

