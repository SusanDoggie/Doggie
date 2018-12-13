//
//  SetClip.swift
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
    
    @inlinable
    @inline(__always)
    func setClip(shape: Shape, winding: (Int16) -> Bool) {
        
        self.clearClipBuffer(with: 0)
        
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
        
        let _min_x = max(0, Int(floor(bound.minX)))
        let _min_y = max(0, Int(floor(bound.minY)))
        let _max_x = min(width, Int(ceil(bound.maxX)))
        let _max_y = min(height, Int(ceil(bound.maxY)))
        
        guard _max_x > _min_x && _max_y > _min_y else { return }
        
        if shouldAntialias && antialias > 1 {
            
            stencil.withUnsafeBufferPointer { stencil in
                
                guard var _stencil = stencil.baseAddress else { return }
                
                self.withUnsafeMutableClipBufferPointer { buffer in
                    
                    guard var clip = buffer.baseAddress else { return }
                    
                    let _stencil_width = antialias * width
                    let _stencil_width2 = antialias * _stencil_width
                    
                    clip += _min_x + _min_y * width
                    _stencil += antialias * _min_x + _min_y * _stencil_width2
                    
                    let _antialias2 = antialias * antialias
                    let div = 1 / Double(_antialias2)
                    
                    for _ in _min_y..<_max_y {
                        
                        var _clip = clip
                        var __stencil = _stencil
                        
                        for _ in _min_x..<_max_x {
                            
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
                                _clip.pointee = _p == _antialias2 ? 1 : div * Double(_p)
                            }
                            
                            _clip += 1
                            __stencil += antialias
                        }
                        
                        clip += width
                        _stencil += _stencil_width2
                    }
                }
            }
        } else {
            
            stencil.withUnsafeBufferPointer { stencil in
                
                guard var _stencil = stencil.baseAddress else { return }
                
                self.withUnsafeMutableClipBufferPointer { buffer in
                    
                    guard var clip = buffer.baseAddress else { return }
                    
                    clip += _min_x + _min_y * width
                    _stencil += _min_x + _min_y * width
                    
                    for _ in _min_y..<_max_y {
                        
                        var _clip = clip
                        var __stencil = _stencil
                        
                        for _ in _min_x..<_max_x {
                            
                            if winding(__stencil.pointee) {
                                _clip.pointee = 1
                            }
                            
                            _clip += 1
                            __stencil += 1
                        }
                        
                        clip += width
                        _stencil += width
                    }
                }
            }
        }
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.setClip(shape: shape) { $0 != 0 }
        case .evenOdd: self.setClip(shape: shape) { $0 & 1 == 1 }
        }
    }
}
