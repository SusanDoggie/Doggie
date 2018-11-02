//
//  resampling.metal
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

#define M_PI 3.1415926535897932384626433832795028841971693993751058

constant int countOfComponents [[function_constant(0)]];

struct interpolate_parameter {
    
    float3x2 transform;
    packed_uint2 source_size;
    packed_float2 a;
    uint b;
    uint antialias;
};

struct Addressing {
    
    bool flag;
    int i;
};

float _linear_interpolate(float t, float a, float b) {
    return a + t * (b - a);
}

float _cosine_interpolate(float t, float a, float b) {
    float u = 1 - cos(t * M_PI);
    float v = 0.5 * u;
    return _linear_interpolate(v, a, b);
}

float _cubic_interpolate(float t, float a, float b, float c, float d) {
    float t2 = t * t;
    float m0 = d - c - a + b;
    float m1 = a - b - m0;
    float m2 = c - a;
    float m3 = b;
    float n0 = m0 * t * t2;
    float n1 = m1 * t2;
    float n2 = m2 * t;
    return n0 + n1 + n2 + m3;
}

float _hermite_interpolate(float t, float a, float b, float c, float d, float s, float e) {
    float t2 = t * t;
    float t3 = t2 * t;
    float _2t3 = 2 * t3;
    float _3t2 = 3 * t2;
    float s0 = 0.5 * (1 - s);
    float e0 = 1 + e;
    float e1 = 1 - e;
    float e2 = s0 * e0;
    float e3 = s0 * e1;
    float u0 = (b - a) * e2;
    float u1 = (c - b) * e3;
    float v0 = (c - b) * e2;
    float v1 = (d - c) * e3;
    float m0 = u0 + u1;
    float m1 = v0 + v1;
    float a0 = _2t3 - _3t2 + 1;
    float a1 = t3 - 2 * t2 + t;
    float a2 = t3 - t2;
    float a3 = -_2t3 + _3t2;
    float b0 = a0 * b;
    float b1 = a1 * m0;
    float b2 = a2 * m1;
    float b3 = a3 * c;
    return b0 + b1 + b2 + b3;
}

float _mitchell_kernel(float x, float B, float C) {
    
    float a1 = 12 - 9 * B - 6 * C;
    float b1 = -18 + 12 * B + 6 * C;
    float c1 = 6 - 2 * B;
    float a2 = -B - 6 * C;
    float b2 = 6 * B + 30 * C;
    float c2 = -12 * B - 48 * C;
    float d2 = 8 * B + 24 * C;
    
    if (x < 1) {
        float u = a1 * x + b1;
        return u * x * x + c1;
    }
    if (x < 2) {
        float u = a2 * x + b2;
        float v = u * x + c2;
        return v * x + d2;
    }
    return 0;
}

float _lanczos_kernel(float x, uint a) {
    
    float _a = 1.0 / (float)a;
    
    if (x == 0) {
        return 1;
    }
    if (x < (float)a) {
        float _x = M_PI * x;
        float u = sin(_x) * sin(_x * _a);
        float v = _x * _x;
        return (float)a * u / v;
    }
    return 0;
}

Addressing _addressing_none(int x, int upperbound) {
    if (x >= 0 && x < upperbound) {
        return { true, x };
    }
    return { false, clamp(x, 0, upperbound) };
}
Addressing _addressing_clamp(int x, int upperbound) {
    return { true, clamp(x, 0, upperbound) };
}
Addressing _addressing_repeat(int x, int upperbound) {
    int _x = x % upperbound;
    if (_x < 0) {
        return { true, _x + upperbound };
    }
    return { true, _x };
}
Addressing _addressing_mirror(int x, int upperbound) {
    int ax = abs(x);
    int _x = ax % upperbound;
    if (((ax / upperbound) & 1) == 1) {
        return { true, upperbound - _x - 1 };
    }
    return { true, _x };
}

