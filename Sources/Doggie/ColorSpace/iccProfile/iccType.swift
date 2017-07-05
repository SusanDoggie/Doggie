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
    
    @_versioned
    struct Header {
        
        @_versioned
        static let MagicNumber: Signature = "acsp"
        
        @_versioned
        var size: BEUInt32                                           /* Profile size in bytes */
        
        @_versioned
        var cmmId: Signature                                         /* CMM for this profile */
        
        @_versioned
        var version: BEUInt32                                        /* Format version number */
        
        @_versioned
        var deviceClass: ClassSignature                              /* Type of profile */
        
        @_versioned
        var colorSpace: ColorSpaceSignature                          /* Color space of data */
        
        @_versioned
        var pcs: ColorSpaceSignature                                 /* PCS, XYZ or Lab only */
        
        @_versioned
        var date: DateTimeNumber                                     /* Date profile was created */
        
        @_versioned
        var magic: Signature                                         /* icMagicNumber */
        
        @_versioned
        var platform: Signature                                      /* Primary Platform */
        
        @_versioned
        var flags: BEUInt32                                          /* Various bit settings */
        
        @_versioned
        var manufacturer: Signature                                  /* Device manufacturer */
        
        @_versioned
        var model: Signature                                         /* Device model number */
        
        @_versioned
        var attributes: BEUInt64                                     /* Device attributes */
        
        @_versioned
        var renderingIntent: BEUInt32                                /* Rendering intent */
        
        @_versioned
        var illuminant: XYZNumber                                    /* Profile illuminant */
        
        @_versioned
        var creator: Signature                                       /* Profile creator */
        
        @_versioned
        var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        
        @_versioned
        var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
        @_versioned
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

@_versioned
protocol iccSignatureProtocol: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    
    associatedtype Bytes : FixedWidthInteger
    
    var rawValue: BEInteger<Bytes> { get set }
    
    init(rawValue: BEInteger<Bytes>)
}

extension iccSignatureProtocol {
    
    @_versioned
    var hashValue: Int {
        return rawValue.hashValue
    }
    
    @_versioned
    init(integerLiteral value: BEInteger<Bytes>.IntegerLiteralType) {
        self.init(rawValue: BEInteger<Bytes>(integerLiteral: value))
    }
    
    @_versioned
    init(stringLiteral value: StaticString) {
        precondition(value.utf8CodeUnitCount == Bytes.bitWidth >> 3)
        self.init(rawValue: value.utf8Start.withMemoryRebound(to: BEInteger<Bytes>.self, capacity: 1) { $0.pointee })
    }
    
    @_versioned
    var description: String {
        var code = self.rawValue
        return String(bytes: UnsafeRawBufferPointer(start: &code, count: Bytes.bitWidth >> 3), encoding: .ascii) ?? ""
    }
}

extension iccProfile.Header {
    
    @_versioned
    struct Signature: iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
    }
    
    @_versioned
    struct ClassSignature: iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        @_versioned static let input: ClassSignature                     = "scnr"
        @_versioned static let display: ClassSignature                   = "mntr"
        @_versioned static let output: ClassSignature                    = "prtr"
        @_versioned static let link: ClassSignature                      = "link"
        @_versioned static let abstract: ClassSignature                  = "abst"
        @_versioned static let colorSpace: ClassSignature                = "spac"
        @_versioned static let namedColor: ClassSignature                = "nmcl"
    }
    
    @_versioned
    struct ColorSpaceSignature: iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        @_versioned static let XYZ: ColorSpaceSignature                        = "XYZ "
        @_versioned static let Lab: ColorSpaceSignature                        = "Lab "
        @_versioned static let Luv: ColorSpaceSignature                        = "Luv "
        @_versioned static let YCbCr: ColorSpaceSignature                      = "YCbr"
        @_versioned static let Yxy: ColorSpaceSignature                        = "Yxy "
        @_versioned static let Rgb: ColorSpaceSignature                        = "RGB "
        @_versioned static let Gray: ColorSpaceSignature                       = "GRAY"
        @_versioned static let Hsv: ColorSpaceSignature                        = "HSV "
        @_versioned static let Hls: ColorSpaceSignature                        = "HLS "
        @_versioned static let Cmyk: ColorSpaceSignature                       = "CMYK"
        @_versioned static let Cmy: ColorSpaceSignature                        = "CMY "
        
        @_versioned static let Named: ColorSpaceSignature                      = "nmcl"
        
        @_versioned static let color2: ColorSpaceSignature                     = "2CLR"
        @_versioned static let color3: ColorSpaceSignature                     = "3CLR"
        @_versioned static let color4: ColorSpaceSignature                     = "4CLR"
        @_versioned static let color5: ColorSpaceSignature                     = "5CLR"
        @_versioned static let color6: ColorSpaceSignature                     = "6CLR"
        @_versioned static let color7: ColorSpaceSignature                     = "7CLR"
        @_versioned static let color8: ColorSpaceSignature                     = "8CLR"
        @_versioned static let color9: ColorSpaceSignature                     = "9CLR"
        @_versioned static let color10: ColorSpaceSignature                    = "ACLR"
        @_versioned static let color11: ColorSpaceSignature                    = "BCLR"
        @_versioned static let color12: ColorSpaceSignature                    = "CCLR"
        @_versioned static let color13: ColorSpaceSignature                    = "DCLR"
        @_versioned static let color14: ColorSpaceSignature                    = "ECLR"
        @_versioned static let color15: ColorSpaceSignature                    = "FCLR"
    }
}

