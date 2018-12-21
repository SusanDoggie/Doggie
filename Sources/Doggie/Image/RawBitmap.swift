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
        self.channels = channels.sorted { $0.bitRange.lowerBound }
        self.data = data
    }
    
    public var isCompact: Bool {
        return channels.first?.bitRange.lowerBound == 0
            && channels.last?.bitRange.upperBound == bitsPerPixel
            && zip(channels, channels.dropFirst()).allSatisfy { $0.bitRange.upperBound == $1.bitRange.lowerBound }
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
    mutating func _read_compact_pixels<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _ : T.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        self.withUnsafeMutableBytes {
            
            guard var destination = $0.baseAddress?.bindMemory(to: T.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            bitmap.channels.withUnsafeBufferPointer { channels in
                
                let row = Pixel.numberOfComponents * width
                
                destination += bitmap.startsRow * row
                
                var data = bitmap.data
                
                for _ in bitmap.startsRow..<height {
                    
                    guard data.count / MemoryLayout<T>.stride != 0 else { return }
                    let data_count = min(bitmap.bytesPerRow, data.count) / MemoryLayout<T>.stride
                    
                    data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<T>) in
                        
                        let source_end = source + data_count
                        
                        var _source = source
                        var _destination = destination
                        
                        for _ in 0..<width {
                            
                            for channel in channels {
                                
                                guard _source < source_end else { return }
                                
                                let __destination = _destination + channel.index
                                
                                switch channel.endianness {
                                case .big: __destination.pointee = T(bigEndian: _source.pointee)
                                case .little: __destination.pointee = T(littleEndian: _source.pointee)
                                }
                                
                                switch bitmap.tiff_predictor {
                                case 1: break
                                case 2:
                                    if _destination > destination {
                                        let lhs = __destination - Pixel.numberOfComponents
                                        __destination.pointee &+= lhs.pointee
                                    }
                                default: fatalError("Unsupported tiff predictor.")
                                }
                                
                                _source += 1
                            }
                            
                            if is_opaque {
                                _destination[Pixel.numberOfComponents - 1] = T.max
                            }
                            
                            _destination += Pixel.numberOfComponents
                        }
                        
                        destination += row
                    }
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    mutating func _read_compact_pixels<T: FixedWidthInteger, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let channel = bitmap.channels[channel_idx]
        let channel_count = bitmap.channels.count
        
        @inline(__always)
        func _denormalized(_ value: R) -> R {
            guard channel.index < Pixel.Model.numberOfComponents else { return value }
            let range = Pixel.Model.rangeOfComponent(channel.index)
            return value * R(range.upperBound - range.lowerBound) + R(range.lowerBound)
        }
        
        self.withUnsafeMutableBytes {
            
            guard var destination = $0.baseAddress?.bindMemory(to: R.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            let row = Pixel.numberOfComponents * width
            
            destination += bitmap.startsRow * row
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                guard data.count / MemoryLayout<T>.stride != 0 else { return }
                let data_count = min(bitmap.bytesPerRow, data.count) / MemoryLayout<T>.stride
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<T>) in
                    
                    let source_end = source + data_count
                    
                    var _source = source + channel_idx
                    var _destination = destination
                    
                    var tiff_predictor_record: T = 0
                    
                    for _ in 0..<width {
                        
                        guard _source < source_end else { return }
                        
                        let __destination = _destination + channel.index
                        
                        let _s: T
                        let _d: T
                        
                        switch channel.endianness {
                        case .big: _s = T(bigEndian: _source.pointee)
                        case .little: _s = T(littleEndian: _source.pointee)
                        }
                        
                        switch bitmap.tiff_predictor {
                        case 1: _d = _s
                        case 2: _d = _s &+ tiff_predictor_record
                        default: fatalError("Unsupported tiff predictor.")
                        }
                        
                        if T.isSigned {
                            __destination.pointee = _denormalized((R(_d) - R(T.min)) / (R(T.max) - R(T.min)))
                        } else {
                            __destination.pointee = _denormalized(R(_d) / R(T.max))
                        }
                        
                        tiff_predictor_record = _d
                        
                        _source += channel_count
                        
                        if is_opaque {
                            _destination[Pixel.numberOfComponents - 1] = 1
                        }
                        
                        _destination += Pixel.numberOfComponents
                    }
                    
                    destination += row
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    mutating func _read_compact_pixels<T: RawBitmapFloatingPoint, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {
        
        let width = self.width
        let height = self.height
        
        guard bitmap.startsRow < height else { return }
        
        let channel = bitmap.channels[channel_idx]
        let channel_count = bitmap.channels.count
        
        @inline(__always)
        func _denormalized(_ value: R) -> R {
            guard channel.index < Pixel.Model.numberOfComponents else { return value }
            let range = Pixel.Model.rangeOfComponent(channel.index)
            return value * R(range.upperBound - range.lowerBound) + R(range.lowerBound)
        }
        
        self.withUnsafeMutableBytes {
            
            guard var destination = $0.baseAddress?.bindMemory(to: R.self, capacity: Pixel.numberOfComponents * $0.count) else { return }
            
            let row = Pixel.numberOfComponents * width
            
            destination += bitmap.startsRow * row
            
            var data = bitmap.data
            
            for _ in bitmap.startsRow..<height {
                
                guard data.count / MemoryLayout<T.BitPattern>.stride != 0 else { return }
                let data_count = min(bitmap.bytesPerRow, data.count) / MemoryLayout<T.BitPattern>.stride
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<T.BitPattern>) in
                    
                    let source_end = source + data_count
                    
                    var _source = source + channel_idx
                    var _destination = destination
                    
                    for _ in 0..<width {
                        
                        guard _source < source_end else { return }
                        
                        let __destination = _destination + channel.index
                        
                        switch channel.endianness {
                        case .big: __destination.pointee = _denormalized(R(T(bitPattern: T.BitPattern(bigEndian: _source.pointee))))
                        case .little: __destination.pointee = _denormalized(R(T(bitPattern: T.BitPattern(littleEndian: _source.pointee))))
                        }
                        
                        _source += channel_count
                        
                        if is_opaque {
                            _destination[Pixel.numberOfComponents - 1] = 1
                        }
                        
                        _destination += Pixel.numberOfComponents
                    }
                    
                    destination += row
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
        
        switch self {
        case let colorSpace as ColorSpace<GrayColorModel>:
            
            if bitmaps.allSatisfy({ $0.bitsPerPixel == $0.channels.count * 8 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned } }) {
                
                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._read_compact_pixels(bitmap, is_opaque, UInt8.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
                
            } else if bitmaps.allSatisfy({ $0.bitsPerPixel == $0.channels.count * 16 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned } }) {
                
                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._read_compact_pixels(bitmap, is_opaque, UInt16.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
                
            }
            
        case let colorSpace as ColorSpace<RGBColorModel>:
            
            if bitmaps.allSatisfy({ $0.bitsPerPixel == $0.channels.count * 8 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned } }) {
                
                var image = Image<RGBA32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._read_compact_pixels(bitmap, is_opaque, UInt8.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
                
            } else if bitmaps.allSatisfy({ $0.bitsPerPixel == $0.channels.count * 16 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned } }) {
                
                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
                
                for bitmap in bitmaps {
                    image._read_compact_pixels(bitmap, is_opaque, UInt16.self)
                }
                
                if premultiplied {
                    image._decode_premultiplied()
                }
                
                return image
                
            }
            
        default: break
        }
        
        if bitmaps.allSatisfy({ ($0.bitsPerPixel == $0.channels.count * 8 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed }) ||
            ($0.bitsPerPixel == $0.channels.count * 16 && $0.isCompact && $0.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed }) ||
            ($0.bitsPerPixel == $0.channels.count * 32 && $0.isCompact && $0.channels.allSatisfy { $0.format == .float }) }) {
            
            var image = Image<FloatColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
            
            for bitmap in bitmaps {
                
                let bitsPerSample = bitmap.bitsPerPixel / bitmap.channels.count
                
                for (channel_idx, channel) in bitmap.channels.enumerated() {
                    switch (bitsPerSample, channel.format) {
                    case (8, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt8.self, Float.self)
                    case (8, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int8.self, Float.self)
                    case (16, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt16.self, Float.self)
                    case (16, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int16.self, Float.self)
                    case (32, .float): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Float.self, Float.self)
                    default: break
                    }
                }
            }
            
            if premultiplied {
                image._decode_premultiplied()
            }
            
            return image
            
        } else {
            
            var image = Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
            
            for bitmap in bitmaps {
                
                if (bitmap.bitsPerPixel == bitmap.channels.count * 8 && bitmap.isCompact && bitmap.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed }) ||
                    (bitmap.bitsPerPixel == bitmap.channels.count * 16 && bitmap.isCompact && bitmap.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed }) ||
                    (bitmap.bitsPerPixel == bitmap.channels.count * 32 && bitmap.isCompact && bitmap.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed || $0.format == .float }) ||
                    (bitmap.bitsPerPixel == bitmap.channels.count * 64 && bitmap.isCompact && bitmap.channels.allSatisfy { $0.format == .unsigned || $0.format == .signed || $0.format == .float }) {
                    
                    let bitsPerSample = bitmap.bitsPerPixel / bitmap.channels.count
                    
                    for (channel_idx, channel) in bitmap.channels.enumerated() {
                        switch (bitsPerSample, channel.format) {
                        case (8, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt8.self, Double.self)
                        case (8, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int8.self, Double.self)
                        case (16, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt16.self, Double.self)
                        case (16, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int16.self, Double.self)
                        case (32, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt32.self, Double.self)
                        case (32, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int32.self, Double.self)
                        case (32, .float): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Float.self, Double.self)
                        case (64, .unsigned): image._read_compact_pixels(bitmap, channel_idx, is_opaque, UInt64.self, Double.self)
                        case (64, .signed): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Int64.self, Double.self)
                        case (64, .float): image._read_compact_pixels(bitmap, channel_idx, is_opaque, Double.self, Double.self)
                        default: break
                        }
                    }
                    
                } else {
                    
                    for channel in bitmap.channels {
                        
                    }
                }
            }
            
            if premultiplied {
                image._decode_premultiplied()
            }
            
            return image
            
        }
    }
}
