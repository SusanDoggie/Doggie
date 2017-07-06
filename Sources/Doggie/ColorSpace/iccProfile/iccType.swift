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

extension iccProfile {
    
    struct Header {
        
        static let MagicNumber: Signature = "acsp"
        
        var size: BEUInt32                                           /* Profile size in bytes */
        
        var cmmId: Signature                                         /* CMM for this profile */
        
        var version: BEUInt32                                        /* Format version number */
        
        var deviceClass: ClassSignature                              /* Type of profile */
        
        var colorSpace: ColorSpaceSignature                          /* Color space of data */
        
        var pcs: ColorSpaceSignature                                 /* PCS, XYZ or Lab only */
        
        var date: DateTimeNumber                                     /* Date profile was created */
        
        var magic: Signature                                         /* icMagicNumber */
        
        var platform: Signature                                      /* Primary Platform */
        
        var flags: BEUInt32                                          /* Various bit settings */
        
        var manufacturer: Signature                                  /* Device manufacturer */
        
        var model: Signature                                         /* Device model number */
        
        var attributes: BEUInt64                                     /* Device attributes */
        
        var renderingIntent: BEUInt32                                /* Rendering intent */
        
        var illuminant: XYZNumber                                    /* Profile illuminant */
        
        var creator: Signature                                       /* Profile creator */
        
        var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        
        var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
        init(cmmId: Signature,
             version: BEUInt32,
             deviceClass: ClassSignature,
             colorSpace: ColorSpaceSignature,
             pcs: ColorSpaceSignature,
             date: DateTimeNumber,
             platform: Signature,
             flags: BEUInt32,
             manufacturer: Signature,
             model: Signature,
             attributes: BEUInt64,
             renderingIntent: BEUInt32,
             illuminant: XYZNumber,
             creator: Signature) {
            
            self.size = 0
            self.cmmId = cmmId
            self.version = version
            self.deviceClass = deviceClass
            self.colorSpace = colorSpace
            self.pcs = pcs
            self.date = date
            self.magic = Header.MagicNumber
            self.platform = platform
            self.flags = flags
            self.manufacturer = manufacturer
            self.model = model
            self.attributes = attributes
            self.renderingIntent = renderingIntent
            self.illuminant = illuminant
            self.creator = creator
            self.profileID = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            self.reserved = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        }
    }
}

protocol iccSignatureProtocol: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    
    associatedtype Bytes : FixedWidthInteger
    
    var rawValue: BEInteger<Bytes> { get set }
    
    init(rawValue: BEInteger<Bytes>)
}

extension iccSignatureProtocol {
    
    var hashValue: Int {
        return rawValue.hashValue
    }
    
    init(integerLiteral value: BEInteger<Bytes>.IntegerLiteralType) {
        self.init(rawValue: BEInteger<Bytes>(integerLiteral: value))
    }
    
    init(stringLiteral value: StaticString) {
        precondition(value.utf8CodeUnitCount == Bytes.bitWidth >> 3)
        self.init(rawValue: value.utf8Start.withMemoryRebound(to: BEInteger<Bytes>.self, capacity: 1) { $0.pointee })
    }
    
    var description: String {
        var code = self.rawValue
        return String(bytes: UnsafeRawBufferPointer(start: &code, count: Bytes.bitWidth >> 3), encoding: .ascii) ?? ""
    }
}

extension iccProfile.Header {
    