extension iccProfile {
    
    @_versioned
    struct TagSignature : iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        @_versioned static let AToB0: TagSignature                                = "A2B0"
        @_versioned static let AToB1: TagSignature                                = "A2B1"
        @_versioned static let AToB2: TagSignature                                = "A2B2"
        @_versioned static let BlueColorant: TagSignature                         = "bXYZ"
        @_versioned static let BlueTRC: TagSignature                              = "bTRC"
        @_versioned static let BToA0: TagSignature                                = "B2A0"
        @_versioned static let BToA1: TagSignature                                = "B2A1"
        @_versioned static let BToA2: TagSignature                                = "B2A2"
        @_versioned static let CalibrationDateTime: TagSignature                  = "calt"
        @_versioned static let CharTarget: TagSignature                           = "targ"
        @_versioned static let ChromaticAdaptation: TagSignature                  = "chad"
        @_versioned static let Chromaticity: TagSignature                         = "chrm"
        @_versioned static let ColorantOrder: TagSignature                        = "clro"
        @_versioned static let ColorantTable: TagSignature                        = "clrt"
        @_versioned static let ColorantTableOut: TagSignature                     = "clot"
        @_versioned static let ColorimetricIntentImageState: TagSignature         = "ciis"
        @_versioned static let Copyright: TagSignature                            = "cprt"
        @_versioned static let CrdInfo: TagSignature                              = "crdi"  /* Removed in V4 */
        @_versioned static let Data: TagSignature                                 = "data"  /* Removed in V4 */
        @_versioned static let DateTime: TagSignature                             = "dtim"  /* Removed in V4 */
        @_versioned static let DeviceMfgDesc: TagSignature                        = "dmnd"
        @_versioned static let DeviceModelDesc: TagSignature                      = "dmdd"
        @_versioned static let DeviceSettings: TagSignature                       = "devs"  /* Removed in V4 */
        @_versioned static let DToB0: TagSignature                                = "D2B0"
        @_versioned static let DToB1: TagSignature                                = "D2B1"
        @_versioned static let DToB2: TagSignature                                = "D2B2"
        @_versioned static let DToB3: TagSignature                                = "D2B3"
        @_versioned static let BToD0: TagSignature                                = "B2D0"
        @_versioned static let BToD1: TagSignature                                = "B2D1"
        @_versioned static let BToD2: TagSignature                                = "B2D2"
        @_versioned static let BToD3: TagSignature                                = "B2D3"
        @_versioned static let Gamut: TagSignature                                = "gamt"
        @_versioned static let GrayTRC: TagSignature                              = "kTRC"
        @_versioned static let GreenColorant: TagSignature                        = "gXYZ"
        @_versioned static let GreenTRC: TagSignature                             = "gTRC"
        @_versioned static let Luminance: TagSignature                            = "lumi"
        @_versioned static let Measurement: TagSignature                          = "meas"
        @_versioned static let MediaBlackPoint: TagSignature                      = "bkpt"
        @_versioned static let MediaWhitePoint: TagSignature                      = "wtpt"
        @_versioned static let MetaData: TagSignature                             = "meta"
        @_versioned static let NamedColor2: TagSignature                          = "ncl2"
        @_versioned static let OutputResponse: TagSignature                       = "resp"
        @_versioned static let PerceptualRenderingIntentGamut: TagSignature       = "rig0"
        @_versioned static let Preview0: TagSignature                             = "pre0"
        @_versioned static let Preview1: TagSignature                             = "pre1"
        @_versioned static let Preview2: TagSignature                             = "pre2"
        @_versioned static let PrintCondition: TagSignature                       = "ptcn"
        @_versioned static let ProfileDescription: TagSignature                   = "desc"
        @_versioned static let ProfileSequenceDesc: TagSignature                  = "pseq"
        @_versioned static let ProfileSequceId: TagSignature                      = "psid"
        @_versioned static let Ps2CRD0: TagSignature                              = "psd0"  /* Removed in V4 */
        @_versioned static let Ps2CRD1: TagSignature                              = "psd1"  /* Removed in V4 */
        @_versioned static let Ps2CRD2: TagSignature                              = "psd2"  /* Removed in V4 */
        @_versioned static let Ps2CRD3: TagSignature                              = "psd3"  /* Removed in V4 */
        @_versioned static let Ps2CSA: TagSignature                               = "ps2s"  /* Removed in V4 */
        @_versioned static let Ps2RenderingIntent: TagSignature                   = "ps2i"  /* Removed in V4 */
        @_versioned static let RedColorant: TagSignature                          = "rXYZ"
        @_versioned static let RedTRC: TagSignature                               = "rTRC"
        @_versioned static let SaturationRenderingIntentGamut: TagSignature       = "rig2"
        @_versioned static let ScreeningDesc: TagSignature                        = "scrd"  /* Removed in V4 */
        @_versioned static let Screening: TagSignature                            = "scrn"  /* Removed in V4 */
        @_versioned static let Technology: TagSignature                           = "tech"
        @_versioned static let UcrBg: TagSignature                                = "bfd "  /* Removed in V4 */
        @_versioned static let ViewingCondDesc: TagSignature                      = "vued"
        @_versioned static let ViewingConditions: TagSignature                    = "view"
    }
}

