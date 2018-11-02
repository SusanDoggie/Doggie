//
//  gradient.metal
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

void _set_opacity(float opacity, device float *destination, int idx);

struct gradient_stop {
    
    float offset;
    float color[16];
};

struct gradient_parameter {
    
    float3x2 transform;
    packed_float2 start;
    packed_float2 end;
    packed_float2 radius;
    uint numOfStops;
};

float axial_shading(float2 point, float2 start, float2 end) {
    
    float2 a = start - point;
    float2 b = end - start;
    float u = b[0] * a[0] + b[1] * a[1];
    float v = b[0] * b[0] + b[1] * b[1];
    
    return -u / v;
}

bool radial_shading_filter(float t, float r0, float r1, bool start_spread, bool end_spread) {
    return r0 + t * r1 >= 0 && (t >= 0 || start_spread) && (t <= 1 || end_spread);
}

float2 degree2roots(float b, float c) {
    if (b == 0) {
        if (c < 0) {
            float _c = sqrt(-c);
            return float2(_c, -_c);
        } else if (c == 0) {
            return float2(0, 0);
        }
        return float2(NAN, NAN);
    }
    if (c == 0) {
        return float2(0, -b);
    }
    float del = b * b - 4 * c;
    if (del == 0) {
        return float2(-0.5 * b);
    } else if (del > 0) {
        float sqrt_del = sqrt(del);
        return float2(0.5 * (sqrt_del - b), 0.5 * (-sqrt_del - b));
    }
    return float2(NAN, NAN);
}

float radial_shading(float2 point, float2 start, float start_radius, float2 end, float end_radius, bool start_spread, bool end_spread) {
    
    float2 p0 = point - start;
    float2 p1 = start - end;
    float r0 = start_radius;
    float r1 = end_radius - start_radius;
    
    float a = p1[0] * p1[0] + p1[1] * p1[1] - r1 * r1;
    float b = 2 * (p0[0] * p1[0] + p0[1] * p1[1] - r0 * r1);
    float c = p0[0] * p0[0] + p0[1] * p0[1] - r0 * r0;
    
    if (a == 0) {
        if (b != 0) {
            float _t = -c / b;
            if (radial_shading_filter(_t, r0, r1, start_spread, end_spread)) {
                return _t;
            }
        }
    } else {
        
        float2 t2 = degree2roots(b / a, c / a);
        
        if (t2[0] == NAN) {
            return NAN;
        }
        
        float _max = max(t2[0], t2[1]);
        float _min = min(t2[0], t2[1]);
        
        if (_max != NAN && radial_shading_filter(_max, r0, r1, start_spread, end_spread)) {
            return _max;
        }
        if (_min != NAN && radial_shading_filter(_min, r0, r1, start_spread, end_spread)) {
            return _min;
        }
    }
    
    return NAN;
}

void _gradient_set_color(const device gradient_stop *stops, int stop_idx, device float *destination, int idx) {
    
    int d_index = idx * countOfComponents;
    gradient_stop stop = stops[stop_idx];
    
    for(int i = 0; i < countOfComponents; ++i) {
        destination[d_index + i] = stop.color[i];
    }
}

void gradient_set_color(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    int d_index = idx * countOfComponents;
    
    if (t <= stops[0].offset) {
        _gradient_set_color(stops, 0, destination, idx);
        return;
    }
    if (t >= stops[numOfStops - 1].offset) {
        _gradient_set_color(stops, numOfStops - 1, destination, idx);
        return;
    }
    
    for(int i = 0; i < numOfStops - 1; ++i) {
        
        gradient_stop lhs = stops[i];
        gradient_stop rhs = stops[i + 1];
        
        if (lhs.offset != rhs.offset && t >= lhs.offset && t <= rhs.offset) {
            
            float s = (t - lhs.offset) / (rhs.offset - lhs.offset);
            
            for(int i = 0; i < countOfComponents; ++i) {
                float lhs_c = lhs.color[i];
                float rhs_c = rhs.color[i];
                destination[d_index + i] = lhs_c * (1 - s) + rhs_c * s;
            }
            
            return;
        }
    }
    
    _gradient_set_color(stops, 0, destination, idx);
}

void _none_start_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    gradient_set_color(1, stops, numOfStops, destination, idx);
    _set_opacity(0, destination, idx);
}

void _pad_start_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    gradient_set_color(1, stops, numOfStops, destination, idx);
}

void _reflect_start_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    int i = (int)trunc(t);
    float s = t - (float)i;
    
    gradient_set_color((i & 1) == 0 ? s : 1 - s, stops, numOfStops, destination, idx);
}

void _repeat_start_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    int i = (int)trunc(t);
    float s = t - (float)i;
    
    gradient_set_color(s, stops, numOfStops, destination, idx);
}

