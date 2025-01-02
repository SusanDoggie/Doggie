//
//  PNGDecoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

struct PNGDecoder: ImageRepDecoder {
    
    static var supportedMediaTypes: [MediaType] {
        return [.png]
    }
    
    var mediaType: MediaType {
        return .png
    }
    
    let data: Data
    
    let chunks: [PNGChunk]
    
    let ihdr: IHDR
    let idat: Data
    
    var actl: AnimationControlChunk?
    var frames: [Frame] = []
    
    init?(data: Data) throws {
        
        guard data.count > 8 else { return nil }
        
        let signature = data.load(as: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
        
        guard (signature.0, signature.1, signature.2, signature.3) == (0x89, 0x50, 0x4E, 0x47) else { return nil }
        guard (signature.4, signature.5, signature.6, signature.7) == (0x0D, 0x0A, 0x1A, 0x0A) else { return nil }
        
        var _chunks = [PNGChunk]()
        var _data = data.dropFirst(8)
        
        while _chunks.last?.signature != "IEND" {
            guard let chunk = PNGChunk(data: _data) else { break }
            _chunks.append(chunk)
            guard _data.count > 12 + chunk.data.count else { break }
            _data = _data.dropFirst(12 + chunk.data.count)
        }
        
        guard let ihdr_chunk = _chunks.first, ihdr_chunk.data.count >= 13 && ihdr_chunk.signature == "IHDR" else { return nil }
        self.ihdr = IHDR(data: ihdr_chunk.data)
        
        guard _chunks.contains(where: { $0.signature == "IDAT" }) else { return nil }
        self.idat = Data(_chunks.filter { $0.signature == "IDAT" }.flatMap { $0.data })
        
        self.data = data
        self.chunks = _chunks
        
        let ihdr = self.ihdr
        
        switch ihdr.colour {
        case 0:
            switch ihdr.bitDepth {
            case 1, 2, 4, 8, 16: break
            default: throw ImageRep.Error.InvalidFormat("Disllowed bit depths.")
            }
        case 2:
            switch ihdr.bitDepth {
            case 8, 16: break
            default: throw ImageRep.Error.InvalidFormat("Disllowed bit depths.")
            }
        case 3:
            switch ihdr.bitDepth {
            case 1, 2, 4, 8: break
            default: throw ImageRep.Error.InvalidFormat("Disllowed bit depths.")
            }
        case 4:
            switch ihdr.bitDepth {
            case 8, 16: break
            default: throw ImageRep.Error.InvalidFormat("Disllowed bit depths.")
            }
        case 6:
            switch ihdr.bitDepth {
            case 8, 16: break
            default: throw ImageRep.Error.InvalidFormat("Disllowed bit depths.")
            }
        default: throw ImageRep.Error.InvalidFormat("Unknown colour type.")
        }
        
        self.resolve_frames()
    }
    
    var width: Int {
        return Int(ihdr.width)
    }
    
    var height: Int {
        return Int(ihdr.height)
    }
    
    var resolution: Resolution {
        return _png_resolution(chunks: chunks)
    }
    
    var colorSpace: AnyColorSpace {
        return _png_colorspace(ihdr: ihdr, chunks: chunks)
    }
    
    func image(fileBacked: Bool) -> AnyImage {
        
        let width = Int(ihdr.width)
        let height = Int(ihdr.height)
        
        return _png_image(ihdr: ihdr, chunks: chunks, width: width, height: height, data: idat, fileBacked: fileBacked)
    }
}

extension PNGDecoder {
    
    struct IHDR {
        
        var width: BEUInt32
        var height: BEUInt32
        var bitDepth: UInt8
        var colour: UInt8
        var compression: UInt8
        var filter: UInt8
        var interlace: UInt8
        
