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


@_versioned
protocol AnyImageBaseProtocol {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var _colorSpace: AnyColorSpaceBaseProtocol { get }
    
    func _draw<Model>(context: ImageContext<Model>, transform: SDTransform)
    
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyImageBaseProtocol
    
    func _convert<P>(to colorSpace: ColorSpace<P.Model>, intent: RenderingIntent) -> Image<P>
    
    func _resize(width: Int, height: Int, resampling algorithm: ResamplingAlgorithm, antialias: Bool) -> AnyImageBaseProtocol
    
    func _resize(width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm, antialias: Bool) -> AnyImageBaseProtocol
}

extension Image : AnyImageBaseProtocol {
    
    @_versioned
    @_inlineable
    var _colorSpace: AnyColorSpaceBaseProtocol {
        return self.colorSpace
    }
    
    @_versioned
    @_inlineable
    func _draw<Model>(context: ImageContext<Model>, transform: SDTransform) {
        context.draw(image: self, transform: transform)
    }
    
    @_versioned
    @_inlineable
    func _convert(to colorSpace: AnyColorSpaceBaseProtocol, intent: RenderingIntent) -> AnyImageBaseProtocol {
        return colorSpace._convert(self, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func _convert<P>(to colorSpace: ColorSpace<P.Model>, intent: RenderingIntent) -> Image<P> {
        return Image<P>(image: self, colorSpace: colorSpace, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func _resize(width: Int, height: Int, resampling algorithm: ResamplingAlgorithm, antialias: Bool) -> AnyImageBaseProtocol {
        return Image<Pixel>(image: self, width: width, height: height, resampling: algorithm, antialias: antialias)
    }
    
    @_versioned
    @_inlineable
    func _resize(width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm, antialias: Bool) -> AnyImageBaseProtocol {
        return Image<Pixel>(image: self, width: width, height: height, transform: transform, resampling: algorithm, antialias: antialias)
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
    public init(width: Int, height: Int, colorSpace: AnyColorSpace) {
        self.init(base: colorSpace._base._createImage(width: width, height: height))
    }
    
    @_inlineable
    public init<Pixel>(_ image: Image<Pixel>) {
        self._base = image
    }
    
    @_inlineable
    public init<Pixel: ColorPixelProtocol>(width: Int, height: Int, colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel()) {
        self.init(Image(width: width, height: height, colorSpace: colorSpace, pixel: pixel))
    }
    
    @_inlineable
    public init<Pixel, Model>(image: Image<Pixel>, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) {
        self._base = image._convert(to: colorSpace, intent: intent)
    }
    
    @_inlineable
    public init<Model>(image: AnyImage, colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) {
        self._base = image._base._convert(to: colorSpace, intent: intent)
    }
    
    @_inlineable
    public init<Pixel>(image: Image<Pixel>, colorSpace: AnyColorSpace, intent: RenderingIntent = .default) {
        self._base = image._convert(to: colorSpace._base, intent: intent)
    }
    
    @_inlineable
    public init<Pixel>(image: Image<Pixel>, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self._base = image._resize(width: width, height: height, resampling: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init<Pixel>(image: Image<Pixel>, width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self._base = image._resize(width: width, height: height, transform: transform, resampling: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init(image: AnyImage, colorSpace: AnyColorSpace, intent: RenderingIntent = .default) {
        self._base = image._base._convert(to: colorSpace._base, intent: intent)
    }
    
    @_inlineable
    public init(image: AnyImage, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self._base = image._base._resize(width: width, height: height, resampling: algorithm, antialias: antialias)
    }
    
    @_inlineable
    public init(image: AnyImage, width: Int, height: Int, transform: SDTransform, resampling algorithm: ResamplingAlgorithm = .default, antialias: Bool = false) {
        self._base = image._base._resize(width: width, height: height, transform: transform, resampling: algorithm, antialias: antialias)
    }
}

extension AnyImage {
    
    @_inlineable
    public func convert<P>(to colorSpace: ColorSpace<P.Model>, intent: RenderingIntent = .default) -> Image<P> {
        return _base._convert(to: colorSpace, intent: intent)
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
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
}

extension ImageContext {
    
    @_inlineable
    public func draw(image: AnyImage, transform: SDTransform) {
        image._base._draw(context: self, transform: transform)
    }
}
