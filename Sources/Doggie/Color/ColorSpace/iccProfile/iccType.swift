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
        
        private var _deviceClass: BEUInt32                                   /* Type of profile */
        private var _colorSpace: BEUInt32                                    /* Color space of data */
        private var _pcs: BEUInt32                                           /* PCS, XYZ or Lab only */
        
        public var deviceClass: ClassSignature {
            return ClassSignature(rawValue: self._deviceClass)
        }
        
        public var colorSpace: ColorSpaceSignature {
            return ColorSpaceSignature(rawValue: self._colorSpace)
        }
        
        public var pcs: ColorSpaceSignature {
            return ColorSpaceSignature(rawValue: self._pcs)
        }
        
        public var date: DateTimeNumber                                         /* Date profile was created */
        
        public var magic: BEUInt32                                          /* icMagicNumber */
        public var platform: BEUInt32                                       /* Primary Platform */
        public var flags: BEUInt32                                          /* Various bit settings */
        public var manufacturer: BEUInt32                                   /* Device manufacturer */
        public var model: BEUInt32                                          /* Device model number */
        public var attributes: BEUInt64                                     /* Device attributes */
        public var renderingIntent: BEUInt32                                /* Rendering intent */
        
        public var illuminant: XYZNumber                                        /* Profile illuminant */
        
        public var creator: BEUInt32                                        /* Profile creator */
        public var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        public var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
    }
}

extension iccProfile.Header : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.Header(size: \(size), cmmId: \(cmmId), version: \(version), deviceClass: \(deviceClass), colorSpace: \(colorSpace), pcs: \(pcs), date: \(date), magic: \(magic), platform: \(platform), flags: \(flags), manufacturer: \(manufacturer), model: \(model), attributes: \(attributes), renderingIntent: \(renderingIntent), illuminant: \(illuminant), creator: \(creator), profileID: \(profileID))"
    }
}

public protocol iccSignature: RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible, Hashable {
    
    var rawValue: BEUInt32 { get set }
    
    init(rawValue: BEUInt32)
}

extension iccSignature {
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public init(integerLiteral value: BEUInt32.IntegerLiteralType) {
        self.init(rawValue: BEUInt32(integerLiteral: value))
    }
    
    public var description: String {
        var code = self.rawValue
        return String(bytes: UnsafeRawBufferPointer(start: &code, count: 4), encoding: .ascii) ?? ""
    }
}

extension iccProfile.Header {
    
    public struct ClassSignature: iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let input: ClassSignature                     = 0x73636E72  /* 'scnr' */
        public static let display: ClassSignature                   = 0x6D6E7472  /* 'mntr' */
        public static let output: ClassSignature                    = 0x70727472  /* 'prtr' */
        public static let link: ClassSignature                      = 0x6C696E6B  /* 'link' */
        public static let abstract: ClassSignature                  = 0x61627374  /* 'abst' */
        public static let colorSpace: ClassSignature                = 0x73706163  /* 'spac' */
        public static let namedColor: ClassSignature                = 0x6e6d636c  /* 'nmcl' */
    }
    
    public struct ColorSpaceSignature: iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let XYZ: ColorSpaceSignature                        = 0x58595A20  /* 'XYZ ' */
        public static let Lab: ColorSpaceSignature                        = 0x4C616220  /* 'Lab ' */
        public static let Luv: ColorSpaceSignature                        = 0x4C757620  /* 'Luv ' */
        public static let YCbCr: ColorSpaceSignature                      = 0x59436272  /* 'YCbr' */
        public static let Yxy: ColorSpaceSignature                        = 0x59787920  /* 'Yxy ' */
        public static let Rgb: ColorSpaceSignature                        = 0x52474220  /* 'RGB ' */
        public static let Gray: ColorSpaceSignature                       = 0x47524159  /* 'GRAY' */
        public static let Hsv: ColorSpaceSignature                        = 0x48535620  /* 'HSV ' */
        public static let Hls: ColorSpaceSignature                        = 0x484C5320  /* 'HLS ' */
        public static let Cmyk: ColorSpaceSignature                       = 0x434D594B  /* 'CMYK' */
        public static let Cmy: ColorSpaceSignature                        = 0x434D5920  /* 'CMY ' */
        
        public static let Named: ColorSpaceSignature                      = 0x6e6d636c  /* 'nmcl' */
        
        public static let color2: ColorSpaceSignature                     = 0x32434C52  /* '2CLR' */
        public static let color3: ColorSpaceSignature                     = 0x33434C52  /* '3CLR' */
        public static let color4: ColorSpaceSignature                     = 0x34434C52  /* '4CLR' */
        public static let color5: ColorSpaceSignature                     = 0x35434C52  /* '5CLR' */
        public static let color6: ColorSpaceSignature                     = 0x36434C52  /* '6CLR' */
        public static let color7: ColorSpaceSignature                     = 0x37434C52  /* '7CLR' */
        public static let color8: ColorSpaceSignature                     = 0x38434C52  /* '8CLR' */
        public static let color9: ColorSpaceSignature                     = 0x39434C52  /* '9CLR' */
        public static let color10: ColorSpaceSignature                    = 0x41434C52  /* 'ACLR' */
        public static let color11: ColorSpaceSignature                    = 0x42434C52  /* 'BCLR' */
        public static let color12: ColorSpaceSignature                    = 0x43434C52  /* 'CCLR' */
        public static let color13: ColorSpaceSignature                    = 0x44434C52  /* 'DCLR' */
        public static let color14: ColorSpaceSignature                    = 0x45434C52  /* 'ECLR' */
        public static let color15: ColorSpaceSignature                    = 0x46434C52  /* 'FCLR' */
    }
}

