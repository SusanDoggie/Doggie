//
//  ImageConvolution.swift
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

@inlinable
@inline(__always)
func _Radix2FiniteImpulseFilter<T: BinaryFloatingPoint>(_ level: Int, _ row: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ signal_row_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ kernel_row_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ out_row_stride: Int) where T : FloatingMathProtocol {
    var signal = signal
    var kreal = kreal
    var kimag = kimag
    var output = output
    for _ in 0..<row {
        Radix2FiniteImpulseFilter(level, signal, signal_stride, signal_count, kreal, kimag, kernel_stride, output, out_stride)
        signal += signal_row_stride
        kreal += kernel_row_stride
        kimag += kernel_row_stride
        output += out_row_stride
    }
}

@inlinable
@inline(__always)
func _TextureConvolution<Pixel, T: BinaryFloatingPoint>(_ texture: Texture<Pixel>, _ filter: [T], _ filter_width: Int, _ filter_height: Int) -> Texture<Pixel> where T : FloatingMathProtocol {
    
    precondition(filter_width > 0, "nonpositive filter_width is not allowed.")
    precondition(filter_height > 0, "nonpositive filter_height is not allowed.")
    precondition(filter_width * filter_height == filter.count, "mismatch filter count.")
    
    let width = texture.width
    let height = texture.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_width = width + filter_width - 1
    let n_height = height + filter_height - 1
    
    guard width > 0 && height > 0 else { return texture }
    
    var result = Texture<Pixel>(width: n_width, height: n_height, resamplingAlgorithm: texture.resamplingAlgorithm, fileBacked: texture.fileBacked)
    
    texture.withUnsafeBytes {
        
        guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
        
        result.withUnsafeMutableBytes {
            
            guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            for _ in 0..<numberOfComponents {
                
                DiscreteConvolve2D((width, height), source, numberOfComponents, (filter_width, filter_height), filter, 1, output, numberOfComponents)
                
                source += 1
                output += 1
            }
        }
    }
    
    return result
}

@inlinable
@inline(__always)
func _TextureConvolution<Pixel, T: BinaryFloatingPoint>(_ texture: Texture<Pixel>, _ horizontal_filter: [T], _ vertical_filter: [T]) -> Texture<Pixel> where T : FloatingMathProtocol {
    
    let width = texture.width
    let height = texture.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_width = width + horizontal_filter.count - 1
    let n_height = height + vertical_filter.count - 1
    
    guard width > 0 && height > 0 else { return texture }
    
    let length1 = Radix2CircularConvolveLength(width, horizontal_filter.count)
    let length2 = Radix2CircularConvolveLength(height, vertical_filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length1 + length2 + length1 * height, fileBacked: texture.fileBacked)
    var result = MappedBuffer<Pixel>(repeating: Pixel(), count: n_width * length2, fileBacked: texture.fileBacked)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        texture.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level1 = log2(length1)
                let level2 = log2(length2)
                
                let _kreal1 = buffer
                let _kimag1 = buffer + 1
                let _kreal2 = buffer + length1
                let _kimag2 = _kreal2 + 1
                let _temp = _kreal2 + length2
                
                HalfRadix2CooleyTukey(level1, horizontal_filter, 1, horizontal_filter.count, _kreal1, _kimag1, 2)
                
                let _length1 = 1 / T(length1)
                vec_op(length1 << 1, _kreal1, 1, _kreal1, 1) { $0 * _length1 }
                
                HalfRadix2CooleyTukey(level2, vertical_filter, 1, vertical_filter.count, _kreal2, _kimag2, 2)
                
                let _length2 = 1 / T(length2)
                vec_op(length2 << 1, _kreal2, 1, _kreal2, 1) { $0 * _length2 }
                
                for _ in 0..<numberOfComponents {
                    
                    _Radix2FiniteImpulseFilter(level1, height, source, numberOfComponents, numberOfComponents * width, width, _kreal1, _kimag1, 2, 0, _temp, 1, length1)
                    _Radix2FiniteImpulseFilter(level2, n_width, _temp, length1, 1, height, _kreal2, _kimag2, 2, 0, output, numberOfComponents * n_width, numberOfComponents)
                    
                    source += 1
                    output += 1
                }
            }
        }
    }
    
    result.removeLast(result.count - n_width * n_height)
    
    return Texture(width: n_width, height: n_height, pixels: result, resamplingAlgorithm: texture.resamplingAlgorithm)
}

