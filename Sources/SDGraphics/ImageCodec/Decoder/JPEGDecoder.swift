//
//  JPEGDecoder.swift
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

struct JPEGDecoder: ImageRepDecoder {
    
    static var mediaType: MediaType {
        return .jpeg
    }
    
    let width: Int
    let height: Int
    
    let format: J_COLOR_SPACE
    
    let bytesPerRow: Int
    
    let density_unit: UINT8
    let x_density: UINT16
    let y_density: UINT16
    
    let iccData: Data?
    
    let buffer: Data
    
    init?(data: Data) {
        guard let decoder = data.withUnsafeBytes(JPEGDecoder.init) else { return nil }
        self = decoder
    }
    
    private init?(bytes: UnsafeRawBufferPointer) {
        
        var cinfo = jpeg_decompress_struct()
        var jerr = jpeg_error_mgr()
        
        guard let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        
        cinfo.err = jpeg_std_error(&jerr)
        jerr.error_exit = { cinfo in cinfo?.pointee.err.pointee.output_message(cinfo) }
        
        jpeg_CreateDecompress(&cinfo, JPEG_LIB_VERSION, MemoryLayout<jpeg_decompress_struct>.size)
        defer { jpeg_destroy_decompress(&cinfo) }
        
        jpeg_mem_src(&cinfo, UnsafeMutablePointer(mutating: baseAddress), UInt(bytes.count))
        
        jpeg_save_markers(&cinfo, JPEG_APP0 + 2, 0xFFFF)
        
        guard _jpeg_read_header(&cinfo, 1) else { return nil }
        
        switch cinfo.out_color_space {
            
        case JCS_GRAYSCALE: break
        case JCS_EXT_RGBA: break
        case JCS_EXT_BGRA: break
        case JCS_EXT_ARGB: break
        case JCS_EXT_ABGR: break
            
        case JCS_EXT_RGBX:
            
            cinfo.out_color_space = JCS_EXT_RGBA
            cinfo.output_components = 4
            
        case JCS_EXT_BGRX:
            
            cinfo.out_color_space = JCS_EXT_BGRA
            cinfo.output_components = 4
            
        case JCS_EXT_XRGB:
            
            cinfo.out_color_space = JCS_EXT_ARGB
            cinfo.output_components = 4
            
        case JCS_EXT_XBGR:
            
            cinfo.out_color_space = JCS_EXT_ABGR
            cinfo.output_components = 4
            
        case JCS_RGB, JCS_EXT_BGR:
            
            cinfo.out_color_space = JCS_EXT_RGBA
            cinfo.output_components = 4
            
        default: return nil
        }
        
        guard _jpeg_start_decompress(&cinfo) else { return nil }
        defer { jpeg_finish_decompress(&cinfo) }
        
        self.width = Int(cinfo.output_width)
        self.height = Int(cinfo.output_height)
        self.format = cinfo.out_color_space
        
        self.density_unit = cinfo.density_unit
        self.x_density = cinfo.X_density
        self.y_density = cinfo.Y_density
        
        let bytesPerRow = width * Int(cinfo.output_components)
        self.bytesPerRow = bytesPerRow
        
        var icc_bytes: UnsafeMutablePointer<UInt8>?
        var icc_bytes_len: UInt32 = 0
        
        jpeg_read_icc_profile(&cinfo, &icc_bytes, &icc_bytes_len)
        
        if let icc_bytes = icc_bytes {
            self.iccData = Data(bytesNoCopy: icc_bytes, count: Int(icc_bytes_len), deallocator: .free)
        } else {
            self.iccData = nil
        }
        
        var buffer = Data(count: bytesPerRow * height)
        
        buffer.withUnsafeMutableBytes {
            
            var buffer = $0.baseAddress!.assumingMemoryBound(to: UInt8.self)
            
            while cinfo.output_scanline < cinfo.output_height {
                
                var _buffer: UnsafeMutablePointer<UInt8>? = buffer
                guard _jpeg_read_scanlines(&cinfo, &_buffer, 1) else { return }
                
                buffer += bytesPerRow
            }
        }
        
        self.buffer = buffer
    }
    
    var resolution: Resolution {
        switch density_unit {
        case 0: return Resolution(horizontal: Double(x_density), vertical: y_density, unit: .point)
        case 1: return Resolution(horizontal: Double(x_density), vertical: y_density, unit: .inch)
        case 2: return Resolution(horizontal: Double(x_density), vertical: y_density, unit: .centimeter)
        default: return .default
        }
    }
    
    var colorSpace: AnyColorSpace {
        
        switch format {
            
        case JCS_GRAYSCALE:
            
            var colorSpace: ColorSpace = .genericGamma22Gray
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<GrayColorModel> ?? .genericGamma22Gray
            }
            
            return AnyColorSpace(colorSpace)
            
        case JCS_EXT_RGBA, JCS_EXT_BGRA, JCS_EXT_ARGB, JCS_EXT_ABGR:
            
            var colorSpace: ColorSpace = .sRGB
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            }
            
            return AnyColorSpace(colorSpace)
            
        default: fatalError()
        }
    }
    
    func image(fileBacked: Bool) -> AnyImage {
        
        switch format {
            
        case JCS_GRAYSCALE:
            
            var colorSpace: ColorSpace = .genericGamma22Gray
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<GrayColorModel> ?? .genericGamma22Gray
            }
            
            var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            let count = width * height
            
            image.withUnsafeMutableBufferPointer {
                
                guard var destination = $0.baseAddress else { return }
                
                buffer.withUnsafeBufferPointer {
                    
                    guard var source = $0.baseAddress else { return }
                    
                    for _ in 0..<count {
                        
                        destination.pointee.w = source.pointee
                        destination.pointee.a = .max
                        
                        destination += 1
                        source += 1
                    }
                }
            }
            
            return AnyImage(image)
            
        case JCS_EXT_RGBA:
            
            var colorSpace: ColorSpace = .sRGB
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            }
            
            var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            image.withUnsafeMutableBytes { destination in
                
                buffer.withUnsafeBytes { source in
                    
                    destination.copyMemory(from: source)
                }
            }
            
            return AnyImage(image)
            
        case JCS_EXT_BGRA:
            
            var colorSpace: ColorSpace = .sRGB
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            }
            
            var image = Image<BGRA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            image.withUnsafeMutableBytes { destination in
                
                buffer.withUnsafeBytes { source in
                    
                    destination.copyMemory(from: source)
                }
            }
            
            return AnyImage(image)
            
        case JCS_EXT_ARGB:
            
            var colorSpace: ColorSpace = .sRGB
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            }
            
            var image = Image<ARGB32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            image.withUnsafeMutableBytes { destination in
                
                buffer.withUnsafeBytes { source in
                    
                    destination.copyMemory(from: source)
                }
            }
            
            return AnyImage(image)
            
        case JCS_EXT_ABGR:
            
            var colorSpace: ColorSpace = .sRGB
            
            if let iccData = iccData, let _colorSpace = try? AnyColorSpace(iccData: iccData) {
                colorSpace = _colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            }
            
            var image = Image<ABGR32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
            
            image.withUnsafeMutableBytes { destination in
                
                buffer.withUnsafeBytes { source in
                    
                    destination.copyMemory(from: source)
                }
            }
            
            return AnyImage(image)
            
        default: fatalError()
        }
    }
}