extension iccProfile {
    
    public struct TagSignature : iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let AToB0: TagSignature                          = 0x41324230  /* 'A2B0' */
        public static let AToB1: TagSignature                          = 0x41324231  /* 'A2B1' */
        public static let AToB2: TagSignature                          = 0x41324232  /* 'A2B2' */
        public static let BlueColorant: TagSignature                   = 0x6258595A  /* 'bXYZ' */
        public static let BlueTRC: TagSignature                        = 0x62545243  /* 'bTRC' */
        public static let BToA0: TagSignature                          = 0x42324130  /* 'B2A0' */
        public static let BToA1: TagSignature                          = 0x42324131  /* 'B2A1' */
        public static let BToA2: TagSignature                          = 0x42324132  /* 'B2A2' */
        public static let CalibrationDateTime: TagSignature            = 0x63616C74  /* 'calt' */
        public static let CharTarget: TagSignature                     = 0x74617267  /* 'targ' */
        public static let ChromaticAdaptation: TagSignature            = 0x63686164  /* 'chad' */
        public static let Chromaticity: TagSignature                   = 0x6368726D  /* 'chrm' */
        public static let ColorantOrder: TagSignature                  = 0x636C726F  /* 'clro' */
        public static let ColorantTable: TagSignature                  = 0x636C7274  /* 'clrt' */
        public static let ColorantTableOut: TagSignature               = 0x636C6F74  /* 'clot' */
        public static let ColorimetricIntentImageState: TagSignature   = 0x63696973  /* 'ciis' */
        public static let Copyright: TagSignature                      = 0x63707274  /* 'cprt' */
        public static let CrdInfo: TagSignature                        = 0x63726469  /* 'crdi' Removed in V4 */
        public static let Data: TagSignature                           = 0x64617461  /* 'data' Removed in V4 */
        public static let DateTime: TagSignature                       = 0x6474696D  /* 'dtim' Removed in V4 */
        public static let DeviceMfgDesc: TagSignature                  = 0x646D6E64  /* 'dmnd' */
        public static let DeviceModelDesc: TagSignature                = 0x646D6464  /* 'dmdd' */
        public static let DeviceSettings: TagSignature                 = 0x64657673  /* 'devs' Removed in V4 */
        public static let DToB0: TagSignature                          = 0x44324230  /* 'D2B0' */
        public static let DToB1: TagSignature                          = 0x44324231  /* 'D2B1' */
        public static let DToB2: TagSignature                          = 0x44324232  /* 'D2B2' */
        public static let DToB3: TagSignature                          = 0x44324233  /* 'D2B3' */
        public static let BToD0: TagSignature                          = 0x42324430  /* 'B2D0' */
        public static let BToD1: TagSignature                          = 0x42324431  /* 'B2D1' */
        public static let BToD2: TagSignature                          = 0x42324432  /* 'B2D2' */
        public static let BToD3: TagSignature                          = 0x42324433  /* 'B2D3' */
        public static let Gamut: TagSignature                          = 0x67616D74  /* 'gamt' */
        public static let GrayTRC: TagSignature                        = 0x6b545243  /* 'kTRC' */
        public static let GreenColorant: TagSignature                  = 0x6758595A  /* 'gXYZ' */
        public static let GreenTRC: TagSignature                       = 0x67545243  /* 'gTRC' */
        public static let Luminance: TagSignature                      = 0x6C756d69  /* 'lumi' */
        public static let Measurement: TagSignature                    = 0x6D656173  /* 'meas' */
        public static let MediaBlackPoint: TagSignature                = 0x626B7074  /* 'bkpt' */
        public static let MediaWhitePoint: TagSignature                = 0x77747074  /* 'wtpt' */
        public static let MetaData: TagSignature                       = 0x6D657461  /* 'meta' */
        public static let NamedColor2: TagSignature                    = 0x6E636C32  /* 'ncl2' */
        public static let OutputResponse: TagSignature                 = 0x72657370  /* 'resp' */
        public static let PerceptualRenderingIntentGamut: TagSignature = 0x72696730  /* 'rig0' */
        public static let Preview0: TagSignature                       = 0x70726530  /* 'pre0' */
        public static let Preview1: TagSignature                       = 0x70726531  /* 'pre1' */
        public static let Preview2: TagSignature                       = 0x70726532  /* 'pre2' */
        public static let PrintCondition: TagSignature                 = 0x7074636e  /* 'ptcn' */
        public static let ProfileDescription: TagSignature             = 0x64657363  /* 'desc' */
        public static let ProfileSequenceDesc: TagSignature            = 0x70736571  /* 'pseq' */
        public static let ProfileSequceId: TagSignature                = 0x70736964  /* 'psid' */
        public static let Ps2CRD0: TagSignature                        = 0x70736430  /* 'psd0' Removed in V4 */
        public static let Ps2CRD1: TagSignature                        = 0x70736431  /* 'psd1' Removed in V4 */
        public static let Ps2CRD2: TagSignature                        = 0x70736432  /* 'psd2' Removed in V4 */
        public static let Ps2CRD3: TagSignature                        = 0x70736433  /* 'psd3' Removed in V4 */
        public static let Ps2CSA: TagSignature                         = 0x70733273  /* 'ps2s' Removed in V4 */
        public static let Ps2RenderingIntent: TagSignature             = 0x70733269  /* 'ps2i' Removed in V4 */
        public static let RedColorant: TagSignature                    = 0x7258595A  /* 'rXYZ' */
        public static let RedTRC: TagSignature                         = 0x72545243  /* 'rTRC' */
        public static let SaturationRenderingIntentGamut: TagSignature = 0x72696732  /* 'rig2' */
        public static let ScreeningDesc: TagSignature                  = 0x73637264  /* 'scrd' Removed in V4 */
        public static let Screening: TagSignature                      = 0x7363726E  /* 'scrn' Removed in V4 */
        public static let Technology: TagSignature                     = 0x74656368  /* 'tech' */
        public static let UcrBg: TagSignature                          = 0x62666420  /* 'bfd ' Removed in V4 */
        public static let ViewingCondDesc: TagSignature                = 0x76756564  /* 'vued' */
        public static let ViewingConditions: TagSignature              = 0x76696577  /* 'view' */
    }
}

