//
//  _fast_decode_alpha_none.swift
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

@inlinable
@inline(__always)
func _fast_decode_alpha_none<T, P>(_ channels: [RawBitmap.Channel], _ is_opaque: Bool, _ format: RawBitmap.Format, _ endianness: RawBitmap.Endianness, _: T.Type, _ decode: (T) -> P.Scalar) -> Image<P>? where P: _FloatComponentPixel {
    
    let numberOfComponents = P.Model.numberOfComponents
    let bitsPerChannel = MemoryLayout<T>.stride << 3
    
    var alpha_none: [RawBitmap.Channel] = []
    for i in 0..<numberOfComponents {
        let lowerBound = i * bitsPerChannel
        let upperBound = lowerBound + bitsPerChannel
        alpha_none.append(RawBitmap.Channel(index: i, format: format, endianness: endianness, bitRange: lowerBound..<upperBound))
    }
    
    guard channels == alpha_none else { return nil }
    
    var image = Image<P>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
    
    for bitmap in bitmaps {
        
        image._fast_decode(bitmap, is_opaque, T.self, P.Scalar.self) { (destination, source) in
            
            var destination = destination
            var source = source
            
            for _ in 0..<numberOfComponents {
                destination.pointee = decode(source.pointee)
                destination += 1
                source += 1
            }
            
            destination.pointee = 1
        }
    }
    
    if premultiplied {
        image._decode_premultiplied()
    }
    
    return image
}

@inlinable
@inline(__always)
func _fast_decode_alpha_none<T: FixedWidthInteger & UnsignedInteger, P>(_ channels: [RawBitmap.Channel], _ is_opaque: Bool, _ endianness: RawBitmap.Endianness, _: T.Type) -> Image<P>? where P: _FloatComponentPixel {
    
    switch endianness {
    case .big: return _fast_decode_alpha_none(channels, is_opaque, .unsigned, endianness, T.self, { P.Scalar(T(bigEndian: $0)) / P.Scalar(T.max) })
    case .little: return _fast_decode_alpha_none(channels, is_opaque, .unsigned, endianness, T.self, { P.Scalar(T(littleEndian: $0)) / P.Scalar(T.max) })
    }
}

@inlinable
@inline(__always)
func _fast_decode_alpha_none<P>(_ channels: [RawBitmap.Channel], _ is_opaque: Bool, _ endianness: RawBitmap.Endianness, _ decode: (P.Scalar) -> P.Scalar) -> Image<P>? where P: _FloatComponentPixel {
    
    return _fast_decode_alpha_none(channels, is_opaque, float, endianness, T.self, decode)
}
