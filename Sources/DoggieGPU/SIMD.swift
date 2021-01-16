//
//  SIMD.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

#if canImport(Metal)

extension SIMD2 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ point: Point) {
        self.init(Scalar(point.x), Scalar(point.y))
    }
    
    @_transparent
    init(_ size: Size) {
        self.init(Scalar(size.width), Scalar(size.height))
    }
}

extension SIMD3 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ vector: Vector) {
        self.init(Scalar(vector.x), Scalar(vector.y), Scalar(vector.z))
    }
}

extension SIMD4 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ rect: Rect) {
        self.init(Scalar(rect.minX), Scalar(rect.minY), Scalar(rect.width), Scalar(rect.height))
    }
}

extension simd_float3x2 {
    
    @_transparent
    init(_ transform: SDTransform) {
        self.init(columns: (
            simd_float2(Float(transform.a), Float(transform.d)),
            simd_float2(Float(transform.b), Float(transform.e)),
            simd_float2(Float(transform.c), Float(transform.f))
        ))
    }
}

#endif
