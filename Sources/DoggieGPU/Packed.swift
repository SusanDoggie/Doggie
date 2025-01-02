//
//  Packed.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

struct Packed2<Scalar> {
    
    var x: Scalar
    
    var y: Scalar
    
    @_transparent
    init(_ x: Scalar, _ y: Scalar) {
        self.x = x
        self.y = y
    }
}

struct Packed3<Scalar> {
    
    var x: Scalar
    
    var y: Scalar
    
    var z: Scalar
    
    @_transparent
    init(_ x: Scalar, _ y: Scalar, _ z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct Packed4<Scalar> {
    
    var x: Scalar
    
    var y: Scalar
    
    var z: Scalar
    
    var w: Scalar
    
    @_transparent
    init(_ x: Scalar, _ y: Scalar, _ z: Scalar, _ w: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

extension Packed2 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ point: Point) {
        self.init(Scalar(point.x), Scalar(point.y))
    }
    
    @_transparent
    init(_ size: Size) {
        self.init(Scalar(size.width), Scalar(size.height))
    }
}

extension Packed3 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ vector: Vector) {
        self.init(Scalar(vector.x), Scalar(vector.y), Scalar(vector.z))
    }
}

extension Packed4 where Scalar: BinaryFloatingPoint {
    
    @_transparent
    init(_ rect: Rect) {
        self.init(Scalar(rect.minX), Scalar(rect.minY), Scalar(rect.width), Scalar(rect.height))
    }
}

typealias packed_int2 = Packed2<Int32>
typealias packed_int3 = Packed3<Int32>
typealias packed_int4 = Packed4<Int32>

typealias packed_uint2 = Packed2<UInt32>
typealias packed_uint3 = Packed3<UInt32>
typealias packed_uint4 = Packed4<UInt32>

typealias packed_float2 = Packed2<Float>
typealias packed_float3 = Packed3<Float>
typealias packed_float4 = Packed4<Float>

typealias packed_float3x2 = Packed3<Packed2<Float>>

extension packed_float3x2 {
    
    @_transparent
    init(_ transform: SDTransform) {
        self.init(
            Packed2(Float(transform.a), Float(transform.d)),
            Packed2(Float(transform.b), Float(transform.e)),
            Packed2(Float(transform.c), Float(transform.f))
        )
    }
}

#endif
