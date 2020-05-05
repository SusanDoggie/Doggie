//
//  TIFFEncodablePixel.swift
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

@usableFromInline
protocol TIFFEncodablePixel: ColorPixel {
    
    func tiff_prediction_2_encode(_ lhs: Self) -> Self
    
    func tiff_prediction_2_decode(_ lhs: Self) -> Self
    
    func tiff_encode_color<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8
    
    func tiff_encode_opacity<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8
}

extension TIFFEncodablePixel where Self: _GrayColorPixel, Component: ByteOutputStreamable {
    
    @inlinable
    @inline(__always)
    func tiff_prediction_2_encode(_ lhs: Self) -> Self {
        return Self(white: w &- lhs.w, opacity: a &- lhs.a)
    }
    
    @inlinable
    @inline(__always)
    func tiff_prediction_2_decode(_ lhs: Self) -> Self {
        return Self(white: w &+ lhs.w, opacity: a &+ lhs.a)
    }
    
    @inlinable
    @inline(__always)
    func tiff_encode_color<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8 {
        data.encode(w.bigEndian)
    }
    
    @inlinable
    @inline(__always)
    func tiff_encode_opacity<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8 {
        data.encode(a.bigEndian)
    }
}

extension TIFFEncodablePixel where Self: _RGBColorPixel, Component: ByteOutputStreamable {
    
    @inlinable
    @inline(__always)
    func tiff_prediction_2_encode(_ lhs: Self) -> Self {
        return Self(red: r &- lhs.r, green: g &- lhs.g, blue: b &- lhs.b, opacity: a &- lhs.a)
    }
    
    @inlinable
    @inline(__always)
    func tiff_prediction_2_decode(_ lhs: Self) -> Self {
        return Self(red: r &+ lhs.r, green: g &+ lhs.g, blue: b &+ lhs.b, opacity: a &+ lhs.a)
    }
    
    @inlinable
    @inline(__always)
    func tiff_encode_color<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8 {
        data.encode(r.bigEndian)
        data.encode(g.bigEndian)
        data.encode(b.bigEndian)
    }
    
    @inlinable
    @inline(__always)
    func tiff_encode_opacity<C: RangeReplaceableCollection>(_ data: inout C) where C.Element == UInt8 {
        data.encode(a.bigEndian)
    }
}

extension ARGB32ColorPixel: TIFFEncodablePixel {
    
}

extension ARGB64ColorPixel: TIFFEncodablePixel {
    
}

extension RGBA32ColorPixel: TIFFEncodablePixel {
    
}

extension RGBA64ColorPixel: TIFFEncodablePixel {
    
}

extension ABGR32ColorPixel: TIFFEncodablePixel {
    
}

extension BGRA32ColorPixel: TIFFEncodablePixel {
    
}

extension Gray16ColorPixel: TIFFEncodablePixel {
    
}

extension Gray32ColorPixel: TIFFEncodablePixel {
    
}
