//
//  SFNTPOST.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

struct SFNTPOST : ByteDecodable {
    
    var format: Fixed16Number<BEInt32>
    var italicAngle: Fixed16Number<BEInt32>
    var underlinePosition: BEInt16
    var underlineThickness: BEInt16
    var isFixedPitch: BEUInt32
    var minMemType42: BEUInt32
    var maxMemType42: BEUInt32
    var minMemType1: BEUInt32
    var maxMemType1: BEUInt32
    
    init(from data: inout Data) throws {
        self.format = try data.decode(Fixed16Number<BEInt32>.self)
        self.italicAngle = try data.decode(Fixed16Number<BEInt32>.self)
        self.underlinePosition = try data.decode(BEInt16.self)
        self.underlineThickness = try data.decode(BEInt16.self)
        self.isFixedPitch = try data.decode(BEUInt32.self)
        self.minMemType42 = try data.decode(BEUInt32.self)
        self.maxMemType42 = try data.decode(BEUInt32.self)
        self.minMemType1 = try data.decode(BEUInt32.self)
        self.maxMemType1 = try data.decode(BEUInt32.self)
    }
}
