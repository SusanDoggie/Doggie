//
//  FastDecode.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
@usableFromInline
struct _fast_decode_info<Model: ColorModel> {
    
    @usableFromInline
    let width: Int
    
    @usableFromInline
    let height: Int
    
    @usableFromInline
    let is_opaque: Bool
    
    @usableFromInline
    let resolution: Resolution
    
    @usableFromInline
    let colorSpace: ColorSpace<Model>
    
    @usableFromInline
    let premultiplied: Bool
    
    @usableFromInline
    let fileBacked: Bool
    
    @inlinable
    @inline(__always)
    init(
        width: Int,
        height: Int,
        is_opaque: Bool,
        resolution: Resolution,
        colorSpace: ColorSpace<Model>,
        premultiplied: Bool,
        fileBacked: Bool
    ) {
        self.width = width
        self.height = height
        self.is_opaque = is_opaque
        self.resolution = resolution
        self.colorSpace = colorSpace
        self.premultiplied = premultiplied
        self.fileBacked = fileBacked
    }
}

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func _fast_create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> AnyImageBaseProtocol? {
        
        guard !bitmaps.isEmpty else { return nil }
        
        let bitsPerPixel = bitmaps[0].bitsPerPixel
        let channels = bitmaps[0].channels.sorted { $0.bitRange.lowerBound }
        
        let numberOfComponents = self.numberOfComponents
        let is_opaque = !channels.contains { $0.index == numberOfComponents }
        
        guard bitmaps.allSatisfy({ $0.endianness == .big && $0.bitsPerPixel == bitsPerPixel && $0.channels.sorted { $0.bitRange.lowerBound } == channels }) else { return nil }
        
        switch self {
            
        case let colorSpace as ColorSpace<GrayColorModel>:
            
            switch bitsPerPixel {
                
            case 8:
                
                let gray8 = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
                ]
                
                if channels == gray8 {
                    
                    var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        destination.pointee.w = source.pointee
                        destination.pointee.a = UInt8.max
                    }
                    
                    return image
                }
                
            case 16:
                
                let gray16_BE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
                ]
                if channels == gray16_BE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        destination.pointee.w = UInt16(bigEndian: source.pointee)
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
                let gray16_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                ]
                if channels == gray16_LE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        destination.pointee.w = UInt16(littleEndian: source.pointee)
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
                let gray16 = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                ]
                
                if channels == gray16 {
                    
                    var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.w = source.pointee
                        source += 1
                        
                        destination.pointee.a = source.pointee
                    }
                    
                    return image
                }
                
                let gray16_alpha_first = [
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 8..<16),
                ]
                
                if channels == gray16_alpha_first {
                    
                    var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = source.pointee
                        source += 1
                        
                        destination.pointee.w = source.pointee
                    }
                    
                    return image
                }
                
            case 32:
                
                let gray32_BE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
                ]
                
                if channels == gray32_BE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.w = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let gray32_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                ]
                
                if channels == gray32_LE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.w = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let gray32_alpha_first_BE = [
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 16..<32),
                ]
                
                if channels == gray32_alpha_first_BE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.w = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let gray32_alpha_first_LE = [
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 16..<32),
                ]
                
                if channels == gray32_alpha_first_LE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.w = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
            default: break
            }
            
        case let colorSpace as ColorSpace<RGBColorModel>:
            
            switch bitsPerPixel {
                
            case 24:
                
                let bgr24 = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 16..<24),
                ]
                
                if channels == bgr24 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.r = source.pointee
                        source += 1
                        
                        destination.pointee.a = UInt8.max
                    }
                    
                    return image
                }
                
                let rgb24 = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<24),
                ]
                
                if channels == rgb24 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.b = source.pointee
                        source += 1
                        
                        destination.pointee.a = UInt8.max
                    }
                    
                    return image
                }
                
            case 32:
                
                let abgr32 = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<24),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 24..<32),
                ]
                
                if channels == abgr32 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = source.pointee
                        source += 1
                        
                        destination.pointee.b = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.r = source.pointee
                    }
                    
                    return image
                }
                
                let bgra32 = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 16..<24),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 24..<32),
                ]
                
                if channels == bgra32 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.r = source.pointee
                        source += 1
                        
                        destination.pointee.a = source.pointee
                    }
                    
                    return image
                }
                
                let argb32 = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<24),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 24..<32),
                ]
                
                if channels == argb32 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = source.pointee
                        source += 1
                        
                        destination.pointee.r = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.b = source.pointee
                    }
                    
                    return image
                }
                
                let rgba32 = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<24),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 24..<32),
                ]
                
                if channels == rgba32 {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt8.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = source.pointee
                        source += 1
                        
                        destination.pointee.g = source.pointee
                        source += 1
                        
                        destination.pointee.b = source.pointee
                        source += 1
                        
                        destination.pointee.a = source.pointee
                    }
                    
                    return image
                }
                
            case 48:
                
                let bgr48_BE = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 32..<48),
                ]
                
                if channels == bgr48_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
                let rgb48_BE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 32..<48),
                ]
                
                if channels == rgb48_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
                let bgr48_LE = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 32..<48),
                ]
                
                if channels == bgr48_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
                let rgb48_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 32..<48),
                ]
                
                if channels == rgb48_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16.max
                    }
                    
                    return image
                }
                
            case 64:
                
                let abgr64_BE = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 32..<48),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 48..<64),
                ]
                
                if channels == abgr64_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let bgra64_BE = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 32..<48),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 48..<64),
                ]
                
                if channels == bgra64_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let argb64_BE = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 32..<48),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 48..<64),
                ]
                
                if channels == argb64_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let rgba64_BE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 32..<48),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 48..<64),
                ]
                
                if channels == rgba64_BE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(bigEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(bigEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let abgr64_LE = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 32..<48),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 48..<64),
                ]
                
                if channels == abgr64_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let bgra64_LE = [
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 32..<48),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .little, bitRange: 48..<64),
                ]
                
                if channels == bgra64_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let argb64_LE = [
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 32..<48),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 48..<64),
                ]
                
                if channels == argb64_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
                let rgba64_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                    RawBitmap.Channel(index: 2, format: .unsigned, endianness: .little, bitRange: 32..<48),
                    RawBitmap.Channel(index: 3, format: .unsigned, endianness: .little, bitRange: 48..<64),
                ]
                
                if channels == rgba64_LE {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    image._fast_decode_pixel(bitmaps, is_opaque, premultiplied, UInt16.self) { (destination, source) in
                        
                        var source = source
                        
                        destination.pointee.r = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.g = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.b = UInt16(littleEndian: source.pointee)
                        source += 1
                        
                        destination.pointee.a = UInt16(littleEndian: source.pointee)
                    }
                    
                    return image
                }
                
            default: break
            }
            
        default: break
        }
        
        let info = _fast_decode_info(
            width: width,
            height: height,
            is_opaque: is_opaque,
            resolution: resolution,
            colorSpace: self,
            premultiplied: premultiplied,
            fileBacked: fileBacked
        )
        
        switch bitsPerPixel {
            
        case 8 * numberOfComponents:
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, UInt8.self) {
                
                return image
            }
            
        case 16 * numberOfComponents:
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, UInt16.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .little, info, UInt16.self) {
                
                return image
            }
            
        case 32 * numberOfComponents:
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .little, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, { Float(bitPattern: UInt32(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .little, info, { Float(bitPattern: UInt32(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
        case 64 * numberOfComponents:
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .little, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .big, info, { Double(bitPattern: UInt64(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_none(bitmaps, .little, info, { Double(bitPattern: UInt64(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
        case 8 * numberOfComponents + 8:
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, UInt8.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, UInt8.self) {
                
                return image
            }
            
        case 16 * numberOfComponents + 16:
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, UInt16.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .little, info, UInt16.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, UInt16.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .little, info, UInt16.self) {
                
                return image
            }
            
        case 32 * numberOfComponents + 32:
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .little, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .little, info, UInt32.self) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, { Float(bitPattern: UInt32(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .little, info, { Float(bitPattern: UInt32(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, { Float(bitPattern: UInt32(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float32ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .little, info, { Float(bitPattern: UInt32(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
        case 64 * numberOfComponents + 64:
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .little, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .little, info, UInt64.self) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .big, info, { Double(bitPattern: UInt64(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_first(bitmaps, .little, info, { Double(bitPattern: UInt64(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .big, info, { Double(bitPattern: UInt64(bigEndian: $0.bitPattern)) }) {
                
                return image
            }
            
            if let image: Image<Float64ColorPixel<Model>> = _fast_decode_alpha_last(bitmaps, .little, info, { Double(bitPattern: UInt64(littleEndian: $0.bitPattern)) }) {
                
                return image
            }
            
        default: break
        }
        
        return nil
    }
}
