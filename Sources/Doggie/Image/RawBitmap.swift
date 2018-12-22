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

extension AnyImage {
    
    @inlinable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool = false) {
        self.init(base: colorSpace._base._create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked))
    }
}

public struct RawBitmap {
    
    public let bitsPerPixel: Int
    public let bytesPerRow: Int
    public let startsRow: Int
    
    public let tiff_predictor: Int
    
    public let channels: [Channel]
    
    public let data: Data
    
    public init(bitsPerPixel: Int, bytesPerRow: Int, startsRow: Int, tiff_predictor: Int = 1, channels: [Channel], data: Data) {
        precondition(channels.allSatisfy({ 0...bitsPerPixel ~= $0.bitRange.lowerBound && 0...bitsPerPixel ~= $0.bitRange.upperBound }), "Invalid channel bitRange.")
        self.bitsPerPixel = bitsPerPixel
        self.bytesPerRow = bytesPerRow
        self.startsRow = startsRow
        self.tiff_predictor = tiff_predictor
        self.channels = channels
        self.data = data
    }
}

extension RawBitmap {
    
    public struct Channel {
        
        public let index: Int
        
        public let format: Format
        public let endianness: Endianness
        
        public let bitRange: Range<Int>
        
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

@usableFromInline
protocol RawBitmapFloatingPoint : BinaryFloatingPoint {
    
    associatedtype BitPattern : FixedWidthInteger
    
    var bitPattern: BitPattern { get }
    
