//
//  iccType.swift
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

private func icRoundOffset<T : BinaryFloatingPoint>(_ v: T) -> T {
    
    return v < 0 ? v - 0.5 : v + 0.5
}

extension iccProfile {
    
    public struct S15Fixed16Number : RawRepresentable, Hashable, CustomStringConvertible {
        
        public typealias RawValue = BEInt32
        
        public var rawValue: BEInt32
        
        public init(rawValue: BEInt32) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(rawValue.representingValue) / 65536.0
            }
            set {
                rawValue = BEInt32(newValue.clamped(to: -32768.0...32767.0) * 65536.0)
            }
        }
        
        public var description: String {
            return "\(value)"
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
    }
}

extension iccProfile {
    
    public struct U16Fixed16Number : RawRepresentable, Hashable, CustomStringConvertible {
        
        public typealias RawValue = BEUInt32
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(rawValue.representingValue) / 65536.0
            }
            set {
                rawValue = BEUInt32(newValue.clamped(to: 0...65535.0) * 65536.0)
            }
        }
        
        public var description: String {
            return "\(value)"
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
    }
}

extension iccProfile {
    
    public struct U1Fixed15Number : RawRepresentable, Hashable, CustomStringConvertible {
        
        public typealias RawValue = BEUInt16
        
        public var rawValue: BEUInt16
        
        public init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(rawValue.representingValue) / 32768.0
            }
            set {
                rawValue = BEUInt16(icRoundOffset(newValue.clamped(to: 0...65535.0/32768.0) * 32768.0))
            }
        }
        
        public var description: String {
            return "\(value)"
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
    }
}

extension iccProfile {
    
    public struct U8Fixed8Number : RawRepresentable, Hashable, CustomStringConvertible {
        
        public typealias RawValue = BEUInt16
        
        public var rawValue: BEUInt16
        
        public init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(rawValue.representingValue) / 256.0
            }
            set {
                rawValue = BEUInt16(icRoundOffset(newValue.clamped(to: 0...255.0) * 256.0))
            }
        }
        
        public var description: String {
            return "\(value)"
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
    }
}

extension iccProfile {
    
    public struct DateTimeNumber {
        
        public var year: BEUInt16
        public var month: BEUInt16
        public var day: BEUInt16
        public var hours: BEUInt16
        public var minutes: BEUInt16
        public var seconds: BEUInt16
    }
}

extension iccProfile {
    
    public struct XYZNumber {
        
        public var X: S15Fixed16Number
        public var Y: S15Fixed16Number
        public var Z: S15Fixed16Number
    }
}

extension iccProfile {
    
    public struct Matrix3x3 : CustomStringConvertible {
        
        public var e00: S15Fixed16Number
        public var e01: S15Fixed16Number
        public var e02: S15Fixed16Number
        public var e10: S15Fixed16Number
        public var e11: S15Fixed16Number
        public var e12: S15Fixed16Number
        public var e20: S15Fixed16Number
        public var e21: S15Fixed16Number
        public var e22: S15Fixed16Number
        
        public var matrix: Matrix {
            return Matrix(a: e00.value, b: e01.value, c: e02.value, d: 0,
                          e: e10.value, f: e11.value, g: e12.value, h: 0,
                          i: e20.value, j: e21.value, k: e22.value, l: 0)
        }
        
        public var description: String {
            return "\(matrix))"
        }
    }
    
    public struct Matrix3x4 : CustomStringConvertible {
        
        public var m: Matrix3x3
        public var e03: S15Fixed16Number
        public var e13: S15Fixed16Number
        public var e23: S15Fixed16Number
        
        public var matrix: Matrix {
            return Matrix(a: m.e00.value, b: m.e01.value, c: m.e02.value, d: e03.value,
                          e: m.e10.value, f: m.e11.value, g: m.e12.value, h: e13.value,
                          i: m.e20.value, j: m.e21.value, k: m.e22.value, l: e23.value)
        }
        
        public var description: String {
            return "\(matrix))"
        }
    }
}

extension iccProfile {
    
    public struct ParametricCurve {
        
        public var funcType: BEUInt16
        public var padding: BEUInt16
        public var gamma: S15Fixed16Number
        public var a: S15Fixed16Number
        public var b: S15Fixed16Number
        public var c: S15Fixed16Number
        public var d: S15Fixed16Number
        public var e: S15Fixed16Number
        public var f: S15Fixed16Number
    }
}

extension iccProfile {
    
    public struct Lut16 {
        
        public var inputChannels: UInt8
        public var outputChannels: UInt8
        public var clutPoints: UInt8
        public var padding: UInt8
        public var matrix: Matrix3x3
        public var inputEntries: BEUInt16
        public var outputEntries: BEUInt16
    }
}

extension iccProfile {
    
    public struct Lut8 {
        
        public var inputChannels: UInt8
        public var outputChannels: UInt8
        public var clutPoints: UInt8
        public var padding: UInt8
        public var matrix: Matrix3x3
    }
}

extension iccProfile {
    
    public struct CLUTStruct {
        
        public var gridPoints: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        public var precision: UInt8
        public var pad1: UInt8
        public var pad2: UInt8
        public var pad3: UInt8
    }
}

extension iccProfile {
    
    public struct LutAtoB {
        
        public var inputChannels: UInt8
        public var outputChannels: UInt8
        public var padding1: UInt8
        public var padding2: UInt8
        public var offsetB: BEUInt32
        public var offsetMatrix: BEUInt32
        public var offsetM: BEUInt32
        public var offsetCLUT: BEUInt32
        public var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    public struct LutBtoA {
        
        public var inputChannels: UInt8
        public var outputChannels: UInt8
        public var padding1: UInt8
        public var padding2: UInt8
        public var offsetB: BEUInt32
        public var offsetMatrix: BEUInt32
        public var offsetM: BEUInt32
        public var offsetCLUT: BEUInt32
        public var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    public struct MultiLocalizedUnicode {
        
        public var count: BEUInt32
        public var size: BEUInt32
    }
    
    public struct MultiLocalizedUnicodeEntry {
        
        public var languageCode: BEUInt16
        public var countryCode: BEUInt16
        public var length: BEUInt32
        public var offset: BEUInt32
        
        public var language: String {
            var code = self.languageCode
            return String(bytes: UnsafeRawBufferPointer(start: &code, count: 2), encoding: .ascii) ?? ""
        }
        public var country: String {
            var code = self.countryCode
            return String(bytes: UnsafeRawBufferPointer(start: &code, count: 2), encoding: .ascii) ?? ""
        }
    }
}

