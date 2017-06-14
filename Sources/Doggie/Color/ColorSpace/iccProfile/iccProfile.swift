//
//  iccProfile.swift
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

import Foundation

public struct iccProfile {
    
    fileprivate let data: Data
    
    public init(_ data: Data) {
        self.data = data
    }
}

extension iccProfile {
    
    public var header: Header {
        get {
            return data.withUnsafeBytes { $0.pointee }
        }
    }
}

extension iccProfile {
    
    public struct Header {
        
        public static let MagicNumber: UInt32 = 0x61637370
        
        private var _size: UInt32                                           /* Profile size in bytes */
        private var _cmmId: UInt32                                          /* CMM for this profile */
        private var _version: UInt32                                        /* Format version number */
        
        private var _deviceClass: UInt32                                    /* Type of profile */
        private var _colorSpace: UInt32                                     /* Color space of data */
        private var _pcs: UInt32                                            /* PCS, XYZ or Lab only */
        
        public var date: DateTimeNumber                                   /* Date profile was created */
        
        private var _magic: UInt32                                          /* icMagicNumber */
        private var _platform: UInt32                                       /* Primary Platform */
        private var _flags: UInt32                                          /* Various bit settings */
        private var _manufacturer: UInt32                                   /* Device manufacturer */
        private var _model: UInt32                                          /* Device model number */
        private var _attributes: UInt64                                     /* Device attributes */
        private var _renderingIntent: UInt32                                /* Rendering intent */
        
        public var illuminant: XYZNumber                                  /* Profile illuminant */
        
        private var _creator: UInt32                                        /* Profile creator */
        public var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        public var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
        public var size: UInt32 {
            get {
                return UInt32(bigEndian: _size)
            }
            set {
                _size = newValue.bigEndian
            }
        }
        public var cmmId: UInt32 {
            get {
                return UInt32(bigEndian: _cmmId)
            }
            set {
                _cmmId = newValue.bigEndian
            }
        }
        public var version: UInt32 {
            get {
                return UInt32(bigEndian: _version)
            }
            set {
                _version = newValue.bigEndian
            }
        }
        
        public var deviceClass: ClassSignature {
            get {
                return ClassSignature(rawValue: UInt32(bigEndian: _deviceClass)) ?? .unknown
            }
            set {
                _deviceClass = newValue.rawValue.bigEndian
            }
        }
        
        public var colorSpace: ColorSpaceSignature {
            get {
                return ColorSpaceSignature(rawValue: UInt32(bigEndian: _colorSpace)) ?? .unknown
            }
            set {
                _colorSpace = newValue.rawValue.bigEndian
            }
        }
        
        public var pcs: ColorSpaceSignature {
            get {
                return ColorSpaceSignature(rawValue: UInt32(bigEndian: _pcs)) ?? .unknown
            }
            set {
                _pcs = newValue.rawValue.bigEndian
            }
        }
        
        public var magic: UInt32 {
            get {
                return UInt32(bigEndian: _magic)
            }
            set {
                _magic = newValue.bigEndian
            }
        }
        public var platform: UInt32 {
            get {
                return UInt32(bigEndian: _platform)
            }
            set {
                _platform = newValue.bigEndian
            }
        }
        public var flags: UInt32 {
            get {
                return UInt32(bigEndian: _flags)
            }
            set {
                _flags = newValue.bigEndian
            }
        }
        public var manufacturer: UInt32 {
            get {
                return UInt32(bigEndian: _manufacturer)
            }
            set {
                _manufacturer = newValue.bigEndian
            }
        }
        public var model: UInt32 {
            get {
                return UInt32(bigEndian: _model)
            }
            set {
                _model = newValue.bigEndian
            }
        }
        public var attributes: UInt64 {
            get {
                return UInt64(bigEndian: _attributes)
            }
            set {
                _attributes = newValue.bigEndian
            }
        }
        public var renderingIntent: UInt32 {
            get {
                return UInt32(bigEndian: _renderingIntent)
            }
            set {
                _renderingIntent = newValue.bigEndian
            }
        }
        
