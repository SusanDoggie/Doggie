//
//  ColorSeparation.swift
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

@inlinable
@inline(__always)
public func ColorSeparation<Pixel>(_ image: Image<Pixel>, _ palette: [Pixel]) -> Image<Pixel> {
    return Image(texture: ColorSeparation(Texture(image: image), palette), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func ColorSeparation<Pixel>(_ texture: Texture<Pixel>, _ palette: [Pixel]) -> Texture<Pixel> {
    
    @inline(__always)
    func distance(_ c0: Pixel, _ c1: Pixel) -> Double {
        let d = Float64ColorPixel(c0) - Float64ColorPixel(c1)
        return d.color.reduce(d.opacity, hypot)
    }
    
    return palette.withUnsafeBufferPointer { palette in texture.map { pixel in palette.min { distance(pixel, $0) }! } }
}

@inlinable
@inline(__always)
public func ColorSeparation<Pixel : _FloatComponentPixelImplement>(_ image: Image<Pixel>, _ palette: [Pixel]) -> Image<Pixel> where Pixel.Scalar : FloatingMathProtocol {
    return Image(texture: ColorSeparation(Texture(image: image), palette), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func ColorSeparation<Pixel : _FloatComponentPixelImplement>(_ texture: Texture<Pixel>, _ palette: [Pixel]) -> Texture<Pixel> where Pixel.Scalar : FloatingMathProtocol {
    
    @inline(__always)
    func distance(_ c0: Pixel, _ c1: Pixel) -> Pixel.Scalar {
        let d = c0 - c1
        return d._color.reduce(d._opacity, Pixel.Scalar.hypot)
    }
    
    return palette.withUnsafeBufferPointer { palette in texture.map { pixel in palette.min { distance(pixel, $0) }! } }
}
