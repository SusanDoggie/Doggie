//
//  ImageConvolution.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

extension _TextureProtocolImplement where RawPixel: ScalarMultiplicative, RawPixel.Scalar: BinaryFloatingPoint & FloatingMathProtocol {
    
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
        
        self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
            
            guard var source = $0.baseAddress else { return }
            
            result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var output = $0.baseAddress else { return }
                
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
    func _direct_convolution_horizontal(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        var result = Self(width: n_width, height: height, resamplingAlgorithm: self.resamplingAlgorithm, pixel: RawPixel.zero, fileBacked: self.fileBacked)
        
        self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
            
            guard var source = $0.baseAddress else { return }
            
            result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var output = $0.baseAddress else { return }
                
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
        
        self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
            
            guard var source = $0.baseAddress else { return }
            
            result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var output = $0.baseAddress else { return }
                
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

extension _TextureProtocolImplement where RawPixel: ScalarMultiplicative, RawPixel.Scalar: BinaryFloatingPoint & FloatingMathProtocol {
    
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
            
            self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var source = $0.baseAddress else { return }
                
                result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                    
                    guard var output = $0.baseAddress else { return }
                    
                    let log2n1 = log2(length1)
                    let log2n2 = log2(length2)
                    
                    for _ in 0..<numberOfComponents {
                        
                        Radix2CircularConvolve2D((log2n1, log2n2), source, numberOfComponents, (width, height), filter, 1, (filter_width, filter_height), buffer, 1, temp, 1)
                        
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
    func _cooleyTukey_convolution_horizontal(_ filter: [RawPixel.Scalar]) -> Self {
        
        let width = self.width
        let height = self.height
        let numberOfComponents = self.numberOfComponents
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return self }
        
        let length = Radix2CircularConvolveLength(width, filter.count)
        
        var buffer = MappedBuffer<RawPixel.Scalar>(repeating: 0, count: length, fileBacked: self.fileBacked)
        var result = MappedBuffer<RawPixel>(repeating: RawPixel.zero, count: n_width * (height - 1) + length, fileBacked: self.fileBacked)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var source = $0.baseAddress else { return }
                
                result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                    
                    guard var output = $0.baseAddress else { return }
                    
                    let log2n = log2(length)
                    
                    let _kreal = buffer
                    let _kimag = buffer + 1
                    let source_row_stride = numberOfComponents * width
                    let output_row_stride = numberOfComponents * n_width
                    
                    HalfRadix2CooleyTukey(log2n, filter, 1, filter.count, _kreal, _kimag, 2)
                    
                    for _ in 0..<numberOfComponents {
                        
                        var _source = source
                        var _output = output
                        
                        for _ in 0..<height {
                            Radix2FiniteImpulseFilter(log2n, _source, numberOfComponents, width, _kreal, _kimag, 2, _output, numberOfComponents)
                            _source += source_row_stride
                            _output += output_row_stride
                        }
                        
                        source += 1
                        output += 1
                    }
                }
            }
        }
        
        result.removeLast(result.count - n_width * height)
        
        return Self(width: n_width, height: height, resamplingAlgorithm: self.resamplingAlgorithm, pixels: result)
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
            
            self.withUnsafeTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                
                guard var source = $0.baseAddress else { return }
                
                result.withUnsafeMutableTypePunnedBufferPointer(to: RawPixel.Scalar.self) {
                    
                    guard var output = $0.baseAddress else { return }
                    
                    let log2n = log2(length)
                    
                    let _kreal = buffer
                    let _kimag = buffer + 1
                    
                    HalfRadix2CooleyTukey(log2n, filter, 1, filter.count, _kreal, _kimag, 2)
                    
                    let row = width * numberOfComponents
                    for _ in 0..<row {
                        Radix2FiniteImpulseFilter(log2n, source, row, height, _kreal, _kimag, 2, output, row)
                        source += 1
                        output += 1
                    }
                }
            }
        }
        
        result.removeLast(result.count - width * n_height)
        
        return Self(width: width, height: n_height, resamplingAlgorithm: self.resamplingAlgorithm, pixels: result)
    }
}

extension _TextureProtocolImplement where RawPixel: ScalarMultiplicative, RawPixel.Scalar: BinaryFloatingPoint & FloatingMathProtocol {
    
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
            result = Self(width: width, height: height, resamplingAlgorithm: resamplingAlgorithm, pixels: k == 1 ? pixels : pixels.map { $0 * k })
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
        
        precondition(!horizontal_filter.isEmpty, "horizontal_filter is empty.")
        precondition(!vertical_filter.isEmpty, "vertical_filter is empty.")
        precondition(numberOfComponents * MemoryLayout<RawPixel.Scalar>.stride == MemoryLayout<RawPixel>.stride)
        
        var result: Self
        
        switch (horizontal_filter.count, vertical_filter.count) {
        case (1, 1):
            let k = horizontal_filter[0] * vertical_filter[0]
            result = Self(width: width, height: height, resamplingAlgorithm: resamplingAlgorithm, pixels: k == 1 ? pixels : pixels.map { $0 * k })
        case (1, _):
            let k = horizontal_filter[0]
            switch algorithm {
            case .direct: result = _direct_convolution_vertical(k == 1 ? vertical_filter : vertical_filter.map { $0 * k })
            case .cooleyTukey: result = _cooleyTukey_convolution_vertical(k == 1 ? vertical_filter : vertical_filter.map { $0 * k })
            }
        case (_, 1):
            let k = vertical_filter[0]
            switch algorithm {
            case .direct: result = _direct_convolution_horizontal(k == 1 ? horizontal_filter : horizontal_filter.map { $0 * k })
            case .cooleyTukey: result = _cooleyTukey_convolution_horizontal(k == 1 ? horizontal_filter : horizontal_filter.map { $0 * k })
            }
        default:
            switch algorithm {
            case .direct: result = _direct_convolution_horizontal(horizontal_filter)._direct_convolution_vertical(vertical_filter)
            case .cooleyTukey: result = _cooleyTukey_convolution_horizontal(horizontal_filter)._cooleyTukey_convolution_vertical(vertical_filter)
            }
        }
        
        result.horizontalWrappingMode = self.horizontalWrappingMode
        result.verticalWrappingMode = self.verticalWrappingMode
        
        return result
    }
}

public protocol _ImageConvolutionProtocol {
    
    associatedtype _ConvolutionFilterScalar: BinaryFloatingPoint
    
    func convolution(_ filter: [_ConvolutionFilterScalar], _ filter_width: Int, _ filter_height: Int, algorithm: ImageConvolutionAlgorithm) -> Self
    
    func convolution(horizontal horizontal_filter: [_ConvolutionFilterScalar], vertical vertical_filter: [_ConvolutionFilterScalar], algorithm: ImageConvolutionAlgorithm) -> Self
}

extension StencilTexture: _ImageConvolutionProtocol {
    
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

extension Texture: _ImageConvolutionProtocol where RawPixel: _FloatComponentPixel, RawPixel.Scalar: FloatingMathProtocol {
    
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

extension Image: _ImageConvolutionProtocol where Pixel: _FloatComponentPixel, Pixel.Scalar: FloatingMathProtocol {
    
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
