//
//  RawBitmap.swift
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

extension AnyImage {

    @inlinable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool = false) {
        self.init(base: colorSpace._base._create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked))
    }
}

public struct RawBitmap {

    public let bitsPerPixel: Int
    public let bytesPerRow: Int

    public let endianness: Endianness
    public let startsRow: Int

    public let tiff_predictor: Int

    public let channels: [Channel]

    public let data: Data

    public init(bitsPerPixel: Int, bytesPerRow: Int, endianness: Endianness = .big, startsRow: Int = 0, tiff_predictor: Int = 1, channels: [Channel], data: Data) {

        precondition(channels.allSatisfy({ 0...bitsPerPixel ~= $0.bitRange.lowerBound && 0...bitsPerPixel ~= $0.bitRange.upperBound }), "Invalid channel bitRange.")

        if endianness == .little {

            precondition(bitsPerPixel % 8 == 0, "Unsupported bitsPerPixel with little-endian.")

            if channels.allSatisfy({ $0.bitRange.lowerBound % 8 == 0 && $0.bitRange.upperBound % 8 == 0 }) {

                self.endianness = .big
                self.channels = channels.map { RawBitmap.Channel(index: $0.index, format: $0.format, endianness: $0.endianness == .big ? .little : .big, bitRange: bitsPerPixel - $0.bitRange.upperBound..<bitsPerPixel - $0.bitRange.lowerBound) }

            } else {

                self.endianness = .little
                self.channels = channels
            }

        } else {
            self.endianness = .big
            self.channels = channels
        }

        self.bitsPerPixel = bitsPerPixel
        self.bytesPerRow = bytesPerRow
        self.startsRow = startsRow
        self.tiff_predictor = tiff_predictor
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

extension Image {

    @inlinable
    @inline(__always)
    static func _denormalized<T: BinaryFloatingPoint>(_ channel_index: Int, _ value: T) -> T {
        guard channel_index < Pixel.Model.numberOfComponents else { return value }
        let range = Pixel.Model.rangeOfComponent(channel_index)
        return value * T(range.upperBound - range.lowerBound) + T(range.lowerBound)
    }

    @inlinable
    @inline(__always)
    mutating func _read_unsigned_aligned_pixel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _ : T.Type) {

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
    mutating func _read_unsigned_aligned_channel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let bytesPerPixel = bitmap.bitsPerPixel >> 3

        let channel = bitmap.channels[channel_idx]
        let byteOffset = channel.bitRange.lowerBound >> 3

        self.withUnsafeMutableBytes {

            guard var dest = $0.baseAddress?.bindMemory(to: T.self, capacity: Pixel.numberOfComponents * $0.count) else { return }

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

                        _destination.pointee = _d

                        tiff_predictor_record = _d

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

    @inlinable
    @inline(__always)
    mutating func _read_aligned_channel<T: FixedWidthInteger, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let bytesPerPixel = bitmap.bitsPerPixel >> 3

        let channel = bitmap.channels[channel_idx]
        let channel_max: R = scalbn(1, T.bitWidth) - 1
        let byteOffset = channel.bitRange.lowerBound >> 3

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
                            _destination.pointee = Image._denormalized(channel.index, R(UInt64(bitPattern: Int64(_d) &- Int64(T.min))) / channel_max)
                        } else {
                            _destination.pointee = Image._denormalized(channel.index, R(_d) / channel_max)
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
    mutating func _read_aligned_channel<T: BinaryFloatingPoint & RawBitPattern, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type, _ : R.Type) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let bytesPerPixel = bitmap.bitsPerPixel >> 3

        let channel = bitmap.channels[channel_idx]
        let byteOffset = channel.bitRange.lowerBound >> 3

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
                        case .big: _destination.pointee = Image._denormalized(channel.index, R(T(bitPattern: T.BitPattern(bigEndian: _source.bindMemory(to: T.BitPattern.self, capacity: 1).pointee))))
                        case .little: _destination.pointee = Image._denormalized(channel.index, R(T(bitPattern: T.BitPattern(littleEndian: _source.bindMemory(to: T.BitPattern.self, capacity: 1).pointee))))
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

    @inlinable
    @inline(__always)
    mutating func _read_unsigned_channel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let channel = bitmap.channels[channel_idx]
        let channel_max: T = (1 << channel.bitRange.count) &- 1

        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        let bytesPerChannel = channel.bitRange.count >> 3
        let channelBytesOffset = channel.bitRange.lowerBound >> 3
        let channelBitsShift = channel.bitRange.lowerBound & 7

        let _slices: LazySliceSequence = channel.bitRange.lazy.slice(by: 8)

        @inline(__always)
        func read_pixel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int) -> UInt8 {
            switch bitmap.endianness {
            case .big: return offset == 0 ? source[i] : (source[i] << offset) | (source[i + 1] >> (8 - offset))
            case .little: return source[bytesPerPixel - i - 1]
            }
        }

        @inline(__always)
        func read_channel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int, _ bits_count: Int) -> UInt8 {
            switch channel.endianness {
            case .big: return channelBitsShift + bits_count <= 8 ? read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift : (read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift) | (read_pixel(source, offset, i + 1 + channelBytesOffset) >> (8 - channelBitsShift))
            case .little: return read_pixel(source, offset, bytesPerChannel - i - 1 + channelBytesOffset)
            }
        }

