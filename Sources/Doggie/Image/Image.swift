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
import Dispatch

@_fixed_layout
public struct Image<Pixel: ColorPixelProtocol> {
    
    public let width: Int
    public let height: Int
    
    @_versioned
    var pixel: [Pixel]
    
    public var colorSpace: ColorSpace<Pixel.Model>
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(width: Int, height: Int, colorSpace: C, pixel: Pixel = Pixel()) where C.Model == Pixel.Model {
        self.width = width
        self.height = height
        self.colorSpace = ColorSpace(colorSpace)
        self.pixel = [Pixel](repeating: pixel, count: width * height)
    }
    
    @_inlineable
    public init<P>(image: Image<P>) where P.Model == Pixel.Model {
        self.width = image.width
        self.height = image.height
        self.colorSpace = image.colorSpace
        self.pixel = image.pixel.map(Pixel.init)
    }
    
    @_inlineable
    public init<C : ColorSpaceProtocol, P>(image: Image<P>, colorSpace: C) where C.Model == Pixel.Model {
        self.width = image.width
        self.height = image.height
        self.colorSpace = ColorSpace(colorSpace)
        self.pixel = image.colorSpace.convert(image.pixel, colorSpace: self.colorSpace)
    }
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self.init(image: image, width: width, height: height, transform: SDTransform.scale(x: Double(width) / Double(image.width), y: Double(height) / Double(image.height)), resampling: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self.width = width
        self.height = height
        self.colorSpace = image.colorSpace
        if image.pixel.count == 0 || transform.determinant.almostZero() {
            self.pixel = [Pixel](repeating: Pixel(), count: width * height)
        } else {
            self.pixel = algorithm.calculate(source: image.pixel, s_width: image.width, width: width, height: height, pixel: Pixel.self, transform: transform.inverse, antialias: antialias)
        }
    }
}

extension ColorSpace {
    
    @_versioned
    @_inlineable
    func convert<S: ColorPixelProtocol, R: ColorPixelProtocol>(_ source: [S], colorSpace: ColorSpace<R.Model>) -> [R] where S.Model == Model {
        let matrix = self.cieXYZ.transferMatrix(to: colorSpace.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
        return source.map { R(color: colorSpace.base.convertFromXYZ(self.base.convertToXYZ($0.color) * matrix), opacity: $0.opacity) }
    }
}

extension Image {
    
    @_inlineable
    public subscript(x: Int, y: Int) -> Color<Pixel.Model> {
        get {
            precondition(0..<width ~= x)
            precondition(0..<height ~= y)
            return Color(colorSpace: colorSpace, color: pixel[width * y + x])
        }
        set {
            precondition(0..<width ~= x)
            precondition(0..<height ~= y)
            pixel[width * y + x] = Pixel(newValue.convert(to: colorSpace))
        }
    }
}

extension Image {
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixel.withUnsafeBufferPointer(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixel.withUnsafeMutableBufferPointer(body)
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
    
    @_inlineable
    public static var `default` : ResamplingAlgorithm {
        return .linear
    }
}

extension ResamplingAlgorithm {
    
    @_versioned
    @inline(__always)
    func read_source<Pixel: ColorPixelProtocol>(_ source: UnsafePointer<Pixel>, _ width: Int, _ height: Int, _ x: Int, _ y: Int) -> Pixel {
        
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
    func antialias_filling1<Pixel: ColorPixelProtocol>(_ buffer: UnsafeMutablePointer<Pixel>, _ width: Int, _ height: Int, _ transform: SDTransform, _ operation: (Point) -> ColorPixel<Pixel.Model>) {
        
        var buffer = buffer
        
        var _p = Point(x: 0, y: 0)
        let _p1 = Point(x: 1, y: 0) * transform
        let _p2 = Point(x: 0, y: 1) * transform
        
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
                buffer.pointee = Pixel(pixel * 0.04)
                buffer += 1
                p += _p1
            }
            _p += _p2
        }
    }
    
    @_versioned
    @inline(__always)
    func antialias_filling2<Pixel: ColorPixelProtocol>(_ buffer: UnsafeMutablePointer<Pixel>, _ width: Int, _ height: Int, _ transform: SDTransform, _ operation: (Point) -> ColorPixel<Pixel.Model>) {
        
        let _p = Point(x: 0, y: 0)
        let _p1 = Point(x: 1, y: 0) * transform
        let _p2 = Point(x: 0, y: 1) * transform
        
        let _q1 = Point(x: 0.2, y: 0) * transform
        let _q2 = Point(x: 0, y: 0.2) * transform
        
        DispatchQueue.concurrentPerform(iterations: height) { i in
            var buffer = buffer + width * i
            var p = _p + _p2 * Double(i)
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
                buffer.pointee = Pixel(pixel * 0.04)
                buffer += 1
                p += _p1
            }
        }
    }
    
