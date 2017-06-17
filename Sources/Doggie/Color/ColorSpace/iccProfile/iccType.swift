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
    
    public struct Header {
        
        public static let MagicNumber: BEUInt32 = 0x61637370
        
        public var size: BEUInt32                                           /* Profile size in bytes */
        public var cmmId: BEUInt32                                          /* CMM for this profile */
        public var version: BEUInt32                                        /* Format version number */
        
        public var deviceClass: ClassSignature                              /* Type of profile */
        public var colorSpace: ColorSpaceSignature                          /* Color space of data */
        public var pcs: ColorSpaceSignature                                 /* PCS, XYZ or Lab only */
        
        public var date: DateTimeNumber                                     /* Date profile was created */
        
        public var magic: BEUInt32                                          /* icMagicNumber */
        public var platform: BEUInt32                                       /* Primary Platform */
        public var flags: BEUInt32                                          /* Various bit settings */
        public var manufacturer: BEUInt32                                   /* Device manufacturer */
        public var model: BEUInt32                                          /* Device model number */
        public var attributes: BEUInt64                                     /* Device attributes */
        public var renderingIntent: BEUInt32                                /* Rendering intent */
        
        public var illuminant: XYZNumber                                    /* Profile illuminant */
        
        public var creator: BEUInt32                                        /* Profile creator */
        public var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        public var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
    }
}

public protocol iccSignature: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    
    associatedtype Bytes : FixedWidthInteger
    
    var rawValue: BEInteger<Bytes> { get set }
    
    init(rawValue: BEInteger<Bytes>)
}

extension iccSignature {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public init(integerLiteral value: BEInteger<Bytes>.IntegerLiteralType) {
        self.init(rawValue: BEInteger<Bytes>(integerLiteral: value))
    }
    
    public init(stringLiteral value: StaticString) {
        precondition(value.utf8CodeUnitCount == Bytes.bitWidth >> 3)
        self.init(rawValue: value.utf8Start.withMemoryRebound(to: BEInteger<Bytes>.self, capacity: 1) { $0.pointee })
    }
    
    public var description: String {
        var code = self.rawValue
        return String(bytes: UnsafeRawBufferPointer(start: &code, count: Bytes.bitWidth >> 3), encoding: .ascii) ?? ""
    }
}

extension iccProfile.Header {
    
    public struct ClassSignature: iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let input: ClassSignature                     = "scnr"
        public static let display: ClassSignature                   = "mntr"
        public static let output: ClassSignature                    = "prtr"
        public static let link: ClassSignature                      = "link"
        public static let abstract: ClassSignature                  = "abst"
        public static let colorSpace: ClassSignature                = "spac"
        public static let namedColor: ClassSignature                = "nmcl"
    }
    
    public struct ColorSpaceSignature: iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let XYZ: ColorSpaceSignature                        = "XYZ "
        public static let Lab: ColorSpaceSignature                        = "Lab "
        public static let Luv: ColorSpaceSignature                        = "Luv "
        public static let YCbCr: ColorSpaceSignature                      = "YCbr"
        public static let Yxy: ColorSpaceSignature                        = "Yxy "
        public static let Rgb: ColorSpaceSignature                        = "RGB "
        public static let Gray: ColorSpaceSignature                       = "GRAY"
        public static let Hsv: ColorSpaceSignature                        = "HSV "
        public static let Hls: ColorSpaceSignature                        = "HLS "
        public static let Cmyk: ColorSpaceSignature                       = "CMYK"
        public static let Cmy: ColorSpaceSignature                        = "CMY "
        
        public static let Named: ColorSpaceSignature                      = "nmcl"
        
        public static let color2: ColorSpaceSignature                     = "2CLR"
        public static let color3: ColorSpaceSignature                     = "3CLR"
        public static let color4: ColorSpaceSignature                     = "4CLR"
        public static let color5: ColorSpaceSignature                     = "5CLR"
        public static let color6: ColorSpaceSignature                     = "6CLR"
        public static let color7: ColorSpaceSignature                     = "7CLR"
        public static let color8: ColorSpaceSignature                     = "8CLR"
        public static let color9: ColorSpaceSignature                     = "9CLR"
        public static let color10: ColorSpaceSignature                    = "ACLR"
        public static let color11: ColorSpaceSignature                    = "BCLR"
        public static let color12: ColorSpaceSignature                    = "CCLR"
        public static let color13: ColorSpaceSignature                    = "DCLR"
        public static let color14: ColorSpaceSignature                    = "ECLR"
        public static let color15: ColorSpaceSignature                    = "FCLR"
    }
}

