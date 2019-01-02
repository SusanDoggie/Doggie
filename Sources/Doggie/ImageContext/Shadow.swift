//
//  DrawShadow.swift
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

extension ImageContext {
    
    @_transparent
    @usableFromInline
    var isShadow: Bool {
        return shadowColor.opacity > 0 && shadowBlur > 0
    }
    
    @inlinable
    @inline(__always)
    func _drawWithShadow(stencil: MappedBuffer<Float>, color: ColorPixel<Pixel.Model>) {
        
        let width = self.width
        let height = self.height
        let convolutionAlgorithm = self.convolutionAlgorithm
        
        let shadowColor = ColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        let shadowOffset = self.shadowOffset
        let shadowBlur = self.shadowBlur
        
        let filter = GaussianBlurFilter(Float(0.5 * shadowBlur))
        let _offset = Point(x: Double(filter.count >> 1) - shadowOffset.width, y: Double(filter.count >> 1) - shadowOffset.height)
        
        let shadow_layer = TextureConvolution(StencilTexture(width: width, height: height, pixels: stencil, resamplingAlgorithm: .linear), horizontal: filter, vertical: filter, convolutionAlgorithm)
        
        stencil.withUnsafeBufferPointer { stencil in
            
            guard var stencil = stencil.baseAddress else { return }
            
            self._withUnsafePixelBlender { blender in
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { () -> ColorPixel<Pixel.Model>? in
                            
                            let _shadow = shadow_layer.pixel(Point(x: x, y: y) + _offset)
                            guard _shadow > 0 else { return nil }
                            
                            var shadowColor = shadowColor
                            shadowColor.opacity *= Double(_shadow)
                            return shadowColor
                        }
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var color = color
                            color.opacity *= Double(stencil.pointee)
                            return color
                        }
                        blender += 1
                        stencil += 1
                    }
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    func _drawWithShadow(texture: Texture<Pixel>) {
        
        let width = self.width
        let height = self.height
        let convolutionAlgorithm = self.convolutionAlgorithm
        
        let shadowColor = ColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        let shadowOffset = self.shadowOffset
        let shadowBlur = self.shadowBlur
        
        let filter = GaussianBlurFilter(Float(0.5 * shadowBlur))
        let _offset = Point(x: Double(filter.count >> 1) - shadowOffset.width, y: Double(filter.count >> 1) - shadowOffset.height)
        
        var shadow_layer = TextureConvolution(StencilTexture<Float>(texture: texture), horizontal: filter, vertical: filter, convolutionAlgorithm)
        shadow_layer.resamplingAlgorithm = .linear
        
        texture.withUnsafeBufferPointer { source in
            
            guard var source = source.baseAddress else { return }
            
            self._withUnsafePixelBlender { blender in
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { () -> ColorPixel<Pixel.Model>? in
                            
                            let _shadow = shadow_layer.pixel(Point(x: x, y: y) + _offset)
                            guard _shadow > 0 else { return nil }
                            
                            var shadowColor = shadowColor
                            shadowColor.opacity *= Double(_shadow)
                            return shadowColor
                        }
                        blender.draw { source.pointee }
                        blender += 1
                        source += 1
                    }
                }
            }
        }
    }
}
