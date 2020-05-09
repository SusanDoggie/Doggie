//
//  _channel_to_double.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _decode_channel_to_double(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool) {
        
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
        
        self.withUnsafeMutableTypePunnedBufferPointer(to: Double.self) {
            
            guard var dest = $0.baseAddress else { return }
            
            let row = Pixel.numberOfComponents * width
            
            dest += bitmap.startsRow * row
            
            var data = bitmap.data
            
            var tiff_predictor_record: [UInt8] = Array(repeating: 0, count: bytesPerChannel + (channel.bitRange.count & 7 == 0 ? 0 : 1))
            
            tiff_predictor_record.withUnsafeMutableBufferPointer { tiff_predictor_record in
                
                for _ in bitmap.startsRow..<height {
                    
                    let _length = min(bitmap.bytesPerRow, data.count)
                    guard _length != 0 else { return }
                    
                    data.popFirst(bitmap.bytesPerRow).withUnsafeBufferPointer { _source in
                        
                        guard let source = _source.baseAddress else { return }
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
