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
    
    let rasterizer = ShapeRasterizeBuffer(stencil: stencil, width: width, height: width)
    
    switch op {
    case let .triangle(p0, p1, p2):
        
        let q0 = p0 * transform
        let q1 = p1 * transform
        let q2 = p2 * transform
        
        rasterizer.rasterize(q0, q1, q2) { d, point, pixel in
            
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
        
        if let transform = SDTransform(from: q0, q1, q2, to: Point(x: 0, y: 0), Point(x: 0.5, y: 0), Point(x: 1, y: 1)) {
            
            @inline(__always)
            func _test(_ point: Point) -> Bool {
                let _q = point * transform
                return _q.x * _q.x - _q.y < 0
            }
            
            rasterizer.rasterize(q0, q1, q2) { d, point, pixel in
                
                if _test(point) {
                    if d.sign == .plus {
                        pixel.stencil.pointee.fetchStore { $0 + 1 }
                    } else {
                        pixel.stencil.pointee.fetchStore { $0 - 1 }
                    }
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
        
        rasterizer.rasterize(q0, q1, q2) { d, point, pixel in
            
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
    func raster(width: Int, height: Int, stencil: inout [Int16]) {
        
        assert(stencil.count == width * height, "incorrect size of stencil.")
        
        if stencil.count == 0 {
            return
        }
        
        let transform = self.transform
        
        stencil.withUnsafeMutableBufferPointer { stencil in
            
            if let ptr = stencil.baseAddress {
                
                let group = DispatchGroup()
                
                self.render { op in SDDefaultDispatchQueue.async(group: group) { _render(op, width: width, height: width, transform: transform, stencil: ptr) } }
                
                group.wait()
            }
        }
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func draw(shape: Shape, color: ColorPixel<Model>, winding: (Int16) -> Bool) {
        
        if let next = self.next {
            next.draw(shape: shape, color: color, winding: winding)
            return
        }
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let width = self.width
        let height = self.height
        let transform = shape.transform * self._transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let stencil_count = _antialias ? width * height * 25 : width * height
        
        if stencil.count != stencil_count {
            stencil = [Int16](repeating: 0, count: stencil_count)
        } else {
            stencil.withUnsafeMutableBytes { _ = memset($0.baseAddress!, 0, $0.count) }
        }
        
        var shape = shape
        
        if _antialias {
            
            shape.transform = transform * SDTransform.scale(5)
            
            shape.raster(width: width * 5, height: height * 5, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<height {
                                        
                                        var __stencil = _stencil
                                        
                                        for _ in 0..<width {
                                            
                                            var _p = 0
                                            
                                            var _s = __stencil
                                            
                                            for _ in 0..<5 {
                                                var __s = _s
                                                for _ in 0..<5 {
                                                    if winding(__s.pointee) {
                                                        _p += 1
                                                    }
                                                    __s += 1
                                                }
                                                _s += 5 * width
                                            }
                                            
                                            let _alpha = _clip.pointee * (0.04 * Double(_p))
                                            
                                            if _alpha > 0 {
                                                
                                                var source = color
                                                source.opacity *= _opacity * _alpha
                                                
                                                _destination.pointee.blend(source: source, blendMode: _blendMode, compositingMode: _compositingMode)
                                            }
                                            
                                            __stencil += 5
                                            _destination += 1
                                            _clip += 1
                                        }
                                        
                                        _stencil += 25 * width
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            
            shape.transform = transform
            
            shape.raster(width: width, height: height, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<width * height {
                                        
                                        let _alpha = _clip.pointee
                                        
                                        if winding(_stencil.pointee) && _alpha > 0 {
                                            
                                            var source = color
                                            source.opacity *= _opacity * _alpha
                                            
                                            _destination.pointee.blend(source: source, blendMode: _blendMode, compositingMode: _compositingMode)
                                        }
                                        
                                        _stencil += 1
                                        _destination += 1
                                        _clip += 1
                                    }
                                }
                            }
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
        case .nonZero: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace))) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace))) { $0 & 1 == 1 }
        }
    }
}
