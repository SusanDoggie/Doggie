//
//  WEBPDecoder.swift
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

struct WEBPDecoder: ImageRepDecoder {
    
    static var mediaType: MediaType {
        return .webp
    }
    
    private var frames: [WEBPFrame] = []
    
    let iccData: Data?
    
    private init(frame: WEBPFrame, iccData: Data?) {
        self.frames = [frame]
        self.iccData = iccData
    }
    
    init?(data: Data) {
        guard let decoder = data.withUnsafeBytes(WEBPDecoder.init) else { return nil }
        self = decoder
    }
    
    private init?(bytes: UnsafeRawBufferPointer) {
        
        guard let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        
        var data = WebPData(bytes: baseAddress, size: bytes.count)
        guard let demux = WebPDemux(&data) else { return nil }
        defer { WebPDemuxDelete(demux) }
        
        let format = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS)
        var iccData: Data?
        
        var chunk_iter = WebPChunkIterator()
        if format & ICCP_FLAG.rawValue != 0 && WebPDemuxGetChunk(demux, "ICCP", 1, &chunk_iter) != 0 {
            defer { WebPDemuxReleaseChunkIterator(&chunk_iter) }
            iccData = Data(bytes: chunk_iter.chunk.bytes, count: chunk_iter.chunk.size)
        }
        
        self.iccData = iccData
        
        var frame_iter = WebPIterator()
        guard WebPDemuxGetFrame(demux, 1, &frame_iter) != 0 else { return nil }
        defer { WebPDemuxReleaseIterator(&frame_iter) }
        
        repeat {
            
            guard let page = WEBPFrame(data: frame_iter.fragment) else { continue }
            
            self.frames.append(page)
            
        } while WebPDemuxNextFrame(&frame_iter) != 0
    }
}

extension WEBPDecoder {
    
    enum PixelFormat: Int32 {
        
        case RGBA
        case ARGB
        case BGRA
        case RGB
        case BGR
    }
}

private class WEBPFrame {
    
    var data = WebPData()
    
    var features = WebPBitstreamFeatures()
    
    init?(data: WebPData) {
        
        var data = data
        guard WebPDataCopy(&data, &self.data) != 0 else { return nil }
        
        let status = WebPGetFeatures(data.bytes, data.size, &features)
        guard status == VP8_STATUS_OK else { return nil }
    }
    
    deinit {
        WebPDataClear(&data)
    }
}

extension WEBPFrame {
    
    func decode(pixels: UnsafeMutableRawBufferPointer, format: WEBPDecoder.PixelFormat, bytesPerRow: Int) {
        guard let _pixels = pixels.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
        switch format {
        case .RGBA: WebPDecodeRGBAInto(data.bytes, data.size, _pixels, pixels.count, Int32(bytesPerRow))
        case .ARGB: WebPDecodeARGBInto(data.bytes, data.size, _pixels, pixels.count, Int32(bytesPerRow))
        case .BGRA: WebPDecodeBGRAInto(data.bytes, data.size, _pixels, pixels.count, Int32(bytesPerRow))
        case .RGB: WebPDecodeRGBInto(data.bytes, data.size, _pixels, pixels.count, Int32(bytesPerRow))
        case .BGR: WebPDecodeBGRInto(data.bytes, data.size, _pixels, pixels.count, Int32(bytesPerRow))
        }
    }
}

extension WEBPDecoder {
    
    var numberOfPages: Int {
        return frames.count
    }
    
    func page(_ index: Int) -> WEBPDecoder {
        return WEBPDecoder(frame: frames[index], iccData: iccData)
    }
}

extension WEBPDecoder {
    
    private var features: WebPBitstreamFeatures {
        return frames[0].features
    }
    
    enum Format: Int32 {
        
        case undefined = 0
        case lossy
        case lossless
    }
    
    var format: WEBPDecoder.Format {
        return WEBPDecoder.Format(rawValue: features.format) ?? .undefined
    }
    
    var width: Int {
        return Int(features.width)
    }
    
    var height: Int {
        return Int(features.height)
    }
    
    var resolution: Resolution {
        return .default
    }
    
    var colorSpace: AnyColorSpace {
        return AnyColorSpace(_colorSpace)
    }
    
    var isOpaque: Bool {
        return features.has_alpha == 0
    }
    
    var isAnimated: Bool {
        return features.has_animation != 0
    }
}

extension WEBPDecoder {
    
    var _colorSpace: ColorSpace<RGBColorModel> {
        guard let iccData = self.iccData, let colorSpace = try? AnyColorSpace(iccData: iccData) else { return .sRGB }
        return colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
    }
    
    func image(fileBacked: Bool) -> AnyImage {
        
        var image = Image<RGBA32ColorPixel>(width: width, height: height, colorSpace: _colorSpace, fileBacked: fileBacked)
        
        image.withUnsafeMutableBytes { frames[0].decode(pixels: $0, format: .RGBA, bytesPerRow: width << 2) }
        
        return AnyImage(image)
    }
    
}
