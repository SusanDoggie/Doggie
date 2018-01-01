//
//  AnyImage.swift
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

import Foundation

@_versioned
protocol AnyImageBaseProtocol {
    
    var _colorSpace: AnyColorSpaceBaseProtocol { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get set }
    
    var isOpaque: Bool { get }
    
    var option: MappedBufferOption { get }
    
    func _color(x: Int, y: Int) -> AnyColorBaseProtocol
    
    mutating func _setColor(x: Int, y: Int, color: AnyColor)
    
    mutating func setWhiteBalance(_ white: Point)
    
    func _linearTone() -> AnyImageBaseProtocol
    
    func _transposed() -> AnyImageBaseProtocol
    
    func _verticalFlipped() -> AnyImageBaseProtocol
    
    func _horizontalFlipped() -> AnyImageBaseProtocol
    
    func _convert<Pixel>(colorSpace: Image<Pixel>.ColorSpace, intent: RenderingIntent, option: MappedBufferOption) -> Image<Pixel>
    
    func _copy(option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _copy<Model>() -> Image<ColorPixel<Model>>?
}

extension Image : AnyImageBaseProtocol {
    
    @_versioned
    @_inlineable
    var _colorSpace: AnyColorSpaceBaseProtocol {
        return self.colorSpace
    }
    
    @_versioned
    @_inlineable
    func _linearTone() -> AnyImageBaseProtocol {
        return self._linearTone()
    }
    
    @_versioned
    @_inlineable
    func _transposed() -> AnyImageBaseProtocol {
        return self._transposed()
    }
    
    @_versioned
    @_inlineable
    func _verticalFlipped() -> AnyImageBaseProtocol {
        return self._verticalFlipped()
    }
    
    @_versioned
    @_inlineable
    func _horizontalFlipped() -> AnyImageBaseProtocol {
        return self._horizontalFlipped()
    }
    
    @_versioned
    @_inlineable
    func _color(x: Int, y: Int) -> AnyColorBaseProtocol {
        return self[x, y]
    }
    
    @_versioned
    @_inlineable
    mutating func _setColor(x: Int, y: Int, color: AnyColor) {
        precondition(0..<width ~= x && 0..<height ~= y)
        pixels[width * y + x] = Pixel(color.convert(to: colorSpace))
    }
    
    @_versioned
    @_inlineable
    func _convert<Pixel>(colorSpace: Image<Pixel>.ColorSpace, intent: RenderingIntent, option: MappedBufferOption) -> Image<Pixel> {
        return Image<Pixel>(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
    
    @_versioned
    @_inlineable
    func _copy(option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image(image: self, option: option)
    }
    
    @_versioned
    @_inlineable
    func _copy<Model>() -> Image<ColorPixel<Model>>? {
        let image = self as? Image<ColorPixel<Pixel.Model>> ?? Image<ColorPixel<Pixel.Model>>(image: self, option: self.option)
        return image as? Image<ColorPixel<Model>>
    }
}

@_fixed_layout
public struct AnyImage : ImageProtocol {
    
    @_versioned
    var _base: AnyImageBaseProtocol
    
    @_versioned
    @_inlineable
    init(base: AnyImageBaseProtocol) {
        self._base = base
    }
    
    @_inlineable
    public var base: Any {
        return _base
    }
}

extension AnyImage {
    
    @_inlineable
    public init<Model>(_ image: Image<Model>) {
        self._base = image
    }
    
    @_inlineable
    public init(_ image: AnyImage) {
        self = image
    }
    
    @_inlineable
    public init<Pixel: ColorPixelProtocol>(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel(), option: MappedBufferOption = .default) {
        self._base = Image<Pixel>(width: width, height: height, resolution: resolution, colorSpace: colorSpace, pixel: pixel, option: option)
    }
    
    @_inlineable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, option: MappedBufferOption = .default) {
        self.init(base: colorSpace._base._create_image(width: width, height: height, resolution: resolution, option: option))
    }
}

extension AnyImage {
    
    @_inlineable
    public init(image: AnyImage, option: MappedBufferOption) {
        self.init(base: image._base._copy(option: option))
    }
    
    @_inlineable
    public init<P>(image: Image<P>, colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption = .default) {
        self.init(base: colorSpace._base._create_image(image: image, intent: intent, option: option))
    }
    
    @_inlineable
    public init(image: AnyImage, colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self.init(base: colorSpace._base._create_image(image: image, intent: intent, option: option))
    }
    
    @_inlineable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
    
    @_inlineable
    public var width: Int {
        return _base.width
    }
    
    @_inlineable
    public var height: Int {
        return _base.height
    }
    
    @_inlineable
    public subscript(x: Int, y: Int) -> AnyColor {
        get {
            return AnyColor(base: _base._color(x: x, y: y))
        }
        set {
            _base._setColor(x: x, y: y, color: newValue)
        }
    }
    
    @_inlineable
    public var resolution: Resolution {
        get {
            return _base.resolution
        }
        set {
            _base.resolution = newValue
        }
    }
    
    @_inlineable
    public var isOpaque: Bool {
        return _base.isOpaque
    }
    
    @_inlineable
    public var option: MappedBufferOption {
        return _base.option
    }
    
    @_inlineable
    public mutating func setWhiteBalance(_ white: Point) {
        return _base.setWhiteBalance(white)
    }
    
    @_inlineable
    public func linearTone() -> AnyImage {
        return AnyImage(base: _base._linearTone())
    }
    
    @_inlineable
    public func transposed() -> AnyImage {
        return AnyImage(base: _base._transposed())
    }
    
    @_inlineable
    public func verticalFlipped() -> AnyImage {
        return AnyImage(base: _base._verticalFlipped())
    }
    
    @_inlineable
    public func horizontalFlipped() -> AnyImage {
        return AnyImage(base: _base._horizontalFlipped())
    }
}

extension Image {
    
    @_inlineable
    public init(image: AnyImage, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self = image._base._convert(colorSpace: colorSpace, intent: intent, option: option)
    }
    
    @_inlineable
    public init?(image: AnyImage) {
        if let image = image._base as? Image {
            self.init(image: image, option: image.option)
        } else {
            guard let image: Image<ColorPixel<Pixel.Model>> = image._base._copy() else { return nil }
            self.init(image: image, option: image.option)
        }
    }
}
