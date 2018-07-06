//
//  Image.swift
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

@_fixed_layout
public struct Image<Pixel: ColorPixelProtocol> : ImageProtocol, Hashable {
    
    public let width: Int
    public let height: Int
    
    public var resolution: Resolution
    
    public private(set) var pixels: MappedBuffer<Pixel>
    
    public var colorSpace: ColorSpace<Pixel.Model>
    
    @usableFromInline
    var cache = Cache<String>()
    
    @inlinable
    init(width: Int, height: Int, resolution: Resolution, pixels: MappedBuffer<Pixel>, colorSpace: ColorSpace<Pixel.Model>) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self.pixels = pixels
        self.colorSpace = colorSpace
    }
    
    @inlinable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel(), option: MappedBufferOption = .default) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
        self.pixels = MappedBuffer(repeating: pixel, count: width * height, option: option)
    }
    
    @inlinable
    public init(image: Image, option: MappedBufferOption) {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        self.pixels = MappedBuffer(image.pixels, option: option)
    }
    
    @inlinable
    public init<P>(image: Image<P>, option: MappedBufferOption) where P.Model == Pixel.Model {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        if let buffer = image.pixels as? MappedBuffer<Pixel> {
            self.pixels = MappedBuffer(buffer, option: option)
        } else {
            self.pixels = image.pixels.map(option: option, Pixel.init)
        }
    }
    
    @inlinable
    public init<P>(image: Image<P>, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default, option: MappedBufferOption) {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = colorSpace
        if image.colorSpace as? ColorSpace<Pixel.Model> == colorSpace {
            if let buffer = image.pixels as? MappedBuffer<Pixel> {
                self.pixels = MappedBuffer(buffer, option: option)
            } else {
                self.pixels = image.pixels.map(option: option) { Pixel(color: $0.color as! Pixel.Model, opacity: $0.opacity) }
            }
        } else {
            self.pixels = image.colorSpace.convert(image.pixels, to: self.colorSpace, intent: intent, option: option)
        }
    }
}

extension Image {
    
    @inlinable
    public init<P>(image: Image<P>) where P.Model == Pixel.Model {
        self.init(image: image, option: image.option)
    }
}

extension Image {
    
    @inlinable
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
    public static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.resolution == rhs.resolution && lhs.colorSpace == rhs.colorSpace && (lhs.cache.identifier == rhs.cache.identifier || lhs.pixels == rhs.pixels)
    }
}

extension Image : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "Image<\(Pixel.self)>(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution))"
    }
}

extension Image {
    
    @inlinable
    public var option: MappedBufferOption {
        return pixels.option
    }
}

extension Image {
    
    @inlinable
    public func color(x: Int, y: Int) -> Doggie.Color<Pixel.Model> {
        precondition(0..<width ~= x && 0..<height ~= y)
        return Color(colorSpace: colorSpace, color: pixels[width * y + x])
    }
    
    @inlinable
    public func color(x: Int, y: Int) -> AnyColor {
        precondition(0..<width ~= x && 0..<height ~= y)
        return AnyColor(colorSpace: colorSpace, color: pixels[width * y + x])
    }
    
    @inlinable
    public mutating func setColor<C: ColorProtocol>(x: Int, y: Int, color: C) {
        cache = Cache()
        precondition(0..<width ~= x && 0..<height ~= y)
        pixels[width * y + x] = Pixel(color.convert(to: colorSpace, intent: .default))
    }
}

extension Image {
    
    @inlinable
    public subscript(x: Int, y: Int) -> Doggie.Color<Pixel.Model> {
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
    public func linearTone() -> Image {
        return Image(width: height, height: width, resolution: resolution, pixels: pixels.map(colorSpace.convertToLinear), colorSpace: colorSpace.linearTone)
    }
    
    @inlinable
    public mutating func setWhiteBalance(_ white: Point) {
        
        cache = Cache()
        
        let colorSpace = self.colorSpace
        
        let m1 = colorSpace.base.cieXYZ._intentMatrix(to: CIEXYZColorSpace(white: colorSpace.referenceWhite.point), chromaticAdaptationAlgorithm: colorSpace.chromaticAdaptationAlgorithm, intent: .default)
        let m2 = CIEXYZColorSpace(white: white)._intentMatrix(to: colorSpace.base.cieXYZ, chromaticAdaptationAlgorithm: colorSpace.chromaticAdaptationAlgorithm, intent: .default)
        
        let matrix = m1 * m2
        
        pixels.withUnsafeMutableBufferPointer {
            
            guard var buffer = $0.baseAddress else { return }
            
            for _ in 0..<$0.count {
                buffer.pointee.color = colorSpace.convertFromXYZ(colorSpace.convertToXYZ(buffer.pointee.color) * matrix)
                buffer += 1
            }
        }
    }
}

extension Image {
    
    @inlinable
    public var isOpaque: Bool {
        return pixels.allSatisfy { $0.isOpaque }
    }
}

extension Image {
    
    @inlinable
    public func map<P>(_ transform: (Pixel) throws -> P) rethrows -> Image<P> where P.Model == Pixel.Model {
        return try Image<P>(width: width, height: height, resolution: resolution, pixels: pixels.map(transform), colorSpace: colorSpace)
    }
}

extension Image {
    
    @inlinable
    public mutating func setOrientation(_ orientation: ImageOrientation) {
        
        switch orientation {
        case .up, .upMirrored, .down, .downMirrored: cache = Cache()
        case .leftMirrored, .left, .rightMirrored, .right: self = self.transposed()
        }
        
        guard pixels.count != 0 else { return }
        
        let width = self.width
        let height = self.height
        
        switch orientation {
        case .up, .leftMirrored: break
        case .right, .upMirrored:
            
            pixels.withUnsafeMutableBufferPointer {
                
                guard let buffer = $0.baseAddress else { return }
                
                var buf1 = buffer
                var buf2 = buffer + width - 1
                
                for _ in 0..<width >> 1 {
                    Swap(height, buf1, width, buf2, width)
                    buf1 += 1
                    buf2 -= 1
                }
            }
            
        case .left, .downMirrored:
            
            pixels.withUnsafeMutableBufferPointer {
                
                guard let buffer = $0.baseAddress else { return }
                
                var buf1 = buffer
                var buf2 = buffer + width * (height - 1)
                
                for _ in 0..<height >> 1 {
                    Swap(width, buf1, 1, buf2, 1)
                    buf1 += width
                    buf2 -= width
                }
            }
            
        case .down, .rightMirrored:
            
            pixels.withUnsafeMutableBufferPointer {
                guard let buffer = $0.baseAddress else { return }
                Swap($0.count >> 1, buffer, 1, buffer + $0.count - 1, -1)
            }
        }
    }
}

extension Image {
    
    @inlinable
    public func transposed() -> Image {
        if pixels.count == 0 {
            return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: [], colorSpace: colorSpace)
        }
        var copy = pixels
        pixels.withUnsafeBufferPointer { source in copy.withUnsafeMutableBufferPointer { destination in Transpose(height, width, source.baseAddress!, 1, destination.baseAddress!, 1) } }
        return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: copy, colorSpace: colorSpace)
    }
    
    @inlinable
    public func verticalFlipped() -> Image {
        var copy = self
        copy.setOrientation(.downMirrored)
        return copy
    }
    
    @inlinable
    public func horizontalFlipped() -> Image {
        var copy = self
        copy.setOrientation(.upMirrored)
        return copy
    }
}

extension Image {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        cache = Cache()
        return try pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try pixels.withUnsafeBytes(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        cache = Cache()
        return try pixels.withUnsafeMutableBytes(body)
    }
}

