//
//  BMPDecoder.swift
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

struct BMPDecoder : ImageRepDecoder {
    
    let data: Data
    
    let header: BMPHeader
    
    init?(data: Data) throws {
        guard let header = BMPHeader(data: data) else { return nil }
        self.data = data
        self.header = header
        
        guard header.offset < data.count else { throw ImageRep.Error.InvalidFormat("Pixel data not found.") }
        
        if header.paletteSize != 0 {
            guard header.DIB.size + 14 <= header.paletteOffset else { throw ImageRep.Error.InvalidFormat("Palette overlap with header.") }
            
            if header.DIB is BITMAPCOREHEADER {
                guard header.paletteOffset + 3 * header.paletteSize <= header.offset else { throw ImageRep.Error.InvalidFormat("Pixel array overlap with palette.") }
            } else {
                guard header.paletteOffset + 4 * header.paletteSize <= header.offset else { throw ImageRep.Error.InvalidFormat("Pixel array overlap with palette.") }
            }
        }
    }
    
    var width: Int {
        return header.width
    }
    
    var height: Int {
        return header.height
    }
    
    var resolution: Resolution {
        return header.resolution
    }
    
    var _colorSpace: ColorSpace<RGBColorModel> {
        if header.colorSpaceOffset != 0 && header.colorSpaceSize != 0 {
            if header.colorSpaceOffset + header.colorSpaceSize <= data.count {
                guard let iccColorSpace = try? AnyColorSpace(iccData: data.dropFirst(header.colorSpaceOffset)) else { return .sRGB }
                return iccColorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            } else {
                return .sRGB
            }
        } else {
            return header.colorSpace
        }
    }
    
    var colorSpace: AnyColorSpace {
        return AnyColorSpace(_colorSpace)
    }
    
    func image(option: MappedBufferOption) -> AnyImage {
        
        let pixels = data.dropFirst(Int(header.offset))
        
        let colorSpace = self._colorSpace
        
        let width = abs(header.width)
        let height = abs(header.height)
        let resolution = header.resolution
        
        guard width > 0 && height > 0 else { return AnyImage(Image<ARGB32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)) }
        
        func UncompressedPixelReader<Pixel : FixedWidthInteger>(_ rMask: Pixel, _ gMask: Pixel, _ bMask: Pixel, _ aMask: Pixel) -> Image<ColorPixel<RGBColorModel>> {
            
            var rMask = UInt32(rMask)
            var gMask = UInt32(gMask)
            var bMask = UInt32(bMask)
            var aMask = UInt32(aMask)
            
            if header.redBitmask != 0 || header.greenBitmask != 0 || header.blueBitmask != 0 || header.alphaBitmask != 0 {
                
                rMask = UInt32(header.redBitmask)
                gMask = UInt32(header.greenBitmask)
                bMask = UInt32(header.blueBitmask)
                aMask = UInt32(header.alphaBitmask)
            }
            
            let rOffset = rMask.trailingZeroBitCount
            let gOffset = gMask.trailingZeroBitCount
            let bOffset = bMask.trailingZeroBitCount
            let aOffset = aMask.trailingZeroBitCount
            
            let rMax = rMask >> rOffset
            let gMax = gMask >> gOffset
            let bMax = bMask >> bOffset
            let aMax = aMask >> aOffset
            
            var image = Image<ColorPixel<RGBColorModel>>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
            
            guard (rMax + 1).isPower2 else { return image }
            guard (gMax + 1).isPower2 else { return image }
            guard (bMax + 1).isPower2 else { return image }
            guard (aMax + 1).isPower2 else { return image }
            
            pixels.withUnsafeBytes { (source: UnsafePointer<LEInteger<Pixel>>) in
                
                let endOfData = pixels.count + Int(bitPattern: source)
                var source = source
                
                image.withUnsafeMutableBufferPointer { destination in
                    
                    if var destination = destination.baseAddress {
                        
                        let row1 = width & 1 == 0 || Pixel.bitWidth == 32 ? width : width + 1
                        let row2 = header.height > 0 ? -width : width
                        
                        if header.height > 0 {
                            destination += width * (height - 1)
                        }
                        
                        for _ in 0..<height {
                            
                            var _source = source
                            var _destination = destination
                            
                            for _ in 0..<width {
                                
                                guard Int(bitPattern: _source) < endOfData else { return }
                                
                                let color = UInt32(_source.pointee)
                                
                                let r = rMax == 0 ? 0 : Double((color & rMask) >> rOffset) / Double(rMax)
                                let g = gMax == 0 ? 0 : Double((color & gMask) >> gOffset) / Double(gMax)
                                let b = bMax == 0 ? 0 : Double((color & bMask) >> bOffset) / Double(bMax)
                                let a = aMax == 0 ? 1 : Double((color & aMask) >> aOffset) / Double(aMax)
                                
                                _destination.pointee = ColorPixel(red: r, green: g, blue: b, opacity: a)
                                
                                _source += 1
                                _destination += 1
                            }
                            
                            source += row1
                            destination += row2
                        }
                    }
                }
            }
            
            return image
        }
        