extension iccProfile {
    
    public struct TagSignature : iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let AToB0: TagSignature                                = "A2B0"
        public static let AToB1: TagSignature                                = "A2B1"
        public static let AToB2: TagSignature                                = "A2B2"
        public static let BlueColorant: TagSignature                         = "bXYZ"
        public static let BlueTRC: TagSignature                              = "bTRC"
        public static let BToA0: TagSignature                                = "B2A0"
        public static let BToA1: TagSignature                                = "B2A1"
        public static let BToA2: TagSignature                                = "B2A2"
        public static let CalibrationDateTime: TagSignature                  = "calt"
        public static let CharTarget: TagSignature                           = "targ"
        public static let ChromaticAdaptation: TagSignature                  = "chad"
        public static let Chromaticity: TagSignature                         = "chrm"
        public static let ColorantOrder: TagSignature                        = "clro"
        public static let ColorantTable: TagSignature                        = "clrt"
        public static let ColorantTableOut: TagSignature                     = "clot"
        public static let ColorimetricIntentImageState: TagSignature         = "ciis"
        public static let Copyright: TagSignature                            = "cprt"
        public static let CrdInfo: TagSignature                              = "crdi"  /* Removed in V4 */
        public static let Data: TagSignature                                 = "data"  /* Removed in V4 */
        public static let DateTime: TagSignature                             = "dtim"  /* Removed in V4 */
        public static let DeviceMfgDesc: TagSignature                        = "dmnd"
        public static let DeviceModelDesc: TagSignature                      = "dmdd"
        public static let DeviceSettings: TagSignature                       = "devs"  /* Removed in V4 */
        public static let DToB0: TagSignature                                = "D2B0"
        public static let DToB1: TagSignature                                = "D2B1"
        public static let DToB2: TagSignature                                = "D2B2"
        public static let DToB3: TagSignature                                = "D2B3"
        public static let BToD0: TagSignature                                = "B2D0"
        public static let BToD1: TagSignature                                = "B2D1"
        public static let BToD2: TagSignature                                = "B2D2"
        public static let BToD3: TagSignature                                = "B2D3"
        public static let Gamut: TagSignature                                = "gamt"
        public static let GrayTRC: TagSignature                              = "kTRC"
        public static let GreenColorant: TagSignature                        = "gXYZ"
        public static let GreenTRC: TagSignature                             = "gTRC"
        public static let Luminance: TagSignature                            = "lumi"
        public static let Measurement: TagSignature                          = "meas"
        public static let MediaBlackPoint: TagSignature                      = "bkpt"
        public static let MediaWhitePoint: TagSignature                      = "wtpt"
        public static let MetaData: TagSignature                             = "meta"
        public static let NamedColor2: TagSignature                          = "ncl2"
        public static let OutputResponse: TagSignature                       = "resp"
        public static let PerceptualRenderingIntentGamut: TagSignature       = "rig0"
        public static let Preview0: TagSignature                             = "pre0"
        public static let Preview1: TagSignature                             = "pre1"
        public static let Preview2: TagSignature                             = "pre2"
        public static let PrintCondition: TagSignature                       = "ptcn"
        public static let ProfileDescription: TagSignature                   = "desc"
        public static let ProfileSequenceDesc: TagSignature                  = "pseq"
        public static let ProfileSequceId: TagSignature                      = "psid"
        public static let Ps2CRD0: TagSignature                              = "psd0"  /* Removed in V4 */
        public static let Ps2CRD1: TagSignature                              = "psd1"  /* Removed in V4 */
        public static let Ps2CRD2: TagSignature                              = "psd2"  /* Removed in V4 */
        public static let Ps2CRD3: TagSignature                              = "psd3"  /* Removed in V4 */
        public static let Ps2CSA: TagSignature                               = "ps2s"  /* Removed in V4 */
        public static let Ps2RenderingIntent: TagSignature                   = "ps2i"  /* Removed in V4 */
        public static let RedColorant: TagSignature                          = "rXYZ"
        public static let RedTRC: TagSignature                               = "rTRC"
        public static let SaturationRenderingIntentGamut: TagSignature       = "rig2"
        public static let ScreeningDesc: TagSignature                        = "scrd"  /* Removed in V4 */
        public static let Screening: TagSignature                            = "scrn"  /* Removed in V4 */
        public static let Technology: TagSignature                           = "tech"
        public static let UcrBg: TagSignature                                = "bfd "  /* Removed in V4 */
        public static let ViewingCondDesc: TagSignature                      = "vued"
        public static let ViewingConditions: TagSignature                    = "view"
    }
}

