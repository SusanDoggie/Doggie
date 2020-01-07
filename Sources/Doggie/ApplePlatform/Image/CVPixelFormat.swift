//
//  CVPixelFormat.swift
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

#if canImport(CoreVideo)

@frozen
public struct CVPixelFormat: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    
    public var rawValue: OSType
    
    public init(rawValue: OSType) {
        self.rawValue = rawValue
    }
}

extension CVPixelFormat {
    
    @inlinable
    @inline(__always)
    public init(integerLiteral value: OSType) {
        self.init(rawValue: value)
    }
    
    @inlinable
    @inline(__always)
    public init(stringLiteral value: StaticString) {
        assert(value.utf8CodeUnitCount == OSType.bitWidth >> 3)
        self.init(rawValue: value.utf8Start.withMemoryRebound(to: OSType.self, capacity: 1) { OSType(bigEndian: $0.pointee) })
    }
}

extension CVPixelFormat {
    
    public var description: String {
        return withUnsafeBytes(of: (rawValue.bigEndian, 0 as UInt8)) { String(cString: $0.baseAddress!.assumingMemoryBound(to: UInt8.self)) }
    }
}

extension CVPixelFormat {
    
    /// 16-bit BE RGB 555.
    public static let BE555_16 = CVPixelFormat(rawValue: kCVPixelFormatType_16BE555)
    
    /// 16-bit LE RGB 555.
    public static let LE555_16 = CVPixelFormat(rawValue: kCVPixelFormatType_16LE555)
    
    /// 16-bit LE RGB 5551.
    public static let LE5551_16 = CVPixelFormat(rawValue: kCVPixelFormatType_16LE5551)
    
    /// 16-bit BE RGB 565.
    public static let BE565_16 = CVPixelFormat(rawValue: kCVPixelFormatType_16BE565)
    
    /// 16-bit LE RGB 565.
    public static let LE565_16 = CVPixelFormat(rawValue: kCVPixelFormatType_16LE565)
    
    /// 24-bit RGB.
    public static let RGB24 = CVPixelFormat(rawValue: kCVPixelFormatType_24RGB)
    
    /// 24-bit BGR.
    public static let BGR24 = CVPixelFormat(rawValue: kCVPixelFormatType_24BGR)
    
    /// 32-bit ARGB.
    public static let ARGB32 = CVPixelFormat(rawValue: kCVPixelFormatType_32ARGB)
    
    /// 32-bit BGRA.
    public static let BGRA32 = CVPixelFormat(rawValue: kCVPixelFormatType_32BGRA)
    
    /// 32-bit ABGR.
    public static let ABGR32 = CVPixelFormat(rawValue: kCVPixelFormatType_32ABGR)
    
    /// 32-bit RGBA.
    public static let RGBA32 = CVPixelFormat(rawValue: kCVPixelFormatType_32RGBA)
    
    /// 64-bit ARGB, 16-bit big-endian samples.
    public static let ARGB64 = CVPixelFormat(rawValue: kCVPixelFormatType_64ARGB)
    
    /// 48-bit RGB, 16-bit big-endian samples.
    public static let RGB48 = CVPixelFormat(rawValue: kCVPixelFormatType_48RGB)
    
    /// 32-bit AlphaGray, 16-bit big-endian samples, black is zero.
    public static let AlphaGray32 = CVPixelFormat(rawValue: kCVPixelFormatType_32AlphaGray)
    
    /// 16-bit Grayscale, 16-bit big-endian samples, black is zero.
    public static let Gray16 = CVPixelFormat(rawValue: kCVPixelFormatType_16Gray)
    
    /// 30-bit RGB, 10-bit big-endian samples, 2 unused padding bits (at least significant end).
    public static let RGB30 = CVPixelFormat(rawValue: kCVPixelFormatType_30RGB)
    
    /// 64-bit RGBA IEEE half-precision float, 16-bit little-endian samples.
    public static let RGBAHalf64 = CVPixelFormat(rawValue: kCVPixelFormatType_64RGBAHalf)
    
    /// 128-bit RGBA IEEE float, 32-bit little-endian samples.
    public static let RGBAFloat128 = CVPixelFormat(rawValue: kCVPixelFormatType_128RGBAFloat)
    
    /// little-endian RGB101010, 2 MSB are zero, wide-gamut (384-895).
    public static let RGBLEPackedWideGamut30 = CVPixelFormat(rawValue: kCVPixelFormatType_30RGBLEPackedWideGamut)
    
    /// little-endian ARGB2101010 full-range ARGB.
    public static let ARGB2101010LEPacked = CVPixelFormat(rawValue: kCVPixelFormatType_ARGB2101010LEPacked)
    
    /// IEEE754-2008 binary16 (half float), describing the depth (distance to an object) in meters.
    public static let DepthFloat16 = CVPixelFormat(rawValue: kCVPixelFormatType_DepthFloat16)
    
    /// IEEE754-2008 binary32 float, describing the depth (distance to an object) in meters.
    public static let DepthFloat32 = CVPixelFormat(rawValue: kCVPixelFormatType_DepthFloat32)
    
    /// IEEE754-2008 binary16 (half float), describing the normalized shift when comparing two images.
    ///
    /// Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ).
    public static let DisparityFloat16 = CVPixelFormat(rawValue: kCVPixelFormatType_DisparityFloat16)
    
    /// IEEE754-2008 binary32 float, describing the normalized shift when comparing two images.
    ///
    /// Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ).
    public static let DisparityFloat32 = CVPixelFormat(rawValue: kCVPixelFormatType_DisparityFloat32)
}

#endif
