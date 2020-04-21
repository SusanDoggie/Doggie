//
//  WEBPAnimatedEncoder.swift
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

struct WEBPAnimatedEncoder: AnimatedImageEncoder {
    
    let width: Int
    let height: Int
    
    var frames: [Frame]
    var repeats: Int
    
    var quality: Double?
    
    var iccData: Data?
    
}

extension WEBPAnimatedEncoder {
    
    struct Frame {
        
        let bytesPerRow: Int
        
        let pixels: Data
        
        var duration: Double
    }
}

extension WEBPAnimatedEncoder {
    
    static func encode(image: AnimatedImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        guard let first = image.frames.first else { return nil }
        guard image.frames.allSatisfy({ $0.image.width == first.image.width && $0.image.height == first.image.height }) else { return nil }
        
        let colorSpace = first.image.colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
        
        var frames: [Frame] = []
        
        for frame in image.frames {
            
            let image = Image<RGBA32ColorPixel>(image: frame.image, colorSpace: colorSpace)
            
            frames.append(Frame(bytesPerRow: 4 * image.width, pixels: image.pixels.data, duration: frame.duration))
        }
        
        var encoder = WEBPAnimatedEncoder(width: first.image.width, height: first.image.height, frames: frames, repeats: image.repeats)
        encoder.iccData = colorSpace.iccData
        
        if let quality = properties[.compressionQuality] as? Double {
            encoder.quality = (quality * 100).clamped(to: 0...100)
        }
        
        return encoder.encode()
    }
}

#if canImport(CoreGraphics)

extension WEBPAnimatedEncoder {
    
    static func encode(image: CGAnimatedImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        guard let first = image.frames.first else { return nil }
        guard image.frames.allSatisfy({ $0.image.width == first.image.width && $0.image.height == first.image.height }) else { return nil }
        
        var frames: [Frame] = []
        
        let colorSpace = first.image.colorSpace
        let iccData: Data?
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            iccData = colorSpace?.copyICCData() as Data?
        } else {
            iccData = colorSpace?.iccData as Data?
        }
        
        for frame in image.frames {
            
            var image = frame.image
            
            switch (image.bitmapInfo.intersection(.byteOrderMask), image.alphaInfo) {
            case (.byteOrder32Big, .last):
                
                guard image.colorSpace !== colorSpace else { break }
                
                fallthrough
                
            default:
                
                let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.last.rawValue)
                
                guard let _image = image.createCGImage(
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    bytesPerRow: 4 * image.width,
                    space: colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: bitmapInfo,
                    decode: image.decode,
                    shouldInterpolate: image.shouldInterpolate,
                    intent: image.renderingIntent
                    ) else { return nil }
                
                image = _image
            }
            
            guard let pixels = image.dataProvider?.data as Data? else { return nil }
            
            frames.append(Frame(bytesPerRow: 4 * image.width, pixels: pixels, duration: frame.duration))
        }
        
        var encoder = WEBPAnimatedEncoder(width: first.image.width, height: first.image.height, frames: frames, repeats: image.repeats)
        encoder.iccData = iccData
        
        if let quality = properties[.compressionQuality] as? Double {
            encoder.quality = (quality * 100).clamped(to: 0...100)
        }
        
        return encoder.encode()
    }
}

#endif

extension WEBPAnimatedEncoder {
    
    func encode() -> Data? {
        
        var options = WebPAnimEncoderOptions()
        WebPAnimEncoderOptionsInit(&options)
        
        options.anim_params.loop_count = Int32(repeats)
        options.minimize_size = 1
        options.allow_mixed = 1
        
        let encoder = WebPAnimEncoderNew(Int32(width), Int32(height), &options)
        defer { WebPAnimEncoderDelete(encoder) }
        
        var timestamp = 0
        
        for frame in frames {
            
            frame.pixels.withUnsafeBufferPointer { bytes in
                
                guard let bytes = bytes.baseAddress else { return }
                
                var pic = WebPPicture()
                var config = WebPConfig()
                
                guard WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, Float(quality ?? 100)) != 0 && WebPPictureInit(&pic) != 0 else { return }
                
                config.lossless = quality == nil ? 1 : 0
                pic.use_argb = 1
                pic.width = Int32(width)
                pic.height = Int32(height)
                
                guard WebPPictureImportRGBA(&pic, bytes, Int32(frame.bytesPerRow)) != 0 && WebPEncode(&config, &pic) != 0 else { return }
                defer { WebPPictureFree(&pic) }
                
                WebPAnimEncoderAdd(encoder, &pic, Int32(timestamp), &config)
            }
            
            timestamp += Int(round(frame.duration * 1000))
        }
        
        WebPAnimEncoderAdd(encoder, nil, Int32(timestamp), nil)
        
        var output = WebPData()
        WebPAnimEncoderAssemble(encoder, &output)
        defer { WebPDataClear(&output) }
        
        return Data(bytes: output.bytes, count: output.size)
    }
}
