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

extension ImageContext {
    
    fileprivate func draw(shape: Shape, color: ColorPixel<Model>, winding: (Int) -> Bool) {
        
        if let next = self.next {
            next.draw(shape: shape, color: color, winding: winding)
            return
        }
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let transform = shape.transform * self._transform
        
        if _image.width == 0 || _image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let stencil_count = _antialias ? _image.width * _image.height * 25 : _image.width * _image.height
        
        if stencil.count != stencil_count {
            stencil = [Int](repeating: 0, count: stencil_count)
        } else {
            stencil.withUnsafeMutableBytes { _ = memset($0.baseAddress!, 0, $0.count) }
        }
        
        var shape = shape
        
        if _antialias {
            
            shape.transform = transform * SDTransform.scale(5)
            
            shape.raster(width: _image.width * 5, height: _image.height * 5, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<image.height {
                                        
                                        var __stencil = _stencil
                                        
                                        for _ in 0..<image.width {
                                            
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
                                                _s += 5 * image.width
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
                                        
                                        _stencil += 25 * image.width
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            
            shape.transform = transform
            
            shape.raster(width: _image.width, height: _image.height, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<image.width * image.height {
                                        
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
    
    public func draw<C>(shape: Shape, color: Color<C>, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace))) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: ColorPixel(color.convert(to: colorSpace))) { $0 & 1 == 1 }
        }
    }
}