    struct Signature: iccSignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
    }
    
    struct ClassSignature: iccSignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        static let input: ClassSignature                     = "scnr"
        static let display: ClassSignature                   = "mntr"
        static let output: ClassSignature                    = "prtr"
        static let link: ClassSignature                      = "link"
        static let abstract: ClassSignature                  = "abst"
        static let colorSpace: ClassSignature                = "spac"
        static let namedColor: ClassSignature                = "nmcl"
    }
    
    struct ColorSpaceSignature: iccSignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        static let XYZ: ColorSpaceSignature                        = "XYZ "
        static let Lab: ColorSpaceSignature                        = "Lab "
        static let Luv: ColorSpaceSignature                        = "Luv "
        static let YCbCr: ColorSpaceSignature                      = "YCbr"
        static let Yxy: ColorSpaceSignature                        = "Yxy "
        static let Rgb: ColorSpaceSignature                        = "RGB "
        static let Gray: ColorSpaceSignature                       = "GRAY"
        static let Hsv: ColorSpaceSignature                        = "HSV "
        static let Hls: ColorSpaceSignature                        = "HLS "
        static let Cmyk: ColorSpaceSignature                       = "CMYK"
        static let Cmy: ColorSpaceSignature                        = "CMY "
        
        static let Named: ColorSpaceSignature                      = "nmcl"
        
        static let color2: ColorSpaceSignature                     = "2CLR"
        static let color3: ColorSpaceSignature                     = "3CLR"
        static let color4: ColorSpaceSignature                     = "4CLR"
        static let color5: ColorSpaceSignature                     = "5CLR"
        static let color6: ColorSpaceSignature                     = "6CLR"
        static let color7: ColorSpaceSignature                     = "7CLR"
        static let color8: ColorSpaceSignature                     = "8CLR"
        static let color9: ColorSpaceSignature                     = "9CLR"
        static let color10: ColorSpaceSignature                    = "ACLR"
        static let color11: ColorSpaceSignature                    = "BCLR"
        static let color12: ColorSpaceSignature                    = "CCLR"
        static let color13: ColorSpaceSignature                    = "DCLR"
        static let color14: ColorSpaceSignature                    = "ECLR"
        static let color15: ColorSpaceSignature                    = "FCLR"
    }
}

extension iccProfile {
    
    struct TagSignature : iccSignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        static let AToB0: TagSignature                                = "A2B0"
        static let AToB1: TagSignature                                = "A2B1"
        static let AToB2: TagSignature                                = "A2B2"
        static let BlueColorant: TagSignature                         = "bXYZ"
        static let BlueTRC: TagSignature                              = "bTRC"
        static let BToA0: TagSignature                                = "B2A0"
        static let BToA1: TagSignature                                = "B2A1"
        static let BToA2: TagSignature                                = "B2A2"
        static let CalibrationDateTime: TagSignature                  = "calt"
        static let CharTarget: TagSignature                           = "targ"
        static let ChromaticAdaptation: TagSignature                  = "chad"
        static let Chromaticity: TagSignature                         = "chrm"
        static let ColorantOrder: TagSignature                        = "clro"
        static let ColorantTable: TagSignature                        = "clrt"
        static let ColorantTableOut: TagSignature                     = "clot"
        static let ColorimetricIntentImageState: TagSignature         = "ciis"
        static let Copyright: TagSignature                            = "cprt"
        static let CrdInfo: TagSignature                              = "crdi"  /* Removed in V4 */
        static let Data: TagSignature                                 = "data"  /* Removed in V4 */
        static let DateTime: TagSignature                             = "dtim"  /* Removed in V4 */
        static let DeviceMfgDesc: TagSignature                        = "dmnd"
        static let DeviceModelDesc: TagSignature                      = "dmdd"
        static let DeviceSettings: TagSignature                       = "devs"  /* Removed in V4 */
        static let DToB0: TagSignature                                = "D2B0"
        static let DToB1: TagSignature                                = "D2B1"
        static let DToB2: TagSignature                                = "D2B2"
        static let DToB3: TagSignature                                = "D2B3"
        static let BToD0: TagSignature                                = "B2D0"
        static let BToD1: TagSignature                                = "B2D1"
        static let BToD2: TagSignature                                = "B2D2"
        static let BToD3: TagSignature                                = "B2D3"
        static let Gamut: TagSignature                                = "gamt"
        static let GrayTRC: TagSignature                              = "kTRC"
        static let GreenColorant: TagSignature                        = "gXYZ"
        static let GreenTRC: TagSignature                             = "gTRC"
        static let Luminance: TagSignature                            = "lumi"
        static let Measurement: TagSignature                          = "meas"
        static let MediaBlackPoint: TagSignature                      = "bkpt"
        static let MediaWhitePoint: TagSignature                      = "wtpt"
        static let MetaData: TagSignature                             = "meta"
        static let NamedColor2: TagSignature                          = "ncl2"
        static let OutputResponse: TagSignature                       = "resp"
        static let PerceptualRenderingIntentGamut: TagSignature       = "rig0"
        static let Preview0: TagSignature                             = "pre0"
        static let Preview1: TagSignature                             = "pre1"
        static let Preview2: TagSignature                             = "pre2"
        static let PrintCondition: TagSignature                       = "ptcn"
        static let ProfileDescription: TagSignature                   = "desc"
        static let ProfileSequenceDesc: TagSignature                  = "pseq"
        static let ProfileSequceId: TagSignature                      = "psid"
        static let Ps2CRD0: TagSignature                              = "psd0"  /* Removed in V4 */
        static let Ps2CRD1: TagSignature                              = "psd1"  /* Removed in V4 */
        static let Ps2CRD2: TagSignature                              = "psd2"  /* Removed in V4 */
        static let Ps2CRD3: TagSignature                              = "psd3"  /* Removed in V4 */
        static let Ps2CSA: TagSignature                               = "ps2s"  /* Removed in V4 */
        static let Ps2RenderingIntent: TagSignature                   = "ps2i"  /* Removed in V4 */
        static let RedColorant: TagSignature                          = "rXYZ"
        static let RedTRC: TagSignature                               = "rTRC"
        static let SaturationRenderingIntentGamut: TagSignature       = "rig2"
        static let ScreeningDesc: TagSignature                        = "scrd"  /* Removed in V4 */
        static let Screening: TagSignature                            = "scrn"  /* Removed in V4 */
        static let Technology: TagSignature                           = "tech"
        static let UcrBg: TagSignature                                = "bfd "  /* Removed in V4 */
        static let ViewingCondDesc: TagSignature                      = "vued"
        static let ViewingConditions: TagSignature                    = "view"
    }
}

