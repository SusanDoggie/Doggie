//
//  ICC Creator.swift
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

import Foundation

extension iccProfile {
    
    mutating func setMessage(_ tag: TagSignature, _ message: (iccMultiLocalizedUnicode.LanguageCode, iccMultiLocalizedUnicode.CountryCode, String) ...) {
        
        var data = Data()
        data.encode(iccMultiLocalizedUnicode(message))
        
        self[tag] = TagData(rawData: data)
    }
    
    mutating func setFloat(_ tag: TagSignature, _ value: Fixed16Number<BEInt32> ...) {
        
        var data = Data(count: 8)
        
        data.encode(iccProfile.TagType.s15Fixed16Array)
        data.encode(0 as BEUInt32)
        data.encode(value)
        
        self[tag] = TagData(rawData: data)
    }
    
    mutating func setXYZ(_ tag: TagSignature, _ xyz: iccXYZNumber ...) {
        
        var data = Data()
        
        data.encode(iccProfile.TagType.XYZArray)
        data.encode(0 as BEUInt32)
        data.encode(xyz)
        
        self[tag] = TagData(rawData: data)
    }
    
    mutating func setLutAtoB(_ tag: TagSignature, B: [iccCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.encode(curve)
            B_data.count = B_data.count.align(4)
        }
        
        let header_size = MemoryLayout<iccLUTTransform.LutAtoB>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagType.lutAtoB, 0 as BEUInt32, iccLUTTransform.LutAtoB(inputChannels: 3, outputChannels: 3, offsetB: BEUInt32(header_size), offsetMatrix: 0, offsetM: 0, offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data)
    }
    
    mutating func setLutBtoA(_ tag: TagSignature, B: [iccCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.encode(curve)
            B_data.count = B_data.count.align(4)
        }
        
        let header_size = MemoryLayout<iccLUTTransform.LutBtoA>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagType.lutBtoA, 0 as BEUInt32, iccLUTTransform.LutBtoA(inputChannels: 3, outputChannels: 3, offsetB: BEUInt32(header_size), offsetMatrix: 0, offsetM: 0, offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data)
    }
    
    mutating func setLutAtoB(_ tag: TagSignature, B: [iccCurve], matrix: Matrix, M: [iccCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.encode(curve)
            B_data.count = B_data.count.align(4)
        }
        
        var matrix_data = Data(count: MemoryLayout<iccMatrix3x4>.stride)
        matrix_data.withUnsafeMutableBytes { $0.pointee = iccMatrix3x4(matrix) }
        
        var M_data = Data()
        
        for curve in M {
            M_data.encode(curve)
            M_data.count = M_data.count.align(4)
        }
        
        let header_size = MemoryLayout<iccLUTTransform.LutAtoB>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagType.lutAtoB, 0 as BEUInt32, iccLUTTransform.LutAtoB(inputChannels: 3, outputChannels: 3, offsetB: BEUInt32(header_size), offsetMatrix: BEUInt32(header_size + B_data.count), offsetM: BEUInt32(header_size + B_data.count + matrix_data.count), offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data + matrix_data + M_data)
    }
    
    mutating func setLutBtoA(_ tag: TagSignature, B: [iccCurve], matrix: Matrix, M: [iccCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.encode(curve)
            B_data.count = B_data.count.align(4)
        }
        
        var matrix_data = Data(count: MemoryLayout<iccMatrix3x4>.stride)
        matrix_data.withUnsafeMutableBytes { $0.pointee = iccMatrix3x4(matrix) }
        
        var M_data = Data()
        
        for curve in M {
            M_data.encode(curve)
            M_data.count = M_data.count.align(4)
        }
        
        let header_size = MemoryLayout<iccLUTTransform.LutBtoA>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagType.lutBtoA, 0 as BEUInt32, iccLUTTransform.LutBtoA(inputChannels: 3, outputChannels: 3, offsetB: BEUInt32(header_size), offsetMatrix: BEUInt32(header_size + B_data.count), offsetM: BEUInt32(header_size + B_data.count + matrix_data.count), offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data + matrix_data + M_data)
    }
    
    mutating func setCurve(_ tag: TagSignature, curve: iccCurve) {
        
        var data = Data()
        data.encode(curve)
        
        self[tag] = TagData(rawData: data)
    }
}

