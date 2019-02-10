//
//  OverlapAddConvolve
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
public struct Radix2OverlapAddConvolve<T: BinaryFloatingPoint & FloatingMathProtocol> {

    @usableFromInline
    let fft_length: Int

    @usableFromInline
    let overlap_length: Int

    @usableFromInline
    var buffer: [T]

    @inlinable
    @inline(__always)
    public init(kernel: [T]) {

        let fft_length = Radix2CircularConvolveLength(kernel.count, kernel.count)
        let half = fft_length >> 1

        let kernel = kernel.map { $0 / T(fft_length) }

        self.fft_length = fft_length
        self.overlap_length = kernel.count - 1
        self.buffer = Array(repeating: 0, count: fft_length << 1 + overlap_length)

        buffer.withUnsafeMutableBufferPointer {

            guard let baseAddress = $0.baseAddress else { return }

            let kreal = baseAddress
            let kimag = baseAddress + half

            HalfRadix2CooleyTukey(log2(fft_length), kernel, 1, kernel.count, kreal, kimag, 1)
        }
    }

    @inlinable
    @inline(__always)
    public mutating func filter(_ source: UnsafeBufferPointer<T>, callback: (UnsafeBufferPointer<T>) -> Void) {

        let fft_length = self.fft_length
        let overlap_length = self.overlap_length
        let half = fft_length >> 1
        var source = source

        let level = log2(fft_length)

        buffer.withUnsafeMutableBufferPointer {

            guard let baseAddress = $0.baseAddress else { return }

            let kreal = baseAddress
            let kimag = baseAddress + half

            let temp = baseAddress + fft_length
            let overlap = temp + fft_length

            while source.count != 0 {

                let count = min(source.count, half)

                Radix2FiniteImpulseFilter(level, source.baseAddress!, 1, count, kreal, kimag, 1, temp, 1)

                vec_op(overlap_length, temp, 1, overlap, 1, temp, 1) { $0 + $1 }
                Move(overlap_length, temp + count, 1, overlap, 1)

                callback(UnsafeBufferPointer(start: temp, count: count))

                source = UnsafeBufferPointer(rebasing: source.dropFirst(count))
            }
        }
    }

    @inlinable
    @inline(__always)
    public func final(callback: (UnsafeBufferPointer<T>) -> Void) {

        let fft_length = self.fft_length
        let overlap_length = self.overlap_length

        buffer.withUnsafeBufferPointer {

            guard let baseAddress = $0.baseAddress else { return }

            let overlap = baseAddress + fft_length << 1

            callback(UnsafeBufferPointer(start: overlap, count: overlap_length))
        }
    }
}
