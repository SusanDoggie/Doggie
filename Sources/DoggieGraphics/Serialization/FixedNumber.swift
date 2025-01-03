//
//  FixedNumber.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

@frozen
@usableFromInline
struct Fixed8Number<BitPattern: FixedWidthInteger & ByteCodable>: BinaryFixedPoint, ByteCodable {
    
    @usableFromInline
    typealias RepresentingValue = Double
    
    @usableFromInline
    var bitPattern: BitPattern
    
    @inlinable
    @inline(__always)
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    @inline(__always)
    static var fractionBitCount: Int {
        return 8
    }
}

extension Fixed8Number: SignedNumeric where BitPattern: SignedNumeric {
    
}

@frozen
@usableFromInline
struct Fixed14Number<BitPattern: FixedWidthInteger & ByteCodable>: BinaryFixedPoint, ByteCodable {
    
    @usableFromInline
    typealias RepresentingValue = Double
    
    @usableFromInline
    var bitPattern: BitPattern
    
    @inlinable
    @inline(__always)
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    @inline(__always)
    static var fractionBitCount: Int {
        return 14
    }
}

extension Fixed14Number: SignedNumeric where BitPattern: SignedNumeric {
    
}

@frozen
@usableFromInline
struct Fixed16Number<BitPattern: FixedWidthInteger & ByteCodable>: BinaryFixedPoint, ByteCodable {
    
    @usableFromInline
    typealias RepresentingValue = Double
    
    @usableFromInline
    var bitPattern: BitPattern
    
    @inlinable
    @inline(__always)
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    @inline(__always)
    static var fractionBitCount: Int {
        return 16
    }
}

extension Fixed16Number: SignedNumeric where BitPattern: SignedNumeric {
    
}

@frozen
@usableFromInline
struct Fixed30Number<BitPattern: FixedWidthInteger & ByteCodable>: BinaryFixedPoint, ByteCodable {
    
    @usableFromInline
    typealias RepresentingValue = Double
    
    @usableFromInline
    var bitPattern: BitPattern
    
    @inlinable
    @inline(__always)
    init(bitPattern: BitPattern) {
        self.bitPattern = bitPattern
    }
    
    @inlinable
    @inline(__always)
    static var fractionBitCount: Int {
        return 30
    }
}

extension Fixed30Number: SignedNumeric where BitPattern: SignedNumeric {
    
}

