//
//  Image.swift
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

import Foundation

@_fixed_layout
public struct Image<ColorSpace : ColorSpaceProtocol, ColorPixel: ColorPixelProtocol> where ColorPixel.Model == ColorSpace.Model {
    
    public let width: Int
    public let height: Int
    
    @_versioned
    var buffer: Data
    
    public var colorSpace: ColorSpace
    
    public var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .linear, antialias: Bool = false) {
        self.init(image: image, width: width, height: height, transform: SDTransform.scale(x: Double(width) / Double(image.width), y: Double(height) / Double(image.height)), resampling: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm = .linear, antialias: Bool = false) {
        self.width = width
        self.height = height
        self.colorSpace = image.colorSpace
        self.chromaticAdaptationAlgorithm = image.chromaticAdaptationAlgorithm
        if image.buffer.count == 0 || transform.determinant.almostZero() {
            self.buffer = Data(count: MemoryLayout<ColorPixel>.stride * width * height)
            self.buffer.withUnsafeMutableBytes { _ = _memset($0, ColorPixel(), MemoryLayout<ColorPixel>.stride * width * height) }
        } else {
            self.buffer = algorithm.calculate(source: image.buffer, s_width: image.width, width: width, height: height, pixel: ColorPixel.self, transform: transform.inverse, antialias: antialias)
        }
    }
    
    @_inlineable
    public init(width: Int, height: Int, colorSpace: ColorSpace, pixel: ColorPixel = ColorPixel(), chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) {
        self.width = width
        self.height = height
        self.colorSpace = colorSpace
        self.chromaticAdaptationAlgorithm = chromaticAdaptationAlgorithm
        self.buffer = Data(count: MemoryLayout<ColorPixel>.stride * width * height)
        self.buffer.withUnsafeMutableBytes { _ = _memset($0, pixel, MemoryLayout<ColorPixel>.stride * width * height) }
    }
    
    @_inlineable
    public init<C : ColorSpaceProtocol, P: ColorPixelProtocol>(image: Image<C, P>, colorSpace: ColorSpace) where C.Model == P.Model {
        self.width = image.width
        self.height = image.height
        self.colorSpace = colorSpace
        self.chromaticAdaptationAlgorithm = image.chromaticAdaptationAlgorithm
        self.buffer = image.buffer._memmap { (pixel: P) in ColorPixel(color: image.colorSpace.convert(pixel.color, to: colorSpace, chromaticAdaptationAlgorithm: image.chromaticAdaptationAlgorithm), opacity: pixel.opacity) }
    }
}

extension Image {
    
    @_inlineable
    public subscript(x: Int, y: Int) -> Color<ColorSpace> {
        get {
            precondition(0..<width ~= x)
            precondition(0..<height ~= y)
            return buffer.withUnsafeBytes { (ptr: UnsafePointer<ColorPixel>) in Color(colorSpace: colorSpace, color: ptr[width * y + x], chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm) }
        }
        set {
            precondition(0..<width ~= x)
            precondition(0..<height ~= y)
            buffer.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<ColorPixel>) in ptr[width * y + x] = ColorPixel(newValue.convert(to: colorSpace)) }
        }
    }
}