extension iccProfile.TagData {
    
    public struct `Type` : iccSignature {
        
        public var rawValue: BEUInt32
        
        public init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        public static let Chromaticity: Type               = 0x6368726D  /* 'chrm' */
        public static let ColorantOrder: Type              = 0x636C726F  /* 'clro' */
        public static let ColorantTable: Type              = 0x636C7274  /* 'clrt' */
        public static let CrdInfo: Type                    = 0x63726469  /* 'crdi' Removed in V4 */
        public static let Curve: Type                      = 0x63757276  /* 'curv' */
        public static let Data: Type                       = 0x64617461  /* 'data' */
        public static let Dict: Type                       = 0x64696374  /* 'dict' */
        public static let DateTime: Type                   = 0x6474696D  /* 'dtim' */
        public static let DeviceSettings: Type             = 0x64657673  /* 'devs' Removed in V4 */
        public static let Lut16: Type                      = 0x6d667432  /* 'mft2' */
        public static let Lut8: Type                       = 0x6d667431  /* 'mft1' */
        public static let LutAtoB: Type                    = 0x6d414220  /* 'mAB ' */
        public static let LutBtoA: Type                    = 0x6d424120  /* 'mBA ' */
        public static let Measurement: Type                = 0x6D656173  /* 'meas' */
        public static let MultiLocalizedUnicode: Type      = 0x6D6C7563  /* 'mluc' */
        public static let MultiProcessElement: Type        = 0x6D706574  /* 'mpet' */
        public static let NamedColor2: Type                = 0x6E636C32  /* 'ncl2' */
        public static let ParametricCurve: Type            = 0x70617261  /* 'para' */
        public static let ProfileSequenceDesc: Type        = 0x70736571  /* 'pseq' */
        public static let ProfileSequceId: Type            = 0x70736964  /* 'psid' */
        public static let ResponseCurveSet16: Type         = 0x72637332  /* 'rcs2' */
        public static let S15Fixed16Array: Type            = 0x73663332  /* 'sf32' */
        public static let Screening: Type                  = 0x7363726E  /* 'scrn' Removed in V4 */
        public static let Signature: Type                  = 0x73696720  /* 'sig ' */
        public static let Text: Type                       = 0x74657874  /* 'text' */
        public static let TextDescription: Type            = 0x64657363  /* 'desc' Removed in V4 */
        public static let U16Fixed16Array: Type            = 0x75663332  /* 'uf32' */
        public static let UcrBg: Type                      = 0x62666420  /* 'bfd ' Removed in V4 */
        public static let UInt16Array: Type                = 0x75693136  /* 'ui16' */
        public static let UInt32Array: Type                = 0x75693332  /* 'ui32' */
        public static let UInt64Array: Type                = 0x75693634  /* 'ui64' */
        public static let UInt8Array: Type                 = 0x75693038  /* 'ui08' */
        public static let ViewingConditions: Type          = 0x76696577  /* 'view' */
        public static let XYZArray: Type                   = 0x58595A20  /* 'XYZ ' */
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

