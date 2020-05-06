//
//  Image.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@frozen
public struct Image<Pixel: ColorPixel>: ImageProtocol, RawPixelProtocol {
    
    public let width: Int
    public let height: Int
    
    public var resolution: Resolution
    
    @usableFromInline
    var _pixels: MappedBuffer<Pixel>
    
    @inlinable
    @inline(__always)
    public var pixels: MappedBuffer<Pixel> {
        return _pixels
    }
    
    public var colorSpace: ColorSpace<Pixel.Model> {
        didSet {
            cache = ImageCache()
        }
    }
    
    @usableFromInline
    var cache = ImageCache()
    
    @inlinable
    @inline(__always)
    init(width: Int, height: Int, resolution: Resolution, pixels: MappedBuffer<Pixel>, colorSpace: ColorSpace<Pixel.Model>) {
        precondition(_isPOD(Pixel.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self._pixels = pixels
        self.colorSpace = colorSpace
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int, resolution: Resolution = .default, colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel(), fileBacked: Bool = false) {
        precondition(_isPOD(Pixel.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
        self._pixels = MappedBuffer(repeating: pixel, count: width * height, fileBacked: fileBacked)
    }
    
    @inlinable
    @inline(__always)
    public init<P>(_ image: Image<P>) where P.Model == Pixel.Model {
        precondition(_isPOD(Pixel.self), "invalid pixel type.")
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        self._pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map(Pixel.init)
    }
    
    @inlinable
    @inline(__always)
    public init<P>(image: Image<P>, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default) {
        
        precondition(_isPOD(Pixel.self), "invalid pixel type.")
        
        if image.colorSpace as? ColorSpace<Pixel.Model> == colorSpace {
            
            self.width = image.width
            self.height = image.height
            self.resolution = image.resolution
            self.colorSpace = colorSpace
            self._pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map { Pixel(color: $0.color as! Pixel.Model, opacity: $0.opacity) }
            
        } else {
            
            let key = ImageCacheColorConversionKey<Pixel>(colorSpace: colorSpace, intent: intent)
            
            if let _image = image.cache.lck.synchronized(block: { image.cache.color_conversion[key] as? Image }) {
                
                self = _image
                
            } else {
                
                self.width = image.width
                self.height = image.height
                self.resolution = image.resolution
                self.colorSpace = colorSpace
                self._pixels = image.colorSpace.convert(image.pixels, to: colorSpace, intent: intent)
                
                let _self = self
                image.cache.lck.synchronized { image.cache.color_conversion[key] = _self }
            }
        }
    }
}

extension Image where Pixel: _GrayColorPixel {
    
    @inlinable
    @inline(__always)
    public init<P: _GrayColorPixel>(_ image: Image<P>) {
        let pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map(Pixel.init)
        self.init(width: image.width, height: image.height, resolution: image.resolution, pixels: pixels, colorSpace: image.colorSpace)
    }
    
    @inlinable
    @inline(__always)
    public init<P: _GrayColorPixel>(_ image: Image<P>) where P.Component == Pixel.Component {
        let pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map(Pixel.init)
        self.init(width: image.width, height: image.height, resolution: image.resolution, pixels: pixels, colorSpace: image.colorSpace)
    }
}

extension Image where Pixel: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    public init<P: _RGBColorPixel>(_ image: Image<P>) {
        let pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map(Pixel.init)
        self.init(width: image.width, height: image.height, resolution: image.resolution, pixels: pixels, colorSpace: image.colorSpace)
    }
    
    @inlinable
    @inline(__always)
    public init<P: _RGBColorPixel>(_ image: Image<P>) where P.Component == Pixel.Component {
        let pixels = image.pixels as? MappedBuffer<Pixel> ?? image.pixels.map(Pixel.init)
        self.init(width: image.width, height: image.height, resolution: image.resolution, pixels: pixels, colorSpace: image.colorSpace)
    }
}

@usableFromInline
final class ImageCache {
    
    @usableFromInline
    let lck = SDLock()
    
    var isOpaque: Bool?
    var visibleRect: Rect?
    
    @usableFromInline
    var color_conversion: [AnyHashable: Any]
    
    var table: [String: Any]
    
    @usableFromInline
    init() {
        self.isOpaque = nil
        self.visibleRect = nil
        self.color_conversion = [:]
        self.table = [:]
    }
}

@usableFromInline
struct ImageCacheColorConversionKey<Pixel: ColorPixel>: Hashable {
    
    @usableFromInline
    let colorSpace: ColorSpace<Pixel.Model>
    
    @usableFromInline
    let intent: RenderingIntent
    
    @usableFromInline
    init(colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent) {
        self.colorSpace = colorSpace
        self.intent = intent
    }
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Pixel.self))
        hasher.combine(colorSpace)
        hasher.combine(intent)
    }
}

extension ImageCache {
    
    func load<Value>(for key: String) -> Value? {
        return lck.synchronized { table[key] as? Value }
    }
    
    func load<Value>(for key: String, body: () -> Value) -> Value {
        
        return lck.synchronized {
            
            if let object = table[key], let value = object as? Value {
                return value
            }
            let value = body()
            table[key] = value
            return value
        }
    }
    
