//
//  GrayPixelDecoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

@frozen
public struct GrayPixelDecoder {
    
    public var width: Int
    public var height: Int
    
    public var resolution: Resolution
    
    public var colorSpace: ColorSpace<GrayColorModel>
    
    public init(width: Int, height: Int, resolution: Resolution, colorSpace: ColorSpace<GrayColorModel>) {
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
    }
}

extension GrayPixelDecoder {
    
    @inlinable
    public func decode_opaque_gray8(data: Data, fileBacked: Bool) -> Image<Gray16ColorPixel> {
        
        var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count)
        
        data.withUnsafeBufferPointer(as: UInt8.self) {
            
            guard var source = $0.baseAddress else { return }
            
            image.withUnsafeMutableBufferPointer {
                
                guard var destination = $0.baseAddress else { return }
                
                for _ in 0..<pixels_count {
                    destination.pointee = Gray16ColorPixel(white: source.pointee)
                    source += 1
                    destination += 1
                }
            }
        }
        
        return image
    }
    
    @inlinable
    public func decode_opaque_gray16(data: Data, endianness: RawBitmap.Endianness, fileBacked: Bool) -> Image<Gray32ColorPixel> {
        
        var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count / 2)
        
        switch endianness {
        case .big:
            
            data.withUnsafeBufferPointer(as: BEUInt16.self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        destination.pointee = Gray32ColorPixel(white: source.pointee.representingValue)
                        source += 1
                        destination += 1
                    }
                }
            }
            
        case .little:
            
            data.withUnsafeBufferPointer(as: LEUInt16.self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        destination.pointee = Gray32ColorPixel(white: source.pointee.representingValue)
                        source += 1
                        destination += 1
                    }
                }
            }
        }
        
        return image
    }
    
}

extension GrayPixelDecoder {
    
    @inlinable
    public func decode_gray8(data: Data, transparent: UInt8, fileBacked: Bool) -> Image<Gray16ColorPixel> {
        
        var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count)
        
        data.withUnsafeBufferPointer(as: UInt8.self) {
            
            guard var source = $0.baseAddress else { return }
            
            image.withUnsafeMutableBufferPointer {
                
                guard var destination = $0.baseAddress else { return }
                
                for _ in 0..<pixels_count {
                    
                    let value = source.pointee
                    
                    if value != transparent {
                        destination.pointee = Gray16ColorPixel(white: value)
                    }
                    
                    source += 1
                    destination += 1
                }
            }
        }
        
        return image
    }
    
    @inlinable
    public func decode_gray16(data: Data, transparent: UInt16, endianness: RawBitmap.Endianness, fileBacked: Bool) -> Image<Gray32ColorPixel> {
        
        var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count / 2)
        
        switch endianness {
        case .big:
            
            data.withUnsafeBufferPointer(as: BEUInt16.self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        
                        let value = source.pointee.representingValue
                        
                        if value != transparent {
                            destination.pointee = Gray32ColorPixel(white: value)
                        }
                        
                        source += 1
                        destination += 1
                    }
                }
            }
            
        case .little:
            
            data.withUnsafeBufferPointer(as: LEUInt16.self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        
                        let value = source.pointee.representingValue
                        
                        if value != transparent {
                            destination.pointee = Gray32ColorPixel(white: value)
                        }
                        
                        source += 1
                        destination += 1
                    }
                }
            }
        }
        
        return image
    }
    
}

extension GrayPixelDecoder {
    
    @inlinable
    public func decode_gray16(data: Data, fileBacked: Bool) -> Image<Gray16ColorPixel> {
        
        var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count / 2)
        
        data.withUnsafeBufferPointer(as: (UInt8, UInt8).self) {
            
            guard var source = $0.baseAddress else { return }
            
            image.withUnsafeMutableBufferPointer {
                
                guard var destination = $0.baseAddress else { return }
                
                for _ in 0..<pixels_count {
                    let (w, a) = source.pointee
                    destination.pointee = Gray16ColorPixel(white: w, opacity: a)
                    source += 1
                    destination += 1
                }
            }
        }
        
        return image
    }
    
    @inlinable
    public func decode_gray32(data: Data, endianness: RawBitmap.Endianness, fileBacked: Bool) -> Image<Gray32ColorPixel> {
        
        var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let pixels_count = min(image.pixels.count, data.count / 4)
        
        switch endianness {
        case .big:
            
            data.withUnsafeBufferPointer(as: (BEUInt16, BEUInt16).self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        let (w, a) = source.pointee
                        destination.pointee = Gray32ColorPixel(white: w.representingValue, opacity: a.representingValue)
                        source += 1
                        destination += 1
                    }
                }
            }
            
        case .little:
            
            data.withUnsafeBufferPointer(as: (LEUInt16, LEUInt16).self) {
                
                guard var source = $0.baseAddress else { return }
                
                image.withUnsafeMutableBufferPointer {
                    
                    guard var destination = $0.baseAddress else { return }
                    
                    for _ in 0..<pixels_count {
                        let (w, a) = source.pointee
                        destination.pointee = Gray32ColorPixel(white: w.representingValue, opacity: a.representingValue)
                        source += 1
                        destination += 1
                    }
                }
            }
        }
        
        return image
    }
    
}
