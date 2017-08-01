//
//  DrawImage.swift
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

public enum ResamplingAlgorithm {
    
    case none
    case linear
    case cosine
    case cubic
    case hermite(Double, Double)
    case mitchell(Double, Double)
    case lanczos(UInt)
}

extension ResamplingAlgorithm {
    
    @_inlineable
    public static var `default` : ResamplingAlgorithm {
        return .linear
    }
}

extension ImageContext {
    
    @_inlineable
    public func draw<C>(image: Image<C>, transform: SDTransform) {
        
        let width = self.width
        let height = self.height
        let transform = transform * self.transform
        
        if width == 0 || height == 0 || image.width == 0 || image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let s_width = image.width
        let s_height = image.height
        
        let source = Image<ColorPixel<Pixel.Model>>(image: image, colorSpace: colorSpace, intent: renderingIntent)
        
        source.withUnsafeBufferPointer { source in
            
            if var _source = source.baseAddress {
                
                self.withUnsafePixelBlender { blender in
                    
                    switch self.resamplingAlgorithm {
                    case .none:
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return read_source(source.baseAddress!, s_width, s_height, Int(point.x), Int(point.y))
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case .linear:
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return smapling2(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: LinearInterpolate)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case .cosine:
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return smapling2(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: CosineInterpolate)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case .cubic:
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return smapling4(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: CubicInterpolate)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case let .hermite(s, e):
                        
                        @inline(__always)
                        func _kernel(_ t: Double, _ a: ColorPixel<Pixel.Model>, _ b: ColorPixel<Pixel.Model>, _ c: ColorPixel<Pixel.Model>, _ d: ColorPixel<Pixel.Model>) -> ColorPixel<Pixel.Model> {
                            return HermiteInterpolate(t, a, b, c, d, s, e)
                        }
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return smapling4(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: _kernel)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case let .mitchell(B, C):
                        
                        let a1 = 12 - 9 * B - 6 * C
                        let b1 = -18 + 12 * B + 6 * C
                        let c1 = 6 - 2 * B
                        let a2 = -B - 6 * C
                        let b2 = 6 * B + 30 * C
                        let c2 = -12 * B - 48 * C
                        let d2 = 8 * B + 24 * C
                        
                        @inline(__always)
                        func _kernel(_ x: Double) -> Double {
                            if x < 1 {
                                return (a1 * x + b1) * x * x + c1
                            }
                            if x < 2 {
                                return ((a2 * x + b2) * x + c2) * x + d2
                            }
                            return 0
                        }
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return convolve(source: source.baseAddress!, width: s_width, height: s_height, point: point, kernel_size: 5, kernel: _kernel)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case .lanczos(1):
                        
                        @inline(__always)
                        func _kernel(_ x: Double) -> Double {
                            if x == 0 {
                                return 1
                            }
                            if x < 1 {
                                let _x = Double.pi * x
                                let _sinc = sin(_x) / _x
                                return _sinc * _sinc
                            }
                            return 0
                        }
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return convolve(source: source.baseAddress!, width: s_width, height: s_height, point: point, kernel_size: 2, kernel: _kernel)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                        
                    case let .lanczos(a):
                        
                        @inline(__always)
                        func _kernel(_ x: Double) -> Double {
                            let a = Double(a)
                            if x == 0 {
                                return 1
                            }
                            if x < a {
                                let _x = Double.pi * x
                                return a * sin(_x) * sin(_x / a) / (_x * _x)
                            }
                            return 0
                        }
                        
                        @inline(__always)
                        func op(point: Point) -> ColorPixel<Pixel.Model> {
                            return convolve(source: source.baseAddress!, width: s_width, height: s_height, point: point, kernel_size: Int(a) << 1, kernel: _kernel)
                        }
                        
                        self.filling(blender, transform.inverse, op)
                    }
                }
            }
        }
    }
    
    @_versioned
    @inline(__always)
    func read_source(_ source: UnsafePointer<ColorPixel<Pixel.Model>>, _ width: Int, _ height: Int, _ x: Int, _ y: Int) -> ColorPixel<Pixel.Model> {
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        if x_range ~= x && y_range ~= y {
            
            return source[y * width + x]
        }
        
        let _x = x.clamped(to: x_range)
        let _y = y.clamped(to: y_range)
        
        return source[_y * width + _x].with(opacity: 0)
    }
    
