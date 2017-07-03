//
//  DrawShape.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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
struct ShapeRasterizeBuffer : RasterizeBufferProtocol {
    
    @_versioned
    var stencil: UnsafeMutablePointer<Int16>
    
    @_versioned
    var width: Int
    
    @_versioned
    var height: Int
    
    @_versioned
    @inline(__always)
    init(stencil: UnsafeMutablePointer<Int16>, width: Int, height: Int) {
        self.stencil = stencil
        self.width = width
        self.height = height
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ShapeRasterizeBuffer, rhs: Int) -> ShapeRasterizeBuffer {
        return ShapeRasterizeBuffer(stencil: lhs.stencil + rhs, width: lhs.width, height: lhs.height)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ShapeRasterizeBuffer, rhs: Int) {
        lhs.stencil += rhs
    }
}

@_versioned
@inline(__always)
func _render(_ op: Shape.RenderOperation, width: Int, height: Int, transform: SDTransform, stencil: UnsafeMutablePointer<Int16>) {
    
    let rasterizer = ShapeRasterizeBuffer(stencil: stencil, width: width, height: height)
    
    switch op {
    case let .triangle(p0, p1, p2):
        
        let q0 = p0 * transform
        let q1 = p1 * transform
        let q2 = p2 * transform
        
        rasterizer.rasterize(q0, q1, q2) { point, pixel in
            
            let d = cross(q1 - q0, q2 - q0)
            
            if d.sign == .plus {
                pixel.stencil.pointee.fetchStore { $0 + 1 }
            } else {
                pixel.stencil.pointee.fetchStore { $0 - 1 }
            }
        }
        
    case let .quadratic(p0, p1, p2):
        
        let q0 = p0 * transform
        let q1 = p1 * transform
        let q2 = p2 * transform
        
        @inline(__always)
        func _test(_ point: Point) -> Bool {
            if let p = Barycentric(q0, q1, q2, point) {
                let _q = p.x * Point(x: 0, y: 0) + p.y * Point(x: 0.5, y: 0) + p.z * Point(x: 1, y: 1)
                return _q.x * _q.x - _q.y < 0
            }
            return false
        }
        
        rasterizer.rasterize(q0, q1, q2) { point, pixel in
            
            let d = cross(q1 - q0, q2 - q0)
            
            if _test(point) {
                if d.sign == .plus {
                    pixel.stencil.pointee.fetchStore { $0 + 1 }
                } else {
                    pixel.stencil.pointee.fetchStore { $0 - 1 }
                }
            }
        }
        
    case let .cubic(p0, p1, p2, v0, v1, v2):
        
        let q0 = p0 * transform
        let q1 = p1 * transform
        let q2 = p2 * transform
        
        @inline(__always)
        func _test(_ point: Point) -> Bool {
            if let p = Barycentric(q0, q1, q2, point) {
                let v = p.x * v0 + p.y * v1 + p.z * v2
                return v.x * v.x * v.x - v.y * v.z < 0
            }
            return false
        }
        
        rasterizer.rasterize(q0, q1, q2) { point, pixel in
            
            let d = cross(q1 - q0, q2 - q0)
            
            if _test(point) {
                if d.sign == .plus {
                    pixel.stencil.pointee.fetchStore { $0 + 1 }
                } else {
                    pixel.stencil.pointee.fetchStore { $0 - 1 }
                }
            }
        }
    }
}

extension Shape {
    
    @_versioned
    @inline(__always)
    func raster(width: Int, height: Int, stencil: inout [Int16]) -> Rect {
        
        assert(stencil.count == width * height, "incorrect size of stencil.")
        
        if stencil.count == 0 {
            return Rect()
        }
        
        let transform = self.transform
        
        var bound: Rect?
        
        stencil.withUnsafeMutableBufferPointer { stencil in
            
            if let ptr = stencil.baseAddress {
                
                let group = DispatchGroup()
                
                self.render { op in
                    
                    SDDefaultDispatchQueue.async(group: group) { _render(op, width: width, height: height, transform: transform, stencil: ptr) }
                    
                    switch op {
                    case let .triangle(p0, p1, p2):
                        
                        let q0 = p0 * transform
                        let q1 = p1 * transform
                        let q2 = p2 * transform
                        
                        bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                        
                    case let .quadratic(p0, p1, p2):
                        
                        let q0 = p0 * transform
                        let q1 = p1 * transform
                        let q2 = p2 * transform
                        
                        bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                        
                    case let .cubic(p0, p1, p2, _, _, _):
                        
                        let q0 = p0 * transform
                        let q1 = p1 * transform
                        let q2 = p2 * transform
                        
                        bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                    }
                }
                
                group.wait()
            }
        }
        
        return bound ?? Rect()
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func draw(shape: Shape, color: ColorPixel<Pixel.Model>, winding: (Int16) -> Bool) {
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let width = self.width
        let height = self.height
        let transform = shape.transform * self.transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        var shape = shape
        
        if antialias {
            
            shape.transform = transform * SDTransform.scale(5)
            
            var stencil = [Int16](repeating: 0, count: width * height * 25)
            
            var bound = shape.raster(width: width * 5, height: height * 5, stencil: &stencil)
            
            bound.origin /= 5
            bound.size /= 5
            
            stencil.withUnsafeBytes { stencil in
                
                if var _stencil = stencil.baseAddress?.assumingMemoryBound(to: (Int16, Int16, Int16, Int16, Int16).self) {
                    
                    self.withUnsafePixelBlender { blender in
                        
                        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                        
                        var blender = blender + offset_x + offset_y * width
                        _stencil += offset_x + 5 * offset_y * width
                        
                        for _ in 0..<_height {
                            
                            var _blender = blender
                            var __stencil = _stencil
                            
                            for _ in 0..<_width {
                                
                                var _p = 0
                                
                                var _s = __stencil
                                
                                for _ in 0..<5 {
                                    let (s0, s1, s2, s3, s4) = _s.pointee
                                    if winding(s0) { _p += 1 }
                                    if winding(s1) { _p += 1 }
                                    if winding(s2) { _p += 1 }
                                    if winding(s3) { _p += 1 }
                                    if winding(s4) { _p += 1 }
                                    _s += width
                                }
                                
                                _blender.draw(opacity: 0.04 * Double(_p)) { color }
                                
                                _blender += 1
                                __stencil += 1
                            }
                            
                            blender += width
                            _stencil += 5 * width
                        }
                    }
                }
            }
            
        } else {
            
            shape.transform = transform
            
            var stencil = [Int16](repeating: 0, count: width * height)
            
            let bound = shape.raster(width: width, height: height, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    self.withUnsafePixelBlender { blender in
                        
                        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                        
                        var blender = blender + offset_x + offset_y * width
                        _stencil += offset_x + offset_y * width
                        
                        for _ in 0..<_height {
                            
                            var _blender = blender
                            var __stencil = _stencil
                            
                            for _ in 0..<_width {
                                
                                if winding(__stencil.pointee) {
                                    _blender.draw { color }
                                }
                                
                                _blender += 1
                                __stencil += 1
                            }
                            
                            blender += width
                            _stencil += width
                        }
                    }
                }
            }
            
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func draw<C>(shape: Shape, color: Color<C>, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace, intent: renderingIntent))) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace, intent: renderingIntent))) { $0 & 1 == 1 }
        }
    }
}


