//
//  RawBitmap.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct RawBitmap {
    
    public var bitsPerPixel: Int
    public var bitsPerRow: Int
    public var startsRow: Int
    
    public var channels: [Channel]
    
    public var data: Data
    
    public init(bitsPerPixel: Int, bitsPerRow: Int, startsRow: Int, channels: [Channel], data: Data) {
        self.bitsPerPixel = bitsPerPixel
        self.bitsPerRow = bitsPerRow
        self.startsRow = startsRow
        self.channels = channels
        self.data = data
    }
}

extension RawBitmap {
    
    public struct Channel {
        
        public var index: Int
        
        public var format: Format
        public var endianness: Endianness
        
        public var bitRange: Range<Int>
        
        public init(index: Int, format: Format, endianness: Endianness, bitRange: Range<Int>) {
            if format == .float {
                precondition(bitRange.count == 32 || bitRange.count == 64, "Only supported Float32 or Float64.")
            }
            if endianness == .little {
                precondition(bitRange.count % 8 == 0, "Unsupported bitRange with little-endian.")
            }
            self.index = index
            self.format = format
            self.endianness = endianness
            self.bitRange = bitRange
        }
    }
}

extension RawBitmap {
    
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
    
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool = false) {
        
        self.init(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
        
        let numberOfComponents = colorSpace.numberOfComponents
        
        let isOpaque = !bitmaps.contains { $0.channels.contains { $0.index == numberOfComponents } }
        
        self.withUnsafeMutableBufferPointer {
            
            guard let destination = $0.baseAddress else { return }
            
            for bitmap in bitmaps where bitmap.startsRow < height {
                
                let dataBitSize = bitmap.data.count << 3
                
                bitmap.data.withUnsafeBytes { (source: UnsafePointer<UInt8>) in
                    
                    var destination = destination + bitmap.startsRow * width
                    
                    var bitsOffset = 0
                    
                    for _ in bitmap.startsRow..<height {
                        
                        var _bitsOffset = bitsOffset
                        var _destination = destination
                        
                        for _ in 0..<width {
                            
                            guard _bitsOffset + bitmap.bitsPerPixel <= dataBitSize else { return }
                            
                            let bytesOffset = _bitsOffset >> 3
                            let source = source + bytesOffset
                            
                            let bytesPerPixel = bitmap.bitsPerPixel >> 3
                            let pixelShift = _bitsOffset & 7
                            
                            @inline(__always)
                            func pixelByte(_ i: Int) -> UInt8 {
                                return pixelShift == 0 ? source[i] : (source[i] << pixelShift) | (source[i + 1] >> (8 - pixelShift))
                            }
                            
                            var pixel = _destination.pointee
                            
                            for channel in bitmap.channels where channel.index <= numberOfComponents {
                                
                                var value = 0.0
                                
                                let channelBytesOffset = channel.bitRange.lowerBound >> 3
                                let channelShift = channel.bitRange.lowerBound & 7
                                let bytesPerChannel = channel.bitRange.count >> 3
                                
                                @inline(__always)
                                func channelByte(_ i: Int) -> UInt8 {
                                    switch channel.endianness {
                                    case .big: return channelShift == 0 ? pixelByte(i + channelBytesOffset) : (pixelByte(i + channelBytesOffset) << channelShift) | (pixelByte(i + 1 + channelBytesOffset) >> (8 - channelShift))
                                    case .little: return pixelByte(bytesPerChannel - i - 1 + channelBytesOffset)
                                    }
                                }
                                
                                switch channel.format {
                                case .unsigned:
                                    
                                    var bitPattern: UInt64 = 0
                                    for (i, slice) in channel.bitRange.slice(by: 8).enumerated() where i < 8 {
                                        bitPattern = (bitPattern << slice.count) | UInt64(channelByte(i))
                                    }
                                    
                                    value = Double(bitPattern) / (scalbn(1, min(channel.bitRange.count, 64)) - 1)
                                    
                                case .signed:
                                    
                                    var signed = false
                                    
                                    var bitPattern: UInt64 = 0
                                    for (i, slice) in channel.bitRange.slice(by: 8).enumerated() where i < 8 {
                                        let byte = channelByte(i)
                                        if i == 0 && byte & 0x80 != 0 {
                                            signed = true
                                        }
                                        bitPattern = (bitPattern << slice.count) | UInt64(byte)
                                    }
                                    
                                    value = Double(bitPattern)
                                    value = scalbn(value, -min(channel.bitRange.count, 64))
                                    
                                    value += signed ? -0.5 : 0.5
                                    
                                case .float:
                                    
                                    var bitPattern: UInt64 = 0
                                    
                                    for offset in 0..<bytesPerChannel {
                                        bitPattern = (bitPattern << 8) | UInt64(channelByte(offset))
                                    }
                                    
                                    switch channel.bitRange.count {
                                    case 32: value = Double(Float(bitPattern: UInt32(truncatingIfNeeded: bitPattern)))
                                    case 64: value = Double(bitPattern: bitPattern)
                                    default: break
                                    }
                                }
                                
                                if !value.isNormal && !value.isSubnormal && !value.isZero {
                                    value = 0
                                }
                                
                                pixel.setNormalizedComponent(channel.index, value)
                            }
                            
                            if isOpaque {
                                pixel.opacity = 1
                            }
                            
                            _destination.pointee = pixel
                            
                            _bitsOffset += bitmap.bitsPerPixel
                            _destination += 1
                        }
                        
                        bitsOffset += bitmap.bitsPerRow
                        destination += width
                    }
                }
            }
            
            if premultiplied {
                
                var destination = destination
                
                for _ in 0..<width * height {
                    
                    var pixel = destination.pointee
                    
                    let opacity = pixel.opacity
                    
                    if opacity != 0 {
                        pixel.color /= opacity
                    }
                    
                    destination += 1
                }
            }
            
        }
        
    }
    
}

extension AnyImage {
    
    @inlinable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool = false) {
        self.init(base: colorSpace._base._create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked))
    }
}

