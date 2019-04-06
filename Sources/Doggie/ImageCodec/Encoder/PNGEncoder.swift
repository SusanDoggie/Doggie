//
//  PNGEncoder.swift
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

struct PNGEncoder : ImageRepEncoder {
    
    private static func encode(_ chunks: PNGChunk ... ) -> MappedBuffer<UInt8> {
        
        var result = MappedBuffer<UInt8>(fileBacked: true)
        
        result.encode(0x89 as UInt8)
        result.encode(0x50 as UInt8)
        result.encode(0x4E as UInt8)
        result.encode(0x47 as UInt8)
        result.encode(0x0D as UInt8)
        result.encode(0x0A as UInt8)
        result.encode(0x1A as UInt8)
        result.encode(0x0A as UInt8)
        
        for chunk in chunks.appended(PNGChunk(signature: "IEND", data: Data())) {
            result.encode(BEUInt32(chunk.data.count))
            result.encode(chunk.signature)
            result.append(contentsOf: chunk.data)
            result.encode(chunk.calculateCRC())
        }
        
        return result
    }
    
    private static func IHDR(width: Int, height: Int, bitDepth: UInt8, colour: UInt8, interlace: Bool) -> PNGChunk {
        
        let width: BEUInt32 = BEUInt32(width)
        let height: BEUInt32 = BEUInt32(height)
        let bitDepth: UInt8 = bitDepth
        let colour: UInt8 = colour
        let compression: UInt8 = 0
        let filter: UInt8 = 0
        let interlace: UInt8 = interlace ? 1 : 0
        
        var ihdr = Data(capacity: 13)
        
        ihdr.encode(width)
        ihdr.encode(height)
        ihdr.encode(bitDepth)
        ihdr.encode(colour)
        ihdr.encode(compression)
        ihdr.encode(filter)
        ihdr.encode(interlace)
        
        return PNGChunk(signature: "IHDR", data: ihdr)
    }
    
    private static func iCCP<C>(_ colorSpace: ColorSpace<C>) -> PNGChunk? {
        
        if let iccData = colorSpace.iccData, let data = try? Deflate(windowBits: 15).process(iccData) {
            
            var iccp = Data()
            
            iccp.append("Doggie ICC profile".data(using: .isoLatin1)!)
            iccp.encode(0 as UInt8)
            iccp.encode(0 as UInt8)
            iccp.append(data)
            
            return PNGChunk(signature: "iCCP", data: iccp)
        }
        
        return nil
    }
    
    private static func pHYs(_ resolution: Resolution) -> PNGChunk {
        
        var phys = Data()
        
        let resolution = resolution.convert(to: .meter)
        
        phys.encode(BEUInt32(round(resolution.horizontal).clamped(to: 0...4294967295)))
        phys.encode(BEUInt32(round(resolution.vertical).clamped(to: 0...4294967295)))
        phys.encode(0 as UInt8)
        
        return PNGChunk(signature: "pHYs", data: phys)
    }
    
