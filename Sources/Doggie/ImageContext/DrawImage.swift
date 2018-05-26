//
//  DrawImage.swift
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

extension ImageContext {
    
    @_inlineable
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(texture: Texture(image: image.convert(to: colorSpace, intent: renderingIntent), resamplingAlgorithm: resamplingAlgorithm), transform: transform)
    }
    
    @_inlineable
    public func draw(texture: Texture<ColorPixel<Pixel.Model>>, transform: SDTransform) {
        
        let width = self.width
        let height = self.height
        let s_width = texture.width
        let s_height = texture.height
        let transform = transform * self.transform
        
        if width == 0 || height == 0 || s_width == 0 || s_height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let _transform = transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            if antialias {
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        var _q = Point(x: x, y: y)
                        var pixel = ColorPixel<Pixel.Model>()
                        for _ in 0..<5 {
                            var q = _q
                            for _ in 0..<5 {
                                pixel += texture.pixel(q * _transform)
                                q.x += 0.2
                            }
                            _q.y += 0.2
                        }
                        blender.draw(color: pixel * 0.04)
                        blender += 1
                    }
                }
                
            } else {
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw(color: texture.pixel(Point(x: x, y: y) * _transform))
                        blender += 1
                    }
                }
            }
        }
    }
}