extension iccProfile.TagData {
    
    @_versioned
    struct `Type` : iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        @_versioned static let Chromaticity: Type               = "chrm"
        @_versioned static let ColorantOrder: Type              = "clro"
        @_versioned static let ColorantTable: Type              = "clrt"
        @_versioned static let CrdInfo: Type                    = "crdi"  /* Removed in V4 */
        @_versioned static let Curve: Type                      = "curv"
        @_versioned static let Data: Type                       = "data"
        @_versioned static let Dict: Type                       = "dict"
        @_versioned static let DateTime: Type                   = "dtim"
        @_versioned static let DeviceSettings: Type             = "devs"  /* Removed in V4 */
        @_versioned static let Lut16: Type                      = "mft2"
        @_versioned static let Lut8: Type                       = "mft1"
        @_versioned static let LutAtoB: Type                    = "mAB "
        @_versioned static let LutBtoA: Type                    = "mBA "
        @_versioned static let Measurement: Type                = "meas"
        @_versioned static let MultiLocalizedUnicode: Type      = "mluc"
        @_versioned static let MultiProcessElement: Type        = "mpet"
        @_versioned static let NamedColor2: Type                = "ncl2"
        @_versioned static let ParametricCurve: Type            = "para"
        @_versioned static let ProfileSequenceDesc: Type        = "pseq"
        @_versioned static let ProfileSequceId: Type            = "psid"
        @_versioned static let ResponseCurveSet16: Type         = "rcs2"
        @_versioned static let S15Fixed16Array: Type            = "sf32"
        @_versioned static let Screening: Type                  = "scrn"  /* Removed in V4 */
        @_versioned static let Signature: Type                  = "sig "
        @_versioned static let Text: Type                       = "text"
        @_versioned static let TextDescription: Type            = "desc"  /* Removed in V4 */
        @_versioned static let U16Fixed16Array: Type            = "uf32"
        @_versioned static let UcrBg: Type                      = "bfd "  /* Removed in V4 */
        @_versioned static let UInt16Array: Type                = "ui16"
        @_versioned static let UInt32Array: Type                = "ui32"
        @_versioned static let UInt64Array: Type                = "ui64"
        @_versioned static let UInt8Array: Type                 = "ui08"
        @_versioned static let ViewingConditions: Type          = "view"
        @_versioned static let XYZArray: Type                   = "XYZ "
    }
}

