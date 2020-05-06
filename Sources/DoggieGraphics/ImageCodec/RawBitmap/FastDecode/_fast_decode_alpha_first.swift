//
//  _fast_decode_alpha_first.swift
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
func _fast_decode_alpha_first<T, P: _FloatComponentPixel>(_ bitmaps: [RawBitmap], _ format: RawBitmap.Format, _ endianness: RawBitmap.Endianness, _ info: _fast_decode_info<P.Model>, _: T.Type, _ decode: (T) -> P.Scalar) -> Image<P>? {
    
    let channels = bitmaps[0].channels.sorted { $0.bitRange.lowerBound }
    
    let numberOfComponents = P.Model.numberOfComponents
    let bitsPerChannel = MemoryLayout<T>.stride << 3
    
    var alpha_first = [RawBitmap.Channel(index: numberOfComponents, format: format, endianness: endianness, bitRange: 0..<bitsPerChannel)]
    for i in 1...numberOfComponents {
        let lowerBound = i * bitsPerChannel
        let upperBound = lowerBound + bitsPerChannel
        alpha_first.append(RawBitmap.Channel(index: i - 1, format: format, endianness: endianness, bitRange: lowerBound..<upperBound))
    }
    
    guard channels == alpha_first else { return nil }
    
    var image = Image<P>(width: info.width, height: info.height, resolution: info.resolution, colorSpace: info.colorSpace, fileBacked: info.fileBacked)
    
    image._fast_decode(bitmaps, info.is_opaque, info.premultiplied, T.self, P.Scalar.self) { (destination, source) in
        
        var destination = destination
        var _source = source + 1
        
        for _ in 0..<numberOfComponents {
            destination.pointee = decode(_source.pointee)
            destination += 1
            _source += 1
        }
        
        destination.pointee = decode(source.pointee)
    }
    
    return image
}

@inlinable
@inline(__always)
func _fast_decode_alpha_first<T: FixedWidthInteger, P: _FloatComponentPixel>(_ bitmaps: [RawBitmap], _ endianness: RawBitmap.Endianness, _ info: _fast_decode_info<P.Model>, _: T.Type) -> Image<P>? {
    
    switch endianness {
    case .big: return _fast_decode_alpha_first(bitmaps, .unsigned, endianness, info, T.self) { P.Scalar(T(bigEndian: $0)) / P.Scalar(T.max) }
    case .little: return _fast_decode_alpha_first(bitmaps, .unsigned, endianness, info, T.self) { P.Scalar(T(littleEndian: $0)) / P.Scalar(T.max) }
    }
}

@inlinable
@inline(__always)
func _fast_decode_alpha_first<P: _FloatComponentPixel>(_ bitmaps: [RawBitmap], _ endianness: RawBitmap.Endianness, _ info: _fast_decode_info<P.Model>, _ decode: (P.Scalar) -> P.Scalar) -> Image<P>? {
    
    return _fast_decode_alpha_first(bitmaps, .float, endianness, info, P.Scalar.self, decode)
}
        
