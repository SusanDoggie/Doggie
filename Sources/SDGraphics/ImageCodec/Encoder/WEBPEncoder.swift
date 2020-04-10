//
//  WEBPEncoder.swift
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

struct WEBPEncoder: ImageRepEncoder {
    
    let width: Int
    let height: Int
    
    let bytesPerRow: Int
    
    var format: PixelFormat
    
    let pixels: Data
    
    var quality: Double?
    
    var iccData: Data?
}

extension WEBPEncoder {
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let pixels: Data
        let bytesPerRow: Int
        let format: PixelFormat
        
        let iccData: Data?
        
        switch image.base {
        case let image as Image<RGBA32ColorPixel>:
            
            pixels = image.pixels.data
            bytesPerRow = 4 * image.width
            format = image.isOpaque ? .RGBX : .RGBA
            
            iccData = image.colorSpace.iccData
            
        case let image as Image<BGRA32ColorPixel>:
            
            pixels = image.pixels.data
            bytesPerRow = 4 * image.width
            format = image.isOpaque ? .BGRX : .BGRA
            
            iccData = image.colorSpace.iccData
            
        default:
            
            if let image = Image<RGBA32ColorPixel>(image) {
                
                pixels = image.pixels.data
                bytesPerRow = 4 * image.width
                format = image.isOpaque ? .RGBX : .RGBA
                
                iccData = image.colorSpace.iccData
                
            } else {
                
                let image = Image<RGBA32ColorPixel>(image: image, colorSpace: .sRGB)
                
                pixels = image.pixels.data
                bytesPerRow = 4 * image.width
                format = image.isOpaque ? .RGBX : .RGBA
                
                iccData = image.colorSpace.iccData
            }
        }
        
        var encoder = WEBPEncoder(width: image.width, height: image.height, bytesPerRow: bytesPerRow, format: format, pixels: pixels)
        encoder.iccData = iccData
        
        if let quality = properties[.compressionQuality] as? Double {
            encoder.quality = 100 * quality
        }
        
        return encoder.encode()
    }
}

#if canImport(CoreGraphics)

extension WEBPEncoder {
    
    static func encode(image: CGImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        var image = image
        let format: PixelFormat
        
        switch (image.bitmapInfo.intersection(.byteOrderMask), image.alphaInfo) {
        case (.byteOrder32Big, .last): format = .RGBA
        case (.byteOrder32Little, .first): format = .BGRA
        case (.byteOrder32Big, .noneSkipLast): format = .RGBX
        case (.byteOrder32Little, .noneSkipFirst): format = .BGRX
        default:
            
            guard let colorSpace = image.colorSpace else { return nil }
            
            if image.alphaInfo == .none || image.alphaInfo == .noneSkipLast || image.alphaInfo == .noneSkipFirst {
                
                let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue)
                
                guard let _image = image.createCGImage(
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    bytesPerRow: 4 * image.width,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo,
                    decode: image.decode,
                    shouldInterpolate: image.shouldInterpolate,
                    intent: image.renderingIntent
                    ) else { return nil }
                
                image = _image
                
                format = .RGBX
                
            } else {
                
                let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.last.rawValue)
                
                guard let _image = image.createCGImage(
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    bytesPerRow: 4 * image.width,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo,
                    decode: image.decode,
                    shouldInterpolate: image.shouldInterpolate,
                    intent: image.renderingIntent
                    ) else { return nil }
                
                image = _image
                
                format = .RGBA
            }
        }
        
        let bytesPerRow = image.bytesPerRow
        
        let iccData: Data?
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            iccData = image.colorSpace?.copyICCData() as Data?
        } else {
            iccData = image.colorSpace?.iccData as Data?
        }
        
        guard let pixels = image.dataProvider?.data as Data? else { return nil }
        
        var encoder = WEBPEncoder(width: image.width, height: image.height, bytesPerRow: bytesPerRow, format: format, pixels: pixels)
        encoder.iccData = iccData
        
        if let quality = properties[.compressionQuality] as? Double {
            encoder.quality = 100 * quality
        }
        
        return encoder.encode()
    }
}

#endif

extension WEBPEncoder {
    
    enum PixelFormat: Int32 {
        
        case RGBA
        case BGRA
        case RGBX
        case BGRX
        case RGB
        case BGR
    }
    
    func encode() -> Data? {
        
        return pixels.withUnsafeBytes {
            
            guard let pixels = $0.baseAddress else { return nil }
            
            guard let mux = WebPMuxNew() else { return nil }
            defer { WebPMuxDelete(mux) }
            
            let importer: Importer
            
            switch format {
            case .RGBA: importer = WebPPictureImportRGBA
            case .BGRA: importer = WebPPictureImportBGRA
            case .RGBX: importer = WebPPictureImportRGBX
            case .BGRX: importer = WebPPictureImportBGRX
            case .RGB: importer = WebPPictureImportRGB
            case .BGR: importer = WebPPictureImportBGR
            }
            
            var output: UnsafeMutablePointer<UInt8>?
            let size = webp_encode(pixels, width, height, bytesPerRow, importer, quality ?? 100, quality == nil, &output)
            
            guard let _output = output, size != 0 else { return false }
            defer { WebPFree(_output) }
            
            var image = WebPData(bytes: output, size: size)
            guard WebPMuxSetImage(mux, &image, 1) == WEBP_MUX_OK else { return nil }
            
            
            if let iccData = iccData {
                
                let status: WebPMuxError = iccData.withUnsafeBytes { data in
                    var _data = WebPData(bytes: data.baseAddress?.assumingMemoryBound(to: UInt8.self), size: data.count)
                    return WebPMuxSetChunk(mux, "ICCP", &_data, 1)
                }
                
                guard status == WEBP_MUX_OK else { return nil }
            }
            
            var output = WebPData()
            guard WebPMuxAssemble(mux, &output) == WEBP_MUX_OK else { return nil }
            defer { WebPDataClear(&output) }
            
            return Data(bytes: output.bytes, count: output.size)
        }
    }
}

private typealias Importer = (UnsafeMutablePointer<WebPPicture>?, UnsafePointer<UInt8>?, Int32) -> Int32

private func webp_encode(_ rgba: UnsafeRawPointer, _ width: Int, _ height: Int, _ stride: Int,
                         _ importer: Importer, _ quality: Double, _ lossless: Bool,
                         _ output: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>) -> Int {
    
    var wrt = WebPMemoryWriter()
    
    return withUnsafeMutablePointer(to: &wrt) { wrt in
        
        var pic = WebPPicture()
        var config = WebPConfig()
        
        if WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, Float(quality)) == 0 || WebPPictureInit(&pic) == 0 {
            return 0  // shouldn't happen, except if system installation is broken
        }
        
        config.lossless = lossless ? 1 : 0
        pic.use_argb = lossless ? 1 : 0
        pic.width = Int32(width)
        pic.height = Int32(height)
        pic.writer = WebPMemoryWrite
        pic.custom_ptr = UnsafeMutableRawPointer(wrt)
        WebPMemoryWriterInit(wrt)
        
        let ok = importer(&pic, rgba.assumingMemoryBound(to: UInt8.self), Int32(stride)) != 0 && WebPEncode(&config, &pic) != 0
        WebPPictureFree(&pic)
        
        if !ok {
            WebPMemoryWriterClear(wrt)
            output.pointee = nil
            return 0
        }
        
        output.pointee = wrt.pointee.mem
        return wrt.pointee.size
    }
}
