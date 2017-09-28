//
//  RawBitmap.swift
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

extension ColorPixelProtocol {
    
    @_versioned
    @_inlineable
    func premultipliedNormalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            let range = Model.rangeOfComponent(index)
            return (self.color[index] * self.opacity - range.lowerBound) / (range.upperBound - range.lowerBound)
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
}

public struct RawBitmap {
    
    public var bitsPerPixel: Int
    public var bitsPerRow: Int
    public var startsRow: Int
    
    public var endianness: Endianness
    
    public var channels: [Channel]
    
    public var data: Data
    
    public init(bitsPerPixel: Int, bitsPerRow: Int, startsRow: Int, endianness: Endianness, channels: [Channel], data: Data) {
        if endianness == .little {
            precondition(bitsPerPixel % 8 == 0, "Unsupported bitsPerPixel with little-endian.")
        }
        self.bitsPerPixel = bitsPerPixel
        self.bitsPerRow = bitsPerRow
        self.startsRow = startsRow
        self.endianness = endianness
        self.channels = channels
        self.data = data
    }
}

extension RawBitmap {
    
    public struct Channel {
        
        public var index: Int
        
        public var format: Format
        public var endianness: Endianness
        
        public var bitRange: CountableRange<Int>
        
        public init(index: Int, format: Format, endianness: Endianness, bitRange: CountableRange<Int>) {
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
    
    public enum AlphaChannelFormat {
        
        case none
        case last
        case first
        case premultipliedLast
        case premultipliedFirst
    }
}

extension Image {
    
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, bitmaps: [RawBitmap], premultiplied: Bool, option: MappedBufferOption = .default) {
        
        self.init(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
        
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
                                switch bitmap.endianness {
                                case .big: return pixelShift == 0 ? source[i] : (source[i] << pixelShift) | (source[i + 1] >> (8 - pixelShift))
                                case .little: return source[bytesPerPixel - i - 1]
                                }
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
                                    
                                    if channel.bitRange.count > 64 {
                                        for (i, slice) in channel.bitRange.slice(by: 8).enumerated() {
                                            value = Double(sign: value.sign, exponentBitPattern: value.exponentBitPattern + UInt(slice.count), significandBitPattern: value.significandBitPattern) + Double(channelByte(i) & UInt8((1 << slice.count) - 1))
                                        }
                                    } else {
                                        var bitPattern: UInt64 = 0
                                        for (i, slice) in channel.bitRange.slice(by: 8).enumerated() {
                                            bitPattern = (bitPattern << slice.count) | UInt64(channelByte(i))
                                        }
                                        value = Double(bitPattern)
                                    }
                                    
                                    value /= Double(sign: .plus, exponent: channel.bitRange.count, significand: 1) - 1
                                    
                                case .signed:
                                    
                                    var signed = false
                                    
                                    if channel.bitRange.count > 64 {
                                        for (i, slice) in channel.bitRange.slice(by: 8).enumerated() {
                                            let byte = channelByte(i)
                                            if i == 0 && byte & 0x80 != 0 {
                                                signed = true
                                            }
                                            value = Double(sign: value.sign, exponentBitPattern: value.exponentBitPattern + UInt(slice.count), significandBitPattern: value.significandBitPattern) + Double(byte & UInt8((1 << slice.count) - 1))
                                        }
                                    } else {
                                        var bitPattern: UInt64 = 0
                                        for (i, slice) in channel.bitRange.slice(by: 8).enumerated() {
                                            let byte = channelByte(i)
                                            if i == 0 && byte & 0x80 != 0 {
                                                signed = true
                                            }
                                            bitPattern = (bitPattern << slice.count) | UInt64(byte)
                                        }
                                        value = Double(bitPattern)
                                    }
                                    
                                    value = Double(sign: value.sign, exponentBitPattern: value.exponentBitPattern - UInt(channel.bitRange.count), significandBitPattern: value.significandBitPattern)
                                    
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
    
    public func rawData(format: RawBitmap.Format, bitsPerChannel: Int, bitsPerPixel: Int, bytesPerRow: Int, alphaChannel: RawBitmap.AlphaChannelFormat, channelEndianness: RawBitmap.Endianness, pixelEndianness: RawBitmap.Endianness, separated: Bool) -> [Data] {
        
        if channelEndianness == .little {
            precondition(bitsPerChannel % 8 == 0, "Unsupported bitsPerChannel with little-endian.")
        }
        if pixelEndianness == .little {
            precondition(bitsPerPixel % 8 == 0, "Unsupported bitsPerPixel with little-endian.")
        }
        if format == .float {
            precondition(bitsPerChannel == 32 || bitsPerChannel == 64, "Only supported Float32 or Float64.")
        }
        precondition(bitsPerChannel == 8 || bitsPerChannel == 16 || bitsPerChannel == 32, "Only supported 8, 16 or 32 bits.")
        
        let numberOfComponents = alphaChannel == .none ? Pixel.Model.numberOfComponents : Pixel.Model.numberOfComponents + 1
        let bitsPerRow = separated ? width * bitsPerChannel : width * bitsPerChannel * numberOfComponents
        
        let padding = bytesPerRow - (bitsPerRow + 7) >> 3
        
        let premultiplied = alphaChannel == .premultipliedFirst || alphaChannel == .premultipliedLast
        let alphaFirst = alphaChannel == .first || alphaChannel == .premultipliedFirst
        let alphaLast = alphaChannel == .last || alphaChannel == .premultipliedLast
        
        precondition(padding >= 0, "Invalid bytesPerRow.")

        var data = [Data]()
        
        @inline(__always)
        func encode(_ value: Double, _ data: inout Data) {
            switch format {
            case .unsigned:
                
                switch bitsPerChannel {
                case 8:
                    let value = UInt8((value * 255).clamped(to: 0...255).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                case 16:
                    let value = UInt16((value * 65535).clamped(to: 0...65535).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                case 32:
                    let value = UInt32((value * 4294967295).clamped(to: 0...4294967295).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                default: fatalError()
                }
                
            case .signed:
                
                switch bitsPerChannel {
                case 8:
                    let value = Int8((value * 255 - 128).clamped(to: -128...127).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                case 16:
                    let value = Int16((value * 65535 - 32768).clamped(to: -32768...32767).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                case 32:
                    let value = Int32((value * 4294967295 - 2147483648).clamped(to: -2147483648...2147483647).rounded())
                    switch channelEndianness {
                    case .big: data.encode(value.bigEndian)
                    case .little: data.encode(value.littleEndian)
                    }
                default: fatalError()
                }
                
            case .float:
                switch bitsPerChannel {
                case 32:
                    switch channelEndianness {
                    case .big: data.encode(Float(value).clamped(to: 0...1).bitPattern.bigEndian)
                    case .little: data.encode(Float(value).clamped(to: 0...1).bitPattern.littleEndian)
                    }
                case 64:
                    switch channelEndianness {
                    case .big: data.encode(value.clamped(to: 0...1).bitPattern.bigEndian)
                    case .little: data.encode(value.clamped(to: 0...1).bitPattern.littleEndian)
                    }
                default: fatalError()
                }
            }
        }
        
        @inline(__always)
        func swapPixel(_ data: inout Data) {
            
            data.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt8>) in
                
                let bytesPerPixel = bitsPerPixel >> 3
                var buffer = buffer
                
                for _ in 0..<height {
                    
                    var _buffer = buffer
                    
                    for _ in 0..<width {
                        for i in 0..<bytesPerPixel >> 1 {
                            swap(&buffer[i], &buffer[bytesPerPixel - i - 1])
                        }
                        _buffer += bytesPerPixel
                    }
                    
                    buffer += bytesPerRow
                }
            }
        }
        
        self.withUnsafeBufferPointer {
            
            guard let source = $0.baseAddress else { return }
            
            if separated {
                
                if alphaFirst {
                    
                    var _data = Data(capacity: bytesPerRow * height)
                    
                    var source = source
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            encode(source.pointee.opacity, &_data)
                            source += 1
                        }
                        _data.count += padding
                    }
                    if pixelEndianness == .little {
                        swapPixel(&_data)
                    }
                    
                    data.append(_data)
                }
                
                for i in 0..<Pixel.Model.numberOfComponents {
                    
                    var _data = Data(capacity: bytesPerRow * height)
                    
                    var source = source
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            encode(premultiplied ? source.pointee.normalizedComponent(i) : source.pointee.premultipliedNormalizedComponent(i), &_data)
                            source += 1
                        }
                        _data.count += padding
                    }
                    if pixelEndianness == .little {
                        swapPixel(&_data)
                    }
                    
                    data.append(_data)
                }
                
                if alphaLast {
                    
                    var _data = Data(capacity: bytesPerRow * height)
                    
                    var source = source
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            encode(source.pointee.opacity, &_data)
                            source += 1
                        }
                        _data.count += padding
                    }
                    if pixelEndianness == .little {
                        swapPixel(&_data)
                    }
                    
                    data.append(_data)
                }
                
            } else {
                
                var _data = Data(capacity: bytesPerRow * height)
                
                var source = source
                
                if alphaFirst {
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            for i in 0..<Pixel.Model.numberOfComponents + 1 {
                                if i == 0 {
                                    encode(source.pointee.opacity, &_data)
                                } else {
                                    encode(premultiplied ? source.pointee.normalizedComponent(i - 1) : source.pointee.premultipliedNormalizedComponent(i - 1), &_data)
                                }
                            }
                            source += 1
                        }
                        _data.count += padding
                    }
                    
                } else if alphaLast {
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            for i in 0..<Pixel.Model.numberOfComponents + 1 {
                                if i == Pixel.Model.numberOfComponents {
                                    encode(source.pointee.opacity, &_data)
                                } else {
                                    encode(premultiplied ? source.pointee.normalizedComponent(i) : source.pointee.premultipliedNormalizedComponent(i), &_data)
                                }
                            }
                            source += 1
                        }
                        _data.count += padding
                    }
                    
                } else {
                    
                    for _ in 0..<height {
                        for _ in 0..<width {
                            for i in 0..<Pixel.Model.numberOfComponents {
                                encode(premultiplied ? source.pointee.normalizedComponent(i) : source.pointee.premultipliedNormalizedComponent(i), &_data)
                            }
                            source += 1
                        }
                        _data.count += padding
                    }
                }
                if pixelEndianness == .little {
                    swapPixel(&_data)
                }
                
                data.append(_data)
            }
            
        }
        
        return data
    }
    
}

extension AnyImage {
    
    @_inlineable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, bitmaps: [RawBitmap], premultiplied: Bool, option: MappedBufferOption = .default) {
        self.init(base: colorSpace._base._createImage(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, option: option))
    }
    
    @_inlineable
    public func rawData(format: RawBitmap.Format, bitsPerChannel: Int, bitsPerPixel: Int, bytesPerRow: Int, alphaChannel: RawBitmap.AlphaChannelFormat, channelEndianness: RawBitmap.Endianness, pixelEndianness: RawBitmap.Endianness, separated: Bool) -> [Data] {
        return _base.rawData(format: format, bitsPerChannel: bitsPerChannel, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, alphaChannel: alphaChannel, channelEndianness: channelEndianness, pixelEndianness: pixelEndianness, separated: separated)
    }
}

