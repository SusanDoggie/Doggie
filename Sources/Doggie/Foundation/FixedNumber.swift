//
//  FixedNumber.swift
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

struct Fixed8Number<BitPattern : FixedWidthInteger & ByteCodable> : BinaryFixedPoint, ByteCodable {
    
    typealias RepresentingValue = Double
    
    var bitPattern: BitPattern
    
    @_transparent
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @_transparent
    static var fractionBitCount: Int {
        return 8
    }
}

struct Fixed14Number<BitPattern : FixedWidthInteger & ByteCodable> : BinaryFixedPoint, ByteCodable {
    
    typealias RepresentingValue = Double
    
    var bitPattern: BitPattern
    
    @_transparent
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @_transparent
    static var fractionBitCount: Int {
        return 14
    }
}

struct Fixed15Number<BitPattern : FixedWidthInteger & ByteCodable> : BinaryFixedPoint, ByteCodable {
    
    typealias RepresentingValue = Double
    
    var bitPattern: BitPattern
    
    @_transparent
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @_transparent
    static var fractionBitCount: Int {
        return 15
    }
}

struct Fixed16Number<BitPattern : FixedWidthInteger & ByteCodable> : BinaryFixedPoint, ByteCodable {
    
    typealias RepresentingValue = Double
    
    var bitPattern: BitPattern
    
    @_transparent
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @_transparent
    static var fractionBitCount: Int {
        return 16
    }
}

struct Fixed30Number<BitPattern : FixedWidthInteger & ByteCodable> : BinaryFixedPoint, ByteCodable {
    
    typealias RepresentingValue = Double
    
    var bitPattern: BitPattern
    
    @_transparent
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @_transparent
    static var fractionBitCount: Int {
        return 30
    }
}

