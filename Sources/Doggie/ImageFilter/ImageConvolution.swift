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

extension _TextureProtocolImplement where RawPixel : ScalarMultiplicative, RawPixel.Scalar : BinaryFloatingPoint & FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    func _direct_convolution(_ filter: [RawPixel.Scalar], _ filter_width: Int, _ filter_height: Int) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter_width - 1
        let n_height = height + filter_height - 1
        
        guard width > 0 && height > 0 else { return self }
        
        var result = Self(width: n_width, height: n_height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        self.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                for _ in 0..<numberOfComponents {
                    
                    DirectConvolve2D((width, height), source, numberOfComponents, (filter_width, filter_height), filter, 1, output, numberOfComponents)
                    
                    source += 1
                    output += 1
                }
            }
        }
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func _direct_convolution(_ horizontal_filter: [RawPixel.Scalar], _ vertical_filter: [RawPixel.Scalar]) -> Self {
        return self._direct_convolution_horizontal(horizontal_filter)._direct_convolution_vertical(vertical_filter)
    }
    
    @inlinable
    @inline(__always)
    func _direct_convolution_horizontal(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        var result = Self(width: n_width, height: height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        self.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                for _ in 0..<numberOfComponents {
                    
                    let source_row_stride = width * numberOfComponents
                    let output_row_stride = n_width * numberOfComponents
                    
                    var _source = source
                    var _output = output
                    
                    for _ in 0..<height {
                        DirectConvolve(width, _source, numberOfComponents, filter.count, filter, 1, _output, numberOfComponents)
                        _source += source_row_stride
                        _output += output_row_stride
                    }
                    
                    source += 1
                    output += 1
                }
            }
        }
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func _direct_convolution_vertical(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_height = height + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        var result = Self(width: width, height: n_height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        self.withUnsafeBytes {
            
            guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
            
            result.withUnsafeMutableBytes {
                
                guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                let row = width * numberOfComponents
                for _ in 0..<row {
                    DirectConvolve(height, source, row, filter.count, filter, 1, output, row)
                    source += 1
                    output += 1
                }
            }
        }
        
        return result
    }
}

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

