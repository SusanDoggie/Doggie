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

extension iccProfile {
    
    mutating func setMessage(_ tag: TagSignature, _ message: (LanguageCode, CountryCode, String) ...) {
        
        var header = Data(count: MemoryLayout<MultiLocalizedUnicode>.stride + 8)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.MultiLocalizedUnicode, 0 as BEUInt32, MultiLocalizedUnicode(count: BEUInt32(message.count), size: BEUInt32(MemoryLayout<MultiLocalizedUnicodeEntry>.stride))) }
        
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
    
    mutating func setFloat(_ tag: TagSignature, _ value: iccProfile.S15Fixed16Number ...) {
        
        var data = Data(count: 8)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.S15Fixed16Array, 0 as BEUInt32) }
        
        data.append(UnsafeBufferPointer(start: value, count: value.count))
        
        self[tag] = TagData(rawData: data)
    }
    
    mutating func setXYZ(_ tag: TagSignature, _ xyz: XYZNumber ...) {
        
        var data = Data(count: 8)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.XYZArray, 0 as BEUInt32) }
        
        data.append(UnsafeBufferPointer(start: xyz, count: xyz.count))
        
        self[tag] = TagData(rawData: data)
    }
    
    private func curveData(curve: ICCCurve) -> Data {
        
        switch curve {
        case .identity:
            
            var data = Data(count: 12)
            
            data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.Curve, 0 as BEUInt32, 0 as BEUInt32) }
            
            return data
            
        case let .gamma(gamma): return parametricCurveData(curve: ParametricCurve(funcType: 0, gamma: S15Fixed16Number(gamma), a: 0, b: 0, c: 0, d: 0, e: 0, f: 0))
        case let .parametric1(gamma, a, b): return parametricCurveData(curve: ParametricCurve(funcType: 1, gamma: S15Fixed16Number(gamma), a: S15Fixed16Number(a), b: S15Fixed16Number(b), c: 0, d: 0, e: 0, f: 0))
        case let .parametric2(gamma, a, b, c): return parametricCurveData(curve: ParametricCurve(funcType: 2, gamma: S15Fixed16Number(gamma), a: S15Fixed16Number(a), b: S15Fixed16Number(b), c: S15Fixed16Number(c), d: 0, e: 0, f: 0))
        case let .parametric3(gamma, a, b, c, d): return parametricCurveData(curve: ParametricCurve(funcType: 3, gamma: S15Fixed16Number(gamma), a: S15Fixed16Number(a), b: S15Fixed16Number(b), c: S15Fixed16Number(c), d: S15Fixed16Number(d), e: 0, f: 0))
        case let .parametric4(gamma, a, b, c, d, e, f): return parametricCurveData(curve: ParametricCurve(funcType: 4, gamma: S15Fixed16Number(gamma), a: S15Fixed16Number(a), b: S15Fixed16Number(b), c: S15Fixed16Number(c), d: S15Fixed16Number(d), e: S15Fixed16Number(e), f: S15Fixed16Number(f)))
        case let .table(points):
            
            var data = Data(count: 12)
            
            data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.Curve, 0 as BEUInt32, BEUInt32(points.count)) }
            
            data.append(UnsafeBufferPointer(start: points.map { BEUInt16(($0 * 65535).clamped(to: 0...65535)) }, count: points.count))
            
            return data
        }
    }
    
    private func parametricCurveData(curve: ParametricCurve) -> Data {
        
        var data = Data(count: 12)
        
        data.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.ParametricCurve, 0 as BEUInt32, curve.funcType, 0 as BEUInt16) }
        
        switch curve.funcType {
        case 0: data.append(UnsafeBufferPointer(start: [curve.gamma], count: 1))
        case 1: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b], count: 3))
        case 2: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c], count: 4))
        case 3: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c, curve.d], count: 5))
        case 4: data.append(UnsafeBufferPointer(start: [curve.gamma, curve.a, curve.b, curve.c, curve.d, curve.e, curve.f], count: 7))
        default: fatalError()
        }
        
        return data
    }
    
    mutating func setLutAtoB(_ tag: TagSignature, B: [ICCCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.append(curveData(curve: curve))
            B_data.count = B_data.count.align(4)
        }
        
        let header_size = MemoryLayout<LutAtoB>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.LutAtoB, 0 as BEUInt32, LutAtoB(inputChannels: 3, outputChannels: 3, padding1: 0, padding2: 0, offsetB: BEUInt32(header_size), offsetMatrix: 0, offsetM: 0, offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data)
    }
    
    mutating func setLutBtoA(_ tag: TagSignature, B: [ICCCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.append(curveData(curve: curve))
            B_data.count = B_data.count.align(4)
        }
        
        let header_size = MemoryLayout<LutBtoA>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.LutBtoA, 0 as BEUInt32, LutBtoA(inputChannels: 3, outputChannels: 3, padding1: 0, padding2: 0, offsetB: BEUInt32(header_size), offsetMatrix: 0, offsetM: 0, offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data)
    }
    
    mutating func setLutAtoB(_ tag: TagSignature, B: [ICCCurve], matrix: Matrix, M: [ICCCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.append(curveData(curve: curve))
            B_data.count = B_data.count.align(4)
        }
        
        var matrix_data = Data(count: MemoryLayout<Matrix3x4>.stride)
        matrix_data.withUnsafeMutableBytes { $0.pointee = Matrix3x4(matrix) }
        
        var M_data = Data()
        
        for curve in M {
            M_data.append(curveData(curve: curve))
            M_data.count = M_data.count.align(4)
        }
        
        let header_size = MemoryLayout<LutAtoB>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.LutAtoB, 0 as BEUInt32, LutAtoB(inputChannels: 3, outputChannels: 3, padding1: 0, padding2: 0, offsetB: BEUInt32(header_size), offsetMatrix: BEUInt32(header_size + B_data.count), offsetM: BEUInt32(header_size + B_data.count + matrix_data.count), offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data + matrix_data + M_data)
    }
    
    mutating func setLutBtoA(_ tag: TagSignature, B: [ICCCurve], matrix: Matrix, M: [ICCCurve]) {
        
        var B_data = Data()
        
        for curve in B {
            B_data.append(curveData(curve: curve))
            B_data.count = B_data.count.align(4)
        }
        
        var matrix_data = Data(count: MemoryLayout<Matrix3x4>.stride)
        matrix_data.withUnsafeMutableBytes { $0.pointee = Matrix3x4(matrix) }
        
        var M_data = Data()
        
        for curve in M {
            M_data.append(curveData(curve: curve))
            M_data.count = M_data.count.align(4)
        }
        
        let header_size = MemoryLayout<LutBtoA>.stride + 8
        
        var header = Data(count: header_size)
        
        header.withUnsafeMutableBytes { $0.pointee = (iccProfile.TagData.TagType.LutBtoA, 0 as BEUInt32, LutBtoA(inputChannels: 3, outputChannels: 3, padding1: 0, padding2: 0, offsetB: BEUInt32(header_size), offsetMatrix: BEUInt32(header_size + B_data.count), offsetM: BEUInt32(header_size + B_data.count + matrix_data.count), offsetCLUT: 0, offsetA: 0)) }
        
        self[tag] = TagData(rawData: header + B_data + matrix_data + M_data)
    }
    
    mutating func setCurve(_ tag: TagSignature, curve: ICCCurve) {
        
        self[tag] = TagData(rawData: curveData(curve: curve))
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
        
        profile.setXYZ(.MediaWhitePoint, iccProfile.XYZNumber(self.white))
        
        if self.black.y != 0 {
            profile.setXYZ(.MediaBlackPoint, iccProfile.XYZNumber(self.black))
        }
        
        if self.luminance != 1 {
            profile.setXYZ(.Luminance, iccProfile.XYZNumber(x: 0, y: iccProfile.S15Fixed16Number(self.luminance), z: 0))
        }
        
        let chromaticAdaptationMatrix = self.chromaticAdaptationMatrix(to: PCSXYZ, .default)
        
        profile.setFloat(.ChromaticAdaptation,
                         iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.a), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.b), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.c),
                         iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.e), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.f), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.g),
                         iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.i), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.j), iccProfile.S15Fixed16Number(chromaticAdaptationMatrix.k))
        
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
        
        profile.setXYZ(.RedColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(matrix.a), y: iccProfile.S15Fixed16Number(matrix.e), z: iccProfile.S15Fixed16Number(matrix.i)))
        profile.setXYZ(.GreenColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(matrix.b), y: iccProfile.S15Fixed16Number(matrix.f), z: iccProfile.S15Fixed16Number(matrix.j)))
        profile.setXYZ(.BlueColorant, iccProfile.XYZNumber(x: iccProfile.S15Fixed16Number(matrix.c), y: iccProfile.S15Fixed16Number(matrix.g), z: iccProfile.S15Fixed16Number(matrix.k)))
        
        profile.setCurve(.RedTRC, curve: iccCurve(0))
        profile.setCurve(.GreenTRC, curve: iccCurve(1))
        profile.setCurve(.BlueTRC, curve: iccCurve(2))
        
        return profile.data
    }
}
