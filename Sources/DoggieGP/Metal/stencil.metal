//
//  stencil.metal
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

#include <metal_stdlib>
using namespace metal;

struct stencil_triangle_parameter {
    
    const uint y_offset;
    const uint width;
    const packed_float2 p0, p1, p2;
};

struct stencil_cubic_parameter {
    
    const uint y_offset;
    const uint width;
    const packed_float2 p0, p1, p2;
    const packed_float3 v0, v1, v2;
};

void swap(thread float2 *a, thread float2 *b) {
    float2 temp = *a;
    *a = *b;
    *b = temp;
}

void sort(thread float2 *a, thread float2 *b, thread float2 *c) {
    if ((*b).y < (*a).y) { swap(a, b); }
    if ((*c).y < (*b).y) { swap(b, c); }
    if ((*b).y < (*a).y) { swap(a, b); }
}

const float scan(const float2 p0, const float2 p1, const float y) {
    const float d = p1.y - p0.y;
    const float _d = 1 / d;
    const float q = (p1.x - p0.x) * _d;
    const float r = (p0.x * p1.y - p1.x * p0.y) * _d;
    return q * y + r;
}

const int2 _clamped(const int bound, const int2 range) {
    return int2(max(0, min(bound, range[0])), max(0, min(bound, range[1])));
}

const int2 _x_range(const int width, const float y, const float2 p0, const float2 p1, const float2 p2) {
    
    float2 q0 = p0;
    float2 q1 = p1;
    float2 q2 = p2;
    
    sort(&q0, &q1, &q2);
    
    const float x0 = scan(q0, q2, y);
    const float x1 = y < q1.y ? scan(q0, q1, y) : scan(q1, q2, y);
    
    const float _min = min(x0, x1);
    const float _max = max(x0, x1);
    
    const float2 range = float2(ceil(_min), floor(_max));
    int2 _range = (int2)range;
    
    if (_range[0] > _range[1]) {
        return _clamped(width, int2(_range[0], _range[0]));
    }
    
    if (range[1] < _max) {
        _range[1] += 1;
    }
    
    return _clamped(width, _range);
}

const float cross(const float2 a, const float2 b) {
    return a.x * b.y - a.y * b.x;
}

const float3 barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q) {
    
    const float det = (p1.y - p2.y) * (p0.x - p2.x) + (p2.x - p1.x) * (p0.y - p2.y);
    
    const float s = ((p1.y - p2.y) * (q.x - p2.x) + (p2.x - p1.x) * (q.y - p2.y)) / det;
    const float t = ((p2.y - p0.y) * (q.x - p2.x) + (p0.x - p2.x) * (q.y - p2.y)) / det;
    
    return float3(s, t, 1 - s - t);
}

kernel void stencil_triangle(const device stencil_triangle_parameter &parameter [[buffer(0)]],
                             device int16_t *stencil [[buffer(1)]],
                             uint2 id [[thread_position_in_grid]]) {
    
    const float2 p0 = parameter.p0;
    const float2 p1 = parameter.p1;
    const float2 p2 = parameter.p2;
    
    const int width = parameter.width;
    const int y = id.y + parameter.y_offset;
    
    const int2 x_range = _x_range(width, y, p0, p1, p2);
    const int x = id.x + x_range[0];
    
    if (x >= x_range[1]) { return; }
    
    if (signbit(cross(p1 - p0, p2 - p0))) {
        --stencil[width * y + x];
    } else {
        ++stencil[width * y + x];
    }
}

kernel void stencil_quadratic(const device stencil_triangle_parameter &parameter [[buffer(0)]],
                              device int16_t *stencil [[buffer(1)]],
                              uint2 id [[thread_position_in_grid]]) {
    
    const float2 p0 = parameter.p0;
    const float2 p1 = parameter.p1;
    const float2 p2 = parameter.p2;
    
    const int width = parameter.width;
    const int y = id.y + parameter.y_offset;
    
    const int2 x_range = _x_range(width, y, p0, p1, p2);
    const int x = id.x + x_range[0];
    
    if (x >= x_range[1]) { return; }
    
    const float3 p = barycentric(p0, p1, p2, float2(x, y));
    const float s = 0.5 * p.y + p.z;
    
    if (s * s > p.z) { return; }
    
    if (signbit(cross(p1 - p0, p2 - p0))) {
        --stencil[width * y + x];
    } else {
        ++stencil[width * y + x];
    }
}

kernel void stencil_cubic(const device stencil_cubic_parameter &parameter [[buffer(0)]],
                          device int16_t *stencil [[buffer(1)]],
                          uint2 id [[thread_position_in_grid]]) {
    
    const float2 p0 = parameter.p0;
    const float2 p1 = parameter.p1;
    const float2 p2 = parameter.p2;
    
    const int width = parameter.width;
    const int y = id.y + parameter.y_offset;
    
    const int2 x_range = _x_range(width, y, p0, p1, p2);
    const int x = id.x + x_range[0];
    
    if (x >= x_range[1]) { return; }
    
    const float3 v0 = parameter.v0;
    const float3 v1 = parameter.v1;
    const float3 v2 = parameter.v2;
    
    const float3 p = barycentric(p0, p1, p2, float2(x, y));
    const float3 u0 = p.x * v0;
    const float3 u1 = p.y * v1;
    const float3 u2 = p.z * v2;
    const float3 v = u0 + u1 + u2;
    
    if (v.x * v.x * v.x > v.y * v.z) { return; }
    
    if (signbit(cross(p1 - p0, p2 - p0))) {
        --stencil[width * y + x];
    } else {
        ++stencil[width * y + x];
    }
}
