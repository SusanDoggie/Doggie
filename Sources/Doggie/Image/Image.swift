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

@_versioned
protocol ImageBaseProtocol {
    
    @_versioned
    var colorModel: ColorModelProtocol.Type { get }
    
    @_versioned
    var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm { get set }
    
    @_versioned
    subscript(position: Int) -> Color { get set }
    
    @_versioned
    func convert(color: Color) -> Color
    
    @_versioned
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace) -> ImageBaseProtocol where RPixel.Model == RSpace.Model
    
    @_versioned
    func blended(source: Image, width: Int, height: Int, transform: SDTransform, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, algorithm: Image.ResamplingAlgorithm, antialias: Bool) -> ImageBaseProtocol
    
    @_versioned
    func resampling(s_width: Int, width: Int, height: Int, transform: SDTransform, algorithm: Image.ResamplingAlgorithm, antialias: Bool) -> ImageBaseProtocol
    
    @_versioned
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R
    
    @_versioned
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

@_versioned
@_fixed_layout
struct ImageBase<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol> : ImageBaseProtocol where ColorPixel.Model == ColorSpace.Model {
    
    @_versioned
    var buffer: Data
    
    @_versioned
    var colorSpace: ColorSpace
    
    @_versioned
    var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    @_versioned
    @_inlineable
    init(buffer: Data, colorSpace: ColorSpace, chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) {
        self.buffer = buffer
        self.colorSpace = colorSpace
        self.chromaticAdaptationAlgorithm = chromaticAdaptationAlgorithm
    }
    
