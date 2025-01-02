//
//  JPEGEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

struct JPEGEncoder: ImageRepEncoder {
    
    let width: Int
    let height: Int
    
    let bytesPerRow: Int
    
    let format: J_COLOR_SPACE
    let components: Int32
    
    let pixels: Data
    
    let iccData: Data
    
    var quality: Int = 75
    
    var density_unit: UINT8 = 0
    var x_density: UINT16 = 1
    var y_density: UINT16 = 1
    
}

extension JPEGEncoder {
    
    static func _encodeGray<Pixel: _GrayColorPixel>(_ pixel: Pixel) -> UInt8 where Pixel.Component == UInt8 {
        
        let w = UInt16(pixel.w)
        let a = UInt16(pixel.a)
        
        return UInt8((a * w + 0xFF * (0xFF - a) + 0x7F) / 0xFF)
    }
    
    static func _encodeRGB<Pixel: _RGBColorPixel>(_ pixel: Pixel) -> Pixel where Pixel.Component == UInt8 {
        
        let r = UInt16(pixel.r)
        let g = UInt16(pixel.g)
        let b = UInt16(pixel.b)
        let a = UInt16(pixel.a)
        
        return Pixel(
            red: UInt8((a * r + 0xFF * (0xFF - a) + 0x7F) / 0xFF),
            green: UInt8((a * g + 0xFF * (0xFF - a) + 0x7F) / 0xFF),
            blue: UInt8((a * b + 0xFF * (0xFF - a) + 0x7F) / 0xFF),
            opacity: pixel.a
        )
    }
}

extension JPEGEncoder {
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let pixels: Data
        let bytesPerRow: Int
        let format: J_COLOR_SPACE
        let components: Int32
        let iccData: Data
        
        switch image.base {
        case let image as Image<Gray16ColorPixel>:
            
            guard let _iccData = image.colorSpace.iccData else { return encode(image: image.convert(to: .genericGamma22Gray), properties: properties) }
            
            pixels = image.pixels.map(JPEGEncoder._encodeGray).data
            bytesPerRow = image.width
            format = JCS_GRAYSCALE
            components = 1
            iccData = _iccData
            
        case let image as Image<ARGB32ColorPixel>:
            
            guard let _iccData = image.colorSpace.iccData else { return encode(image: image.convert(to: .sRGB), properties: properties) }
            
            pixels = image.pixels.map(JPEGEncoder._encodeRGB).data
            bytesPerRow = 4 * image.width
            format = JCS_EXT_XRGB
            components = 4
            iccData = _iccData
            
        case let image as Image<RGBA32ColorPixel>:
            
            guard let _iccData = image.colorSpace.iccData else { return encode(image: image.convert(to: .sRGB), properties: properties) }
            
            pixels = image.pixels.map(JPEGEncoder._encodeRGB).data
            bytesPerRow = 4 * image.width
            format = JCS_EXT_RGBX
            components = 4
            iccData = _iccData
            
        case let image as Image<ABGR32ColorPixel>:
            
            guard let _iccData = image.colorSpace.iccData else { return encode(image: image.convert(to: .sRGB), properties: properties) }
            
            pixels = image.pixels.map(JPEGEncoder._encodeRGB).data
            bytesPerRow = 4 * image.width
            format = JCS_EXT_XBGR
            components = 4
            iccData = _iccData
            
        case let image as Image<BGRA32ColorPixel>:
            
            guard let _iccData = image.colorSpace.iccData else { return encode(image: image.convert(to: .sRGB), properties: properties) }
            
            pixels = image.pixels.map(JPEGEncoder._encodeRGB).data
            bytesPerRow = 4 * image.width
            format = JCS_EXT_BGRX
            components = 4
            iccData = _iccData
            
        default:
            
            if image.colorSpace.base is ColorSpace<GrayColorModel> {
                
                let _image = Image<Gray16ColorPixel>(image) ?? image.convert(to: .genericGamma22Gray)
                
                guard let _iccData = _image.colorSpace.iccData else { return encode(image: _image.convert(to: .genericGamma22Gray), properties: properties) }
                
                pixels = _image.pixels.map(JPEGEncoder._encodeGray).data
                bytesPerRow = _image.width
                format = JCS_GRAYSCALE
                components = 1
                iccData = _iccData
                
            } else {
                
                let _image = Image<RGBA32ColorPixel>(image) ?? image.convert(to: .sRGB)
                
                guard let _iccData = _image.colorSpace.iccData else { return encode(image: _image.convert(to: .sRGB), properties: properties) }
                
                pixels = _image.pixels.map(JPEGEncoder._encodeRGB).data
                bytesPerRow = 4 * _image.width
                format = JCS_EXT_RGBX
                components = 4
                iccData = _iccData
            }
        }
        
        var encoder = JPEGEncoder(width: image.width, height: image.height, bytesPerRow: bytesPerRow, format: format, components: components, pixels: pixels, iccData: iccData)
        
        if let _quality = properties[.compressionQuality] as? Double {
            encoder.quality = Int(_quality * 100).clamped(to: 0...100)
        }
        
        switch image.resolution.unit {
        case .inch:
            
            encoder.density_unit = 1
            encoder.x_density = UInt16(image.resolution.horizontal)
            encoder.y_density = UInt16(image.resolution.vertical)
            
        case .centimeter:
            
            encoder.density_unit = 2
            encoder.x_density = UInt16(image.resolution.horizontal)
            encoder.y_density = UInt16(image.resolution.vertical)
            
        default:
            
            let resolution = image.resolution.convert(to: .inch)
            
            encoder.density_unit = 1
            encoder.x_density = UInt16(resolution.horizontal)
            encoder.y_density = UInt16(resolution.vertical)
        }
        
        return encoder.encode()
    }
    
}

extension JPEGEncoder {
    
    func encode() -> Data? {
        
        pixels.withUnsafeBytes {
            
            guard let pixels = $0.baseAddress else { return nil }
            
            var cinfo = jpeg_compress_struct()
            var jerr = jpeg_error_mgr()
            
            cinfo.err = jpeg_std_error(&jerr)
            
            jpeg_CreateCompress(&cinfo, JPEG_LIB_VERSION, MemoryLayout<jpeg_compress_struct>.size)
            defer { jpeg_destroy_compress(&cinfo) }
            
            var outbuffer: UnsafeMutablePointer<UInt8>?
            var outsize: UInt = 0
            
            jpeg_mem_dest(&cinfo, &outbuffer, &outsize)
            
            cinfo.image_width = JDIMENSION(width)
            cinfo.image_height = JDIMENSION(height)
            cinfo.input_components = components
            cinfo.in_color_space = format
            
            cinfo.density_unit = density_unit
            cinfo.X_density = x_density
            cinfo.Y_density = y_density
            
            jpeg_set_defaults(&cinfo)
            jpeg_set_quality(&cinfo, Int32(quality), 1)
            
            jpeg_start_compress(&cinfo, 1)
            
            iccData.withUnsafeBytes { data in jpeg_write_icc_profile(&cinfo, data.baseAddress?.assumingMemoryBound(to: JOCTET.self), UInt32(data.count)) }
            
            var scanline = pixels.assumingMemoryBound(to: UInt8.self)
            
            while cinfo.next_scanline < cinfo.image_height {
                
                var _scanline: UnsafeMutablePointer? = UnsafeMutablePointer(mutating: scanline)
                jpeg_write_scanlines(&cinfo, &_scanline, 1)
                
                scanline += bytesPerRow
            }
            
            jpeg_finish_compress(&cinfo)
            
            return outbuffer.map { Data(bytes: $0, count: Int(outsize)) }
        }
    }
}

