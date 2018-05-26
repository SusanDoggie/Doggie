//
//  DrawGradientMesh.swift
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

@_versioned
@_fixed_layout
struct ImageContextGradientMeshRasterizeBuffer<P : ColorPixelProtocol> : RasterizeBufferProtocol {
    
    @_versioned
    var blender: ImageContextPixelBlender<P>
    
    @_versioned
    var width: Int
    
    @_versioned
    var height: Int
    
    @_versioned
    @inline(__always)
    init(blender: ImageContextPixelBlender<P>, width: Int, height: Int) {
        self.blender = blender
        self.width = width
        self.height = height
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextGradientMeshRasterizeBuffer, rhs: Int) -> ImageContextGradientMeshRasterizeBuffer {
        return ImageContextGradientMeshRasterizeBuffer(blender: lhs.blender + rhs, width: lhs.width, height: lhs.height)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextGradientMeshRasterizeBuffer, rhs: Int) {
        lhs.blender += rhs
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func _drawGradient(_ blender: ImageContextPixelBlender<Pixel>, _ patch: CubicBezierPatch<Point>, _ c0: ColorPixel<Pixel.Model>, _ c1: ColorPixel<Pixel.Model>, _ c2: ColorPixel<Pixel.Model>, _ c3: ColorPixel<Pixel.Model>) {
        
        let (p0, p1, p2, p3) = patch.split(0.5, 0.5)
        
        let c4 = 0.5 * (c0 + c1)
        let c5 = 0.5 * (c0 + c2)
        let c6 = 0.5 * (c1 + c3)
        let c7 = 0.5 * (c2 + c3)
        let c8 = 0.25 * (c0 + c1 + c2 + c3)
        
        @inline(__always)
        func _draw(_ patch: CubicBezierPatch<Point>, _ c0: ColorPixel<Pixel.Model>, _ c1: ColorPixel<Pixel.Model>, _ c2: ColorPixel<Pixel.Model>, _ c3: ColorPixel<Pixel.Model>) {
            
            let d0 = patch.m00 - patch.m03
            let d1 = patch.m30 - patch.m33
            let d2 = patch.m00 - patch.m30
            let d3 = patch.m03 - patch.m33
            
            if abs(d0.x) < 1 && abs(d0.y) < 1 && abs(d1.x) < 1 && abs(d1.y) < 1 && abs(d2.x) < 1 && abs(d2.y) < 1 && abs(d3.x) < 1 && abs(d3.y) < 1 {
                
                let width = self.width
                let height = self.height
                
                let rasterizer = ImageContextGradientMeshRasterizeBuffer(blender: blender, width: width, height: height)
                
                rasterizer.rasterize(patch.m00, patch.m03, patch.m30) { _, buf in buf.blender.draw(color: c8) }
                rasterizer.rasterize(patch.m03, patch.m33, patch.m30) { _, buf in buf.blender.draw(color: c8) }
                
            } else {
                _drawGradient(blender, patch, c0, c1, c2, c3)
            }
        }
        
        _draw(p0, c0, c4, c5, c8)
        _draw(p1, c5, c8, c2, c7)
        _draw(p2, c4, c1, c8, c6)
        _draw(p3, c8, c6, c7, c3)
        
    }
    
    @_inlineable
    public func drawGradient<C: ColorProtocol>(_ patch: CubicBezierPatch<Point>, color c0: C, _ c1: C, _ c2: C, _ c3: C) {
        
        let width = self.width
        let height = self.height
        let transform = self.transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        self.withUnsafePixelBlender { blender in
            
            _drawGradient(blender, CubicBezierPatch<Point>(patch.m00 * transform, patch.m01 * transform, patch.m02 * transform, patch.m03 * transform,
                                                    patch.m10 * transform, patch.m11 * transform, patch.m12 * transform, patch.m13 * transform,
                                                    patch.m20 * transform, patch.m21 * transform, patch.m22 * transform, patch.m23 * transform,
                                                    patch.m30 * transform, patch.m31 * transform, patch.m32 * transform, patch.m33 * transform),
                          ColorPixel(c0.convert(to: colorSpace, intent: renderingIntent)),
                          ColorPixel(c1.convert(to: colorSpace, intent: renderingIntent)),
                          ColorPixel(c2.convert(to: colorSpace, intent: renderingIntent)),
                          ColorPixel(c3.convert(to: colorSpace, intent: renderingIntent)))
        }
    }
}
