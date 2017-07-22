//
//  TIFFDecoder.swift
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

struct TIFFDecoder : ImageRepDecoder {
    
    let header: TIFFHeader
    
    var pages: [TIFFPage] = []
    
    var defaultPage: TIFFPage {
        if pages.count == 1 {
            return pages[0]
        }
        return pages.first { !$0.isReducedResolution && !$0.isMask } ?? pages[0]
    }
    
    var width: Int {
        return defaultPage.width
    }
    
    var height: Int {
        return defaultPage.height
    }
    
    var resolution: Resolution {
        return defaultPage.resolution
    }
    
    var colorSpace: AnyColorSpace {
        return defaultPage.colorSpace
    }
    
    init?(data: Data) throws {
        
        var _data = data
        guard let header = try? _data.decode(TIFFHeader.self) else { return nil }
        guard header.version == 42 else { return nil }    // Answer to the Ultimate Question of Life, the Universe, and Everything
        
        self.header = header
        
        var offset = Int(header.IFD)
        
        while offset > 0 {
            
            _data = data.dropFirst(offset)
            
            var tags: [TIFFTag] = []
            
            switch header.endianness {
            case .BIG:
                
                guard let tag_count = try? _data.decode(BEUInt16.self) else { return nil }
                
                for _ in 0..<Int(tag_count) {
                    
                    guard let tag: UInt16 = try? _data.decode(BEUInt16.self).representingValue else { return nil }
                    guard let type: UInt16 = try? _data.decode(BEUInt16.self).representingValue else { return nil }
                    guard let count: UInt32 = try? _data.decode(BEUInt32.self).representingValue else { return nil }
                    guard _data.count > 4 else { return nil }
                    
                    tags.append(TIFFTag(endianness: header.endianness, tag: TIFFTag.Tag(rawValue: tag), type: type, count: count, data: _data.popFirst(4)))
                }
                
                guard let _offset = try? _data.decode(BEUInt32.self) else { return nil }
                offset = offset < _offset ? Int(_offset) : 0
                
            case .LITTLE:
                
                guard let tag_count = try? _data.decode(LEUInt16.self) else { return nil }
                
                for _ in 0..<Int(tag_count) {
                    
                    guard let tag: UInt16 = try? _data.decode(LEUInt16.self).representingValue else { return nil }
                    guard let type: UInt16 = try? _data.decode(LEUInt16.self).representingValue else { return nil }
                    guard let count: UInt32 = try? _data.decode(LEUInt32.self).representingValue else { return nil }
                    guard _data.count > 4 else { return nil }
                    
                    tags.append(TIFFTag(endianness: header.endianness, tag: TIFFTag.Tag(rawValue: tag), type: type, count: count, data: _data.popFirst(4)))
                }
                
                guard let _offset = try? _data.decode(LEUInt32.self) else { return nil }
                offset = offset < _offset ? Int(_offset) : 0
                
            default: fatalError()
            }
            
            if pages.count == 0 {
                pages.append(try TIFFPage(header, tags, data))
            } else {
                if let page = try? TIFFPage(header, tags, data) {
                    pages.append(page)
                }
            }
        }
        
        guard pages.count > 0 else { throw ImageRep.Error.InvalidFormat("Image data not found.") }
    }
    
    func image() -> AnyImage {
        return defaultPage.image()
    }
}

struct TIFFPage {
    
    var endianness: TIFFHeader.Endianness
    
    var newSubfileType: Int = 0
    
    var isReducedResolution: Bool {
        return self.newSubfileType & 1 == 1
    }
    var isPage: Bool {
        return self.newSubfileType & 2 == 1
    }
    var isMask: Bool {
        return self.newSubfileType & 4 == 1
    }
    
    var width: Int
    var height: Int
    
    var compression: Int = 1
    var planarConfiguration: Int = 1
    
    var sampleFormat: [Int] = []
    
    var orientation: Int = 1
    var resolutionUnit: Int = 0
    var resolutionX: Double = 0
    var resolutionY: Double = 0
    
    var samplesPerPixel: Int
    var extraSamples: [Int] = [] // unspecified == 0, premultiplied == 1, straight == 2
    var bitsPerSample: [Int] = []
    
