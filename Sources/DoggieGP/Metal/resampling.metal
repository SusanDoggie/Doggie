//
//  resampling.metal
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

#include <metal_stdlib>
using namespace metal;

constant int countOfComponents [[function_constant(0)]];

struct interpolate_parameter {
    
    const float3x2 transform;
    const packed_uint2 source_size;
    const packed_float2 a;
    const uint b;
    const uint antialias;
};

struct Addressing {
    
    const bool flag;
    const int i;
};

const float _linear_interpolate(const float t, const float a, const float b) {
    return a + t * (b - a);
}

const float _cosine_interpolate(const float t, const float a, const float b) {
    const float u = 1 - cospi(t);
    const float v = 0.5 * u;
    return _linear_interpolate(v, a, b);
}

const float _cubic_interpolate(const float t, const float a, const float b, const float c, const float d) {
    const float t2 = t * t;
    const float m0 = d - c - a + b;
    const float m1 = a - b - m0;
    const float m2 = c - a;
    const float m3 = b;
    const float n0 = m0 * t * t2;
    const float n1 = m1 * t2;
    const float n2 = m2 * t;
    return n0 + n1 + n2 + m3;
}

const float _hermite_interpolate(const float t, const float a, const float b, const float c, const float d, const float s,const  float e) {
    const float t2 = t * t;
    const float t3 = t2 * t;
    const float _2t3 = 2 * t3;
    const float _3t2 = 3 * t2;
    const float s0 = 0.5 * (1 - s);
    const float e0 = 1 + e;
    const float e1 = 1 - e;
    const float e2 = s0 * e0;
    const float e3 = s0 * e1;
    const float u0 = (b - a) * e2;
    const float u1 = (c - b) * e3;
    const float v0 = (c - b) * e2;
    const float v1 = (d - c) * e3;
    const float m0 = u0 + u1;
    const float m1 = v0 + v1;
    const float a0 = _2t3 - _3t2 + 1;
    const float a1 = t3 - 2 * t2 + t;
    const float a2 = t3 - t2;
    const float a3 = -_2t3 + _3t2;
    const float b0 = a0 * b;
    const float b1 = a1 * m0;
    const float b2 = a2 * m1;
    const float b3 = a3 * c;
    return b0 + b1 + b2 + b3;
}

const float _mitchell_kernel(const float x, const float B, const float C) {
    
    const float a1 = 12 - 9 * B - 6 * C;
    const float b1 = -18 + 12 * B + 6 * C;
    const float c1 = 6 - 2 * B;
    const float a2 = -B - 6 * C;
    const float b2 = 6 * B + 30 * C;
    const float c2 = -12 * B - 48 * C;
    const float d2 = 8 * B + 24 * C;
    
    if (x < 1) {
        const float u = a1 * x + b1;
        return u * x * x + c1;
    }
    if (x < 2) {
        const float u = a2 * x + b2;
        const float v = u * x + c2;
        return v * x + d2;
    }
    return 0;
}

const float _lanczos_kernel(const float x, const uint a) {
    
    const float _a = 1.0 / (float)a;
    
    if (x == 0) {
        return 1;
    }
    if (x < (float)a) {
        const float _x = M_PI_F * x;
        const float u = sin(_x) * sin(_x * _a);
        const float v = _x * _x;
        return (float)a * u / v;
    }
    return 0;
}

const Addressing _addressing_none(const int x, const int upperbound) {
    if (x >= 0 && x < upperbound) {
        return { true, x };
    }
    return { false, clamp(x, 0, upperbound) };
}
const Addressing _addressing_clamp(const int x, const int upperbound) {
    return { true, clamp(x, 0, upperbound) };
}
const Addressing _addressing_repeat(const int x, const int upperbound) {
    const int _x = x % upperbound;
    if (_x < 0) {
        return { true, _x + upperbound };
    }
    return { true, _x };
}
const Addressing _addressing_mirror(const int x, const int upperbound) {
    const int ax = abs(x);
    const int _x = ax % upperbound;
    if (((ax / upperbound) & 1) == 1) {
        return { true, upperbound - _x - 1 };
    }
    return { true, _x };
}

