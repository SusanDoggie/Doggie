//
//  DrawShadow.swift
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

import Foundation

@_versioned
@_fixed_layout
struct ShadowTexture {
    
    @_versioned
    let width: Int
    
    @_versioned
    let height: Int
    
    @_versioned
    var pixels: MappedBuffer<Double>
    
    @_versioned
    @_inlineable
    init(width: Int, height: Int, option: MappedBufferOption) {
        self.width = width
        self.height = height
        self.pixels = MappedBuffer(repeating: 0, count: width * height, option: option)
    }
    
    @_versioned
    @_inlineable
    init(width: Int, height: Int, pixels: MappedBuffer<Double>) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }
}

extension ShadowTexture {
    
    @_versioned
    @_inlineable
    func pixel(_ point: Point) -> Double {
        return sampling2(point: point, sampler: LinearInterpolate)
    }
}

extension ShadowTexture {
    
    @_versioned
    @inline(__always)
    func read_source(_ x: Int, _ y: Int) -> Double {
        
        let x_range = 0..<width
        let y_range = 0..<height
        
        return x_range ~= x && y_range ~= y ? pixels[y * width + x] : 0
        
    }
    
    @_versioned
    @inline(__always)
    func sampling2(point: Point, sampler: (Double, Double, Double) -> Double) -> Double {
        
        let _x1 = Int(point.x)
        let _y1 = Int(point.y)
        let _x2 = _x1 + 1
        let _y2 = _y1 + 1
        
        let _tx = point.x - Double(_x1)
        let _ty = point.y - Double(_y1)
        
        let _s1 = read_source(_x1, _y1)
        let _s2 = read_source(_x2, _y1)
        let _s3 = read_source(_x1, _y2)
        let _s4 = read_source(_x2, _y2)
        
        return sampler(_ty, sampler(_tx, _s1, _s2), sampler(_tx, _s3, _s4))
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func gaussianBlurFilter(_ blur: Double) -> [Double] {
        
        let t = 2 * blur * blur
        let c = 1 / sqrt(.pi * t)
        let _t = -1 / t
        
        let s = Int(ceil(6 * blur)) >> 1
        
        return (-s...s).map {
            let x = Double($0)
            return exp(x * x * _t) * c
        }
    }
    
    @_versioned
    @_inlineable
    func _shadow(_ map: MappedBuffer<Double>, _ filter: [Double]) -> ShadowTexture {
        
        let width = self.width
        let height = self.height
        let option = self.image.option
        
        let n_width = width + filter.count - 1
        
        guard width > 0 && height > 0 else { return ShadowTexture(width: width, height: height, pixels: map) }
        
        let length = FFTConvolveLength(width, filter.count)
        
        var buffer = MappedBuffer<Double>(repeating: 0, count: length + length * height, option: option)
        var result = ShadowTexture(width: n_width, height: length, option: option)
        
        buffer.withUnsafeMutableBufferPointer {
            
            guard let buffer = $0.baseAddress else { return }
            
            map.withUnsafeBufferPointer {
                
                guard let source = $0.baseAddress else { return }
                
                result.pixels.withUnsafeMutableBufferPointer {
                    
                    guard let output = $0.baseAddress else { return }
                    
                    let level = log2(length)
                    
                    let _kreal = buffer
                    let _kimag = buffer + 1
                    let _temp1 = _kreal + length
                    
                    HalfRadix2CooleyTukey(level, filter, 1, filter.count, _kreal, _kimag, 2)
                    
                    var _length = Double(length)
                    Div(length, _kreal, _kimag, 2, &_length, 0, _kreal, _kimag, 2)
                    
                    _Radix2FiniteImpulseFilter(level, height, source, 1, width, width, _kreal, _kimag, 2, 0, _temp1, 1, length)
                    _Radix2FiniteImpulseFilter(level, n_width, _temp1, length, 1, height, _kreal, _kimag, 2, 0, output, n_width, 1)
                }
            }
        }
        
        return result
    }
}
