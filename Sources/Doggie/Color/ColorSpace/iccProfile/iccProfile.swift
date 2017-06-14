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
    
    public let data: Data
    
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
        
        public static let MagicNumber: UInt32Number = 0x61637370
        
        public var size: UInt32Number                                           /* Profile size in bytes */
        public var cmmId: UInt32Number                                          /* CMM for this profile */
        public var version: UInt32Number                                        /* Format version number */
        
        private var _deviceClass: UInt32Number                                   /* Type of profile */
        private var _colorSpace: UInt32Number                                    /* Color space of data */
        private var _pcs: UInt32Number                                           /* PCS, XYZ or Lab only */
        
        public var deviceClass: ClassSignature {
            get {
                return ClassSignature(rawValue: _deviceClass) ?? .unknown
            }
            set {
                _deviceClass = newValue.rawValue
            }
        }
        public var colorSpace: ColorSpaceSignature {
            get {
                return ColorSpaceSignature(rawValue: _colorSpace) ?? .unknown
            }
            set {
                _colorSpace = newValue.rawValue
            }
        }
        public var pcs: ColorSpaceSignature {
            get {
                return ColorSpaceSignature(rawValue: _pcs) ?? .unknown
            }
            set {
                _pcs = newValue.rawValue
            }
        }
        
        public var date: DateTimeNumber                                         /* Date profile was created */
        
        public var magic: UInt32Number                                          /* icMagicNumber */
        public var platform: UInt32Number                                       /* Primary Platform */
        public var flags: UInt32Number                                          /* Various bit settings */
        public var manufacturer: UInt32Number                                   /* Device manufacturer */
        public var model: UInt32Number                                          /* Device model number */
        public var attributes: UInt64Number                                     /* Device attributes */
        public var renderingIntent: UInt32Number                                /* Rendering intent */
        
        public var illuminant: XYZNumber                                        /* Profile illuminant */
        
        public var creator: UInt32Number                                        /* Profile creator */
        public var profileID: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Profile ID using RFC 1321 MD5 128bit fingerprinting */
        public var reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)   /* Reserved for future use */
        
    }
}

extension iccProfile.Header : CustomStringConvertible {
    
    public var description: String {
        return "iccProfile.Header(size:\(size), cmmId:\(cmmId), version:\(version), deviceClass:\(deviceClass), colorSpace:\(colorSpace), pcs:\(pcs), date:\(date), magic:\(magic), platform:\(platform), flags:\(flags), manufacturer:\(manufacturer), model:\(model), attributes:\(attributes), renderingIntent:\(renderingIntent), illuminant:\(illuminant), creator:\(creator), profileID:\(profileID))"
    }
}

extension iccProfile.Header {
    
    public enum ClassSignature: iccProfile.UInt32Number {
        
        case unknown
        
        case input                     = 0x73636E72  /* 'scnr' */
        case display                   = 0x6D6E7472  /* 'mntr' */
        case output                    = 0x70727472  /* 'prtr' */
        case link                      = 0x6C696E6B  /* 'link' */
        case abstract                  = 0x61627374  /* 'abst' */
        case colorSpace                = 0x73706163  /* 'spac' */
        case namedColor                = 0x6e6d636c  /* 'nmcl' */
    }
    
    public enum ColorSpaceSignature: iccProfile.UInt32Number {
        
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

