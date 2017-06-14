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
    
    public struct UInt16Number : RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral {
        
        public typealias RawValue = UInt16
        
        public var rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: UInt16) {
            self.rawValue = value.bigEndian
        }
        
        public var value: UInt16 {
            get {
                return UInt16(bigEndian: rawValue)
            }
            set {
                rawValue = newValue.bigEndian
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
    
    public struct UInt32Number : RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral {
        
        public typealias RawValue = UInt32
        
        public var rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: UInt32) {
            self.rawValue = value.bigEndian
        }
        
        public var value: UInt32 {
            get {
                return UInt32(bigEndian: rawValue)
            }
            set {
                rawValue = newValue.bigEndian
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
    
    public struct UInt64Number : RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral {
        
        public typealias RawValue = UInt64
        
        public var rawValue: UInt64
        
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: UInt64) {
            self.rawValue = value.bigEndian
        }
        
        public var value: UInt64 {
            get {
                return UInt64(bigEndian: rawValue)
            }
            set {
                rawValue = newValue.bigEndian
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
    
    public struct S15Fixed16Number : RawRepresentable, Hashable, CustomStringConvertible {
        
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
                rawValue = UInt32(newValue.clamped(to: -32768.0...32767.0) * 65536.0).bigEndian
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

