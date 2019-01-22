//
//  GaussianBlur.swift
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
public func GaussianBlurFilter<T: BinaryFloatingPoint>(_ sd: T) -> [T] where T: FloatingMathProtocol {
    
    precondition(sd > 0, "sd is less than or equal to zero.")
    
    let t = 2 * sd * sd
    let c = 1 / sqrt(.pi * t)
    let _t = -1 / t
    
    let s = Int(ceil(6 * sd)) >> 1
    
    return (-s...s).map {
        let x = T($0)
        return T.exp(x * x * _t) * c
    }
}

@inlinable
@inline(__always)
public func GaussianBlur<T>(_ texture: StencilTexture<T>, _ sd: T, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> StencilTexture<T> {
    let filter = GaussianBlurFilter(sd)
    return texture.convolution(horizontal: filter, vertical: filter, algorithm: algorithm)
}

@inlinable
@inline(__always)
public func GaussianBlur<RawPixel>(_ texture: Texture<RawPixel>, _ sd: RawPixel.Scalar, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Texture<RawPixel> where RawPixel : _FloatComponentPixel, RawPixel.Scalar : BinaryFloatingPoint & FloatingMathProtocol {
    let filter = GaussianBlurFilter(sd)
    return texture.convolution(horizontal: filter, vertical: filter, algorithm: algorithm)
}

@inlinable
@inline(__always)
public func GaussianBlur<Pixel>(_ image: Image<Pixel>, _ sd: Pixel.Scalar, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image<Pixel> where Pixel : _FloatComponentPixel, Pixel.Scalar : BinaryFloatingPoint & FloatingMathProtocol {
    let filter = GaussianBlurFilter(sd)
    return image.convolution(horizontal: filter, vertical: filter, algorithm: algorithm)
}
