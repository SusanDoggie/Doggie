//
//  PNGAnimatedEncoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

extension PNGEncoder: AnimatedImageEncoder {
    
    struct Frame<Pixel: ColorPixel> {
        
        var image: Image<Pixel>
        
        var duration: Double
        
    }
    
    static func encodeAnimationControlChunk(frames_count: Int, repeats: Int) -> PNGChunk {
        
        var data = Data(capacity: 8)
        
        data.encode(BEUInt32(frames_count))
        data.encode(BEUInt32(repeats))
        
        return PNGChunk(signature: "acTL", data: data)
    }
    
    static func encodeFrameControlChunk(sequence_number: Int, region: PNGRegion, duration: Int, dispose_op: UInt8, blend_op: UInt8) -> PNGChunk {
        
        var data = Data(capacity: 26)
        
        data.encode(BEUInt32(sequence_number))
        data.encode(BEUInt32(region.width))
        data.encode(BEUInt32(region.height))
        data.encode(BEUInt32(region.x))
        data.encode(BEUInt32(region.y))
        data.encode(BEUInt16(duration))
        data.encode(1000 as BEUInt16)
        data.encode(dispose_op)
        data.encode(blend_op)
        
        return PNGChunk(signature: "fcTL", data: data)
    }
    
    static func encodeFrameDataChunk<Pixel>(image: Image<Pixel>, region: PNGRegion, sequence_number: Int, deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool, opaque: Bool) -> PNGChunk? where Pixel: TIFFEncodablePixel {
        
        guard let encoded_data = encodeIDAT(image: image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque)?.data else { return nil }
        
        var data = Data(capacity: encoded_data.count + 4)
        
        data.encode(BEUInt32(sequence_number))
        data.append(encoded_data)
        
        return PNGChunk(signature: "fdAT", data: data)
    }
    
    static func trim_to_minimize<Pixel>(prev_image: Image<Pixel>, image: Image<Pixel>) -> PNGRegion {
        
        var region = PNGRegion(x: 0, y: 0, width: image.width, height: image.height)
        
        let width = image.width
        let height = image.height
        
        prev_image.withUnsafeBufferPointer {
            
            guard let prev_image = $0.baseAddress else { return }
            
            image.withUnsafeBufferPointer {
                
                guard let image = $0.baseAddress else { return }
                
                var top = 0
                var left = 0
                var bottom = 0
                var right = 0
                
                loop: for y in (0..<height).reversed() {
                    let prev_image = prev_image + width * y
                    let image = image + width * y
                    for x in 0..<width where prev_image[x] != image[x] {
                        break loop
                    }
                    bottom += 1
                }
                
                let max_y = height - bottom
                
                loop: for y in 0..<max_y {
                    let prev_image = prev_image + width * y
                    let image = image + width * y
                    for x in 0..<width where prev_image[x] != image[x] {
                        break loop
                    }
                    top += 1
                }
                
                loop: for x in (0..<width).reversed() {
                    for y in top..<max_y where prev_image[x + width * y] != image[x + width * y] {
                        break loop
                    }
                    right += 1
                }
                
                let max_x = width - right
                
                loop: for x in 0..<max_x {
                    for y in top..<max_y where prev_image[x + width * y] != image[x + width * y] {
                        break loop
                    }
                    left += 1
                }
                
                region = PNGRegion(x: left, y: top, width: max_x - left, height: max_y - top)
            }
        }
        
        return region
    }
    