#define INTERPOLATE(HWRAPPING, VWRAPPING)                                                                                                              \
float _read_source_##HWRAPPING##_##VWRAPPING(const device float *source, int x, int y, int i, uint2 size) {                                            \
                                                                                                                                                       \
    Addressing _x = _addressing_##HWRAPPING(x, size[0]);                                                                                               \
    Addressing _y = _addressing_##VWRAPPING(y, size[1]);                                                                                               \
                                                                                                                                                       \
    int idx = x + y * size[0];                                                                                                                         \
    float pixel = source[idx * countOfComponents + i];                                                                                                 \
                                                                                                                                                       \
    if (_x.flag && _y.flag) {                                                                                                                          \
        return pixel;                                                                                                                                  \
    }                                                                                                                                                  \
    if (i < countOfComponents - 1) {                                                                                                                   \
        return pixel;                                                                                                                                  \
    }                                                                                                                                                  \
    return 0;                                                                                                                                          \
}                                                                                                                                                      \
float _none_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, int i, uint2 size) {                                       \
                                                                                                                                                       \
    return _read_source_##HWRAPPING##_##VWRAPPING(source, (float)floor(point[0]), (float)floor(point[1]), i, size);                                    \
}                                                                                                                                                      \
float _linear_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, int i, uint2 size) {                                     \
                                                                                                                                                       \
    float _i = floor(point[0]);                                                                                                                        \
    float _j = floor(point[1]);                                                                                                                        \
    float _tx = point[0] - _i;                                                                                                                         \
    float _ty = point[1] - _j;                                                                                                                         \
                                                                                                                                                       \
    int _x1 = (int)_i;                                                                                                                                 \
    int _y1 = (int)_j;                                                                                                                                 \
    int _x2 = _x1 + 1;                                                                                                                                 \
    int _y2 = _y1 + 1;                                                                                                                                 \
                                                                                                                                                       \
    float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                     \
    float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                     \
    float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                     \
    float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                     \
                                                                                                                                                       \
    return _linear_interpolate(_ty, _linear_interpolate(_tx, _s1, _s2), _linear_interpolate(_tx, _s3, _s4));                                           \
}                                                                                                                                                      \
float _cosine_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, int i, uint2 size) {                                     \
                                                                                                                                                       \
    float _i = floor(point[0]);                                                                                                                        \
    float _j = floor(point[1]);                                                                                                                        \
    float _tx = point[0] - _i;                                                                                                                         \
    float _ty = point[1] - _j;                                                                                                                         \
                                                                                                                                                       \
    int _x1 = (int)_i;                                                                                                                                 \
    int _y1 = (int)_j;                                                                                                                                 \
    int _x2 = _x1 + 1;                                                                                                                                 \
    int _y2 = _y1 + 1;                                                                                                                                 \
                                                                                                                                                       \
    float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                     \
    float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                     \
    float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                     \
    float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                     \
                                                                                                                                                       \
    return _cosine_interpolate(_ty, _cosine_interpolate(_tx, _s1, _s2), _cosine_interpolate(_tx, _s3, _s4));                                           \
}                                                                                                                                                      \
float _cubic_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, int i, uint2 size) {                                      \
                                                                                                                                                       \
    float _i = floor(point[0]);                                                                                                                        \
    float _j = floor(point[1]);                                                                                                                        \
    float _tx = point[0] - _i;                                                                                                                         \
    float _ty = point[1] - _j;                                                                                                                         \
                                                                                                                                                       \
    int _x2 = (int)_i;                                                                                                                                 \
    int _y2 = (int)_j;                                                                                                                                 \
    int _x3 = _x2 + 1;                                                                                                                                 \
    int _y3 = _y2 + 1;                                                                                                                                 \
    int _x1 = _x2 - 1;                                                                                                                                 \
    int _y1 = _y2 - 1;                                                                                                                                 \
    int _x4 = _x2 + 2;                                                                                                                                 \
    int _y4 = _y2 + 2;                                                                                                                                 \
                                                                                                                                                       \
    float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                     \
    float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                     \
    float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y1, i, size);                                                                     \
    float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y1, i, size);                                                                     \
    float _s5 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                     \
    float _s6 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                     \
    float _s7 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y2, i, size);                                                                     \
    float _s8 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y2, i, size);                                                                     \
    float _s9 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y3, i, size);                                                                     \
    float _s10 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y3, i, size);                                                                    \
    float _s11 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y3, i, size);                                                                    \
    float _s12 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y3, i, size);                                                                    \
    float _s13 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y4, i, size);                                                                    \
    float _s14 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y4, i, size);                                                                    \
    float _s15 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y4, i, size);                                                                    \
    float _s16 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y4, i, size);                                                                    \
                                                                                                                                                       \
    float _u1 = _cubic_interpolate(_tx, _s1, _s2, _s3, _s4);                                                                                           \
    float _u2 = _cubic_interpolate(_tx, _s5, _s6, _s7, _s8);                                                                                           \
    float _u3 = _cubic_interpolate(_tx, _s9, _s10, _s11, _s12);                                                                                        \
    float _u4 = _cubic_interpolate(_tx, _s13, _s14, _s15, _s16);                                                                                       \
                                                                                                                                                       \
    return _cubic_interpolate(_ty, _u1, _u2, _u3, _u4);                                                                                                \
}                                                                                                                                                      \
float _hermite_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, float s, float e, int i, uint2 size) {                  \
                                                                                                                                                       \
    float _i = floor(point[0]);                                                                                                                        \
    float _j = floor(point[1]);                                                                                                                        \
    float _tx = point[0] - _i;                                                                                                                         \
    float _ty = point[1] - _j;                                                                                                                         \
                                                                                                                                                       \
    int _x2 = (int)_i;                                                                                                                                 \
    int _y2 = (int)_j;                                                                                                                                 \
    int _x3 = _x2 + 1;                                                                                                                                 \
    int _y3 = _y2 + 1;                                                                                                                                 \
    int _x1 = _x2 - 1;                                                                                                                                 \
    int _y1 = _y2 - 1;                                                                                                                                 \
    int _x4 = _x2 + 2;                                                                                                                                 \
    int _y4 = _y2 + 2;                                                                                                                                 \
                                                                                                                                                       \
    float _s1 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y1, i, size);                                                                     \
    float _s2 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y1, i, size);                                                                     \
    float _s3 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y1, i, size);                                                                     \
    float _s4 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y1, i, size);                                                                     \
    float _s5 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y2, i, size);                                                                     \
    float _s6 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y2, i, size);                                                                     \
    float _s7 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y2, i, size);                                                                     \
    float _s8 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y2, i, size);                                                                     \
    float _s9 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y3, i, size);                                                                     \
    float _s10 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y3, i, size);                                                                    \
    float _s11 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y3, i, size);                                                                    \
    float _s12 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y3, i, size);                                                                    \
    float _s13 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x1, _y4, i, size);                                                                    \
    float _s14 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x2, _y4, i, size);                                                                    \
    float _s15 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x3, _y4, i, size);                                                                    \
    float _s16 = _read_source_##HWRAPPING##_##VWRAPPING(source, _x4, _y4, i, size);                                                                    \
                                                                                                                                                       \
    float _u1 = _hermite_interpolate(_tx, _s1, _s2, _s3, _s4, s, e);                                                                                   \
    float _u2 = _hermite_interpolate(_tx, _s5, _s6, _s7, _s8, s, e);                                                                                   \
    float _u3 = _hermite_interpolate(_tx, _s9, _s10, _s11, _s12, s, e);                                                                                \
    float _u4 = _hermite_interpolate(_tx, _s13, _s14, _s15, _s16, s, e);                                                                               \
                                                                                                                                                       \
    return _hermite_interpolate(_ty, _u1, _u2, _u3, _u4, s, e);                                                                                        \
}                                                                                                                                                      \
float _mitchell_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, float B, float C, int i, uint2 size) {                 \
                                                                                                                                                       \
    float pixel = 0;                                                                                                                                   \
    float t = 0;                                                                                                                                       \
                                                                                                                                                       \
    int _x = (int)floor(point[0]);                                                                                                                     \
    int _y = (int)floor(point[1]);                                                                                                                     \
                                                                                                                                                       \
    int min_x = _x - 1;                                                                                                                                \
    int max_x = min_x + 5;                                                                                                                             \
    int min_y = _y - 1;                                                                                                                                \
    int max_y = min_y + 5;                                                                                                                             \
                                                                                                                                                       \
    for (int y = min_y; y < max_y; ++y) {                                                                                                              \
        for (int x = min_x; y < max_x; ++x) {                                                                                                          \
            float k = _mitchell_kernel(distance(point, float2(x, y)), B, C);                                                                           \
            pixel += _read_source_##HWRAPPING##_##VWRAPPING(source, x, y, i, size) * k;                                                                \
            t += k;                                                                                                                                    \
        }                                                                                                                                              \
    }                                                                                                                                                  \
    return t == 0 ? 0 : pixel / t;                                                                                                                     \
}                                                                                                                                                      \
float _lanczos_interpolate_##HWRAPPING##_##VWRAPPING(const device float *source, float2 point, uint a, int i, uint2 size) {                            \
                                                                                                                                                       \
    float pixel = 0;                                                                                                                                   \
    float t = 0;                                                                                                                                       \
                                                                                                                                                       \
    int _x = (int)floor(point[0]);                                                                                                                     \
    int _y = (int)floor(point[1]);                                                                                                                     \
                                                                                                                                                       \
    int kernel_size = a << 1;                                                                                                                          \
    int b = 1 - kernel_size & 1;                                                                                                                       \
    int min_x = _x - a + b;                                                                                                                            \
    int max_x = min_x + kernel_size;                                                                                                                   \
    int min_y = _y - a + b;                                                                                                                            \
    int max_y = min_y + kernel_size;                                                                                                                   \
                                                                                                                                                       \
    for (int y = min_y; y < max_y; ++y) {                                                                                                              \
        for (int x = min_x; y < max_x; ++x) {                                                                                                          \
            float k = _lanczos_kernel(distance(point, float2(x, y)), a);                                                                               \
            pixel += _read_source_##HWRAPPING##_##VWRAPPING(source, x, y, i, size) * k;                                                                \
            t += k;                                                                                                                                    \
        }                                                                                                                                              \
    }                                                                                                                                                  \
    return t == 0 ? 0 : pixel / t;                                                                                                                     \
}                                                                                                                                                      \
kernel void none_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                    \
                                                       const device float *source [[buffer(1)]],                                                       \
                                                       device float *destination [[buffer(2)]],                                                        \
                                                       uint2 id [[thread_position_in_grid]],                                                           \
                                                       uint2 grid [[threads_per_grid]]) {                                                              \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _none_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                            \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void linear_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                  \
                                                         const device float *source [[buffer(1)]],                                                     \
                                                         device float *destination [[buffer(2)]],                                                      \
                                                         uint2 id [[thread_position_in_grid]],                                                         \
                                                         uint2 grid [[threads_per_grid]]) {                                                            \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _linear_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                          \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void cosine_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                  \
                                                         const device float *source [[buffer(1)]],                                                     \
                                                         device float *destination [[buffer(2)]],                                                      \
                                                         uint2 id [[thread_position_in_grid]],                                                         \
                                                         uint2 grid [[threads_per_grid]]) {                                                            \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _cosine_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                          \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void cubic_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                   \
                                                        const device float *source [[buffer(1)]],                                                      \
                                                        device float *destination [[buffer(2)]],                                                       \
                                                        uint2 id [[thread_position_in_grid]],                                                          \
                                                        uint2 grid [[threads_per_grid]]) {                                                             \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _cubic_interpolate_##HWRAPPING##_##VWRAPPING(source, point, i, size);                                                           \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void hermite_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                 \
                                                          const device float *source [[buffer(1)]],                                                    \
                                                          device float *destination [[buffer(2)]],                                                     \
                                                          uint2 id [[thread_position_in_grid]],                                                        \
                                                          uint2 grid [[threads_per_grid]]) {                                                           \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    float2 arg = parameter.a;                                                                                                                          \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _hermite_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg[0], arg[1], i, size);                                         \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void mitchell_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                \
                                                           const device float *source [[buffer(1)]],                                                   \
                                                           device float *destination [[buffer(2)]],                                                    \
                                                           uint2 id [[thread_position_in_grid]],                                                       \
                                                           uint2 grid [[threads_per_grid]]) {                                                          \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    float2 arg = parameter.a;                                                                                                                          \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _mitchell_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg[0], arg[1], i, size);                                        \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
}                                                                                                                                                      \
kernel void lanczos_interpolate_##HWRAPPING##_##VWRAPPING(const device interpolate_parameter &parameter [[buffer(0)]],                                 \
                                                          const device float *source [[buffer(1)]],                                                    \
                                                          device float *destination [[buffer(2)]],                                                     \
                                                          uint2 id [[thread_position_in_grid]],                                                        \
                                                          uint2 grid [[threads_per_grid]]) {                                                           \
                                                                                                                                                       \
    uint2 size = parameter.source_size;                                                                                                                \
    const int idx = grid[0] * id[1] + id[0];                                                                                                           \
                                                                                                                                                       \
    uint arg = parameter.b;                                                                                                                            \
    int antialias = parameter.antialias;                                                                                                               \
    float _a = 1.0 / (float)antialias;                                                                                                                 \
    float _a2 = 1.0 / (float)(antialias * antialias);                                                                                                  \
                                                                                                                                                       \
    for (int i = 0; i < countOfComponents; ++i) {                                                                                                      \
        float sum = 0;                                                                                                                                 \
        for (int y = 0; y < antialias; ++y) {                                                                                                          \
            for (int x = 0; x < antialias; ++x) {                                                                                                      \
                float _x = (float)id[0] + (float)x * _a;                                                                                               \
                float _y = (float)id[1] + (float)y * _a;                                                                                               \
                float2 point = parameter.transform * float3(_x, _y, 1);                                                                                \
                sum += _lanczos_interpolate_##HWRAPPING##_##VWRAPPING(source, point, arg, i, size);                                                    \
            }                                                                                                                                          \
        }                                                                                                                                              \
        destination[idx * countOfComponents + i] = sum * _a2;                                                                                          \
    }                                                                                                                                                  \
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
