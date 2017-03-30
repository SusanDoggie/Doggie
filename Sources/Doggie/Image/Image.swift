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
    subscript(position: Int) -> Color { get set }
    
    @_versioned
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model
    
    @_versioned
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model
    
    @_versioned
    func resampling(s_width: Int, width: Int, height: Int, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol
    
    @_versioned
    func resampling<T: SDTransformProtocol>(s_width: Int, width: Int, height: Int, transform: T, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol
    
    @_versioned
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R
    
    @_versioned
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

@_versioned
@_fixed_layout
struct ImageBase<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol> : ImageBaseProtocol where ColorPixel.Model == ColorSpace.Model {
    
    @_versioned
    var buffer: [ColorPixel]
    
    @_versioned
    var colorSpace: ColorSpace
    
    @_versioned
    var algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    @_versioned
    @_inlineable
    init(buffer: [ColorPixel], colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) {
        self.buffer = buffer
        self.colorSpace = colorSpace
        self.algorithm = algorithm
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
            let pixel = buffer[position]
            return Color(colorSpace: colorSpace, color: pixel.color, opacity: pixel.opacity)
        }
        set {
            let color = newValue.convert(to: colorSpace, algorithm: algorithm)
            buffer[position] = ColorPixel(color: color.color as! ColorSpace.Model, opacity: color.opacity)
        }
    }
    
    @_versioned
    @_inlineable
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, opacity: $1.opacity) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    @_versioned
    @_inlineable
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, opacity: $1.opacity) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    @_versioned
    @_inlineable
    func resampling(s_width: Int, width: Int, height: Int, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol {
        
        return resampling(s_width: s_width, width: width, height: height, transform: SDTransform.Scale(x: Double(width) / Double(s_width), y: Double(height) / Double(buffer.count / s_width)), algorithm: algorithm)
    }
    @_versioned
    @_inlineable
    func resampling<T: SDTransformProtocol>(s_width: Int, width: Int, height: Int, transform: T, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol {
        
        return ImageBase(buffer: algorithm.calculate(source: self.buffer, s_width: s_width, width: width, height: height, transform: SDTransform(transform.inverse)), colorSpace: self.colorSpace, algorithm: self.algorithm)
    }
    
    @_versioned
    @_inlineable
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeMutableBytes(body)
    }
    
    @_versioned
    @_inlineable
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeBytes(body)
    }
}

@_fixed_layout
public struct Image {
    
    public let width: Int
    public let height: Int
    
    @_versioned
    var base: ImageBaseProtocol
    
    @_inlineable
    public init(image: Image, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .linear) {
        self.width = width
        self.height = height
        self.base = image.base.resampling(s_width: image.width, width: width, height: height, algorithm: algorithm)
    }
    
    @_inlineable
    public init<T: SDTransformProtocol>(image: Image, width: Int, height: Int, transform: T, resampling algorithm: ResamplingAlgorithm = .linear) {
        self.width = width
        self.height = height
        self.base = image.base.resampling(s_width: image.width, width: width, height: height, transform: transform, algorithm: algorithm)
    }
    
    @_inlineable
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(width: Int, height: Int, pixel: ColorPixel, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = width
        self.height = height
        self.base = ImageBase(buffer: [ColorPixel](repeating: pixel, count: width * height), colorSpace: colorSpace, algorithm: algorithm)
    }
    
    @_inlineable
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    @_inlineable
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : LinearColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    @_inlineable
    public var colorModel: ColorModelProtocol.Type {
        return base.colorModel
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
    
    public enum ResamplingAlgorithm {
        
        case none
        case linear
        case cosine
        case cubic
        case mitchell(Double, Double)
        case lanczos(UInt)
    }
}

extension Image.ResamplingAlgorithm {
    
