//
//  StencilTexture.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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
public struct StencilTexture<T: BinaryFloatingPoint>: TextureProtocol where T: ScalarProtocol, T.Scalar: FloatingMathProtocol {
    
    public typealias RawPixel = T
    
    public typealias Pixel = T
    
    public let width: Int
    
    public let height: Int
    
    @usableFromInline
    var _pixels: MappedBuffer<T>
    
    @inlinable
    @inline(__always)
    public var pixels: MappedBuffer<T> {
        return _pixels
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm
    
    public var horizontalWrappingMode: WrappingMode = .none
    public var verticalWrappingMode: WrappingMode = .none
    
    @inlinable
    @inline(__always)
    init(width: Int, height: Int, pixels: MappedBuffer<T>, resamplingAlgorithm: ResamplingAlgorithm) {
        precondition(_isPOD(T.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self._pixels = pixels
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm = .default, pixel: T = 0, fileBacked: Bool = false) {
        precondition(_isPOD(T.self), "invalid pixel type.")
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self._pixels = MappedBuffer(repeating: pixel, count: width * height, fileBacked: fileBacked)
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    @inline(__always)
    public init<P>(texture: StencilTexture<P>) {
        precondition(_isPOD(T.self), "invalid pixel type.")
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self._pixels = texture.pixels as? MappedBuffer<T> ?? texture.pixels.map(T.init)
    }
    
    @inlinable
    @inline(__always)
    public init<P>(texture: Texture<P>) {
        precondition(_isPOD(T.self), "invalid pixel type.")
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self._pixels = texture.pixels.map { T($0.opacity) }
    }
}

extension StencilTexture {
    
    @inlinable
    @inline(__always)
    public init<P>(image: Image<P>, resamplingAlgorithm: ResamplingAlgorithm = .default) {
        self.init(width: image.width, height: image.height, pixels: image.pixels.map { T($0.opacity) }, resamplingAlgorithm: resamplingAlgorithm)
    }
}

extension Image where Pixel : ScalarMultiplicative, Pixel.Scalar : BinaryFloatingPoint, Pixel.Scalar : FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    public init(texture: StencilTexture<Pixel.Scalar>, resolution: Resolution = .default, colorSpace: ColorSpace<Pixel.Model>, background: Pixel, foreground: Pixel) {
        self.init(width: texture.width, height: texture.height, resolution: resolution, pixels: texture.pixels.map { LinearInterpolate($0, background, foreground) }, colorSpace: colorSpace)
    }
}

extension StencilTexture {
    
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
    public static func ==(lhs: StencilTexture, rhs: StencilTexture) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.resamplingAlgorithm == rhs.resamplingAlgorithm && lhs.horizontalWrappingMode == rhs.horizontalWrappingMode && lhs.verticalWrappingMode == rhs.verticalWrappingMode && lhs.pixels == rhs.pixels
    }
    
    @inlinable
    @inline(__always)
    public func isStorageEqual(_ other: StencilTexture) -> Bool {
        return self.width == other.width && self.height == other.height && self.resamplingAlgorithm == other.resamplingAlgorithm && self.horizontalWrappingMode == other.horizontalWrappingMode && self.verticalWrappingMode == other.verticalWrappingMode && self.pixels.isStorageEqual(other.pixels)
    }
}

extension StencilTexture : CustomStringConvertible {
    
    @inlinable
    @inline(__always)
    public var description: String {
        return "StencilTexture(width: \(width), height: \(height))"
    }
}

extension StencilTexture {
    
    @inlinable
    @inline(__always)
    public var numberOfComponents: Int {
        return 1
    }
}

extension StencilTexture {
    
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

extension StencilTexture {
    
    @inlinable
    @inline(__always)
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        
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

extension StencilTexture: _TextureProtocolImplement {
    
}

extension StencilTexture: _ResamplingImplement {
    
    @inlinable
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> T {
        
        guard width != 0 && height != 0 else { return 0 }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? pixel : 0
    }
}

