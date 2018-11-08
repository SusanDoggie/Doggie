//
//  TextureProtocol.swift
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

public enum WrappingMode {
    
    case none
    case clamp
    case `repeat`
    case mirror
}

public protocol TextureProtocol: RawPixelProtocol {
    
    associatedtype Pixel : ScalarMultiplicative where Pixel.Scalar: BinaryFloatingPoint & FloatingMathProtocol
    
    var resamplingAlgorithm: ResamplingAlgorithm { get set }
    
    var horizontalWrappingMode: WrappingMode { get set }
    
    var verticalWrappingMode: WrappingMode { get set }
    
    func map<P>(_ transform: (RawPixel) throws -> P) rethrows -> Texture<P>
    
    func map<P>(_ transform: (RawPixel) throws -> P) rethrows -> StencilTexture<P>
    
    func pixel(_ point: Point) -> Pixel
}

@usableFromInline
protocol _TextureProtocolImplement: TextureProtocol {
    
    init(width: Int, height: Int, pixels: MappedBuffer<RawPixel>, resamplingAlgorithm: ResamplingAlgorithm)
}

extension _TextureProtocolImplement {
    
    @inlinable
    @inline(__always)
    public func map<P>(_ transform: (RawPixel) throws -> P) rethrows -> Texture<P> {
        
        var texture = try Texture<P>(width: width, height: height, pixels: pixels.map(transform), resamplingAlgorithm: resamplingAlgorithm)
        
        texture.horizontalWrappingMode = self.horizontalWrappingMode
        texture.verticalWrappingMode = self.verticalWrappingMode
        
        return texture
    }
    
    @inlinable
    @inline(__always)
    public func map<P>(_ transform: (RawPixel) throws -> P) rethrows -> StencilTexture<P> {
        
        var texture = try StencilTexture<P>(width: width, height: height, pixels: pixels.map(transform), resamplingAlgorithm: resamplingAlgorithm)
        
        texture.horizontalWrappingMode = self.horizontalWrappingMode
        texture.verticalWrappingMode = self.verticalWrappingMode
        
        return texture
    }
}

extension _TextureProtocolImplement {
    
    @inlinable
    @inline(__always)
    public func transposed() -> Self {
        
        if pixels.count == 0 {
            
            var texture = Self(width: height, height: width, pixels: [], resamplingAlgorithm: resamplingAlgorithm)
            
            texture.horizontalWrappingMode = self.horizontalWrappingMode
            texture.verticalWrappingMode = self.verticalWrappingMode
            
            return texture
        }
        
        var copy = pixels
        pixels.withUnsafeBufferPointer { source in copy.withUnsafeMutableBufferPointer { destination in Transpose(height, width, source.baseAddress!, 1, destination.baseAddress!, 1) } }
        
        var texture = Self(width: height, height: width, pixels: copy, resamplingAlgorithm: resamplingAlgorithm)
        
        texture.horizontalWrappingMode = self.horizontalWrappingMode
        texture.verticalWrappingMode = self.verticalWrappingMode
        
        return texture
    }
}

extension WrappingMode {
    
    @inlinable
    @inline(__always)
    func addressing(_ x: Int, _ upperbound: Int) -> (Bool, Int) {
        switch self {
        case .none: return 0..<upperbound ~= x ? (true, x) : (false, x.clamped(to: 0..<upperbound))
        case .clamp: return (true, x.clamped(to: 0..<upperbound))
        case .repeat:
            let _x = x % upperbound
            return _x < 0 ? (true, _x + upperbound) : (true, _x)
        case .mirror:
            let ax = abs(x)
            let _x = ax % upperbound
            return (ax / upperbound) & 1 == 1 ? (true, upperbound - _x - 1) : (true, _x)
        }
    }
}
