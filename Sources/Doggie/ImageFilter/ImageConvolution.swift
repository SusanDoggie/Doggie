//
//  ImageConvolution.swift
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

@_versioned
@_inlineable
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

@_versioned
@_inlineable
func _ImageConvolution<Pixel, T: BinaryFloatingPoint>(_ image: Image<Pixel>, _ horizontal_filter: [T], _ vertical_filter: [T]) -> Image<Pixel> where T : FloatingMathProtocol {
    
    let width = image.width
    let height = image.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_width = width + horizontal_filter.count - 1
    let n_height = height + vertical_filter.count - 1
    
    guard width > 0 && height > 0 else { return image }
    
    let length1 = FFTConvolveLength(width, horizontal_filter.count)
    let length2 = FFTConvolveLength(height, vertical_filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length1 + length2 + length1 * height + n_width * length2, option: image.option)
    var result = Image<Pixel>(width: n_width, height: n_height, resolution: image.resolution, colorSpace: image.colorSpace, option: image.option)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        image.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level1 = log2(length1)
                let level2 = log2(length2)
                
                let _kreal1 = buffer
                let _kimag1 = buffer + 1
                let _kreal2 = buffer + length1
                let _kimag2 = _kreal2 + 1
                let _temp1 = _kreal2 + length2
                let _temp2 = _temp1 + length1 * height
                
                HalfRadix2CooleyTukey(level1, horizontal_filter, 1, horizontal_filter.count, _kreal1, _kimag1, 2)
                
                var _length1 = T(length1)
                Div(length1, _kreal1, _kimag1, 2, &_length1, 0, _kreal1, _kimag1, 2)
                
                HalfRadix2CooleyTukey(level2, vertical_filter, 1, vertical_filter.count, _kreal2, _kimag2, 2)
                
                var _length2 = T(length2)
                Div(length2, _kreal2, _kimag2, 2, &_length2, 0, _kreal2, _kimag2, 2)
                
                for _ in 0..<numberOfComponents {
                    
                    _Radix2FiniteImpulseFilter(level1, height, source, numberOfComponents, numberOfComponents * width, width, _kreal1, _kimag1, 2, 0, _temp1, 1, length1)
                    _Radix2FiniteImpulseFilter(level2, n_width, _temp1, length1, 1, height, _kreal2, _kimag2, 2, 0, _temp2, 1, length2)
                    
                    do {
                        var _temp2 = _temp2
                        var output = output
                        let out_stride = numberOfComponents * n_width
                        for _ in 0..<n_height {
                            Move(n_width, _temp2, length2, output, numberOfComponents)
                            _temp2 += 1
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

@_versioned
@_inlineable
func _ImageConvolutionHorizontal<Pixel, T: BinaryFloatingPoint>(_ image: Image<Pixel>, _ filter: [T]) -> Image<Pixel> where T : FloatingMathProtocol {
    
    let width = image.width
    let height = image.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_width = width + filter.count - 1
    
    guard width > 0 && height > 0 else { return image }
    
    let length = FFTConvolveLength(width, filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length + length * height, option: image.option)
    var result = Image<Pixel>(width: n_width, height: height, resolution: image.resolution, colorSpace: image.colorSpace, option: image.option)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        image.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level = log2(length)
                
                let _kreal = buffer
                let _kimag = buffer + 1
                let _temp = buffer + length
                
                HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                
                var _length = T(length)
                Div(length, _kreal, _kimag, 2, &_length, 0, _kreal, _kimag, 2)
                
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

@_versioned
@_inlineable
func _ImageConvolutionVertical<Pixel, T: BinaryFloatingPoint>(_ image: Image<Pixel>, _ filter: [T]) -> Image<Pixel> where T : FloatingMathProtocol {
    
    let width = image.width
    let height = image.height
    let numberOfComponents = Pixel.numberOfComponents
    
    let n_height = height + filter.count - 1
    
    guard width > 0 && height > 0 else { return image }
    
    let length = FFTConvolveLength(height, filter.count)
    
    var buffer = MappedBuffer<T>(repeating: 0, count: length + length * width, option: image.option)
    var result = Image<Pixel>(width: width, height: n_height, resolution: image.resolution, colorSpace: image.colorSpace, option: image.option)
    
    buffer.withUnsafeMutableBufferPointer {
        
        guard let buffer = $0.baseAddress else { return }
        
        image.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: T.self) else { return }
                
                let level = log2(length)
                
                let _kreal = buffer
                let _kimag = buffer + 1
                let _temp = buffer + length
                
                HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                
                var _length = T(length)
                Div(length, _kreal, _kimag, 2, &_length, 0, _kreal, _kimag, 2)
                
                for _ in 0..<numberOfComponents {
                    
                    _Radix2FiniteImpulseFilter(level, width, source, numberOfComponents * width, numberOfComponents, height, _kreal, _kimag, 2, 0, _temp, 1, length)
                    
                    do {
                        var _temp = _temp
                        var output = output
                        let out_stride = numberOfComponents * width
                        for _ in 0..<n_height {
                            Move(width, _temp, length, output, numberOfComponents)
                            _temp += 1
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

@_inlineable
public func ImageConvolution<Model>(_ image: Image<ColorPixel<Model>>, horizontal horizontal_filter: [Double], vertical vertical_filter: [Double]) -> Image<ColorPixel<Model>> {
    return _ImageConvolution(image, horizontal_filter, vertical_filter)
}
@_inlineable
public func ImageConvolution<Model>(_ image: Image<FloatColorPixel<Model>>, horizontal horizontal_filter: [Float], vertical vertical_filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return _ImageConvolution(image, horizontal_filter, vertical_filter)
}
@_inlineable
public func ImageConvolutionHorizontal<Model>(_ image: Image<ColorPixel<Model>>, _ filter: [Double]) -> Image<ColorPixel<Model>> {
    return _ImageConvolutionHorizontal(image, filter)
}
@_inlineable
public func ImageConvolutionHorizontal<Model>(_ image: Image<FloatColorPixel<Model>>, _ filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return _ImageConvolutionHorizontal(image, filter)
}
@_inlineable
public func ImageConvolutionVertical<Model>(_ image: Image<ColorPixel<Model>>, _ filter: [Double]) -> Image<ColorPixel<Model>> {
    return _ImageConvolutionVertical(image, filter)
}
@_inlineable
public func ImageConvolutionVertical<Model>(_ image: Image<FloatColorPixel<Model>>, _ filter: [Float]) -> Image<FloatColorPixel<Model>> {
    return _ImageConvolutionVertical(image, filter)
}
