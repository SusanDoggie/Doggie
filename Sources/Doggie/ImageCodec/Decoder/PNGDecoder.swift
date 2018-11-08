//
//  PNGDecoder.swift
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

struct PNGDecoder : ImageRepDecoder {
    
    let data: Data
    
    let chunks: [PNGChunk]
    
    init?(data: Data) throws {
        
        guard data.count > 8 else { return nil }
        
        let signature = data.withUnsafeBytes { $0.pointee as (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) }
        
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
        
        guard let first = _chunks.first, first.data.count >= 13 && first.signature == "IHDR" else { return nil }
        
        guard _chunks.contains(where: { $0.signature == "IDAT" }) else { return nil }
        
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
    }
    
    var width: Int {
        return Int(ihdr.width)
    }
    
    var height: Int {
        return Int(ihdr.height)
    }
    
    var resolution: Resolution {
        
        if let phys = chunks.first(where: { $0.signature == "pHYs" }), phys.data.count >= 9 {
            
            let horizontal = phys.data.withUnsafeBytes { $0.pointee as BEUInt32 }
            let vertical = phys.data.dropFirst(4).withUnsafeBytes { $0.pointee as BEUInt32 }
            let unit = phys.data.dropFirst(8).withUnsafeBytes { $0.pointee as UInt8 }
            
            switch unit {
            case 1: return Resolution(horizontal: Double(horizontal), vertical: Double(vertical), unit: .meter)
            default: break
            }
        }
        
        return Resolution(horizontal: 1, vertical: 1, unit: .point)
    }
    
    var palette : [RGBA32ColorPixel]? {
        
        guard let plte = chunks.first(where: { $0.signature == "PLTE" }), plte.data.count % 3 == 0 else { return nil }
        
        let count = plte.data.count / 3
        
        var palette = [RGBA32ColorPixel]()
        palette.reserveCapacity(count)
        
        plte.data.withUnsafeBytes { (ptr: UnsafePointer<(UInt8, UInt8, UInt8)>) in
            
            if let tRNS = chunks.first(where: { $0.signature == "tRNS" }) {
                
                var counter = tRNS.data.count
                
                tRNS.data.withUnsafeBytes { (ptr2: UnsafePointer<UInt8>) in
                    var ptr = ptr
                    var ptr2 = ptr2
                    for _ in 0..<count {
                        let (r, g, b) = ptr.pointee
                        palette.append(RGBA32ColorPixel(red: r, green: g, blue: b, opacity: counter > 0 ? ptr2.pointee : 255))
                        ptr += 1
                        ptr2 += 1
                        counter -= 1
                    }
                }
                
            } else {
                var ptr = ptr
                for _ in 0..<count {
                    let (r, g, b) = ptr.pointee
                    palette.append(RGBA32ColorPixel(red: r, green: g, blue: b))
                    ptr += 1
                }
            }
        }
        
        return palette
    }
    
    var gAMA: Double {
        
        guard let gama = chunks.first(where: { $0.signature == "gAMA" }), gama.data.count >= 4 else { return 100000.0 / 45455.0 }
        
        let gamma = gama.data.withUnsafeBytes { $0.pointee as BEUInt32 }
        return 100000.0 / Double(gamma)
    }
    
    var cHRM: (Point, Point, Point, Point) {
        
        guard let chrm = chunks.first(where: { $0.signature == "cHRM" }), chrm.data.count >= 32 else {
            return (Point(x: 0.3127, y: 0.3290), Point(x: 0.6400, y: 0.3300), Point(x: 0.3000, y: 0.6000), Point(x: 0.1500, y: 0.0600))
        }
        
        let whiteX = chrm.data.withUnsafeBytes { $0.pointee as BEUInt32 }
        let whiteY = chrm.data.dropFirst(4).withUnsafeBytes { $0.pointee as BEUInt32 }
        let redX = chrm.data.dropFirst(8).withUnsafeBytes { $0.pointee as BEUInt32 }
        let redY = chrm.data.dropFirst(12).withUnsafeBytes { $0.pointee as BEUInt32 }
        let greenX = chrm.data.dropFirst(16).withUnsafeBytes { $0.pointee as BEUInt32 }
        let greenY = chrm.data.dropFirst(20).withUnsafeBytes { $0.pointee as BEUInt32 }
        let blueX = chrm.data.dropFirst(24).withUnsafeBytes { $0.pointee as BEUInt32 }
        let blueY = chrm.data.dropFirst(28).withUnsafeBytes { $0.pointee as BEUInt32 }
        
        let white = Point(x: 0.00001 * Double(whiteX), y: 0.00001 * Double(whiteY))
        let red = Point(x: 0.00001 * Double(redX), y: 0.00001 * Double(redY))
        let green = Point(x: 0.00001 * Double(greenX), y: 0.00001 * Double(greenY))
        let blue = Point(x: 0.00001 * Double(blueX), y: 0.00001 * Double(blueY))
        
        return (white, red, green, blue)
    }
    
