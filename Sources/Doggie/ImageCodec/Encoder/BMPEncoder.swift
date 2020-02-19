//
//  BMPEncoder.swift
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

struct BMPEncoder: ImageRepEncoder {
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let image = Image<ARGB32ColorPixel>(image: image, colorSpace: .sRGB)
        
        let resolution = image.resolution.convert(to: .meter)
        
        if image.isOpaque {
            
            let _width = image.width * 3
            let row = _width.align(4)
            let padding = row - _width
            
            let pixel_size = row * image.height
            
            var buffer = MappedBuffer<UInt8>(capacity: 54 + pixel_size, fileBacked: true)
            
            buffer.encode("BM" as Signature<BEUInt16>)
            buffer.encode(LEUInt32(54 + pixel_size))
            buffer.encode(0 as LEUInt16)
            buffer.encode(0 as LEUInt16)
            buffer.encode(54 as LEUInt32)
            
            buffer.encode(40 as LEUInt32)
            
            buffer.encode(LEInt32(image.width))
            buffer.encode(LEInt32(-image.height))
            buffer.encode(1 as LEUInt16)
            buffer.encode(24 as LEUInt16)
            
            buffer.encode(BITMAPINFOHEADER.CompressionType.BI_RGB)
            buffer.encode(LEUInt32(pixel_size))
            buffer.encode(LEUInt32(round(resolution.horizontal).clamped(to: 0...4294967295)))
            buffer.encode(LEUInt32(round(resolution.vertical).clamped(to: 0...4294967295)))
            buffer.encode(0 as LEUInt32)
            buffer.encode(0 as LEUInt32)
            
            var counter = image.width
            
            for pixel in image.pixels {
                buffer.encode(pixel.b)
                buffer.encode(pixel.g)
                buffer.encode(pixel.r)
                counter -= 1
                if counter == 0 {
                    buffer.append(contentsOf: repeatElement(0, count: padding))
                    counter = image.width
                }
            }
            
            return buffer.data
            
        } else {
            
            let pixel_size = image.pixels.count << 2
            
            var buffer = MappedBuffer<UInt8>(capacity: 70 + pixel_size, fileBacked: true)
            
            buffer.encode("BM" as Signature<BEUInt16>)
            buffer.encode(LEUInt32(70 + pixel_size))
            buffer.encode(0 as LEUInt16)
            buffer.encode(0 as LEUInt16)
            buffer.encode(70 as LEUInt32)
            
            buffer.encode(56 as LEUInt32)
            
            buffer.encode(LEInt32(image.width))
            buffer.encode(LEInt32(-image.height))
            buffer.encode(1 as LEUInt16)
            buffer.encode(32 as LEUInt16)
            
            buffer.encode(BITMAPINFOHEADER.CompressionType.BI_BITFIELDS)
            buffer.encode(LEUInt32(pixel_size))
            buffer.encode(LEUInt32(round(resolution.horizontal).clamped(to: 0...4294967295)))
            buffer.encode(LEUInt32(round(resolution.vertical).clamped(to: 0...4294967295)))
            buffer.encode(0 as LEUInt32)
            buffer.encode(0 as LEUInt32)
            
            buffer.encode(0x00FF0000 as LEUInt32)
            buffer.encode(0x0000FF00 as LEUInt32)
            buffer.encode(0x000000FF as LEUInt32)
            buffer.encode(0xFF000000 as LEUInt32)
            
            for pixel in image.pixels {
                buffer.encode(pixel.b)
                buffer.encode(pixel.g)
                buffer.encode(pixel.r)
                buffer.encode(pixel.a)
            }
            
            return buffer.data
        }
    }
    
}