#define INTERPOLATE(HWRAPPING, VWRAPPING)                                                                                                                                   \
const float _read_source_##HWRAPPING##_##VWRAPPING(const device float *source, const int x, const int y, const int i, const uint2 size) {                                   \
                                                                                                                                                                            \
    const Addressing _x = _addressing_##HWRAPPING(x, size.x);                                                                                                               \
    const Addressing _y = _addressing_##VWRAPPING(y, size.y);                                                                                                               \
                                                                                                                                                                            \
    const int idx = _x.i + _y.i * size.x;                                                                                                                                   \
    const float pixel = source[idx * countOfComponents + i];                                                                                                                \
                                                                                                                                                                            \
    if (_x.flag && _y.flag) {                                                                                                                                               \
        return pixel;                                                                                                                                                       \
    }                                                                                                                                                                       \
    if (i < countOfComponents - 1) {                                                                                                                                        \
        return pixel;                                                                                                                                                       \
    }                                                                                                                                                                       \
    return 0;                                                                                                                                                               \
}                                                                                                                                                                           \
const float _none_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const int i, const uint2 size) {                                    \
                                                                                                                                                                            \
    return _read_source_##HWRAPPING##_##VWRAPPING(source, (float)floor(point.x), (float)floor(point.y), i, size);                                                           \
}                                                                                                                                                                           \
const float _linear_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const int i, const uint2 size) {                                  \
                                                                                                                                                                            \
    const float _i = floor(point.x);                                                                                                                                        \
    const float _j = floor(point.y);                                                                                                                                        \
    const float _tx = point.x - _i;                                                                                                                                         \
    const float _ty = point.y - _j;                                                                                                                                         \
                                                                                                                                                                            \
    const int _x1 = (int)_i;                                                                                                                                                \
    const int _y1 = (int)_j;                                                                                                                                                \
    const int _x2 = _x1 + 1;                                                                                                                                                \
    const int _y2 = _y1 + 1;                                                                                                                                                \
                                                                                                                                                                            \
    const float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                                    \
    const float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                                    \
    const float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                                    \
    const float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                                    \
                                                                                                                                                                            \
    return _linear_interpolate(_ty, _linear_interpolate(_tx, _s1, _s2), _linear_interpolate(_tx, _s3, _s4));                                                                \
}                                                                                                                                                                           \
const float _cosine_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const int i, const uint2 size) {                                  \
                                                                                                                                                                            \
    const float _i = floor(point.x);                                                                                                                                        \
    const float _j = floor(point.y);                                                                                                                                        \
    const float _tx = point.x - _i;                                                                                                                                         \
    const float _ty = point.y - _j;                                                                                                                                         \
                                                                                                                                                                            \
    const int _x1 = (int)_i;                                                                                                                                                \
    const int _y1 = (int)_j;                                                                                                                                                \
    const int _x2 = _x1 + 1;                                                                                                                                                \
    const int _y2 = _y1 + 1;                                                                                                                                                \
                                                                                                                                                                            \
    const float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                                    \
    const float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                                    \
    const float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                                    \
    const float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                                    \
                                                                                                                                                                            \
    return _cosine_interpolate(_ty, _cosine_interpolate(_tx, _s1, _s2), _cosine_interpolate(_tx, _s3, _s4));                                                                \
}                                                                                                                                                                           \
const float _cubic_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const int i, const uint2 size) {                                   \
                                                                                                                                                                            \
    const float _i = floor(point.x);                                                                                                                                        \
    const float _j = floor(point.y);                                                                                                                                        \
    const float _tx = point.x - _i;                                                                                                                                         \
    const float _ty = point.y - _j;                                                                                                                                         \
                                                                                                                                                                            \
    const int _x2 = (int)_i;                                                                                                                                                \
    const int _y2 = (int)_j;                                                                                                                                                \
    const int _x3 = _x2 + 1;                                                                                                                                                \
    const int _y3 = _y2 + 1;                                                                                                                                                \
    const int _x1 = _x2 - 1;                                                                                                                                                \
    const int _y1 = _y2 - 1;                                                                                                                                                \
    const int _x4 = _x2 + 2;                                                                                                                                                \
    const int _y4 = _y2 + 2;                                                                                                                                                \
                                                                                                                                                                            \
    const float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                                    \
    const float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                                    \
    const float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y1, i, size);                                                                                    \
    const float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y1, i, size);                                                                                    \
    const float _s5 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                                    \
    const float _s6 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                                    \
    const float _s7 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y2, i, size);                                                                                    \
    const float _s8 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y2, i, size);                                                                                    \
    const float _s9 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y3, i, size);                                                                                    \
    const float _s10 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y3, i, size);                                                                                   \
    const float _s11 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y3, i, size);                                                                                   \
    const float _s12 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y3, i, size);                                                                                   \
    const float _s13 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y4, i, size);                                                                                   \
    const float _s14 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y4, i, size);                                                                                   \
    const float _s15 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y4, i, size);                                                                                   \
    const float _s16 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y4, i, size);                                                                                   \
                                                                                                                                                                            \
    const float _u1 = _cubic_interpolate(_tx, _s1, _s2, _s3, _s4);                                                                                                          \
    const float _u2 = _cubic_interpolate(_tx, _s5, _s6, _s7, _s8);                                                                                                          \
    const float _u3 = _cubic_interpolate(_tx, _s9, _s10, _s11, _s12);                                                                                                       \
    const float _u4 = _cubic_interpolate(_tx, _s13, _s14, _s15, _s16);                                                                                                      \
                                                                                                                                                                            \
    return _cubic_interpolate(_ty, _u1, _u2, _u3, _u4);                                                                                                                     \
}                                                                                                                                                                           \
const float _hermite_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const float s, const float e, const int i, const uint2 size) {   \
                                                                                                                                                                            \
    const float _i = floor(point.x);                                                                                                                                        \
    const float _j = floor(point.y);                                                                                                                                        \
    const float _tx = point.x - _i;                                                                                                                                         \
    const float _ty = point.y - _j;                                                                                                                                         \
                                                                                                                                                                            \
    const int _x2 = (int)_i;                                                                                                                                                \
    const int _y2 = (int)_j;                                                                                                                                                \
    const int _x3 = _x2 + 1;                                                                                                                                                \
    const int _y3 = _y2 + 1;                                                                                                                                                \
    const int _x1 = _x2 - 1;                                                                                                                                                \
    const int _y1 = _y2 - 1;                                                                                                                                                \
    const int _x4 = _x2 + 2;                                                                                                                                                \
    const int _y4 = _y2 + 2;                                                                                                                                                \
                                                                                                                                                                            \
    const float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                                    \
    const float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                                    \
    const float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y1, i, size);                                                                                    \
    const float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y1, i, size);                                                                                    \
    const float _s5 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                                    \
    const float _s6 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                                    \
    const float _s7 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y2, i, size);                                                                                    \
    const float _s8 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y2, i, size);                                                                                    \
    const float _s9 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y3, i, size);                                                                                    \
    const float _s10 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y3, i, size);                                                                                   \
    const float _s11 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y3, i, size);                                                                                   \
    const float _s12 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y3, i, size);                                                                                   \
    const float _s13 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y4, i, size);                                                                                   \
    const float _s14 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y4, i, size);                                                                                   \
    const float _s15 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y4, i, size);                                                                                   \
    const float _s16 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y4, i, size);                                                                                   \
                                                                                                                                                                            \
    const float _u1 = _hermite_interpolate(_tx, _s1, _s2, _s3, _s4, s, e);                                                                                                  \
    const float _u2 = _hermite_interpolate(_tx, _s5, _s6, _s7, _s8, s, e);                                                                                                  \
    const float _u3 = _hermite_interpolate(_tx, _s9, _s10, _s11, _s12, s, e);                                                                                               \
    const float _u4 = _hermite_interpolate(_tx, _s13, _s14, _s15, _s16, s, e);                                                                                              \
                                                                                                                                                                            \
    return _hermite_interpolate(_ty, _u1, _u2, _u3, _u4, s, e);                                                                                                             \
}                                                                                                                                                                           \
const float _mitchell_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const float B, const float C, const int i, const uint2 size) {  \
                                                                                                                                                                            \
    float pixel = 0;                                                                                                                                                        \
    float t = 0;                                                                                                                                                            \
                                                                                                                                                                            \
    const int _x = (int)floor(point.x);                                                                                                                                     \
    const int _y = (int)floor(point.y);                                                                                                                                     \
                                                                                                                                                                            \
    const int min_x = _x - 1;                                                                                                                                               \
    const int max_x = min_x + 5;                                                                                                                                            \
    const int min_y = _y - 1;                                                                                                                                               \
    const int max_y = min_y + 5;                                                                                                                                            \
                                                                                                                                                                            \
    for (int y = min_y; y < max_y; ++y) {                                                                                                                                   \
        for (int x = min_x; x < max_x; ++x) {                                                                                                                               \
            const float k = _mitchell_kernel(distance(point, float2(x, y)), B, C);                                                                                          \
            pixel += _read_source_##HWRAPPING##_##VWRAPPING(source, x, y, i, size) * k;                                                                                     \
            t += k;                                                                                                                                                         \
        }                                                                                                                                                                   \
    }                                                                                                                                                                       \
    return t == 0 ? 0 : pixel / t;                                                                                                                                          \
}                                                                                                                                                                           \
const float _lanczos_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, const float2 point, const uint a, const int i, const uint2 size) {                   \
                                                                                                                                                                            \
    float pixel = 0;                                                                                                                                                        \
    float t = 0;                                                                                                                                                            \
                                                                                                                                                                            \
    const int _x = (int)floor(point.x);                                                                                                                                     \
    const int _y = (int)floor(point.y);                                                                                                                                     \
                                                                                                                                                                            \
    const int kernel_size = a << 1;                                                                                                                                         \
    const int b = 1 - kernel_size & 1;                                                                                                                                      \
    const int min_x = _x - a + b;                                                                                                                                           \
    const int max_x = min_x + kernel_size;                                                                                                                                  \
    const int min_y = _y - a + b;                                                                                                                                           \
    const int max_y = min_y + kernel_size;                                                                                                                                  \
                                                                                                                                                                            \
    for (int y = min_y; y < max_y; ++y) {                                                                                                                                   \
        for (int x = min_x; x < max_x; ++x) {                                                                                                                               \
            const float k = _lanczos_kernel(distance(point, float2(x, y)), a);                                                                                              \
            pixel += _read_source_##HWRAPPING##_##VWRAPPING(source, x, y, i, size) * k;                                                                                     \
            t += k;                                                                                                                                                         \
        }                                                                                                                                                                   \
    }                                                                                                                                                                       \
    return t == 0 ? 0 : pixel / t;                                                                                                                                          \
}                                                                                                                                                                           \
kernel void none_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                         \
                                                       const device float *source [[buffer(1)]],                                                                            \
                                                       device float *destination [[buffer(2)]],                                                                             \
                                                       uint2 id [[thread_position_in_grid]],                                                                                \
                                                       uint2 grid [[threads_per_grid]]) {                                                                                   \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _none_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                                                 \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void linear_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                       \
                                                         const device float *source [[buffer(1)]],                                                                          \
                                                         device float *destination [[buffer(2)]],                                                                           \
                                                         uint2 id [[thread_position_in_grid]],                                                                              \
                                                         uint2 grid [[threads_per_grid]]) {                                                                                 \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _linear_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                                               \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void cosine_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                       \
                                                         const device float *source [[buffer(1)]],                                                                          \
                                                         device float *destination [[buffer(2)]],                                                                           \
                                                         uint2 id [[thread_position_in_grid]],                                                                              \
                                                         uint2 grid [[threads_per_grid]]) {                                                                                 \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _cosine_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                                               \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void cubic_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                        \
                                                        const device float *source [[buffer(1)]],                                                                           \
                                                        device float *destination [[buffer(2)]],                                                                            \
                                                        uint2 id [[thread_position_in_grid]],                                                                               \
                                                        uint2 grid [[threads_per_grid]]) {                                                                                  \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _cubic_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                                                \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void hermite_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                      \
                                                          const device float *source [[buffer(1)]],                                                                         \
                                                          device float *destination [[buffer(2)]],                                                                          \
                                                          uint2 id [[thread_position_in_grid]],                                                                             \
                                                          uint2 grid [[threads_per_grid]]) {                                                                                \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const float2 arg = parameter.a;                                                                                                                                         \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _hermite_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg.x, arg.y, i, size);                                                                \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void mitchell_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                     \
                                                           const device float *source [[buffer(1)]],                                                                        \
                                                           device float *destination [[buffer(2)]],                                                                         \
                                                           uint2 id [[thread_position_in_grid]],                                                                            \
                                                           uint2 grid [[threads_per_grid]]) {                                                                               \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const float2 arg = parameter.a;                                                                                                                                         \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _mitchell_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg.x, arg.y, i, size);                                                               \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}                                                                                                                                                                           \
