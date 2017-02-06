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
        
        var result = [ColorPixel](repeating: ColorPixel(), count: width * height)
        
        if buffer.count != 0 {
            let s_height = buffer.count / s_width
            let _transform = transform.inverse
            
            self.buffer.withUnsafeBufferPointer { source in
                if let source = source.baseAddress {
                    result.withUnsafeMutableBufferPointer { buffer in
                        if var pointer = buffer.baseAddress {
                            for i in buffer.indices {
                                pointer.pointee = algorithm.calculate(source: source, width: s_width, height: s_height, point: Point(x: i % width, y: i / width) * _transform)
                                pointer += 1
                            }
                        }
                    }
                }
            }
        }
        return ImageBase(buffer: result, colorSpace: self.colorSpace, algorithm: self.algorithm)
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
    
    public init<T: SDTransformProtocol>(image: Image, width: Int, height: Int, transform: T, resampling algorithm: ResamplingAlgorithm = .lanczos(3)) {
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
        case lanczos(Int)
    }
}

extension Image.ResamplingAlgorithm {
    
    func calculate<ColorPixel: ColorPixelProtocol>(source: UnsafePointer<ColorPixel>, width: Int, height: Int, point: Point) -> ColorPixel where ColorPixel.Model : ColorBlendProtocol {
        switch self {
        case .none:
            
            let _x = Int(point.x.rounded())
            let _y = Int(point.y.rounded())
            return source[_y * width + _x]
            
        case let .lanczos(a):
            
            let a = abs(a)
            
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
            
            var s_color = ColorPixel.Model()
            var s_alpha: Double = 0
            var t: Double = 0
            
            let _x = Int(point.x)
            let _y = Int(point.y)
            
            let min_x = (_x - a + 1).clamped(to: 0..<width)
            let max_x = (_x + a + 1).clamped(to: 0..<width)
            let min_y = (_y - a + 1).clamped(to: 0..<height)
            let max_y = (_y + a + 1).clamped(to: 0..<height)
            
            for y in min_y..<max_y {
                let _y = y * width
                for x in min_x..<max_x {
                    let l = _kernel((point - Point(x: x, y: y)).magnitude)
                    let _source = source[x + _y]
                    s_color = s_color.blend(source: _source.color) { $0 + $1 * l }
                    s_alpha += _source.alpha * l
                    t += l
                }
            }
            return t == 0 ? ColorPixel() : ColorPixel(color: s_color.blend { $0 / t }, alpha: s_alpha / t)
        }
    }
}
