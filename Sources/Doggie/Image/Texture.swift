//
//  Texture.swift
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

@_fixed_layout
public struct Texture<RawPixel: ColorPixelProtocol>: TextureProtocol {
    
    public typealias Pixel = Float64ColorPixel<RawPixel.Model>
    
    public let width: Int
    
    public let height: Int
    
    public private(set) var pixels: MappedBuffer<RawPixel>
    
    public var resamplingAlgorithm: ResamplingAlgorithm
    
    public var horizontalWrappingMode: WrappingMode = .none
    public var verticalWrappingMode: WrappingMode = .none
    
    @inlinable
    @inline(__always)
    init(width: Int, height: Int, pixels: MappedBuffer<RawPixel>, resamplingAlgorithm: ResamplingAlgorithm) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self.pixels = pixels
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    @inline(__always)
    public init(width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm = .default, pixel: RawPixel = RawPixel(), fileBacked: Bool = false) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.pixels = MappedBuffer(repeating: pixel, count: width * height, fileBacked: fileBacked)
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    @inline(__always)
    public init<P>(texture: Texture<P>) where P.Model == RawPixel.Model {
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self.pixels = texture.pixels as? MappedBuffer<RawPixel> ?? texture.pixels.map(RawPixel.init)
    }
}

extension Texture {
    
    @inlinable
    @inline(__always)
    public init(image: Image<RawPixel>, resamplingAlgorithm: ResamplingAlgorithm = .default) {
        self.init(width: image.width, height: image.height, pixels: image.pixels, resamplingAlgorithm: resamplingAlgorithm)
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    public init(texture: Texture<Pixel>, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: texture.width, height: texture.height, resolution: resolution, pixels: texture.pixels, colorSpace: colorSpace)
    }
}

extension Texture : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "Texture<\(RawPixel.self)>(width: \(width), height: \(height))"
    }
}

extension Texture {
    
    @inlinable
    public var numberOfComponents: Int {
        return Pixel.numberOfComponents
    }
}

extension Texture {
    
    @inlinable
    public var fileBacked: Bool {
        get {
            return pixels.fileBacked
        }
        set {
            pixels.fileBacked = newValue
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
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<RawPixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<RawPixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    @inline(__always)
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBytes(body)
    }
    
    @inlinable
    @inline(__always)
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBytes(body)
    }
}

extension Texture: _TextureProtocolImplement {
    
}

extension Texture: _ResamplingImplement {
    
    @inlinable
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> Float64ColorPixel<RawPixel.Model> {
        
        guard width != 0 && height != 0 else { return Float64ColorPixel() }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? Float64ColorPixel(pixel) : Float64ColorPixel(color: pixel.color, opacity: 0)
    }
}