    var _GrayColorSpace: ColorSpace<GrayColorModel> {
        
        let D65 = Point(x: 0.3127, y: 0.3290)
        let _colorSpace = ColorSpace.calibratedGray(white: D65, gamma: gAMA)
        
        guard let icc = chunks.first(where: { $0.signature == "iCCP" }) else { return _colorSpace }
        
        guard let separator = icc.data.index(of: 0) else { return _colorSpace }
        
        let _offset = separator - icc.data.startIndex
        guard 1...80 ~= _offset && icc.data.count > _offset + 2 else { return _colorSpace }
        
        let compression = icc.data[separator + 1..<separator + 2].withUnsafeBytes { $0.pointee as UInt8 }
        
        guard let iccData = decompress(data: icc.data.suffix(from: separator + 2), compression: compression) else { return _colorSpace }
        guard let iccColorSpace = try? AnyColorSpace(iccData: iccData) else { return _colorSpace }
        
        return iccColorSpace.base as? ColorSpace<GrayColorModel> ?? _colorSpace
    }
    
    var _RGBColorSpace: ColorSpace<RGBColorModel> {
        
        if chunks.contains(where: { $0.signature == "sRGB" }) {
            return .sRGB
        }
        
        let cHRM = self.cHRM
        let _colorSpace = ColorSpace.calibratedRGB(white: cHRM.0, red: cHRM.1, green: cHRM.2, blue: cHRM.3, gamma: gAMA)
        
        guard let icc = chunks.first(where: { $0.signature == "iCCP" }) else { return _colorSpace }
        
        guard let separator = icc.data.index(of: 0) else { return _colorSpace }
        
        let _offset = separator - icc.data.startIndex
        guard 1...80 ~= _offset && icc.data.count > _offset + 2 else { return _colorSpace }
        
        let compression = icc.data[separator + 1..<separator + 2].withUnsafeBytes { $0.pointee as UInt8 }
        
        guard let iccData = decompress(data: icc.data.suffix(from: separator + 2), compression: compression) else { return _colorSpace }
        guard let iccColorSpace = try? AnyColorSpace(iccData: iccData) else { return _colorSpace }
        
        return iccColorSpace.base as? ColorSpace<RGBColorModel> ?? _colorSpace
    }
    
    var colorSpace: AnyColorSpace {
        switch ihdr.colour {
        case 0, 4: return AnyColorSpace(_GrayColorSpace)
        case 2, 3, 6: return AnyColorSpace(_RGBColorSpace)
        default: fatalError()
        }
    }
    
    var mediaType: ImageRep.MediaType {
        return .png
    }
    
    func decompress(data: Data, compression: UInt8) -> Data? {
        do {
            return try self.decompressor(compression)?.process(data)
        } catch {
            return nil
        }
    }
    
    func decompressor(_ compression: UInt8) -> CompressionCodec? {
        switch compression {
        case 0: return try? Inflate()
        default: return nil
        }
    }
    
