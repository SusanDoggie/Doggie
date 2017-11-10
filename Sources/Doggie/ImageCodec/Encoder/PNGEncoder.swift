//
//  PNGEncoder.swift
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

struct PNGEncoder : ImageRepEncoder {
    
    private static func encode(_ chunks: PNGChunk ... ) -> Data {
        
        var result = Data()
        
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
            result.append(chunk.data)
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
    
    private static func filter0(_ pixel: Data, _ previous: Data?, _ bitsPerPixel: UInt8) -> Data {
        
        var s = pixel.reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
        
        var filtered = pixel
        var type = 0
        
        for i in 1...4 {
            var buffer = Data(capacity: pixel.count)
            PNGFilter0(UInt8(i), pixel, previous, bitsPerPixel, true, &buffer)
            let t = buffer.reduce(0.0) { $0 + abs(Double(Int8(bitPattern: $1))) }
            if t < s {
                s = t
                filtered = buffer
                type = i
            }
        }
        
        var result = Data(capacity: filtered.count + 1)
        
        result.encode(UInt8(type))
        result.append(filtered)
        
        return result
    }
    
    private static func encodeIDAT<Pixel>(image: Image<Pixel>, bitsPerPixel: UInt8, interlace: Bool, _ body: (inout Data, Pixel) -> Void) -> PNGChunk? {
        
        let width = image.width
        let height = image.height
        
        guard let deflate = try? Deflate(windowBits: 15) else { return nil }
        
        var compressed = Data(capacity: height * width * Int(bitsPerPixel >> 3))
        
        do {
            
            if interlace {
                
                try image.withUnsafeBufferPointer {
                    
                    guard let buffer = $0.baseAddress else { return }
                    
                    let starting_row = [0, 0, 4, 0, 2, 0, 1]
                    let starting_col = [0, 4, 0, 2, 0, 1, 0]
                    let row_increment = [8, 8, 8, 4, 4, 2, 2]
                    let col_increment = [8, 8, 4, 4, 2, 2, 1]
                    
                    for pass in 0..<7 {
                        
                        let _starting_row = starting_row[pass]
                        let _starting_col = starting_col[pass]
                        let _row_increment = row_increment[pass]
                        let _col_increment = col_increment[pass]
                        
                        guard width > _starting_col else { continue }
                        guard height > _starting_row else { continue }
                        
                        let sample_count = (width - _starting_col + (_col_increment - 1)) / _col_increment
                        let scanline_bitSize = Int(bitsPerPixel) * sample_count
                        let scanline_size = (scanline_bitSize + 7) >> 3
                        
                        var previous: Data?
                        
                        for row in stride(from: _starting_row, to: height, by: _row_increment) {
                            
                            var scanline = Data(capacity: scanline_size)
                            
                            for col in stride(from: _starting_col, to: width, by: _col_increment) {
                                
                                let position = row * width + col
                                let destination = buffer + position
                                
                                body(&scanline, destination.pointee)
                            }
                            
                            try deflate.process(filter0(scanline, previous, bitsPerPixel), &compressed)
                            
                            previous = scanline
                        }
                    }
                }
                
            } else {
                
                let scanline_capacity = width * Int(bitsPerPixel >> 3)
                
                try image.withUnsafeBufferPointer {
                    
                    guard var buffer = $0.baseAddress else { return }
                    
                    var previous: Data?
                    
                    for _ in 0..<height {
                        
                        var scanline = Data(capacity: scanline_capacity)
                        
                        for _ in 0..<width {
                            body(&scanline, buffer.pointee)
                            buffer += 1
                        }
                        
                        try deflate.process(filter0(scanline, previous, bitsPerPixel), &compressed)
                        
                        previous = scanline
                    }
                }
            }
            
            try deflate.final(&compressed)
            
        } catch {
            return nil
        }
        
        return PNGChunk(signature: "IDAT", data: compressed)
    }
    
    private static func encodeRGB(image: Image<ARGB64ColorPixel>, interlace: Bool) -> Data? {
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: 16, colour: opaque ? 2 : 6, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        guard let iccp = iCCP(image.colorSpace) else { return nil }
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 48, interlace: interlace) {
                $0.encode(BEUInt16($1.r))
                $0.encode(BEUInt16($1.g))
                $0.encode(BEUInt16($1.b))
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 64, interlace: interlace) {
                $0.encode(BEUInt16($1.r))
                $0.encode(BEUInt16($1.g))
                $0.encode(BEUInt16($1.b))
                $0.encode(BEUInt16($1.a))
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    private static func encodeRGB(image: Image<ARGB32ColorPixel>, interlace: Bool) -> Data? {
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: 8, colour: opaque ? 2 : 6, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        guard let iccp = iCCP(image.colorSpace) else { return nil }
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 24, interlace: interlace) {
                $0.encode($1.r)
                $0.encode($1.g)
                $0.encode($1.b)
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 32, interlace: interlace) {
                $0.encode($1.r)
                $0.encode($1.g)
                $0.encode($1.b)
                $0.encode($1.a)
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    private static func encodeGray(image: Image<Gray32ColorPixel>, interlace: Bool) -> Data? {
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: 16, colour: opaque ? 0 : 4, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        guard let iccp = iCCP(image.colorSpace) else { return nil }
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 16, interlace: interlace) {
                $0.encode(BEUInt16($1.w))
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 32, interlace: interlace) {
                $0.encode(BEUInt16($1.w))
                $0.encode(BEUInt16($1.a))
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    private static func encodeGray(image: Image<Gray16ColorPixel>, interlace: Bool) -> Data? {
        
        let opaque = image.isOpaque
        
        let ihdr = IHDR(width: image.width, height: image.height, bitDepth: 8, colour: opaque ? 0 : 4, interlace: interlace)
        let phys = pHYs(image.resolution)
        
        guard let iccp = iCCP(image.colorSpace) else { return nil }
        
        let _idat: PNGChunk?
        
        if opaque {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 8, interlace: interlace) {
                $0.encode($1.w)
            }
        } else {
            
            _idat = encodeIDAT(image: image, bitsPerPixel: 16, interlace: interlace) {
                $0.encode($1.w)
                $0.encode($1.a)
            }
        }
        
        guard let idat = _idat else { return nil }
        
        return encode(ihdr, phys, iccp, idat)
    }
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        
        let interlaced = properties[ImageRep.PropertyKey.interlaced] as? Bool == true
        
        if let image = image.base as? Image<Gray32ColorPixel> {
            return encodeGray(image: image, interlace: interlaced)
        }
        
        if let image = Image<Gray16ColorPixel>(image: image) {
            return encodeGray(image: image, interlace: interlaced)
        }
        
        if let image = image.base as? Image<ARGB64ColorPixel> {
            return encodeRGB(image: image, interlace: interlaced)
        }
        
        if let image = Image<ARGB32ColorPixel>(image: image) {
            return encodeRGB(image: image, interlace: interlaced)
        }
        
        return encodeRGB(image: Image<ARGB32ColorPixel>(image: image, colorSpace: .sRGB), interlace: interlaced)
    }
}

