//
//  TIFFRawRepresentable.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

protocol TIFFRawRepresentable {
    
    func tiff_color_data(_ predictor: TIFFPrediction, _ isOpaque: Bool) -> MappedBuffer<UInt8>
    
    func tiff_opacity_data(_ predictor: TIFFPrediction) -> MappedBuffer<UInt8>
}

extension Image: TIFFRawRepresentable {
    
    func tiff_color_data(_ predictor: TIFFPrediction, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
        
        let samplesPerPixel = isOpaque ? Pixel.Model.numberOfComponents : Pixel.Model.numberOfComponents + 1
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: self.width * self.height * samplesPerPixel * bytesPerSample, fileBacked: true)
        
        self.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
                
            case .none:
                
                let count = self.width * self.height
                
                if isOpaque {
                    for _ in 0..<count {
                        let color = source.pointee.color.normalized()
                        for i in 0..<Pixel.Model.numberOfComponents {
                            data.encode(UInt16((color[i] * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        }
                        source += 1
                    }
                } else {
                    for _ in 0..<count {
                        let pixel = source.pointee
                        let color = pixel.color.normalized()
                        for i in 0..<Pixel.Model.numberOfComponents {
                            data.encode(UInt16((color[i] * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        }
                        data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                        source += 1
                    }
                }
                
            case .subtract:
                
                var lhs: [UInt16] = Array(repeating: 0, count: samplesPerPixel)
                
                lhs.withUnsafeMutableBufferPointer {
                    
                    guard let lhs = $0.baseAddress else { return }
                    
                    if isOpaque {
                        
                        for _ in 0..<self.height {
                            
                            memset(lhs, 0, samplesPerPixel << 1)
                            
                            for _ in 0..<self.width {
                                
                                let color = source.pointee.color.normalized()
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((color[i] * 65535).clamped(to: 0...65535).rounded())
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
                                let color = pixel.color.normalized()
                                for i in 0..<Pixel.Model.numberOfComponents {
                                    let c = UInt16((color[i] * 65535).clamped(to: 0...65535).rounded())
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
            }
        }
        
        return data
    }
    
    func tiff_opacity_data(_ predictor: TIFFPrediction) -> MappedBuffer<UInt8> {
        
        let bytesPerSample = 2
        
        var data = MappedBuffer<UInt8>(capacity: self.width * self.height * bytesPerSample, fileBacked: true)
        
        self.withUnsafeBufferPointer {
            
            guard var source = $0.baseAddress else { return }
            
            switch predictor {
                
            case .none:
                
                let count = self.width * self.height
                
                for _ in 0..<count {
                    data.encode(UInt16((source.pointee.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    source += 1
                }
                
            case .subtract:
                
                var lhs: UInt16 = 0
                
                for _ in 0..<self.height {
                    
                    lhs = 0
                    
                    for _ in 0..<self.width {
                        
                        let c = UInt16((source.pointee.opacity * 65535).clamped(to: 0...65535).rounded())
                        let s = c &- lhs
                        data.encode(s.bigEndian)
                        lhs = c
                        
                        source += 1
                    }
                }
            }
        }
        
        return data
    }
}

func tiff_color_data<Pixel: TIFFEncodablePixel>(_ image: Image<Pixel>, _ predictor: TIFFPrediction, _ isOpaque: Bool) -> MappedBuffer<UInt8> {
    
    let samplesPerPixel = isOpaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
    let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
    
    var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
    
    image.withUnsafeBufferPointer {
        
        guard var source = $0.baseAddress else { return }
        
        switch predictor {
            
        case .none:
            
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
            
        case .subtract:
            
            if isOpaque {
                
                for _ in 0..<image.height {
                    
                    var lhs = Pixel()
                    
                    for _ in 0..<image.width {
                        
                        let rhs = source.pointee
                        let pixel = rhs.tiff_prediction_2_encode(lhs)
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
                        let pixel = rhs.tiff_prediction_2_encode(lhs)
                        pixel.tiff_encode_color(&data)
                        pixel.tiff_encode_opacity(&data)
                        lhs = rhs
                        source += 1
                    }
                }
            }
        }
    }
    
    return data
}

func tiff_opacity_data<Pixel: TIFFEncodablePixel>(_ image: Image<Pixel>, _ predictor: TIFFPrediction) -> MappedBuffer<UInt8> {
    
    let bytesPerSample = MemoryLayout<Pixel>.stride / Pixel.numberOfComponents
    
    var data = MappedBuffer<UInt8>(capacity: image.width * image.height * bytesPerSample, fileBacked: true)
    
    image.withUnsafeBufferPointer {
        
        guard var source = $0.baseAddress else { return }
        
        switch predictor {
            
        case .none:
            
            let count = image.width * image.height
            
            for _ in 0..<count {
                let pixel = source.pointee
                pixel.tiff_encode_opacity(&data)
                source += 1
            }
            
        case .subtract:
            
            for _ in 0..<image.height {
                
                var lhs = Pixel()
                
                for _ in 0..<image.width {
                    
                    let rhs = source.pointee
                    let pixel = rhs.tiff_prediction_2_encode(lhs)
                    pixel.tiff_encode_opacity(&data)
                    lhs = rhs
                    source += 1
                }
            }
        }
    }
    
    return data
}

func tiff_color_data<Pixel>(_ image: Image<Pixel>, _ predictor: TIFFPrediction, _ isOpaque: Bool) -> MappedBuffer<UInt8> where Pixel.Model == LabColorModel {
    
    let samplesPerPixel = isOpaque ? 3 : 4
    let bytesPerSample = 2
    
    var data = MappedBuffer<UInt8>(capacity: image.width * image.height * samplesPerPixel * bytesPerSample, fileBacked: true)
    
    image.withUnsafeBufferPointer {
        
        guard var source = $0.baseAddress else { return }
        
        switch predictor {
            
        case .none:
            
            let count = image.width * image.height
            
            if isOpaque {
                for _ in 0..<count {
                    let color = source.pointee.color.normalized()
                    data.encode(UInt16((color[0] * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    data.encode(Int16((color[1] * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(Int16((color[2] * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    source += 1
                }
            } else {
                for _ in 0..<count {
                    let pixel = source.pointee
                    let color = pixel.color.normalized()
                    data.encode(UInt16((color[0] * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    data.encode(Int16((color[1] * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(Int16((color[2] * 65535 - 32768).clamped(to: -32768...32767).rounded()).bigEndian)
                    data.encode(UInt16((pixel.opacity * 65535).clamped(to: 0...65535).rounded()).bigEndian)
                    source += 1
                }
            }
            
        case .subtract:
            
            if isOpaque {
                
                for _ in 0..<image.height {
                    
                    var _l1: UInt16 = 0
                    var _a1: Int16 = 0
                    var _b1: Int16 = 0
                    
                    for _ in 0..<image.width {
                        
                        let color = source.pointee.color.normalized()
                        
                        let _l2 = UInt16((color[0] * 65535).clamped(to: 0...65535).rounded())
                        let _a2 = Int16((color[1] * 65535 - 32768).clamped(to: -32768...32767).rounded())
                        let _b2 = Int16((color[2] * 65535 - 32768).clamped(to: -32768...32767).rounded())
                        
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
                        let color = pixel.color.normalized()
                        
                        let _l2 = UInt16((color[0] * 65535).clamped(to: 0...65535).rounded())
                        let _a2 = Int16((color[1] * 65535 - 32768).clamped(to: -32768...32767).rounded())
                        let _b2 = Int16((color[2] * 65535 - 32768).clamped(to: -32768...32767).rounded())
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
        }
    }
    
    return data
}