        init(data: Data) {
            self.width = data.load(as: BEUInt32.self)
            self.height = data.load(fromByteOffset: 4, as: BEUInt32.self)
            self.bitDepth = data.load(fromByteOffset: 8, as: UInt8.self)
            self.colour = data.load(fromByteOffset: 9, as: UInt8.self)
            self.compression = data.load(fromByteOffset: 10, as: UInt8.self)
            self.filter = data.load(fromByteOffset: 11, as: UInt8.self)
            self.interlace = data.load(fromByteOffset: 12, as: UInt8.self)
        }
    }
}

func _png_resolution(chunks: [PNGChunk]) -> Resolution {
    
    if let phys = chunks.first(where: { $0.signature == "pHYs" }), phys.data.count >= 9 {
        
        let horizontal = phys.data.load(as: BEUInt32.self)
        let vertical = phys.data.load(fromByteOffset: 4, as: BEUInt32.self)
        let unit = phys.data.load(fromByteOffset: 8, as: UInt8.self)
        
        switch unit {
        case 1: return Resolution(horizontal: Double(horizontal), vertical: Double(vertical), unit: .meter)
        default: break
        }
    }
    
    return Resolution(horizontal: 1, vertical: 1, unit: .point)
}

func _png_decompress(data: Data, compression: UInt8) -> Data? {
    switch compression {
    case 0: return try? Inflate().process(data)
    default: return nil
    }
}

func _png_colorspace(ihdr: PNGDecoder.IHDR, chunks: [PNGChunk]) -> AnyColorSpace {
    
    var gAMA: Double {
        
        guard let gama = chunks.first(where: { $0.signature == "gAMA" }), gama.data.count >= 4 else { return 100000.0 / 45455.0 }
        
        let gamma = gama.data.load(as: BEUInt32.self)
        return 100000.0 / Double(gamma)
    }
    
    var cHRM: (Point, Point, Point, Point) {
        
        guard let chrm = chunks.first(where: { $0.signature == "cHRM" }), chrm.data.count >= 32 else {
            return (CIE1931.D65.rawValue, Point(x: 0.6400, y: 0.3300), Point(x: 0.3000, y: 0.6000), Point(x: 0.1500, y: 0.0600))
        }
        
        let whiteX = chrm.data.load(as: BEUInt32.self)
        let whiteY = chrm.data.load(fromByteOffset: 4, as: BEUInt32.self)
        let redX = chrm.data.load(fromByteOffset: 8, as: BEUInt32.self)
        let redY = chrm.data.load(fromByteOffset: 12, as: BEUInt32.self)
        let greenX = chrm.data.load(fromByteOffset: 16, as: BEUInt32.self)
        let greenY = chrm.data.load(fromByteOffset: 20, as: BEUInt32.self)
        let blueX = chrm.data.load(fromByteOffset: 24, as: BEUInt32.self)
        let blueY = chrm.data.load(fromByteOffset: 28, as: BEUInt32.self)
        
        let white = Point(x: 0.00001 * Double(whiteX), y: 0.00001 * Double(whiteY))
        let red = Point(x: 0.00001 * Double(redX), y: 0.00001 * Double(redY))
        let green = Point(x: 0.00001 * Double(greenX), y: 0.00001 * Double(greenY))
        let blue = Point(x: 0.00001 * Double(blueX), y: 0.00001 * Double(blueY))
        
        return (white, red, green, blue)
    }
    
    var _GrayColorSpace: ColorSpace<GrayColorModel> {
        
        let _colorSpace = ColorSpace.calibratedGray(illuminant: CIE1931.D65, gamma: gAMA)
        
        guard let icc = chunks.first(where: { $0.signature == "iCCP" }) else { return _colorSpace }
        
        guard let separator = icc.data.firstIndex(of: 0) else { return _colorSpace }
        
        let _offset = separator - icc.data.startIndex
        guard 1...80 ~= _offset && icc.data.count > _offset + 2 else { return _colorSpace }
        
        let compression = icc.data[separator + 1..<separator + 2].load(as: UInt8.self)
        
        guard let iccData = _png_decompress(data: icc.data.suffix(from: separator + 2), compression: compression) else { return _colorSpace }
        guard let iccColorSpace = try? AnyColorSpace(iccData: iccData) else { return _colorSpace }
        
        return iccColorSpace.base as? ColorSpace<GrayColorModel> ?? _colorSpace
    }
    
    var _RGBColorSpace: ColorSpace<RGBColorModel> {
        
        if chunks.contains(where: { $0.signature == "sRGB" }) {
            return .sRGB
        }
        
        let chrm = cHRM
        let _colorSpace = ColorSpace.calibratedRGB(white: chrm.0, red: chrm.1, green: chrm.2, blue: chrm.3, gamma: gAMA)
        
        guard let icc = chunks.first(where: { $0.signature == "iCCP" }) else { return _colorSpace }
        
        guard let separator = icc.data.firstIndex(of: 0) else { return _colorSpace }
        
        let _offset = separator - icc.data.startIndex
        guard 1...80 ~= _offset && icc.data.count > _offset + 2 else { return _colorSpace }
        
        let compression = icc.data[separator + 1..<separator + 2].load(as: UInt8.self)
        
        guard let iccData = _png_decompress(data: icc.data.suffix(from: separator + 2), compression: compression) else { return _colorSpace }
        guard let iccColorSpace = try? AnyColorSpace(iccData: iccData) else { return _colorSpace }
        
        return iccColorSpace.base as? ColorSpace<RGBColorModel> ?? _colorSpace
    }
    
    switch ihdr.colour {
    case 0, 4: return AnyColorSpace(_GrayColorSpace)
    case 2, 3, 6: return AnyColorSpace(_RGBColorSpace)
    default: fatalError()
    }
}

func _png_palette(chunks: [PNGChunk]) -> [RGBA32ColorPixel]? {
    
    guard let plte = chunks.first(where: { $0.signature == "PLTE" }), plte.data.count % 3 == 0 else { return nil }
    
    let count = plte.data.count / 3
    
    var palette = [RGBA32ColorPixel]()
    palette.reserveCapacity(count)
    
    if let trns = chunks.first(where: { $0.signature == "tRNS" }) {
        
        plte.data.withUnsafeBufferPointer(as: (UInt8, UInt8, UInt8).self) {
            
            guard var plte = $0.baseAddress else { return }
            
            trns.data.withUnsafeBufferPointer { trns in
                
                let trns_count = min(count, trns.count)
                
                if var _trns = trns.baseAddress {
                    
                    for _ in 0..<trns_count {
                        let (r, g, b) = plte.pointee
                        palette.append(RGBA32ColorPixel(red: r, green: g, blue: b, opacity: _trns.pointee))
                        plte += 1
                        _trns += 1
                    }
                }
                
                for _ in trns_count..<count {
                    let (r, g, b) = plte.pointee
                    palette.append(RGBA32ColorPixel(red: r, green: g, blue: b))
                    plte += 1
                }
            }
        }
        
    } else {
        
        plte.data.withUnsafeBufferPointer(as: (UInt8, UInt8, UInt8).self) {
            
            guard var plte = $0.baseAddress else { return }
            
            for _ in 0..<count {
                let (r, g, b) = plte.pointee
                palette.append(RGBA32ColorPixel(red: r, green: g, blue: b))
                plte += 1
            }
        }
    }
    
    return palette
}

func _png_image(ihdr: PNGDecoder.IHDR, chunks: [PNGChunk], width: Int, height: Int, data: Data?, fileBacked: Bool) -> AnyImage {
    
    let bitsPerPixel: UInt8
    
    switch ihdr.colour {
    case 0: bitsPerPixel = ihdr.interlace == 0 ? ihdr.bitDepth : max(8, ihdr.bitDepth)
    case 2: bitsPerPixel = 3 * ihdr.bitDepth
    case 3: bitsPerPixel = ihdr.interlace == 0 ? ihdr.bitDepth : max(8, ihdr.bitDepth)
    case 4: bitsPerPixel = 2 * ihdr.bitDepth
    case 6: bitsPerPixel = 4 * ihdr.bitDepth
    default: fatalError()
    }
    
    let pixels = data.flatMap { _png_filter(ihdr: ihdr, width: width, height: height, data: $0) }
    let pixels_count = pixels.map { ($0.count << 3) / Int(bitsPerPixel) } ?? 0
    
    let resolution = _png_resolution(chunks: chunks)
    let colorSpace = _png_colorspace(ihdr: ihdr, chunks: chunks)
    
    switch ihdr.colour {
    case 0:
        
        guard let colorSpace = colorSpace.base as? ColorSpace<GrayColorModel> else { fatalError() }
        
        var transparent: UInt16?
        
        if let tRNS = chunks.first(where: { $0.signature == "tRNS" }), tRNS.data.count >= 2 {
            transparent = tRNS.data.load(as: BEUInt16.self).representingValue
        }
        
        switch ihdr.bitDepth {
        case 1, 2, 4:
            
            var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            let transparent = transparent.map { UInt8(truncatingIfNeeded: $0) }
            
            pixels?.withUnsafeBufferPointer { pixels in
                
                guard var source = pixels.baseAddress else { return }
                
                let start = source
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    if ihdr.interlace == 0 {
                        
                        let rowBits = Int(bitsPerPixel) * width
                        let row = (rowBits + 7) >> 3
                        
                        let channel_max: UInt8
                        
                        switch bitsPerPixel {
                        case 1: channel_max = 1
                        case 2: channel_max = 3
                        case 4: channel_max = 15
                        default: fatalError()
                        }
                        
                        for _ in 0..<height {
                            
                            var _destination = destination
                            
                            let count: Int
                            
                            switch bitsPerPixel {
                            case 1: count = min(width, min((width + 7) >> 3, pixels.count - (source - start)) << 3)
                            case 2: count = min(width, min((width + 3) >> 2, pixels.count - (source - start)) << 2)
                            case 4: count = min(width, min((width + 1) >> 1, pixels.count - (source - start)) << 1)
                            default: fatalError()
                            }
                            
                            guard count > 0 else { return }
                            
                            for value in ImageRepDecoderBitStream(buffer: source, count: count, bitWidth: Int(bitsPerPixel)) {
                                
                                if value != transparent {
                                    _destination.pointee = Gray16ColorPixel(white: _mul_div(value, UInt8.max, channel_max))
                                }
                                
                                _destination += 1
                            }
                            
                            source += row
                            destination += width
                        }
                        
                    } else {
                        
                        let channel_max: UInt8
                        
                        switch ihdr.bitDepth {
                        case 1: channel_max = 1
                        case 2: channel_max = 3
                        case 4: channel_max = 15
                        case 8: channel_max = 255
                        default: fatalError()
                        }
                        
                        for _ in 0..<pixels_count {
                            
                            let value = source.pointee
                            
                            if value != transparent {
                                destination.pointee = Gray16ColorPixel(white: _mul_div(value, UInt8.max, channel_max))
                            }
                            
                            source += 1
                            destination += 1
                        }
                    }
                }
            }
            
            return AnyImage(image)
            
        case 8:
            
            if let pixels = pixels {
                
                let decoder = GrayPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                if let transparent = transparent {
                    
                    let image = decoder.decode_gray8(data: pixels, transparent: UInt8(truncatingIfNeeded: transparent), fileBacked: fileBacked)
                    
                    return AnyImage(image)
                    
                } else {
                    
                    let image = decoder.decode_opaque_gray8(data: pixels, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                }
                
            } else {
                
                let image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        case 16:
            
            if let pixels = pixels {
                
                let decoder = GrayPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                if let transparent = transparent {
                    
                    let image = decoder.decode_gray16(data: pixels, transparent: transparent, endianness: .big, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                    
                } else {
                    
                    let image = decoder.decode_opaque_gray16(data: pixels, endianness: .big, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                }
                
            } else {
                
                let image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        default: fatalError()
        }
        
    case 2:
        
        guard let colorSpace = colorSpace.base as? ColorSpace<RGBColorModel> else { fatalError() }
        
        var transparent: (UInt16, UInt16, UInt16)?
        
        if let tRNS = chunks.first(where: { $0.signature == "tRNS" }), tRNS.data.count >= 6 {
            let red = tRNS.data.load(as: BEUInt16.self).representingValue
            let green = tRNS.data.load(fromByteOffset: 2, as: BEUInt16.self).representingValue
            let blue = tRNS.data.load(fromByteOffset: 4, as: BEUInt16.self).representingValue
            transparent = (red, green, blue)
        }
        
        switch ihdr.bitDepth {
        case 8:
            
            if let pixels = pixels {
                
                let decoder = RGBPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                if let (r, g, b) = transparent {
                    
                    let _r = UInt8(truncatingIfNeeded: r)
                    let _g = UInt8(truncatingIfNeeded: g)
                    let _b = UInt8(truncatingIfNeeded: b)
                    
                    let image = decoder.decode_rgb24(data: pixels, transparent: (_r, _g, _b), fileBacked: fileBacked)
                    
                    return AnyImage(image)
                    
                } else {
                    
                    let image = decoder.decode_rgb24(data: pixels, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                }
                
            } else {
                
                let image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        case 16:
            
            if let pixels = pixels {
                
                let decoder = RGBPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                if let transparent = transparent {
                    
                    let image = decoder.decode_rgb48(data: pixels, transparent: transparent, endianness: .big, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                    
                } else {
                    
                    let image = decoder.decode_rgb48(data: pixels, endianness: .big, fileBacked: fileBacked)
                    
                    return AnyImage(image)
                }
                
            } else {
                
                let image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        default: fatalError()
        }
        
    case 3:
        
        guard let colorSpace = colorSpace.base as? ColorSpace<RGBColorModel> else { fatalError() }
        
        var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        guard let palette = _png_palette(chunks: chunks) else { return AnyImage(image) }
        
        pixels?.withUnsafeBufferPointer { pixels in
            
            guard var source = pixels.baseAddress else { return }
            
            palette.withUnsafeBufferPointer { palette in
                
                let start = source
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    if ihdr.interlace == 0 {
                        
                        let rowBits = Int(bitsPerPixel) * width
                        let row = (rowBits + 7) >> 3
                        
                        for _ in 0..<height {
                            
                            var _destination = destination
                            
                            let count: Int
                            
                            switch bitsPerPixel {
                            case 1: count = min(width, min((width + 7) >> 3, pixels.count - (source - start)) << 3)
                            case 2: count = min(width, min((width + 3) >> 2, pixels.count - (source - start)) << 2)
                            case 4: count = min(width, min((width + 1) >> 1, pixels.count - (source - start)) << 1)
                            case 8: count = min(width, pixels.count - (source - start))
                            default: fatalError()
                            }
                            
                            guard count > 0 else { return }
                            
                            for index in ImageRepDecoderBitStream(buffer: source, count: count, bitWidth: Int(bitsPerPixel)) {
                                
                                _destination.pointee = index < palette.count ? palette[Int(index)] : RGBA32ColorPixel()
                                _destination += 1
                            }
                            
                            source += row
                            destination += width
                        }
                        
                    } else {
                        
                        for _ in 0..<pixels_count {
                            let index = source.pointee
                            destination.pointee = index < palette.count ? palette[Int(index)] : RGBA32ColorPixel()
                            source += 1
                            destination += 1
                        }
                    }
                }
            }
        }
        
        return AnyImage(image)
        
    case 4:
        
        guard let colorSpace = colorSpace.base as? ColorSpace<GrayColorModel> else { fatalError() }
        
        switch ihdr.bitDepth {
        case 8:
            
            if let pixels = pixels {
                
                let decoder = GrayPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                let image = decoder.decode_gray16(data: pixels, fileBacked: fileBacked)
                
                return AnyImage(image)
                
            } else {
                
                let image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        case 16:
            
            if let pixels = pixels {
                
                let decoder = GrayPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                let image = decoder.decode_gray32(data: pixels, endianness: .big, fileBacked: fileBacked)
                
                return AnyImage(image)
                
            } else {
                
                let image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        default: fatalError()
        }
    case 6:
        
        guard let colorSpace = colorSpace.base as? ColorSpace<RGBColorModel> else { fatalError() }
        
        switch ihdr.bitDepth {
        case 8:
            
            if let pixels = pixels {
                
                let decoder = RGBPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                let image = decoder.decode_rgba32(data: pixels, fileBacked: fileBacked)
                
                return AnyImage(image)
                
            } else {
                
                let image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        case 16:
            
            if let pixels = pixels {
                
                let decoder = RGBPixelDecoder(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
                
                let image = decoder.decode_rgba64(data: pixels, endianness: .big, fileBacked: fileBacked)
                
                return AnyImage(image)
                
            } else {
                
                let image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                return AnyImage(image)
            }
            
        default: fatalError()
        }
        
    default: fatalError()
    }
}

func _png_filter(ihdr: PNGDecoder.IHDR, width: Int, height: Int, data: Data) -> Data? {
    
    let bitsPerPixel: UInt8
    
    switch ihdr.colour {
    case 0: bitsPerPixel = 1 * ihdr.bitDepth
    case 2: bitsPerPixel = 3 * ihdr.bitDepth
    case 3: bitsPerPixel = 1 * ihdr.bitDepth
    case 4: bitsPerPixel = 2 * ihdr.bitDepth
    case 6: bitsPerPixel = 4 * ihdr.bitDepth
    default: fatalError()
    }
    
    let decompressor: CompressionCodec
    
    switch ihdr.compression {
    case 0:
        guard let _decompressor = try? Inflate() else { return nil }
        decompressor = _decompressor
    default: return nil
    }
    
    if ihdr.interlace == 0 {
        switch ihdr.filter {
        case 0:
            
            let rowBits = Int(bitsPerPixel) * width
            let row = (rowBits + 7) >> 3
            var decoder = png_filter0_decoder(row_length: row, bitsPerPixel: bitsPerPixel)
            var result = Data(capacity: row * height)
            
            do {
                
                try decompressor.update(data) { decoder.decode($0) { result.append(contentsOf: $0) } }
                try decompressor.finalize { decoder.decode($0) { result.append(contentsOf: $0) } }
                decoder.finalize { result.append(contentsOf: $0) }
                
            } catch {
                return nil
            }
            
            return result
            
        default: break
        }
    } else {
        switch ihdr.filter {
        case 0:
            
            var result = Data(count: max(1, Int(bitsPerPixel >> 3)) * width * height)
            
            do {
                
                try result.withUnsafeMutableTypePunnedBufferPointer(to: UInt8.self) {
                    
                    guard let destination = $0.baseAddress else { return }
                    
                    func filling(_ value: UInt8, _ column: Int, _ row: Int, _ _width: Int, _ _height: Int) {
                        
                        let position = row * width + column
                        var destination = destination + position
                        
                        for _ in 0..<_height {
                            
                            var _destination = destination
                            
                            for _ in 0..<_width {
                                _destination.pointee = value
                                _destination += 1
                            }
                            
                            destination += width
                        }
                    }
                    
                    func filling2(_ offset: Int, _ value: UnsafePointer<UInt8>, _ column: Int, _ row: Int, _ _width: Int, _ _height: Int) {
                        
                        let position = row * width + column
                        var destination = destination + position * offset
                        
                        for _ in 0..<_height {
                            
                            var _destination = destination
                            
                            for _ in 0..<_width {
                                memcpy(_destination, value, offset)
                                _destination += offset
                            }
                            
                            destination += width * offset
                        }
                    }
                    
                    func filling3(_ state: png_interlace_state, _ scanline: UnsafeBufferPointer<UInt8>) {
                        
                        guard var source = scanline.baseAddress else { return }
                        guard state.pass < 7 else { return }
                        
                        let row = state.current_row
                        let starting_col = state.starting_col
                        let col_increment = state.col_increment
                        let block_width = state.block_width
                        let block_height = state.block_height
                        
                        switch bitsPerPixel {
                        case 1:
                            
                            var _col = stride(from: starting_col, to: width, by: col_increment).makeIterator()
                            for _ in 0..<scanline.count {
                                var p = source.pointee
                                for _ in 0..<8 {
                                    guard let col = _col.next() else { return }
                                    let index = (p & 0x80) >> 7
                                    p <<= bitsPerPixel
                                    filling(index, col, row, min(block_width, width - col), min(block_height, height - row))
                                }
                                source += 1
                            }
                            
                        case 2:
                            
                            var _col = stride(from: starting_col, to: width, by: col_increment).makeIterator()
                            for _ in 0..<scanline.count {
                                var p = source.pointee
                                for _ in 0..<4 {
                                    guard let col = _col.next() else { return }
                                    let index = (p & 0xC0) >> 6
                                    p <<= bitsPerPixel
                                    filling(index, col, row, min(block_width, width - col), min(block_height, height - row))
                                }
                                source += 1
                            }
                            
                        case 4:
                            
                            var _col = stride(from: starting_col, to: width, by: col_increment).makeIterator()
                            for _ in 0..<scanline.count {
                                var p = source.pointee
                                for _ in 0..<2 {
                                    guard let col = _col.next() else { return }
                                    let index = (p & 0xF0) >> 4
                                    p <<= bitsPerPixel
                                    filling(index, col, row, min(block_width, width - col), min(block_height, height - row))
                                }
                                source += 1
                            }
                            
                        default:
                            var counter = 0
                            let offset = Int(bitsPerPixel >> 3)
                            for col in stride(from: starting_col, to: width, by: col_increment) {
                                guard counter < scanline.count else { return }
                                filling2(offset, source, col, row, min(block_width, width - col), min(block_height, height - row))
                                counter += offset
                                source += offset
                            }
                        }
                    }
                    
                    var interlace_state = png_interlace_state(width: width, height: height, bitsPerPixel: bitsPerPixel)
                    var decoder: png_filter0_decoder?
                    
                    var pass: Int?
                    
                    func scanner(_ data: UnsafeBufferPointer<UInt8>) {
                        
                        interlace_state.scan(data) { state, data in
                            
                            if pass != state.pass {
                                decoder = png_filter0_decoder(row_length: state.scanline_size, bitsPerPixel: bitsPerPixel)
                                pass = state.pass
                            }
                            
                            decoder?.decode(data) { filling3(state, $0) }
                        }
                    }
                    
                    try decompressor.update(data, scanner)
                    try decompressor.finalize(scanner)
                    
                    decoder?.finalize { filling3(interlace_state, $0) }
                }
                
            } catch {
                return nil
            }
            
            return result
            
        default: break
        }
    }
    
    return nil
}
