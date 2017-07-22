//
//  RawImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

import Foundation

public struct RawBitmapChannel {
    
    public var channel: Int
    
    public var format: Format
    public var endianness: Endianness
    
    public var startsRow: Int
    
    public var bitmapIndex: Int
    public var bitsPerPixel: Int
    public var bitsPerRow: Int
    public var bitRange: Range<Int>
    
    public init(channel: Int, format: Format, endianness: Endianness, startsRow: Int, bitmapIndex: Int, bitsPerPixel: Int, bitsPerRow: Int, bitRange: Range<Int>) {
        if format == .float {
            precondition(bitRange.count == 32 || bitRange.count == 64, "Only supported Float32 or Float64.")
        }
        if endianness == .little {
            precondition(bitRange.count == 8 || bitRange.count == 16 || bitRange.count == 32 || bitRange.count == 64, "Only supported 8, 16, 32 or 64 bits little-endian.")
        }
        self.channel = channel
        self.format = format
        self.endianness = endianness
        self.startsRow = startsRow
        self.bitmapIndex = bitmapIndex
        self.bitsPerPixel = bitsPerPixel
        self.bitsPerRow = bitsPerRow
        self.bitRange = bitRange
    }
}

extension RawBitmapChannel {
    
    public enum Format {
        
        case unsigned
        case signed
        case float
    }
    
    public enum Endianness {
        
        case big
        case little
    }
}

extension Image {
    
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), channels: [RawBitmapChannel], bitmaps: [Data], premultiplied: Bool, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(image: RawImage(width: width, height: height, channels: channels, bitmaps: bitmaps, premultiplied: premultiplied, colorSpace: colorSpace, resolution: resolution).image())
    }
}

extension AnyImage {
    
    @_inlineable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), channels: [RawBitmapChannel], bitmaps: [Data], premultiplied: Bool, colorSpace: AnyColorSpace) {
        self.init(base: colorSpace._base._createImage(width: width, height: height, resolution: resolution, channels: channels, bitmaps: bitmaps, premultiplied: premultiplied))
    }
}

struct RawImage<Model : ColorModelProtocol> {
    
    let width: Int
    let height: Int
    
    var channels: [RawBitmapChannel]
    var bitmaps: [Data]
    
    var premultiplied: Bool
    
    var colorSpace: ColorSpace<Model>
    
    var resolution: Resolution
    
}

extension UnsafePointer where Pointee == UInt8 {
    
    @inline(__always)
    fileprivate func _bitPattern(from range: Range<Int>) -> UInt64 {
        
        let bitWidth = range.count
        
        precondition(bitWidth <= 64)
        
        let byteOffset = range.lowerBound >> 3
        var source = self + byteOffset
        
        let s = range.lowerBound - byteOffset << 3
        
        var remain = bitWidth - (8 - s)
        var value = UInt64(source.pointee) & (0xFF >> s)
        
        while remain > 0 {
            source += 1
            let s1 = min(remain, 8)
            let s2 = 8 - s1
            value = value << s1 + UInt64(source.pointee >> s2)
            remain -= 8
        }
        
        return value
    }
}

extension RawImage {
    
