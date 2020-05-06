//
//  _unsigned_pixel.swift
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
    mutating func _decode_unsigned_pixel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _: T.Type) {
        
        if bitmap.bitsPerPixel % 8 == 0 && bitmap.endianness == .big && bitmap.channels.allSatisfy({ $0.bitRange.lowerBound % 8 == 0 && $0.bitRange.count == T.bitWidth }) {
            self._decode_unsigned_aligned_pixel(bitmap, is_opaque, T.self)
        } else {
            for (channel_idx, channel) in bitmap.channels.enumerated() {
                if bitmap.bitsPerPixel % 8 == 0 && bitmap.endianness == .big && channel.bitRange.lowerBound % 8 == 0 && channel.bitRange.count == T.bitWidth {
                    self._decode_unsigned_aligned_channel(bitmap, channel_idx, is_opaque, T.self)
                } else {
                    self._decode_unsigned_channel(bitmap, channel_idx, is_opaque, T.self)
                }
            }
        }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _decode_unsigned_aligned_pixel<T: FixedWidthInteger & UnsignedInteger>(_ bitmap: RawBitmap, _ is_opaque: Bool, _: T.Type) {
        
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
                    
                    data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                        
                        guard var source = bytes.baseAddress else { return }
                        var destination = dest
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
    
}