@inlinable
@inline(__always)
func _TextureConvolutionHorizontal<Pixel, T: BinaryFloatingPoint>(_ texture: Texture<Pixel>, _ filter: [T]) -> Texture<Pixel> where T : FloatingMathProtocol {
    
    let width = texture.width
    let height = texture.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_width = width + filter.count - 1
    
    guard width > 0 && height > 0 else { return texture }
    
    let length = Radix2CircularConvolveLength(width, filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length + length * height, fileBacked: texture.fileBacked)
    var result = Texture<Pixel>(width: n_width, height: height, resamplingAlgorithm: texture.resamplingAlgorithm, fileBacked: texture.fileBacked)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        texture.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level = log2(length)
                
                let _kreal = buffer
                let _kimag = buffer + 1
                let _temp = buffer + length
                
                HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                
                let _length = 1 / T(length)
                vec_op(length << 1, buffer, 1, buffer, 1) { $0 * _length }
                
                for _ in 0..<numberOfComponents {
                    
                    _Radix2FiniteImpulseFilter(level, height, source, numberOfComponents, numberOfComponents * width, width, _kreal, _kimag, 2, 0, _temp, 1, length)
                    
                    do {
                        var _temp = _temp
                        var output = output
                        let out_stride = numberOfComponents * n_width
                        for _ in 0..<height {
                            Move(n_width, _temp, 1, output, numberOfComponents)
                            _temp += length
                            output += out_stride
                        }
                    }
                    
                    source += 1
                    output += 1
                }
            }
        }
    }
    
    return result
}

@inlinable
@inline(__always)
func _TextureConvolutionVertical<Pixel, T: BinaryFloatingPoint>(_ texture: Texture<Pixel>, _ filter: [T]) -> Texture<Pixel> where T : FloatingMathProtocol {
    
    let width = texture.width
    let height = texture.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_height = height + filter.count - 1
    
    guard width > 0 && height > 0 else { return texture }
    
    let length = Radix2CircularConvolveLength(height, filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length, fileBacked: texture.fileBacked)
    var result = MappedBuffer<Pixel>(repeating: Pixel(), count: width * length, fileBacked: texture.fileBacked)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        texture.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level = log2(length)
                
                let _kreal = buffer
                let _kimag = buffer + 1
                
                HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                
                let _length = 1 / T(length)
                vec_op(length << 1, buffer, 1, buffer, 1) { $0 * _length }
                
                for _ in 0..<numberOfComponents {
                    
                    _Radix2FiniteImpulseFilter(level, width, source, numberOfComponents * width, numberOfComponents, height, _kreal, _kimag, 2, 0, output, numberOfComponents * width, numberOfComponents)
                    
                    source += 1
                    output += 1
                }
            }
        }
    }
    
    result.removeLast(result.count - width * n_height)
    
    return Texture(width: width, height: n_height, pixels: result, resamplingAlgorithm: texture.resamplingAlgorithm)
}

