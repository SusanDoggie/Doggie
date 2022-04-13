//
//  AnyImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
    
    public let base: any ImageProtocol
    
    @inlinable
    public init(_ image: any ImageProtocol) {
        if let image = image as? AnyImage {
            self = image
        } else {
            self.base = image
        }
    }
}

extension AnyImage {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyImage, rhs: AnyImage) -> Bool {
        return lhs.base._equalTo(rhs.base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: AnyImage) -> Bool {
        return base._isStorageEqual(other.base)
    }
}

extension AnyImage {
    
    @inlinable
    public var colorSpace: AnyColorSpace {
        return AnyColorSpace(base.colorSpace)
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return base.numberOfComponents
    }
    
    @inlinable
    public var width: Int {
        return base.width
    }
    
    @inlinable
    public var height: Int {
        return base.height
    }
    
    @inlinable
    public subscript(x: Int, y: Int) -> AnyColor {
        get {
            return base.color(x: x, y: y)
        }
        set {
            base.setColor(x: x, y: y, color: newValue)
        }
    }
    
    @inlinable
    public var resolution: Resolution {
        get {
            return base.resolution
        }
        set {
            base.resolution = newValue
        }
    }
    
    @inlinable
    public var isOpaque: Bool {
        return base.isOpaque
    }
    
    @inlinable
    public var visibleRect: Rect {
        return base.visibleRect
    }
    
    @inlinable
    public var fileBacked: Bool {
        get {
            return base.fileBacked
        }
        set {
            base.fileBacked = newValue
        }
    }
    
    @inlinable
    public func setMemoryAdvise(_ advise: MemoryAdvise) {
        return base.setMemoryAdvise(advise)
    }
    
    @inlinable
    public func memoryLock() {
        base.memoryLock()
    }
    
    @inlinable
    public func memoryUnlock() {
        base.memoryUnlock()
    }
    
    @inlinable
    public mutating func setOrientation(_ orientation: ImageOrientation) {
        return base.setOrientation(orientation)
    }
    
    @inlinable
    public func linearTone() -> AnyImage {
        return AnyImage(base.linearTone())
    }
    
    @inlinable
    public func withWhiteBalance(_ white: Point) -> AnyImage {
        return AnyImage(base.withWhiteBalance(white))
    }
    
    @inlinable
    public func premultiplied() -> AnyImage {
        return AnyImage(base.premultiplied())
    }
    
    @inlinable
    public func unpremultiplied() -> AnyImage {
        return AnyImage(base.unpremultiplied())
    }
    
    @inlinable
    public func transposed() -> AnyImage {
        return AnyImage(base.transposed())
    }
    
    @inlinable
    public func verticalFlipped() -> AnyImage {
        return AnyImage(base.verticalFlipped())
    }
    
    @inlinable
    public func horizontalFlipped() -> AnyImage {
        return AnyImage(base.horizontalFlipped())
    }
}

extension AnyImage {
    
    @inlinable
    public func convert<P>(to colorSpace: DoggieGraphics.ColorSpace<P.Model>, intent: RenderingIntent = .default) -> Image<P> {
        return self.base.convert(to: colorSpace, intent: intent)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyImage {
        return self.base.convert(to: colorSpace, intent: intent)
    }
}

extension _ColorSpaceProtocol {
    
    @inlinable
    func _create_image<P>(image: Image<P>, intent: RenderingIntent) -> any ImageProtocol {
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
        return AnyImage(colorSpace.base._create_image(image: self, intent: intent))
    }
}

extension ImageProtocol {
    
    @inlinable
    func _copy<Pixel>() -> Image<Pixel>? {
        guard let colorSpace = self.colorSpace as? ColorSpace<Pixel.Model> else { return nil }
        let pixels = self.pixels as? MappedBuffer<Pixel> ?? self.pixels.map { Pixel(color: $0.color as! Pixel.Model, opacity: $0.opacity) }
        return Image<Pixel>(width: self.width, height: self.height, resolution: self.resolution, colorSpace: colorSpace, pixels: pixels)
    }
}

extension Image {
    
    @inlinable
    public init?(_ image: AnyImage) {
        guard let image = image.base as? Image ?? image.base._copy() else { return nil }
        self = image
    }
}
