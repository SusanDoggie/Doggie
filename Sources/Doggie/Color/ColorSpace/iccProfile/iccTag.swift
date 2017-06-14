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
        
        case AToB0                          = 0x41324230  /* 'A2B0' */
        case AToB1                          = 0x41324231  /* 'A2B1' */
        case AToB2                          = 0x41324232  /* 'A2B2' */
        case BlueColorant                   = 0x6258595A  /* 'bXYZ' */
        case BlueTRC                        = 0x62545243  /* 'bTRC' */
        case BToA0                          = 0x42324130  /* 'B2A0' */
        case BToA1                          = 0x42324131  /* 'B2A1' */
        case BToA2                          = 0x42324132  /* 'B2A2' */
        case CalibrationDateTime            = 0x63616C74  /* 'calt' */
        case CharTarget                     = 0x74617267  /* 'targ' */
        case ChromaticAdaptation            = 0x63686164  /* 'chad' */
        case Chromaticity                   = 0x6368726D  /* 'chrm' */
        case ColorantOrder                  = 0x636C726F  /* 'clro' */
        case ColorantTable                  = 0x636C7274  /* 'clrt' */
        case ColorantTableOut               = 0x636C6F74  /* 'clot' */
        case ColorimetricIntentImageStateTag   = 0x63696973  /* 'ciis' */
        case Copyright                      = 0x63707274  /* 'cprt' */
        case CrdInfo                        = 0x63726469  /* 'crdi' Removed in V4 */
        case Data                           = 0x64617461  /* 'data' Removed in V4 */
        case DateTime                       = 0x6474696D  /* 'dtim' Removed in V4 */
        case DeviceMfgDesc                  = 0x646D6E64  /* 'dmnd' */
        case DeviceModelDesc                = 0x646D6464  /* 'dmdd' */
        case DeviceSettings                 = 0x64657673  /* 'devs' Removed in V4 */
        case DToB0                          = 0x44324230  /* 'D2B0' */
        case DToB1                          = 0x44324231  /* 'D2B1' */
        case DToB2                          = 0x44324232  /* 'D2B2' */
        case DToB3                          = 0x44324233  /* 'D2B3' */
        case BToD0                          = 0x42324430  /* 'B2D0' */
        case BToD1                          = 0x42324431  /* 'B2D1' */
        case BToD2                          = 0x42324432  /* 'B2D2' */
        case BToD3                          = 0x42324433  /* 'B2D3' */
        case Gamut                          = 0x67616D74  /* 'gamt' */
        case GrayTRC                        = 0x6b545243  /* 'kTRC' */
        case GreenColorant                  = 0x6758595A  /* 'gXYZ' */
        case GreenTRC                       = 0x67545243  /* 'gTRC' */
        case Luminance                      = 0x6C756d69  /* 'lumi' */
        case Measurement                    = 0x6D656173  /* 'meas' */
        case MediaBlackPoint                = 0x626B7074  /* 'bkpt' */
        case MediaWhitePoint                = 0x77747074  /* 'wtpt' */
        case MetaData                       = 0x6D657461  /* 'meta' */
        case NamedColor2                    = 0x6E636C32  /* 'ncl2' */
        case OutputResponse                 = 0x72657370  /* 'resp' */
        case PerceptualRenderingIntentGamutTag = 0x72696730  /* 'rig0' */
        case Preview0                       = 0x70726530  /* 'pre0' */
        case Preview1                       = 0x70726531  /* 'pre1' */
        case Preview2                       = 0x70726532  /* 'pre2' */
        case PrintCondition                 = 0x7074636e  /* 'ptcn' */
        case ProfileDescription             = 0x64657363  /* 'desc' */
        case ProfileSequenceDesc            = 0x70736571  /* 'pseq' */
        case ProfileSequceId                = 0x70736964  /* 'psid' */
        case Ps2CRD0                        = 0x70736430  /* 'psd0' Removed in V4 */
        case Ps2CRD1                        = 0x70736431  /* 'psd1' Removed in V4 */
        case Ps2CRD2                        = 0x70736432  /* 'psd2' Removed in V4 */
        case Ps2CRD3                        = 0x70736433  /* 'psd3' Removed in V4 */
        case Ps2CSA                         = 0x70733273  /* 'ps2s' Removed in V4 */
        case Ps2RenderingIntent             = 0x70733269  /* 'ps2i' Removed in V4 */
        case RedColorant                    = 0x7258595A  /* 'rXYZ' */
        case RedTRC                         = 0x72545243  /* 'rTRC' */
        case SaturationRenderingIntentGamutTag = 0x72696732  /* 'rig2' */
        case ScreeningDesc                  = 0x73637264  /* 'scrd' Removed in V4 */
        case Screening                      = 0x7363726E  /* 'scrn' Removed in V4 */
        case Technology                     = 0x74656368  /* 'tech' */
        case UcrBg                          = 0x62666420  /* 'bfd ' Removed in V4 */
        case ViewingCondDesc                = 0x76756564  /* 'vued' */
        case ViewingConditions              = 0x76696577  /* 'view' */
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
        
        switch type {
        case .UInt16Array: return "\(uInt16Array ?? []))"
        case .UInt32Array: return "\(uInt32Array ?? []))"
        case .UInt64Array: return "\(uInt64Array ?? []))"
        case .UInt8Array: return "\(uInt8Array ?? []))"
        case .S15Fixed16Array: return "\(s15Fixed16Array ?? []))"
        case .U16Fixed16Array: return "\(u16Fixed16Array ?? []))"
        case .XYZArray: return "\(XYZArray ?? []))"
        default: return "TagData(type:\(type), data:\(data))"
        }
    }
}

