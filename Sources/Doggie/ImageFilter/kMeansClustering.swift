//
//  kMeansClustering.swift
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
public func kMeansClustering<Pixel>(_ image: Image<Pixel>, _ resultingImageColor: Bool, _ color: inout [Pixel]) {
    kMeansClustering(Texture(image: image), resultingImageColor, &color)
}

@inlinable
@inline(__always)
public func kMeansClustering<Pixel>(_ texture: Texture<Pixel>, _ resultingImageColor: Bool, _ color: inout [Pixel]) {
    
    var means: [(Float64ColorPixel<Pixel.Model>, Int)] = Array(repeating: (Float64ColorPixel<Pixel.Model>(), 0), count: color.count)
    
    @inline(__always)
    func distance(_ c0: Float64ColorPixel<Pixel.Model>, _ c1: Pixel) -> Double {
        let d = c0 - Float64ColorPixel(c1)
        return d.color.reduce(d.opacity, hypot)
    }
    
    color.withUnsafeBufferPointer { color in
        
        means.withUnsafeMutableBufferPointer {
            
            guard let means = $0.baseAddress else { return }
            
            texture.withUnsafeBufferPointer { pixels in
                
                for pixel in pixels {
                    
                    let _pixel = Float64ColorPixel(pixel)
                    
                    let index = color.enumerated().min { distance(_pixel, $0.1) }!.0
                    
                    means[index].0 += _pixel
                    means[index].1 += 1
                }
            }
        }
    }
    
    let _color = zip(color, means).map { $1.1 == 0 ? Float64ColorPixel($0) : $1.0 / Double($1.1) }
    
    if resultingImageColor {
        color = texture.withUnsafeBufferPointer { pixels in _color.map { color in pixels.min { distance(color, $0) }! } }
    } else {
        color = _color.map(Pixel.init)
    }
}

@inlinable
@inline(__always)
public func kMeansClustering<Pixel : _FloatComponentPixelImplement>(_ image: Image<Pixel>, _ resultingImageColor: Bool, _ color: inout [Pixel]) where Pixel.Scalar : FloatingMathProtocol {
    kMeansClustering(Texture(image: image), resultingImageColor, &color)
}

@inlinable
@inline(__always)
public func kMeansClustering<Pixel : _FloatComponentPixelImplement>(_ texture: Texture<Pixel>, _ resultingImageColor: Bool, _ color: inout [Pixel]) where Pixel.Scalar : FloatingMathProtocol {
    
    var means: [(Pixel, Int)] = Array(repeating: (Pixel(), 0), count: color.count)
    
    @inline(__always)
    func distance(_ c0: Pixel, _ c1: Pixel) -> Pixel.Scalar {
        let d = c0 - c1
        return d._color.reduce(d._opacity, Pixel.Scalar.hypot)
    }
    
    color.withUnsafeBufferPointer { color in
        
        means.withUnsafeMutableBufferPointer {
            
            guard let means = $0.baseAddress else { return }
            
            texture.withUnsafeBufferPointer { pixels in
                
                for pixel in pixels {
                    
                    let index = color.enumerated().min { distance(pixel, $0.1) }!.0
                    
                    means[index].0 += pixel
                    means[index].1 += 1
                }
            }
        }
    }
    
    let _color = zip(color, means).map { $1.1 == 0 ? $0 : $1.0 / Pixel.Scalar($1.1) }
    
    if resultingImageColor {
        color = texture.withUnsafeBufferPointer { pixels in _color.map { color in pixels.min { distance(color, $0) }! } }
    } else {
        color = _color
    }
}