extension _TextureProtocolImplement where RawPixel : ScalarMultiplicative, RawPixel.Scalar : BinaryFloatingPoint & FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    func _cooleyTukey_convolution(_ filter: [RawPixel.Scalar], _ filter_width: Int, _ filter_height: Int) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter_width - 1
        let n_height = height + filter_height - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length1 = Radix2CircularConvolveLength(width, filter_width)
        let length2 = Radix2CircularConvolveLength(height, filter_height)
        
        var buffer = MappedBuffer<RawPixel.Scalar>(repeating: 0, count: length1 * length2 * 2, fileBacked: self.fileBacked)
        var result = Self(width: n_width, height: n_height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            let temp = buffer + length1 * length2
            
            self.withUnsafeBytes {
                
                guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                result.withUnsafeMutableBytes {
                    
                    guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                    
                    let level1 = log2(length1)
                    let level2 = log2(length2)
                    
                    for _ in 0..<numberOfComponents {
                        
                        Radix2CircularConvolve2D((level1, level2), source, numberOfComponents, (width, height), filter, 1, (filter_width, filter_height), buffer, 1, temp, 1)
                        
                        do {
                            var buffer = buffer
                            var output = output
                            let out_stride = numberOfComponents * n_width
                            for _ in 0..<n_height {
                                Move(n_width, buffer, 1, output, numberOfComponents)
                                buffer += length1
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
    func _cooleyTukey_convolution(_ horizontal_filter: [RawPixel.Scalar], _ vertical_filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + horizontal_filter.count - 1
        let n_height = height + vertical_filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length1 = Radix2CircularConvolveLength(width, horizontal_filter.count)
        let length2 = Radix2CircularConvolveLength(height, vertical_filter.count)
        
        var buffer = MappedBuffer<RawPixel.Scalar>(repeating: 0, count: length1 + length2 + length1 * height, fileBacked: self.fileBacked)
        var result = MappedBuffer<RawPixel>(repeating: RawPixel.zero, count: n_width * length2, fileBacked: self.fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            self.withUnsafeBytes {
                
                guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                result.withUnsafeMutableBytes {
                    
                    guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                    
                    let level1 = log2(length1)
                    let level2 = log2(length2)
                    
                    let _kreal1 = buffer
                    let _kimag1 = buffer + 1
                    let _kreal2 = buffer + length1
                    let _kimag2 = _kreal2 + 1
                    let _temp = _kreal2 + length2
                    
                    HalfRadix2CooleyTukey(level1, horizontal_filter, 1, horizontal_filter.count, _kreal1, _kimag1, 2)
                    
                    let _length1 = 1 / RawPixel.Scalar(length1)
                    vec_op(length1 << 1, _kreal1, 1, _kreal1, 1) { $0 * _length1 }
                    
                    HalfRadix2CooleyTukey(level2, vertical_filter, 1, vertical_filter.count, _kreal2, _kimag2, 2)
                    
                    let _length2 = 1 / RawPixel.Scalar(length2)
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
        
        return Self(width: n_width, height: n_height, pixels: result, resamplingAlgorithm: self.resamplingAlgorithm)
    }
    
    @inlinable
    @inline(__always)
    func _cooleyTukey_convolution_horizontal(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length = Radix2CircularConvolveLength(width, filter.count)
        
        var buffer = MappedBuffer<RawPixel.Scalar>(repeating: 0, count: length + length * height, fileBacked: self.fileBacked)
        var result = Self(width: n_width, height: height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            self.withUnsafeBytes {
                
                guard var source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                result.withUnsafeMutableBytes {
                    
                    guard var output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                    
                    let level = log2(length)
                    
                    let _kreal = buffer
                    let _kimag = buffer + 1
                    let _temp = buffer + length
                    
                    HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                    
                    let _length = 1 / RawPixel.Scalar(length)
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
    func _cooleyTukey_convolution_vertical(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_height = height + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length = Radix2CircularConvolveLength(height, filter.count)
        
        var buffer = MappedBuffer<RawPixel.Scalar>(repeating: 0, count: length, fileBacked: self.fileBacked)
        var result = MappedBuffer<RawPixel>(repeating: RawPixel.zero, count: width * length, fileBacked: self.fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            self.withUnsafeBytes {
                
                guard let source = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                
                result.withUnsafeMutableBytes {
                    
                    guard let output = $0.baseAddress?.assumingMemoryBound(to: RawPixel.Scalar.self) else { return }
                    
                    let level = log2(length)
                    
                    let _kreal = buffer
                    let _kimag = buffer + 1
                    
                    HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                    
                    let _length = 1 / RawPixel.Scalar(length)
                    vec_op(length << 1, buffer, 1, buffer, 1) { $0 * _length }
                    
                    let row = width * numberOfComponents
                    _Radix2FiniteImpulseFilter(level, row, source, row, 1, height, _kreal, _kimag, 2, 0, output, row, 1)
                }
            }
        }
        
        result.removeLast(result.count - width * n_height)
        
        return Self(width: width, height: n_height, pixels: result, resamplingAlgorithm: self.resamplingAlgorithm)
    }
}

extension _TextureProtocolImplement where RawPixel : ScalarMultiplicative, RawPixel.Scalar : BinaryFloatingPoint & FloatingMathProtocol {
    
    @inlinable
    @inline(__always)
    func _convolution(_ filter: [RawPixel.Scalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm) -> Self {
        
        precondition(filter_width > 0, "nonpositive filter_width is not allowed.")
        precondition(filter_height > 0, "nonpositive filter_height is not allowed.")
        precondition(filter_width * filter_height == filter.count, "mismatch filter count.")
        precondition(numberOfComponents * MemoryLayout<RawPixel.Scalar>.stride == MemoryLayout<RawPixel>.stride)
        
        var result: Self
        
        switch (filter_width, filter_height) {
        case (1, 1):
            let k = filter[0]
            result = Self(width: width, height: height, pixels: pixels.map { $0 * k }, resamplingAlgorithm: resamplingAlgorithm)
        case (1, _):
            switch algorithm {
            case .direct: result = _direct_convolution_vertical(filter)
            case .cooleyTukey: result = _cooleyTukey_convolution_vertical(filter)
            }
        case (_, 1):
            switch algorithm {
            case .direct: result = _direct_convolution_horizontal(filter)
            case .cooleyTukey: result = _cooleyTukey_convolution_horizontal(filter)
            }
        default:
            switch algorithm {
            case .direct: result = _direct_convolution(filter, filter_width, filter_height)
            case .cooleyTukey: result = _cooleyTukey_convolution(filter, filter_width, filter_height)
            }
        }
        
        result.horizontalWrappingMode = self.horizontalWrappingMode
        result.verticalWrappingMode = self.verticalWrappingMode
        
        return result
    }
    
    @inlinable
    @inline(__always)
    func _convolution(horizontal horizontal_filter: [RawPixel.Scalar], vertical vertical_filter: [RawPixel.Scalar], algorithm: ImageConvolutionAlgorithm) -> Self {
        
        precondition(horizontal_filter.count != 0, "horizontal_filter is empty.")
        precondition(vertical_filter.count != 0, "vertical_filter is empty.")
        precondition(numberOfComponents * MemoryLayout<RawPixel.Scalar>.stride == MemoryLayout<RawPixel>.stride)
        
        var result: Self
        
        switch (horizontal_filter.count, vertical_filter.count) {
        case (1, 1):
            let k = horizontal_filter[0] * vertical_filter[0]
            result = Self(width: width, height: height, pixels: pixels.map { $0 * k }, resamplingAlgorithm: resamplingAlgorithm)
        case (1, _):
            let k = horizontal_filter[0]
            switch algorithm {
            case .direct: result = _direct_convolution_vertical(vertical_filter.map { $0 * k })
            case .cooleyTukey: result = _cooleyTukey_convolution_vertical(vertical_filter.map { $0 * k })
            }
        case (_, 1):
            let k = vertical_filter[0]
            switch algorithm {
            case .direct: result = _direct_convolution_horizontal(horizontal_filter.map { $0 * k })
            case .cooleyTukey: result = _cooleyTukey_convolution_horizontal(horizontal_filter.map { $0 * k })
            }
        default:
            switch algorithm {
            case .direct: result = _direct_convolution(horizontal_filter, vertical_filter)
            case .cooleyTukey: result = _cooleyTukey_convolution(horizontal_filter, vertical_filter)
            }
        }
        
        result.horizontalWrappingMode = self.horizontalWrappingMode
        result.verticalWrappingMode = self.verticalWrappingMode
        
        return result
    }
}

public protocol _ImageConvolutionProtocol {
    
    associatedtype _ConvolutionFilterScalar : BinaryFloatingPoint
    
    func convolution(_ filter: [_ConvolutionFilterScalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm) -> Self
    
    func convolution(horizontal horizontal_filter: [_ConvolutionFilterScalar], vertical vertical_filter: [_ConvolutionFilterScalar], algorithm: ImageConvolutionAlgorithm) -> Self
}

extension StencilTexture : _ImageConvolutionProtocol {
    
    public typealias _ConvolutionFilterScalar = RawPixel.Scalar
    
    @inlinable
    @inline(__always)
    public func convolution(_ filter: [RawPixel.Scalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> StencilTexture {
        return self._convolution(filter, filter_width, filter_height, algorithm: algorithm)
    }
    
    @inlinable
    @inline(__always)
    public func convolution(horizontal horizontal_filter: [RawPixel.Scalar], vertical vertical_filter: [RawPixel.Scalar], algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> StencilTexture {
        return self._convolution(horizontal: horizontal_filter, vertical: vertical_filter, algorithm: algorithm)
    }
}

extension Texture : _ImageConvolutionProtocol where RawPixel : _FloatComponentPixel, RawPixel.Scalar : FloatingMathProtocol {
    
    public typealias _ConvolutionFilterScalar = RawPixel.Scalar
    
    @inlinable
    @inline(__always)
    public func convolution(_ filter: [RawPixel.Scalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Texture {
        return self._convolution(filter, filter_width, filter_height, algorithm: algorithm)
    }
    
    @inlinable
    @inline(__always)
    public func convolution(horizontal horizontal_filter: [RawPixel.Scalar], vertical vertical_filter: [RawPixel.Scalar], algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Texture {
        return self._convolution(horizontal: horizontal_filter, vertical: vertical_filter, algorithm: algorithm)
    }
}

extension Image : _ImageConvolutionProtocol where Pixel : _FloatComponentPixel, Pixel.Scalar : FloatingMathProtocol {
    
    public typealias _ConvolutionFilterScalar = Pixel.Scalar
    
    @inlinable
    @inline(__always)
    public func convolution(_ filter: [Pixel.Scalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image {
        return Image(texture: Texture(image: self).convolution(filter, filter_width, filter_height, algorithm: algorithm), resolution: self.resolution, colorSpace: self.colorSpace)
    }
    
    @inlinable
    @inline(__always)
    public func convolution(horizontal horizontal_filter: [Pixel.Scalar], vertical vertical_filter: [Pixel.Scalar], algorithm: ImageConvolutionAlgorithm = .cooleyTukey) -> Image {
        return Image(texture: Texture(image: self).convolution(horizontal: horizontal_filter, vertical: vertical_filter, algorithm: algorithm), resolution: self.resolution, colorSpace: self.colorSpace)
    }
}
