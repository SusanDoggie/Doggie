//
//  BMPEncoder.swift
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

struct BMPEncoder : ImageRepEncoder {
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        
        let image = Image<ARGB32ColorPixel>(image: image) ?? Image<ARGB32ColorPixel>(image: image, colorSpace: .sRGB)
        
        var pixels = [UInt8]()
        pixels.reserveCapacity(image.width * image.height * 4)
        
        for pixel in image.pixels {
            pixels.append(pixel.b)
            pixels.append(pixel.g)
            pixels.append(pixel.r)
            pixels.append(pixel.a)
        }
        
        guard let iccData = image.colorSpace.iccData else { return nil }
        
        var header = Data(capacity: 140 + pixels.count + iccData.count)
        
        header.encode("BM" as BMPHeader.Signature)
        header.encode(LEUInt32(140 + pixels.count + iccData.count))
        header.encode(0 as LEUInt16)
        header.encode(0 as LEUInt16)
        header.encode(140 as LEUInt32)
        
        header.encode(124 as LEUInt32)
        
        header.encode(LEInt32(image.width))
        header.encode(LEInt32(-image.height))
        header.encode(1 as LEUInt16)
        header.encode(32 as LEUInt16)
        
        header.encode(BITMAPINFOHEADER.CompressionType.BI_BITFIELDS)
        header.encode(LEUInt32(pixels.count))
        header.encode(LEUInt32(round(72.0 / 0.0254)))
        header.encode(LEUInt32(round(72.0 / 0.0254)))
        header.encode(0 as LEUInt32)
        header.encode(0 as LEUInt32)
        
        header.encode(0x00FF0000 as LEUInt32)
        header.encode(0x0000FF00 as LEUInt32)
        header.encode(0x000000FF as LEUInt32)
        header.encode(0xFF000000 as LEUInt32)
        
        header.encode(BITMAPINFOHEADER.ColorSpaceType.LCS_PROFILE_EMBEDDED)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.FXPT2DOT30)
        header.encode(0 as BITMAPINFOHEADER.U16Fixed16Number)
        header.encode(0 as BITMAPINFOHEADER.U16Fixed16Number)
        header.encode(0 as BITMAPINFOHEADER.U16Fixed16Number)
        
        header.encode(BITMAPINFOHEADER.IntentType.LCS_GM_IMAGES)
        header.encode(LEUInt32(126 + pixels.count))
        header.encode(LEUInt32(iccData.count))
        header.encode(0 as LEUInt32)
        
        header.count += 2
        
        return header + pixels + iccData
    }
    
}