extension iccProfile {
    
    @_versioned
    struct S15Fixed16Number : FixedPointProtocol {
        
        typealias RepresentingValue = Double
        
        @_versioned
        var rawValue: BEInt32
        
        @_versioned
        init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        @_versioned
        static var fractionalBitCount: Int {
            return 16
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct U16Fixed16Number : FixedPointProtocol {
        
        typealias RepresentingValue = Double
        
        @_versioned
        var rawValue: BEUInt32
        
        @_versioned
        init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        @_versioned
        static var fractionalBitCount: Int {
            return 16
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct U1Fixed15Number : FixedPointProtocol {
        
        typealias RepresentingValue = Double
        
        @_versioned
        var rawValue: BEUInt16
        
        @_versioned
        init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        @_versioned
        static var fractionalBitCount: Int {
            return 15
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct U8Fixed8Number : FixedPointProtocol {
        
        typealias RepresentingValue = Double
        
        @_versioned
        var rawValue: BEUInt16
        
        @_versioned
        init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        @_versioned
        static var fractionalBitCount: Int {
            return 8
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct DateTimeNumber {
        
        @_versioned
        var year: BEUInt16
        
        @_versioned
        var month: BEUInt16
        
        @_versioned
        var day: BEUInt16
        
        @_versioned
        var hours: BEUInt16
        
        @_versioned
        var minutes: BEUInt16
        
        @_versioned
        var seconds: BEUInt16
        
        @_versioned
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
    
    @_versioned
    struct XYZNumber {
        
        @_versioned
        var x: S15Fixed16Number
        
        @_versioned
        var y: S15Fixed16Number
        
        @_versioned
        var z: S15Fixed16Number
        
        @_versioned
        init(x: S15Fixed16Number, y: S15Fixed16Number, z: S15Fixed16Number) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        @_versioned
        init(_ xyz: XYZColorModel) {
            self.x = S15Fixed16Number(representingValue: xyz.x)
            self.y = S15Fixed16Number(representingValue: xyz.y)
            self.z = S15Fixed16Number(representingValue: xyz.z)
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct Matrix3x3 {
        
        @_versioned
        var e00: S15Fixed16Number
        
        @_versioned
        var e01: S15Fixed16Number
        
        @_versioned
        var e02: S15Fixed16Number
        
        @_versioned
        var e10: S15Fixed16Number
        
        @_versioned
        var e11: S15Fixed16Number
        
        @_versioned
        var e12: S15Fixed16Number
        
        @_versioned
        var e20: S15Fixed16Number
        
        @_versioned
        var e21: S15Fixed16Number
        
        @_versioned
        var e22: S15Fixed16Number
        
        @_versioned
        init(_ matrix: Matrix) {
            self.e00 = S15Fixed16Number(representingValue: matrix.a)
            self.e01 = S15Fixed16Number(representingValue: matrix.b)
            self.e02 = S15Fixed16Number(representingValue: matrix.c)
            self.e10 = S15Fixed16Number(representingValue: matrix.e)
            self.e11 = S15Fixed16Number(representingValue: matrix.f)
            self.e12 = S15Fixed16Number(representingValue: matrix.g)
            self.e20 = S15Fixed16Number(representingValue: matrix.i)
            self.e21 = S15Fixed16Number(representingValue: matrix.j)
            self.e22 = S15Fixed16Number(representingValue: matrix.k)
        }
        
        @_versioned
        var matrix: Matrix {
            return Matrix(a: e00.representingValue, b: e01.representingValue, c: e02.representingValue, d: 0,
                          e: e10.representingValue, f: e11.representingValue, g: e12.representingValue, h: 0,
                          i: e20.representingValue, j: e21.representingValue, k: e22.representingValue, l: 0)
        }
    }
    
    @_versioned
    struct Matrix3x4 {
        
        @_versioned
        var m: Matrix3x3
        
        @_versioned
        var e03: S15Fixed16Number
        
        @_versioned
        var e13: S15Fixed16Number
        
        @_versioned
        var e23: S15Fixed16Number
        
        @_versioned
        init(_ matrix: Matrix) {
            self.m = Matrix3x3(matrix)
            self.e03 = S15Fixed16Number(representingValue: matrix.d)
            self.e13 = S15Fixed16Number(representingValue: matrix.h)
            self.e23 = S15Fixed16Number(representingValue: matrix.l)
        }
        
        @_versioned
        var matrix: Matrix {
            return Matrix(a: m.e00.representingValue, b: m.e01.representingValue, c: m.e02.representingValue, d: e03.representingValue,
                          e: m.e10.representingValue, f: m.e11.representingValue, g: m.e12.representingValue, h: e13.representingValue,
                          i: m.e20.representingValue, j: m.e21.representingValue, k: m.e22.representingValue, l: e23.representingValue)
        }
    }
}

extension iccProfile {
    
    @_versioned
    struct ParametricCurve {
        
        @_versioned
        var funcType: BEUInt16
        
        @_versioned
        var padding: BEUInt16
        
        @_versioned
        var gamma: S15Fixed16Number
        
        @_versioned
        var a: S15Fixed16Number
        
        @_versioned
        var b: S15Fixed16Number
        
        @_versioned
        var c: S15Fixed16Number
        
        @_versioned
        var d: S15Fixed16Number
        
        @_versioned
        var e: S15Fixed16Number
        
        @_versioned
        var f: S15Fixed16Number
        
        @_versioned
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
    
    @_versioned
    struct Lut16 {
        
        @_versioned
        var inputChannels: UInt8
        
        @_versioned
        var outputChannels: UInt8
        
        @_versioned
        var grids: UInt8
        
        @_versioned
        var padding: UInt8
        
        @_versioned
        var matrix: Matrix3x3
        
        @_versioned
        var inputEntries: BEUInt16
        
        @_versioned
        var outputEntries: BEUInt16
    }
}

extension iccProfile {
    
    @_versioned
    struct Lut8 {
        
        @_versioned
        var inputChannels: UInt8
        
        @_versioned
        var outputChannels: UInt8
        
        @_versioned
        var grids: UInt8
        
        @_versioned
        var padding: UInt8
        
        @_versioned
        var matrix: Matrix3x3
    }
}

extension iccProfile {
    
    @_versioned
    struct CLUTStruct {
        
        @_versioned
        var grids: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        @_versioned
        var precision: UInt8
        
        @_versioned
        var pad1: UInt8
        
        @_versioned
        var pad2: UInt8
        
        @_versioned
        var pad3: UInt8
    }
}

extension iccProfile {
    
    @_versioned
    struct LutAtoB {
        
        @_versioned
        var inputChannels: UInt8
        
        @_versioned
        var outputChannels: UInt8
        
        @_versioned
        var padding1: UInt8
        
        @_versioned
        var padding2: UInt8
        
        @_versioned
        var offsetB: BEUInt32
        
        @_versioned
        var offsetMatrix: BEUInt32
        
        @_versioned
        var offsetM: BEUInt32
        
        @_versioned
        var offsetCLUT: BEUInt32
        
        @_versioned
        var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    @_versioned
    struct LutBtoA {
        
        @_versioned
        var inputChannels: UInt8
        
        @_versioned
        var outputChannels: UInt8
        
        @_versioned
        var padding1: UInt8
        
        @_versioned
        var padding2: UInt8
        
        @_versioned
        var offsetB: BEUInt32
        
        @_versioned
        var offsetMatrix: BEUInt32
        
        @_versioned
        var offsetM: BEUInt32
        
        @_versioned
        var offsetCLUT: BEUInt32
        
        @_versioned
        var offsetA: BEUInt32
    }
}

extension iccProfile {
    
    @_versioned
    struct LanguageCode: iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt16
        
        @_versioned
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    @_versioned
    struct CountryCode: iccSignatureProtocol {
        
        @_versioned
        var rawValue: BEUInt16
        
        @_versioned
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    @_versioned
    struct MultiLocalizedUnicode {
        
        @_versioned
        var count: BEUInt32
        
        @_versioned
        var size: BEUInt32
        
        @_versioned
        init(count: BEUInt32, size: BEUInt32) {
            self.count = count
            self.size = size
        }
    }
    
    @_versioned
    struct MultiLocalizedUnicodeEntry {
        
        @_versioned
        var language: LanguageCode
        
        @_versioned
        var country: CountryCode
        
        @_versioned
        var length: BEUInt32
        
        @_versioned
        var offset: BEUInt32
        
        @_versioned
        init(language: LanguageCode, country: CountryCode, length: BEUInt32, offset: BEUInt32) {
            self.language = language
            self.country = country
            self.length = length
            self.offset = offset
        }
    }
}


