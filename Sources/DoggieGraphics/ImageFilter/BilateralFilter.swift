//
//  BilateralFilter.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@inlinable
@inline(__always)
public func BilateralFilter<Pixel>(_ image: Image<Pixel>, _ spatial: Double, _ range: Double) -> Image<Pixel> {
    return Image(texture: BilateralFilter(Texture(image: image), spatial, range), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel>(_ texture: Texture<Pixel>, _ spatial: Double, _ range: Double) -> Texture<Pixel> {
    return BilateralFilter(texture, Size(width: spatial, height: spatial), range)
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel>(_ image: Image<Pixel>, _ spatial: Size, _ range: Double) -> Image<Pixel> {
    return Image(texture: BilateralFilter(Texture(image: image), spatial, range), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel>(_ texture: Texture<Pixel>, _ spatial: Size, _ range: Double) -> Texture<Pixel> {
    
    precondition(spatial.width > 0 || spatial.height > 0, "spatial is less than or equal to zero.")
    precondition(range > 0, "range is less than or equal to zero.")
    
    @inline(__always)
    func dot(_ c0: Float32ColorPixel<Pixel.Model>, _ c1: Float32ColorPixel<Pixel.Model>) -> Float {
        let d = c0 - c1
        return d._color.reduce(d._opacity * d._opacity) { $0 + $1 * $1 }
    }
    
    let _r0 = Int(ceil(6 * spatial.width)) >> 1
    let _r1 = Int(ceil(6 * spatial.height)) >> 1
    
    var result = texture
    
    let width = texture.width
    let height = texture.height
    
    let _c0 = -0.5 / Float(spatial.width * spatial.width)
    let _c1 = -0.5 / Float(spatial.height * spatial.height)
    let _c2 = -0.5 / Float(range * range)
    
    result.withUnsafeMutableBufferPointer {
        
        guard var buffer = $0.baseAddress else { return }
        
        texture.withUnsafeBufferPointer {
            
            guard var texture = $0.baseAddress else { return }
            
            for j in 0..<height {
                
                let min_y = max(0, j - _r1) - j
                let max_y = min(height - 1, j + _r1) - j
                
                for i in 0..<width {
                    
                    let min_x = max(0, i - _r0) - i
                    let max_x = min(width - 1, i + _r0) - i
                    
                    var kernel = texture + min_x + min_y * width
                    
                    let _p = Float32ColorPixel(texture.pointee)
                    var s = Float32ColorPixel<Pixel.Model>()
                    var t: Float = 0.0
                    
                    for y in min_y...max_y {
                        var _kernel = kernel
                        for x in min_x...max_x {
                            
                            let _k = Float32ColorPixel(_kernel.pointee)
                            let _x = _c0 * Float(x * x)
                            let _y = _c1 * Float(y * y)
                            let _z = _c2 * dot(_p, _k)
                            let w = exp(_x + _y + _z)
                            
                            s += w * _k
                            t += w
                            
                            _kernel += 1
                        }
                        kernel += width
                    }
                    
                    buffer.pointee = Pixel(s / t)
                    buffer += 1
                    texture += 1
                }
            }
        }
    }
    
    return result
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel: _FloatComponentPixel>(_ image: Image<Pixel>, _ spatial: Pixel.Scalar, _ range: Pixel.Scalar) -> Image<Pixel> where Pixel.Scalar: FloatingMathProtocol {
    return Image(texture: BilateralFilter(Texture(image: image), spatial, range), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel: _FloatComponentPixel>(_ texture: Texture<Pixel>, _ spatial: Pixel.Scalar, _ range: Pixel.Scalar) -> Texture<Pixel> where Pixel.Scalar: FloatingMathProtocol {
    return BilateralFilter(texture, Size(width: Double(spatial), height: Double(spatial)), Double(range))
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel: _FloatComponentPixel>(_ image: Image<Pixel>, _ spatial: Size, _ range: Double) -> Image<Pixel> where Pixel.Scalar: FloatingMathProtocol {
    return Image(texture: BilateralFilter(Texture(image: image), spatial, range), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func BilateralFilter<Pixel: _FloatComponentPixel>(_ texture: Texture<Pixel>, _ spatial: Size, _ range: Double) -> Texture<Pixel> where Pixel.Scalar: FloatingMathProtocol {
    
    precondition(spatial.width > 0 || spatial.height > 0, "spatial is less than or equal to zero.")
    precondition(range > 0, "range is less than or equal to zero.")
    
    @inline(__always)
    func dot(_ c0: Pixel, _ c1: Pixel) -> Pixel.Scalar {
        let d = c0 - c1
        return d._color.reduce(d._opacity * d._opacity) { $0 + $1 * $1 }
    }
    
    let _r0 = Int(ceil(6 * spatial.width)) >> 1
    let _r1 = Int(ceil(6 * spatial.height)) >> 1
    
    var result = texture
    
    let width = texture.width
    let height = texture.height
    
    let _c0 = -0.5 / Pixel.Scalar(spatial.width * spatial.width)
    let _c1 = -0.5 / Pixel.Scalar(spatial.height * spatial.height)
    let _c2 = -0.5 / Pixel.Scalar(range * range)
    
    result.withUnsafeMutableBufferPointer {
        
        guard var buffer = $0.baseAddress else { return }
        
        texture.withUnsafeBufferPointer {
            
            guard var texture = $0.baseAddress else { return }
            
            for j in 0..<height {
                
                let min_y = max(0, j - _r1) - j
                let max_y = min(height - 1, j + _r1) - j
                
                for i in 0..<width {
                    
                    let min_x = max(0, i - _r0) - i
                    let max_x = min(width - 1, i + _r0) - i
                    
                    var kernel = texture + min_x + min_y * width
                    
                    let _p = texture.pointee
                    var s = Pixel()
                    var t: Pixel.Scalar = 0.0
                    
                    for y in min_y...max_y {
                        var _kernel = kernel
                        for x in min_x...max_x {
                            
                            let _k = _kernel.pointee
                            let _x = _c0 * Pixel.Scalar(x * x)
                            let _y = _c1 * Pixel.Scalar(y * y)
                            let _z = _c2 * dot(_p, _k)
                            let w = Pixel.Scalar.exp(_x + _y + _z)
                            
                            s += w * _k
                            t += w
                            
                            _kernel += 1
                        }
                        kernel += width
                    }
                    
                    buffer.pointee = s / t
                    buffer += 1
                    texture += 1
                }
            }
        }
    }
    
    return result
}
