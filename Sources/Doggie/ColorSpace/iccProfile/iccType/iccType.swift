//
//  iccType.swift
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

extension iccProfile {
    
    struct Header : ByteCodable {
        
        static let MagicNumber: Signature<BEUInt32> = "acsp"
        
        var size: BEUInt32                                                     /* Profile size in bytes */
        var cmmId: Signature<BEUInt32>                                         /* CMM for this profile */
        var version: BEUInt32                                                  /* Format version number */
        var deviceClass: ClassSignature                                        /* Type of profile */
        var colorSpace: ColorSpaceSignature                                    /* Color space of data */
        var pcs: ColorSpaceSignature                                           /* PCS, XYZ or Lab only */
        var date: iccDateTimeNumber                                            /* Date profile was created */
        var magic: Signature<BEUInt32>                                         /* icMagicNumber */
        var platform: Signature<BEUInt32>                                      /* Primary Platform */
        var flags: BEUInt32                                                    /* Various bit settings */
        var manufacturer: Signature<BEUInt32>                                  /* Device manufacturer */
        var model: Signature<BEUInt32>                                         /* Device model number */
        var attributes: BEUInt64                                               /* Device attributes */
        var renderingIntent: BEUInt32                                          /* Rendering intent */
        var illuminant: iccXYZNumber                                           /* Profile illuminant */
        var creator: Signature<BEUInt32>                                       /* Profile creator */
        var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
        init(cmmId: Signature<BEUInt32>,
             version: BEUInt32,
             deviceClass: ClassSignature,
             colorSpace: ColorSpaceSignature,
             pcs: ColorSpaceSignature,
             date: iccDateTimeNumber,
             platform: Signature<BEUInt32>,
             flags: BEUInt32,
             manufacturer: Signature<BEUInt32>,
             model: Signature<BEUInt32>,
             attributes: BEUInt64,
             renderingIntent: BEUInt32,
             illuminant: iccXYZNumber,
             creator: Signature<BEUInt32>) {
            
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
        
        init(from data: inout Data) throws {
            self.size = try data.decode(BEUInt32.self)
            self.cmmId = try data.decode(Signature.self)
            self.version = try data.decode(BEUInt32.self)
            self.deviceClass = try data.decode(ClassSignature.self)
            self.colorSpace = try data.decode(ColorSpaceSignature.self)
            self.pcs = try data.decode(ColorSpaceSignature.self)
            self.date = try data.decode(iccDateTimeNumber.self)
            self.magic = try data.decode(Signature.self)
            self.platform = try data.decode(Signature.self)
            self.flags = try data.decode(BEUInt32.self)
            self.manufacturer = try data.decode(Signature.self)
            self.model = try data.decode(Signature.self)
            self.attributes = try data.decode(BEUInt64.self)
            self.renderingIntent = try data.decode(BEUInt32.self)
            self.illuminant = try data.decode(iccXYZNumber.self)
            self.creator = try data.decode(Signature.self)
            self.profileID = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                              try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                              try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                              try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
            self.reserved = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                             try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
        }
        
        func encode<C : RangeReplaceableCollection>(to data: inout C) where C.Element == UInt8 {
            data.encode(size)
            data.encode(cmmId)
            data.encode(version)
            data.encode(deviceClass)
            data.encode(colorSpace)
            data.encode(pcs)
            data.encode(date)
            data.encode(magic)
            data.encode(platform)
            data.encode(flags)
            data.encode(manufacturer)
            data.encode(model)
            data.encode(attributes)
            data.encode(renderingIntent)
            data.encode(illuminant)
            data.encode(creator)
            data.encode(profileID.0, profileID.1, profileID.2, profileID.3,
                        profileID.4, profileID.5, profileID.6, profileID.7,
                        profileID.8, profileID.9, profileID.10, profileID.11,
                        profileID.12, profileID.13, profileID.14, profileID.15)
            data.encode(reserved.0, reserved.1, reserved.2, reserved.3,
                        reserved.4, reserved.5, reserved.6, reserved.7,
                        reserved.8, reserved.9, reserved.10, reserved.11,
                        reserved.12, reserved.13, reserved.14, reserved.15,
                        reserved.16, reserved.17, reserved.18, reserved.19,
                        reserved.20, reserved.21, reserved.22, reserved.23,
                        reserved.24, reserved.25, reserved.26, reserved.27)
        }
    }
}

extension iccProfile.Header {
    
    struct ClassSignature: SignatureProtocol {
        
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
    
    struct ColorSpaceSignature: SignatureProtocol {
        
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
    
    struct TagSignature : SignatureProtocol {
        
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

extension iccProfile {
    
    struct TagType : SignatureProtocol {
        
        var rawValue: BEUInt32
        
        init(rawValue: BEUInt32) {
            self.rawValue = rawValue
        }
        
        static let chromaticity: TagType               = "chrm"
        static let colorantOrder: TagType              = "clro"
        static let colorantTable: TagType              = "clrt"
        static let crdInfo: TagType                    = "crdi"  /* Removed in V4 */
        static let curve: TagType                      = "curv"
        static let data: TagType                       = "data"
        static let dict: TagType                       = "dict"
        static let dateTime: TagType                   = "dtim"
        static let deviceSettings: TagType             = "devs"  /* Removed in V4 */
        static let lut16: TagType                      = "mft2"
        static let lut8: TagType                       = "mft1"
        static let lutAtoB: TagType                    = "mAB "
        static let lutBtoA: TagType                    = "mBA "
        static let measurement: TagType                = "meas"
        static let multiLocalizedUnicode: TagType      = "mluc"
        static let multiProcessElement: TagType        = "mpet"
        static let namedColor2: TagType                = "ncl2"
        static let parametricCurve: TagType            = "para"
        static let profileSequenceDesc: TagType        = "pseq"
        static let profileSequceId: TagType            = "psid"
        static let responseCurveSet16: TagType         = "rcs2"
        static let s15Fixed16Array: TagType            = "sf32"
        static let screening: TagType                  = "scrn"  /* Removed in V4 */
        static let signature: TagType                  = "sig "
        static let text: TagType                       = "text"
        static let textDescription: TagType            = "desc"  /* Removed in V4 */
        static let u16Fixed16Array: TagType            = "uf32"
        static let ucrBg: TagType                      = "bfd "  /* Removed in V4 */
        static let uInt16Array: TagType                = "ui16"
        static let uInt32Array: TagType                = "ui32"
        static let uInt64Array: TagType                = "ui64"
        static let uInt8Array: TagType                 = "ui08"
        static let viewingConditions: TagType          = "view"
        static let XYZArray: TagType                   = "XYZ "
    }
}

