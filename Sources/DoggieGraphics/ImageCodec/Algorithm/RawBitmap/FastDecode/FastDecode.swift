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

extension Image where Pixel: TIFFEncodablePixel {
    
    @inlinable
    @inline(__always)
    mutating func _fast_decode<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _: T.Type, callback: (UnsafeMutablePointer<Pixel>, UnsafePointer<T>) -> Void) {
        
        let numberOfComponents = is_opaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        
        self.withUnsafeMutableBufferPointer {
            
            guard var dest = $0.baseAddress else { return }
            
            dest += bitmap.startsRow * width
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    
                    guard var source = bytes.baseAddress else { return }
                    var destination = dest
                    let source_end = source + _length
                    
                    for _ in 0..<width {
                        
                        guard source + bytesPerPixel <= source_end else { return }
                        
                        let _source = source.bindMemory(to: T.self, capacity: numberOfComponents)
                        
                        callback(destination, _source)
                        
                        switch bitmap.tiff_predictor {
                        case 1: break
                        case 2:
                            if destination > dest {
                                let lhs = destination - 1
                                destination.pointee = destination.pointee.tiff_prediction_2_decode(lhs.pointee)
                            }
                        default: fatalError("Unsupported tiff predictor.")
                        }
                        
                        source += bytesPerPixel
                        destination += 1
                    }
                    
                    dest += width
                }
            }
        }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _fast_decode<T: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ is_opaque: Bool, _: T.Type, callback: (UnsafeMutablePointer<T>, UnsafePointer<T>) -> Void) {
        
        let numberOfComponents = is_opaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        
        self.withUnsafeMutableBufferPointer {
            
            guard var dest = $0.baseAddress else { return }
            
            dest += bitmap.startsRow * width
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    
                    guard var source = bytes.baseAddress else { return }
                    var destination = dest
                    let source_end = source + _length
                    
                    for _ in 0..<width {
                        
                        guard source + bytesPerPixel <= source_end else { return }
                        
                        let _source = source.bindMemory(to: T.self, capacity: numberOfComponents)
                        let _destination = UnsafeRawMutablePointer(destination).bindMemory(to: T.self, capacity: Pixel.numberOfComponents)
                        
                        callback(_destination, _source)
                        
                        source += bytesPerPixel
                        destination += 1
                    }
                    
                    dest += width
                }
            }
        }
    }
}

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func _fast_create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> AnyImageBaseProtocol? {
        
        guard !bitmaps.isEmpty else { return nil }
        
        let bitsPerPixel = bitmaps[0].bitsPerPixel
        let channels = bitmaps[0].channels.sorted { $0.bitRange.lowerBound }
        
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt8.self) { (destination, source) in
                            
                            destination.pointee.w = source.pointee
                            destination.pointee.a = UInt8.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
            case 16:
                
                let gray16_BE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
                ]
                if channels == gray16_BE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            destination.pointee.w = UInt16(bigEndian: source.pointee)
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
                let gray16_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                ]
                if channels == gray16_LE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            destination.pointee.w = UInt16(littleEndian: source.pointee)
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
                let gray16 = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
                ]
                
                if channels == gray16 {
                    
                    var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.w = source.pointee
                            source += 1
                            
                            destination.pointee.a = source.pointee
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.w = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(bigEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
                let gray32_LE = [
                    RawBitmap.Channel(index: 0, format: .unsigned, endianness: .little, bitRange: 0..<16),
                    RawBitmap.Channel(index: 1, format: .unsigned, endianness: .little, bitRange: 16..<32),
                ]
                
                if channels == gray32_LE {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.w = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(littleEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.r = source.pointee
                            source += 1
                            
                            destination.pointee.a = UInt8.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.b = source.pointee
                            source += 1
                            
                            destination.pointee.a = UInt8.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = source.pointee
                            source += 1
                            
                            destination.pointee.b = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.r = source.pointee
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.r = source.pointee
                            source += 1
                            
                            destination.pointee.a = source.pointee
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = source.pointee
                            source += 1
                            
                            destination.pointee.r = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.b = source.pointee
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt8.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = source.pointee
                            source += 1
                            
                            destination.pointee.g = source.pointee
                            source += 1
                            
                            destination.pointee.b = source.pointee
                            source += 1
                            
                            destination.pointee.a = source.pointee
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, true, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16.max
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(bigEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(bigEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(bigEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(littleEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.a = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
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
                    
                    for bitmap in bitmaps {
                        
                        image._fast_decode(bitmap, false, UInt16.self) { (destination, source) in
                            
                            var source = source
                            
                            destination.pointee.r = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.g = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.b = UInt16(littleEndian: source.pointee)
                            source += 1
                            
                            destination.pointee.a = UInt16(littleEndian: source.pointee)
                        }
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
            default: break
            }
            
        default: break
        }
        
        switch bitsPerPixel {
            
        case 32 * Model.numberOfComponents:
            
            var float32_alpha_none_BE: [RawBitmap.Channel] = []
            for i in 0..<Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_none_BE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_none_BE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(bigEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                        
                        destination.pointee = 1
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float32_alpha_none_LE: [RawBitmap.Channel] = []
            for i in 0..<Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_none_LE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_none_LE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(littleEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                        
                        destination.pointee = 1
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        case 64 * Model.numberOfComponents:
            
            var float64_alpha_none_BE: [RawBitmap.Channel] = []
            for i in 0..<Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_none_BE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_none_BE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(bigEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                        
                        destination.pointee = 1
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float64_alpha_none_LE: [RawBitmap.Channel] = []
            for i in 0..<Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_none_LE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_none_LE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(littleEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                        
                        destination.pointee = 1
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        case 32 * Model.numberOfComponents + 32:
            
            var float32_alpha_first_BE = [RawBitmap.Channel(index: Model.numberOfComponents, format: .unsigned, endianness: .big, bitRange: 0..<32)]
            for i in 1...Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_first_BE.append(RawBitmap.Channel(index: i - 1, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_first_BE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var _source = source + 1
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(bigEndian: _source.pointee.bitPattern))
                            destination += 1
                            _source += 1
                        }
                        
                        destination.pointee = Float(bitPattern: UInt32(bigEndian: source.pointee.bitPattern))
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float32_alpha_first_LE = [RawBitmap.Channel(index: Model.numberOfComponents, format: .unsigned, endianness: .little, bitRange: 0..<32)]
            for i in 1...Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_first_LE.append(RawBitmap.Channel(index: i - 1, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_first_LE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var _source = source + 1
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(littleEndian: _source.pointee.bitPattern))
                            destination += 1
                            _source += 1
                        }
                        
                        destination.pointee = Float(bitPattern: UInt32(littleEndian: source.pointee.bitPattern))
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float32_alpha_last_BE: [RawBitmap.Channel] = []
            for i in 0...Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_last_BE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_last_BE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0...Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(bigEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float32_alpha_last_LE: [RawBitmap.Channel] = []
            for i in 0...Model.numberOfComponents {
                let lowerBound = i * 32
                let upperBound = i * 32 + 32
                float32_alpha_last_LE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float32_alpha_last_LE {
                
                var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Float.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0...Model.numberOfComponents {
                            destination.pointee = Float(bitPattern: UInt32(littleEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        case 64 * Model.numberOfComponents + 64:
            
            var float64_alpha_first_BE = [RawBitmap.Channel(index: Model.numberOfComponents, format: .unsigned, endianness: .big, bitRange: 0..<64)]
            for i in 1...Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_first_BE.append(RawBitmap.Channel(index: i - 1, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_first_BE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var _source = source + 1
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(bigEndian: _source.pointee.bitPattern))
                            destination += 1
                            _source += 1
                        }
                        
                        destination.pointee = Double(bitPattern: UInt64(bigEndian: source.pointee.bitPattern))
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float64_alpha_first_LE = [RawBitmap.Channel(index: Model.numberOfComponents, format: .unsigned, endianness: .little, bitRange: 0..<64)]
            for i in 1...Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_first_LE.append(RawBitmap.Channel(index: i - 1, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_first_LE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var _source = source + 1
                        
                        for _ in 0..<Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(littleEndian: _source.pointee.bitPattern))
                            destination += 1
                            _source += 1
                        }
                        
                        destination.pointee = Double(bitPattern: UInt64(littleEndian: source.pointee.bitPattern))
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float64_alpha_last_BE: [RawBitmap.Channel] = []
            for i in 0...Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_last_BE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .big, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_last_BE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0...Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(bigEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            var float64_alpha_last_LE: [RawBitmap.Channel] = []
            for i in 0...Model.numberOfComponents {
                let lowerBound = i * 64
                let upperBound = i * 64 + 64
                float64_alpha_last_LE.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .little, bitRange: lowerBound..<upperBound))
            }
            
            if channels == float64_alpha_last_LE {
                
                var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                    image._fast_decode(bitmap, true, Double.self) { (destination, source) in
                        
                        var destination = destination
                        var source = source
                        
                        for _ in 0...Model.numberOfComponents {
                            destination.pointee = Double(bitPattern: UInt64(littleEndian: source.pointee.bitPattern))
                            destination += 1
                            source += 1
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        default: break
        }
        
        return nil
    }
}
