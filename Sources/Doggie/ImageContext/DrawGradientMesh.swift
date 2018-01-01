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

import Foundation

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
    func _drawGradient(_ blender: ImageContextPixelBlender<Pixel>, _ patch: CubicBezierPatch, _ c0: ColorPixel<Pixel.Model>, _ c1: ColorPixel<Pixel.Model>, _ c2: ColorPixel<Pixel.Model>, _ c3: ColorPixel<Pixel.Model>) {
        
        let (m0, n0) = Bezier(patch.m00, patch.m01, patch.m02, patch.m03).split(0.5)
        let (m1, n1) = Bezier(patch.m10, patch.m11, patch.m12, patch.m13).split(0.5)
        let (m2, n2) = Bezier(patch.m20, patch.m21, patch.m22, patch.m23).split(0.5)
        let (m3, n3) = Bezier(patch.m30, patch.m31, patch.m32, patch.m33).split(0.5)
        
        let (s0, t0) = Bezier(m0[0], m1[0], m2[0], m3[0]).split(0.5)
        let (s1, t1) = Bezier(m0[1], m1[1], m2[1], m3[1]).split(0.5)
        let (s2, t2) = Bezier(m0[2], m1[2], m2[2], m3[2]).split(0.5)
        let (s3, t3) = Bezier(m0[3], m1[3], m2[3], m3[3]).split(0.5)
        
        let (u0, v0) = Bezier(n0[0], n1[0], n2[0], n3[0]).split(0.5)
        let (u1, v1) = Bezier(n0[1], n1[1], n2[1], n3[1]).split(0.5)
        let (u2, v2) = Bezier(n0[2], n1[2], n2[2], n3[2]).split(0.5)
        let (u3, v3) = Bezier(n0[3], n1[3], n2[3], n3[3]).split(0.5)
        
        let p0 = CubicBezierPatch(s0[0], s1[0], s2[0], s3[0],
                                  s0[1], s1[1], s2[1], s3[1],
                                  s0[2], s1[2], s2[2], s3[2],
                                  s0[3], s1[3], s2[3], s3[3])
        
        let p1 = CubicBezierPatch(t0[0], t1[0], t2[0], t3[0],
                                  t0[1], t1[1], t2[1], t3[1],
                                  t0[2], t1[2], t2[2], t3[2],
                                  t0[3], t1[3], t2[3], t3[3])
        
        let p2 = CubicBezierPatch(u0[0], u1[0], u2[0], u3[0],
                                  u0[1], u1[1], u2[1], u3[1],
                                  u0[2], u1[2], u2[2], u3[2],
                                  u0[3], u1[3], u2[3], u3[3])
        
        let p3 = CubicBezierPatch(v0[0], v1[0], v2[0], v3[0],
                                  v0[1], v1[1], v2[1], v3[1],
                                  v0[2], v1[2], v2[2], v3[2],
                                  v0[3], v1[3], v2[3], v3[3])
        
        let c4 = 0.5 * (c0 + c1)
        let c5 = 0.5 * (c0 + c2)
        let c6 = 0.5 * (c1 + c3)
        let c7 = 0.5 * (c2 + c3)
        let c8 = 0.25 * (c0 + c1 + c2 + c3)
        
        @inline(__always)
        func _draw(_ patch: CubicBezierPatch, _ c0: ColorPixel<Pixel.Model>, _ c1: ColorPixel<Pixel.Model>, _ c2: ColorPixel<Pixel.Model>, _ c3: ColorPixel<Pixel.Model>) {
            
            let d0 = patch.m00 - patch.m03
            let d1 = patch.m30 - patch.m33
            let d2 = patch.m00 - patch.m30
            let d3 = patch.m03 - patch.m33
            
            if abs(d0.x) < 1 && abs(d0.y) < 1 && abs(d1.x) < 1 && abs(d1.y) < 1 && abs(d2.x) < 1 && abs(d2.y) < 1 && abs(d3.x) < 1 && abs(d3.y) < 1 {
                
                let width = self.width
                let height = self.height
                
                let rasterizer = ImageContextGradientMeshRasterizeBuffer(blender: blender, width: width, height: height)
                
                rasterizer.rasterize(patch.m00, patch.m03, patch.m30) { _, buf in buf.blender.draw { c8 } }
                rasterizer.rasterize(patch.m03, patch.m33, patch.m30) { _, buf in buf.blender.draw { c8 } }
                
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
    public func drawGradient<C: ColorProtocol>(_ patch: CubicBezierPatch, color c0: C, _ c1: C, _ c2: C, _ c3: C) {
        
        let width = self.width
        let height = self.height
        let transform = self.transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        self.withUnsafePixelBlender { blender in
            
            _drawGradient(blender, CubicBezierPatch(patch.m00 * transform, patch.m01 * transform, patch.m02 * transform, patch.m03 * transform,
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
