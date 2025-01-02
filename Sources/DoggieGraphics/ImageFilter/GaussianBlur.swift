//
//  GaussianBlur.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
public func GaussianBlurFilter<T: BinaryFloatingPoint>(_ sd: T) -> [T] where T: ElementaryFunctions {
    
    precondition(sd > 0, "sd is less than or equal to zero.")
    
    let s = Int(ceil(6 * sd)) >> 1
    let t = 2 * sd * sd
    let c = sqrt(.pi * t)
    
    return (-s...s).map {
        let x = T($0)
        return T.exp(x * x / -t) / c
    }
}

@inlinable
@inline(__always)
public func GaussianBlur<Image: _ImageConvolutionProtocol>(_ image: Image, _ sd: Image._ConvolutionFilterScalar, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image where Image._ConvolutionFilterScalar: ElementaryFunctions {
    let filter = GaussianBlurFilter(sd)
    return image.convolution(horizontal: filter, vertical: filter, algorithm: algorithm)
}
