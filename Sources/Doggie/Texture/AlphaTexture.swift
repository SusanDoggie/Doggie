//
//  AlphaTexture.swift
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

public struct AlphaTexture: TextureProtocol {
    
    public typealias Pixel = Double
    
    public typealias SourcePixel = Double
    
    public let width: Int
    
    public let height: Int
    
    public private(set) var pixels: MappedBuffer<Double>
    
    public var resamplingAlgorithm: ResamplingAlgorithm
    
    public var horizontalWrappingMode: WrappingMode = .none
    public var verticalWrappingMode: WrappingMode = .none
    
    @inlinable
    init(width: Int, height: Int, pixels: MappedBuffer<Double>, resamplingAlgorithm: ResamplingAlgorithm) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        precondition(width * height == pixels.count, "mismatch pixels count.")
        self.width = width
        self.height = height
        self.pixels = pixels
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    public init(width: Int, height: Int, resamplingAlgorithm: ResamplingAlgorithm = .default, pixel: Double = 0, option: MappedBufferOption = .default) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.pixels = MappedBuffer(repeating: pixel, count: width * height, option: option)
        self.resamplingAlgorithm = resamplingAlgorithm
    }
    
    @inlinable
    public init<P>(texture: Texture<P>) {
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self.pixels = texture.pixels.map { $0.opacity }
    }
    
    @inlinable
    public init<P>(texture: Texture<P>, option: MappedBufferOption) {
        self.width = texture.width
        self.height = texture.height
        self.resamplingAlgorithm = texture.resamplingAlgorithm
        self.horizontalWrappingMode = texture.horizontalWrappingMode
        self.verticalWrappingMode = texture.verticalWrappingMode
        self.pixels = texture.pixels.map(option: option) { $0.opacity }
    }
}

extension AlphaTexture {
    
    @inlinable
    public init<Pixel>(image: Image<Pixel>, resamplingAlgorithm: ResamplingAlgorithm = .default) {
        self.init(width: image.width, height: image.height, pixels: image.pixels.map { $0.opacity }, resamplingAlgorithm: resamplingAlgorithm)
    }
    
    @inlinable
    public init<Pixel>(image: Image<Pixel>, resamplingAlgorithm: ResamplingAlgorithm = .default, option: MappedBufferOption) {
        self.init(width: image.width, height: image.height, pixels: image.pixels.map(option: option) { $0.opacity }, resamplingAlgorithm: resamplingAlgorithm)
    }
}

extension AlphaTexture : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "AlphaTexture(width: \(width), height: \(height))"
    }
}

extension AlphaTexture {
    
    @inlinable
    public func map(_ transform: (Double) throws -> Double) rethrows -> AlphaTexture {
        
        var texture = try AlphaTexture(width: height, height: width, pixels: pixels.map(transform), resamplingAlgorithm: resamplingAlgorithm)
        
        texture.horizontalWrappingMode = self.horizontalWrappingMode
        texture.verticalWrappingMode = self.verticalWrappingMode
        
        return texture
    }
}

extension AlphaTexture {
    
    @inlinable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @inlinable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBytes(body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBytes(body)
    }
}

extension AlphaTexture: _TextureProtocolImplement {
    
    @usableFromInline
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> Double {
        
        guard width != 0 && height != 0 else { return 0 }
        
        let (x_flag, _x) = horizontalWrappingMode.addressing(x, width)
        let (y_flag, _y) = verticalWrappingMode.addressing(y, height)
        
        let pixel = pixels[_y * width + _x]
        return x_flag && y_flag ? pixel : 0
    }
}
