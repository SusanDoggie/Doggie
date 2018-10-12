//
//  DrawShape.swift
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
    @usableFromInline
    func draw(shape: Shape, color: ColorPixel<Pixel.Model>, winding: (Int16) -> Bool) {
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let width = self.width
        let height = self.height
        let transform = shape.transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let (bound, stencil) = self._stencil(shape: shape)
        
        if shouldAntialias && antialias > 1 {
            
            stencil.withUnsafeBufferPointer { stencil in
                
                guard var _stencil = stencil.baseAddress else { return }
                
                if isShadow {
                    
                    var buf = MappedBuffer<Float>(repeating: 0, count: width * height, option: image.option)
                    
                    buf.withUnsafeMutableBufferPointer {
                        
                        guard var buf = $0.baseAddress else { return }
                        
                        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                        
                        let _stencil_width = antialias * width
                        let _stencil_width2 = antialias * _stencil_width
                        
                        buf += offset_x + offset_y * width
                        _stencil += antialias * offset_x + offset_y * _stencil_width2
                        
                        let _antialias2 = antialias * antialias
                        let div = 1 / Float(_antialias2)
                        
                        for _ in 0..<_height {
                            
                            var _buf = buf
                            var __stencil = _stencil
                            
                            for _ in 0..<_width {
                                
                                var _p: UInt8 = 0
                                
                                var _s = __stencil
                                
                                for _ in 0..<antialias {
                                    var __s = _s
                                    for _ in 0..<antialias {
                                        if winding(__s.pointee) {
                                            _p = _p &+ 1
                                        }
                                        __s += 1
                                    }
                                    _s += _stencil_width
                                }
                                
                                if _p != 0 {
                                    _buf.pointee = _p == _antialias2 ? 1 : div * Float(_p)
                                }
                                
                                _buf += 1
                                __stencil += antialias
                            }
                            
                            buf += width
                            _stencil += _stencil_width2
                        }
                    }
                    
                    self._drawWithShadow(stencil: buf, color: color)
                    
                } else {
                    
                    self._withUnsafePixelBlender { blender in
                        
                        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                        
                        let _stencil_width = antialias * width
                        let _stencil_width2 = antialias * _stencil_width
                        
                        var blender = blender + offset_x + offset_y * width
                        _stencil += antialias * offset_x + offset_y * _stencil_width2
                        
                        let _antialias2 = antialias * antialias
                        let div = 1 / Double(_antialias2)
                        
                        for _ in 0..<_height {
                            
                            var _blender = blender
                            var __stencil = _stencil
                            
                            for _ in 0..<_width {
                                
                                _blender.draw { () -> ColorPixel<Pixel.Model>? in
                                    
                                    var _p: UInt8 = 0
                                    
                                    var _s = __stencil
                                    
                                    for _ in 0..<antialias {
                                        var __s = _s
                                        for _ in 0..<antialias {
                                            if winding(__s.pointee) {
                                                _p = _p &+ 1
                                            }
                                            __s += 1
                                        }
                                        _s += _stencil_width
                                    }
                                    
                                    if _p != 0 {
                                        var color = color
                                        if _p != _antialias2 {
                                            color.opacity *= div * Double(_p)
                                        }
                                        return color
                                    }
                                    
                                    return nil
                                }
                                
                                _blender += 1
                                __stencil += antialias
                            }
                            
                            blender += width
                            _stencil += _stencil_width2
                        }
                    }
                }
            }
            
        } else {
            
            if isShadow {
                
                self._drawWithShadow(stencil: stencil.map { winding($0) ? 1.0 : 0.0 }, color: color)
                
            } else {
                
                stencil.withUnsafeBufferPointer { stencil in
                    
                    guard var _stencil = stencil.baseAddress else { return }
                    
                    self._withUnsafePixelBlender { blender in
                        
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
    
    @inline(__always)
    public func draw(shape: Shape, winding: Shape.WindingRule, color: Pixel.Model, opacity: Double = 1) {
        switch winding {
        case .nonZero: self.draw(shape: shape, color: ColorPixel(color: color, opacity: opacity)) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: ColorPixel(color: color, opacity: opacity)) { $0 & 1 == 1 }
        }
    }
}