extension iccProfile.TagData {
    
    struct `Type` : iccSignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        static let Chromaticity: Type               = "chrm"
        static let ColorantOrder: Type              = "clro"
        static let ColorantTable: Type              = "clrt"
        static let CrdInfo: Type                    = "crdi"  /* Removed in V4 */
        static let Curve: Type                      = "curv"
        static let Data: Type                       = "data"
        static let Dict: Type                       = "dict"
        static let DateTime: Type                   = "dtim"
        static let DeviceSettings: Type             = "devs"  /* Removed in V4 */
        static let Lut16: Type                      = "mft2"
        static let Lut8: Type                       = "mft1"
        static let LutAtoB: Type                    = "mAB "
        static let LutBtoA: Type                    = "mBA "
        static let Measurement: Type                = "meas"
        static let MultiLocalizedUnicode: Type      = "mluc"
        static let MultiProcessElement: Type        = "mpet"
        static let NamedColor2: Type                = "ncl2"
        static let ParametricCurve: Type            = "para"
        static let ProfileSequenceDesc: Type        = "pseq"
        static let ProfileSequceId: Type            = "psid"
        static let ResponseCurveSet16: Type         = "rcs2"
        static let S15Fixed16Array: Type            = "sf32"
        static let Screening: Type                  = "scrn"  /* Removed in V4 */
        static let Signature: Type                  = "sig "
        static let Text: Type                       = "text"
        static let TextDescription: Type            = "desc"  /* Removed in V4 */
        static let U16Fixed16Array: Type            = "uf32"
        static let UcrBg: Type                      = "bfd "  /* Removed in V4 */
        static let UInt16Array: Type                = "ui16"
        static let UInt32Array: Type                = "ui32"
        static let UInt64Array: Type                = "ui64"
        static let UInt8Array: Type                 = "ui08"
        static let ViewingConditions: Type          = "view"
        static let XYZArray: Type                   = "XYZ "
    }
}

