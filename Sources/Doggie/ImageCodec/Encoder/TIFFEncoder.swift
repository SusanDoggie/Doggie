//
//  TIFFEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

struct TIFFEncoder : ImageRepEncoder {
    
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
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        
        let bitsPerChannel: Int
        let photometric: Int
        var pixelData: MappedBuffer<UInt8>
        
        let resolutionUnit: Int
        let resolutionX: Double
        let resolutionY: Double
        
        let compression = properties[.compression] as? ImageRep.TIFFCompressionScheme ?? .none
        let predictor: Int
        
        switch compression {
        case .none: predictor = 1
        case .deflate: predictor = 2
        }
        
        switch image.colorSpace.base {
        case is ColorSpace<RGBColorModel>: photometric = 2
        case is ColorSpace<GrayColorModel>: photometric = 1
        case is ColorSpace<LabColorModel>: photometric = 8
        default: photometric = 5
        }
        
        let colorSpace = photometric == 8 ? AnyColorSpace(.cieLab(white: Point(x: 0.34567, y: 0.35850))) : image.colorSpace
        guard let iccData = colorSpace.iccData else { return encode(image: AnyImage(Image<Float32ColorPixel<LabColorModel>>(image: image, colorSpace: .cieLab(white: Point(x: 0.34567, y: 0.35850)))), properties: properties) }
        
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
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        case let image as Image<ARGB64ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        case let image as Image<RGBA32ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        case let image as Image<RGBA64ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        case let image as Image<Gray16ColorPixel>:
            
            bitsPerChannel = 8
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        case let image as Image<Gray32ColorPixel>:
            
            bitsPerChannel = 16
            
            pixelData = tiff_rawData(image, predictor, isOpaque)
            
        default:
            
            bitsPerChannel = 16
            
            if photometric == 8 {
                if let image = image.base as? Image<Float64ColorPixel<LabColorModel>>, image.colorSpace == .cieLab(white: Point(x: 0.34567, y: 0.35850)) {
                    pixelData = tiff_rawData(image, predictor, isOpaque)
                } else {
                    pixelData = tiff_rawData(Image<Float32ColorPixel<LabColorModel>>(image: image, colorSpace: .cieLab(white: Point(x: 0.34567, y: 0.35850))), predictor, isOpaque)
                }
            } else {
                let image = image.base as! TIFFRawRepresentable
                pixelData = image.tiff_rawData(predictor, isOpaque)
            }
        }
        
        switch compression {
        case .none: break
        case .deflate:
            do {
                var compressed = MappedBuffer<UInt8>(fileBacked: true)
                try Deflate(windowBits: 15).final(pixelData, &compressed)
                pixelData = compressed
            } catch {
                return nil
            }
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
        case .deflate: encode(tag: .Compression, type: 3, value: [8], &data)
        }
        encode(tag: .Predictor, type: 3, value: [predictor], &data)
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

private protocol TIFFRawRepresentable {
    
    func tiff_rawData(_ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8>
}

private protocol TIFFEncodablePixel: ColorPixelProtocol {
    
    func tiff_prediction_2(_ lhs: Self) -> Self
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>)
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>)
}

