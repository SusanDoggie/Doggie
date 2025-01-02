//
//  WEBPDecoder.swift
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

struct WEBPDecoder: ImageRepDecoder {
    
    static var supportedMediaTypes: [MediaType] {
        return [.webp]
    }
    
    var mediaType: MediaType {
        return .webp
    }
    
    let decoder: Decoder
    let iccData: Data?
    
    init?(data: Data) {
        
        guard let decoder = data.withUnsafeBytes(Decoder.init), decoder.anim_info.frame_count > 0 else { return nil }
        self.decoder = decoder
        
        let demuxer = decoder.demuxer
        
        let format = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS)
        var iccData: Data?
        
        var chunk_iter = WebPChunkIterator()
        if format & ICCP_FLAG.rawValue != 0 && WebPDemuxGetChunk(demuxer, "ICCP", 1, &chunk_iter) != 0 {
            defer { WebPDemuxReleaseChunkIterator(&chunk_iter) }
            iccData = Data(bytes: chunk_iter.chunk.bytes, count: chunk_iter.chunk.size)
        }
        
        self.iccData = iccData
    }
}

extension WEBPDecoder {
    
    struct Frame {
        
        let image: Image<RGBA32ColorPixel>
        
        let timestamp: Int32
        
        let delay: Int32
    }
    
    class WEBPData {
        
        var mem = WebPData()
        
        init?(bytes: UnsafeRawBufferPointer) {
            
            guard let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
            
            var data = WebPData(bytes: baseAddress, size: bytes.count)
            guard WebPDataCopy(&data, &self.mem) != 0 else { return nil }
        }
        
        deinit {
            WebPDataClear(&mem)
        }
    }
    
    class Decoder {
        
        let lck = NSLock()
        
        let decoder: OpaquePointer
        let anim_info: WebPAnimInfo
        
        var data: WEBPData
        
        var frames: [Frame] = []
        
        init?(bytes: UnsafeRawBufferPointer) {
            
            var options = WebPAnimDecoderOptions()
            WebPAnimDecoderOptionsInit(&options)
            
            options.color_mode = MODE_RGBA
            
            guard let data = WEBPData(bytes: bytes) else { return nil }
            self.data = data
            
            guard let decoder = WebPAnimDecoderNew(&self.data.mem, &options) else { return nil }
            self.decoder = decoder
            
            var anim_info = WebPAnimInfo()
            WebPAnimDecoderGetInfo(decoder, &anim_info)
            self.anim_info = anim_info
        }
        
        deinit {
            WebPAnimDecoderDelete(decoder)
        }
        
        func read_frame(index: Int, colorSpace: ColorSpace<RGBColorModel>, fileBacked: Bool) -> Frame {
            
            guard index < anim_info.frame_count else { fatalError("Index out of range.") }
            
            self.lck.lock()
            defer { self.lck.unlock() }
            
            while index >= frames.count {
                
                var buf: UnsafeMutablePointer<UInt8>?
                var timestamp: Int32 = 0
                
                WebPAnimDecoderGetNext(decoder, &buf, &timestamp)
                
                var image = Image<RGBA32ColorPixel>(width: Int(anim_info.canvas_width), height: Int(anim_info.canvas_height), colorSpace: colorSpace, fileBacked: fileBacked)
                
                image.withUnsafeMutableBytes { buffer in
                    
                    guard let buf = buf else { return }
                    
                    buffer.copyMemory(from: UnsafeRawBufferPointer(start: buf, count: buffer.count))
                }
                
                let last_timestamp = frames.last?.timestamp ?? 0
                
                frames.append(Frame(image: image, timestamp: timestamp, delay: timestamp - last_timestamp))
            }
            
            return frames[index]
        }
        
        var demuxer: OpaquePointer? {
            return WebPAnimDecoderGetDemuxer(decoder)
        }
    }
    
}

extension WEBPDecoder {
    
    var width: Int {
        return Int(decoder.anim_info.canvas_width)
    }
    
    var height: Int {
        return Int(decoder.anim_info.canvas_height)
    }
    
    var resolution: Resolution {
        return .default
    }
    
    var colorSpace: AnyColorSpace {
        return AnyColorSpace(_colorSpace)
    }
    
    func image(fileBacked: Bool) -> AnyImage {
        return decoder.read_frame(index: 0, colorSpace: _colorSpace, fileBacked: fileBacked).image(fileBacked: fileBacked)
    }
}

extension WEBPDecoder {
    
    var _colorSpace: ColorSpace<RGBColorModel> {
        guard let iccData = self.iccData, let colorSpace = try? AnyColorSpace(iccData: iccData) else { return .sRGB }
        return colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
    }
    
    var numberOfPages: Int {
        return Int(decoder.anim_info.frame_count)
    }
    
    func page(_ index: Int) -> ImageRepBase {
        return decoder.read_frame(index: index, colorSpace: _colorSpace, fileBacked: true)
    }
}

extension WEBPDecoder.Frame: ImageRepBase {
    
    var width: Int {
        return image.width
    }
    
    var height: Int {
        return image.height
    }
    
    var resolution: Resolution {
        return .default
    }
    
    var colorSpace: AnyColorSpace {
        return AnyColorSpace(image.colorSpace)
    }
    
    func image(fileBacked: Bool) -> AnyImage {
        var image = self.image
        image.fileBacked = fileBacked
        return AnyImage(image)
    }
}

extension WEBPDecoder {
    
    var isAnimated: Bool {
        return decoder.anim_info.frame_count > 1
    }
    
    var repeats: Int {
        return Int(decoder.anim_info.loop_count)
    }
}

extension WEBPDecoder.Frame {
    
    var duration: Double {
        return Double(delay) / 1000
    }
}