        switch header.bitsPerPixel {
        case 16:
            
            let bMask: UInt16 = 0x001F
            let gMask: UInt16 = 0x03E0
            let rMask: UInt16 = 0x7C00
            let aMask: UInt16 = 0x0000
            
            let image = UncompressedPixelReader(rMask, gMask, bMask, aMask)
            
            return AnyImage(image)
            
        case 32:
            
            let bMask: UInt32 = 0x000000FF
            let gMask: UInt32 = 0x0000FF00
            let rMask: UInt32 = 0x00FF0000
            let aMask: UInt32 = 0x00000000
            
            let image = UncompressedPixelReader(rMask, gMask, bMask, aMask)
            
            return AnyImage(image)
            
        case 24:
            
            var image = Image<ARGB32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
            
            pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                
                let endOfData = pixels.count + Int(bitPattern: source)
                var source = source
                
                image.withUnsafeMutableBufferPointer { destination in
                    
                    if var destination = destination.baseAddress {
                        
                        let row1 = (3 * width).align(4)
                        let row2 = header.height > 0 ? -width : width
                        
                        if header.height > 0 {
                            destination += width * (height - 1)
                        }
                        
                        for _ in 0..<height {
                            
                            struct RGB24 {
                                
                                var blue: UInt8
                                var green: UInt8
                                var red: UInt8
                            }
                            
                            source.withMemoryRebound(to: RGB24.self, capacity: 1) { source in
                                
                                var _source = source
                                var _destination = destination
                                
                                for _ in 0..<width {
                                    
                                    guard Int(bitPattern: _source) < endOfData else { return }
                                    
                                    let color = _source.pointee
                                    
                                    _destination.pointee = ARGB32ColorPixel(red: color.red, green: color.green, blue: color.blue)
                                    
                                    _source += 1
                                    _destination += 1
                                }
                            }
                            
                            source += row1
                            destination += row2
                        }
                    }
                }
            }
            
            return AnyImage(image)
            
        default:
            
            let paletteCount = header.paletteSize
            
            let palette: [ARGB32ColorPixel]
            
