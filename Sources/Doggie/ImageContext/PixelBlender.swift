//
//  PixelBlender.swift
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
    let compositingMode: ColorCompositingMode
    
    @_versioned
    let blendMode: ColorBlendMode
    
    @_versioned
    @inline(__always)
    init(destination: UnsafeMutablePointer<P>, clip: UnsafePointer<Double>, opacity: Double, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
        self.destination = destination
        self.clip = clip
        self.opacity = opacity
        self.compositingMode = compositingMode
        self.blendMode = blendMode
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextPixelBlender, rhs: Int) -> ImageContextPixelBlender {
        return ImageContextPixelBlender(destination: lhs.destination + rhs, clip: lhs.clip + rhs, opacity: lhs.opacity, compositingMode: lhs.compositingMode, blendMode: lhs.blendMode)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextPixelBlender, rhs: Int) {
        lhs.destination += rhs
        lhs.clip += rhs
    }
    
    @_versioned
    @inline(__always)
    func draw<C : ColorPixelProtocol>(color: C) where C.Model == P.Model {
        
        let _clip = clip.pointee
        
        if _clip > 0 {
            var source = color
            source.opacity *= opacity * _clip
            destination.pointee.blend(source: source, compositingMode: compositingMode, blendMode: blendMode)
        }
    }
}

extension ImageContext {
    
    @_versioned
    @inline(__always)
    func withUnsafePixelBlender(_ body: (ImageContextPixelBlender<Pixel>) -> Void) {
        
        let opacity = self.opacity
        let blendMode = self.blendMode
        let compositingMode = self.compositingMode
        
        guard opacity > 0 else { return }
        
        let shadowColor = self.shadowColor
        let shadowBlur = self.shadowBlur
        
        if shadowColor.opacity > 0 && shadowBlur > 0 {
            
            let width = self.width
            let height = self.height
            let option = self.image.option
            
            let filter = gaussianBlurFilter(0.5 * shadowBlur)
            
            let shadowColor = ColorPixel(shadowColor.convert(to: colorSpace, intent: renderingIntent))
            let shadowOffset = self.shadowOffset
            let _offset = Point(x: Double(filter.count >> 1) - shadowOffset.width, y: Double(filter.count >> 1) - shadowOffset.height)
            
            var layer = Texture<Pixel>(width: width, height: height, option: option)
            
            layer.withUnsafeMutableBufferPointer { _layer in
                
                guard let _destination = _layer.baseAddress else { return }
                
                self.withUnsafeClipBufferPointer { _clip in
                    
                    guard let _clip = _clip.baseAddress else { return }
                    
                    body(ImageContextPixelBlender(destination: _destination, clip: _clip, opacity: opacity, compositingMode: compositingMode, blendMode: blendMode))
                }
            }
            
            let shadow_layer = _shadow(layer.pixels.map { $0.opacity }, filter)
            
            layer.withUnsafeBufferPointer { source in
                
                guard var source = source.baseAddress else { return }
                
                self.withUnsafeMutableImageBufferPointer { _image in
                    
                    guard let _destination = _image.baseAddress else { return }
                    
                    self.withUnsafeClipBufferPointer { _clip in
                        
                        guard let _clip = _clip.baseAddress else { return }
                        
                        var blender = ImageContextPixelBlender(destination: _destination, clip: _clip, opacity: opacity, compositingMode: compositingMode, blendMode: blendMode)
                        
                        for y in 0..<height {
                            for x in 0..<width {
                                var shadowColor = shadowColor
                                shadowColor.opacity *= shadow_layer.pixel(Point(x: x, y: y) + _offset)
                                blender.draw(color: shadowColor)
                                blender.draw(color: source.pointee)
                                blender += 1
                                source += 1
                            }
                        }
                    }
                }
            }
            
        } else {
            
            self.withUnsafeMutableImageBufferPointer { _image in
                
                guard let _destination = _image.baseAddress else { return }
                
                self.withUnsafeClipBufferPointer { _clip in
                    
                    guard let _clip = _clip.baseAddress else { return }
                    
                    body(ImageContextPixelBlender(destination: _destination, clip: _clip, opacity: opacity, compositingMode: compositingMode, blendMode: blendMode))
                }
            }
        }
    }
}
