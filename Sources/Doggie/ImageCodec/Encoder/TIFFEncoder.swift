//
//  TIFFEncoder.swift
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

private protocol TIFFRawRepresentable {
    
    func rawData(_ isOpaque: Bool) -> FileBuffer
}

extension Image : TIFFRawRepresentable {
    
    fileprivate func rawData(_ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? Pixel.Model.numberOfComponents : Pixel.Model.numberOfComponents + 1
        let bytesPerSample = 2
        
        let count = self.width * self.height
        
        var data = FileBuffer(capacity: count * samplesPerPixel * bytesPerSample)
        
        self.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<count {
                    let color = source.pointee.color
                    for i in 0..<Pixel.Model.numberOfComponents {
                        data.encode(UInt16((color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    }
                    source += 1
                }
            } else {
                for _ in 0..<count {
                    let pixel = source.pointee
                    for i in 0..<Pixel.Model.numberOfComponents {
                        data.encode(UInt16((pixel.color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    }
                    data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
}

struct TIFFEncoder : ImageRepEncoder {
    
    private static func rawData(_ image: Image<ColorPixel<LabColorModel>>, _ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? 3 : 4
        let bytesPerSample = 1
        
        var data = FileBuffer(capacity: image.width * image.height * samplesPerPixel * bytesPerSample)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<image.width * image.height {
                    let color = source.pointee.color
                    data.encode(UInt16((color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    data.encode(Int16((color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(Int16((color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(UInt16((pixel.color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    data.encode(Int16((pixel.color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(Int16((pixel.color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
    private static func rawData(_ image: Image<ARGB32ColorPixel>, _ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? 3 : 4
        let bytesPerSample = 1
        
        var data = FileBuffer(capacity: image.width * image.height * samplesPerPixel * bytesPerSample)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.r.bigEndian)
                    data.encode(pixel.g.bigEndian)
                    data.encode(pixel.b.bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.r.bigEndian)
                    data.encode(pixel.g.bigEndian)
                    data.encode(pixel.b.bigEndian)
                    data.encode(pixel.a.bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
    private static func rawData(_ image: Image<ARGB64ColorPixel>, _ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? 3 : 4
        let bytesPerSample = 2
        
        var data = FileBuffer(capacity: image.width * image.height * samplesPerPixel * bytesPerSample)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.r.bigEndian)
                    data.encode(pixel.g.bigEndian)
                    data.encode(pixel.b.bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.r.bigEndian)
                    data.encode(pixel.g.bigEndian)
                    data.encode(pixel.b.bigEndian)
                    data.encode(pixel.a.bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
    private static func rawData(_ image: Image<Gray16ColorPixel>, _ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? 1 : 2
        let bytesPerSample = 1
        
        var data = FileBuffer(capacity: image.width * image.height * samplesPerPixel * bytesPerSample)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.w.bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.w.bigEndian)
                    data.encode(pixel.a.bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
    private static func rawData(_ image: Image<Gray32ColorPixel>, _ isOpaque: Bool) -> FileBuffer {
        
        let samplesPerPixel = isOpaque ? 1 : 2
        let bytesPerSample = 2
        
        var data = FileBuffer(capacity: image.width * image.height * samplesPerPixel * bytesPerSample)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            if isOpaque {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.w.bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<image.width * image.height {
                    let pixel = source.pointee
                    data.encode(pixel.w.bigEndian)
                    data.encode(pixel.a.bigEndian)
                    source += 1
                }
            }
        }
        
        return data
    }
    
    private static func encode(tag: TIFFTag.Tag, type: UInt16, value: [Int], _ data: inout FileBuffer) {
        
        data.encode(tag.rawValue.bigEndian)
        data.encode(type.bigEndian)
        data.encode(UInt32(value.count).bigEndian)
        
        switch type {
        case 1:
            guard 1...4 ~= value.count else { fatalError() }
            for v in value {
                data.encode(UInt8(v).bigEndian)
            }
            data.append(contentsOf: repeatElement(0 as UInt8, count: 4 - value.count))
        case 3:
            guard 1...2 ~= value.count else { fatalError() }
            for v in value {
                data.encode(UInt16(v).bigEndian)
            }
            if value.count != 2 {
                data.encode(0 as UInt16)
            }
        case 4:
            guard value.count == 1 else { fatalError() }
            for v in value {
                data.encode(UInt32(v).bigEndian)
            }
        default: fatalError()
        }
    }
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        
        var data = FileBuffer()
        data.encode(TIFFHeader(endianness: .BIG, version: 42, IFD: 8))
        
        let isOpaque = image.isOpaque
        let samplesPerPixel = isOpaque ? image.colorSpace.numberOfComponents : image.colorSpace.numberOfComponents + 1
        
        let bitsPerChannel: Int
        let photometric: Int
        let pixelData: FileBuffer
        
        let resolutionUnit: Int
        let resolutionX: Double
        let resolutionY: Double
        
        switch image.resolution.unit {
        case .inch:
            resolutionUnit = 2
            resolutionX = image.resolution.horizontal
            resolutionY = image.resolution.vertical
        case .centimeter:
            resolutionUnit = 3
            resolutionX = image.resolution.horizontal
            resolutionY = image.resolution.vertical
        default:
            let resolution = image.resolution.convert(to: .inch)
            resolutionUnit = 2
            resolutionX = resolution.horizontal
            resolutionY = resolution.vertical
        }
        
        switch image.colorSpace.base {
        case is ColorSpace<RGBColorModel>: photometric = 2
        case is ColorSpace<GrayColorModel>: photometric = 1
        case is ColorSpace<LabColorModel>: photometric = 8
        default: photometric = 5
        }
        
        switch image.base {
        case let image as Image<ARGB32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = rawData(image, isOpaque)
            
        case let image as Image<ARGB64ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = rawData(image, isOpaque)
            
        case let image as Image<Gray16ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = rawData(image, isOpaque)
            
        case let image as Image<Gray32ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = rawData(image, isOpaque)
            
        default:
            
            bitsPerChannel = 16
            
            if photometric == 8  {
                pixelData = rawData(Image<ColorPixel<LabColorModel>>(image: image, colorSpace: ColorSpace.cieLab(white: Point(x: 0.34567, y: 0.35850))), isOpaque)
            } else {
                let image = image.base as! TIFFRawRepresentable
                pixelData = image.rawData(isOpaque)
            }
        }
        
        var tag_count: UInt16 = 13
        
        if !isOpaque {
            tag_count += 1
        }
        if photometric != 8 {
            tag_count += 1
        }
        
        data.encode(tag_count.bigEndian)
        encode(tag: .SamplesPerPixel, type: 3, value: [samplesPerPixel], &data)
        encode(tag: .NewSubfileType, type: 4, value: [0], &data)
        encode(tag: .ImageWidth, type: 3, value: [image.width], &data)
        encode(tag: .ImageHeight, type: 3, value: [image.height], &data)
        encode(tag: .Compression, type: 3, value: [1], &data)
        encode(tag: .PlanarConfiguration, type: 3, value: [1], &data)
        encode(tag: .Photometric, type: 3, value: [photometric], &data)
        encode(tag: .StripByteCounts, type: 4, value: [pixelData.count], &data)
        encode(tag: .ResolutionUnit, type: 3, value: [resolutionUnit], &data)
        
        if !isOpaque {
            encode(tag: .ExtraSamples, type: 3, value: [2], &data)
        }
        
        var offset = data.count + 52
        
        if photometric != 8 {
            offset += 12
        }
        
        var _data = FileBuffer()
        
        do {
            
            data.encode(TIFFTag.Tag.ResolutionX.rawValue.bigEndian)
            data.encode(UInt16(5).bigEndian)
            data.encode(UInt32(1).bigEndian)
            data.encode(UInt32(offset + _data.count).bigEndian)
            
            let m = pow(10, (9 - ceil(log10(resolutionX))).clamped(to: 0...9))
            _data.encode(UInt32((resolutionX * m).clamped(to: 0...4294967295)).bigEndian)
            _data.encode(UInt32(m).bigEndian)
        }
        
        do {
            
            data.encode(TIFFTag.Tag.ResolutionY.rawValue.bigEndian)
            data.encode(UInt16(5).bigEndian)
            data.encode(UInt32(1).bigEndian)
            data.encode(UInt32(offset + _data.count).bigEndian)
            
            let m = pow(10, (9 - ceil(log10(resolutionY))).clamped(to: 0...9))
            _data.encode(UInt32((resolutionY * m).clamped(to: 0...4294967295)).bigEndian)
            _data.encode(UInt32(m).bigEndian)
        }
        
        if samplesPerPixel > 2 {
            
            data.encode(TIFFTag.Tag.BitsPerSample.rawValue.bigEndian)
            data.encode(UInt16(3).bigEndian)
            data.encode(UInt32(samplesPerPixel).bigEndian)
            data.encode(UInt32(offset + _data.count).bigEndian)
            
            for _ in 0..<samplesPerPixel {
                _data.encode(UInt16(bitsPerChannel).bigEndian)
            }
            
        } else {
            encode(tag: .BitsPerSample, type: 3, value: Array(repeating: bitsPerChannel, count: samplesPerPixel), &data)
        }
        
        if photometric != 8 {
            
            guard let iccData = image.colorSpace.iccData else { return nil }
            
            data.encode(TIFFTag.Tag.IccProfile.rawValue.bigEndian)
            data.encode(UInt16(7).bigEndian)
            data.encode(UInt32(iccData.count).bigEndian)
            data.encode(UInt32(offset + _data.count).bigEndian)
            
            _data.append(contentsOf: iccData)
        }
        
        do {
            encode(tag: .StripOffsets, type: 4, value: [offset + _data.count], &data)
            _data.append(contentsOf: pixelData)
        }
        
        data.encode(0 as UInt32)
        data.append(contentsOf: _data)
        
        return data.data
    }
    
}

