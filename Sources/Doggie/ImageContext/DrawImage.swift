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
    
    @inline(__always)
    public func draw<T>(stencil: StencilTexture<T>, transform: SDTransform, color: Pixel.Model) {
        
        let width = self.width
        let height = self.height
        let s_width = stencil.width
        let s_height = stencil.height
        let transform = transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        if width == 0 || height == 0 || s_width == 0 || s_height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let _transform = transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            if shouldAntialias && antialias > 1 {
                
                var blender = blender
                
                let __transform = SDTransform.scale(1 / Double(antialias)) * _transform
                let div = 1 / Double(antialias * antialias)
                
                for y in stride(from: 0, to: height * antialias, by: antialias) {
                    for x in stride(from: 0, to: width * antialias, by: antialias) {
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var pixel: T = 0
                            for j in 0..<antialias {
                                for i in 0..<antialias {
                                    pixel += stencil.pixel(Point(x: x + i, y: y + j) * __transform)
                                }
                            }
                            return ColorPixel(color: color, opacity: Double(pixel) * div)
                        }
                        blender += 1
                    }
                }
                
            } else {
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { ColorPixel(color: color, opacity: Double(stencil.pixel(Point(x: x, y: y) * _transform))) }
                        blender += 1
                    }
                }
            }
        }
    }
    
    @inline(__always)
    public func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Pixel.Model {
        
        let width = self.width
        let height = self.height
        let s_width = texture.width
        let s_height = texture.height
        let transform = transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        if width == 0 || height == 0 || s_width == 0 || s_height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let _transform = transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            if shouldAntialias && antialias > 1 {
                
                var blender = blender
                
                let __transform = SDTransform.scale(1 / Double(antialias)) * _transform
                let div = 1 / Double(antialias * antialias)
                
                for y in stride(from: 0, to: height * antialias, by: antialias) {
                    for x in stride(from: 0, to: width * antialias, by: antialias) {
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var pixel = ColorPixel<Pixel.Model>()
                            for j in 0..<antialias {
                                for i in 0..<antialias {
                                    pixel += texture.pixel(Point(x: x + i, y: y + j) * __transform)
                                }
                            }
                            return pixel * div
                        }
                        blender += 1
                    }
                }
                
            } else {
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { texture.pixel(Point(x: x, y: y) * _transform) }
                        blender += 1
                    }
                }
            }
        }
    }
}