kernel void lanczos_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                                      \
                                                          const device float *source [[buffer(1)]],                                                                         \
                                                          device float *destination [[buffer(2)]],                                                                          \
                                                          uint2 id [[thread_position_in_grid]],                                                                             \
                                                          uint2 grid [[threads_per_grid]]) {                                                                                \
                                                                                                                                                                            \
    const uint2 size = parameter.source_size;                                                                                                                               \
    const int idx = grid.x * id.y + id.x;                                                                                                                                   \
                                                                                                                                                                            \
    const uint arg = parameter.b;                                                                                                                                           \
    const int antialias = parameter.antialias;                                                                                                                              \
    const float _a = 1.0 / (float)antialias;                                                                                                                                \
    const float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                                 \
                                                                                                                                                                            \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                                           \
        float sum = 0;                                                                                                                                                      \
        for (int y = 0; y < antialias; ++y) {                                                                                                                               \
            for (int x = 0; x < antialias; ++x) {                                                                                                                           \
                const float _x = (float)id.x + (float)x * _a;                                                                                                               \
                const float _y = (float)id.y + (float)y * _a;                                                                                                               \
                const float2 point = parameter.transform * float3(_x, _y, 1);                                                                                               \
                sum += _lanczos_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg, i, size);                                                                         \
            }                                                                                                                                                               \
        }                                                                                                                                                                   \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                                               \
    }                                                                                                                                                                       \
}

INTERPOLATE(none, none)
INTERPOLATE(clamp, none)
INTERPOLATE(repeat, none)
INTERPOLATE(mirror, none)

INTERPOLATE(none, clamp)
INTERPOLATE(clamp, clamp)
INTERPOLATE(repeat, clamp)
INTERPOLATE(mirror, clamp)

INTERPOLATE(none, repeat)
INTERPOLATE(clamp, repeat)
INTERPOLATE(repeat, repeat)
INTERPOLATE(mirror, repeat)

INTERPOLATE(none, mirror)
INTERPOLATE(clamp, mirror)
INTERPOLATE(repeat, mirror)
INTERPOLATE(mirror, mirror)
