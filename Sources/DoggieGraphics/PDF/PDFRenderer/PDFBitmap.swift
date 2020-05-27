//
//  PDFBitmap.swift
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

struct PDFBitmap {
    
    let width: Int
    let height: Int
    let bitsPerComponent: Int
    
    let colorSpace: PDFColorSpace
    
    let decodeParms: [PDFName: PDFObject]
    
    let data: Data
    
    init?(width: Int,
          height: Int,
          bitsPerComponent: Int,
          colorSpace: PDFColorSpace,
          decodeParms: [PDFName: PDFObject],
          data: Data) {
        
        guard bitsPerComponent % 8 == 0 else { return nil }
        
        self.width = width
        self.height = height
        self.bitsPerComponent = bitsPerComponent
        self.colorSpace = colorSpace
        self.decodeParms = decodeParms
        self.data = data
    }
    
}

extension PDFBitmap {
    
    var predictor: Int? {
        return decodeParms["Predictor"]?.intValue
    }
    
    var bitsPerPixel: Int {
        return bitsPerComponent * colorSpace.numberOfComponents
    }
    
    var bytesPerPixel: Int {
        return bitsPerPixel >> 3
    }
    
    var bytesPerRow: Int {
        return bytesPerPixel * width
    }
    
    var channels: [RawBitmap.Channel] {
        
        var channels: [RawBitmap.Channel] = []
        
        for i in 0..<colorSpace.numberOfComponents {
            let start = bitsPerComponent * i
            let end = bitsPerComponent * i + bitsPerComponent
            channels.append(RawBitmap.Channel(index: i, format: .unsigned, endianness: .big, bitRange: start..<end))
        }
        
        return channels
    }
    
    func maskBitmap(_ index: Int) -> RawBitmap {
        
        let channels: [RawBitmap.Channel] = [
            RawBitmap.Channel(index: index, format: .unsigned, endianness: .big, bitRange: 0..<bitsPerComponent)
        ]
        
        return RawBitmap(bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, tiff_predictor: predictor ?? 1, channels: channels, data: data)
    }
    
    var rawBitmap: RawBitmap {
        return RawBitmap(bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, tiff_predictor: predictor ?? 1, channels: channels, data: data)
    }
}

extension PDFBitmap {
    
    func create_image(mask: PDFBitmap?, device colorSpace: AnyColorSpace?) -> AnyImage? {
        
        switch (self.colorSpace, colorSpace?.base) {
            
        case (.deviceGray, let colorSpace as ColorSpace<GrayColorModel>):
            
            var bitmaps = [self.rawBitmap]
            
            if let mask = mask, mask.width == self.width && mask.height == self.height {
                bitmaps.append(mask.maskBitmap(self.colorSpace.numberOfComponents))
            }
            
            return AnyImage(width: self.width, height: self.height, colorSpace: AnyColorSpace(colorSpace), bitmaps: bitmaps, premultiplied: false)
            
        case (.deviceRGB, let colorSpace as ColorSpace<RGBColorModel>):
            
            var bitmaps = [self.rawBitmap]
            
            if let mask = mask, mask.width == self.width && mask.height == self.height {
                bitmaps.append(mask.maskBitmap(self.colorSpace.numberOfComponents))
            }
            
            return AnyImage(width: self.width, height: self.height, colorSpace: AnyColorSpace(colorSpace), bitmaps: bitmaps, premultiplied: false)
            
        case (.deviceCMYK, let colorSpace as ColorSpace<CMYKColorModel>):
            
            var bitmaps = [self.rawBitmap]
            
            if let mask = mask, mask.width == self.width && mask.height == self.height {
                bitmaps.append(mask.maskBitmap(self.colorSpace.numberOfComponents))
            }
            
            return AnyImage(width: self.width, height: self.height, colorSpace: AnyColorSpace(colorSpace), bitmaps: bitmaps, premultiplied: false)
            
        case (let .indexed(base, table), _):
            
            guard self.bitsPerComponent == 8 else { return nil }
            
            guard let _color = PDFBitmap(width: self.width, height: self.height, bitsPerComponent: 8, colorSpace: base, decodeParms: self.decodeParms, data: Data(self.data.flatMap { table[Int($0)] })) else { return nil }
            
            return _color.create_image(mask: mask, device: colorSpace)
            
        case (let .colorSpace(colorSpace), _):
            
            var bitmaps = [self.rawBitmap]
            
            if let mask = mask, mask.width == self.width && mask.height == self.height {
                bitmaps.append(mask.maskBitmap(self.colorSpace.numberOfComponents))
            }
            
            return AnyImage(width: self.width, height: self.height, colorSpace: colorSpace, bitmaps: bitmaps, premultiplied: false)
            
        default: return nil
        }
    }
}
