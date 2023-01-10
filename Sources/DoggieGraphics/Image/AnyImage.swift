//
//  AnyImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct AnyImage: ImageProtocol {
    
    @usableFromInline
    var _base: any _ImageProtocol
    
    @inlinable
    init(base image: any _ImageProtocol) {
        self._base = image
    }
    
    @inlinable
    public init(_ image: AnyImage) {
        self = image
    }
    
    @inlinable
    public init<Pixel>(_ image: Image<Pixel>) {
        self._base = image
    }
}

extension AnyImage {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyImage, rhs: AnyImage) -> Bool {
        return lhs._base._equalTo(rhs._base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: AnyImage) -> Bool {
        return _base._isStorageEqual(other._base)
    }
}

extension _ImageProtocol {
    
    @inlinable
    var _colorSpace: any _ColorSpaceProtocol {
        return colorSpace
    }
}

extension AnyImage {
    
    @inlinable
    public var base: any ImageProtocol {
        return self._base
    }
    
    @inlinable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base: _base._colorSpace)
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return _base.numberOfComponents
    }
    
    @inlinable
    public var width: Int {
        return _base.width
    }
    
    @inlinable
    public var height: Int {
        return _base.height
    }
    
    @inlinable
    public subscript(x: Int, y: Int) -> AnyColor {
        get {
            return _base.color(x: x, y: y)
        }
        set {
            _base.setColor(x: x, y: y, color: newValue)
        }
    }
    
    @inlinable
    public var resolution: Resolution {
        get {
            return _base.resolution
        }
        set {
            _base.resolution = newValue
        }
    }
    
    @inlinable
    public var isOpaque: Bool {
        return _base.isOpaque
    }
    
    @inlinable
    public var visibleRect: Rect {
        return _base.visibleRect
    }
    
    @inlinable
    public var fileBacked: Bool {
        get {
            return _base.fileBacked
        }
        set {
            _base.fileBacked = newValue
        }
    }
    
    @inlinable
    public func setMemoryAdvise(_ advise: MemoryAdvise) {
        return _base.setMemoryAdvise(advise)
    }
    
    @inlinable
    public func memoryLock() {
        _base.memoryLock()
    }
    
    @inlinable
    public func memoryUnlock() {
        _base.memoryUnlock()
    }
    
    @inlinable
    public mutating func setOrientation(_ orientation: ImageOrientation) {
        return _base.setOrientation(orientation)
    }
    
    @inlinable
    public func linearTone() -> AnyImage {
        return AnyImage(base: _base.linearTone())
    }
    
    @inlinable
    public func withWhiteBalance(_ white: Point) -> AnyImage {
        return AnyImage(base: _base.withWhiteBalance(white))
    }
    
    @inlinable
    public func premultiplied() -> AnyImage {
        return AnyImage(base: _base.premultiplied())
    }
    
    @inlinable
    public func unpremultiplied() -> AnyImage {
        return AnyImage(base: _base.unpremultiplied())
    }
    
    @inlinable
    public func transposed() -> AnyImage {
        return AnyImage(base: _base.transposed())
    }
    
    @inlinable
    public func verticalFlipped() -> AnyImage {
        return AnyImage(base: _base.verticalFlipped())
    }
    
    @inlinable
    public func horizontalFlipped() -> AnyImage {
        return AnyImage(base: _base.horizontalFlipped())
    }
}

extension AnyImage {
    
    @inlinable
    public func convert<P>(to colorSpace: DoggieGraphics.ColorSpace<P.Model>, intent: RenderingIntent = .default) -> Image<P> {
        return self._base.convert(to: colorSpace, intent: intent)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyImage {
        return self._base.convert(to: colorSpace, intent: intent)
    }
}

extension _ColorSpaceProtocol {
    
    @inlinable
    func _create_image<P>(image: Image<P>, intent: RenderingIntent) -> any _ImageProtocol {
        if let colorSpace = self as? ColorSpace<P.Model> {
            return Image<P>(image: image, colorSpace: colorSpace, intent: intent)
        } else {
            return Image<Float32ColorPixel<Model>>(image: image, colorSpace: self as! ColorSpace<Model>, intent: intent)
        }
    }
}

extension Image {
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyImage {
        return AnyImage(base: colorSpace._base._create_image(image: self, intent: intent))
    }
}

extension _ImageProtocol {
    
    @inlinable
    func _copy<Pixel>() -> Image<Pixel>? {
        guard let colorSpace = self.colorSpace as? DoggieGraphics.ColorSpace<Pixel.Model> else { return nil }
        let pixels = self.pixels as? MappedBuffer<Pixel> ?? self.pixels.map { Pixel(color: $0.color as! Pixel.Model, opacity: $0.opacity) }
        return Image<Pixel>(width: self.width, height: self.height, resolution: self.resolution, colorSpace: colorSpace, pixels: pixels)
    }
}

extension Image {
    
    @inlinable
    public init?(_ image: AnyImage) {
        guard let image = image._base as? Image ?? image._base._copy() else { return nil }
        self = image
    }
}
