//
//  Stencil.swift
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

@frozen
@usableFromInline
struct ShapeRasterizeBuffer: RasterizeBufferProtocol {
    
    @usableFromInline
    var stencil: UnsafeMutablePointer<Int16>
    
    @usableFromInline
    var width: Int
    
    @usableFromInline
    var height: Int
    
    @inlinable
    init(stencil: UnsafeMutablePointer<Int16>, width: Int, height: Int) {
        self.stencil = stencil
        self.width = width
        self.height = height
    }
    
    @inlinable
    static func + (lhs: ShapeRasterizeBuffer, rhs: Int) -> ShapeRasterizeBuffer {
        return ShapeRasterizeBuffer(stencil: lhs.stencil + rhs, width: lhs.width, height: lhs.height)
    }
    
    @inlinable
    static func += (lhs: inout ShapeRasterizeBuffer, rhs: Int) {
        lhs.stencil += rhs
    }
}

@inlinable
func _render(_ op: Shape.RenderOperation, width: Int, height: Int, stencil: UnsafeMutablePointer<Int16>) {
    
    let rasterizer = ShapeRasterizeBuffer(stencil: stencil, width: width, height: height)
    
    switch op {
    case let .triangle(p0, p1, p2):
        
        if cross(p1 - p0, p2 - p0).sign == .plus {
            rasterizer.rasterize(p0, p1, p2) { pixel in pixel.stencil.pointee += 1 }
        } else {
            rasterizer.rasterize(p0, p1, p2) { pixel in pixel.stencil.pointee -= 1 }
        }
        
    case let .quadratic(p0, p1, p2):
        
        if cross(p1 - p0, p2 - p0).sign == .plus {
            rasterizer.rasterize(p0, p1, p2) { barycentric, _, pixel in
                let s = 0.5 * barycentric.y + barycentric.z
                if s * s < barycentric.z {
                    pixel.stencil.pointee += 1
                }
            }
        } else {
            rasterizer.rasterize(p0, p1, p2) { barycentric, _, pixel in
                let s = 0.5 * barycentric.y + barycentric.z
                if s * s < barycentric.z {
                    pixel.stencil.pointee -= 1
                }
            }
        }
        
    case let .cubic(p0, p1, p2, v0, v1, v2):
        
        if cross(p1 - p0, p2 - p0).sign == .plus {
            rasterizer.rasterize(p0, p1, p2) { barycentric, _, pixel in
                let u0 = barycentric.x * v0
                let u1 = barycentric.y * v1
                let u2 = barycentric.z * v2
                let v = u0 + u1 + u2
                if v.x * v.x * v.x < v.y * v.z {
                    pixel.stencil.pointee += 1
                }
            }
        } else {
            rasterizer.rasterize(p0, p1, p2) { barycentric, _, pixel in
                let u0 = barycentric.x * v0
                let u1 = barycentric.y * v1
                let u2 = barycentric.z * v2
                let v = u0 + u1 + u2
                if v.x * v.x * v.x < v.y * v.z {
                    pixel.stencil.pointee -= 1
                }
            }
        }
    }
}

extension Shape {
    
    @inlinable
    func raster(width: Int, height: Int, stencil: inout MappedBuffer<Int16>) -> Rect {
        
        precondition(stencil.count == width * height, "incorrect size of stencil.")
        
        if stencil.isEmpty {
            return .null
        }
        
        let transform = self.transform
        
        var bound = Rect.null
        
        stencil.withUnsafeMutableBufferPointer { stencil in
            
            guard let ptr = stencil.baseAddress else { return }
            
            self.render { op in
                
                let _op = op * transform
                
                _render(_op, width: width, height: height, stencil: ptr)
                
                switch _op {
                case let .triangle(p0, p1, p2): bound = bound.union(Rect.bound([p0, p1, p2]))
                case let .quadratic(p0, p1, p2): bound = bound.union(Rect.bound([p0, p1, p2]))
                case let .cubic(p0, p1, p2, _, _, _): bound = bound.union(Rect.bound([p0, p1, p2]))
                }
            }
        }
        
        return bound
    }
}

extension ImageContext {
    
    @inlinable
    func _stencil(shape: Shape) -> (Rect, MappedBuffer<Int16>) {
        
        let transform = shape.transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        var shape = shape
        
        if shouldAntialias && antialias > 1 {
            
            shape.transform = transform * SDTransform.scale(Double(antialias))
            
            var stencil = MappedBuffer<Int16>(repeating: 0, count: width * height * antialias * antialias)
            
            let bound = shape.raster(width: width * antialias, height: height * antialias, stencil: &stencil)
            
            return (bound / Double(antialias), stencil)
            
        } else {
            
            shape.transform = transform
            
            var stencil = MappedBuffer<Int16>(repeating: 0, count: width * height)
            
            let bound = shape.raster(width: width, height: height, stencil: &stencil)
            
            return (bound, stencil)
        }
    }
}