        self.withUnsafeMutableBytes {

            guard var dest = $0.baseAddress?.bindMemory(to: T.self, capacity: Pixel.numberOfComponents * $0.count) else { return }

            let row = Pixel.numberOfComponents * width

            dest += bitmap.startsRow * row

            var data = bitmap.data

            for _ in bitmap.startsRow..<height {

                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }

                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<UInt8>) in

                    var destination = dest
                    let dataBitSize = _length << 3

                    var _bitsOffset = 0

                    var tiff_predictor_record: T = 0

                    for _ in 0..<width {

                        guard _bitsOffset + bitmap.bitsPerPixel <= dataBitSize else { return }

                        let _destination = destination + channel.index

                        var bitPattern: T = 0
                        for (i, slice) in _slices.enumerated() {
                            var byte = read_channel(source + _bitsOffset >> 3, _bitsOffset & 7, i, slice.count)
                            if slice.count != 8 {
                                byte >>= 8 - slice.count
                            }
                            bitPattern = (bitPattern << slice.count) | T(byte)
                        }

                        let _d: T

                        switch bitmap.tiff_predictor {
                        case 1: _d = bitPattern
                        case 2: _d = bitPattern &+ tiff_predictor_record
                        default: fatalError("Unsupported tiff predictor.")
                        }

                        _destination.pointee = _scale_integer(_d & channel_max, channel_max, T.max)

                        tiff_predictor_record = _d

                        if is_opaque {
                            destination[Pixel.numberOfComponents - 1] = T.max
                        }

                        destination += Pixel.numberOfComponents
                        _bitsOffset += bitmap.bitsPerPixel
                    }