            if header.DIB is BITMAPCOREHEADER {
                
                struct Palette {
                    
                    var blue: UInt8
                    var green: UInt8
                    var red: UInt8
                }
                
                palette = data.dropFirst(header.paletteOffset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<Palette>, count: paletteCount).map { ARGB32ColorPixel(red: $0.red, green: $0.green, blue: $0.blue) } }
                
            } else {
                
                struct Palette {
                    
                    var blue: UInt8
                    var green: UInt8
                    var red: UInt8
                    var reserved: UInt8
                }
                
                palette = data.dropFirst(header.paletteOffset).withUnsafeBytes { UnsafeBufferPointer(start: $0 as UnsafePointer<Palette>, count: paletteCount).map { ARGB32ColorPixel(red: $0.red, green: $0.green, blue: $0.blue) } }
            }
            
            func UncompressedPixelReader() -> Image<ARGB32ColorPixel> {
                
                let bitWidth = UInt8(header.bitsPerPixel)
                
                var image = Image<ARGB32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
                
                palette.withUnsafeBufferPointer { palette in
                    
                    pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                        
                        let start = source
                        var source = source
                        
                        image.withUnsafeMutableBufferPointer { destination in
                            
                            if var destination = destination.baseAddress {
                                
                                let row1 = (width * Int(bitWidth)).align(32) >> 3
                                let row2 = header.height > 0 ? -width : width
                                
                                if header.height > 0 {
                                    destination += width * (height - 1)
                                }
                                
                                for _ in 0..<height {
                                    
                                    var _destination = destination
                                    
                                    let count: Int
                                    
                                    switch bitWidth {
                                    case 1: count = min(width, min((width + 7) >> 3, pixels.count - (source - start)) << 3)
                                    case 2: count = min(width, min((width + 3) >> 2, pixels.count - (source - start)) << 2)
                                    case 4: count = min(width, min((width + 1) >> 1, pixels.count - (source - start)) << 1)
                                    case 8: count = min(width, pixels.count - (source - start))
                                    default: fatalError()
                                    }
                                    
                                    guard count > 0 else { return }
                                    
                                    for index in ImageRepDecoderBitStream(buffer: source, count: count, bitWidth: Int(bitWidth)) {
                                        
                                        _destination.pointee = index < palette.count ? palette[Int(index)] : ARGB32ColorPixel()
                                        _destination += 1
                                    }
                                    
                                    source += row1
                                    destination += row2
                                }
                            }
                        }
                    }
                }
                
                return image
            }
            
            if let DIB = header.DIB as? BITMAPINFOHEADER {
                switch DIB.compression {
                case .BI_RLE4, .BI_RLE8:
                    
                    let bitWidth = UInt8(header.bitsPerPixel)
                    
                    var image = Image<ARGB32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
                    
                    palette.withUnsafeBufferPointer { palette in
                        
                        pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                            
                            var stream = UnsafeBufferPointer(start: source, count: pixels.count)[...]
                            
                            image.withUnsafeMutableBufferPointer { destination in
                                
                                if var line = destination.baseAddress {
                                    
                                    let row = header.height > 0 ? -width : width
                                    
                                    if header.height > 0 {
                                        line += width * (height - 1)
                                    }
                                    
                                    var _destination = line
                                    
                                    var x = 0
                                    var y = 0
                                    
                                    while let code = stream.popFirst() {
                                        switch code {
                                        case 0:
                                            
                                            guard let mode = stream.popFirst() else { return }
                                            
                                            switch mode {
                                            case 0:
                                                
                                                line += row
                                                _destination = line
                                                x = 0
                                                y += 1
                                                
                                                guard y < height else { return }
                                                
                                            case 1: return
                                            case 2:
                                                
                                                guard let hDelta = stream.popFirst() else { return }
                                                guard let vDelta = stream.popFirst() else { return }
                                                
                                                x += Int(hDelta)
                                                y += Int(vDelta)
                                                line += Int(vDelta)
                                                _destination = line + x
                                                
                                                guard y < height else { return }
                                                
                                            case let count:
                                                
                                                if bitWidth == 4 {
                                                    
                                                    let length = (count + 1) >> 1
                                                    
                                                    let values = stream.prefix(Int(length))
                                                    
                                                    guard stream.count >= Int(length.align(2)) else { return }
                                                    stream.removeFirst(Int(length.align(2)))
                                                    
                                                    guard values.count == length else { return }
                                                    
                                                    for (c, value) in values.enumerated() {
                                                        if c + 1 == length && count & 1 == 1 {
                                                            if x < width && y < height {
                                                                let index = Int((value & 0xF0) >> 4)
                                                                _destination.pointee = index < palette.count ? palette[Int(index)] : ARGB32ColorPixel()
                                                                _destination += 1
                                                                x += 1
                                                            }
                                                        } else {
                                                            let index = Int(value)
                                                            if x < width && y < height {
                                                                let i0 = (index & 0xF0) >> 4
                                                                _destination.pointee = i0 < palette.count ? palette[Int(i0)] : ARGB32ColorPixel()
                                                                _destination += 1
                                                                x += 1
                                                            }
                                                            if x < width && y < height {
                                                                let i1 = index & 0x0F
                                                                _destination.pointee = i1 < palette.count ? palette[Int(i1)] : ARGB32ColorPixel()
                                                                _destination += 1
                                                                x += 1
                                                            }
                                                        }
                                                    }
                                                    
                                                } else {
                                                    let values = stream.prefix(Int(count))
                                                    
                                                    guard stream.count >= Int(count.align(2)) else { return }
                                                    stream.removeFirst(Int(count.align(2)))
                                                    
                                                    guard values.count == count else { return }
                                                    
                                                    for value in values {
                                                        if x < width && y < height {
                                                            let index = Int(value)
                                                            _destination.pointee = index < palette.count ? palette[Int(index)] : ARGB32ColorPixel()
                                                            _destination += 1
                                                            x += 1
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        case let count:
                                            
                                            guard let value = stream.popFirst() else { return }
                                            
                                            for i in 0..<count {
                                                if x < width && y < height {
                                                    let index: Int
                                                    if bitWidth == 4 {
                                                        index = i & 1 == 0 ? Int((value & 0xF0) >> 4) : Int(value & 0x0F)
                                                    } else {
                                                        index = Int(value)
                                                    }
                                                    _destination.pointee = index < palette.count ? palette[Int(index)] : ARGB32ColorPixel()
                                                    _destination += 1
                                                    x += 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    return AnyImage(image)
                    
                default: return AnyImage(UncompressedPixelReader())
                }
            } else {
                 return AnyImage(UncompressedPixelReader())
            }
        }
    }
}

struct BMPHeader {
    
    var signature: Signature<BEUInt16>
    var size: LEUInt32
    var reserved1: LEUInt16
    var reserved2: LEUInt16
    var offset: LEUInt32
    
    var DIB: DIBHeader
    
    init?(data: Data) {
        
        self.signature = data.withUnsafeBytes { $0.pointee }
        self.size = data.dropFirst(2).withUnsafeBytes { $0.pointee }
        self.reserved1 = data.dropFirst(6).withUnsafeBytes { $0.pointee }
        self.reserved2 = data.dropFirst(8).withUnsafeBytes { $0.pointee }
        self.offset = data.dropFirst(10).withUnsafeBytes { $0.pointee }
        
        guard data.count > 18 else { return nil }
        
        let DIBSize: LEUInt32 = data.dropFirst(14).withUnsafeBytes { $0.pointee }
        
        if DIBSize == 12 {
            
            guard let DIB = BITMAPCOREHEADER(data: data.dropFirst(14)) else { return nil }
            
            switch DIB.bitsPerPixel {
            case 1, 4, 8, 24: break
            default: return nil
            }
            
            self.DIB = DIB
            
        } else {
            
            guard let DIB = BITMAPINFOHEADER(data: data.dropFirst(14)) else { return nil }
            
            switch DIB.bitsPerPixel {
            case 1, 2: guard DIB.compression == .BI_RGB else { return nil }
            case 4: guard DIB.compression == .BI_RGB || DIB.compression == .BI_RLE4 else { return nil }
            case 8: guard DIB.compression == .BI_RGB || DIB.compression == .BI_RLE8 else { return nil }
            case 24: guard DIB.compression == .BI_RGB else { return nil }
            case 16, 32: guard DIB.compression == .BI_RGB || DIB.compression == .BI_BITFIELDS || DIB.compression == .BI_ALPHABITFIELDS else { return nil }
            default: return nil
            }
            
            self.DIB = DIB
        }
    }
    
    var width: Int {
        return DIB._width
    }
    
    var height: Int {
        return DIB._height
    }
    
    var resolution: Resolution {
        return Resolution(horizontal: Double(DIB.hResolution.representingValue), vertical: Double(DIB.vResolution.representingValue), unit: .meter)
    }
    
    var bitsPerPixel: Int {
        return Int(DIB.bitsPerPixel)
    }
    
    var colorSpace: ColorSpace<RGBColorModel> {
        return DIB.colorSpace
    }
    
    var colorSpaceOffset: Int {
        return DIB.colorSpaceOffset
    }
    
    var colorSpaceSize: Int {
        return DIB.colorSpaceSize
    }
    
    var paletteOffset: Int {
        return DIB.paletteOffset
    }
    
    var paletteBitSize: Int {
        return DIB.paletteBitSize
    }
    
    var paletteSize: Int {
        return DIB.paletteSize
    }
    
    var redBitmask: LEUInt32 {
        return DIB.redBitmask
    }
    var greenBitmask: LEUInt32 {
        return DIB.greenBitmask
    }
    var blueBitmask: LEUInt32 {
        return DIB.blueBitmask
    }
    var alphaBitmask: LEUInt32 {
        return DIB.alphaBitmask
    }
}

protocol DIBHeader {
    
    var _width: Int { get }
    var _height: Int { get }
    
    var hResolution: LEUInt32 { get }
    var vResolution: LEUInt32 { get }
    
    var size: LEUInt32 { get }
    
    var bitsPerPixel: LEUInt16 { get }
    
    var colorSpace: ColorSpace<RGBColorModel> { get }
    
    var colorSpaceOffset: Int { get }
    
    var colorSpaceSize: Int { get }
    
    var paletteOffset: Int { get }
    
    var paletteBitSize: Int { get }
    
    var paletteSize: Int { get }
    
    var redBitmask: LEUInt32 { get }
    var greenBitmask: LEUInt32 { get }
    var blueBitmask: LEUInt32 { get }
    var alphaBitmask: LEUInt32 { get }
}

struct BITMAPCOREHEADER : DIBHeader {
    
    var size: LEUInt32 = 0
    var width: LEUInt16 = 0
    var height: LEUInt16 = 0
    var planes: LEUInt16 = 0
    var bitsPerPixel: LEUInt16 = 0
    
    init?(data: Data) {
        
        self.size = data.withUnsafeBytes { $0.pointee }
        
        guard self.size <= data.count else { return nil }
        
        self.width = data.dropFirst(4).withUnsafeBytes { $0.pointee }
        self.height = data.dropFirst(6).withUnsafeBytes { $0.pointee }
        self.planes = data.dropFirst(8).withUnsafeBytes { $0.pointee }
        self.bitsPerPixel = data.dropFirst(10).withUnsafeBytes { $0.pointee }
    }
    
    var _width: Int {
        return Int(width)
    }
    var _height: Int {
        return Int(height)
    }
    
    var hResolution: LEUInt32 {
        return 2835
    }
    var vResolution: LEUInt32 {
        return 2835
    }
    
    var colorSpace: ColorSpace<RGBColorModel> {
        return .sRGB
    }
    
    var colorSpaceOffset: Int {
        return 0
    }
    
    var colorSpaceSize: Int {
        return 0
    }
    
    var paletteOffset: Int {
        return 14 + Int(size)
    }
    
    var paletteBitSize: Int {
        return 24
    }
    
    var paletteSize: Int {
        switch bitsPerPixel {
        case 1, 4, 8: return 1 << Int(bitsPerPixel)
        default: return 0
        }
    }
    
    var redBitmask: LEUInt32 {
        return 0
    }
    var greenBitmask: LEUInt32 {
        return 0
    }
    var blueBitmask: LEUInt32 {
        return 0
    }
    var alphaBitmask: LEUInt32 {
        return 0
    }
}

struct BITMAPINFOHEADER : DIBHeader {
    
    var size: LEUInt32 = 0
    var width: LEInt32 = 0
    var height: LEInt32 = 0
    var planes: LEUInt16 = 0
    var bitsPerPixel: LEUInt16 = 0
    
    var compression: CompressionType = 0
    var imageSize: LEUInt32 = 0
    var hResolution: LEUInt32 = 0
    var vResolution: LEUInt32 = 0
    var paletteCount: LEUInt32 = 0
    var importantColorCount: LEUInt32 = 0
    
    // BITMAPV2INFOHEADER
    
    var redBitmask: LEUInt32 = 0
    var greenBitmask: LEUInt32 = 0
    var blueBitmask: LEUInt32 = 0
    
    // BITMAPV3INFOHEADER
    
    var alphaBitmask: LEUInt32 = 0
    
    // BITMAPV4HEADER
    
    var colorSpaceType: ColorSpaceType = 0
    var redX: Fixed30Number<LEUInt32> = 0
    var redY: Fixed30Number<LEUInt32> = 0
    var redZ: Fixed30Number<LEUInt32> = 0
    var greenX: Fixed30Number<LEUInt32> = 0
    var greenY: Fixed30Number<LEUInt32> = 0
    var greenZ: Fixed30Number<LEUInt32> = 0
    var blueX: Fixed30Number<LEUInt32> = 0
    var blueY: Fixed30Number<LEUInt32> = 0
    var blueZ: Fixed30Number<LEUInt32> = 0
    var redGamma: Fixed16Number<LEUInt32> = 0
    var greenGamma: Fixed16Number<LEUInt32> = 0
    var blueGamma: Fixed16Number<LEUInt32> = 0
    
    // BITMAPV5HEADER
    
    var intent: IntentType = 0
    var profileData: LEUInt32 = 0
    var profileSize: LEUInt32 = 0
    var reserved: LEUInt32 = 0
    
    init?(data: Data) {
        
        self.size = data.prefix(4).withUnsafeBytes { $0.pointee }
        
        guard self.size <= data.count else { return nil }
        
        switch self.size {
        case 40, 52, 56, 108, 124: break
        default: return nil
        }
        
        self.width = data.dropFirst(4).withUnsafeBytes { $0.pointee }
        self.height = data.dropFirst(8).withUnsafeBytes { $0.pointee }
        self.planes = data.dropFirst(12).withUnsafeBytes { $0.pointee }
        self.bitsPerPixel = data.dropFirst(14).withUnsafeBytes { $0.pointee }
        
        self.compression = data.dropFirst(16).withUnsafeBytes { $0.pointee }
        self.imageSize = data.dropFirst(20).withUnsafeBytes { $0.pointee }
        self.hResolution = data.dropFirst(24).withUnsafeBytes { $0.pointee }
        self.vResolution = data.dropFirst(28).withUnsafeBytes { $0.pointee }
        self.paletteCount = data.dropFirst(32).withUnsafeBytes { $0.pointee }
        self.importantColorCount = data.dropFirst(36).withUnsafeBytes { $0.pointee }
        
        if self.size == 40 {
            if self.bitsPerPixel == 16 || self.bitsPerPixel == 32 {
                if self.compression == .BI_BITFIELDS {
                    self.size = 52   // Extra bit masks
                }
                if self.compression == .BI_ALPHABITFIELDS {
                    self.size = 56   // Extra bit masks
                }
            }
        }
        
        if self.size >= 52 {
            self.redBitmask = data.dropFirst(40).withUnsafeBytes { $0.pointee }
            self.greenBitmask = data.dropFirst(44).withUnsafeBytes { $0.pointee }
            self.blueBitmask = data.dropFirst(48).withUnsafeBytes { $0.pointee }
        }
        
        if self.size >= 56 {
            self.alphaBitmask = data.dropFirst(52).withUnsafeBytes { $0.pointee }
        }
        
        if self.size >= 108 {
            self.colorSpaceType = data.dropFirst(56).withUnsafeBytes { $0.pointee }
            self.redX = data.dropFirst(60).withUnsafeBytes { $0.pointee }
            self.redY = data.dropFirst(64).withUnsafeBytes { $0.pointee }
            self.redZ = data.dropFirst(68).withUnsafeBytes { $0.pointee }
            self.greenX = data.dropFirst(72).withUnsafeBytes { $0.pointee }
            self.greenY = data.dropFirst(76).withUnsafeBytes { $0.pointee }
            self.greenZ = data.dropFirst(80).withUnsafeBytes { $0.pointee }
            self.blueX = data.dropFirst(84).withUnsafeBytes { $0.pointee }
            self.blueY = data.dropFirst(88).withUnsafeBytes { $0.pointee }
            self.blueZ = data.dropFirst(92).withUnsafeBytes { $0.pointee }
            self.redGamma = data.dropFirst(96).withUnsafeBytes { $0.pointee }
            self.greenGamma = data.dropFirst(100).withUnsafeBytes { $0.pointee }
            self.blueGamma = data.dropFirst(104).withUnsafeBytes { $0.pointee }
        }
        
        if self.size >= 124 {
            self.intent = data.dropFirst(108).withUnsafeBytes { $0.pointee }
            self.profileData = data.dropFirst(112).withUnsafeBytes { $0.pointee }
            self.profileSize = data.dropFirst(116).withUnsafeBytes { $0.pointee }
            self.reserved = data.dropFirst(120).withUnsafeBytes { $0.pointee }
        }
    }
    
    var _width: Int {
        return Int(width)
    }
    var _height: Int {
        return Int(height)
    }
    
    var colorSpace: ColorSpace<RGBColorModel> {
        
        if self.size < 108 {
            return .sRGB
        }
        
        switch colorSpaceType {
        case .LCS_CALIBRATED_RGB:
            
            let red = XYZColorModel(x: redX.representingValue, y: redY.representingValue, z: redZ.representingValue)
            let green = XYZColorModel(x: greenX.representingValue, y: greenY.representingValue, z: greenZ.representingValue)
            let blue = XYZColorModel(x: blueX.representingValue, y: blueY.representingValue, z: blueZ.representingValue)
            
            let white = red + green + blue
            
            let colorSpace = ColorSpace.calibratedRGB(white: white.point, red: red.point, green: green.point, blue: blue.point, gamma: (redGamma.representingValue, greenGamma.representingValue, blueGamma.representingValue))
            
            return colorSpace
            
        case .LCS_sRGB: return .sRGB
        case .LCS_WINDOWS_COLOR_SPACE: return .sRGB
        case .LCS_PROFILE_LINKED: break
        case .LCS_PROFILE_EMBEDDED: break
        default: break
        }
        return .sRGB
    }
    
    var colorSpaceOffset: Int {
        switch colorSpaceType {
        case .LCS_PROFILE_EMBEDDED: return 14 + Int(profileData)
        default: break
        }
        return 0
    }
    
    var colorSpaceSize: Int {
        switch colorSpaceType {
        case .LCS_PROFILE_EMBEDDED: return Int(profileSize)
        default: break
        }
        return 0
    }
    
    var paletteOffset: Int {
        return 14 + Int(size)
    }
    
    var paletteBitSize: Int {
        return 32
    }
    
    var paletteSize: Int {
        switch bitsPerPixel {
        case 1, 2, 4, 8: return paletteCount == 0 ? 1 << Int(bitsPerPixel) : min(1 << Int(bitsPerPixel), Int(paletteCount))
        default: return 0
        }
    }
}

extension BITMAPINFOHEADER {
    
    struct CompressionType: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, DataCodable {
        
        var rawValue: LEUInt32
        
        init(rawValue: LEUInt32) {
            self.rawValue = rawValue
        }
        
        var hashValue: Int {
            return rawValue.hashValue
        }
        
        init(integerLiteral value: LEUInt32.IntegerLiteralType) {
            self.init(rawValue: LEUInt32(integerLiteral: value))
        }
        
        static let BI_RGB: CompressionType                                  = 0x00000000
        static let BI_RLE8: CompressionType                                 = 0x00000001
        static let BI_RLE4: CompressionType                                 = 0x00000002
        static let BI_BITFIELDS: CompressionType                            = 0x00000003
        static let BI_ALPHABITFIELDS: CompressionType                       = 0x00000004
        
        func encode(to data: inout Data) {
            self.rawValue.encode(to: &data)
        }
        
        init(from data: inout Data) throws {
            self.init(rawValue: try LEUInt32(from: &data))
        }
    }
    
    struct ColorSpaceType: SignatureProtocol {
        
        var rawValue: LEUInt32
        
        init(rawValue: LEUInt32) {
            self.rawValue = rawValue
        }
        
        static let LCS_CALIBRATED_RGB: ColorSpaceType                      = 0x00000000
        static let LCS_sRGB: ColorSpaceType                                = "sRGB"
        static let LCS_WINDOWS_COLOR_SPACE: ColorSpaceType                 = "Win "
        static let LCS_PROFILE_LINKED: ColorSpaceType                      = "LINK"
        static let LCS_PROFILE_EMBEDDED: ColorSpaceType                    = "MBED"
    }
    
    struct IntentType: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, DataCodable {
        
        var rawValue: LEUInt32
        
        init(rawValue: LEUInt32) {
            self.rawValue = rawValue
        }
        
        var hashValue: Int {
            return rawValue.hashValue
        }
        
        init(integerLiteral value: LEUInt32.IntegerLiteralType) {
            self.init(rawValue: LEUInt32(integerLiteral: value))
        }
        
        static let LCS_GM_ABS_COLORIMETRIC: IntentType                     = 0x00000008
        static let LCS_GM_BUSINESS: IntentType                             = 0x00000001
        static let LCS_GM_GRAPHICS: IntentType                             = 0x00000002
        static let LCS_GM_IMAGES: IntentType                               = 0x00000004
        
        func encode(to data: inout Data) {
            self.rawValue.encode(to: &data)
        }
        
        init(from data: inout Data) throws {
            self.init(rawValue: try LEUInt32(from: &data))
        }
    }
}