    @_versioned
    @inline(__always)
    func filling1<Pixel: ColorPixelProtocol>(_ buffer: UnsafeMutablePointer<Pixel>, _ width: Int, _ height: Int, _ transform: SDTransform, _ antialias: Bool, _ operation: (Point) -> Pixel) {
        
        if antialias {
            
            antialias_filling1(buffer, width, height, transform) { ColorPixel(operation($0)) }
            
        } else {
            
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
    }
    
    @_versioned
    @inline(__always)
    func filling2<Pixel: ColorPixelProtocol>(_ buffer: UnsafeMutablePointer<Pixel>, _ width: Int, _ height: Int, _ transform: SDTransform, _ antialias: Bool, _ operation: (Point) -> ColorPixel<Pixel.Model>) {
        
        if antialias {
            
            antialias_filling1(buffer, width, height, transform, operation)
            
        } else {
            
            var buffer = buffer
            
            var _p = Point(x: 0, y: 0)
            let _p1 = Point(x: 1, y: 0) * transform
            let _p2 = Point(x: 0, y: 1) * transform
            
            for _ in 0..<height {
                var p = _p
                for _ in 0..<width {
                    buffer.pointee = Pixel(operation(p))
                    buffer += 1
                    p += _p1
                }
                _p += _p2
            }
        }
    }
    
    @_versioned
    @inline(__always)
    func filling3<Pixel: ColorPixelProtocol>(_ buffer: UnsafeMutablePointer<Pixel>, _ width: Int, _ height: Int, _ transform: SDTransform, _ antialias: Bool, _ operation: (Point) -> ColorPixel<Pixel.Model>) {
        
        if antialias {
            
            antialias_filling2(buffer, width, height, transform, operation)
            
        } else {
            
            let _p = Point(x: 0, y: 0)
            let _p1 = Point(x: 1, y: 0) * transform
            let _p2 = Point(x: 0, y: 1) * transform
            
            DispatchQueue.concurrentPerform(iterations: height) { i in
                var buffer = buffer + width * i
                var p = _p + _p2 * Double(i)
                for _ in 0..<width {
                    buffer.pointee = Pixel(operation(p))
                    buffer += 1
                    p += _p1
                }
            }
        }
    }
    
    @_versioned
    @_inlineable
    @_specialize(ColorPixel<RGBColorModel>) @_specialize(ColorPixel<CMYKColorModel>) @_specialize(ColorPixel<GrayColorModel>) @_specialize(ARGB32ColorPixel)
    func calculate<Pixel: ColorPixelProtocol>(source: [Pixel], s_width: Int, width: Int, height: Int, pixel: Pixel.Type, transform: SDTransform, antialias: Bool) -> [Pixel] {
        
        var result = [Pixel](repeating: Pixel(), count: width * height)
        
        if source.count != 0 {
            
            let s_height = source.count / s_width
            
            result.withUnsafeMutableBufferPointer { buffer in
                
                switch self {
                case .none:
                    
                    source.withUnsafeBufferPointer { source in
                        
                        @inline(__always)
                        func op(point: Point) -> Pixel {
                            return read_source(source.baseAddress!, s_width, s_height, Int(point.x), Int(point.y))
                        }
                        
                        filling1(buffer.baseAddress!, width, height, transform, antialias, op)
                    }
                    
                default:
                    
                    let _source = source as? [ColorPixel<Pixel.Model>] ?? source.map(ColorPixel.init)
                    
                    _source.withUnsafeBufferPointer { source in
                        
                        switch self {
                        case .none: fatalError()
                        case .linear:
                            
                            @inline(__always)
                            func op(point: Point) -> ColorPixel<Pixel.Model> {
                                return smapling2(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: LinearInterpolate)
                            }
                            
                            filling2(buffer.baseAddress!, width, height, transform, antialias, op)
                            
                        case .cosine:
                            
                            @inline(__always)
                            func op(point: Point) -> ColorPixel<Pixel.Model> {
                                return smapling2(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: CosineInterpolate)
                            }
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                            
                        case .cubic:
                            
                            @inline(__always)
                            func op(point: Point) -> ColorPixel<Pixel.Model> {
                                return smapling4(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: CubicInterpolate)
                            }
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                            
                        case let .hermite(s, e):
                            
                            @inline(__always)
                            func _kernel(_ t: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
                                return HermiteInterpolate(t, a, b, c, d, s, e)
                            }
                            
                            @inline(__always)
                            func op(point: Point) -> ColorPixel<Pixel.Model> {
                                return smapling4(source: source.baseAddress!, width: s_width, height: s_height, point: point, sampler: _kernel)
                            }
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                            
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
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                            
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
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                            
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
                            
                            filling3(buffer.baseAddress!, width, height, transform, antialias, op)
                        }
                    }
                }
            }
        }
        return result
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
