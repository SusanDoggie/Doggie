//
//  TIFFEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

struct TIFFEncoder: ImageRepEncoder {
    
    private static func encode(tag: TIFFTag.Tag, type: UInt16, value: [Int], _ data: inout MappedBuffer<UInt8>) {
        
        data.encode(tag.rawValue.bigEndian)
        data.encode(type.bigEndian)
        data.encode(UInt32(value.count).bigEndian)
        
        switch type {
        case 1:
            precondition(1...4 ~= value.count)
            for v in value {
                data.encode(UInt8(v).bigEndian)
            }
            data.append(contentsOf: repeatElement(0 as UInt8, count: 4 - value.count))
        case 3:
            precondition(1...2 ~= value.count)
            for v in value {
                data.encode(UInt16(v).bigEndian)
            }
            if value.count != 2 {
                data.encode(0 as UInt16)
            }
        case 4:
            precondition(value.count == 1)
            for v in value {
                data.encode(UInt32(v).bigEndian)
            }
        default: fatalError()
        }
    }
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let bitsPerChannel: Int
        let photometric: Int
        var pixelData: MappedBuffer<UInt8>
        
        let resolutionUnit: Int
        let resolutionX: Double
        let resolutionY: Double
        
        let compression = properties[.compression] as? ImageRep.TIFFCompressionScheme ?? .deflate
        let deflate_level = properties[.deflateLevel] as? Deflate.Level ?? .default
        let predictor: TIFFPrediction
        
        switch compression {
        case .none: predictor = .none
        case .lzw: predictor = properties[.predictor] as? TIFFPrediction ?? .subtract
        case .packBits: predictor = properties[.predictor] as? TIFFPrediction ?? .subtract
        case .deflate:
            switch deflate_level {
            case .none: predictor = .none
            default: predictor = properties[.predictor] as? TIFFPrediction ?? .subtract
            }
        }
        
        switch image.colorSpace.base {
        case is ColorSpace<RGBColorModel>: photometric = 2
        case is ColorSpace<GrayColorModel>: photometric = 1
        case is ColorSpace<LabColorModel>: photometric = 8
        default: photometric = 5
        }
        
        let colorSpace = photometric == 8 ? AnyColorSpace.genericLab : image.colorSpace
        guard let iccData = colorSpace.iccData else { return encode(image: AnyImage(Image<Float32ColorPixel<LabColorModel>>(image: image, colorSpace: .genericLab)), properties: properties) }
        
        let isOpaque = image.isOpaque
        let samplesPerPixel = isOpaque ? image.colorSpace.numberOfComponents : image.colorSpace.numberOfComponents + 1
        
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
        
        switch image.base {
        case let image as Image<ARGB32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<ARGB64ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<RGBA32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<RGBA64ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<ABGR32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<BGRA32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<Gray16ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        case let image as Image<Gray32ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_color_data(image, predictor, isOpaque)
            
        default:
            
            bitsPerChannel = 16
            
            if photometric == 8 {
                if let image = image.base as? Image<Float64ColorPixel<LabColorModel>>, image.colorSpace == .genericLab {
                    pixelData = tiff_color_data(image, predictor, isOpaque)
                } else {
                    pixelData = tiff_color_data(Image<Float32ColorPixel<LabColorModel>>(image: image, colorSpace: .genericLab), predictor, isOpaque)
                }
            } else {
                guard let image = image.base as? TIFFRawRepresentable else { return nil }
                pixelData = image.tiff_color_data(predictor, isOpaque)
            }
        }
        
        do {
            
            let encoder: CompressionCodec?
            
            switch compression {
            case .none: encoder = nil
            case .lzw: encoder = TIFFLZWEncoder()
            case .packBits: encoder = TIFFPackBitsEncoder()
            case .deflate:
                switch deflate_level {
                case .none: encoder = nil
                default: encoder = try Deflate(level: deflate_level, windowBits: 15)
                }
            }
            
            if let encoder = encoder {
                var compressed = MappedBuffer<UInt8>(fileBacked: true)
                try encoder.update(pixelData, &compressed)
                try encoder.finalize(&compressed)
                pixelData = compressed
            }
            
        } catch {
            return nil
        }
        
        var tag_count: UInt16 = 15
        
        if !isOpaque {
            tag_count += 1
        }
        
        var data = MappedBuffer<UInt8>(fileBacked: true)
        data.encode(TIFFHeader(endianness: .BIG, version: 42, IFD: 8))
        
        data.encode(tag_count.bigEndian)
        encode(tag: .SamplesPerPixel, type: 3, value: [samplesPerPixel], &data)
        encode(tag: .NewSubfileType, type: 4, value: [0], &data)
        encode(tag: .ImageWidth, type: 3, value: [image.width], &data)
        encode(tag: .ImageHeight, type: 3, value: [image.height], &data)
        switch compression {
        case .none: encode(tag: .Compression, type: 3, value: [1], &data)
        case .lzw: encode(tag: .Compression, type: 3, value: [5], &data)
        case .packBits: encode(tag: .Compression, type: 3, value: [32773], &data)
        case .deflate:
            switch deflate_level {
            case .none: encode(tag: .Compression, type: 3, value: [1], &data)
            default: encode(tag: .Compression, type: 3, value: [8], &data)
            }
        }
        encode(tag: .Predictor, type: 3, value: [predictor.rawValue], &data)
        encode(tag: .PlanarConfiguration, type: 3, value: [1], &data)
        encode(tag: .Photometric, type: 3, value: [photometric], &data)
        encode(tag: .StripByteCounts, type: 4, value: [pixelData.count], &data)
        encode(tag: .ResolutionUnit, type: 3, value: [resolutionUnit], &data)
        
        if !isOpaque {
            encode(tag: .ExtraSamples, type: 3, value: [2], &data)
        }
        
        let offset = data.count + 64
        
        var _data = MappedBuffer<UInt8>(fileBacked: true)
        
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
        
        do {
            
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