    var palette: Data?
    
    var photometric: Int
    
    var rowsPerStrip: Int = ~0
    var stripsPerImage: Int
    var strips: [Data] = []
    
    var colorSpace: AnyColorSpace
    
    var tags: [TIFFTag]
    
    init(_ header: TIFFHeader, _ tags: [TIFFTag], _ data: Data) throws {
        
        self.tags = tags
        
        self.endianness = header.endianness
        
        guard let width = tags.first(where: { $0.tag == .ImageWidth }) else { throw ImageRep.Error.InvalidFormat("Image width not found.") }
        guard let height = tags.first(where: { $0.tag == .ImageHeight }) else { throw ImageRep.Error.InvalidFormat("Image height not found.") }
        guard let photometric = tags.first(where: { $0.tag == .Photometric }) else { throw ImageRep.Error.InvalidFormat("Photometric interpretation not found.") }
        guard let samplesPerPixel = tags.first(where: { $0.tag == .SamplesPerPixel }) else { throw ImageRep.Error.InvalidFormat("Samples per pixel not found.") }
        guard let bitsPerSample = tags.first(where: { $0.tag == .BitsPerSample }) else { throw ImageRep.Error.InvalidFormat("Bits per sample not found.") }
        guard let stripOffsets = tags.first(where: { $0.tag == .StripOffsets }) else { throw ImageRep.Error.InvalidFormat("Invalid strip offset type.") }
        guard let stripByteCounts = tags.first(where: { $0.tag == .StripByteCounts }) else { throw ImageRep.Error.InvalidFormat("Strip byte counts not found.") }
        
        self.width = try width.fatchInteger()
        self.height = try height.fatchInteger()
        self.photometric = try photometric.fatchInteger()
        self.samplesPerPixel = try samplesPerPixel.fatchInteger()
        self.bitsPerSample = try bitsPerSample.fatchIntegers(data)
        
        self.colorSpace = try TIFFPage.fatchColorSpace(tags: tags, photometric: self.photometric, data)
        
        if let rowsPerStrip = tags.first(where: { $0.tag == .RowsPerStrip }), let _rowsPerStrip = try? rowsPerStrip.fatchInteger() {
            self.rowsPerStrip = _rowsPerStrip
        }
        
        self.stripsPerImage = (self.height + self.rowsPerStrip - 1) / self.rowsPerStrip
        
        for (offset, length) in zip(try stripOffsets.fatchIntegers(data), try stripByteCounts.fatchIntegers(data)) {
            self.strips.append(data.dropFirst(offset).prefix(length))
        }
        
        if let newSubfileType = tags.first(where: { $0.tag == .NewSubfileType }), let _newSubfileType = try? newSubfileType.fatchInteger() {
            self.newSubfileType = _newSubfileType
        }
        
        if let compression = tags.first(where: { $0.tag == .Compression }), let _compression = try? compression.fatchInteger() {
            self.compression = _compression
        }
        if let planarConfiguration = tags.first(where: { $0.tag == .PlanarConfiguration }), let _planarConfiguration = try? planarConfiguration.fatchInteger() {
            self.planarConfiguration = _planarConfiguration
        }
        if let sampleFormat = tags.first(where: { $0.tag == .SampleFormat }), let _sampleFormat = try? sampleFormat.fatchIntegers(data) {
            self.sampleFormat = Array(_sampleFormat.prefix(self.samplesPerPixel))
        }
        self.sampleFormat.append(contentsOf: repeatElement(1, count: self.samplesPerPixel - self.sampleFormat.count))
        
        if let orientation = tags.first(where: { $0.tag == .Orientation }), let _orientation = try? orientation.fatchInteger() {
            self.orientation = _orientation
        }
        
        if let unit = tags.first(where: { $0.tag == .ResolutionUnit }), let _unit = try? unit.fatchInteger() {
            self.resolutionUnit = _unit
        }
        if let resolutionX = tags.first(where: { $0.tag == .ResolutionX }), let _resolutionX = try? resolutionX.fatchRational(data) {
            self.resolutionX = _resolutionX
        }
        if let resolutionY = tags.first(where: { $0.tag == .ResolutionY }), let _resolutionY = try? resolutionY.fatchRational(data) {
            self.resolutionY = _resolutionY
        }
        
        switch self.compression {
        case 1: break
        default: throw ImageRep.Error.Unsupported("Unsupported compression.")
        }
        
        if self.isMask {
            guard self.photometric == 4 else { throw ImageRep.Error.InvalidFormat("Invalid photometric interpretation.") }
        }
        
        guard self.samplesPerPixel == self.bitsPerSample.count else { throw ImageRep.Error.InvalidFormat("Invalid samples count.") }
        
        for (bits, format) in zip(self.bitsPerSample, self.sampleFormat) where format == 3 {
            guard bits == 32 || bits == 64 else { throw ImageRep.Error.InvalidFormat("Unsupported bits per sample.") }
        }
        
        switch self.photometric {
        case 3:
            guard self.samplesPerPixel == 1 else { throw ImageRep.Error.InvalidFormat("Invalid samples count.") }
            guard self.bitsPerSample[0] == 8 else { throw ImageRep.Error.Unsupported("Unsupported bits per sample.") }
            if let colorMap = tags.first(where: { $0.tag == .ColorMap }) {
                let offset = colorMap.offset
                let length = 3 << self.bitsPerSample[0]
                self.palette = data.dropFirst(offset).prefix(length)
            }
        case 4: guard self.samplesPerPixel == 1 else { throw ImageRep.Error.InvalidFormat("Invalid samples count.") }
        default: guard self.samplesPerPixel >= self.colorSpace.numberOfComponents else { throw ImageRep.Error.InvalidFormat("Invalid samples count.") }
        }
        
        if self.photometric == 3 || self.photometric == 4 {
            guard self.strips.count == self.stripsPerImage else { throw ImageRep.Error.InvalidFormat("Invalid strip count.") }
        } else {
            if let extraSamples = tags.first(where: { $0.tag == .ExtraSamples }), let _extraSamples = try? extraSamples.fatchIntegers(data) {
                if _extraSamples.count == self.samplesPerPixel - self.colorSpace.numberOfComponents {
                    self.extraSamples = _extraSamples
                }
            }
            switch planarConfiguration {
            case 1: guard self.strips.count == self.stripsPerImage else { throw ImageRep.Error.InvalidFormat("Invalid strip count.") }
            case 2: guard self.strips.count == self.samplesPerPixel * self.stripsPerImage else { throw ImageRep.Error.InvalidFormat("Invalid strip count.") }
            default: throw ImageRep.Error.InvalidFormat("Invalid planar configuration.")
            }
        }
        
    }
    
