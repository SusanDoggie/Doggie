//
//  PixelBlender.swift
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

@_versioned
@_fixed_layout
struct ImageContextPixelBlender<P : ColorPixelProtocol> {
    
    @_versioned
    var destination: UnsafeMutablePointer<P>
    
    @_versioned
    var clip: UnsafePointer<Double>
    
    @_versioned
    let opacity: Double
    
    @_versioned
    let blendMode: ColorBlendMode
    
    @_versioned
    let compositingMode: ColorCompositingMode
    
    @_versioned
    @inline(__always)
    init(destination: UnsafeMutablePointer<P>, clip: UnsafePointer<Double>, opacity: Double, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        self.destination = destination
        self.clip = clip
        self.opacity = opacity
        self.blendMode = blendMode
        self.compositingMode = compositingMode
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextPixelBlender, rhs: Int) -> ImageContextPixelBlender {
        return ImageContextPixelBlender(destination: lhs.destination + rhs, clip: lhs.clip + rhs, opacity: lhs.opacity, blendMode: lhs.blendMode, compositingMode: lhs.compositingMode)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextPixelBlender, rhs: Int) {
        lhs.destination += rhs
        lhs.clip += rhs
    }
    
    @_versioned
    @inline(__always)
    func draw<C : ColorPixelProtocol>(opacity: Double = 1, _ color: () -> C?) where C.Model == P.Model {
        
        let _alpha = clip.pointee * opacity
        
        if _alpha > 0, var source = color() {
            source.opacity *= self.opacity * _alpha
            destination.pointee.blend(source: source, blendMode: blendMode, compositingMode: compositingMode)
        }
    }
}

extension ImageContext {
    
    @_versioned
    @inline(__always)
    func withUnsafePixelBlender(_ body: (ImageContextPixelBlender<Pixel>) -> Void) {
        
        self.withUnsafeMutableImageBufferPointer { _image in
            
            guard let _destination = _image.baseAddress else { return }
            
            self.withUnsafeClipBufferPointer { _clip in
                
                guard let _clip = _clip.baseAddress else { return }
                
                body(ImageContextPixelBlender(destination: _destination, clip: _clip, opacity: opacity, blendMode: blendMode, compositingMode: compositingMode))
            }
        }
    }
}