    static func encodeFrames<Pixel>(frames: [Frame<Pixel>], deflate_level: Deflate.Level, predictor: PNGPrediction, interlaced: Bool, opaque: Bool) -> [PNGChunk]? where Pixel: TIFFEncodablePixel {
        
        var chunks: [PNGChunk] = []
        chunks.reserveCapacity(frames.count << 1)
        
        var prev_image: Image<Pixel>?
        
        var last_duration = 0
        var last_sequence_number = 0
        var sequence_number = 0
        
        for (i, frame) in frames.enumerated() {
            
            var region = PNGRegion(x: 0, y: 0, width: frame.image.width, height: frame.image.height)
            
            if let prev_image = prev_image {
                region = trim_to_minimize(prev_image: prev_image, image: frame.image)
            }
            
            if region.width == 0 && region.height == 0 {
                
                last_duration += Int(Double(frame.duration * 1000).rounded())
                
                let fctl = encodeFrameControlChunk(sequence_number: last_sequence_number, region: region, duration: last_duration, dispose_op: 0, blend_op: 0)
                chunks[chunks.count - 2] = fctl
                
                continue
                
            } else {
                
                last_duration = Int(Double(frame.duration * 1000).rounded())
                
                let fctl = encodeFrameControlChunk(sequence_number: sequence_number, region: region, duration: last_duration, dispose_op: 0, blend_op: 0)
                chunks.append(fctl)
                
                last_sequence_number = sequence_number
                sequence_number += 1
            }
            
            if i == 0 {
                
                guard let idat = encodeIDAT(image: frame.image, region: region, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
                
                chunks.append(idat)
                
            } else {
                
                guard let fdat = encodeFrameDataChunk(image: frame.image, region: region, sequence_number: sequence_number, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
                
                chunks.append(fdat)
                
                sequence_number += 1
            }
            
            prev_image = frame.image
        }
        
        return chunks
    }
    
    static func encode(image: AnimatedImage, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let deflate_level = properties[.deflateLevel] as? Deflate.Level ?? .default
        let predictor = properties[.predictor] as? PNGPrediction ?? .all
        let interlaced = properties[.interlaced] as? Bool == true
        
        let opaque = image.frames.allSatisfy { $0.image.isOpaque }
        
        guard let first = image.frames.first else { return nil }
        guard image.frames.allSatisfy({ $0.image.width == first.image.width && $0.image.height == first.image.height }) else { return nil }
        
        let phys = pHYs(first.image.resolution)
        
        let actl = encodeAnimationControlChunk(frames_count: image.frames.count, repeats: image.repeats)
        
        let ihdr: PNGChunk
        let iccp: PNGChunk
        let frame_chunks: [PNGChunk]
        
        if var colorSpace = first.image.colorSpace.base as? ColorSpace<GrayColorModel> {
            
            if let _iccp = iCCP(colorSpace, deflate_level: deflate_level) {
                iccp = _iccp
            } else {
                colorSpace = .genericGamma22Gray
                iccp = iCCP(colorSpace, deflate_level: deflate_level)!
            }
            
            ihdr = IHDR(width: first.image.width, height: first.image.height, bitDepth: 8, colour: opaque ? 0 : 4, interlaced: interlaced)
            
            let frames = image.frames.map { Frame(image: $0.image.convert(to: colorSpace) as Image<Gray16ColorPixel>, duration: $0.duration) }
            
            guard let _frame_chunks = encodeFrames(frames: frames, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
            
            frame_chunks = _frame_chunks
            
        } else {
            
            var colorSpace = first.image.colorSpace.base as? ColorSpace<RGBColorModel> ?? .sRGB
            
            if let _iccp = iCCP(colorSpace, deflate_level: deflate_level) {
                iccp = _iccp
            } else {
                colorSpace = .sRGB
                iccp = iCCP(colorSpace, deflate_level: deflate_level)!
            }
            
            ihdr = IHDR(width: first.image.width, height: first.image.height, bitDepth: 8, colour: opaque ? 2 : 6, interlaced: interlaced)
            
            let frames = image.frames.map { Frame(image: $0.image.convert(to: colorSpace) as Image<RGBA32ColorPixel>, duration: $0.duration) }
            
            guard let _frame_chunks = encodeFrames(frames: frames, deflate_level: deflate_level, predictor: predictor, interlaced: interlaced, opaque: opaque) else { return nil }
            
            frame_chunks = _frame_chunks
        }
        
        return encode([ihdr, phys, iccp, actl] + frame_chunks).data
    }
}
