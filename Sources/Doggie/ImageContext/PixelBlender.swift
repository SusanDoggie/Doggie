//
//  PixelBlender.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
@usableFromInline
struct ImageContextPixelBlender<P : ColorPixelProtocol> {
    
    @usableFromInline
    var destination: UnsafeMutablePointer<P>
    
    @usableFromInline
    var clip: UnsafePointer<Double>?
    
    @usableFromInline
    let opacity: Double
    
    @usableFromInline
    let compositingMode: ColorCompositingMode
    
    @usableFromInline
    let blendMode: ColorBlendMode
    
    @inlinable
    @inline(__always)
    init(destination: UnsafeMutablePointer<P>, clip: UnsafePointer<Double>?, opacity: Double, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
        self.destination = destination
        self.clip = clip
        self.opacity = opacity
        self.compositingMode = compositingMode
        self.blendMode = blendMode
    }
    
    @inlinable
    @inline(__always)
    static func + (lhs: ImageContextPixelBlender, rhs: Int) -> ImageContextPixelBlender {
        return ImageContextPixelBlender(destination: lhs.destination + rhs, clip: lhs.clip.map { $0 + rhs }, opacity: lhs.opacity, compositingMode: lhs.compositingMode, blendMode: lhs.blendMode)
    }
    
    @inlinable
    @inline(__always)
    static func += (lhs: inout ImageContextPixelBlender, rhs: Int) {
        lhs.destination += rhs
        lhs.clip = lhs.clip.map { $0 + rhs }
    }
    
    @inlinable
    @inline(__always)
    func draw<C : ColorPixelProtocol>(color: () -> C) where C.Model == P.Model {
        self._draw { color() }
    }
    
    @inlinable
    @inline(__always)
    func draw<C : ColorPixelProtocol>(color: () -> C?) where C.Model == P.Model {
        self._draw { color() }
    }
    
    @inlinable
    @inline(__always)
    func _draw<C : ColorPixelProtocol>(color: () -> C?) where C.Model == P.Model {
        
        if let _clip = clip?.pointee {
            if _clip > 0, var source = color() {
                source.opacity *= opacity * _clip
                destination.pointee.blend(source: source, compositingMode: compositingMode, blendMode: blendMode)
            }
        } else if var source = color() {
            source.opacity *= opacity
            destination.pointee.blend(source: source, compositingMode: compositingMode, blendMode: blendMode)
        }
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    func _withUnsafePixelBlender(_ body: (ImageContextPixelBlender<Pixel>) -> Void) {
        
        let opacity = self.opacity
        let blendMode = self.blendMode
        let compositingMode = self.compositingMode
        
        guard opacity > 0 else { return }
        
        self.withUnsafeClipBufferPointer { _clip in
            
            self.withUnsafeMutableImageBufferPointer { _image in
                
                guard let _destination = _image.baseAddress else { return }
                
                body(ImageContextPixelBlender(destination: _destination, clip: _clip?.baseAddress, opacity: opacity, compositingMode: compositingMode, blendMode: blendMode))
            }
        }
    }
    
    @inlinable
    @inline(__always)
    func withUnsafePixelBlender(_ body: (ImageContextPixelBlender<Pixel>) -> Void) {
        
        let opacity = self.opacity
        let blendMode = self.blendMode
        let compositingMode = self.compositingMode
        
        guard opacity > 0 else { return }
        
        if self.isShadow {
            
            var layer = Texture<Pixel>(width: width, height: height, fileBacked: image.fileBacked)
            
            self.withUnsafeClipBufferPointer { _clip in
                
                layer.withUnsafeMutableBufferPointer { _layer in
                    
                    guard let _destination = _layer.baseAddress else { return }
                    
                    body(ImageContextPixelBlender(destination: _destination, clip: _clip?.baseAddress, opacity: opacity, compositingMode: compositingMode, blendMode: blendMode))
                }
            }
            
            self._drawWithShadow(texture: layer)
            
        } else {
            
            self._withUnsafePixelBlender(body)
        }
    }
}
