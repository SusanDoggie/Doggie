//
//  AnyImage.swift
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
protocol AnyImageBaseProtocol {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get set }
    
    var isOpaque: Bool { get }
    
    var option: MappedBufferOption { get }
    
    func rawData(format: RawBitmap.Format, bitsPerChannel: Int, bitsPerPixel: Int, bytesPerRow: Int, alphaChannel: RawBitmap.AlphaChannelFormat, channelEndianness: RawBitmap.Endianness, pixelEndianness: RawBitmap.Endianness, separated: Bool) -> [Data]
    
    var _colorSpace: AnyColorSpaceBaseProtocol { get }
    
    func _linearTone() -> AnyImageBaseProtocol
    
    func _transposed() -> AnyImageBaseProtocol
    
    func _verticalFlipped() -> AnyImageBaseProtocol
    
    func _horizontalFlipped() -> AnyImageBaseProtocol
    
    func _draw<Model>(context: ImageContext<Model>, transform: SDTransform)
    
    func _convert<Model>() -> Image<ColorPixel<Model>>?
    
    func _convert(option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _convert<P>(to colorSpace: ColorSpace<P.Model>, intent: RenderingIntent, option: MappedBufferOption) -> Image<P>
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
        return self.linearTone()
    }
    
    @_versioned
    @_inlineable
    func _transposed() -> AnyImageBaseProtocol {
        return self.transposed()
    }
    
    @_versioned
    @_inlineable
    func _verticalFlipped() -> AnyImageBaseProtocol {
        return self.verticalFlipped()
    }
    
    @_versioned
    @_inlineable
    func _horizontalFlipped() -> AnyImageBaseProtocol {
        return self.horizontalFlipped()
    }
    
    @_versioned
    @_inlineable
    func _draw<Model>(context: ImageContext<Model>, transform: SDTransform) {
        context.draw(image: self, transform: transform)
    }
    
    @_versioned
    @_inlineable
    func _convert<Model>() -> Image<ColorPixel<Model>>? {
        let image = self as? Image<ColorPixel<Pixel.Model>> ?? Image<ColorPixel<Pixel.Model>>(image: self)
        return image as? Image<ColorPixel<Model>>
    }
    
    @_versioned
    @_inlineable
    func _convert(option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image(image: self, option: option)
    }
    
    @_versioned
    @_inlineable
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol {
        return colorSpace._convert(self, intent: intent, option: option)
    }
    
    @_versioned
    @_inlineable
    func _convert<P>(to colorSpace: ColorSpace<P.Model>, intent: RenderingIntent, option: MappedBufferOption) -> Image<P> {
        return Image<P>(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
}

@_fixed_layout
public struct AnyImage {
    
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
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: AnyColorSpace, option: MappedBufferOption = .default) {
        self.init(base: colorSpace._base._createImage(width: width, height: height, resolution: resolution, option: option))
    }
    
    @_inlineable
    public init<Pixel>(_ image: Image<Pixel>, option: MappedBufferOption = .default) {
        self._base = image._convert(option: option)
    }
    
    @_inlineable
    public init(_ image: AnyImage, option: MappedBufferOption = .default) {
        self._base = image._base._convert(option: option)
    }
    
    @_inlineable
    public init<Pixel: ColorPixelProtocol>(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel(), option: MappedBufferOption = .default) {
        self.init(Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace, pixel: pixel, option: option))
    }
    
    @_inlineable
    public init<Pixel, Model>(image: Image<Pixel>, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self._base = image._convert(to: colorSpace, intent: intent, option: option)
    }
    
    @_inlineable
    public init<Model>(image: AnyImage, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self._base = image._base._convert(to: colorSpace, intent: intent, option: option)
    }
    
    @_inlineable
    public init<Pixel>(image: Image<Pixel>, colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self._base = image._convert(to: colorSpace._base, intent: intent, option: option)
    }
    
    @_inlineable
    public init(image: AnyImage, colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self._base = image._base._convert(to: colorSpace._base, intent: intent, option: option)
    }
    
    @_inlineable
    public init<Pixel, Model>(image: Image<Pixel>, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image.option)
    }
    
    @_inlineable
    public init<Model>(image: AnyImage, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image._base.option)
    }
    
    @_inlineable
    public init<Pixel>(image: Image<Pixel>, colorSpace: AnyColorSpace, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image.option)
    }
    
    @_inlineable
    public init(image: AnyImage, colorSpace: AnyColorSpace, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image._base.option)
    }
}

extension AnyImage {
    
    @_inlineable
    public var width: Int {
        return _base.width
    }
    
    @_inlineable
    public var height: Int {
        return _base.height
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
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
}

extension AnyImage {
    
    @_inlineable
    public func linearTone() -> AnyImage {
        return AnyImage(base: _base._linearTone())
    }
}

extension AnyImage {
    
    @_inlineable
    public var isOpaque: Bool {
        return _base.isOpaque
    }
}

extension AnyImage {
    
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
        self = image._base._convert(to: colorSpace, intent: intent, option: option)
    }
    
    @_inlineable
    public init(image: AnyImage, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image._base.option)
    }
    
    @_inlineable
    public init?(image: AnyImage) {
        if let image = image._base as? Image {
            self.init(image: image)
        } else {
            guard let image: Image<ColorPixel<Pixel.Model>> = image._base._convert() else { return nil }
            self.init(image: image)
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func draw(image: AnyImage, transform: SDTransform) {
        image._base._draw(context: self, transform: transform)
    }
}