    static func fatchColorSpace(tags: [TIFFTag], photometric: Int, _ data: Data) throws -> AnyColorSpace {
        
        switch photometric {
        case 0, 1, 2, 3, 4, 5, 8, 9: break
        default: throw ImageRep.Error.Unsupported("Unsupported color space.")
        }
        
        if let iccProfile = tags.first(where: { $0.tag == .IccProfile }) {
            let offset = iccProfile.offset
            if offset < data.count, let colorSpace = try? AnyColorSpace(iccData: data.dropFirst(offset)) {
                switch photometric {
                case 0, 1:
                    if colorSpace.base is ColorSpace<GrayColorModel> {
                        return colorSpace
                    }
                case 2, 3:
                    if colorSpace.base is ColorSpace<GrayColorModel> {
                        return colorSpace
                    }
                case 5: return colorSpace
                case 9:
                    if colorSpace.base is ColorSpace<LabColorModel> {
                        return colorSpace
                    }
                default: break
                }
            }
        }
        
        var whitePoint: Point?
        var grayResponseCurve: Double?
        var primaryChromaticities: (Point, Point, Point)?
        
        if let _whitePoint = tags.first(where: { $0.tag == .WhitePoint }), let point = try? _whitePoint.fatchRationals(data) {
            whitePoint = Point(x: point[0], y: point[1])
        }
        
        switch photometric {
        case 0, 1:
            
            if let _grayResponseCurve = tags.first(where: { $0.tag == .GrayResponseCurve }), let curve = try? _grayResponseCurve.fatchInteger() {
                var unit = 2
                if let _grayResponseUnit = tags.first(where: { $0.tag == .GrayResponseUnit }), let _unit = try? _grayResponseUnit.fatchInteger() {
                    unit = _unit
                }
                switch unit {
                case 1: grayResponseCurve = Double(curve) / 10
                case 2: grayResponseCurve = Double(curve) / 100
                case 3: grayResponseCurve = Double(curve) / 1000
                case 4: grayResponseCurve = Double(curve) / 10000
                case 5: grayResponseCurve = Double(curve) / 100000
                default: break
                }
            }
        case 2, 3:
            
            if let _primaryChromaticities = tags.first(where: { $0.tag == .PrimaryChromaticities }), let point = try? _primaryChromaticities.fatchRationals(data) {
                primaryChromaticities = (Point(x: point[0], y: point[1]), Point(x: point[2], y: point[3]), Point(x: point[4], y: point[5]))
            }
        default: break
        }
        
        let D65 = Point(x: 0.3127, y: 0.3290)
        
        switch photometric {
        case 0, 1: return AnyColorSpace(ColorSpace.calibratedGray(white: whitePoint ?? D65, gamma: grayResponseCurve ?? 2.2))
        case 2, 3:
            if let whitePoint = whitePoint, let (red, green, blue) = primaryChromaticities {
                return AnyColorSpace(ColorSpace.calibratedRGB(white: whitePoint, red: red, green: green, blue: blue, gamma: 2.2))
            } else {
                return AnyColorSpace(ColorSpace.calibratedRGB(white: Point(x: 0.3127, y: 0.3290), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.3000, y: 0.6000), blue: Point(x: 0.1500, y: 0.0600), gamma: 2.2))
            }
        case 4: return AnyColorSpace(ColorSpace.calibratedGray(white: D65))
        case 8, 9: return AnyColorSpace(ColorSpace.cieLab(white: Point(x: 0.34567, y: 0.35850)))
        default: fatalError()
        }
    }
    
    var resolution: Resolution {
        switch resolutionUnit {
        case 1: return Resolution(horizontal: resolutionX, vertical: resolutionY, unit: .point)
        case 2: return Resolution(horizontal: resolutionX, vertical: resolutionY, unit: .inch)
        case 3: return Resolution(horizontal: resolutionX, vertical: resolutionY, unit: .centimeter)
        default: return Resolution(resolution: 1, unit: .point)
        }
    }
    
    var columnX: Bool {
        switch orientation {
        case 1, 2, 3, 4: return true
        default: return false
        }
    }
    
    var flipX: Bool {
        switch orientation {
        case 2, 3, 6, 7: return true
        default: return false
        }
    }
    
    var flipY: Bool {
        switch orientation {
        case 3, 4, 7, 8: return true
        default: return false
        }
    }
    
    func image() -> AnyImage {
        
        let colorSpace = self.colorSpace
        
        switch compression {
        case 1:
            if photometric == 3 {
                
                var image = Image<ARGB32ColorPixel>(width: width, height: height, colorSpace: colorSpace.base as! ColorSpace<RGBColorModel>)
                
                image.withUnsafeMutableBufferPointer { uncompressedPalettePixelReader($0.baseAddress) }
                
                return AnyImage(image)
                
            } else {
                
                var image: AnyImage
                
                let row = columnX ? height : width
                let column = columnX ? width : height
                
                switch planarConfiguration {
                case 1:
                    
                    var channels = [RawBitmapChannel]()
                    
                    let bitsPerPixel = self.bitsPerSample.reduce(0, +)
                    
                    var offset = 0
                    for (i, (bits, format)) in zip(self.bitsPerSample, self.sampleFormat).enumerated() {
                        if i < colorSpace.numberOfComponents {
                            for j in 0..<stripsPerImage {
                                if photometric == 8 && i != 0 && format == 1 {
                                    channels.append(RawBitmapChannel(channel: i, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                } else {
                                    switch format {
                                    case 1: channels.append(RawBitmapChannel(channel: i, format: .unsigned, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                    case 2: channels.append(RawBitmapChannel(channel: i, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                    case 3:
                                        switch endianness {
                                        case .BIG: channels.append(RawBitmapChannel(channel: i, format: .float, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                        case .LITTLE: channels.append(RawBitmapChannel(channel: i, format: .float, endianness: .little, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                        default: fatalError()
                                        }
                                    default: break
                                    }
                                }
                            }
                        } else {
                            let flag = extraSamples[i - colorSpace.numberOfComponents]
                            if flag == 1 || flag == 2 {
                                for j in 0..<stripsPerImage {
                                    switch format {
                                    case 1: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .unsigned, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                    case 2: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                    case 3:
                                        switch endianness {
                                        case .BIG: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .float, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                        case .LITTLE: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .float, endianness: .little, startsRow: j * rowsPerStrip, bitmapIndex: j, bitsPerPixel: bitsPerPixel, bitsPerRow: (bitsPerPixel * column).align(8), bitRange: offset..<offset + bits))
                                        default: fatalError()
                                        }
                                    default: break
                                    }
                                }
                            }
                        }
                        offset += bits
                    }
                    
                    image = AnyImage(width: column, height: row, resolution: resolution, channels: channels, bitmaps: strips, premultiplied: extraSamples.contains(1), colorSpace: colorSpace)
                    
                    if !columnX {
                        image = image.transposed()
                    }
                    
                case 2:
                    
                    var channels = [RawBitmapChannel]()
                    
                    for (i, (bits, format)) in zip(self.bitsPerSample, self.sampleFormat).enumerated() {
                        if i < colorSpace.numberOfComponents {
                            for j in 0..<stripsPerImage {
                                if photometric == 8 && i != 0 && format == 1 {
                                    channels.append(RawBitmapChannel(channel: i, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                } else {
                                    switch format {
                                    case 1: channels.append(RawBitmapChannel(channel: i, format: .unsigned, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                    case 2: channels.append(RawBitmapChannel(channel: i, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                    case 3:
                                        switch endianness {
                                        case .BIG: channels.append(RawBitmapChannel(channel: i, format: .float, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                        case .LITTLE: channels.append(RawBitmapChannel(channel: i, format: .float, endianness: .little, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                        default: fatalError()
                                        }
                                    default: break
                                    }
                                }
                            }
                        } else {
                            let flag = extraSamples[i - colorSpace.numberOfComponents]
                            if flag == 1 || flag == 2 {
                                for j in 0..<stripsPerImage {
                                    switch format {
                                    case 1: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .unsigned, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                    case 2: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .signed, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                    case 3:
                                        switch endianness {
                                        case .BIG: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .float, endianness: .big, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                        case .LITTLE: channels.append(RawBitmapChannel(channel: colorSpace.numberOfComponents, format: .float, endianness: .little, startsRow: j * rowsPerStrip, bitmapIndex: i * stripsPerImage + j, bitsPerPixel: bits, bitsPerRow: (bits * column).align(8), bitRange: 0..<bits))
                                        default: fatalError()
                                        }
                                    default: break
                                    }
                                }
                            }
                        }
                    }
                    
                    image = AnyImage(width: column, height: row, resolution: resolution, channels: channels, bitmaps: strips, premultiplied: extraSamples.contains(1), colorSpace: colorSpace)
                    
                    if !columnX {
                        image = image.transposed()
                    }
                    
                default: fatalError()
                }
                if flipX {
                    image = image.horizontalFlipped()
                }
                if flipY {
                    image = image.verticalFlipped()
                }
                return image
                
            }
        default: fatalError()
        }
        
        return AnyImage(width: 0, height: 0, colorSpace: colorSpace)
    }
    
    func uncompressedPalettePixelReader(_ pixel: UnsafeMutablePointer<ARGB32ColorPixel>?) {
        
        guard let pixel = pixel else { return }
        
        let row: Int
        let col: Int
        
        var destination = pixel
        
        if columnX {
            row = flipY ? -width : width
            col = flipX ? -1 : 1
            if flipY {
                destination += width * (height - 1)
            }
            if flipX {
                destination += width - 1
            }
        } else {
            row = flipY ? -1 : 1
            col = flipX ? -width : width
            if flipY {
                destination += width - 1
            }
            if flipX {
                destination += width * (height - 1)
            }
        }
        
        palette?.withUnsafeBytes { (palette: UnsafePointer<(UInt8, UInt8, UInt8)>) in
            
            let palette_count = self.palette!.count / 3
            
            var remain = height
            let rowSize = width
            
            for strip in strips {
                
                let rowCount = min(rowsPerStrip, strip.count / rowSize, remain)
                
                strip.withUnsafeBytes { (buf: UnsafePointer<UInt8>) in
                    var source = buf
                    for _ in 0..<rowCount {
                        
                        var _source = source
                        var _destination = destination
                        
                        for _ in 0..<width {
                            
                            let index = Int(_source.pointee)
                            if index < palette_count {
                                let (r, g, b) = palette[index]
                                _destination.pointee = ARGB32ColorPixel(red: r, green: g, blue: b)
                            }
                            
                            _source += 1
                            _destination += col
                        }
                        
                        source += rowSize
                        destination += row
                    }
                }
                
                remain -= rowCount
            }
        }
        
    }
}

struct TIFFHeader : DataCodable {
    
    var endianness: Endianness
    var version: UInt16
    var IFD: UInt32
    
    init(from data: inout Data) throws {
        
        self.endianness = try data.decode(Endianness.self)
        
        switch self.endianness {
        case .BIG:
            
            self.version = try data.decode(BEUInt16.self).representingValue
            self.IFD = try data.decode(BEUInt32.self).representingValue
            
        case .LITTLE:
            
            self.version = try data.decode(LEUInt16.self).representingValue
            self.IFD = try data.decode(LEUInt32.self).representingValue
            
        default: throw ImageRep.Error.InvalidFormat("Invalid endianness identifier")
        }
    }
    
    func encode(to data: inout Data) {
        
        data.encode(data)
        
        switch endianness {
        case .BIG:
            data.encode(BEUInt16(version))
            data.encode(BEUInt32(IFD))
        case .LITTLE:
            data.encode(LEUInt16(version))
            data.encode(LEUInt32(IFD))
        default: fatalError()
        }
    }
}

extension TIFFHeader {
    
    struct Endianness: SignatureProtocol {
        
        var rawValue: UInt16
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        static let BIG: Endianness                      = "MM"
        static let LITTLE: Endianness                   = "II"
    }
}

struct TIFFTag {
    
    var endianness: TIFFHeader.Endianness
    var tag: Tag
    var type: UInt16
    var count: UInt32
    var data: Data
}

extension TIFFTag {
    
    var offset: Int {
        switch self.endianness {
        case .BIG: return Int(self.data.withUnsafeBytes { $0.pointee as BEUInt32 })
        case .LITTLE: return Int(self.data.withUnsafeBytes { $0.pointee as LEUInt32 })
        default: fatalError()
        }
    }
    
    func fatchInteger() throws -> Int {
        guard self.count == 1 else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
        switch self.endianness {
        case .BIG:
            switch self.type {
            case 1: return Int(self.data.withUnsafeBytes { $0.pointee as UInt8 })
            case 3: return Int(self.data.withUnsafeBytes { $0.pointee as BEUInt16 })
            case 4: return Int(self.data.withUnsafeBytes { $0.pointee as BEUInt32 })
            default: throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)")
            }
        case .LITTLE:
            switch self.type {
            case 1: return Int(self.data.withUnsafeBytes { $0.pointee as UInt8 })
            case 3: return Int(self.data.withUnsafeBytes { $0.pointee as LEUInt16 })
            case 4: return Int(self.data.withUnsafeBytes { $0.pointee as LEUInt32 })
            default: throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)")
            }
        default: fatalError()
        }
    }
    
    func fatchIntegers(_ data: Data) throws -> [Int] {
        if self.count == 1 {
            return [try self.fatchInteger()]
        }
        switch endianness {
        case .BIG:
            
            let offset = self.offset
            switch self.type {
            case 1:
                guard offset + Int(self.count) <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<UInt8>, count: Int(self.count)).map(Int.init) }
            case 3:
                guard offset + Int(self.count) << 1 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<BEUInt16>, count: Int(self.count)).map(Int.init) }
            case 4:
                guard offset + Int(self.count) << 2 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<BEUInt32>, count: Int(self.count)).map(Int.init) }
            default: throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)")
            }
        case .LITTLE:
            
            let offset = self.offset
            switch self.type {
            case 1:
                guard offset + Int(self.count) <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<UInt8>, count: Int(self.count)).map(Int.init) }
            case 3:
                guard offset + Int(self.count) << 1 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<LEUInt16>, count: Int(self.count)).map(Int.init) }
            case 4:
                guard offset + Int(self.count) << 2 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)") }
                return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<LEUInt32>, count: Int(self.count)).map(Int.init) }
            default: throw ImageRep.Error.InvalidFormat("Invalid tag type: \(tag)")
            }
        default: fatalError()
        }
    }
    
    func fatchRational(_ data: Data) throws -> Double {
        guard self.count == 1 && self.type == 5 else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
        switch self.endianness {
        case .BIG:
            let offset = self.offset
            guard offset + 8 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
            let (numerator, denominator) = data.dropFirst(offset).withUnsafeBytes { $0.pointee as (BEUInt32, BEUInt32) }
            return Double(numerator.representingValue) / Double(denominator.representingValue)
        case .LITTLE:
            let offset = self.offset
            guard offset + 8 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
            let (numerator, denominator) = data.dropFirst(offset).withUnsafeBytes { $0.pointee as (LEUInt32, LEUInt32) }
            return Double(numerator.representingValue) / Double(denominator.representingValue)
        default: fatalError()
        }
    }
    
    func fatchRationals(_ data: Data) throws -> [Double] {
        guard self.type == 5 else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
        if self.count == 1 {
            return [try fatchRational(data)]
        }
        switch self.endianness {
        case .BIG:
            let offset = self.offset
            guard offset + Int(self.count) << 3 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
            return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<(BEUInt32, BEUInt32)>, count: Int(self.count)).map { Double($0.0.representingValue) / Double($0.1.representingValue) } }
        case .LITTLE:
            let offset = self.offset
            guard offset + Int(self.count) << 3 <= data.count else { throw ImageRep.Error.InvalidFormat("Invalid tag type: \(self)") }
            return data.dropFirst(offset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<(LEUInt32, LEUInt32)>, count: Int(self.count)).map { Double($0.0.representingValue) / Double($0.1.representingValue) } }
        default: fatalError()
        }
    }
}