                    dest += row
                }
            }
        }
    }

    @inlinable
    @inline(__always)
    mutating func _read_channel<T: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _ : T.Type) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let channel = bitmap.channels[channel_idx]
        let channel_max: T = scalbn(1, channel.bitRange.count) - 1

        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        let bytesPerChannel = channel.bitRange.count >> 3
        let channelBytesOffset = channel.bitRange.lowerBound >> 3
        let channelBitsShift = channel.bitRange.lowerBound & 7

        let _slices: LazySliceSequence = channel.bitRange.lazy.slice(by: 8)

        let _base = (1 as UInt64) << (channel.bitRange.count - 1)
        let _mask = ((1 as UInt64) << channel.bitRange.count) &- 1

        @inline(__always)
        func read_pixel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int) -> UInt8 {
            switch bitmap.endianness {
            case .big: return offset == 0 ? source[i] : (source[i] << offset) | (source[i + 1] >> (8 - offset))
            case .little: return source[bytesPerPixel - i - 1]
            }
        }

        @inline(__always)
        func read_channel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int, _ bits_count: Int) -> UInt8 {
            switch channel.endianness {
            case .big: return channelBitsShift + bits_count <= 8 ? read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift : (read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift) | (read_pixel(source, offset, i + 1 + channelBytesOffset) >> (8 - channelBitsShift))
            case .little: return read_pixel(source, offset, bytesPerChannel - i - 1 + channelBytesOffset)
            }
        }

        self.withUnsafeMutableBytes {

            guard var dest = $0.baseAddress?.bindMemory(to: T.self, capacity: Pixel.numberOfComponents * $0.count) else { return }

            let row = Pixel.numberOfComponents * width

            dest += bitmap.startsRow * row

            var data = bitmap.data

            for _ in bitmap.startsRow..<height {

                let _length = min(bitmap.bytesPerRow, data.count)
                guard _length != 0 else { return }

                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<UInt8>) in

                    var destination = dest
                    let dataBitSize = _length << 3

                    var _bitsOffset = 0

                    var tiff_predictor_record: UInt64 = 0

                    for _ in 0..<width {

                        guard _bitsOffset + bitmap.bitsPerPixel <= dataBitSize else { return }

                        let _destination = destination + channel.index

                        var bitPattern: UInt64 = 0
                        for (i, slice) in _slices.enumerated() {
                            var byte = read_channel(source + _bitsOffset >> 3, _bitsOffset & 7, i, slice.count)
                            if slice.count != 8 {
                                byte >>= 8 - slice.count
                            }
                            bitPattern = (bitPattern << slice.count) | UInt64(byte)
                        }

                        let _d: UInt64

                        switch bitmap.tiff_predictor {
                        case 1: _d = bitPattern
                        case 2: _d = bitPattern &+ tiff_predictor_record
                        default: fatalError("Unsupported tiff predictor.")
                        }

                        switch channel.format {
                        case .unsigned: _destination.pointee = Image._denormalized(channel.index, T(_d & _mask) / channel_max)
                        case .signed: _destination.pointee = Image._denormalized(channel.index, T((_d &+ _base) & _mask) / channel_max)
                        default: break
                        }

                        tiff_predictor_record = _d

                        if is_opaque {
                            destination[Pixel.numberOfComponents - 1] = 1
                        }

                        destination += Pixel.numberOfComponents
                        _bitsOffset += bitmap.bitsPerPixel
                    }

                    dest += row
                }
            }
        }
    }

    @inlinable
    @inline(__always)
    mutating func _read_channel_to_double(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool) {

        let width = self.width
        let height = self.height

        guard bitmap.startsRow < height else { return }

        let channel = bitmap.channels[channel_idx]

        let bytesPerPixel = bitmap.bitsPerPixel >> 3
        let bytesPerChannel = channel.bitRange.count >> 3
        let channelBytesOffset = channel.bitRange.lowerBound >> 3
        let channelBitsShift = channel.bitRange.lowerBound & 7

        @inline(__always)
        func read_pixel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int) -> UInt8 {
            switch bitmap.endianness {
            case .big: return offset == 0 ? source[i] : (source[i] << offset) | (source[i + 1] >> (8 - offset))
            case .little: return source[bytesPerPixel - i - 1]
            }
        }

        @inline(__always)
        func read_channel(_ source: UnsafePointer<UInt8>, _ offset: Int, _ i: Int, _ bits_count: Int) -> UInt8 {
            switch channel.endianness {
            case .big: return channelBitsShift + bits_count <= 8 ? read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift : (read_pixel(source, offset, i + channelBytesOffset) << channelBitsShift) | (read_pixel(source, offset, i + 1 + channelBytesOffset) >> (8 - channelBitsShift))
            case .little: return read_pixel(source, offset, bytesPerChannel - i - 1 + channelBytesOffset)
            }
        }

        self.withUnsafeMutableBytes {

            guard var dest = $0.baseAddress?.bindMemory(to: Double.self, capacity: Pixel.numberOfComponents * $0.count) else { return }

            let row = Pixel.numberOfComponents * width

            dest += bitmap.startsRow * row

            var data = bitmap.data

            var tiff_predictor_record: [UInt8] = Array(zeros: bytesPerChannel + (channel.bitRange.count & 7 == 0 ? 0 : 1))

            tiff_predictor_record.withUnsafeMutableBufferPointer { tiff_predictor_record in

                for _ in bitmap.startsRow..<height {

                    let _length = min(bitmap.bytesPerRow, data.count)
                    guard _length != 0 else { return }

                    data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (source: UnsafePointer<UInt8>) in

                        var destination = dest
                        let dataBitSize = _length << 3

                        var _bitsOffset = 0

                        if bitmap.tiff_predictor != 1 {
                            memset(tiff_predictor_record.baseAddress!, 0, tiff_predictor_record.count)
                        }

                        for _ in 0..<width {

                            guard _bitsOffset + bitmap.bitsPerPixel <= dataBitSize else { return }

                            let _destination = destination + channel.index

                            let _d: UInt64

                            switch bitmap.tiff_predictor {
                            case 1:

                                var bitPattern: UInt64 = 0
                                for i in 0..<8 {
                                    bitPattern = (bitPattern << 8) | UInt64(read_channel(source + _bitsOffset >> 3, _bitsOffset & 7, i, 8))
                                }

                                _d = bitPattern

                            case 2:

                                var overflow = false
                                for i in 0..<tiff_predictor_record.count {
                                    let byte: UInt8
                                    if i == 0 && channel.bitRange.count & 7 != 0 {
                                        let mask = ~((0xFF as UInt8) >> (channel.bitRange.count & 7))
                                        byte = read_channel(source + _bitsOffset >> 3, _bitsOffset & 7, tiff_predictor_record.count - i - 1, channel.bitRange.count & 7) & mask
                                    } else {
                                        byte = read_channel(source + _bitsOffset >> 3, _bitsOffset & 7, tiff_predictor_record.count - i - 1, 8)
                                    }
                                    if overflow {
                                        let (_add, _overflow) = tiff_predictor_record[i].addingReportingOverflow(1)
                                        (tiff_predictor_record[i], overflow) = _add.addingReportingOverflow(byte)
                                        overflow = _overflow || overflow
                                    } else {
                                        (tiff_predictor_record[i], overflow) = tiff_predictor_record[i].addingReportingOverflow(byte)
                                    }
                                }

                                var bitPattern: UInt64 = 0
                                for byte in tiff_predictor_record.reversed().prefix(8) {
                                    bitPattern = (bitPattern << 8) | UInt64(byte)
                                }

                                _d = bitPattern

                            default: fatalError("Unsupported tiff predictor.")
                            }

                            switch channel.format {
                            case .unsigned: _destination.pointee = Image._denormalized(channel.index, Double(_d) / Double(UInt64.max))
                            case .signed: _destination.pointee = Image._denormalized(channel.index, Double(UInt64(bitPattern: Int64(bitPattern: _d) &- Int64.min)) / Double(UInt64.max))
                            default: break
                            }

                            if is_opaque {
                                destination[Pixel.numberOfComponents - 1] = 1
                            }

                            destination += Pixel.numberOfComponents
                            _bitsOffset += bitmap.bitsPerPixel
                        }

                        dest += row
                    }
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

extension Image {

    @inlinable
    @inline(__always)
    mutating func _decode_unsigned_pixel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _ : T.Type) {

        if bitmap.bitsPerPixel % 8 == 0 && bitmap.endianness == .big && bitmap.channels.allSatisfy({ $0.bitRange.lowerBound % 8 == 0 && $0.bitRange.count == T.bitWidth }) {
            self._read_unsigned_aligned_pixel(bitmap, is_opaque, T.self)
        } else {
            for (channel_idx, channel) in bitmap.channels.enumerated() {
                if bitmap.bitsPerPixel % 8 == 0 && bitmap.endianness == .big && channel.bitRange.lowerBound % 8 == 0 && channel.bitRange.count == T.bitWidth {
                    self._read_unsigned_aligned_channel(bitmap, channel_idx, is_opaque, T.self)
                } else {
                    self._read_unsigned_channel(bitmap, channel_idx, is_opaque, T.self)
                }
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

        let premultiplied = premultiplied && !is_opaque

        precondition(bitmaps.allSatisfy { (($0.bitsPerPixel * width).align(8) >> 3) <= $0.bytesPerRow }, "Invalid bytesPerRow.")
        precondition(bitmaps.allSatisfy { $0.channels.allSatisfy { 0...numberOfComponents ~= $0.index } }, "Invalid channel index.")

        switch self {
        case let colorSpace as ColorSpace<GrayColorModel>:

            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 8 && $0.format == .unsigned } }) {

                var image = Image<Gray16ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)

                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt8.self)
                }

                if premultiplied {
                    image._decode_premultiplied()
                }

                return image
            }

            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {

                var image = Image<Gray32ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)

                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt16.self)
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
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt8.self)
                }

                if premultiplied {
                    image._decode_premultiplied()
                }

                return image
            }

            if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 16 && $0.format == .unsigned } }) {

                var image = Image<RGBA64ColorPixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)

                for bitmap in bitmaps {
                    image._decode_unsigned_pixel(bitmap, is_opaque, UInt16.self)
                }

                if premultiplied {
                    image._decode_premultiplied()
                }

                return image
            }

        default: break
        }

        if bitmaps.allSatisfy({ $0.channels.allSatisfy { $0.bitRange.count <= 23 || ($0.bitRange.count == 32 && $0.format == .float) } }) {

            var image = Image<Float32ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)

            for bitmap in bitmaps {
                for (channel_idx, channel) in bitmap.channels.enumerated() {
                    switch (bitmap.bitsPerPixel % 8, bitmap.endianness, channel.bitRange.lowerBound % 8, channel.bitRange.count, channel.format) {
                    case (0, .big, 0, 8, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt8.self, Float.self)
                    case (0, .big, 0, 8, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int8.self, Float.self)
                    case (0, .big, 0, 16, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt16.self, Float.self)
                    case (0, .big, 0, 16, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int16.self, Float.self)
                    case (0, .big, 0, 32, .float): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Float.self, Float.self)
                    default: image._read_channel(bitmap, channel_idx, is_opaque, Float.self)
                    }
                }
            }

            if premultiplied {
                image._decode_premultiplied()
            }

            return image
        }

        var image = Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)

        for bitmap in bitmaps {
            for (channel_idx, channel) in bitmap.channels.enumerated() {
                switch (bitmap.bitsPerPixel % 8, bitmap.endianness, channel.bitRange.lowerBound % 8, channel.bitRange.count, channel.format) {
                case (0, .big, 0, 8, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt8.self, Double.self)
                case (0, .big, 0, 8, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int8.self, Double.self)
                case (0, .big, 0, 16, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt16.self, Double.self)
                case (0, .big, 0, 16, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int16.self, Double.self)
                case (0, .big, 0, 32, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt32.self, Double.self)
                case (0, .big, 0, 32, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int32.self, Double.self)
                case (0, .big, 0, 32, .float): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Float.self, Double.self)
                case (0, .big, 0, 64, .unsigned): image._read_aligned_channel(bitmap, channel_idx, is_opaque, UInt64.self, Double.self)
                case (0, .big, 0, 64, .signed): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Int64.self, Double.self)
                case (0, .big, 0, 64, .float): image._read_aligned_channel(bitmap, channel_idx, is_opaque, Double.self, Double.self)
                default:
                    if channel.bitRange.count <= 64 {
                        image._read_channel(bitmap, channel_idx, is_opaque, Double.self)
                    } else {
                        image._read_channel_to_double(bitmap, channel_idx, is_opaque)
                    }
                }
            }
        }

        if premultiplied {
            image._decode_premultiplied()
        }

        return image
    }
}
