//
//  iccTag.swift
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

extension iccProfile : RandomAccessCollection {
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return data[128..<132].withUnsafeBytes { Int(UInt32(bigEndian: $0.pointee)) }
    }
    
    public subscript(position: Int) -> (TagSignature, TagData) {
        return _tagData(position: position)
    }
}

extension iccProfile {
    
    public subscript(signature: TagSignature) -> TagData? {
        return signature == .unknown ? nil : self.first { $0.0 == signature }?.1
    }
}

extension iccProfile {
    
    fileprivate func _tagData(position: Int) -> (TagSignature, TagData) {
        let tag_offset = 132 + 12 * position
        let sig = data[tag_offset..<tag_offset + 4].withUnsafeBytes { TagSignature(rawValue: $0.pointee) } ?? .unknown
        let offset = data[tag_offset + 4..<tag_offset + 8].withUnsafeBytes { $0.pointee as UInt32Number }.rawValue
        let size = data[tag_offset + 8..<tag_offset + 12].withUnsafeBytes { $0.pointee as UInt32Number }.rawValue
        return (sig, TagData(_data: data[Int(offset)..<Int(offset + size)]))
    }
    
    public enum TagSignature : UInt32Number {
        
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

extension iccProfile {
    
    public struct TagData {
        
        fileprivate let _data: Data
        
        fileprivate init(_data: Data) {
            self._data = _data
        }
        
        public var type: Type {
            return Type(rawValue: header.signature) ?? .unknown
        }
        
        public var data: Data {
            return _data.dropFirst(8)
        }
    }
}

extension iccProfile.TagData {
    
    public struct Header {
        
        public var signature: iccProfile.UInt32Number            /* Signature */
        public var reserved: (UInt8, UInt8, UInt8, UInt8)
    }
    
    public var header: Header {
        return _data.withUnsafeBytes { $0.pointee }
    }
}

extension iccProfile.TagData : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.TagData(type:\(type), data:\(data))"
    }
}

extension iccProfile.TagData {
    
    public enum `Type` : iccProfile.UInt32Number {
        
        case unknown
        
        case ChromaticityType               = 0x6368726D  /* 'chrm' */
        case ColorantOrderType              = 0x636C726F  /* 'clro' */
        case ColorantTableType              = 0x636C7274  /* 'clrt' */
        case CrdInfoType                    = 0x63726469  /* 'crdi' Removed in V4 */
        case CurveType                      = 0x63757276  /* 'curv' */
        case DataType                       = 0x64617461  /* 'data' */
        case DictType                       = 0x64696374  /* 'dict' */
        case DateTimeType                   = 0x6474696D  /* 'dtim' */
        case DeviceSettingsType             = 0x64657673  /* 'devs' Removed in V4 */
        case Lut16Type                      = 0x6d667432  /* 'mft2' */
        case Lut8Type                       = 0x6d667431  /* 'mft1' */
        case LutAtoBType                    = 0x6d414220  /* 'mAB ' */
        case LutBtoAType                    = 0x6d424120  /* 'mBA ' */
        case MeasurementType                = 0x6D656173  /* 'meas' */
        case MultiLocalizedUnicodeType      = 0x6D6C7563  /* 'mluc' */
        case MultiProcessElementType        = 0x6D706574  /* 'mpet' */
        case NamedColor2Type                = 0x6E636C32  /* 'ncl2' */
        case ParametricCurveType            = 0x70617261  /* 'para' */
        case ProfileSequenceDescType        = 0x70736571  /* 'pseq' */
        case ProfileSequceIdType            = 0x70736964  /* 'psid' */
        case ResponseCurveSet16Type         = 0x72637332  /* 'rcs2' */
        case S15Fixed16ArrayType            = 0x73663332  /* 'sf32' */
        case ScreeningType                  = 0x7363726E  /* 'scrn' Removed in V4 */
        case SignatureType                  = 0x73696720  /* 'sig ' */
        case TextType                       = 0x74657874  /* 'text' */
        case TextDescriptionType            = 0x64657363  /* 'desc' Removed in V4 */
        case U16Fixed16ArrayType            = 0x75663332  /* 'uf32' */
        case UcrBgType                      = 0x62666420  /* 'bfd ' Removed in V4 */
        case UInt16ArrayType                = 0x75693136  /* 'ui16' */
        case UInt32ArrayType                = 0x75693332  /* 'ui32' */
        case UInt64ArrayType                = 0x75693634  /* 'ui64' */
        case UInt8ArrayType                 = 0x75693038  /* 'ui08' */
        case ViewingConditionsType          = 0x76696577  /* 'view' */
        case XYZType                        = 0x58595A20  /* 'XYZ ' */
    }
}