extension iccProfile.TagData {
    
    public struct `Type` : iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let Chromaticity: Type               = "chrm"
        public static let ColorantOrder: Type              = "clro"
        public static let ColorantTable: Type              = "clrt"
        public static let CrdInfo: Type                    = "crdi"  /* Removed in V4 */
        public static let Curve: Type                      = "curv"
        public static let Data: Type                       = "data"
        public static let Dict: Type                       = "dict"
        public static let DateTime: Type                   = "dtim"
        public static let DeviceSettings: Type             = "devs"  /* Removed in V4 */
        public static let Lut16: Type                      = "mft2"
        public static let Lut8: Type                       = "mft1"
        public static let LutAtoB: Type                    = "mAB "
        public static let LutBtoA: Type                    = "mBA "
        public static let Measurement: Type                = "meas"
        public static let MultiLocalizedUnicode: Type      = "mluc"
        public static let MultiProcessElement: Type        = "mpet"
        public static let NamedColor2: Type                = "ncl2"
        public static let ParametricCurve: Type            = "para"
        public static let ProfileSequenceDesc: Type        = "pseq"
        public static let ProfileSequceId: Type            = "psid"
        public static let ResponseCurveSet16: Type         = "rcs2"
        public static let S15Fixed16Array: Type            = "sf32"
        public static let Screening: Type                  = "scrn"  /* Removed in V4 */
        public static let Signature: Type                  = "sig "
        public static let Text: Type                       = "text"
        public static let TextDescription: Type            = "desc"  /* Removed in V4 */
        public static let U16Fixed16Array: Type            = "uf32"
        public static let UcrBg: Type                      = "bfd "  /* Removed in V4 */
        public static let UInt16Array: Type                = "ui16"
        public static let UInt32Array: Type                = "ui32"
        public static let UInt64Array: Type                = "ui64"
        public static let UInt8Array: Type                 = "ui08"
        public static let ViewingConditions: Type          = "view"
        public static let XYZArray: Type                   = "XYZ "
    }
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
        public var grids: UInt8
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
        public var grids: UInt8
        public var padding: UInt8
        public var matrix: Matrix3x3
    }
}

extension iccProfile {
    
    public struct CLUTStruct {
        
        public var grids: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
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
    
    public struct LanguageCode: iccSignature {
        
        public var rawValue: BEUInt16
        
        public init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    public struct CountryCode: iccSignature {
        
        public var rawValue: BEUInt16
        
        public init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    public struct MultiLocalizedUnicode {
        
        public var count: BEUInt32
        public var size: BEUInt32
    }
    
    public struct MultiLocalizedUnicodeEntry {
        
        public var language: LanguageCode
        public var country: CountryCode
        public var length: BEUInt32
        public var offset: BEUInt32
    }
}

