//
//  TransparencyLayer.swift
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

extension ImageContext {
    
    @_inlineable
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            if _image.width == 0 || _image.height == 0 {
                return
            }
            
            let layer = ImageContext(width: _image.width, height: _image.height, colorSpace: colorSpace)
            layer._antialias = self._antialias
            layer._transform = self._transform
            layer._resamplingAlgorithm = self._resamplingAlgorithm
            
            self.next = layer
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func endTransparencyLayer() {
        
        if let next = self.next {
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                if _image.width == 0 || _image.height == 0 {
                    return
                }
                
                next.image.withUnsafeBufferPointer { source in
                    
                    if var _source = source.baseAddress {
                        
                        _image.withUnsafeMutableBufferPointer { destination in
                            
                            if var _destination = destination.baseAddress {
                                
                                clip.withUnsafeBufferPointer { _clip in
                                    
                                    if var _clip = _clip.baseAddress {
                                        
                                        for _ in 0..<_image.width * _image.height {
                                            
                                            let _alpha = _clip.pointee
                                            
                                            if _alpha > 0 {
                                                
                                                var __source = _source.pointee
                                                __source.opacity *= _opacity * _alpha
                                                
                                                _destination.pointee.blend(source: __source, blendMode: _blendMode, compositingMode: _compositingMode)
                                            }
                                            
                                            _source += 1
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
}