        public var creator: UInt32 {
            get {
                return UInt32(bigEndian: _creator)
            }
            set {
                _creator = newValue.bigEndian
            }
        }
    }
}

extension iccProfile.Header : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.Header(size:\(size), cmmId:\(cmmId), version:\(version), deviceClass:\(deviceClass), colorSpace:\(colorSpace), pcs:\(pcs), date:\(date), magic:\(magic), platform:\(platform), flags:\(flags), manufacturer:\(manufacturer), model:\(model), attributes:\(attributes), renderingIntent:\(renderingIntent), illuminant:\(illuminant), creator:\(creator), profileID:\(profileID))"
    }
}

extension iccProfile.Header {
    
    public enum ClassSignature: UInt32 {
        
        case unknown
        
        case input                     = 0x73636E72  /* 'scnr' */
        case display                   = 0x6D6E7472  /* 'mntr' */
        case output                    = 0x70727472  /* 'prtr' */
        case link                      = 0x6C696E6B  /* 'link' */
        case abstract                  = 0x61627374  /* 'abst' */
        case colorSpace                = 0x73706163  /* 'spac' */
        case namedColor                = 0x6e6d636c  /* 'nmcl' */
    }
    
    public enum ColorSpaceSignature: UInt32 {
        
        case unknown
        
        case XYZ                        = 0x58595A20  /* 'XYZ ' */
        case Lab                        = 0x4C616220  /* 'Lab ' */
        case Luv                        = 0x4C757620  /* 'Luv ' */
        case YCbCr                      = 0x59436272  /* 'YCbr' */
        case Yxy                        = 0x59787920  /* 'Yxy ' */
        case Rgb                        = 0x52474220  /* 'RGB ' */
        case Gray                       = 0x47524159  /* 'GRAY' */
        case Hsv                        = 0x48535620  /* 'HSV ' */
        case Hls                        = 0x484C5320  /* 'HLS ' */
        case Cmyk                       = 0x434D594B  /* 'CMYK' */
        case Cmy                        = 0x434D5920  /* 'CMY ' */
        
        case color2                     = 0x32434C52  /* '2CLR' */
        case color3                     = 0x33434C52  /* '3CLR' */
        case color4                     = 0x34434C52  /* '4CLR' */
        case color5                     = 0x35434C52  /* '5CLR' */
        case color6                     = 0x36434C52  /* '6CLR' */
        case color7                     = 0x37434C52  /* '7CLR' */
        case color8                     = 0x38434C52  /* '8CLR' */
        case color9                     = 0x39434C52  /* '9CLR' */
        case color10                    = 0x41434C52  /* 'ACLR' */
        case color11                    = 0x42434C52  /* 'BCLR' */
        case color12                    = 0x43434C52  /* 'CCLR' */
        case color13                    = 0x44434C52  /* 'DCLR' */
        case color14                    = 0x45434C52  /* 'ECLR' */
        case color15                    = 0x46434C52  /* 'FCLR' */
    }
}

extension iccProfile.Header {
    
    public struct DateTimeNumber {
        
        private var _year: UInt16
        private var _month: UInt16
        private var _day: UInt16
        private var _hours: UInt16
        private var _minutes: UInt16
        private var _seconds: UInt16
        
        public var year: UInt16 {
            get {
                return UInt16(bigEndian: _year)
            }
            set {
                _year = newValue.bigEndian
            }
        }
        public var month: UInt16 {
            get {
                return UInt16(bigEndian: _month)
            }
            set {
                _month = newValue.bigEndian
            }
        }
        public var day: UInt16 {
            get {
                return UInt16(bigEndian: _day)
            }
            set {
                _day = newValue.bigEndian
            }
        }
        public var hours: UInt16 {
            get {
                return UInt16(bigEndian: _hours)
            }
            set {
                _hours = newValue.bigEndian
            }
        }
        public var minutes: UInt16 {
            get {
                return UInt16(bigEndian: _minutes)
            }
            set {
                _minutes = newValue.bigEndian
            }
        }
        public var seconds: UInt16 {
            get {
                return UInt16(bigEndian: _seconds)
            }
            set {
                _seconds = newValue.bigEndian
            }
        }
    }
    
