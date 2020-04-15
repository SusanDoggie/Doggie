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
        
        var _data = data
        guard let marker = try? _data.decode(JPEGMarker.self), marker == .SOI else { return nil }
        
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
        case 0: return Resolution(horizontal: Double(x_density), vertical: Double(y_density), unit: .point)
        case 1: return Resolution(horizontal: Double(x_density), vertical: Double(y_density), unit: .inch)
        case 2: return Resolution(horizontal: Double(x_density), vertical: Double(y_density), unit: .centimeter)
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
            
            image.withUnsafeMutableBufferPointer {
                
                guard var destination = $0.baseAddress else { return }
                
                buffer.withUnsafeBufferPointer {
                    
                    guard var source = $0.baseAddress else { return }
                    
                    for _ in 0..<$0.count {
                        
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

struct JPEGMarker: RawRepresentable, Hashable, Comparable, ExpressibleByIntegerLiteral {
    
    var rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

extension JPEGMarker {
    
    static func < (lhs: JPEGMarker, rhs: JPEGMarker) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension JPEGMarker {
    
    static let SOF0: JPEGMarker     = 0xC0
    static let SOF1: JPEGMarker     = 0xC1
    static let SOF2: JPEGMarker     = 0xC2
    static let SOF3: JPEGMarker     = 0xC3
    static let SOF5: JPEGMarker     = 0xC5
    static let SOF6: JPEGMarker     = 0xC6
    static let SOF7: JPEGMarker     = 0xC7
    static let SOF9: JPEGMarker     = 0xC9
    static let SOF10: JPEGMarker    = 0xCA
    static let SOF11: JPEGMarker    = 0xCB
    static let SOF13: JPEGMarker    = 0xCD
    static let SOF14: JPEGMarker    = 0xCE
    static let SOF15: JPEGMarker    = 0xCF
    static let DHT: JPEGMarker      = 0xC4
    static let DAC: JPEGMarker      = 0xCC
    static let RST0: JPEGMarker     = 0xD0
    static let RST1: JPEGMarker     = 0xD1
    static let RST2: JPEGMarker     = 0xD2
    static let RST3: JPEGMarker     = 0xD3
    static let RST4: JPEGMarker     = 0xD4
    static let RST5: JPEGMarker     = 0xD5
    static let RST6: JPEGMarker     = 0xD6
    static let RST7: JPEGMarker     = 0xD7
    static let SOI: JPEGMarker      = 0xD8
    static let EOI: JPEGMarker      = 0xD9
    static let SOS: JPEGMarker      = 0xDA
    static let DQT: JPEGMarker      = 0xDB
    static let DNL: JPEGMarker      = 0xDC
    static let DRI: JPEGMarker      = 0xDD
    static let DHP: JPEGMarker      = 0xDE
    static let EXP: JPEGMarker      = 0xDF
    static let APP0: JPEGMarker     = 0xE0
    static let APP1: JPEGMarker     = 0xE1
    static let APP2: JPEGMarker     = 0xE2
    static let APP3: JPEGMarker     = 0xE3
    static let APP4: JPEGMarker     = 0xE4
    static let APP5: JPEGMarker     = 0xE5
    static let APP6: JPEGMarker     = 0xE6
    static let APP7: JPEGMarker     = 0xE7
    static let APP8: JPEGMarker     = 0xE8
    static let APP9: JPEGMarker     = 0xE9
    static let APP10: JPEGMarker    = 0xEA
    static let APP11: JPEGMarker    = 0xEB
    static let APP12: JPEGMarker    = 0xEC
    static let APP13: JPEGMarker    = 0xED
    static let APP14: JPEGMarker    = 0xEE
    static let APP15: JPEGMarker    = 0xEF
    static let JPG0: JPEGMarker     = 0xF0
    static let JPG1: JPEGMarker     = 0xF1
    static let JPG2: JPEGMarker     = 0xF2
    static let JPG3: JPEGMarker     = 0xF3
    static let JPG4: JPEGMarker     = 0xF4
    static let JPG5: JPEGMarker     = 0xF5
    static let JPG6: JPEGMarker     = 0xF6
    static let JPG7: JPEGMarker     = 0xF7
    static let JPG8: JPEGMarker     = 0xF8
    static let JPG9: JPEGMarker     = 0xF9
    static let JPG10: JPEGMarker    = 0xFA
    static let JPG11: JPEGMarker    = 0xFB
    static let JPG12: JPEGMarker    = 0xFC
    static let JPG13: JPEGMarker    = 0xFD
    static let COM: JPEGMarker      = 0xFE
    
}

extension JPEGMarker: ByteCodable {
    
    init(from data: inout Data) throws {
        var byte = try data.decode(UInt8.self)
        guard byte == 0xFF else { throw ImageRep.Error.InvalidFormat("Invalid marker.") }
        while byte == 0xFF { byte = try data.decode(UInt8.self) }
        self.init(rawValue: byte)
    }
    
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(0xFF as UInt8)
        stream.encode(rawValue)
    }
}

extension JPEGMarker: CustomStringConvertible {
    
    var description: String {
        return "0x\(String(rawValue, radix: 16).uppercased())"
    }
}
