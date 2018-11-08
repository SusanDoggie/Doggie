//
//  Underpainting.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
public func Underpainting<Pixel>(_ image: Image<Pixel>, _ expand: Double, _ background_color: Pixel.Model) -> Image<Pixel> {
    return Image(texture: Underpainting(Texture(image: image), expand, background_color), resolution: image.resolution, colorSpace: image.colorSpace)
}

@inlinable
@inline(__always)
public func Underpainting<Pixel>(_ texture: Texture<Pixel>, _ expand: Double, _ background_color: Pixel.Model) -> Texture<Pixel> {
    
    let width = texture.width
    let height = texture.height
    let fileBacked = texture.fileBacked
    
    var result = texture
    
    guard width > 0 && height > 0 else { return result }
    
    func _filter(_ blur: Float) -> [Float] {
        
        let t = 2 * blur * blur
        let _t = -1 / t
        
        let s = Int(ceil(6 * blur)) >> 1
        
        return (-s...s).map {
            let x = Float($0)
            return exp(x * x * _t)
        }
    }
    
    let filter = _filter(Float(expand * 0.5))
    var stencil = StencilTexture<Float>(texture: texture).map { $0.almostZero() ? $0 : 1 }._apply(filter).map { $0 < 0.6854015858994297386824412701652185185921339959326058 ? 0 : 1 }
    stencil.resamplingAlgorithm = .none
    
    let half = filter.count >> 1
    
    result.withUnsafeMutableBufferPointer {
        
        guard var output = $0.baseAddress else { return }
        
        for y in 0..<height {
            for x in 0..<width {
                let shadowColor = ColorPixel(color: background_color, opacity: stencil.pixel(Point(x: x + half, y: y + half)))
                output.pointee = Pixel(shadowColor.blended(source: output.pointee))
                output += 1
            }
        }
    }
    
    return result
}
