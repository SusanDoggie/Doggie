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

import Foundation
import Dispatch

extension ImageContext {
    
    @_versioned
    @_inlineable
    func setClip(shape: Shape, winding: (Int16) -> Bool) {
        
        self.clearClipBuffer(with: 0)
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let width = self.width
        let height = self.height
        let transform = shape.transform * self.transform
        
        if width == 0 || height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let (bound, stencil) = self._stencil(shape: shape)
        
        if antialias {
            
            stencil.withUnsafeBytes { stencil in
                
                guard var _stencil = stencil.baseAddress?.assumingMemoryBound(to: (Int16, Int16, Int16, Int16, Int16).self) else { return }
                
                self.withUnsafeMutableClipBufferPointer { buffer in
                    
                    guard var clip = buffer.baseAddress else { return }
                    
                    let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                    let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                    let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                    let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                    
                    clip += offset_x + offset_y * width
                    _stencil += offset_x + 5 * offset_y * width
                    
                    let n = ProcessInfo.processInfo.activeProcessorCount
                    
                    let _count = _height / n
                    let _remain = _height % n
                    
                    DispatchQueue.concurrentPerform(iterations: _remain == 0 ? n : n + 1) {
                        
                        var clip = clip + $0 * _count * width
                        var _stencil = _stencil + 5 * $0 * _count * width
                        
                        for _ in 0..<($0 != n ? _count : _remain) {
                            
                            var _clip = clip
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
                                
                                _clip.pointee = 0.04 * Double(_p)
                                
                                _clip += 1
                                __stencil += 1
                            }
                            
                            clip += width
                            _stencil += 5 * width
                        }
                    }
                }
            }
        } else {
            
            stencil.withUnsafeBufferPointer { stencil in
                
                guard var _stencil = stencil.baseAddress else { return }
                
                self.withUnsafeMutableClipBufferPointer { buffer in
                    
                    guard var clip = buffer.baseAddress else { return }
                    
                    let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
                    let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
                    let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
                    let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
                    
                    clip += offset_x + offset_y * width
                    _stencil += offset_x + offset_y * width
                    
                    let n = ProcessInfo.processInfo.activeProcessorCount
                    
                    let _count = _height / n
                    let _remain = _height % n
                    
                    DispatchQueue.concurrentPerform(iterations: _remain == 0 ? n : n + 1) {
                        
                        var clip = clip + $0 * _count * width
                        var _stencil = _stencil + $0 * _count * width
                        
                        for _ in 0..<($0 != n ? _count : _remain) {
                            
                            var _clip = clip
                            var __stencil = _stencil
                            
                            for _ in 0..<_width {
                                
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
}

extension ImageContext {
    
    @_inlineable
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.setClip(shape: shape) { $0 != 0 }
        case .evenOdd: self.setClip(shape: shape) { $0 & 1 == 1 }
        }
    }
}