void _none_end_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    gradient_set_color(0, stops, numOfStops, destination, idx);
    _set_opacity(0, destination, idx);
}

void _pad_end_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    gradient_set_color(0, stops, numOfStops, destination, idx);
}

void _reflect_end_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    int i = (int)trunc(t);
    float s = t - (float)i;
    
    gradient_set_color((i & 1) == 0 ? -s : 1 + s, stops, numOfStops, destination, idx);
}

void _repeat_end_spread(float t, const device gradient_stop *stops, int numOfStops, device float *destination, int idx) {
    
    int i = (int)trunc(t);
    float s = t - (float)i;
    
    gradient_set_color(1 + s, stops, numOfStops, destination, idx);
}

#define GRADIENTKERNEL(STARTMODE, ENDMODE, STARTSPREAD, ENDSPREAD)                                                      \
void gradient_mapping_##STARTMODE##_##ENDMODE(float t,                                                                  \
                                              const device gradient_stop *stops,                                        \
                                              int numOfStops,                                                           \
                                              device float *destination,                                                \
                                              int idx) {                                                                \
    if (t == NAN) {                                                                                                     \
        return;                                                                                                         \
    }                                                                                                                   \
    if (t >= 0 && t <= 1) {                                                                                             \
        gradient_set_color(t, stops, numOfStops, destination, idx);                                                     \
    } else if (t > 0.5) {                                                                                               \
        _##ENDMODE##_end_spread(t, stops, numOfStops, destination, idx);                                                \
    } else {                                                                                                            \
        _##STARTMODE##_start_spread(t, stops, numOfStops, destination, idx);                                            \
    }                                                                                                                   \
}                                                                                                                       \
kernel void axial_gradient_##STARTMODE##_##ENDMODE(const device gradient_parameter &parameter [[buffer(0)]],            \
                                                   const device gradient_stop *stops [[buffer(1)]],                     \
                                                   device float *out [[buffer(2)]],                                     \
                                                   uint2 id [[thread_position_in_grid]],                                \
                                                   uint2 grid [[threads_per_grid]]) {                                   \
                                                                                                                        \
    const int idx = grid[0] * id[1] + id[0];                                                                            \
                                                                                                                        \
    int numOfStops = parameter.numOfStops;                                                                              \
    float2 start = parameter.start;                                                                                     \
    float2 end = parameter.end;                                                                                         \
                                                                                                                        \
    float2 point = parameter.transform * float3(id[0], id[1], 1);                                                       \
                                                                                                                        \
    float t = axial_shading(point, start, end);                                                                         \
    gradient_mapping_##STARTMODE##_##ENDMODE(t, stops, numOfStops, out, idx);                                           \
}                                                                                                                       \
kernel void radial_gradient_##STARTMODE##_##ENDMODE(const device gradient_parameter &parameter [[buffer(0)]],           \
                                                    const device gradient_stop *stops [[buffer(1)]],                    \
                                                    device float *out [[buffer(2)]],                                    \
                                                    uint2 id [[thread_position_in_grid]],                               \
                                                    uint2 grid [[threads_per_grid]]) {                                  \
                                                                                                                        \
    const int idx = grid[0] * id[1] + id[0];                                                                            \
                                                                                                                        \
    int numOfStops = parameter.numOfStops;                                                                              \
    float2 start = parameter.start;                                                                                     \
    float2 end = parameter.end;                                                                                         \
    float2 radius = parameter.radius;                                                                                   \
                                                                                                                        \
    float2 point = parameter.transform * float3(id[0], id[1], 1);                                                       \
                                                                                                                        \
    float t = radial_shading(point, start, radius[0], end, radius[1], STARTSPREAD, ENDSPREAD);                          \
    gradient_mapping_##STARTMODE##_##ENDMODE(t, stops, numOfStops, out, idx);                                           \
}

GRADIENTKERNEL(none, none, false, false)
GRADIENTKERNEL(pad, none, true, false)
GRADIENTKERNEL(reflect, none, true, false)
GRADIENTKERNEL(repeat, none, true, false)

GRADIENTKERNEL(none, pad, false, true)
GRADIENTKERNEL(pad, pad, true, true)
GRADIENTKERNEL(reflect, pad, true, true)
GRADIENTKERNEL(repeat, pad, true, true)

GRADIENTKERNEL(none, reflect, false, true)
GRADIENTKERNEL(pad, reflect, true, true)
GRADIENTKERNEL(reflect, reflect, true, true)
GRADIENTKERNEL(repeat, reflect, true, true)

GRADIENTKERNEL(none, repeat, false, true)
GRADIENTKERNEL(pad, repeat, true, true)
GRADIENTKERNEL(reflect, repeat, true, true)
GRADIENTKERNEL(repeat, repeat, true, true)