    public struct XYZNumber {
        
        private var _X: UInt32
        private var _Y: UInt32
        private var _Z: UInt32
        
        public var X: Float32 {
            get {
                return Float32(UInt32(bigEndian: _X)) / 65536.0
            }
            set {
                _X = UInt32(newValue * 65536.0).bigEndian
            }
        }
        public var Y: Float32 {
            get {
                return Float32(UInt32(bigEndian: _Y)) / 65536.0
            }
            set {
                _Y = UInt32(newValue * 65536.0).bigEndian
            }
        }
        public var Z: Float32 {
            get {
                return Float32(UInt32(bigEndian: _Z)) / 65536.0
            }
            set {
                _Z = UInt32(newValue * 65536.0).bigEndian
            }
        }
    }
}

extension iccProfile.Header.DateTimeNumber : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.Header.DateTimeNumber(year:\(year), month:\(month), day:\(day), hours:\(hours), minutes:\(minutes), seconds:\(seconds))"
    }
}

extension iccProfile.Header.XYZNumber : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.Header.XYZNumber(X:\(X), Y:\(Y), Z:\(Z))"
    }
}

extension iccProfile : RandomAccessCollection {
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return data[128..<132].withUnsafeBytes { Int(UInt32(bigEndian: $0.pointee)) }
    }
    
    public subscript(position: Int) -> (TagSignature, Data) {
        return _tagData(position: position)
    }
}

extension iccProfile {
    
    public subscript(signature: TagSignature) -> Data? {
        return signature == .unknown ? nil : self.first { $0.0 == signature }?.1
    }
}

extension iccProfile {
    
    fileprivate func _tagData(position: Int) -> (TagSignature, Data) {
        let tag_offset = 132 + 12 * position
        let sig = data[tag_offset..<tag_offset + 4].withUnsafeBytes { TagSignature(rawValue: UInt32(bigEndian: $0.pointee)) ?? .unknown }
        let offset = data[tag_offset + 4..<tag_offset + 8].withUnsafeBytes { UInt32(bigEndian: $0.pointee) }
        let size = data[tag_offset + 8..<tag_offset + 12].withUnsafeBytes { UInt32(bigEndian: $0.pointee) }
        return (sig, data[Int(offset)..<Int(offset + size)])
    }
    
    public enum TagSignature : UInt32 {
        
        case unknown
        
