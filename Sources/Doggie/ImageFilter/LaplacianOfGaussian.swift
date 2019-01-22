//
//  LaplacianOfGaussian.swift
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
public func LaplacianOfGaussianFilter<T: BinaryFloatingPoint>(_ sd: T) -> [T] where T: FloatingMathProtocol {
    
    precondition(sd > 0, "sd is less than or equal to zero.")
    
    let t = 2 * sd * sd
    let c = -1 / (.pi * sd * sd)
    let _t = -1 / t
    
    let s = Int(ceil(6 * sd)) >> 1
    
    var filter: [T] = []
    
    for y in -s...s {
        for x in -s...s {
            let k = _t * T(x * x + y * y)
            filter.append(c * (1 + k) * T.exp(k))
        }
    }
    
    return filter
}

@inlinable
@inline(__always)
public func LaplacianOfGaussian<Image: _ImageConvolutionProtocol>(_ image: Image, _ sd: Image._ConvolutionFilterScalar, _ algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image where Image._ConvolutionFilterScalar : FloatingMathProtocol {
    let filter = LaplacianOfGaussianFilter(sd)
    let size = Int(isqrt(UInt(filter.count)))
    return image.convolution(filter, size, size, algorithm: algorithm)
}