    func store<Value>(value: Value, for key: String) {
        lck.synchronized { table[key] = value }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(resolution)
        hasher.combine(colorSpace)
        withUnsafeBufferPointer {
            for element in $0.prefix(16) {
                hasher.combine(element)
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.resolution == rhs.resolution && lhs.colorSpace == rhs.colorSpace && lhs.pixels == rhs.pixels
    }
    
    @inlinable
    @inline(__always)
    public func isStorageEqual(_ other: Image) -> Bool {
        return self.width == other.width && self.height == other.height && self.resolution == other.resolution && self.colorSpace.isStorageEqual(other.colorSpace) && self.pixels.isStorageEqual(other.pixels)
    }
}

extension Image: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Image<\(Pixel.self)>(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution))"
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public var numberOfComponents: Int {
        return Pixel.numberOfComponents
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public var fileBacked: Bool {
        get {
            return pixels.fileBacked
        }
        set {
            _pixels.fileBacked = newValue
        }
    }
    
    @inlinable
    public func setMemoryAdvise(_ advise: MemoryAdvise) {
        pixels.setMemoryAdvise(advise)
    }
    
    @inlinable
    public func memoryLock() {
        pixels.memoryLock()
    }
    
    @inlinable
    public func memoryUnlock() {
        pixels.memoryUnlock()
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func color(x: Int, y: Int) -> DoggieGraphics.Color<Pixel.Model> {
        precondition(0..<width ~= x && 0..<height ~= y)
        return Color(colorSpace: colorSpace, color: pixels[width * y + x])
    }
    
    @inlinable
    @inline(__always)
    public func color(x: Int, y: Int) -> AnyColor {
        precondition(0..<width ~= x && 0..<height ~= y)
        return AnyColor(colorSpace: colorSpace, color: pixels[width * y + x])
    }
    
    @inlinable
    @inline(__always)
    public mutating func setColor<C: ColorProtocol>(x: Int, y: Int, color: C) {
        cache = ImageCache()
        precondition(0..<width ~= x && 0..<height ~= y)
        _pixels[width * y + x] = Pixel(color.convert(to: colorSpace, intent: .default))
    }
}

extension Image {
    
    @inlinable
    public subscript(x: Int, y: Int) -> DoggieGraphics.Color<Pixel.Model> {
        get {
            return self.color(x: x, y: y)
        }
        set {
            self.setColor(x: x, y: y, color: newValue)
        }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func linearTone() -> Image {
        return Image(width: width, height: height, resolution: resolution, pixels: pixels.map(colorSpace.convertToLinear), colorSpace: colorSpace.linearTone)
    }
    
    @inlinable
    @inline(__always)
    public mutating func setWhiteBalance(_ white: Point) {
        
        cache = ImageCache()
        
        let colorSpace = self.colorSpace
        
        let m1 = colorSpace.base.cieXYZ._intentMatrix(to: CIEXYZColorSpace(white: colorSpace.referenceWhite.point), chromaticAdaptationAlgorithm: colorSpace.chromaticAdaptationAlgorithm, intent: .default)
        let m2 = CIEXYZColorSpace(white: white)._intentMatrix(to: colorSpace.base.cieXYZ, chromaticAdaptationAlgorithm: colorSpace.chromaticAdaptationAlgorithm, intent: .default)
        
        let matrix = m1 * m2
        
        _pixels.withUnsafeMutableBufferPointer {
            
            guard var buffer = $0.baseAddress else { return }
            
            for _ in 0..<$0.count {
                buffer.pointee.color = colorSpace.convertFromXYZ(colorSpace.convertToXYZ(buffer.pointee.color) * matrix)
                buffer += 1
            }
        }
    }
}

extension Image {
    
    public var isOpaque: Bool {
        return cache.lck.synchronized {
            if cache.isOpaque == nil {
                cache.isOpaque = pixels.allSatisfy { $0.isOpaque }
            }
            return cache.isOpaque!
        }
    }
    
    public var visibleRect: Rect {
        
        return cache.lck.synchronized {
            
            if cache.visibleRect == nil {
                
                cache.visibleRect = self.withUnsafeBufferPointer {
                    
                    guard let ptr = $0.baseAddress else { return Rect() }
                    
                    var top = 0
                    var left = 0
                    var bottom = 0
                    var right = 0
                    
                    loop: for y in (0..<height).reversed() {
                        let ptr = ptr + width * y
                        for x in 0..<width where ptr[x].opacity != 0 {
                            break loop
                        }
                        bottom += 1
                    }
                    
                    let max_y = height - bottom
                    
                    loop: for y in 0..<max_y {
                        let ptr = ptr + width * y
                        for x in 0..<width where ptr[x].opacity != 0 {
                            break loop
                        }
                        top += 1
                    }
                    
                    loop: for x in (0..<width).reversed() {
                        for y in top..<max_y where ptr[x + width * y].opacity != 0 {
                            break loop
                        }
                        right += 1
                    }
                    
                    let max_x = width - right
                    
                    loop: for x in 0..<max_x {
                        for y in top..<max_y where ptr[x + width * y].opacity != 0 {
                            break loop
                        }
                        left += 1
                    }
                    
                    return Rect(x: left, y: top, width: max_x - left, height: max_y - top)
                }
            }
            return cache.visibleRect!
        }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func map<P>(_ transform: (Pixel) throws -> P) rethrows -> Image<P> where P.Model == Pixel.Model {
        return try Image<P>(width: width, height: height, resolution: resolution, pixels: pixels.map(transform), colorSpace: colorSpace)
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func premultiplied() -> Image {
        return self.map { $0.premultiplied() }
    }
    
    @inlinable
    @inline(__always)
    public func unpremultiplied() -> Image {
        return self.map { $0.unpremultiplied() }
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func transposed() -> Image {
        if pixels.isEmpty {
            return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: [], colorSpace: colorSpace)
        }
        var copy = pixels
        pixels.withUnsafeBufferPointer { source in copy.withUnsafeMutableBufferPointer { destination in Transpose(width, height, source.baseAddress!, 1, destination.baseAddress!, 1) } }
        return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: copy, colorSpace: colorSpace)
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        cache = ImageCache()
        return try _pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try pixels.withUnsafeBytes(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        cache = ImageCache()
        return try _pixels.withUnsafeMutableBytes(body)
    }
}