    func filter(_ data: Data, _ ihdr: IHDR) -> Data? {
        
        let bitsPerPixel: UInt8
        
        switch ihdr.colour {
        case 0: bitsPerPixel = 1 * ihdr.bitDepth
        case 2: bitsPerPixel = 3 * ihdr.bitDepth
        case 3: bitsPerPixel = 1 * ihdr.bitDepth
        case 4: bitsPerPixel = 2 * ihdr.bitDepth
        case 6: bitsPerPixel = 4 * ihdr.bitDepth
        default: fatalError()
        }
        
        let width = Int(ihdr.width)
        let height = Int(ihdr.height)
        
        guard let decompressor = self.decompressor(ihdr.compression) else { return nil }
        
        if ihdr.interlace == 0 {
            switch ihdr.filter {
            case 0:
                
                let rowBits = Int(bitsPerPixel) * width
                let row = (rowBits + 7) >> 3
                var decoder = png_filter0_decoder(row_length: row, bitsPerPixel: bitsPerPixel)
                var result = Data(capacity: row * height)
                
                do {
                    
                    try decompressor.process_final(data) { decoder.decode($0) { result.append(contentsOf: $0) } }
                    decoder.final { result.append(contentsOf: $0) }
                    
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
                    
                    try result.withUnsafeMutableBytes { (destination: UnsafeMutablePointer<UInt8>) in
                        
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
                        
                        try decompressor.process_final(data) { data in
                            
                            interlace_state.scan(data) { state, data in
                                
                                if pass != state.pass {
                                    decoder = png_filter0_decoder(row_length: state.scanline_size, bitsPerPixel: bitsPerPixel)
                                    pass = state.pass
                                }
                                
                                decoder?.decode(data) { filling3(state, $0) }
                            }
                        }
                        
                        decoder?.final { filling3(interlace_state, $0) }
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
    
    func image(fileBacked: Bool) -> AnyImage {
        
        let ihdr = self.ihdr
        
        let width = Int(ihdr.width)
        let height = Int(ihdr.height)
        
        let IDAT_data = Data(chunks.filter { $0.signature == "IDAT" }.flatMap { $0.data })
        
        guard let pixels = filter(IDAT_data, ihdr) else { return AnyImage(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked) }
        
        let bitsPerPixel: UInt8
        
        switch ihdr.colour {
        case 0: bitsPerPixel = ihdr.interlace == 0 ? ihdr.bitDepth : max(8, ihdr.bitDepth)
        case 2: bitsPerPixel = 3 * ihdr.bitDepth
        case 3: bitsPerPixel = ihdr.interlace == 0 ? ihdr.bitDepth : max(8, ihdr.bitDepth)
        case 4: bitsPerPixel = 2 * ihdr.bitDepth
        case 6: bitsPerPixel = 4 * ihdr.bitDepth
        default: fatalError()
        }
        
        let pixels_count = (pixels.count << 3) / Int(bitsPerPixel)
        
        switch ihdr.colour {
        case 0:
            
            switch ihdr.bitDepth {
            case 1, 2, 4:
                
                var image = Image<ColorPixel<GrayColorModel>>(width: width, height: height, resolution: resolution, colorSpace: _GrayColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                    
                    let start = source
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
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
                                
                                for value in ImageRepDecoderBitStream(buffer: source, count: count, bitWidth: Int(bitsPerPixel)) {
                                    
                                    let d: Double
                                    
                                    switch bitsPerPixel {
                                    case 1: d = 1
                                    case 2: d = 3
                                    case 4: d = 15
                                    default: fatalError()
                                    }
                                    
                                    _destination.pointee = ColorPixel(white: Double(value) / d)
                                    _destination += 1
                                }
                                
                                source += row
                                destination += width
                            }
                            
                        } else {
                            let d = Double(1 << ihdr.bitDepth - 1)
                            for _ in 0..<pixels_count {
                                destination.pointee = ColorPixel(white: Double(source.pointee) / d)
                                source += 1
                                destination += 1
                            }
                        }
                    }
                }
                
                return AnyImage(image)
                
            case 8:
                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _GrayColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            destination.pointee = Gray16ColorPixel(white: source.pointee)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            case 16:
                
                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _GrayColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<BEUInt16>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            destination.pointee = Gray32ColorPixel(white: source.pointee.representingValue)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            default: fatalError()
            }
            
        case 2:
            
            switch ihdr.bitDepth {
            case 8:
                var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _RGBColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(UInt8, UInt8, UInt8)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (r, g, b) = source.pointee
                            destination.pointee = RGBA32ColorPixel(red: r, green: g, blue: b)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            case 16:
                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _RGBColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(BEUInt16, BEUInt16, BEUInt16)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (r, g, b) = source.pointee
                            destination.pointee = RGBA64ColorPixel(red: r.representingValue, green: g.representingValue, blue: b.representingValue)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            default: fatalError()
            }
            
        case 3:
            
            var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _RGBColorSpace, fileBacked: fileBacked)
            
            guard let palette = self.palette else { return AnyImage(image) }
            
            palette.withUnsafeBufferPointer { palette in
                
                pixels.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                    
                    let start = source
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
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
            switch ihdr.bitDepth {
            case 8:
                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _GrayColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(UInt8, UInt8)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (w, a) = source.pointee
                            destination.pointee = Gray16ColorPixel(white: w, opacity: a)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            case 16:
                
                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _GrayColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(BEUInt16, BEUInt16)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (w, a) = source.pointee
                            destination.pointee = Gray32ColorPixel(white: w.representingValue, opacity: a.representingValue)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            default: fatalError()
            }
        case 6:
            
            switch ihdr.bitDepth {
            case 8:
                var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _RGBColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(UInt8, UInt8, UInt8, UInt8)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (r, g, b, a) = source.pointee
                            destination.pointee = RGBA32ColorPixel(red: r, green: g, blue: b, opacity: a)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            case 16:
                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: _RGBColorSpace, fileBacked: fileBacked)
                
                pixels.withUnsafeBytes { (source: UnsafePointer<(BEUInt16, BEUInt16, BEUInt16, BEUInt16)>) in
                    
                    var source = source
                    
                    image.withUnsafeMutableBufferPointer { destination in
                        
                        guard var destination = destination.baseAddress else { return }
                        
                        for _ in 0..<pixels_count {
                            let (r, g, b, a) = source.pointee
                            destination.pointee = RGBA64ColorPixel(red: r.representingValue, green: g.representingValue, blue: b.representingValue, opacity: a.representingValue)
                            source += 1
                            destination += 1
                        }
                    }
                }
                
                return AnyImage(image)
                
            default: fatalError()
            }
            
        default: fatalError()
        }
    }
}

extension PNGDecoder {
    