extension iccProfile {
    
    struct S15Fixed16Number : BinaryFixedPoint {
        
        typealias RepresentingValue = Double
        
        var bitPattern: BEInt32
        
        init(bitPattern: BitPattern) {
            self.bitPattern = bitPattern
        }
        
        static var fractionBitCount: Int {
            return 16
        }
    }
}

extension iccProfile {
    
    struct U16Fixed16Number : BinaryFixedPoint {
        
        typealias RepresentingValue = Double
        
        var bitPattern: BEUInt32
        
        init(bitPattern: BitPattern) {
            self.bitPattern = bitPattern
        }
        
        static var fractionBitCount: Int {
            return 16
        }
    }
}

extension iccProfile {
    
    struct U1Fixed15Number : BinaryFixedPoint {
        
        typealias RepresentingValue = Double
        
        var bitPattern: BEUInt16
        
        init(bitPattern: BitPattern) {
            self.bitPattern = bitPattern
        }
        
        static var fractionBitCount: Int {
            return 15
        }
    }
}

extension iccProfile {
    
    struct U8Fixed8Number : BinaryFixedPoint {
        
        typealias RepresentingValue = Double
        
        var bitPattern: BEUInt16
        
        init(bitPattern: BitPattern) {
            self.bitPattern = bitPattern
        }
        
        static var fractionBitCount: Int {
            return 8
        }
    }
}

extension iccProfile {
    
    struct DateTimeNumber {
        
        var year: BEUInt16
        
        var month: BEUInt16
        
        var day: BEUInt16
        
        var hours: BEUInt16
        
        var minutes: BEUInt16
        
        var seconds: BEUInt16
        
        init(year: BEUInt16, month: BEUInt16, day: BEUInt16, hours: BEUInt16, minutes: BEUInt16, seconds: BEUInt16) {
            self.year = year
            self.month = month
            self.day = day
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
        }
    }
}

extension iccProfile {
    
    struct XYZNumber {
        
        var x: S15Fixed16Number
        
        var y: S15Fixed16Number
        
        var z: S15Fixed16Number
        
        init(x: S15Fixed16Number, y: S15Fixed16Number, z: S15Fixed16Number) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        init(_ xyz: XYZColorModel) {
            self.x = S15Fixed16Number(xyz.x)
            self.y = S15Fixed16Number(xyz.y)
            self.z = S15Fixed16Number(xyz.z)
        }
    }
}

extension iccProfile {
    
    struct Matrix3x3 {
        
        var e00: S15Fixed16Number
        
        var e01: S15Fixed16Number
        
        var e02: S15Fixed16Number
        
        var e10: S15Fixed16Number
        
        var e11: S15Fixed16Number
        
        var e12: S15Fixed16Number
        
        var e20: S15Fixed16Number
        
        var e21: S15Fixed16Number
        
        var e22: S15Fixed16Number
        
        init(_ matrix: Matrix) {
            self.e00 = S15Fixed16Number(matrix.a)
            self.e01 = S15Fixed16Number(matrix.b)
            self.e02 = S15Fixed16Number(matrix.c)
            self.e10 = S15Fixed16Number(matrix.e)
            self.e11 = S15Fixed16Number(matrix.f)
            self.e12 = S15Fixed16Number(matrix.g)
            self.e20 = S15Fixed16Number(matrix.i)
            self.e21 = S15Fixed16Number(matrix.j)
            self.e22 = S15Fixed16Number(matrix.k)
        }
        
        var matrix: Matrix {
            return Matrix(a: e00.representingValue, b: e01.representingValue, c: e02.representingValue, d: 0,
                          e: e10.representingValue, f: e11.representingValue, g: e12.representingValue, h: 0,
                          i: e20.representingValue, j: e21.representingValue, k: e22.representingValue, l: 0)
        }
    }
    
    struct Matrix3x4 {
        
        var m: Matrix3x3
        
        var e03: S15Fixed16Number
        
