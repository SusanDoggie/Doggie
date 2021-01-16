//
//  DifferenceOfGaussian.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
public func DifferenceOfGaussianFilter<T: BinaryFloatingPoint>(_ sd: T, _ k: T) -> [T] where T: ElementaryFunctions {
    
    precondition(sd > 0, "sd is less than or equal to zero.")
    precondition(k > 0, "k is less than or equal to zero.")
    
    let s = Int(ceil(6 * max(sd, sd * k))) >> 1
    let t = 2 * sd * sd
    let c = .pi * t
    let k2 = k * k
    
    var filter: [T] = []
    
    for y in -s...s {
        for x in -s...s {
            let u = T(x * x + y * y) / -t
            filter.append((T.exp(u / k2) / k2 - T.exp(u)) / c)
        }
    }
    
    return filter
}

@inlinable
@inline(__always)
public func DifferenceOfGaussian<Image: _ImageConvolutionProtocol>(_ image: Image, _ sd: Image._ConvolutionFilterScalar, _ k: Image._ConvolutionFilterScalar, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image where Image._ConvolutionFilterScalar: ElementaryFunctions {
    let filter = DifferenceOfGaussianFilter(sd, k)
    let size = Int(isqrt(UInt(filter.count)))
    return image.convolution(filter, size, size, algorithm: algorithm)
}
