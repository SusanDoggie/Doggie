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

constant int countOfComponents [[function_constant(0)]];

const float cross(const float2 a, const float2 b);
const float3 Barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q);
const bool inTriangle(const float2 p0, const float2 p1, const float2 p2, const float2 position);

void _set_opacity(const float opacity, device float *destination, const int idx);

struct stencil_parameter {
    
    const packed_uint2 offset;
    const uint width;
    const uint count;
};

struct stencil_triangle_struct {
    
    const packed_float2 p0, p1, p2;
};

struct stencil_quadratic_struct {
    
    const packed_float2 p0, p1, p2;
};

struct stencil_cubic_struct {
    
    const packed_float2 p0, p1, p2;
    const packed_float3 v0, v1, v2;
};

const int stencil_triangle(const float2 point, const device stencil_triangle_struct *triangles, const int count) {
    
    int counter = 0;
    
    for (int i = 0; i < count; ++i) {
        
        const stencil_triangle_struct triangle = triangles[i];
        
        const float2 p0 = triangle.p0;
        const float2 p1 = triangle.p1;
        const float2 p2 = triangle.p2;
        
        if (inTriangle(p0, p1, p2, point)) {
            if (signbit(cross(p1 - p0, p2 - p0))) {
                --counter;
            } else {
                ++counter;
            }
        }
    }
    
    return counter;
}

const int stencil_quadratic(const float2 point, const device stencil_quadratic_struct *triangles, const int count) {
    
    int counter = 0;
    
    for (int i = 0; i < count; ++i) {
        
        const stencil_quadratic_struct triangle = triangles[i];
        
        const float2 p0 = triangle.p0;
        const float2 p1 = triangle.p1;
        const float2 p2 = triangle.p2;
        
        if (inTriangle(p0, p1, p2, point)) {
            
            const float3 p = Barycentric(p0, p1, p2, point);
            const float s = 0.5 * p[1] + p[2];
            
            if (s * s < p[2]) {
                if (signbit(cross(p1 - p0, p2 - p0))) {
                    --counter;
                } else {
                    ++counter;
                }
            }
        }
    }
    
    return counter;
}

const int stencil_cubic(const float2 point, const device stencil_cubic_struct *triangles, const int count) {
    
    int counter = 0;
    
    for (int i = 0; i < count; ++i) {
        
        const stencil_cubic_struct triangle = triangles[i];
        
        const float2 p0 = triangle.p0;
        const float2 p1 = triangle.p1;
        const float2 p2 = triangle.p2;
        const float3 v0 = triangle.v0;
        const float3 v1 = triangle.v1;
        const float3 v2 = triangle.v2;
        
        if (inTriangle(p0, p1, p2, point)) {
            
            const float3 p = Barycentric(p0, p1, p2, point);
            const float3 u0 = p[0] * v0;
            const float3 u1 = p[1] * v1;
            const float3 u2 = p[2] * v2;
            const float3 v = u0 + u1 + u2;
            
            if (v[0] * v[0] * v[0] < v[1] * v[2]) {
                if (signbit(cross(p1 - p0, p2 - p0))) {
                    --counter;
                } else {
                    ++counter;
                }
            }
        }
    }
    
    return counter;
}

struct fill_parameter {
    
    const packed_uint2 offset;
    const uint width;
    const uint antialias;
    const float color[16];
    const uint triangle_count;
    const uint quadratic_count;
    const uint cubic_count;
};

kernel void fill_nonZero(const device fill_parameter &parameter [[buffer(0)]],
                         const device stencil_triangle_struct *triangles [[buffer(1)]],
                         const device stencil_quadratic_struct *quadratics [[buffer(2)]],
                         const device stencil_cubic_struct *cubics [[buffer(3)]],
                         device float *out [[buffer(4)]],
                         uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    
    const float _a = 1.0 / (float)antialias;
    
    int counter = 0;
    
    for (int j = 0; j < antialias; ++j) {
        for (int i = 0; i < antialias; ++i) {
            
            const float2 point = float2((float)position[0] + (float)i * _a, (float)position[1] + (float)j * _a);
            
            int stencil = stencil_triangle(point, triangles, parameter.triangle_count);
            stencil += stencil_quadratic(point, quadratics, parameter.quadratic_count);
            stencil += stencil_cubic(point, cubics, parameter.cubic_count);
            
            if (stencil != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < countOfComponents; ++i) {
        out[idx * countOfComponents + i] = parameter.color[i];
    }
    
    _set_opacity((float)counter / (float)(antialias * antialias), out, idx);
}

kernel void fill_evenOdd(const device fill_parameter &parameter [[buffer(0)]],
                         const device stencil_triangle_struct *triangles [[buffer(1)]],
                         const device stencil_quadratic_struct *quadratics [[buffer(2)]],
                         const device stencil_cubic_struct *cubics [[buffer(3)]],
                         device float *out [[buffer(4)]],
                         uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    
    const float _a = 1.0 / (float)antialias;
    
    int counter = 0;
    
    for (int j = 0; j < antialias; ++j) {
        for (int i = 0; i < antialias; ++i) {
            
            const float2 point = float2((float)position[0] + (float)i * _a, (float)position[1] + (float)j * _a);
            
            int stencil = stencil_triangle(point, triangles, parameter.triangle_count);
            stencil += stencil_quadratic(point, quadratics, parameter.quadratic_count);
            stencil += stencil_cubic(point, cubics, parameter.cubic_count);
            
            if ((stencil & 1) != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < countOfComponents; ++i) {
        out[idx * countOfComponents + i] = parameter.color[i];
    }
    
    _set_opacity((float)counter / (float)(antialias * antialias), out, idx);
}