        case AToB0Tag                          = 0x41324230  /* 'A2B0' */
        case AToB1Tag                          = 0x41324231  /* 'A2B1' */
        case AToB2Tag                          = 0x41324232  /* 'A2B2' */
        case BlueColorantTag                   = 0x6258595A  /* 'bXYZ' */
        case BlueTRCTag                        = 0x62545243  /* 'bTRC' */
        case BToA0Tag                          = 0x42324130  /* 'B2A0' */
        case BToA1Tag                          = 0x42324131  /* 'B2A1' */
        case BToA2Tag                          = 0x42324132  /* 'B2A2' */
        case CalibrationDateTimeTag            = 0x63616C74  /* 'calt' */
        case CharTargetTag                     = 0x74617267  /* 'targ' */
        case ChromaticAdaptationTag            = 0x63686164  /* 'chad' */
        case ChromaticityTag                   = 0x6368726D  /* 'chrm' */
        case ColorantOrderTag                  = 0x636C726F  /* 'clro' */
        case ColorantTableTag                  = 0x636C7274  /* 'clrt' */
        case ColorantTableOutTag               = 0x636C6F74  /* 'clot' */
        case ColorimetricIntentImageStateTag   = 0x63696973  /* 'ciis' */
        case CopyrightTag                      = 0x63707274  /* 'cprt' */
        case CrdInfoTag                        = 0x63726469  /* 'crdi' Removed in V4 */
        case DataTag                           = 0x64617461  /* 'data' Removed in V4 */
        case DateTimeTag                       = 0x6474696D  /* 'dtim' Removed in V4 */
        case DeviceMfgDescTag                  = 0x646D6E64  /* 'dmnd' */
        case DeviceModelDescTag                = 0x646D6464  /* 'dmdd' */
        case DeviceSettingsTag                 = 0x64657673  /* 'devs' Removed in V4 */
        case DToB0Tag                          = 0x44324230  /* 'D2B0' */
        case DToB1Tag                          = 0x44324231  /* 'D2B1' */
        case DToB2Tag                          = 0x44324232  /* 'D2B2' */
        case DToB3Tag                          = 0x44324233  /* 'D2B3' */
        case BToD0Tag                          = 0x42324430  /* 'B2D0' */
        case BToD1Tag                          = 0x42324431  /* 'B2D1' */
        case BToD2Tag                          = 0x42324432  /* 'B2D2' */
        case BToD3Tag                          = 0x42324433  /* 'B2D3' */
        case GamutTag                          = 0x67616D74  /* 'gamt' */
        case GrayTRCTag                        = 0x6b545243  /* 'kTRC' */
        case GreenColorantTag                  = 0x6758595A  /* 'gXYZ' */
        case GreenTRCTag                       = 0x67545243  /* 'gTRC' */
        case LuminanceTag                      = 0x6C756d69  /* 'lumi' */
        case MeasurementTag                    = 0x6D656173  /* 'meas' */
        case MediaBlackPointTag                = 0x626B7074  /* 'bkpt' */
        case MediaWhitePointTag                = 0x77747074  /* 'wtpt' */
        case MetaDataTag                       = 0x6D657461  /* 'meta' */
        case NamedColor2Tag                    = 0x6E636C32  /* 'ncl2' */
        case OutputResponseTag                 = 0x72657370  /* 'resp' */
        case PerceptualRenderingIntentGamutTag = 0x72696730  /* 'rig0' */
        case Preview0Tag                       = 0x70726530  /* 'pre0' */
        case Preview1Tag                       = 0x70726531  /* 'pre1' */
        case Preview2Tag                       = 0x70726532  /* 'pre2' */
        case PrintConditionTag                 = 0x7074636e  /* 'ptcn' */
        case ProfileDescriptionTag             = 0x64657363  /* 'desc' */
        case ProfileSequenceDescTag            = 0x70736571  /* 'pseq' */
        case ProfileSequceIdTag                = 0x70736964  /* 'psid' */
        case Ps2CRD0Tag                        = 0x70736430  /* 'psd0' Removed in V4 */
        case Ps2CRD1Tag                        = 0x70736431  /* 'psd1' Removed in V4 */
        case Ps2CRD2Tag                        = 0x70736432  /* 'psd2' Removed in V4 */
        case Ps2CRD3Tag                        = 0x70736433  /* 'psd3' Removed in V4 */
        case Ps2CSATag                         = 0x70733273  /* 'ps2s' Removed in V4 */
        case Ps2RenderingIntentTag             = 0x70733269  /* 'ps2i' Removed in V4 */
        case RedColorantTag                    = 0x7258595A  /* 'rXYZ' */
        case RedTRCTag                         = 0x72545243  /* 'rTRC' */
        case SaturationRenderingIntentGamutTag = 0x72696732  /* 'rig2' */
        case ScreeningDescTag                  = 0x73637264  /* 'scrd' Removed in V4 */
        case ScreeningTag                      = 0x7363726E  /* 'scrn' Removed in V4 */
        case TechnologyTag                     = 0x74656368  /* 'tech' */
        case UcrBgTag                          = 0x62666420  /* 'bfd ' Removed in V4 */
        case ViewingCondDescTag                = 0x76756564  /* 'vued' */
        case ViewingConditionsTag              = 0x76696577  /* 'view' */
    }
}

