//
//  SlowDecode.swift
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

extension Image {
    
    @inlinable
    @inline(__always)
    static func _denormalized<T: BinaryFloatingPoint>(_ channel_index: Int, _ value: T) -> T {
        guard channel_index < Pixel.Model.numberOfComponents else { return value }
        let range = Pixel.Model.rangeOfComponent(channel_index)
        return value * T(range.upperBound - range.lowerBound) + T(range.lowerBound)
    }
}

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func _create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> AnyImageBaseProtocol {
        
        if let image = _fast_create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked) {
            return image
        }
        
        let numberOfComponents = self.numberOfComponents
        let is_opaque = !bitmaps.contains { $0.channels.contains { $0.index == numberOfComponents } }
        
        let premultiplied = premultiplied && !is_opaque
        
        precondition(bitmaps.allSatisfy { (($0.bitsPerPixel * width).align(8) >> 3) <= $0.bytesPerRow }, "Invalid bytesPerRow.")
        precondition(bitmaps.allSatisfy { $0.channels.allSatisfy { 0...numberOfComponents ~= $0.index } }, "Invalid channel index.")
        
        switch self {
        case let colorSpace as ColorSpace<GrayColorModel>:
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 8 && $0.format == .unsigned } }) {
                
                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt8.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {
                
                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt16.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        case let colorSpace as ColorSpace<RGBColorModel>:
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 8 && $0.format == .unsigned } }) {
                
                var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt8.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {
                
                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt16.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        default: break
        }
        
        if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 23 || ($0.bitRange.count == 32 && $0.format == .float) } }) {
            
            var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
            
            for bitmap in bitmaps {
                for (channel_idx, channel) in bitmap.channels.enumerated() {
                    switch (bitmap.bitsPerPixel % 8, bitmap.endianness, channel.bitRange.lowerBound % 8, channel.bitRange.count, channel.format) {
                    case (0, .big, 0, 8, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt8.self, Float.self)
                    case (0, .big, 0, 8, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int8.self, Float.self)
                    case (0, .big, 0, 16, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt16.self, Float.self)
                    case (0, .big, 0, 16, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int16.self, Float.self)
                    case (0, .big, 0, 32, .float): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Float.self, Float.self)
                    default: image._decode_channel(bitmap, channel_idx, is_opaque, Float.self)
                    }
                }
            }
            
            if premultiplied {
                image._decode_premultiplied()
            }
            
            return image
        }
        
        var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
        
        for bitmap in bitmaps {
            for (channel_idx, channel) in bitmap.channels.enumerated() {
                switch (bitmap.bitsPerPixel % 8, bitmap.endianness, channel.bitRange.lowerBound % 8, channel.bitRange.count, channel.format) {
                case (0, .big, 0, 8, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt8.self, Double.self)
                case (0, .big, 0, 8, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int8.self, Double.self)
                case (0, .big, 0, 16, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt16.self, Double.self)
                case (0, .big, 0, 16, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int16.self, Double.self)
                case (0, .big, 0, 32, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt32.self, Double.self)
                case (0, .big, 0, 32, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int32.self, Double.self)
                case (0, .big, 0, 32, .float): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Float.self, Double.self)
                case (0, .big, 0, 64, .unsigned): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, UInt64.self, Double.self)
                case (0, .big, 0, 64, .signed): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Int64.self, Double.self)
                case (0, .big, 0, 64, .float): image._decode_aligned_channel(bitmap, channel_idx, is_opaque, Double.self, Double.self)
                default:
                    if channel.bitRange.count <= 64 {
                        image._decode_channel(bitmap, channel_idx, is_opaque, Double.self)
                    } else {
                        image._decode_channel_to_double(bitmap, channel_idx, is_opaque)
                    }
                }
            }
        }
        
        if premultiplied {
            image._decode_premultiplied()
        }
        
        return image
    }
}