    init(bitPattern: BitPattern)
    
}

extension Float : RawBitmapFloatingPoint {
    
}

extension Double : RawBitmapFloatingPoint {
    
}

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _read_aligned_pixels<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _ : T.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        
        self.withUnsafeMutableBytes {
            
            guard var dest = $0.baseAddress?.bindMemory(to: T.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            bitmap.channels.withUnsafeBufferPointer { channels in
                
                let row = Pixel.numberOfComponents * width
                
                dest += bitmap.startsRow * row
                
                var data = bitmap.data
                
                for _ in bitmap.startsRow..<height {
                    
                    let _length = min(bitmap.bytesPerRow, data.count)
                    guard _length != 0 else { return }
                    
                    data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
                        
                        var destination = dest
                        var source = UnsafeRawPointer(bytes)
                        let source_end = source + _length
                        
                        for _ in 0..<width {
                            
                            guard source + bytesPerPixel <= source_end else { return }
                            
                            for channel in channels {
                                
                                let byteOffset = channel.bitRange.lowerBound >> 3
                                
                                let _destination = destination + channel.index
                                let _source = source + byteOffset
                                
                                switch channel.endianness {
                                case .big: _destination.pointee = T(bigEndian: _source.bindMemory(to: T.self, capacity: 1).pointee)
                                case .little: _destination.pointee = T(littleEndian: _source.bindMemory(to: T.self, capacity: 1).pointee)
                                }
                                
                                switch bitmap.tiff_predictor {
                                case 1: break
                                case 2:
                                    if destination > dest {
                                        let lhs = _destination - Pixel.numberOfComponents
                                        _destination.pointee &+= lhs.pointee
                                    }
                                default: fatalError("Unsupported tiff predictor.")
                                }
                            }
                            
                            source += bytesPerPixel
                            
                            if is_opaque {
                                destination[Pixel.numberOfComponents - 1] = T.max
                            }
                            
                            destination += Pixel.numberOfComponents
                        }
                        
                        dest += row
                    }
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    mutating func _read_aligned_pixels<T: FixedWidthInteger, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        
        let channel = bitmap.channels[channel_idx]
        let byteOffset = channel.bitRange.lowerBound >> 3
        
        @inline(__always)
        func _denormalized(_ value: R) -> R {
            guard channel.index < Pixel.Model.numberOfComponents else { return value }
            let range = Pixel.Model.rangeOfComponent(channel.index)
            return value * R(range.upperBound - range.lowerBound) + R(range.lowerBound)
        }
        
        self.withUnsafeMutableBytes {
            
            guard var dest = $0.baseAddress?.bindMemory(to: R.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            let row = Pixel.numberOfComponents * width
            
            dest += bitmap.startsRow * row
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
                    
                    var destination = dest
                    var source = UnsafeRawPointer(bytes)
                    let source_end = source + _length
                    
                    var tiff_predictor_record: T = 0
                    
                    for _ in 0..<width {
                        
                        guard source + bytesPerPixel <= source_end else { return }
                        
                        let _destination = destination + channel.index
                        let _source = source + byteOffset
                        
                        let _s: T
                        let _d: T
                        
                        switch channel.endianness {
                        case .big: _s = T(bigEndian: _source.bindMemory(to: T.self, capacity: 1).pointee)
                        case .little: _s = T(littleEndian: _source.bindMemory(to: T.self, capacity: 1).pointee)
                        }
                        
                        switch bitmap.tiff_predictor {
                        case 1: _d = _s
                        case 2: _d = _s &+ tiff_predictor_record
                        default: fatalError("Unsupported tiff predictor.")
                        }
                        
                        if T.isSigned {
                            _destination.pointee = _denormalized((R(_d) - R(T.min)) / (R(T.max) - R(T.min)))
                        } else {
                            _destination.pointee = _denormalized(R(_d) / R(T.max))
                        }
                        
                        tiff_predictor_record = _d
                        
                        source += bytesPerPixel
                        
                        if is_opaque {
                            destination[Pixel.numberOfComponents - 1] = 1
                        }
                        
                        destination += Pixel.numberOfComponents
                    }
                    
                    dest += row
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    mutating func _read_aligned_pixels<T: RawBitmapFloatingPoint, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        
        let channel = bitmap.channels[channel_idx]
        let byteOffset = channel.bitRange.lowerBound >> 3
        
        @inline(__always)
        func _denormalized(_ value: R) -> R {
            guard channel.index < Pixel.Model.numberOfComponents else { return value }
            let range = Pixel.Model.rangeOfComponent(channel.index)
            return value * R(range.upperBound - range.lowerBound) + R(range.lowerBound)
        }
        
        self.withUnsafeMutableBytes {
            
            guard var dest = $0.baseAddress?.bindMemory(to: R.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            let row = Pixel.numberOfComponents * width
            
            dest += bitmap.startsRow * row
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
                    
                    var destination = dest
                    var source = UnsafeRawPointer(bytes)
                    let source_end = source + _length
                    
                    for _ in 0..<width {
                        
                        guard source + bytesPerPixel <= source_end else { return }
                        
                        let _destination = destination + channel.index
                        let _source = source + byteOffset
                        
                        switch channel.endianness {
                        case .big: _destination.pointee = _denormalized(R(T(bitPattern: T.BitPattern(bigEndian: _source.bindMemory(to: T.BitPattern.self, capacity: 1).pointee))))
                        case .little: _destination.pointee = _denormalized(R(T(bitPattern: T.BitPattern(littleEndian: _source.bindMemory(to: T.BitPattern.self, capacity: 1).pointee))))
                        }
                        
                        source += bytesPerPixel
                        
                        if is_opaque {
                            destination[Pixel.numberOfComponents - 1] = 1
                        }
                        
                        destination += Pixel.numberOfComponents
                    }
                    
                    dest += row
                }
            }
        }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _decode_premultiplied() {
        
        let width = self.width
        let height = self.height
        
        self.withUnsafeMutableBufferPointer {
            
            guard var destination = $0.baseAddress else { return }
            
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

extension ColorSpace {
    
    @inlinable
    @inline(__always)
    func _create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> AnyImageBaseProtocol {
        
        let numberOfComponents = self.numberOfComponents
        let is_opaque = !bitmaps.contains { $0.channels.contains { $0.index == numberOfComponents } }
        
        precondition(bitmaps.allSatisfy({ $0.channels.allSatisfy { 0...numberOfComponents ~= $0.index } }), "Invalid channel index.")
        
        if bitmaps.allSatisfy({ $0.bitsPerPixel & 7 == 0 && $0.channels.allSatisfy { $0.bitRange.lowerBound & 7 == 0 } }) {
            
            switch self {
            case let colorSpace as ColorSpace<GrayColorModel>:
                
                if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 8 && $0.format == .unsigned } }) {
                    
                    var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        image._read_aligned_pixels(bitmap, is_opaque, UInt8.self)
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
                if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 16 && $0.format == .unsigned } }) {
                    
                    var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        image._read_aligned_pixels(bitmap, is_opaque, UInt16.self)
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
            case let colorSpace as ColorSpace<RGBColorModel>:
                
                if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 8 && $0.format == .unsigned } }) {
                    
                    var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        image._read_aligned_pixels(bitmap, is_opaque, UInt8.self)
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
                if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 16 && $0.format == .unsigned } }) {
                    
                    var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                    
                    for bitmap in bitmaps {
                        image._read_aligned_pixels(bitmap, is_opaque, UInt16.self)
                    }
                    
                    if premultiplied {
                        image._decode_premultiplied()
                    }
                    
                    return image
                }
                
            default: break
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 8 || $0.bitRange.count == 16 || ($0.bitRange.count == 32 && $0.format == .float) } }) {
                
                var image = Image<FloatColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    for (channel_idx, channel) in bitmap.channels.enumerated() {
                        switch (channel.bitRange.count, channel.format) {
                        case (8, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt8.self, Float.self)
                        case (8, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int8.self, Float.self)
                        case (16, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt16.self, Float.self)
                        case (16, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int16.self, Float.self)
                        case (32, .float): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Float.self, Float.self)
                        default: break
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count == 8 || $0.bitRange.count == 16 || $0.bitRange.count == 32 || $0.bitRange.count == 64 } }) {
                
                var image = Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    for (channel_idx, channel) in bitmap.channels.enumerated() {
                        switch (channel.bitRange.count, channel.format) {
                        case (8, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt8.self, Double.self)
                        case (8, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int8.self, Double.self)
                        case (16, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt16.self, Double.self)
                        case (16, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int16.self, Double.self)
                        case (32, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt32.self, Double.self)
                        case (32, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int32.self, Double.self)
                        case (32, .float): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Float.self, Double.self)
                        case (64, .unsigned): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, UInt64.self, Double.self)
                        case (64, .signed): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Int64.self, Double.self)
                        case (64, .float): image._read_aligned_pixels(bitmap, channel_idx, is_opaque, Double.self, Double.self)
                        default: break
                        }
                    }
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
        }
        
        switch self {
        case let colorSpace as ColorSpace<GrayColorModel>:
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 8 && $0.format == .unsigned } }) {
                
                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {
                
                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        case let colorSpace as ColorSpace<RGBColorModel>:
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 8 && $0.format == .unsigned } }) {
                
                var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {
                
                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
            }
            
        default: break
        }
        
        if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 23 || ($0.bitRange.count == 32 && $0.format == .float) } }) {
            
            var image = Image<FloatColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
            
            for bitmap in bitmaps {
                for (channel_idx, channel) in bitmap.channels.enumerated() {
                    
                }
            }
            
            if premultiplied {
                image._decode_premultiplied()
            }
            
            return image
        }
        
        var image = Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
        
        for bitmap in bitmaps {
            for (channel_idx, channel) in bitmap.channels.enumerated() {
                
            }
        }
        
        if premultiplied {
            image._decode_premultiplied()
        }
        
        return image
    }
}