@inlinable
@inline(__always)
public func TextureConvolution<Model>(_ texture: Texture<ColorPixel<Model>>, _ filter: [Double], _ filter_width: Int, _ filter_height: Int) -> Texture<ColorPixel<Model>> {
    return _TextureConvolution(texture, filter, filter_width, filter_height)
}
@inlinable
@inline(__always)
public func TextureConvolution<Model>(_ texture: Texture<FloatColorPixel<Model>>, _ filter: [Float], _ filter_width: Int, _ filter_height: Int) -> Texture<FloatColorPixel<Model>> {
    return _TextureConvolution(texture, filter, filter_width, filter_height)
}
@inlinable
@inline(__always)
public func TextureConvolution<Model>(_ texture: Texture<ColorPixel<Model>>, horizontal horizontal_filter: [Double], vertical vertical_filter: [Double]) -> Texture<ColorPixel<Model>> {
    return _TextureConvolution(texture, horizontal_filter, vertical_filter)
}
@inlinable
@inline(__always)
public func TextureConvolution<Model>(_ texture: Texture<FloatColorPixel<Model>>, horizontal horizontal_filter: [Float], vertical vertical_filter: [Float]) -> Texture<FloatColorPixel<Model>> {
    return _TextureConvolution(texture, horizontal_filter, vertical_filter)
}
@inlinable
@inline(__always)
public func TextureConvolutionHorizontal<Model>(_ texture: Texture<ColorPixel<Model>>, _ filter: [Double]) -> Texture<ColorPixel<Model>> {
    return _TextureConvolutionHorizontal(texture, filter)
}
@inlinable
@inline(__always)
public func TextureConvolutionHorizontal<Model>(_ texture: Texture<FloatColorPixel<Model>>, _ filter: [Float]) -> Texture<FloatColorPixel<Model>> {
    return _TextureConvolutionHorizontal(texture, filter)
}
@inlinable
@inline(__always)
public func TextureConvolutionVertical<Model>(_ texture: Texture<ColorPixel<Model>>, _ filter: [Double]) -> Texture<ColorPixel<Model>> {
    return _TextureConvolutionVertical(texture, filter)
}
@inlinable
@inline(__always)
public func TextureConvolutionVertical<Model>(_ texture: Texture<FloatColorPixel<Model>>, _ filter: [Float]) -> Texture<FloatColorPixel<Model>> {
    return _TextureConvolutionVertical(texture, filter)
}

@inlinable
@inline(__always)
public func ImageConvolution<Model>(_ image: Image<ColorPixel<Model>>, _ filter: [Double], _ filter_width: Int, _ filter_height: Int) -> Image<ColorPixel<Model>> {
    return Image(texture: TextureConvolution(Texture(image: image), filter, filter_width, filter_height), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolution<Model>(_ image: Image<FloatColorPixel<Model>>, _ filter: [Float], _ filter_width: Int, _ filter_height: Int) -> Image<FloatColorPixel<Model>> {
    return Image(texture: TextureConvolution(Texture(image: image), filter, filter_width, filter_height), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolution<Model>(_ image: Image<ColorPixel<Model>>, horizontal horizontal_filter: [Double], vertical vertical_filter: [Double]) -> Image<ColorPixel<Model>> {
    return Image(texture: TextureConvolution(Texture(image: image), horizontal: horizontal_filter, vertical: vertical_filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolution<Model>(_ image: Image<FloatColorPixel<Model>>, horizontal horizontal_filter: [Float], vertical vertical_filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return Image(texture: TextureConvolution(Texture(image: image), horizontal: horizontal_filter, vertical: vertical_filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolutionHorizontal<Model>(_ image: Image<ColorPixel<Model>>, _ filter: [Double]) -> Image<ColorPixel<Model>> {
    return Image(texture: TextureConvolutionHorizontal(Texture(image: image), filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolutionHorizontal<Model>(_ image: Image<FloatColorPixel<Model>>, _ filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return Image(texture: TextureConvolutionHorizontal(Texture(image: image), filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolutionVertical<Model>(_ image: Image<ColorPixel<Model>>, _ filter: [Double]) -> Image<ColorPixel<Model>> {
    return Image(texture: TextureConvolutionVertical(Texture(image: image), filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
@inlinable
@inline(__always)
public func ImageConvolutionVertical<Model>(_ image: Image<FloatColorPixel<Model>>, _ filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return Image(texture: TextureConvolutionVertical(Texture(image: image), filter), resolution: image.resolution, colorSpace: image.colorSpace)
}