extension ARGB32ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: ARGB32ColorPixel) -> ARGB32ColorPixel {
        return ARGB32ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension ARGB64ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: ARGB64ColorPixel) -> ARGB64ColorPixel {
        return ARGB64ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension RGBA32ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: RGBA32ColorPixel) -> RGBA32ColorPixel {
        return RGBA32ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension RGBA64ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: RGBA64ColorPixel) -> RGBA64ColorPixel {
        return RGBA64ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Gray16ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: Gray16ColorPixel) -> Gray16ColorPixel {
        return Gray16ColorPixel(white: w &- lhs.w, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(w.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Gray32ColorPixel : TIFFEncodablePixel {
    
    fileprivate func tiff_prediction_2(_ lhs: Gray32ColorPixel) -> Gray32ColorPixel {
        return Gray32ColorPixel(white: w &- lhs.w, opacity: a &- lhs.a)
    }
    
    fileprivate func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(w.bigEndian)
    }
    
    fileprivate func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Image : TIFFRawRepresentable {
    
    fileprivate func tiff_rawData(_ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
        
        let samplesPerPixel = isOpaque ? Pixel.Model.numberOfComponents : Pixel.Model.numberOfComponents + 1
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: self.width * self.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        self.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = self.width * self.height
                
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
            case 2:
                
                var lhs: [UInt16] = Array(repeating: 0, count: samplesPerPixel)
                
                lhs.withUnsafeMutableBufferPointer {
                    
                    guard let lhs = $0.baseAddress else { return }
                    
                    if isOpaque {
                        
                        for _ in 0..<self.height {
                            
                            memset(lhs, 0, samplesPerPixel << 1)
                            
                            for _ in 0..<self.width {
                                
                                let color = source.pointee.color
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[i]
                                    data.encode(s.bigEndian)
                                    lhs[i] = c
                                }
                                source += 1
                            }
                        }
                        
                    } else {
                        
                        for _ in 0..<self.height {
                            
                            memset(lhs, 0, samplesPerPixel << 1)
                            
                            for _ in 0..<self.width {
                                
                                let pixel = source.pointee
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((pixel.color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[i]
                                    data.encode(s.bigEndian)
                                    lhs[i] = c
                                }
                                do {
                                    let c = UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[Pixel.Model.numberOfComponents]
                                    data.encode(s.bigEndian)
                                    lhs[Pixel.Model.numberOfComponents] = c
                                }
                                source += 1
                            }
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
}

extension TIFFEncoder {
    
    private static func tiff_rawData<Pixel: TIFFEncodablePixel>(_ image: Image<Pixel>, _ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
        
        let samplesPerPixel = isOpaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        
        var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = image.width * image.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        pixel.tiff_encode_color(&data)
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        pixel.tiff_encode_color(&data)
                        pixel.tiff_encode_opacity(&data)
                        source += 1
                    }
                }
            case 2:
                
                if isOpaque {
                    
                    for _ in 0..<image.height {
                        
                        var lhs = Pixel()
                        
                        for _ in 0..<image.width {
                            
                            let rhs = source.pointee
                            let pixel = rhs.tiff_prediction_2(lhs)
                            pixel.tiff_encode_color(&data)
                            lhs = rhs
                            source += 1
                        }
                    }
                } else {
                    
                    for _ in 0..<image.height {
                        
                        var lhs = Pixel()
                        
                        for _ in 0..<image.width {
                            
                            let rhs = source.pointee
                            let pixel = rhs.tiff_prediction_2(lhs)
                            pixel.tiff_encode_color(&data)
                            pixel.tiff_encode_opacity(&data)
                            lhs = rhs
                            source += 1
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
    private static func tiff_rawData<Pixel>(_ image: Image<Pixel>, _ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> where Pixel.Model == LabColorModel {
        
        let samplesPerPixel = isOpaque ? 3 : 4
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = image.width * image.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let color = source.pointee.color
                        data.encode(UInt16((color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        data.encode(Int16((color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(Int16((color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        data.encode(UInt16((pixel.color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        data.encode(Int16((pixel.color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(Int16((pixel.color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        source += 1
                    }
                }
            case 2:
                
                if isOpaque {
                    
                    for _ in 0..<image.height {
                        
                        var _l1: UInt16 = 0
                        var _a1: Int16 = 0
                        var _b1: Int16 = 0
                        
                        for _ in 0..<image.width {
                            
                            let color = source.pointee.color
                            
                            let _l2 = UInt16((color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded())
                            let _a2 = Int16((color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _b2 = Int16((color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            
                            let _l3 = _l2 &- _l1
                            let _a3 = _a2 &- _a1
                            let _b3 = _b2 &- _b1
                            
                            data.encode(_l3.bigEndian)
                            data.encode(_a3.bigEndian)
                            data.encode(_b3.bigEndian)
                            
                            _l1 = _l2
                            _a1 = _a2
                            _b1 = _b2
                            
                            source += 1
                        }
                    }
                } else {
                    
                    for _ in 0..<image.height {
                        
                        var _l1: UInt16 = 0
                        var _a1: Int16 = 0
                        var _b1: Int16 = 0
                        var _o1: UInt16 = 0
                        
                        for _ in 0..<image.width {
                            
                            let pixel = source.pointee
                            
                            let _l2 = UInt16((pixel.color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded())
                            let _a2 = Int16((pixel.color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _b2 = Int16((pixel.color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _o2 = UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded())
                            
                            let _l3 = _l2 &- _l1
                            let _a3 = _a2 &- _a1
                            let _b3 = _b2 &- _b1
                            let _o3 = _o2 &- _o1
                            
                            data.encode(_l3.bigEndian)
                            data.encode(_a3.bigEndian)
                            data.encode(_b3.bigEndian)
                            data.encode(_o3.bigEndian)
                            
                            _l1 = _l2
                            _a1 = _a2
                            _b1 = _b2
                            _o1 = _o2
                            
                            source += 1
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
}
