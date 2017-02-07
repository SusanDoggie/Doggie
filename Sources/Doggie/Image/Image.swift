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

private protocol ImageBaseProtocol {
    
    var colorModel: ColorModelProtocol.Type { get }
    
    subscript(position: Int) -> Color { get set }
    
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RSpace.Model : ColorBlendProtocol, RPixel.Model == RSpace.Model
    
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RSpace.Model : ColorBlendProtocol, RPixel.Model == RSpace.Model
    
    func resampling<T: SDTransformProtocol>(s_width: Int, width: Int, height: Int, transform: T, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol
    
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R
    
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

private struct ImageBase<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol> : ImageBaseProtocol where ColorSpace.Model : ColorBlendProtocol, ColorPixel.Model == ColorSpace.Model {
    
    var buffer: [ColorPixel]
    
    var colorSpace: ColorSpace
    var algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    var colorModel: ColorModelProtocol.Type {
        return ColorSpace.Model.self
    }
    
    subscript(position: Int) -> Color {
        get {
            let pixel = buffer[position]
            return Color(colorSpace: colorSpace, color: pixel.color, alpha: pixel.alpha)
        }
        set {
            let color = newValue.convert(to: colorSpace, algorithm: algorithm)
            buffer[position] = ColorPixel(color: color.color as! ColorSpace.Model, alpha: color.alpha)
        }
    }
    
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RSpace.Model : ColorBlendProtocol, RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, alpha: $1.alpha) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RSpace.Model : ColorBlendProtocol, RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, alpha: $1.alpha) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    func resampling<T: SDTransformProtocol>(s_width: Int, width: Int, height: Int, transform: T, algorithm: Image.ResamplingAlgorithm) -> ImageBaseProtocol {
        
        return ImageBase(buffer: algorithm.calculate(source: self.buffer, s_width: s_width, width: width, height: height, transform: transform), colorSpace: self.colorSpace, algorithm: self.algorithm)
    }
    
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeMutableBytes(body)
    }
    
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeBytes(body)
    }
}

public struct Image {
    
    public let width: Int
    public let height: Int
    private var base: ImageBaseProtocol
    
    public init<T: SDTransformProtocol>(image: Image, width: Int, height: Int, transform: T, resampling algorithm: ResamplingAlgorithm = .linear) {
        self.width = width
        self.height = height
        self.base = image.base.resampling(s_width: image.width, width: width, height: height, transform: transform, algorithm: algorithm)
    }
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(width: Int, height: Int, pixel: ColorPixel, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorSpace.Model : ColorBlendProtocol, ColorPixel.Model == ColorSpace.Model {
        self.width = width
        self.height = height
        self.base = ImageBase(buffer: [ColorPixel](repeating: pixel, count: width * height), colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorSpace.Model : ColorBlendProtocol, ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : LinearColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorSpace.Model : ColorBlendProtocol, ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public var colorModel: ColorModelProtocol.Type {
        return base.colorModel
    }
    
    public subscript(x: Int, y: Int) -> Color {
        get {
            return base[width * y + x]
        }
        set {
            base[width * y + x] = newValue
        }
    }
    
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try base.withUnsafeMutableBytes(body)
    }
    
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
        case lanczos(UInt)
    }
}

extension Image.ResamplingAlgorithm {
    
