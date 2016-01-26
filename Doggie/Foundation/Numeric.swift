//
//  Numeric.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

private let _bits_reverse_table: [UInt8] = [0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0, 0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8, 0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4, 0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC, 0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2, 0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA, 0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6, 0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE, 0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1, 0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9, 0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5, 0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD, 0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3, 0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB, 0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7, 0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF]

public extension UInt64 {
    
    var reverse: UInt64 {
        let _a = UInt64(_bits_reverse_table[Int(self & 0xFF)]) << 56
        let _b = UInt64(_bits_reverse_table[Int((self >> 8) & 0xFF)]) << 48
        let _c = UInt64(_bits_reverse_table[Int((self >> 16) & 0xFF)]) << 40
        let _d = UInt64(_bits_reverse_table[Int((self >> 24) & 0xFF)]) << 32
        let _e = UInt64(_bits_reverse_table[Int((self >> 32) & 0xFF)]) << 24
        let _f = UInt64(_bits_reverse_table[Int((self >> 40) & 0xFF)]) << 16
        let _g = UInt64(_bits_reverse_table[Int((self >> 48) & 0xFF)]) << 8
        let _h = UInt64(_bits_reverse_table[Int((self >> 56) & 0xFF)])
        return _a | _b | _c | _d | _e | _f | _g | _h
    }
}
public extension UInt32 {
    
    var reverse: UInt32 {
        let _a = UInt32(_bits_reverse_table[Int(self & 0xFF)]) << 24
        let _b = UInt32(_bits_reverse_table[Int((self >> 8) & 0xFF)]) << 16
        let _c = UInt32(_bits_reverse_table[Int((self >> 16) & 0xFF)]) << 8
        let _d = UInt32(_bits_reverse_table[Int((self >> 24) & 0xFF)])
        return _a | _b | _c | _d
    }
}
public extension UInt16 {
    
    var reverse: UInt16 {
        let _a = UInt16(_bits_reverse_table[Int(self & 0xFF)]) << 8
        let _b = UInt16(_bits_reverse_table[Int((self >> 8) & 0xFF)])
        return _a | _b
    }
}
public extension UInt8 {
    
    var reverse: UInt8 {
        return _bits_reverse_table[Int(self)]
    }
}
public extension Int64 {
    
    var reverse: Int64 {
        return Int64(bitPattern: UInt64(bitPattern: self).reverse)
    }
}
public extension Int32 {
    
    var reverse: Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self).reverse)
    }
}
public extension Int16 {
    
    var reverse: Int16 {
        return Int16(bitPattern: UInt16(bitPattern: self).reverse)
    }
}
public extension Int8 {
    
    var reverse: Int8 {
        return Int8(bitPattern: UInt8(bitPattern: self).reverse)
    }
}

@warn_unused_result
public func log2(x: Int64) -> Int64 {
    return Int64(flsll(x)) - 1
}
@warn_unused_result
public func log2(x: Int32) -> Int32 {
    return fls(x) - 1
}
@warn_unused_result
public func log2(x: Int16) -> Int16 {
    return Int16(truncatingBitPattern: log2(Int32(x) & 0xFFFF))
}
@warn_unused_result
public func log2(x: Int8) -> Int8 {
    return Int8(truncatingBitPattern: log2(Int32(x) & 0xFF))
}
@warn_unused_result
public func log2(x: Int) -> Int {
    return Int(flsl(x)) - 1
}
@warn_unused_result
public func log2(x: UInt64) -> UInt64 {
    return UInt64(bitPattern: log2(Int64(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt32) -> UInt32 {
    return UInt32(bitPattern: log2(Int32(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt16) -> UInt16 {
    return UInt16(bitPattern: log2(Int16(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt8) -> UInt8 {
    return UInt8(bitPattern: log2(Int8(bitPattern: x)))
}
@warn_unused_result
public func log2(x: UInt) -> UInt {
    return UInt(bitPattern: log2(Int(bitPattern: x)))
}

public extension UInt64 {
    
    var hibit: UInt64 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt32 {
    
    var hibit: UInt32 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt16 {
    
    var hibit: UInt16 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt8 {
    
    var hibit: UInt8 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension UInt {
    
    var hibit: UInt {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int64 {
    
    var hibit: Int64 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int32 {
    
    var hibit: Int32 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int16 {
    
    var hibit: Int16 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int8 {
    
    var hibit: Int8 {
        return self == 0 ? 0 : 1 << log2(self)
    }
}
public extension Int {
    
    var hibit: Int {
        return self == 0 ? 0 : 1 << log2(self)
    }
}

extension IntegerType {
    
    public var isPower2 : Bool {
        return 0 < self && self & (self &- 1) == 0
    }
    
    @warn_unused_result
    public func align(s: Self) -> Self {
        assert(s.isPower2, "alignment is not power of 2.")
        let MASK = s - 1
        return (self + MASK) & ~MASK
    }
}
