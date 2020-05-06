//
//  _aligned_float_channel.swift
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
    mutating func _decode_aligned_channel<T: BinaryFloatingPoint & RawBitPattern, R: BinaryFloatingPoint>(_ bitmap: RawBitmap, _ channel_idx: Int, _ is_opaque: Bool, _: T.Type, _ : R.Type) {
        
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
                
                data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    
                    guard var source = bytes.baseAddress else { return }
                    var destination = dest
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
    
}
