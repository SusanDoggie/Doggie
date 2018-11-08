//
//  DrawShadow.swift
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
    
    @_transparent
    @usableFromInline
    var isShadow: Bool {
        return shadowColor.opacity > 0 && shadowBlur > 0
    }
    
    @inlinable
    @inline(__always)
    func _drawWithShadow(stencil: MappedBuffer<Float>, color: ColorPixel<Pixel.Model>) {
        
        let width = self.width
        let height = self.height
        
        let shadowColor = ColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        let shadowOffset = self.shadowOffset
        let shadowBlur = self.shadowBlur
        
        let filter = GaussianBlurFilter(Float(0.5 * shadowBlur))
        let _offset = Point(x: Double(filter.count >> 1) - shadowOffset.width, y: Double(filter.count >> 1) - shadowOffset.height)
        
        let shadow_layer = StencilTexture(width: width, height: height, pixels: stencil, resamplingAlgorithm: .linear)._apply(filter)
        
        stencil.withUnsafeBufferPointer { stencil in
            
            guard var stencil = stencil.baseAddress else { return }
            
            self._withUnsafePixelBlender { blender in
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var shadowColor = shadowColor
                            shadowColor.opacity *= Double(shadow_layer.pixel(Point(x: x, y: y) + _offset))
                            return shadowColor
                        }
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var color = color
                            color.opacity *= Double(stencil.pointee)
                            return color
                        }
                        blender += 1
                        stencil += 1
                    }
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    func _drawWithShadow(texture: Texture<Pixel>) {
        
        let width = self.width
        let height = self.height
        
        let shadowColor = ColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        let shadowOffset = self.shadowOffset
        let shadowBlur = self.shadowBlur
        
        let filter = GaussianBlurFilter(Float(0.5 * shadowBlur))
        let _offset = Point(x: Double(filter.count >> 1) - shadowOffset.width, y: Double(filter.count >> 1) - shadowOffset.height)
        
        var shadow_layer = StencilTexture<Float>(texture: texture)._apply(filter)
        shadow_layer.resamplingAlgorithm = .linear
        
        texture.withUnsafeBufferPointer { source in
            
            guard var source = source.baseAddress else { return }
            
            self._withUnsafePixelBlender { blender in
                
                var blender = blender
                
                for y in 0..<height {
                    for x in 0..<width {
                        blender.draw { () -> ColorPixel<Pixel.Model> in
                            var shadowColor = shadowColor
                            shadowColor.opacity *= Double(shadow_layer.pixel(Point(x: x, y: y) + _offset))
                            return shadowColor
                        }
                        blender.draw { source.pointee }
                        blender += 1
                        source += 1
                    }
                }
            }
        }
    }
}

extension StencilTexture {
    
    @inlinable
    @inline(__always)
    func _apply(_ filter: [T]) -> StencilTexture {
        
        let width = self.width
        let height = self.height
        let fileBacked = self.fileBacked
        let resamplingAlgorithm = self.resamplingAlgorithm
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length1 = Radix2CircularConvolveLength(width, filter.count)
        let length2 = Radix2CircularConvolveLength(height, filter.count)
        
        var buffer = MappedBuffer<T>(repeating: 0, count: length1 + length2 + length1 * height, fileBacked: fileBacked)
        var result = StencilTexture<T>(width: n_width, height: length2, resamplingAlgorithm: resamplingAlgorithm, fileBacked: fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            self.withUnsafeBufferPointer {
                
                guard let source = $0.baseAddress else { return }
                
                result.withUnsafeMutableBufferPointer {
                    
                    guard let output = $0.baseAddress else { return }
                    
                    let level1 = log2(length1)
                    let level2 = log2(length2)
                    
                    let _kreal1 = buffer
                    let _kimag1 = buffer + 1
                    let _kreal2 = buffer + length1
                    let _kimag2 = _kreal2 + 1
                    let _temp = _kreal2 + length2
                    
                    HalfRadix2CooleyTukey(level1, filter, 1, filter.count, _kreal1, _kimag1, 2)
                    
                    var _length1 = T(length1)
                    Div(length1, _kreal1, _kimag1, 2, &_length1, 0, _kreal1, _kimag1, 2)
                    
                    HalfRadix2CooleyTukey(level2, filter, 1, filter.count, _kreal2, _kimag2, 2)
                    
                    var _length2 = T(length2)
                    Div(length2, _kreal2, _kimag2, 2, &_length2, 0, _kreal2, _kimag2, 2)
                    
                    _Radix2FiniteImpulseFilter(level1, height, source, 1, width, width, _kreal1, _kimag1, 2, 0, _temp, 1, length1)
                    _Radix2FiniteImpulseFilter(level2, n_width, _temp, length1, 1, height, _kreal2, _kimag2, 2, 0, output, n_width, 1)
                }
            }
        }
        
        return result
    }
}