    func image() -> Image<ColorPixel<Model>> {
        
        var image = Image<ColorPixel<Model>>(width: width, height: height, colorSpace: colorSpace)
        
        image.withUnsafeMutableBufferPointer {
            
            guard let destination = $0.baseAddress else { return }
            
            let numberOfComponents = colorSpace.numberOfComponents
            
            let isOpaque = !self.channels.contains(where: { $0.channel == numberOfComponents })
            
            for channel in 0..<numberOfComponents + 1 {
                
                for _channel in self.channels.filter({ $0.channel == channel }) {
                    
                    guard _channel.startsRow < height else { continue }
                    guard _channel.bitmapIndex < self.bitmaps.count else { continue }
                    
                    let bitmap = self.bitmaps[_channel.bitmapIndex]
                    
                    let bitsPerPixel = _channel.bitsPerPixel
                    let bitsPerRow = _channel.bitsPerRow
                    let bitRange = _channel.bitRange
                    
                    let bitsWidth = bitRange.count
                    
                    let endianness = _channel.endianness
                    
                    guard bitsWidth > 0 else { continue }
                    guard bitRange.lowerBound >= 0 && bitRange.upperBound <= bitsPerPixel else { continue }
                    
                    guard bitsPerPixel * width <= bitsPerRow else { continue }
                    
                    var destination = destination
                    
                    let bitmapBitsLegnth = bitmap.count << 3
                    
                    bitmap.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                        
                        for y in _channel.startsRow..<height {
                            
                            let rowBitsOffset = bitsPerRow * y
                            
                            for x in 0..<width {
                                
                                let pixelBitsOffset = rowBitsOffset + x * bitsPerPixel + bitRange.lowerBound
                                
                                let patternBitRange = pixelBitsOffset..<pixelBitsOffset + bitsWidth
                                
                                guard patternBitRange.upperBound <= bitmapBitsLegnth else { return }
                                
                                var value: Double = 0.0
                                
                                switch _channel.format {
                                    
                                case .unsigned:
                                    
                                    if bitsWidth > 64 {
                                        
                                        for patternSlice in patternBitRange.slice(by: 64) {
                                            let pattern = source._bitPattern(from: Range(patternSlice))
                                            value = value * pow(2, Double(patternSlice.count)) + Double(pattern)
                                        }
                                        
                                    } else {
                                        let pattern = source._bitPattern(from: Range(patternBitRange))
                                        
                                        switch endianness {
                                        case .big: value = Double(pattern)
                                        case .little:
                                            switch bitsWidth {
                                            case 8: value = Double(pattern)
                                            case 16: value = Double(UInt16(extendingOrTruncating: pattern).byteSwapped)
                                            case 32: value = Double(UInt32(extendingOrTruncating: pattern).byteSwapped)
                                            case 64: value = Double(UInt64(extendingOrTruncating: pattern).byteSwapped)
                                            default: break
                                            }
                                        }
                                    }
                                    
                                    value /= pow(2, Double(bitsWidth)) - 1
                                    
                                case .signed:
                                    
                                    var signed = false
                                    
                                    if bitsWidth > 64 {
                                        
                                        for (flag, patternSlice) in patternBitRange.slice(by: 64).enumerated() {
                                            let pattern = source._bitPattern(from: Range(patternSlice))
                                            if flag == 0 && pattern & (1 << (patternSlice.count - 1)) != 0 {
                                                signed = true
                                            }
                                            value = value * pow(2, Double(patternSlice.count)) + Double(pattern)
                                        }
                                        
                                    } else {
                                        
                                        let pattern = source._bitPattern(from: Range(patternBitRange))
                                        
                                        if pattern & (1 << (bitsWidth - 1)) != 0 {
                                            signed = true
                                        }
                                        
                                        switch endianness {
                                        case .big: value = Double(pattern)
                                        case .little:
                                            switch bitsWidth {
                                            case 8: value = Double(pattern)
                                            case 16: value = Double(UInt16(extendingOrTruncating: pattern).byteSwapped)
                                            case 32: value = Double(UInt32(extendingOrTruncating: pattern).byteSwapped)
                                            case 64: value = Double(UInt64(extendingOrTruncating: pattern).byteSwapped)
                                            default: break
                                            }
                                        }
                                    }
                                    
                                    value *= pow(2, Double(-bitsWidth))
                                    
                                    if signed {
                                        value -= 1
                                    }
                                    value += 0.5
                                    
                                case .float:
                                    
                                    let pattern = source._bitPattern(from: Range(patternBitRange))
                                    
                                    switch endianness {
                                    case .big:
                                        switch bitsWidth {
                                        case 32: value = Double(Float(bitPattern: UInt32(extendingOrTruncating: pattern)))
                                        case 64: value = Double(bitPattern: pattern)
                                        default: break
                                        }
                                    case .little:
                                        switch bitsWidth {
                                        case 32: value = Double(Float(bitPattern: UInt32(extendingOrTruncating: pattern).byteSwapped))
                                        case 64: value = Double(bitPattern: pattern.byteSwapped)
                                        default: break
                                        }
                                    }
                                }
                                
                                if channel == numberOfComponents && premultiplied {
                                    var pixel = destination.pointee
                                    if value == 0 {
                                        pixel.color = Model()
                                    } else {
                                        pixel.color /= value
                                        pixel.opacity = value
                                    }
                                    destination.pointee = pixel
                                } else {
                                    destination.pointee.setNormalizedComponent(channel, value)
                                }
                                if isOpaque {
                                    destination.pointee.opacity = 1
                                }
                                
                                destination += 1
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
        }
        
        return image
    }
}