extension iccProfile.TagData {
    
    public var uInt16Array: [iccProfile.UInt16Number]? {
        
        return type == .UInt16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.UInt16Number>.stride)) } : nil
    }
    
    public var uInt32Array: [iccProfile.UInt32Number]? {
        
        return type == .UInt32Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.UInt32Number>.stride)) } : nil
    }
    
    public var uInt64Array: [iccProfile.UInt64Number]? {
        
        return type == .UInt64Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.UInt64Number>.stride)) } : nil
    }
    
    public var uInt8Array: [UInt8]? {
        
        return type == .UInt8Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<UInt8>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public var s15Fixed16Array: [iccProfile.S15Fixed16Number]? {
        
        return type == .S15Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.S15Fixed16Number>.stride)) } : nil
    }
    
    public var u16Fixed16Array: [iccProfile.U16Fixed16Number]? {
        
        return type == .U16Fixed16Array ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.U16Fixed16Number>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public var XYZArray: [iccProfile.XYZNumber]? {
        
        return type == .XYZArray ? data.withUnsafeBytes { Array(UnsafeBufferPointer(start: $0, count: data.count / MemoryLayout<iccProfile.XYZNumber>.stride)) } : nil
    }
}

extension iccProfile.TagData {
    
    public enum `Type` : iccProfile.UInt32Number {
        
        case unknown
        
        case Chromaticity               = 0x6368726D  /* 'chrm' */
        case ColorantOrder              = 0x636C726F  /* 'clro' */
        case ColorantTable              = 0x636C7274  /* 'clrt' */
        case CrdInfo                    = 0x63726469  /* 'crdi' Removed in V4 */
        case Curve                      = 0x63757276  /* 'curv' */
        case Data                       = 0x64617461  /* 'data' */
        case Dict                       = 0x64696374  /* 'dict' */
        case DateTime                   = 0x6474696D  /* 'dtim' */
        case DeviceSettings             = 0x64657673  /* 'devs' Removed in V4 */
        case Lut16                      = 0x6d667432  /* 'mft2' */
        case Lut8                       = 0x6d667431  /* 'mft1' */
        case LutAtoB                    = 0x6d414220  /* 'mAB ' */
        case LutBtoA                    = 0x6d424120  /* 'mBA ' */
        case Measurement                = 0x6D656173  /* 'meas' */
        case MultiLocalizedUnicodeType      = 0x6D6C7563  /* 'mluc' */
        case MultiProcessElementType        = 0x6D706574  /* 'mpet' */
        case NamedColor2                = 0x6E636C32  /* 'ncl2' */
        case ParametricCurve            = 0x70617261  /* 'para' */
        case ProfileSequenceDescType        = 0x70736571  /* 'pseq' */
        case ProfileSequceId            = 0x70736964  /* 'psid' */
        case ResponseCurveSet16         = 0x72637332  /* 'rcs2' */
        case S15Fixed16Array            = 0x73663332  /* 'sf32' */
        case Screening                  = 0x7363726E  /* 'scrn' Removed in V4 */
        case Signature                  = 0x73696720  /* 'sig ' */
        case Text                       = 0x74657874  /* 'text' */
        case TextDescription            = 0x64657363  /* 'desc' Removed in V4 */
        case U16Fixed16Array            = 0x75663332  /* 'uf32' */
        case UcrBg                      = 0x62666420  /* 'bfd ' Removed in V4 */
        case UInt16Array                = 0x75693136  /* 'ui16' */
        case UInt32Array                = 0x75693332  /* 'ui32' */
        case UInt64Array                = 0x75693634  /* 'ui64' */
        case UInt8Array                 = 0x75693038  /* 'ui08' */
        case ViewingConditions          = 0x76696577  /* 'view' */
        case XYZArray                   = 0x58595A20  /* 'XYZ ' */
    }
}