    @_versioned
    @_inlineable
    init(size: Int, pixel: ColorPixel, colorSpace: ColorSpace, chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) {
        
        var data = Data(count: MemoryLayout<ColorPixel>.stride * size)
        data.withUnsafeMutableBytes { _ = _memset($0, pixel, MemoryLayout<ColorPixel>.stride * size) }
        
        self.init(buffer: data, colorSpace: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_versioned
    @_inlineable
    var colorModel: ColorModelProtocol.Type {
        return ColorSpace.Model.self
    }
    
    @_versioned
    @_inlineable
    subscript(position: Int) -> Color {
        get {
            return buffer.withUnsafeBytes { (ptr: UnsafePointer<ColorPixel>) in
                let pixel = ptr[position]
                return Color(colorSpace: colorSpace, color: pixel.color, opacity: pixel.opacity)
            }
        }
        set {
            buffer.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<ColorPixel>) in
                let color = newValue.convert(to: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
                ptr[position] = ColorPixel(color: color.color as! ColorSpace.Model, opacity: color.opacity)
            }
        }
    }
    
    @_versioned
    @_inlineable
    func convert(color: Color) -> Color {
        return color.convert(to: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_versioned
    @_inlineable
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace) -> ImageBaseProtocol where RPixel.Model == RSpace.Model {
        
        return ImageBase<RPixel, RSpace>(buffer: buffer._memmap { (pixel: ColorPixel) in RPixel(color: self.colorSpace.convert(pixel.color, to: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm), opacity: pixel.opacity) }, colorSpace: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_versioned
    @_inlineable
    func blended(source: Image, width: Int, height: Int, transform: SDTransform, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, algorithm: Image.ResamplingAlgorithm, antialias: Bool) -> ImageBaseProtocol {
        
        if buffer.count == 0 || source.width == 0 || source.height == 0 || transform.determinant.almostZero() {
            return self
        }
        
        let _source: ImageBase
        
        if transform == SDTransform.identity && width == source.width && height == source.height {
            _source = Image(image: source, pixel: ColorPixel.self, colorSpace: colorSpace).base as! ImageBase
        } else if source.colorModel.count < ColorSpace.Model.count || (source.colorModel.count == ColorSpace.Model.count && width * height < source.width * source.height) {
            let _temp = Image(image: source, width: width, height: height, transform: transform, resampling: algorithm, antialias: antialias)
            _source = Image(image: _temp, pixel: ColorPixel.self, colorSpace: colorSpace).base as! ImageBase
        } else {
            let _temp = Image(image: source, pixel: ColorPixel.self, colorSpace: colorSpace)
            _source = Image(image: _temp, width: width, height: height, transform: transform, resampling: algorithm, antialias: antialias).base as! ImageBase
        }
        
        var _buffer = self.buffer
        
        _source.buffer.withUnsafeBytes { (_s: UnsafePointer<ColorPixel>) in
            _buffer.withUnsafeMutableBytes { (_d: UnsafeMutablePointer<ColorPixel>) in
                var _s = _s
                var _d = _d
                for _ in 0..<buffer.count {
                    _d.pointee.blend(source: _s.pointee, blendMode: blendMode, compositingMode: compositingMode)
                    _s += 1
                    _d += 1
                }
            }
        }
        
        return ImageBase(buffer: _buffer, colorSpace: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_versioned
    @_inlineable
    func resampling(s_width: Int, width: Int, height: Int, transform: SDTransform, algorithm: Image.ResamplingAlgorithm, antialias: Bool) -> ImageBaseProtocol {
        
        if buffer.count == 0 || transform.determinant.almostZero() {
            return ImageBase(size: width * height, pixel: ColorPixel(), colorSpace: self.colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
        }
        return ImageBase(buffer: algorithm.calculate(source: self.buffer, s_width: s_width, width: width, height: height, pixel: ColorPixel.self, transform: transform.inverse, antialias: antialias), colorSpace: self.colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_versioned
    @_inlineable
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) in try body(UnsafeMutableRawBufferPointer(start: ptr, count: buffer.count)) }
    }
    
    @_versioned
    @_inlineable
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in try body(UnsafeRawBufferPointer(start: ptr, count: buffer.count)) }
    }
}

@_fixed_layout
public struct Image {
    
    public let width: Int
    public let height: Int
    
    @_versioned
    var base: ImageBaseProtocol
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .linear, antialias: Bool = false) {
        self.width = width
        self.height = height
        self.base = image.base.resampling(s_width: image.width, width: width, height: height, transform: SDTransform.scale(x: Double(width) / Double(image.width), y: Double(height) / Double(image.height)), algorithm: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm = .linear, antialias: Bool = false) {
        self.width = width
        self.height = height
        self.base = image.base.resampling(s_width: image.width, width: width, height: height, transform: transform, algorithm: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(width: Int, height: Int, pixel: ColorPixel, colorSpace: ColorSpace, chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = width
        self.height = height
        self.base = ImageBase(size: width * height, pixel: pixel, colorSpace: colorSpace, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm)
    }
    
    @_inlineable
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace) where ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace)
    }
    
    @_inlineable
    public func convert(from color: Color) -> Color {
        return base.convert(color: color)
    }
    @_inlineable
    public var colorModel: ColorModelProtocol.Type {
        return base.colorModel
    }
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm {
        get {
            return base.chromaticAdaptationAlgorithm
        }
        set {
            base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @_inlineable
    public subscript(x: Int, y: Int) -> Color {
        get {
            return base[width * y + x]
        }
        set {
            base[width * y + x] = newValue
        }
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try base.withUnsafeMutableBytes(body)
    }
    
    @_inlineable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try base.withUnsafeBytes(body)
    }
}

extension Image {
    
    @_inlineable
    public mutating func blend(source: Image, transform: SDTransform, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, algorithm: Image.ResamplingAlgorithm, antialias: Bool) {
        
        base = base.blended(source: source, width: width, height: height, transform: transform, blendMode: blendMode, compositingMode: compositingMode, algorithm: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public func blended(source: Image, transform: SDTransform, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, algorithm: Image.ResamplingAlgorithm, antialias: Bool) -> Image {
        var result = self
        result.blend(source: source, transform: transform, blendMode: blendMode, compositingMode: compositingMode, algorithm: algorithm, antialias: antialias)
        return result
    }
}

extension Image {
    
    public enum ResamplingAlgorithm {
        
        case none
        case linear
        case cosine
        case cubic
        case hermite(Double, Double)
        case mitchell(Double, Double)
        case lanczos(UInt)
    }
}

extension Image.ResamplingAlgorithm {
    
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
