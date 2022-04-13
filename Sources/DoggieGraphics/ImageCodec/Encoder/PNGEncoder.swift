//
//  PNGEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

struct PNGEncoder: ImageRepEncoder {
    
    static func encode(_ chunks: [PNGChunk]) -> MappedBuffer<UInt8> {
        
        var result = MappedBuffer<UInt8>(fileBacked: true)
        
        result.append(0x89)
        result.append(0x50)
        result.append(0x4E)
        result.append(0x47)
        result.append(0x0D)
        result.append(0x0A)
        result.append(0x1A)
        result.append(0x0A)
        
        for chunk in chunks.appended(PNGChunk(signature: "IEND", data: Data())) {
            result.encode(BEUInt32(chunk.data.count))
            result.encode(chunk.signature)
            result.append(contentsOf: chunk.data)
            result.encode(chunk.calculateCRC())
        }
        
        return result
    }
    
    static func IHDR(width: Int, height: Int, bitDepth: UInt8, colour: UInt8, interlaced: Bool) -> PNGChunk {
        
        let width: BEUInt32 = BEUInt32(width)
        let height: BEUInt32 = BEUInt32(height)
        let bitDepth: UInt8 = bitDepth
        let colour: UInt8 = colour
        let compression: UInt8 = 0
        let filter: UInt8 = 0
        let interlaced: UInt8 = interlaced ? 1 : 0
        
        var ihdr = Data(capacity: 13)
        
        ihdr.encode(width)
        ihdr.encode(height)
        ihdr.encode(bitDepth)
        ihdr.encode(colour)
        ihdr.encode(compression)
        ihdr.encode(filter)
        ihdr.encode(interlaced)
        
        return PNGChunk(signature: "IHDR", data: ihdr)
    }
    
    static func iCCP<C>(_ colorSpace: ColorSpace<C>, deflate_level: Deflate.Level) -> PNGChunk? {
        
        if let iccData = colorSpace.iccData, let data = try? Deflate(level: deflate_level, windowBits: 15).process(iccData) {
            
            var iccp = Data()
            
            iccp.append("Doggie ICC profile".data(using: .isoLatin1)!)
            iccp.append(0)
            iccp.append(0)
            iccp.append(data)
            
            return PNGChunk(signature: "iCCP", data: iccp)
        }
        
        return nil
    }
    
    static func pHYs(_ resolution: Resolution) -> PNGChunk {
        
        var phys = Data()
        
        let resolution = resolution.convert(to: .meter)
        
        phys.encode(BEUInt32(round(resolution.horizontal).clamped(to: 0...4294967295)))
        phys.encode(BEUInt32(round(resolution.vertical).clamped(to: 0...4294967295)))
        phys.append(0)
        
        return PNGChunk(signature: "pHYs", data: phys)
    }
    
    static func encodeIDAT<Pixel>(image: Image<Pixel>, region: PNGRegion, bitsPerPixel: UInt8, deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool, _ body: (inout Data, Pixel) -> Void) -> PNGChunk? {
        
        let width = region.width
        let height = region.height
        
        let image_width = image.width
        
        guard let deflate = try? Deflate(level: deflate_level, windowBits: 15) else { return nil }
        
        var compressed = MappedBuffer<UInt8>(capacity: height * width * Int(bitsPerPixel >> 3), fileBacked: true)
        
        do {
            
            if interlaced {
                
                try image.withUnsafeBufferPointer {
                    
                    guard var buffer = $0.baseAddress else { return }
                    buffer += region.x + region.y * image_width
                    
                    for pass in 0..<7 {
                        
                        let starting_row = png_interlace_starting_row[pass]
                        let starting_col = png_interlace_starting_col[pass]
                        let row_increment = png_interlace_row_increment[pass]
                        let col_increment = png_interlace_col_increment[pass]
                        
                        guard width > starting_col else { continue }
                        guard height > starting_row else { continue }
                        
                        let scanline_count = (width - starting_col + (col_increment - 1)) / col_increment
                        let scanline_size = (Int(bitsPerPixel) * scanline_count + 7) >> 3
                        
                        var encoder = png_filter0_encoder(row_length: scanline_size, bitsPerPixel: bitsPerPixel, methods: predictor)
                        
                        var scanline = Data(capacity: scanline_size)
                        
                        for row in stride(from: starting_row, to: height, by: row_increment) {
                            
                            scanline.count = 0
                            
                            for col in stride(from: starting_col, to: width, by: col_increment) {
                                
                                let destination = buffer + row * image_width + col
                                
                                body(&scanline, destination.pointee)
                            }
                            
                            try scanline.withUnsafeBufferPointer { try encoder.encode($0) { try deflate.update($0) { compressed.append(contentsOf: $0) } } }
                        }
                        
                        try encoder.finalize { try deflate.update($0) { compressed.append(contentsOf: $0) } }
                    }
                }
                
            } else {
                
                let scanline_size = width * Int(bitsPerPixel >> 3)
                
                try image.withUnsafeBufferPointer {
                    
                    guard var buffer = $0.baseAddress else { return }
                    buffer += region.x + region.y * image_width
                    
                    var encoder = png_filter0_encoder(row_length: scanline_size, bitsPerPixel: bitsPerPixel, methods: predictor)
                    
                    var scanline = Data(capacity: scanline_size)
                    
                    for _ in 0..<height {
                        
                        scanline.count = 0
                        
                        var _buffer = buffer
                        
                        for _ in 0..<width {
                            body(&scanline, _buffer.pointee)
                            _buffer += 1
                        }
                        
                        buffer += image_width
                        
                        try scanline.withUnsafeBufferPointer { try encoder.encode($0) { try deflate.update($0) { compressed.append(contentsOf: $0) } } }
                        
                    }
                    
                    try encoder.finalize { try deflate.update($0) { compressed.append(contentsOf: $0) } }
                }
            }
            
            try deflate.finalize(&compressed)
            
        } catch {
            return nil
        }
        
        return PNGChunk(signature: "IDAT", data: compressed.data)
    }
    