        var e13: S15Fixed16Number
        
        var e23: S15Fixed16Number
        
        init(_ matrix: Matrix) {
            self.m = Matrix3x3(matrix)
            self.e03 = S15Fixed16Number(matrix.d)
            self.e13 = S15Fixed16Number(matrix.h)
            self.e23 = S15Fixed16Number(matrix.l)
        }
        
        var matrix: Matrix {
            return Matrix(a: m.e00.representingValue, b: m.e01.representingValue, c: m.e02.representingValue, d: e03.representingValue,
                          e: m.e10.representingValue, f: m.e11.representingValue, g: m.e12.representingValue, h: e13.representingValue,
                          i: m.e20.representingValue, j: m.e21.representingValue, k: m.e22.representingValue, l: e23.representingValue)
        }
    }
}

extension iccProfile {
    
    struct ParametricCurve {
        
        var funcType: BEUInt16
        
        var padding: BEUInt16
        
        var gamma: S15Fixed16Number
        
        var a: S15Fixed16Number
        
        var b: S15Fixed16Number
        
        var c: S15Fixed16Number
        
        var d: S15Fixed16Number
        
        var e: S15Fixed16Number
        
        var f: S15Fixed16Number
        
        init(funcType: BEUInt16,
             gamma: S15Fixed16Number,
             a: S15Fixed16Number,
             b: S15Fixed16Number,
             c: S15Fixed16Number,
             d: S15Fixed16Number,
             e: S15Fixed16Number,
             f: S15Fixed16Number) {
            
            self.funcType = funcType
            self.padding = 0
            self.gamma = gamma
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
        }
    }
}

extension iccProfile {
    
    struct Lut16 {
        
        var inputChannels: UInt8
        
        var outputChannels: UInt8
        
        var grids: UInt8
        
        var padding: UInt8
        
        var matrix: Matrix3x3
        
        var inputEntries: BEUInt16
        
        var outputEntries: BEUInt16
    }
}

extension iccProfile {
    
    struct Lut8 {
        
        var inputChannels: UInt8
        
        var outputChannels: UInt8
        
        var grids: UInt8
        
        var padding: UInt8
        
        var matrix: Matrix3x3
    }
}

extension iccProfile {
    
    struct CLUTStruct {
        
        var grids: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        var precision: UInt8
        
        var pad1: UInt8
        
        var pad2: UInt8
        
        var pad3: UInt8
    }
}

extension iccProfile {
    
    struct LutAtoB {
        
        var inputChannels: UInt8
        
        var outputChannels: UInt8
        
        var padding1: UInt8
        
        var padding2: UInt8
        
        var offsetB: BEUInt32
        
        var offsetMatrix: BEUInt32
        
        var offsetM: BEUInt32
        
        var offsetCLUT: BEUInt32
        
        var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    struct LutBtoA {
        
        var inputChannels: UInt8
        
        var outputChannels: UInt8
        
        var padding1: UInt8
        
        var padding2: UInt8
        
        var offsetB: BEUInt32
        
        var offsetMatrix: BEUInt32
        
        var offsetM: BEUInt32
        
        var offsetCLUT: BEUInt32
        
        var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    struct LanguageCode: iccSignatureProtocol {
        
        var rawValue: BEUInt16
        
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    struct CountryCode: iccSignatureProtocol {
        
        var rawValue: BEUInt16
        
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    struct MultiLocalizedUnicode {
        
        var count: BEUInt32
        
        var size: BEUInt32
        
        init(count: BEUInt32, size: BEUInt32) {
            self.count = count
            self.size = size
        }
    }
    
    struct MultiLocalizedUnicodeEntry {
        
        var language: LanguageCode
        
        var country: CountryCode
        
        var length: BEUInt32
        
        var offset: BEUInt32
        
        init(language: LanguageCode, country: CountryCode, length: BEUInt32, offset: BEUInt32) {
            self.language = language
            self.country = country
            self.length = length
            self.offset = offset
        }
    }
}


