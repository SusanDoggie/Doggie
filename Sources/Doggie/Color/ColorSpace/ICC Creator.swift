//
//  ICC Creator.swift
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

@_versioned
let PCSXYZ = CIEXYZColorSpace(white: XYZColorModel(luminance: 1, x: 0.34567, y: 0.35850), black: XYZColorModel())

extension iccProfile {
    
    @_versioned
    mutating func setMessage(_ tag: TagSignature, _ message: (LanguageCode, CountryCode, String) ...) {
        
        var header = Data(count: MemoryLayout<MultiLocalizedUnicode>.stride + 8)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.Type.MultiLocalizedUnicode, 0 as BEUInt32, MultiLocalizedUnicode(count: BEUInt32(message.count), size: BEUInt32(MemoryLayout<MultiLocalizedUnicodeEntry>.stride))) }
        
        let entry_size = message.count * MemoryLayout<MultiLocalizedUnicodeEntry>.stride
        var entry = Data(count: entry_size)
        var data = Data()
        
        entry.withUnsafeMutableBytes { (entry: UnsafeMutablePointer<MultiLocalizedUnicodeEntry>) in
            var entry = entry
            var offset = MemoryLayout<MultiLocalizedUnicode>.stride + entry_size + 8
            for (language, country, string) in message {
                var strData = string.data(using: .utf16BigEndian)!
                data.append(strData)
                entry.pointee = MultiLocalizedUnicodeEntry(language: language, country: country, length: BEUInt32(strData.count), offset: BEUInt32(offset))
                offset += strData.count
                entry += 1
            }
        }
        
        self[tag] = TagData(rawData: header + entry + data)
    }
    
    @_versioned
    mutating func setFloat(_ tag: TagSignature, _ value: iccProfile.S15Fixed16Number ...) {
        
        var data = Data(count: 8)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.Type.S15Fixed16Array, 0 as BEUInt32) }
        
        data.append(UnsafeBufferPointer(start: value, count: value.count))
        
        self[tag] = TagData(rawData: data)
    }
    
    @_versioned
    mutating func setXYZ(_ tag: TagSignature, _ xyz: XYZNumber ...) {
        
        var data = Data(count: 8)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.Type.XYZArray, 0 as BEUInt32) }
        
        data.append(UnsafeBufferPointer(start: xyz, count: xyz.count))
        
        self[tag] = TagData(rawData: data)
    }
    
    @_versioned
    mutating func setParametricCurve(_ tag: TagSignature, curve: ParametricCurve) {
        
        var data = Data(count: 12)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.Type.ParametricCurve, 0 as BEUInt32, curve.funcType, 0 as BEUInt32) }
        
        switch curve.funcType {
        case 0: data.append(UnsafeBufferPointer(start: [curve.gamma], count: 1))
        case 1: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b], count: 3))
        case 2: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c], count: 4))
        case 3: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c, curve.d], count: 5))
        case 4: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c, curve.d, curve.e, curve.f], count: 7))
        default: fatalError()
        }
        
        self[tag] = TagData(rawData: data)
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    @_inlineable
    func _iccProfile(deviceClass: iccProfile.Header.ClassSignature, colorSpace: iccProfile.Header.ColorSpaceSignature) -> iccProfile {
        
        let date = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: Date())
        
        let header = iccProfile.Header(cmmId: "DOGG",
                                       version: 0x04300000,
                                       deviceClass: deviceClass,
                                       colorSpace: colorSpace,
                                       pcs: .XYZ,
                                       date: iccProfile.DateTimeNumber(year: BEUInt16(date.year!),
                                                                       month: BEUInt16(date.month!),
                                                                       day: BEUInt16(date.day!),
                                                                       hours: BEUInt16(date.hour!),
                                                                       minutes: BEUInt16(date.minute!),
                                                                       seconds: BEUInt16(date.second!)),
                                       platform: "DOGG",
                                       flags: 0,
                                       manufacturer: "DOGG",
                                       model: 0,
                                       attributes: 0,
                                       renderingIntent: 0,
                                       illuminant: iccProfile.XYZNumber(PCSXYZ.white),
                                       creator: "DOGG")
        
        var profile = iccProfile(header: header)
        
        profile.setMessage(.Copyright, ("en", "US", "Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved."))
        
        profile.setXYZ(.MediaWhitePoint, iccProfile.XYZNumber(self.cieXYZ.normalized.white))
        
        let chromaticAdaptationMatrix = self.cieXYZ.normalized.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        profile.setFloat(.ChromaticAdaptation,
                         iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.a), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.b), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.c),
                         iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.e), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.f), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.g),
                         iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.i), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.j), iccProfile.S15Fixed16Number(value: chromaticAdaptationMatrix.k))
        
        return profile
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .display, colorSpace: .Gray)
        
        profile.setMessage(.ProfileDescription, ("en", "US", "Doggie Calibrated Gray Color Space"))
        
        profile.setParametricCurve(.GrayTRC, curve: iccParametricCurve())
        
        return profile.data
    }
}

extension CalibratedRGBColorSpace {
    
    @_versioned
    @_inlineable
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .display, colorSpace: .Rgb)
        
        profile.setMessage(.ProfileDescription, ("en", "US", "Doggie Calibrated RGB Color Space"))
        
        let matrix = transferMatrix * self.cieXYZ.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        profile.setXYZ(.RedColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(value: matrix.a), y: iccProfile.S15Fixed16Number(value: matrix.e), z: iccProfile.S15Fixed16Number(value: matrix.i)))
        profile.setXYZ(.GreenColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(value: matrix.b), y: iccProfile.S15Fixed16Number(value: matrix.f), z: iccProfile.S15Fixed16Number(value: matrix.j)))
        profile.setXYZ(.BlueColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(value: matrix.c), y: iccProfile.S15Fixed16Number(value: matrix.g), z: iccProfile.S15Fixed16Number(value: matrix.k)))
        
        profile.setParametricCurve(.RedTRC, curve: iccParametricCurve(0))
        profile.setParametricCurve(.GreenTRC, curve: iccParametricCurve(1))
        profile.setParametricCurve(.BlueTRC, curve: iccParametricCurve(2))
        
        return profile.data
    }
}