    @_versioned
    @inline(__always)
    func filling(_ blender: ImageContextPixelBlender<Pixel>, _ transform: SDTransform, _ operation: (Point) -> ColorPixel<Pixel.Model>) {
        
        var blender = blender
        
        var _p = Point(x: 0, y: 0)
        let _p1 = Point(x: 1, y: 0) * transform
        let _p2 = Point(x: 0, y: 1) * transform
        
        if antialias {
            
            let _q1 = Point(x: 0.2, y: 0) * transform
            let _q2 = Point(x: 0, y: 0.2) * transform
            
            for _ in 0..<height {
                var p = _p
                for _ in 0..<width {
                    var _q = p
                    var pixel = ColorPixel<Pixel.Model>()
                    for _ in 0..<5 {
                        var q = _q
                        for _ in 0..<5 {
                            pixel += operation(q)
                            q += _q1
                        }
                        _q += _q2
                    }
                    blender.draw { pixel * 0.04 }
                    blender += 1
                    p += _p1
                }
                _p += _p2
            }
            
        } else {
            
            for _ in 0..<height {
                var p = _p
                for _ in 0..<width {
                    blender.draw { operation(p) }
                    blender += 1
                    p += _p1
                }
                _p += _p2
            }
        }
    }
    
    @_versioned
    @inline(__always)
    func convolve(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, kernel_size: Int, kernel: (Double) -> Double) -> ColorPixel<Pixel.Model> {
        
        var pixel = ColorPixel<Pixel.Model>()
        var t: Double = 0
        
        let _x = Int(point.x)
        let _y = Int(point.y)
        
        let a = kernel_size >> 1
        let b = 1 - kernel_size & 1
        let min_x = _x - a + b
        let max_x = min_x + kernel_size
        let min_y = _y - a + b
        let max_y = min_y + kernel_size
        
        for y in min_y..<max_y {
            for x in min_x..<max_x {
                let k = kernel((point - Point(x: x, y: y)).magnitude)
                pixel += read_source(source, width, height, x, y) * k
                t += k
            }
        }
        return t == 0 ? ColorPixel<Pixel.Model>() : pixel / t
    }
    
    @_versioned
    @inline(__always)
    func smapling2(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, sampler: (Double, ColorPixel<Pixel.Model>, ColorPixel<Pixel.Model>) -> ColorPixel<Pixel.Model>) -> ColorPixel<Pixel.Model> {
        
        let _x1 = Int(point.x)
        let _y1 = Int(point.y)
        let _x2 = _x1 + 1
        let _y2 = _y1 + 1
        
        let _tx = point.x - Double(_x1)
        let _ty = point.y - Double(_y1)
        
        let _s1 = read_source(source, width, height, _x1, _y1)
        let _s2 = read_source(source, width, height, _x2, _y1)
        let _s3 = read_source(source, width, height, _x1, _y2)
        let _s4 = read_source(source, width, height, _x2, _y2)
        
        return sampler(_ty, sampler(_tx, _s1, _s2), sampler(_tx, _s3, _s4))
        
    }
    
    @_versioned
    @inline(__always)
    func smapling4(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, sampler: (Double, ColorPixel<Pixel.Model>, ColorPixel<Pixel.Model>, ColorPixel<Pixel.Model>, ColorPixel<Pixel.Model>) -> ColorPixel<Pixel.Model>) -> ColorPixel<Pixel.Model> {
        
        let _x2 = Int(point.x)
        let _y2 = Int(point.y)
        let _x3 = _x2 + 1
        let _y3 = _y2 + 1
        let _x1 = _x2 - 1
        let _y1 = _y2 - 1
        let _x4 = _x2 + 2
        let _y4 = _y2 + 2
        
        let _tx = point.x - Double(_x2)
        let _ty = point.y - Double(_y2)
        
        let _s1 = read_source(source, width, height, _x1, _y1)
        let _s2 = read_source(source, width, height, _x2, _y1)
        let _s3 = read_source(source, width, height, _x3, _y1)
        let _s4 = read_source(source, width, height, _x4, _y1)
        let _s5 = read_source(source, width, height, _x1, _y2)
        let _s6 = read_source(source, width, height, _x2, _y2)
        let _s7 = read_source(source, width, height, _x3, _y2)
        let _s8 = read_source(source, width, height, _x4, _y2)
        let _s9 = read_source(source, width, height, _x1, _y3)
        let _s10 = read_source(source, width, height, _x2, _y3)
        let _s11 = read_source(source, width, height, _x3, _y3)
        let _s12 = read_source(source, width, height, _x4, _y3)
        let _s13 = read_source(source, width, height, _x1, _y4)
        let _s14 = read_source(source, width, height, _x2, _y4)
        let _s15 = read_source(source, width, height, _x3, _y4)
        let _s16 = read_source(source, width, height, _x4, _y4)
        
        let _u1 = sampler(_tx, _s1, _s2, _s3, _s4)
        let _u2 = sampler(_tx, _s5, _s6, _s7, _s8)
        let _u3 = sampler(_tx, _s9, _s10, _s11, _s12)
        let _u4 = sampler(_tx, _s13, _s14, _s15, _s16)
        
        return sampler(_ty, _u1, _u2, _u3, _u4)
        
    }
}