    static func encodeIDAT<Pixel>(image: Image<Pixel>, region: PNGRegion, deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool, opaque: Bool) -> PNGChunk? where Pixel: TIFFEncodablePixel {
        
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        let bitDepth = UInt8(bytesPerSample << 3)
        
        if opaque {
            
            let bitsPerPixel = bitDepth * UInt8(Pixel.numberOfComponents - 1)
            
            return encodeIDAT(image: image, region: region, bitsPerPixel: bitsPerPixel, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced) {
                $1.tiff_encode_color(&$0)
            }
            
        } else {
            
            let bitsPerPixel = bitDepth * UInt8(Pixel.numberOfComponents)
            
            return encodeIDAT(image: image, region: region, bitsPerPixel: bitsPerPixel, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced) {
                $1.tiff_encode_color(&$0)
                $1.tiff_encode_opacity(&$0)
            }
        }
    }
    
    static func encodeRGB<Pixel>(image: Image<Pixel>, region: PNGRegion, deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool) -> MappedBuffer<UInt8>? where Pixel: TIFFEncodablePixel, Pixel.Model == RGBColorModel {
        
        guard let iccp = iCCP(image.colorSpace, deflate_level: deflate_level) else { return encodeRGB(image: Image<Pixel>(image: image, colorSpace: .sRGB), region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced) }
        
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        let bitDepth = UInt8(bytesPerSample << 3)
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: bitDepth, colour: opaque ? 2 : 6, interlaced: interlaced)
        let phys = pHYs(image.resolution)
        
        guard let idat = encodeIDAT(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
        
        return encode([ihdr, phys, iccp, idat])
    }
    
    static func encodeGray<Pixel>(image: Image<Pixel>, region: PNGRegion, deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool) -> MappedBuffer<UInt8>? where Pixel: TIFFEncodablePixel, Pixel.Model == GrayColorModel {
        
        guard let iccp = iCCP(image.colorSpace, deflate_level: deflate_level) else { return encodeGray(image: Image<Pixel>(image: image, colorSpace: .genericGamma22Gray), region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced) }
        
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        let bitDepth = UInt8(bytesPerSample << 3)
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: bitDepth, colour: opaque ? 0 : 4, interlaced: interlaced)
        let phys = pHYs(image.resolution)
        
        guard let idat = encodeIDAT(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
        
        return encode([ihdr, phys, iccp, idat])
    }
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let deflate_level = properties[.deflateLevel] as? Deflate.Level ?? .default
        let predictor = properties[.predictor] as? PNGPrediction ?? .all
        let interlaced = properties[.interlaced] as? Bool == true
        
        let region = PNGRegion(x: 0, y: 0, width: image.width, height: image.height)
        
        if let image = image.base as? Image<Gray32ColorPixel> {
            return encodeGray(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = Image<Gray16ColorPixel>(image) {
            return encodeGray(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = image.base as? Image<ARGB64ColorPixel> {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = image.base as? Image<RGBA64ColorPixel> {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = image.base as? Image<RGBA32ColorPixel> {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = image.base as? Image<ABGR32ColorPixel> {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = image.base as? Image<BGRA32ColorPixel> {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        if let image = Image<ARGB32ColorPixel>(image) {
            return encodeRGB(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
        }
        
        return encodeRGB(image: image.convert(to: .sRGB) as Image<ARGB32ColorPixel>, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced)?.data
    }
}

