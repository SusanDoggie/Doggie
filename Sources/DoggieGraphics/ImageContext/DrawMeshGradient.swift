//
//  DrawMeshGradient.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension ImageContext {
    
    @frozen
    @usableFromInline
    struct MeshGradientRasterizeBuffer: RasterizeBufferProtocol {
        
        @usableFromInline
        var blender: PixelBlender
        
        @usableFromInline
        var width: Int
        
        @usableFromInline
        var height: Int
        
        @inlinable
        @inline(__always)
        init(blender: PixelBlender, width: Int, height: Int) {
            self.blender = blender
            self.width = width
            self.height = height
        }
    }
}

extension ImageContext.MeshGradientRasterizeBuffer {
    
    @inlinable
    @inline(__always)
    static func + (lhs: Self, rhs: Int) -> Self {
        return Self(blender: lhs.blender + rhs, width: lhs.width, height: lhs.height)
    }
    
    @inlinable
    @inline(__always)
    static func += (lhs: inout Self, rhs: Int) {
        lhs.blender += rhs
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    func _drawMeshGradient(_ rasterizer: MeshGradientRasterizeBuffer, _ patch: CubicBezierPatch<Point>, _ c0: Float32ColorPixel<Pixel.Model>, _ c1: Float32ColorPixel<Pixel.Model>, _ c2: Float32ColorPixel<Pixel.Model>, _ c3: Float32ColorPixel<Pixel.Model>) {
        
        let (p0, p1, p2, p3) = patch.split(0.5, 0.5)
        
        let c4 = 0.5 * (c0 + c1)
        let c5 = 0.5 * (c0 + c2)
        let c6 = 0.5 * (c1 + c3)
        let c7 = 0.5 * (c2 + c3)
        let c8 = 0.5 * (c4 + c7)
        
        @inline(__always)
        func _draw(_ patch: CubicBezierPatch<Point>, _ c0: Float32ColorPixel<Pixel.Model>, _ c1: Float32ColorPixel<Pixel.Model>, _ c2: Float32ColorPixel<Pixel.Model>, _ c3: Float32ColorPixel<Pixel.Model>) {
            
            let width = rasterizer.width
            let height = rasterizer.height
            
            let min_x = Int(min(min(patch.m00.x, patch.m03.x), min(patch.m30.x, patch.m33.x)).rounded(.up))
            let max_x = Int(max(max(patch.m00.x, patch.m03.x), max(patch.m30.x, patch.m33.x)).rounded(.down))
            let min_y = Int(min(min(patch.m00.y, patch.m03.y), min(patch.m30.y, patch.m33.y)).rounded(.up))
            let max_y = Int(max(max(patch.m00.y, patch.m03.y), max(patch.m30.y, patch.m33.y)).rounded(.down))
            
            guard 0 <= max_x && min_x <= width && 0 <= max_y && min_y <= height else { return }
            
            let d0 = patch.m00 - patch.m03
            let d1 = patch.m30 - patch.m33
            let d2 = patch.m00 - patch.m30
            let d3 = patch.m03 - patch.m33
            
            if abs(d0.x) < 1 && abs(d0.y) < 1 && abs(d1.x) < 1 && abs(d1.y) < 1 && abs(d2.x) < 1 && abs(d2.y) < 1 && abs(d3.x) < 1 && abs(d3.y) < 1 {
                
                rasterizer.rasterize(patch.m00, patch.m03, patch.m30) { buf in buf.blender.draw { c8 } }
                rasterizer.rasterize(patch.m03, patch.m33, patch.m30) { buf in buf.blender.draw { c8 } }
                
            } else {
                _drawMeshGradient(rasterizer, patch, c0, c1, c2, c3)
            }
        }
        
        _draw(p0, c0, c4, c5, c8)
        _draw(p1, c4, c1, c8, c6)
        _draw(p2, c5, c8, c2, c7)
        _draw(p3, c8, c6, c7, c3)
        
    }
    
    @inlinable
    @inline(__always)
    public func drawMeshGradient<C>(_ mesh: MeshGradient<C>) {
        
        let width = self.width
        let height = self.height
        let transform = self.transform
        
        guard width != 0 && height != 0 && transform.invertible else { return }
        
        let patches = mesh.patches
        let colors = mesh.patch_colors.map { (
            Float32ColorPixel($0.convert(to: colorSpace, intent: renderingIntent)),
            Float32ColorPixel($1.convert(to: colorSpace, intent: renderingIntent)),
            Float32ColorPixel($2.convert(to: colorSpace, intent: renderingIntent)),
            Float32ColorPixel($3.convert(to: colorSpace, intent: renderingIntent))
            ) }
        
        self.withUnsafePixelBlender { blender in
            
            for (patch, var (c0, c1, c2, c3)) in zip(patches, colors) {
                
                c0.opacity *= mesh.opacity
                c1.opacity *= mesh.opacity
                c2.opacity *= mesh.opacity
                c3.opacity *= mesh.opacity
                
                let rasterizer = MeshGradientRasterizeBuffer(blender: blender, width: width, height: height)
                
                _drawMeshGradient(rasterizer, patch * transform, c0, c1, c2, c3)
            }
        }
    }
}
