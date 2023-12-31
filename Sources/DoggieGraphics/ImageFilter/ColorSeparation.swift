//
//  ColorSeparation.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
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
    return palette.map(Float32ColorPixel.init).withUnsafeBufferPointer { palette in texture.map { pixel in Pixel(palette.min { Float32ColorPixel(pixel).distance(to: $0) }!) } }
}

@inlinable
@inline(__always)
public func ColorSeparation<Pixel: _FloatComponentPixel>(_ image: Image<Pixel>, _ palette: [Pixel]) -> Image<Pixel> where Pixel.Scalar: ElementaryFunctions {
    return Image(texture: ColorSeparation(Texture(image: image), palette), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func ColorSeparation<Pixel: _FloatComponentPixel>(_ texture: Texture<Pixel>, _ palette: [Pixel]) -> Texture<Pixel> where Pixel.Scalar: ElementaryFunctions {
    return palette.withUnsafeBufferPointer { palette in texture.map { pixel in palette.min { pixel.distance(to: $0) }! } }
}
