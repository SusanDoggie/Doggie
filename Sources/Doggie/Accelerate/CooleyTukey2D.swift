//
//  CooleyTukey2D.swift
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
public func HalfRadix2CooleyTukey2D<T: BinaryFloatingPoint>(_ level: (Int, Int), _ input: UnsafePointer<T>, _ in_stride: Int, _ in_count: (Int, Int), _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    let width = 1 << level.0
    let height = 1 << level.1
    let half_width = width >> 1

    let in_width = in_count.0
    let in_height = in_count.1

    let in_row_stride = in_stride * in_width
    let out_row_stride = out_stride * half_width

    do {
        var input = input
        var _real = _real
        var _imag = _imag

        for _ in 0..<in_height {
            HalfRadix2CooleyTukey(level.0, input, in_stride, in_width, _real, _imag, out_stride)
            input += in_row_stride
            _real += out_row_stride
            _imag += out_row_stride
        }
        for _ in in_height..<height {
            var _r = _real
            var _i = _imag
            for _ in 0..<half_width {
                _r.pointee = 0
                _i.pointee = 0
                _r += out_stride
                _i += out_stride
            }
            _real += out_row_stride
            _imag += out_row_stride
        }
    }

    do {
        var _real = _real
        var _imag = _imag

        HalfRadix2CooleyTukey(level.1, _real, out_row_stride)
        HalfRadix2CooleyTukey(level.1, _imag, out_row_stride)

        for _ in 1..<half_width {
            _real += out_stride
            _imag += out_stride
            Radix2CooleyTukey(level.1, _real, _imag, out_row_stride)
        }
    }
}

@inlinable
@inline(__always)
public func HalfInverseRadix2CooleyTukey2D<T: BinaryFloatingPoint>(_ level: (Int, Int), _ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int) where T : FloatingMathProtocol {

    let width = 1 << level.0
    let height = 1 << level.1
    let half_width = width >> 1

    let _real = output
    let _imag = output + out_stride
    let _out_stride = out_stride << 1

    do {
        var real = real
        var imag = imag
        var _real = _real
        var _imag = _imag

        let in_row_stride = in_stride * half_width
        let out_row_stride = _out_stride * half_width

        HalfInverseRadix2CooleyTukey(level.1, real, real + in_row_stride, in_row_stride << 1, _real, out_row_stride)
        HalfInverseRadix2CooleyTukey(level.1, imag, imag + in_row_stride, in_row_stride << 1, _imag, out_row_stride)

        for _ in 1..<half_width {
            real += in_stride
            imag += in_stride
            _real += _out_stride
            _imag += _out_stride
            InverseRadix2CooleyTukey(level.1, real, imag, in_row_stride, height, _real, _imag, out_row_stride)
        }
    }

    do {
        var output = output

        let out_row_stride = out_stride * width

        for _ in 0..<height {
            HalfInverseRadix2CooleyTukey(level.0, output, out_stride)
            output += out_row_stride
        }
    }
}

@inlinable
@inline(__always)
public func separate_convolution_filter<T: BinaryFloatingPoint>(_ filter: [T], _ width: Int, _ height: Int) -> ([T], [T])? {

    var horizontal = [T](repeating: 0, count: width)
    var vertical = [T](repeating: 0, count: height)

    filter.withUnsafeBufferPointer {

        guard let filter = $0.baseAddress else { return }

        return horizontal.withUnsafeMutableBufferPointer {

            guard let horizontal = $0.baseAddress else { return }

            return vertical.withUnsafeMutableBufferPointer {

                guard let vertical = $0.baseAddress else { return }

                var (i, m) = UnsafeBufferPointer(start: filter, count: width * height).enumerated().max { abs($0.element) < abs($1.element) }!

                guard m != 0 else { return }

                let j = i % width
                i /= width
                m = 1 / sqrt(abs(m))

                do {

                    var _filter = filter + i * width
                    var _horizontal = horizontal

                    for _ in 0..<width {
                        _horizontal.pointee = _filter.pointee * m
                        _filter += 1
                        _horizontal += 1
                    }
                }

                do {

                    var _filter = filter + j
                    let _horizontal = horizontal + j
                    var _vertical = vertical

                    for _ in 0..<height {
                        _vertical.pointee = _filter.pointee / _horizontal.pointee
                        _filter += width
                        _vertical += 1
                    }
                }
            }
        }
    }

    let is_equal = zip(filter, vertical.flatMap { a in horizontal.map { a * $0 } }).allSatisfy { $0.almostEqual($1) }

    return is_equal ? (horizontal, vertical) : nil
}
