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

public struct Image<Pixel: ColorPixelProtocol> {
    
    public let width: Int
    public let height: Int
    
    public var resolution: Resolution
    
    public internal(set) var pixels: MappedBuffer<Pixel>
    
    public var colorSpace: ColorSpace<Pixel.Model>
    
    @_versioned
    @_inlineable
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
    
    @_inlineable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel()) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
        self.pixels = MappedBuffer<Pixel>(repeating: pixel, count: width * height)
    }
    
    @_inlineable
    public init<P>(image: Image<P>) where P.Model == Pixel.Model {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        self.pixels = image.pixels as? MappedBuffer<Pixel> ?? MappedBuffer<Pixel>(image.pixels.lazy.map(Pixel.init))
    }
    
    @_inlineable
    public init<P>(image: Image<P>, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default) {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = colorSpace
        self.pixels = image.colorSpace.convert(image.pixels, to: self.colorSpace, intent: intent)
    }
}

extension Image : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "Image<\(Pixel.self)>(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution))"
    }
}

extension Image : CustomPlaygroundQuickLookable {
    
    @_inlineable
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return PlaygroundQuickLook.text(description)
    }
}

extension Image {
    
    @_inlineable
    public subscript(x: Int, y: Int) -> Color<Pixel.Model> {
        get {
            precondition(0..<width ~= x && 0..<height ~= y)
            return Color(colorSpace: colorSpace, color: pixels[width * y + x])
        }
        set {
            precondition(0..<width ~= x && 0..<height ~= y)
            pixels[width * y + x] = Pixel(newValue.convert(to: colorSpace))
        }
    }
}

extension Image {
    
    @_inlineable
    public func linearTone() -> Image {
        return Image(width: height, height: width, resolution: resolution, pixels: colorSpace.convertToLinear(pixels), colorSpace: colorSpace.linearTone)
    }
}

extension Image {
    
    @_inlineable
    public var isOpaque: Bool {
        return pixels.all { $0.isOpaque }
    }
}

extension Image {
    
    @_inlineable
    public func transposed() -> Image {
        if pixels.count == 0 {
            return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: [], colorSpace: colorSpace)
        }
        var copy = pixels
        pixels.withUnsafeBufferPointer { source in copy.withUnsafeMutableBufferPointer { destination in Transpose(height, width, source.baseAddress!, 1, destination.baseAddress!, 1) } }
        return Image(width: height, height: width, resolution: Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit), pixels: copy, colorSpace: colorSpace)
    }
    
    @_inlineable
    public func verticalFlipped() -> Image {
        
        var pixels = self.pixels
        
        if pixels.count != 0 {
            
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
        }
        
        return Image(width: width, height: height, resolution: resolution, pixels: pixels, colorSpace: colorSpace)
    }
    
    @_inlineable
    public func horizontalFlipped() -> Image {
        
        var pixels = self.pixels
        
        if pixels.count != 0 {
            
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
        }
        
        return Image(width: width, height: height, resolution: resolution, pixels: pixels, colorSpace: colorSpace)
    }
}

extension Image {
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @_inlineable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBytes(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBytes(body)
    }
}