    @_specialize(ColorPixel<RGBColorModel>, SDTransform) @_specialize(ColorPixel<CMYKColorModel>, SDTransform) @_specialize(ColorPixel<GrayColorModel>, SDTransform) @_specialize(ARGB32ColorPixel, SDTransform)
    func calculate<Pixel: ColorPixelProtocol, T: SDTransformProtocol>(source: [Pixel], s_width: Int, width: Int, height: Int, transform: T) -> [Pixel] where Pixel.Model : ColorBlendProtocol {
        
        var result = [Pixel](repeating: Pixel(), count: width * height)
        
        if source.count != 0 {
            let s_height = source.count / s_width
            let _transform = transform.inverse
            
            source.withUnsafeBufferPointer { source in
                if let source = source.baseAddress {
                    result.withUnsafeMutableBufferPointer { buffer in
                        if var pointer = buffer.baseAddress {
                            for i in buffer.indices {
                                pointer.pointee = sampler(source: source, width: s_width, height: s_height, point: Point(x: i % width, y: i / width) * _transform)
                                pointer += 1
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    func smapling2<Pixel: ColorPixelProtocol>(source: UnsafePointer<Pixel>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double) -> Double) -> Pixel where Pixel.Model : ColorBlendProtocol {
        
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
            
            let _s1 = check1 && check3 ? ColorPixel(source[_y1 * width + _x1]) : ColorPixel(color: source[__y1 * width + __x1].color, alpha: 0)
            let _s2 = check2 && check3 ? ColorPixel(source[_y1 * width + _x2]) : ColorPixel(color: source[__y1 * width + __x2].color, alpha: 0)
            let _s3 = check1 && check4 ? ColorPixel(source[_y2 * width + _x1]) : ColorPixel(color: source[__y2 * width + __x1].color, alpha: 0)
            let _s4 = check2 && check4 ? ColorPixel(source[_y2 * width + _x2]) : ColorPixel(color: source[__y2 * width + __x2].color, alpha: 0)
            
            let _u1 = _s1.color.blend(_s2.color) { sampler(_tx, $0, $1) }
            let _u2 = _s3.color.blend(_s4.color) { sampler(_tx, $0, $1) }
            let _v = _u1.blend(_u2) { sampler(_ty, $0, $1) }
            
            return Pixel(color: _v, alpha: sampler(_ty, sampler(_tx, _s1.alpha, _s2.alpha), sampler(_tx, _s3.alpha, _s4.alpha)))
            
        } else {
            return Pixel()
        }
    }
    
    func smapling4<Pixel: ColorPixelProtocol>(source: UnsafePointer<Pixel>, width: Int, height: Int, point: Point, sampler: (Double, Double, Double, Double, Double) -> Double) -> Pixel where Pixel.Model : ColorBlendProtocol {
        
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
            
            let _s1 = check1 && check5 ? ColorPixel(source[_y1 * width + _x1]) : ColorPixel(color: source[__y1 * width + __x1].color, alpha: 0)
            let _s2 = check2 && check5 ? ColorPixel(source[_y1 * width + _x2]) : ColorPixel(color: source[__y1 * width + __x2].color, alpha: 0)
            let _s3 = check3 && check5 ? ColorPixel(source[_y1 * width + _x3]) : ColorPixel(color: source[__y1 * width + __x3].color, alpha: 0)
            let _s4 = check4 && check5 ? ColorPixel(source[_y1 * width + _x4]) : ColorPixel(color: source[__y1 * width + __x4].color, alpha: 0)
            let _s5 = check1 && check6 ? ColorPixel(source[_y2 * width + _x1]) : ColorPixel(color: source[__y2 * width + __x1].color, alpha: 0)
            let _s6 = check2 && check6 ? ColorPixel(source[_y2 * width + _x2]) : ColorPixel(color: source[__y2 * width + __x2].color, alpha: 0)
            let _s7 = check3 && check6 ? ColorPixel(source[_y2 * width + _x3]) : ColorPixel(color: source[__y2 * width + __x3].color, alpha: 0)
            let _s8 = check4 && check6 ? ColorPixel(source[_y2 * width + _x4]) : ColorPixel(color: source[__y2 * width + __x4].color, alpha: 0)
            let _s9 = check1 && check7 ? ColorPixel(source[_y3 * width + _x1]) : ColorPixel(color: source[__y3 * width + __x1].color, alpha: 0)
            let _s10 = check2 && check7 ? ColorPixel(source[_y3 * width + _x2]) : ColorPixel(color: source[__y3 * width + __x2].color, alpha: 0)
            let _s11 = check3 && check7 ? ColorPixel(source[_y3 * width + _x3]) : ColorPixel(color: source[__y3 * width + __x3].color, alpha: 0)
            let _s12 = check4 && check7 ? ColorPixel(source[_y3 * width + _x4]) : ColorPixel(color: source[__y3 * width + __x4].color, alpha: 0)
            let _s13 = check1 && check8 ? ColorPixel(source[_y4 * width + _x1]) : ColorPixel(color: source[__y4 * width + __x1].color, alpha: 0)
            let _s14 = check2 && check8 ? ColorPixel(source[_y4 * width + _x2]) : ColorPixel(color: source[__y4 * width + __x2].color, alpha: 0)
            let _s15 = check3 && check8 ? ColorPixel(source[_y4 * width + _x3]) : ColorPixel(color: source[__y4 * width + __x3].color, alpha: 0)
            let _s16 = check4 && check8 ? ColorPixel(source[_y4 * width + _x4]) : ColorPixel(color: source[__y4 * width + __x4].color, alpha: 0)
            
            let _u1 = _s1.color.blend(_s2.color, _s3.color, _s4.color) { sampler(_tx, $0, $1, $2, $3) }
            let _u2 = _s5.color.blend(_s6.color, _s7.color, _s8.color) { sampler(_tx, $0, $1, $2, $3) }
            let _u3 = _s9.color.blend(_s10.color, _s11.color, _s12.color) { sampler(_tx, $0, $1, $2, $3) }
            let _u4 = _s13.color.blend(_s14.color, _s15.color, _s16.color) { sampler(_tx, $0, $1, $2, $3) }
            let _v = _u1.blend(_u2, _u3, _u4) { sampler(_ty, $0, $1, $2, $3) }
            
            let a1 = sampler(_tx, _s1.alpha, _s2.alpha, _s3.alpha, _s4.alpha)
            let a2 = sampler(_tx, _s5.alpha, _s6.alpha, _s7.alpha, _s8.alpha)
            let a3 = sampler(_tx, _s9.alpha, _s10.alpha, _s11.alpha, _s12.alpha)
            let a4 = sampler(_tx, _s13.alpha, _s14.alpha, _s15.alpha, _s16.alpha)
            
            return Pixel(color: _v, alpha: sampler(_ty, a1, a2, a3, a4))
            
        } else {
            return Pixel()
        }
    }
    
    func sampler<Pixel: ColorPixelProtocol>(source: UnsafePointer<Pixel>, width: Int, height: Int, point: Point) -> Pixel where Pixel.Model : ColorBlendProtocol {
        switch self {
        case .none:
            
            let _x = Int(point.x)
            let _y = Int(point.y)
            return (0..<width).contains(_x) && (0..<height).contains(_y) ? source[_y * width + _x] : Pixel()
            
        case .linear:
            
            return smapling2(source: source, width: width, height: height, point: point, sampler: LinearInterpolate)
            
        case .cosine:
            
            return smapling2(source: source, width: width, height: height, point: point, sampler: CosineInterpolate)
            
        case .cubic:
            
            return smapling4(source: source, width: width, height: height, point: point, sampler: CubicInterpolate)
            
        case let .lanczos(a):
            
            func _kernel(_ x: Double) -> Double {
                let a = Double(a)
                if x == 0 {
                    return 1
                }
                if x < -a {
                    return 0
                }
                if x < a {
                    let _x = Double.pi * x
                    return a * sin(_x) * sin(_x / a) / (_x * _x)
                }
                return 0
            }
            
            var s_color = Pixel.Model()
            var s_alpha: Double = 0
            var t: Double = 0
            
            let _x = Int(point.x)
            let _y = Int(point.y)
            
            let a = Int(a)
            
            let min_x = _x - a + 1
            let max_x = _x + a + 1
            let min_y = _y - a + 1
            let max_y = _y + a + 1
            
            let x_range = 0..<width
            let y_range = 0..<height
            
            for y in min_y..<max_y {
                for x in min_x..<max_x {
                    let l = _kernel((point - Point(x: x, y: y)).magnitude)
                    let _source = x_range.contains(x) && y_range.contains(y) ? ColorPixel(source[y * width + x]) : ColorPixel(color: source[y.clamped(to: y_range) * width + x.clamped(to: x_range)].color, alpha: 0)
                    s_color = s_color.blend(_source.color) { $0 + $1 * l }
                    s_alpha += _source.alpha * l
                    t += l
                }
            }
            return t == 0 ? Pixel() : Pixel(color: s_color.blend { $0 / t }, alpha: s_alpha / t)
        }
    }
}