extension CIEXYZColorSpace {
    
    func _iccProfile(deviceClass: iccProfile.Header.ClassSignature, colorSpace: iccProfile.Header.ColorSpaceSignature, pcs: iccProfile.Header.ColorSpaceSignature) -> iccProfile {
        
        let date = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: Date())
        
        let header = iccProfile.Header(cmmId: "DOGG",
                                       version: 0x04300000,
                                       deviceClass: deviceClass,
                                       colorSpace: colorSpace,
                                       pcs: pcs,
                                       date: iccDateTimeNumber(year: BEUInt16(date.year!),
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
                                       illuminant: iccXYZNumber(PCSXYZ.white),
                                       creator: "DOGG")
        
        var profile = iccProfile(header: header)
        
        profile.setMessage(.Copyright, ("en", "US", "Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved."))
        
        profile.setXYZ(.MediaWhitePoint, iccXYZNumber(self.white))
        
        if self.black.y != 0 {
            profile.setXYZ(.MediaBlackPoint, iccXYZNumber(self.black))
        }
        
        if self.luminance != 1 {
            profile.setXYZ(.Luminance, iccXYZNumber(x: 0, y: Fixed16Number(self.luminance), z: 0))
        }
        
        let chromaticAdaptationMatrix = self.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        profile.setFloat(.ChromaticAdaptation,
                         Fixed16Number(chromaticAdaptationMatrix.a), Fixed16Number(chromaticAdaptationMatrix.b), Fixed16Number(chromaticAdaptationMatrix.c),
                         Fixed16Number(chromaticAdaptationMatrix.e), Fixed16Number(chromaticAdaptationMatrix.f), Fixed16Number(chromaticAdaptationMatrix.g),
                         Fixed16Number(chromaticAdaptationMatrix.i), Fixed16Number(chromaticAdaptationMatrix.j), Fixed16Number(chromaticAdaptationMatrix.k))
        
        return profile
    }
}

extension CIEXYZColorSpace {
    
    @_versioned
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .colorSpace, colorSpace: .XYZ, pcs: .XYZ)
        
        profile.setMessage(.ProfileDescription, ("en", "US", self.localizedName!))
        
        profile.setLutAtoB(.AToB0, B: [.identity, .identity, .identity])
        profile.setLutBtoA(.BToA0, B: [.identity, .identity, .identity])
        
        return profile.data
    }
}

extension CIELabColorSpace {
    
    @_versioned
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .colorSpace, colorSpace: .Lab, pcs: .Lab)
        
        profile.setMessage(.ProfileDescription, ("en", "US", self.localizedName!))
        
        profile.setLutAtoB(.AToB0, B: [.identity, .identity, .identity])
        profile.setLutBtoA(.BToA0, B: [.identity, .identity, .identity])
        
        return profile.data
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .display, colorSpace: .Gray, pcs: .XYZ)
        
        profile.setMessage(.ProfileDescription, ("en", "US", self.localizedName!))
        
        profile.setCurve(.GrayTRC, curve: iccCurve())
        
        return profile.data
    }
}

extension CalibratedRGBColorSpace {
    
    @_versioned
    var iccData: Data? {
        
        var profile = cieXYZ._iccProfile(deviceClass: .display, colorSpace: .Rgb, pcs: .XYZ)
        
        profile.setMessage(.ProfileDescription, ("en", "US", self.localizedName!))
        
        let matrix = transferMatrix * self.cieXYZ.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        profile.setXYZ(.RedColorant, iccXYZNumber(x: Fixed16Number(matrix.a), y: Fixed16Number(matrix.e), z: Fixed16Number(matrix.i)))
        profile.setXYZ(.GreenColorant, iccXYZNumber(x: Fixed16Number(matrix.b), y: Fixed16Number(matrix.f), z: Fixed16Number(matrix.j)))
        profile.setXYZ(.BlueColorant, iccXYZNumber(x: Fixed16Number(matrix.c), y: Fixed16Number(matrix.g), z: Fixed16Number(matrix.k)))
        
        profile.setCurve(.RedTRC, curve: iccCurve(0))
        profile.setCurve(.GreenTRC, curve: iccCurve(1))
        profile.setCurve(.BlueTRC, curve: iccCurve(2))
        
        return profile.data
    }
}