    private static func encodeIDAT<Pixel>(image: Image<Pixel>, bitsPerPixel: UInt8, interlace: Bool, _ body: (inout Data, Pixel) -> Void) -> PNGChunk? {
        
        let width = image.width
        let height = image.height
        
        guard let deflate = try? Deflate(windowBits: 15) else { return nil }
        
        var compressed = MappedBuffer<UInt8>(capacity: height * width * Int(bitsPerPixel >> 3), fileBacked: true)
        
        do {
            
            if interlace {
                
                try image.withUnsafeBufferPointer {
                    
                    guard let buffer = $0.baseAddress else { return }
                    
                    for pass in 0..<7 {
                        
                        let starting_row = png_interlace_starting_row[pass]
                        let starting_col = png_interlace_starting_col[pass]
                        let row_increment = png_interlace_row_increment[pass]
                        let col_increment = png_interlace_col_increment[pass]
                        
                        guard width > starting_col else { continue }
                        guard height > starting_row else { continue }
                        
                        let scanline_count = (width - starting_col + (col_increment - 1)) / col_increment
                        let scanline_size = (Int(bitsPerPixel) * scanline_count + 7) >> 3
                        
                        var encoder = png_filter0_encoder(row_length: scanline_size, bitsPerPixel: bitsPerPixel)
                        
                        var scanline = Data(capacity: scanline_size)
                        
                        for row in stride(from: starting_row, to: height, by: row_increment) {
                            
                            scanline.count = 0
                            
                            for col in stride(from: starting_col, to: width, by: col_increment) {
                                
                                let position = row * width + col
                                let destination = buffer + position
                                
                                body(&scanline, destination.pointee)
                            }
                            
                            try scanline.withUnsafeBufferPointer { try encoder.encode($0) { try deflate.process($0) { compressed.append(contentsOf: $0) } } }
                        }
                        
                        try encoder.final { try deflate.process($0) { compressed.append(contentsOf: $0) } }
                    }
                }
                
            } else {
                
                let scanline_size = width * Int(bitsPerPixel >> 3)
                
                try image.withUnsafeBufferPointer {
                    
                    guard var buffer = $0.baseAddress else { return }
                    
                    var encoder = png_filter0_encoder(row_length: scanline_size, bitsPerPixel: bitsPerPixel)
                    
                    var scanline = Data(capacity: scanline_size)
                    
                    for _ in 0..<height {
                        
                        scanline.count = 0
                        
                        for _ in 0..<width {
                            body(&scanline, buffer.pointee)
                            buffer += 1
                        }
                        
                        try scanline.withUnsafeBufferPointer { try encoder.encode($0) { try deflate.process($0) { compressed.append(contentsOf: $0) } } }
                        
                    }
                    
                    try encoder.final { try deflate.process($0) { compressed.append(contentsOf: $0) } }
                }
            }
            
            try deflate.final(&compressed)
            
        } catch {
            return nil
        }
        
        return PNGChunk(signature: "IDAT", data: compressed.data)
    }
    
    private static func encodeRGB<Pixel>(image: Image<Pixel>, interlace: Bool) -> MappedBuffer<UInt8>? where Pixel : PNGEncodablePixel, Pixel.Model == RGBColorModel {
        
        guard let iccp = iCCP(image.colorSpace) else { return encodeRGB(image: Image<Pixel>(image: image, colorSpace: .sRGB), interlace: interlace) }
        
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        let bitDepth = UInt8(bytesPerSample << 3)
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: bitDepth, colour: opaque ? 2 : 6, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: bitDepth * 3, interlace: interlace) {
                $1.png_encode_color(&$0)
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: bitDepth * 4, interlace: interlace) {
                $1.png_encode_color(&$0)
                $1.png_encode_opacity(&$0)
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    private static func encodeGray<Pixel>(image: Image<Pixel>, interlace: Bool) -> MappedBuffer<UInt8>? where Pixel : PNGEncodablePixel, Pixel.Model == GrayColorModel {
        
        guard let iccp = iCCP(image.colorSpace) else { return encodeGray(image: Image<Pixel>(image: image, colorSpace: .genericGamma22Gray), interlace: interlace) }
        
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        let bitDepth = UInt8(bytesPerSample << 3)
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: bitDepth, colour: opaque ? 0 : 4, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: bitDepth, interlace: interlace) {
                $1.png_encode_color(&$0)
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: bitDepth * 2, interlace: interlace) {
                $1.png_encode_color(&$0)
                $1.png_encode_opacity(&$0)
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        
        let interlaced = properties[.interlaced] as? Bool == true
        
        if let image = image.base as? Image<Gray32ColorPixel> {
            return encodeGray(image: image, interlace: interlaced)?.data
        }
        
        if let image = Image<Gray16ColorPixel>(image) {
            return encodeGray(image: image, interlace: interlaced)?.data
        }
        
        if let image = image.base as? Image<ARGB64ColorPixel> {
            return encodeRGB(image: image, interlace: interlaced)?.data
        }
        
        if let image = image.base as? Image<RGBA64ColorPixel> {
            return encodeRGB(image: image, interlace: interlaced)?.data
        }
        
        if let image = image.base as? Image<RGBA32ColorPixel> {
            return encodeRGB(image: image, interlace: interlaced)?.data
        }
        
        if let image = image.base as? Image<BGRA32ColorPixel> {
            return encodeRGB(image: image, interlace: interlaced)?.data
        }
        
        if let image = Image<ARGB32ColorPixel>(image) {
            return encodeRGB(image: image, interlace: interlaced)?.data
        }
        
        return encodeRGB(image: Image<ARGB32ColorPixel>(image: image, colorSpace: .sRGB), interlace: interlaced)?.data
    }
}