    @_versioned
    @_inlineable
    @_specialize(ColorPixel<RGBColorModel>) @_specialize(ColorPixel<CMYKColorModel>) @_specialize(ColorPixel<GrayColorModel>) @_specialize(ARGB32ColorPixel)
    func calculate<Pixel: ColorPixelProtocol>(source: [Pixel], s_width: Int, width: Int, height: Int, transform: SDTransform) -> [Pixel] {
        
        var result = [Pixel](repeating: Pixel(), count: width * height)
        
        if source.count != 0 {
            
            let s_height = source.count / s_width
            
            result.withUnsafeMutableBufferPointer { buffer in
                
                @_transparent
                func filling(operation: (Point) -> Pixel) {
                    
                    if var pointer = buffer.baseAddress {
                        
                        var _p = Point(x: 0, y: 0)
                        let _p1 = Point(x: 1, y: 0) * transform
                        let _p2 = Point(x: 0, y: 1) * transform
                        
                        for _ in 0..<height {
                            var p = _p
                            for _ in 0..<width {
                                pointer.pointee = operation(p)
                                pointer += 1
                                p += _p1
                            }
                            _p += _p2
                        }
                    }
                }
                
                switch self {
                case .none:
                    source.withUnsafeBufferPointer { source in
                        if let _source = source.baseAddress {
                            filling { point in
                                let _x = Int(point.x)
                                let _y = Int(point.y)
                                return 0..<s_width ~= _x && 0..<s_height ~= _y ? _source[_y * s_width + _x] : Pixel()
                            }
                        }
                    }
                default:
                    
                    source.map { ColorPixel($0) }.withUnsafeBufferPointer { source in
                        if let _source = source.baseAddress {
                            switch self {
                            case .none: fatalError()
                            case .linear: filling { smapling2(source: _source, width: s_width, height: s_height, point: $0, sampler: LinearInterpolate) }
                            case .cosine: filling { smapling2(source: _source, width: s_width, height: s_height, point: $0, sampler: CosineInterpolate) }
                            case .cubic: filling { smapling4(source: _source, width: s_width, height: s_height, point: $0, sampler: CubicInterpolate) }
                            case let .mitchell(B, C):
                                
                                let a1 = 12 - 9 * B - 6 * C
                                let b1 = -18 + 12 * B + 6 * C
                                let c1 = 6 - 2 * B
                                let a2 = -B - 6 * C
                                let b2 = 6 * B + 30 * C
                                let c2 = -12 * B - 48 * C
                                let d2 = 8 * B + 24 * C
                                
                                @_transparent
                                func _kernel(_ x: Double) -> Double {
                                    if x < 1 {
                                        return (a1 * x + b1) * x * x + c1
                                    }
                                    if x < 2 {
                                        return ((a2 * x + b2) * x + c2) * x + d2
                                    }
                                    return 0
                                }
                                filling { convolve(source: _source, width: s_width, height: s_height, point: $0, kernel_size: 5, kernel: _kernel) }
                                
                            case .lanczos(1):
                                
                                @_transparent
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
                                filling { convolve(source: _source, width: s_width, height: s_height, point: $0, kernel_size: 2, kernel: _kernel) }
                                
                            case let .lanczos(a):
                                
                                @_transparent
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
                                filling { convolve(source: _source, width: s_width, height: s_height, point: $0, kernel_size: Int(a) << 1, kernel: _kernel) }
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    @_versioned
    @_transparent
    func convolve<Pixel: ColorPixelProtocol>(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, kernel_size: Int, kernel: (Double) -> Double) -> Pixel {
        
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
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        for y in min_y..<max_y {
            for x in min_x..<max_x {
                let l = kernel((point - Point(x: x, y: y)).magnitude)
                let _source = x_range.contains(x) && y_range.contains(y) ? source[y * width + x] : source[y.clamped(to: y_range) * width + x.clamped(to: x_range)].with(opacity: 0)
                pixel += _source * l
                t += l
            }
        }
        return t == 0 ? Pixel() : Pixel(pixel / t)
    }
    
    @_versioned
    @_transparent
    func smapling2<Pixel: ColorPixelProtocol>(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double) -> Double) -> Pixel {
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        let _x1 = Int(point.x)
        let _y1 = Int(point.y)
        let _x2 = _x1 + 1
        let _y2 = _y1 + 1
        let check1 = x_range.contains(_x1)
        let check2 = x_range.contains(_x2)
        let check3 = y_range.contains(_y1)
        let check4 = y_range.contains(_y2)
        
        let _tx = point.x - Double(_x1)
        let _ty = point.y - Double(_y1)
        
        if check1 || check2 || check3 || check4 {
            
            let __x1 = _x1.clamped(to: x_range)
            let __x2 = _x2.clamped(to: x_range)
            let __y1 = _y1.clamped(to: y_range)
            let __y2 = _y2.clamped(to: y_range)
            
            let _s1 = check1 && check3 ? source[_y1 * width + _x1] : source[__y1 * width + __x1].with(opacity: 0)
            let _s2 = check2 && check3 ? source[_y1 * width + _x2] : source[__y1 * width + __x2].with(opacity: 0)
            let _s3 = check1 && check4 ? source[_y2 * width + _x1] : source[__y2 * width + __x1].with(opacity: 0)
            let _s4 = check2 && check4 ? source[_y2 * width + _x2] : source[__y2 * width + __x2].with(opacity: 0)
            
            var color = Pixel.Model()
            for i in 0..<Pixel.Model.count {
                color.setComponent(i, sampler(_ty,sampler(_tx, _s1.color.component(i), _s2.color.component(i)), sampler(_tx, _s3.color.component(i), _s4.color.component(i))))
            }
            return Pixel(color: color, opacity: sampler(_ty, sampler(_tx, _s1.opacity, _s2.opacity), sampler(_tx, _s3.opacity, _s4.opacity)))
            
        } else {
            return Pixel()
        }
    }
    
    @_versioned
    @_transparent
    func smapling4<Pixel: ColorPixelProtocol>(source: UnsafePointer<ColorPixel<Pixel.Model>>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double, Double, Double) -> Double) -> Pixel {
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        let _x2 = Int(point.x)
        let _y2 = Int(point.y)
        let _x3 = _x2 + 1
        let _y3 = _y2 + 1
        let _x1 = _x2 - 1
        let _y1 = _y2 - 1
        let _x4 = _x2 + 2
        let _y4 = _y2 + 2
        let check1 = x_range.contains(_x1)
        let check2 = x_range.contains(_x2)
        let check3 = x_range.contains(_x3)
        let check4 = x_range.contains(_x4)
        let check5 = y_range.contains(_y1)
        let check6 = y_range.contains(_y2)
        let check7 = y_range.contains(_y3)
        let check8 = y_range.contains(_y4)
        
        let _tx = point.x - Double(_x2)
        let _ty = point.y - Double(_y2)
        
        if check1 || check2 || check3 || check4 || check5 || check6 || check7 || check8 {
            
            let __x1 = _x1.clamped(to: x_range)
            let __x2 = _x2.clamped(to: x_range)
            let __x3 = _x3.clamped(to: x_range)
            let __x4 = _x4.clamped(to: x_range)
            let __y1 = _y1.clamped(to: y_range)
            let __y2 = _y2.clamped(to: y_range)
            let __y3 = _y3.clamped(to: y_range)
            let __y4 = _y4.clamped(to: y_range)
            
            let _s1 = check1 && check5 ? source[_y1 * width + _x1] : source[__y1 * width + __x1].with(opacity: 0)
            let _s2 = check2 && check5 ? source[_y1 * width + _x2] : source[__y1 * width + __x2].with(opacity: 0)
            let _s3 = check3 && check5 ? source[_y1 * width + _x3] : source[__y1 * width + __x3].with(opacity: 0)
            let _s4 = check4 && check5 ? source[_y1 * width + _x4] : source[__y1 * width + __x4].with(opacity: 0)
            let _s5 = check1 && check6 ? source[_y2 * width + _x1] : source[__y2 * width + __x1].with(opacity: 0)
            let _s6 = check2 && check6 ? source[_y2 * width + _x2] : source[__y2 * width + __x2].with(opacity: 0)
            let _s7 = check3 && check6 ? source[_y2 * width + _x3] : source[__y2 * width + __x3].with(opacity: 0)
            let _s8 = check4 && check6 ? source[_y2 * width + _x4] : source[__y2 * width + __x4].with(opacity: 0)
            let _s9 = check1 && check7 ? source[_y3 * width + _x1] : source[__y3 * width + __x1].with(opacity: 0)
            let _s10 = check2 && check7 ? source[_y3 * width + _x2] : source[__y3 * width + __x2].with(opacity: 0)
            let _s11 = check3 && check7 ? source[_y3 * width + _x3] : source[__y3 * width + __x3].with(opacity: 0)
            let _s12 = check4 && check7 ? source[_y3 * width + _x4] : source[__y3 * width + __x4].with(opacity: 0)
            let _s13 = check1 && check8 ? source[_y4 * width + _x1] : source[__y4 * width + __x1].with(opacity: 0)
            let _s14 = check2 && check8 ? source[_y4 * width + _x2] : source[__y4 * width + __x2].with(opacity: 0)
            let _s15 = check3 && check8 ? source[_y4 * width + _x3] : source[__y4 * width + __x3].with(opacity: 0)
            let _s16 = check4 && check8 ? source[_y4 * width + _x4] : source[__y4 * width + __x4].with(opacity: 0)
            
            var color = Pixel.Model()
            for i in 0..<Pixel.Model.count {
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
            
            return Pixel(color: color, opacity: sampler(_ty, a1, a2, a3, a4))
            
        } else {
            return Pixel()
        }
    }
}
