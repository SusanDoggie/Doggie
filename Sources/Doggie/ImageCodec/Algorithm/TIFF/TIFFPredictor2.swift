//
//  TIFFPredictor2.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

protocol TIFFRawRepresentable {
    
    func tiff_rawData(_ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8>
}

protocol TIFFEncodablePixel: ColorPixelProtocol {
    
    func tiff_prediction_2(_ lhs: Self) -> Self
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>)
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>)
}

extension ARGB32ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: ARGB32ColorPixel) -> ARGB32ColorPixel {
        return ARGB32ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension ARGB64ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: ARGB64ColorPixel) -> ARGB64ColorPixel {
        return ARGB64ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension RGBA32ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: RGBA32ColorPixel) -> RGBA32ColorPixel {
        return RGBA32ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension RGBA64ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: RGBA64ColorPixel) -> RGBA64ColorPixel {
        return RGBA64ColorPixel(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Gray16ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: Gray16ColorPixel) -> Gray16ColorPixel {
        return Gray16ColorPixel(white: w &- lhs.w, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(w.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Gray32ColorPixel : TIFFEncodablePixel {
    
    func tiff_prediction_2(_ lhs: Gray32ColorPixel) -> Gray32ColorPixel {
        return Gray32ColorPixel(white: w &- lhs.w, opacity: a &- lhs.a)
    }
    
    func tiff_encode_color(_ data: inout MappedBuffer<UInt8>) {
        data.encode(w.bigEndian)
    }
    
    func tiff_encode_opacity(_ data: inout MappedBuffer<UInt8>) {
        data.encode(a.bigEndian)
    }
}

extension Image : TIFFRawRepresentable {
    
    func tiff_rawData(_ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
        
        let samplesPerPixel = isOpaque ? Pixel.Model.numberOfComponents : Pixel.Model.numberOfComponents + 1
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: self.width * self.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        self.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = self.width * self.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let color = source.pointee.color
                        for i in 0..<Pixel.Model.numberOfComponents {
                            data.encode(UInt16((color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        }
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        for i in 0..<Pixel.Model.numberOfComponents {
                            data.encode(UInt16((pixel.color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        }
                        data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        source += 1
                    }
                }
            case 2:
                
                var lhs: [UInt16] = Array(repeating: 0, count: samplesPerPixel)
                
                lhs.withUnsafeMutableBufferPointer {
                    
                    guard let lhs = $0.baseAddress else { return }
                    
                    if isOpaque {
                        
                        for _ in 0..<self.height {
                            
                            memset(lhs, 0, samplesPerPixel << 1)
                            
                            for _ in 0..<self.width {
                                
                                let color = source.pointee.color
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[i]
                                    data.encode(s.bigEndian)
                                    lhs[i] = c
                                }
                                source += 1
                            }
                        }
                        
                    } else {
                        
                        for _ in 0..<self.height {
                            
                            memset(lhs, 0, samplesPerPixel << 1)
                            
                            for _ in 0..<self.width {
                                
                                let pixel = source.pointee
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((pixel.color.normalizedComponent(i) * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[i]
                                    data.encode(s.bigEndian)
                                    lhs[i] = c
                                }
                                do {
                                    let c = UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded())
                                    let s = c &- lhs[Pixel.Model.numberOfComponents]
                                    data.encode(s.bigEndian)
                                    lhs[Pixel.Model.numberOfComponents] = c
                                }
                                source += 1
                            }
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
}

extension TIFFEncoder {
    
    static func tiff_rawData<Pixel: TIFFEncodablePixel>(_ image: Image<Pixel>, _ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
        
        let samplesPerPixel = isOpaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
        let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
        
        var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = image.width * image.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        pixel.tiff_encode_color(&data)
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        pixel.tiff_encode_color(&data)
                        pixel.tiff_encode_opacity(&data)
                        source += 1
                    }
                }
            case 2:
                
                if isOpaque {
                    
                    for _ in 0..<image.height {
                        
                        var lhs = Pixel()
                        
                        for _ in 0..<image.width {
                            
                            let rhs = source.pointee
                            let pixel = rhs.tiff_prediction_2(lhs)
                            pixel.tiff_encode_color(&data)
                            lhs = rhs
                            source += 1
                        }
                    }
                } else {
                    
                    for _ in 0..<image.height {
                        
                        var lhs = Pixel()
                        
                        for _ in 0..<image.width {
                            
                            let rhs = source.pointee
                            let pixel = rhs.tiff_prediction_2(lhs)
                            pixel.tiff_encode_color(&data)
                            pixel.tiff_encode_opacity(&data)
                            lhs = rhs
                            source += 1
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
    
    static func tiff_rawData<Pixel>(_ image: Image<Pixel>, _ predictor: Int, _ isOpaque: Bool) -> MappedBuffer<UInt8> where Pixel.Model == LabColorModel {
        
        let samplesPerPixel = isOpaque ? 3 : 4
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        image.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
            case 1:
                let count = image.width * image.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let color = source.pointee.color
                        data.encode(UInt16((color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        data.encode(Int16((color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(Int16((color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        data.encode(UInt16((pixel.color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        data.encode(Int16((pixel.color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(Int16((pixel.color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                        data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        source += 1
                    }
                }
            case 2:
                
                if isOpaque {
                    
                    for _ in 0..<image.height {
                        
                        var _l1: UInt16 = 0
                        var _a1: Int16 = 0
                        var _b1: Int16 = 0
                        
                        for _ in 0..<image.width {
                            
                            let color = source.pointee.color
                            
                            let _l2 = UInt16((color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded())
                            let _a2 = Int16((color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _b2 = Int16((color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            
                            let _l3 = _l2 &- _l1
                            let _a3 = _a2 &- _a1
                            let _b3 = _b2 &- _b1
                            
                            data.encode(_l3.bigEndian)
                            data.encode(_a3.bigEndian)
                            data.encode(_b3.bigEndian)
                            
                            _l1 = _l2
                            _a1 = _a2
                            _b1 = _b2
                            
                            source += 1
                        }
                    }
                } else {
                    
                    for _ in 0..<image.height {
                        
                        var _l1: UInt16 = 0
                        var _a1: Int16 = 0
                        var _b1: Int16 = 0
                        var _o1: UInt16 = 0
                        
                        for _ in 0..<image.width {
                            
                            let pixel = source.pointee
                            
                            let _l2 = UInt16((pixel.color.normalizedComponent(0) * 65535).clamped(to: 0...65535).rounded())
                            let _a2 = Int16((pixel.color.normalizedComponent(1) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _b2 = Int16((pixel.color.normalizedComponent(2) * 65535 - 32768).clamped(to: -32768...32767).rounded())
                            let _o2 = UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded())
                            
                            let _l3 = _l2 &- _l1
                            let _a3 = _a2 &- _a1
                            let _b3 = _b2 &- _b1
                            let _o3 = _o2 &- _o1
                            
                            data.encode(_l3.bigEndian)
                            data.encode(_a3.bigEndian)
                            data.encode(_b3.bigEndian)
                            data.encode(_o3.bigEndian)
                            
                            _l1 = _l2
                            _a1 = _a2
                            _b1 = _b2
                            _o1 = _o2
                            
                            source += 1
                        }
                    }
                }
            default: fatalError()
            }
        }
        
        return data
    }
}
