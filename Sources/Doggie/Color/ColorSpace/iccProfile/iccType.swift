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

public protocol iccUIntNumber : RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral where RawValue : FixedWidthInteger {
    
    var bigEndian: RawValue { get set }
    
    init(bigEndian: RawValue)
}

extension iccUIntNumber {
    
    public var rawValue: RawValue {
        get {
            return RawValue(bigEndian: bigEndian)
        }
        set {
            bigEndian = newValue.bigEndian
        }
    }
    
    public init(rawValue: RawValue) {
        self.init(bigEndian: rawValue.bigEndian)
    }
    
    public init(integerLiteral value: RawValue) {
        self.init(bigEndian: value.bigEndian)
    }
    
    public var description: String {
        return "\(rawValue)"
    }
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension iccProfile {
    
    public struct UInt16Number : iccUIntNumber {
        
        public typealias RawValue = UInt16
        
        public var bigEndian: UInt16
        
        public init(bigEndian: UInt16) {
            self.bigEndian = bigEndian
        }
    }
    
    public struct UInt32Number : iccUIntNumber {
        
        public typealias RawValue = UInt32
        
        public var bigEndian: UInt32
        
        public init(bigEndian: UInt32) {
            self.bigEndian = bigEndian
        }
    }
    
    public struct UInt64Number : iccUIntNumber {
        
        public typealias RawValue = UInt64
        
        public var bigEndian: UInt64
        
        public init(bigEndian: UInt64) {
            self.bigEndian = bigEndian
        }
    }
}

extension iccProfile {
    
    public struct S15Fixed16Number : RawRepresentable, Hashable, CustomStringConvertible {
        
        public typealias RawValue = Int32
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(Int32(bigEndian: rawValue)) / 65536.0
            }
            set {
                rawValue = Int32(newValue.clamped(to: -32768.0...32767.0) * 65536.0).bigEndian
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
        
        public typealias RawValue = UInt32
        
        public var rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(UInt32(bigEndian: rawValue)) / 65536.0
            }
            set {
                rawValue = UInt32(newValue.clamped(to: 0...65535.0) * 65536.0).bigEndian
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
        
        public typealias RawValue = UInt16
        
        public var rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(UInt16(bigEndian: rawValue)) / 32768.0
            }
            set {
                rawValue = UInt16(icRoundOffset(newValue.clamped(to: 0...65535.0/32768.0) * 32768.0)).bigEndian
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
        
        public typealias RawValue = UInt16
        
        public var rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public var value: Double {
            get {
                return Double(UInt16(bigEndian: rawValue)) / 256.0
            }
            set {
                rawValue = UInt16(icRoundOffset(newValue.clamped(to: 0...255.0) * 256.0)).bigEndian
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
        
        public var year: UInt16Number
        public var month: UInt16Number
        public var day: UInt16Number
        public var hours: UInt16Number
        public var minutes: UInt16Number
        public var seconds: UInt16Number
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
    
    public struct ChromaticityNumber {
        
        public var x: U16Fixed16Number
        public var y: U16Fixed16Number
    }
}

extension iccProfile {
    
    public struct Response16Number {
        
        public var deviceCode: UInt16Number
        public var reserved: UInt16Number
        public var measurementValue: S15Fixed16Number
    }
}

extension iccProfile {
    
    public struct PositionNumber {
        
        public var offset: UInt32Number
        public var size: UInt32Number
    }
}

extension iccProfile {
    
    public struct ParametricCurve {
        
        public var funcType: UInt16Number           /* Function Type                */
                                                    /* 0 = gamma only               */
        public var pad: UInt16Number                /* Padding for byte alignment   */
        public var gamma: S15Fixed16Number          /* x°gamma                      */
        public var a: S15Fixed16Number              /* a                            */
        public var b: S15Fixed16Number              /* b                            */
        public var c: S15Fixed16Number              /* c                            */
        public var d: S15Fixed16Number              /* d                            */
        public var e: S15Fixed16Number              /* e                            */
        public var f: S15Fixed16Number              /* f                            */
    }
}
