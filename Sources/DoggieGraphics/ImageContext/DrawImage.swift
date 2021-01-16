//
//  DrawImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func draw<T>(stencil: StencilTexture<T>, transform: SDTransform, color: Pixel.Model) {
        
        let width = self.width
        let height = self.height
        let s_width = stencil.width
        let s_height = stencil.height
        let transform = transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        guard width != 0 && height != 0 && s_width != 0 && s_height != 0 && transform.invertible else { return }
        
        let _transform = transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            if shouldAntialias && antialias > 1 {
                
                var blender = blender
                
                let __transform = SDTransform.scale(1 / Double(antialias)) * _transform
                let div = Double(antialias * antialias)
                
                stencil.withUnsafeStencilTexture { stencil in
                    for y in stride(from: 0, to: height * antialias, by: antialias) {
                        for x in stride(from: 0, to: width * antialias, by: antialias) {
                            blender.draw { () -> Float32ColorPixel<Pixel.Model> in
                                var pixel: T = 0
                                for _y in y..<y + antialias {
                                    for _x in x..<x + antialias {
                                        pixel += stencil.pixel(Point(x: _x, y: _y) * __transform)
                                    }
                                }
                                return Float32ColorPixel(color: color, opacity: Double(pixel) / div)
                            }
                            blender += 1
                        }
                    }
                }
                
            } else {
                
                var blender = blender
                
                stencil.withUnsafeStencilTexture { stencil in
                    for y in 0..<height {
                        for x in 0..<width {
                            blender.draw { Float32ColorPixel(color: color, opacity: Double(stencil.pixel(Point(x: x, y: y) * _transform))) }
                            blender += 1
                        }
                    }
                }
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Pixel.Model {
        
        let width = self.width
        let height = self.height
        let s_width = texture.width
        let s_height = texture.height
        let transform = transform * self.transform
        let shouldAntialias = self.shouldAntialias
        let antialias = self.antialias
        
        guard width != 0 && height != 0 && s_width != 0 && s_height != 0 && transform.invertible else { return }
        
        let _transform = transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            if shouldAntialias && antialias > 1 {
                
                var blender = blender
                
                let __transform = SDTransform.scale(1 / Double(antialias)) * _transform
                let div = Float(antialias * antialias)
                
                texture.withUnsafeTexture { texture in
                    for y in stride(from: 0, to: height * antialias, by: antialias) {
                        for x in stride(from: 0, to: width * antialias, by: antialias) {
                            blender.draw { () -> Float32ColorPixel<Pixel.Model> in
                                var pixel = Float32ColorPixel<Pixel.Model>()
                                for _y in y..<y + antialias {
                                    for _x in x..<x + antialias {
                                        pixel += texture.pixel(Point(x: _x, y: _y) * __transform)
                                    }
                                }
                                return pixel / div
                            }
                            blender += 1
                        }
                    }
                }
                
            } else {
                
                var blender = blender
                
                texture.withUnsafeTexture { texture in
                    for y in 0..<height {
                        for x in 0..<width {
                            blender.draw { texture.pixel(Point(x: x, y: y) * _transform) }
                            blender += 1
                        }
                    }
                }
            }
        }
    }
}

extension StencilTexture {
    
    @usableFromInline
    struct _UnsafeStencilTexture: _ResamplingImplement {
        
        @usableFromInline
        let pixels: UnsafeBufferPointer<RawPixel>
        
        @usableFromInline
        let width: Int
        
        @usableFromInline
        let height: Int
        
        @usableFromInline
        let resamplingAlgorithm: ResamplingAlgorithm
        
        @usableFromInline
        let horizontalWrappingMode: WrappingMode
        
        @usableFromInline
        let verticalWrappingMode: WrappingMode
        
        @inlinable
        @inline(__always)
        init(_ pixels: UnsafeBufferPointer<T>, width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm, horizontalWrappingMode: WrappingMode, verticalWrappingMode: WrappingMode) {
            self.pixels = pixels
            self.width = width
            self.height = height
            self.resamplingAlgorithm = resamplingAlgorithm
            self.horizontalWrappingMode = horizontalWrappingMode
            self.verticalWrappingMode = verticalWrappingMode
        }
    }
}

extension StencilTexture._UnsafeStencilTexture {
    
    @inlinable
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> T {
        
        guard width != 0 && height != 0 else { return 0 }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? pixel : 0
    }
}

extension StencilTexture {
    
    @inlinable
    @inline(__always)
    func withUnsafeStencilTexture<R>(_ body: (_UnsafeStencilTexture) throws -> R) rethrows -> R {
        
        let width = self.width
        let height = self.height
        let resamplingAlgorithm = self.resamplingAlgorithm
        let horizontalWrappingMode = self.horizontalWrappingMode
        let verticalWrappingMode = self.verticalWrappingMode
        
        return try withUnsafeBufferPointer { try body(_UnsafeStencilTexture($0, width: width, height: height, resamplingAlgorithm: resamplingAlgorithm, horizontalWrappingMode: horizontalWrappingMode, verticalWrappingMode: verticalWrappingMode)) }
    }
}

extension Texture {
    
    @usableFromInline
    struct _UnsafeTexture: _ResamplingImplement {
        
        @usableFromInline
        let pixels: UnsafeBufferPointer<RawPixel>
        
        @usableFromInline
        let width: Int
        
        @usableFromInline
        let height: Int
        
        @usableFromInline
        let resamplingAlgorithm: ResamplingAlgorithm
        
        @usableFromInline
        let horizontalWrappingMode: WrappingMode
        
        @usableFromInline
        let verticalWrappingMode: WrappingMode
        
        @inlinable
        @inline(__always)
        init(_ pixels: UnsafeBufferPointer<RawPixel>, width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm, horizontalWrappingMode: WrappingMode, verticalWrappingMode: WrappingMode) {
            self.pixels = pixels
            self.width = width
            self.height = height
            self.resamplingAlgorithm = resamplingAlgorithm
            self.horizontalWrappingMode = horizontalWrappingMode
            self.verticalWrappingMode = verticalWrappingMode
        }
    }
}

extension Texture._UnsafeTexture {
    
    @inlinable
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> Float32ColorPixel<RawPixel.Model> {
        
        guard width != 0 && height != 0 else { return Float32ColorPixel() }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? Float32ColorPixel(pixel) : Float32ColorPixel(color: pixel.color, opacity: 0)
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    func withUnsafeTexture<R>(_ body: (_UnsafeTexture) throws -> R) rethrows -> R {
        
        let width = self.width
        let height = self.height
        let resamplingAlgorithm = self.resamplingAlgorithm
        let horizontalWrappingMode = self.horizontalWrappingMode
        let verticalWrappingMode = self.verticalWrappingMode
        
        return try withUnsafeBufferPointer { try body(_UnsafeTexture($0, width: width, height: height, resamplingAlgorithm: resamplingAlgorithm, horizontalWrappingMode: horizontalWrappingMode, verticalWrappingMode: verticalWrappingMode)) }
    }
}
