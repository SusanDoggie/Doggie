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

private protocol ImageBaseProtocol {
    
    var colorModel: ColorModelProtocol.Type { get }
    
    subscript(position: Int) -> Color { get set }
    
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model
    
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm) -> ImageBaseProtocol where RPixel.Model == RSpace.Model
    
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R
    
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

private struct ImageBase<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol> : ImageBaseProtocol where ColorPixel.Model == ColorSpace.Model {
    
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
    
    func convert<RPixel: ColorPixelProtocol, RSpace : ColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> ImageBaseProtocol where RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, alpha: $1.alpha) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    func convert<RPixel: ColorPixelProtocol, RSpace : LinearColorSpaceProtocol>(pixel: RPixel.Type, colorSpace: RSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> ImageBaseProtocol where RPixel.Model == RSpace.Model {
        let _buffer = zip(self.colorSpace.convert(buffer.map { $0.color }, to: colorSpace, algorithm: algorithm), buffer).map { RPixel(color: $0, alpha: $1.alpha) }
        return ImageBase<RPixel, RSpace>(buffer: _buffer, colorSpace: colorSpace, algorithm: algorithm)
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
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(width: Int, height: Int, pixel: ColorPixel, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = width
        self.height = height
        self.base = ImageBase(buffer: [ColorPixel](repeating: pixel, count: width * height), colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.width = image.width
        self.height = image.height
        self.base = image.base.convert(pixel: pixel, colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : LinearColorSpaceProtocol>(image: Image, pixel: ColorPixel.Type, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
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
