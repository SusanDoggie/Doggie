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
            
            let width = self.width
            let height = self.height
            
            if width == 0 || height == 0 {
                return
            }
            
            self.next = ImageContext(copyStates: self, colorSpace: colorSpace)
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
                
                let width = self.width
                let height = self.height
                
                self.next = nil
                
                if width == 0 || height == 0 {
                    return
                }
                
                next.image.withUnsafeBufferPointer { source in
                    
                    if var _source = source.baseAddress {
                        
                        self.withUnsafePixelBlender { blender in
                            
                            var blender = blender
                            
                            for _ in 0..<width * height {
                                
                                blender.draw { _source.pointee }
                                
                                blender += 1
                                _source += 1
                            }
                        }
                    }
                }
            }
        }
    }
}
