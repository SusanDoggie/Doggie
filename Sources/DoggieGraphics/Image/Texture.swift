//
//  Texture.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
public struct Texture<RawPixel: ColorPixel>: TextureProtocol {
    
    public typealias Pixel = Float32ColorPixel<RawPixel.Model>
    
    public let width: Int
    
    public let height: Int
    
    public var resamplingAlgorithm: ResamplingAlgorithm
    
    public var horizontalWrappingMode: WrappingMode = .none
    public var verticalWrappingMode: WrappingMode = .none
    
    @usableFromInline
    var _pixels: MappedBuffer<RawPixel>
    
    @inlinable
    @inline(__always)
    public var pixels: MappedBuffer<RawPixel> {
        return _pixels
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm = .default, pixels: MappedBuffer<RawPixel>) {
        precondition(_isPOD(RawPixel.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self.resamplingAlgorithm = resamplingAlgorithm
        self._pixels = pixels
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm = .default, pixel: RawPixel = RawPixel(), fileBacked: Bool = false) {
        precondition(_isPOD(RawPixel.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.resamplingAlgorithm = resamplingAlgorithm
        self._pixels = MappedBuffer(repeating: pixel, count: width * height, fileBacked: fileBacked)
    }
    
    @inlinable
    @inline(__always)
    public init<P>(texture: Texture<P>) where P.Model == RawPixel.Model {
        precondition(_isPOD(RawPixel.self), "invalid pixel type.")
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self._pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
    }
}

extension Texture where RawPixel: _GrayColorPixel {
    
    @inlinable
    @inline(__always)
    public init<P: _GrayColorPixel>(_ texture: Texture<P>) {
        let pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
        self.init(width: texture.width, height: texture.height, resamplingAlgorithm: texture.resamplingAlgorithm, pixels: pixels)
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
    }
    
    @inlinable
    @inline(__always)
    public init<P: _GrayColorPixel>(_ texture: Texture<P>) where P.Component == RawPixel.Component {
        let pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
        self.init(width: texture.width, height: texture.height, resamplingAlgorithm: texture.resamplingAlgorithm, pixels: pixels)
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
    }
}

extension Texture where RawPixel: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    public init<P: _RGBColorPixel>(_ texture: Texture<P>) {
        let pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
        self.init(width: texture.width, height: texture.height, resamplingAlgorithm: texture.resamplingAlgorithm, pixels: pixels)
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
    }
    
    @inlinable
    @inline(__always)
    public init<P: _RGBColorPixel>(_ texture: Texture<P>) where P.Component == RawPixel.Component {
        let pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
        self.init(width: texture.width, height: texture.height, resamplingAlgorithm: texture.resamplingAlgorithm, pixels: pixels)
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public init(image: Image<RawPixel>, resamplingAlgorithm: ResamplingAlgorithm = .default) {
        self.init(width: image.width, height: image.height, resamplingAlgorithm: resamplingAlgorithm, pixels: image.pixels)
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public init(texture: Texture<Pixel>, resolution: Resolution = .default, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: texture.width, height: texture.height, resolution: resolution, colorSpace: colorSpace, pixels: texture.pixels)
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(resamplingAlgorithm)
        hasher.combine(horizontalWrappingMode)
        hasher.combine(verticalWrappingMode)
        withUnsafeBufferPointer {
            for element in $0.prefix(16) {
                hasher.combine(element)
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public static func ==(lhs: Texture, rhs: Texture) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.resamplingAlgorithm == rhs.resamplingAlgorithm && lhs.horizontalWrappingMode == rhs.horizontalWrappingMode && lhs.verticalWrappingMode == rhs.verticalWrappingMode && lhs.pixels == rhs.pixels
    }
    
    @inlinable
    @inline(__always)
    public func isStorageEqual(_ other: Texture) -> Bool {
        return self.width == other.width && self.height == other.height && self.resamplingAlgorithm == other.resamplingAlgorithm && self.horizontalWrappingMode == other.horizontalWrappingMode && self.verticalWrappingMode == other.verticalWrappingMode && self.pixels.isStorageEqual(other.pixels)
    }
}

extension Texture: CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "Texture<\(RawPixel.self)>(width: \(width), height: \(height))"
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public var numberOfComponents: Int {
        return Pixel.numberOfComponents
    }
}

extension Texture {
    
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

extension Texture {
    
    @inlinable
    @inline(__always)
    public var isOpaque: Bool {
        return pixels.allSatisfy { $0.isOpaque }
    }
    
    @inlinable
    public var visibleRect: Rect {
        
        return self.withUnsafeBufferPointer {
            
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
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public func premultiplied() -> Texture {
        return self.map { $0.premultiplied() }
    }
    
    @inlinable
    @inline(__always)
    public func unpremultiplied() -> Texture {
        return self.map { $0.unpremultiplied() }
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<RawPixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<RawPixel>) throws -> R) rethrows -> R {
        
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
        
        return try _pixels.withUnsafeMutableBytes(body)
    }
}

extension Texture: _TextureProtocolImplement {
    
}

extension Texture: _ResamplingImplement {
    
    @inlinable
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> Float32ColorPixel<RawPixel.Model> {
        
        guard width != 0 && height != 0 else { return Float32ColorPixel() }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? Float32ColorPixel(pixel) : Float32ColorPixel(color: pixel.color, opacity: 0)
    }
}