    var ihdr: IHDR {
        return IHDR(data: chunks.first!.data)
    }
    
    struct IHDR {
        
        var width: BEUInt32
        var height: BEUInt32
        var bitDepth: UInt8
        var colour: UInt8
        var compression: UInt8
        var filter: UInt8
        var interlace: UInt8
        
        init(data: Data) {
            self.width = data.withUnsafeBytes { $0.pointee }
            self.height = data.dropFirst(4).withUnsafeBytes { $0.pointee }
            self.bitDepth = data.dropFirst(8).withUnsafeBytes { $0.pointee }
            self.colour = data.dropFirst(9).withUnsafeBytes { $0.pointee }
            self.compression = data.dropFirst(10).withUnsafeBytes { $0.pointee }
            self.filter = data.dropFirst(11).withUnsafeBytes { $0.pointee }
            self.interlace = data.dropFirst(12).withUnsafeBytes { $0.pointee }
        }
    }
}

struct PNGChunk {
    
    var signature: Signature<BEUInt32>
    var data: Data
    
    init(signature: Signature<BEUInt32>, data: Data) {
        self.signature = signature
        self.data = data
    }
    
    init?(data: Data) {
        
        guard data.count >= 12 else { return nil }
        
        let length = data.withUnsafeBytes { $0.pointee as BEUInt32 }
        self.signature = data.dropFirst(4).withUnsafeBytes { $0.pointee }
        
        guard signature.description.allSatisfy({ "a"..."z" ~= $0 || "A"..."Z" ~= $0 }) else { return nil }
        
        self.data = data.dropFirst(8).prefix(Int(length))
    }
    
    func calculateCRC() -> BEUInt32 {
        return BEUInt32(PNGCRC32(signature, data))
    }
}

func PNGCRC32(_ signature: Signature<BEUInt32>, _ data: Data) -> UInt32 {
    
    let table: [UInt32] = [
        0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3,
        0x0eDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91,
        0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5,
        0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B,
        0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F,
        0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D,
        0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01,
        0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
        0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB,
        0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9,
        0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD,
        0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683,
        0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7,
        0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5,
        0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
        0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F,
        0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713,
        0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21,
        0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45,
        0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB,
        0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF,
        0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
    ]
    
    var c: UInt32 = ~0
    
    var _signature = Data()
    signature.write(to: &_signature)
    
    for byte in _signature {
        c = table[Int(UInt8(truncatingIfNeeded: c) ^ byte)] ^ (c >> 8)
    }
    for byte in data {
        c = table[Int(UInt8(truncatingIfNeeded: c) ^ byte)] ^ (c >> 8)
    }
    return ~c
}