extension Image {
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<ColorPixel>) throws -> R) rethrows -> R {
        
        return try buffer.withUnsafeBytes { try body(UnsafeBufferPointer(start: $0, count: width * height)) }
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (UnsafeMutableBufferPointer<ColorPixel>) throws -> R) rethrows -> R {
        
        return try buffer.withUnsafeMutableBytes { try body(UnsafeMutableBufferPointer(start: $0, count: width * height)) }
    }
}

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
    
    @_versioned
    @_inlineable
    @_specialize(ColorPixel<RGBColorModel>) @_specialize(ColorPixel<CMYKColorModel>) @_specialize(ColorPixel<GrayColorModel>) @_specialize(ARGB32ColorPixel)
    func calculate<Pixel: ColorPixelProtocol>(source: Data, s_width: Int, width: Int, height: Int, pixel: Pixel.Type, transform: SDTransform, antialias: Bool) -> Data {
        
        var result = Data(count: MemoryLayout<Pixel>.stride * width * height)
        
        if source.count != 0 {
            
            let s_count = source.count / MemoryLayout<Pixel>.stride
            let s_height = s_count / s_width
            
            result.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<Pixel>) in
                
                @inline(__always)
                func _filling(operation: (Point) -> Pixel) {
                    
                    var buffer = buffer
                    
                    var _p = Point(x: 0, y: 0)
                    let _p1 = Point(x: 1, y: 0) * transform
                    let _p2 = Point(x: 0, y: 1) * transform
                    
                    for _ in 0..<height {
                        var p = _p
                        for _ in 0..<width {
                            buffer.pointee = operation(p)
                            buffer += 1
                            p += _p1
                        }
                        _p += _p2
                    }
                }
                
                switch self {
                case .none:
                    source.withUnsafeBytes { (source: UnsafePointer<Pixel>) in
                        _filling { point in
                            let _x = Int(point.x)
                            let _y = Int(point.y)
                            return 0..<s_width ~= _x && 0..<s_height ~= _y ? source[_y * s_width + _x] : Pixel()
                        }
                    }
                default:
                    
                    @inline(__always)
                    func filling(operation: (Point) -> ColorPixel<Pixel.Model>) {
                        
                        if antialias {
                            
                            var buffer = buffer
                            
                            var _p = Point(x: 0, y: 0)
                            let _p1 = Point(x: 1, y: 0) * transform
                            let _p2 = Point(x: 0, y: 1) * transform
                            
                            let _q1 = Point(x: -0.4, y: -0.4) * transform
                            let _q2 = Point(x: 0.2, y: 0) * transform
                            let _q3 = Point(x: 0, y: 0.2) * transform
                            
                            for _ in 0..<height {
                                var p = _p
                                for _ in 0..<width {
                                    var _q = p + _q1
                                    var pixel = ColorPixel<Pixel.Model>()
                                    for _ in 0..<5 {
                                        var q = _q
                                        for _ in 0..<5 {
                                            pixel += operation(q)
                                            q += _q2
                                        }
                                        _q += _q3
                                    }
                                    buffer.pointee = Pixel(pixel * 0.04)
                                    buffer += 1
                                    p += _p1
                                }
                                _p += _p2
                            }
                        } else {
                            _filling { Pixel(operation($0)) }
                        }
                    }
                    
                    let _source = Pixel.self is ColorPixel<Pixel.Model>.Type ? source : source._memmap { (pixel: Pixel) in ColorPixel(pixel) }
                    
                    _source.withUnsafeBytes { (source: UnsafePointer<ColorPixel<Pixel.Model>>) in
                        
                        switch self {
                        case .none: fatalError()
                        case .linear: filling { smapling2(source: source, width: s_width, height: s_height, point: $0, sampler: LinearInterpolate) }
                        case .cosine: filling { smapling2(source: source, width: s_width, height: s_height, point: $0, sampler: CosineInterpolate) }
                        case .cubic: filling { smapling4(source: source, width: s_width, height: s_height, point: $0, sampler: CubicInterpolate) }
                        case let .hermite(s, e):
                            
                            @inline(__always)
                            func _kernel(_ t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
                                return HermiteInterpolate(t, a, b, c, d, s, e)
                            }
                            filling { smapling4(source: source, width: s_width, height: s_height, point: $0, sampler: _kernel) }
                            
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
                            filling { convolve(source: source, width: s_width, height: s_height, point: $0, kernel_size: 5, kernel: _kernel) }
                            
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
                            filling { convolve(source: source, width: s_width, height: s_height, point: $0, kernel_size: 2, kernel: _kernel) }
                            
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
                            filling { convolve(source: source, width: s_width, height: s_height, point: $0, kernel_size: Int(a) << 1, kernel: _kernel) }
                        }
                    }
                }
            }
        }
        return result
    }
    
    @_versioned
    @inline(__always)
    func read_source<ColorModel: ColorModelProtocol>(_ source: UnsafePointer<ColorPixel<ColorModel>>, _ width: Int, _ height: Int, _ x: Int, _ y: Int) -> ColorPixel<ColorModel> {
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        let check1 = x_range.contains(x)
        let check2 = y_range.contains(y)
        
        if check1 && check2 {
            return source[y * width + x]
        }
        
        let _x = x.clamped(to: x_range)
        let _y = y.clamped(to: y_range)
        
        return source[_y * width + _x].with(opacity: 0)
    }
    
    @_versioned
    @inline(__always)
    func convolve<ColorModel: ColorModelProtocol>(source: UnsafePointer<ColorPixel<ColorModel>>, width: Int, height: Int, point: Point, kernel_size: Int, kernel: (Double) -> Double) -> ColorPixel<ColorModel> {
        
        var pixel = ColorPixel<ColorModel>()
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
        return t == 0 ? ColorPixel<ColorModel>() : pixel / t
    }
    
    @_versioned
    @inline(__always)
    func smapling2<ColorModel: ColorModelProtocol>(source: UnsafePointer<ColorPixel<ColorModel>>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double) -> Double) -> ColorPixel<ColorModel> {
        
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
        
        var color = ColorModel()
        
        for i in 0..<ColorModel.count {
            color.setComponent(i, sampler(_ty,sampler(_tx, _s1.color.component(i), _s2.color.component(i)), sampler(_tx, _s3.color.component(i), _s4.color.component(i))))
        }
        
        return ColorPixel<ColorModel>(color: color, opacity: sampler(_ty, sampler(_tx, _s1.opacity, _s2.opacity), sampler(_tx, _s3.opacity, _s4.opacity)))
        
    }
    
    @_versioned
    @inline(__always)
    func smapling4<ColorModel: ColorModelProtocol>(source: UnsafePointer<ColorPixel<ColorModel>>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double, Double, Double) -> Double) -> ColorPixel<ColorModel> {
        
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
        
        var color = ColorModel()
        
        for i in 0..<ColorModel.count {
            let _u1 = sampler(_tx, _s1.color.component(i), _s2.color.component(i), _s3.color.component(i), _s4.color.component(i))
            let _u2 = sampler(_tx, _s5.color.component(i), _s6.color.component(i), _s7.color.component(i), _s8.color.component(i))
            let _u3 = sampler(_tx, _s9.color.component(i), _s10.color.component(i), _s11.color.component(i), _s12.color.component(i))
            let _u4 = sampler(_tx, _s13.color.component(i), _s14.color.component(i), _s15.color.component(i), _s16.color.component(i))
            color.setComponent(i, sampler(_ty, _u1, _u2, _u3, _u4))
        }
        
        let a1 = sampler(_tx, _s1.opacity, _s2.opacity, _s3.opacity, _s4.opacity)
        let a2 = sampler(_tx, _s5.opacity, _s6.opacity, _s7.opacity, _s8.opacity)
        let a3 = sampler(_tx, _s9.opacity, _s10.opacity, _s11.opacity, _s12.opacity)
        let a4 = sampler(_tx, _s13.opacity, _s14.opacity, _s15.opacity, _s16.opacity)
        
        return ColorPixel<ColorModel>(color: color, opacity: sampler(_ty, a1, a2, a3, a4))
        
    }
}