extension TIFFTag {
    
    struct Tag: RawRepresentable, Hashable, ExpressibleByIntegerLiteral {
        
        var rawValue: UInt16
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        var hashValue: Int {
            return rawValue.hashValue
        }
        
        init(integerLiteral value: UInt16.IntegerLiteralType) {
            self.init(rawValue: UInt16(integerLiteral: value))
        }
        
        static let NewSubfileType: Tag                             = 254
        static let ImageWidth: Tag                                 = 256
        static let ImageHeight: Tag                                = 257
        static let BitsPerSample: Tag                              = 258
        static let Compression: Tag                                = 259
        static let Photometric: Tag                                = 262
        static let StripOffsets: Tag                               = 273
        static let Orientation: Tag                                = 274
        static let SamplesPerPixel: Tag                            = 277
        static let RowsPerStrip: Tag                               = 278
        static let StripByteCounts: Tag                            = 279
        static let ResolutionX: Tag                                = 282
        static let ResolutionY: Tag                                = 283
        static let PlanarConfiguration: Tag                        = 284
        static let GrayResponseUnit: Tag                           = 290
        static let GrayResponseCurve: Tag                          = 291
        static let ResolutionUnit: Tag                             = 296
        static let TransferFunction: Tag                           = 301
        static let WhitePoint: Tag                                 = 318
        static let PrimaryChromaticities: Tag                      = 319
        static let ColorMap: Tag                                   = 320
        static let TileWidth: Tag                                  = 322
        static let TileLength: Tag                                 = 323
        static let TileOffsets: Tag                                = 324
        static let TileByteCounts: Tag                             = 325
        static let ExtraSamples: Tag                               = 338
        static let SampleFormat: Tag                               = 339
        static let IccProfile: Tag                                 = 34675
    }
}
