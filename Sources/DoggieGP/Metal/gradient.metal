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

void _set_opacity(const float opacity, device float *destination, const int idx);

struct gradient_stop {
    
    const float offset;
    const float color[16];
};

struct gradient_parameter {
    
    const float3x2 transform;
    const packed_float2 start;
    const packed_float2 end;
    const packed_float2 radius;
    const uint numOfStops;
};

const float axial_shading(const float2 point, const float2 start, const float2 end) {
    
    const float2 a = start - point;
    const float2 b = end - start;
    const float u = b.x * a.x + b.y * a.y;
    const float v = b.x * b.x + b.y * b.y;
    
    return -u / v;
}

const bool radial_shading_filter(const float t, const float r0, const float r1, const bool start_spread, const bool end_spread) {
    return r0 + t * r1 >= 0 && (t >= 0 || start_spread) && (t <= 1 || end_spread);
}

const float2 degree2roots(const float b, const float c) {
    if (b == 0) {
        if (c < 0) {
            const float _c = sqrt(-c);
            return float2(_c, -_c);
        } else if (c == 0) {
            return float2(0, 0);
        }
        return float2(NAN, NAN);
    }
    if (c == 0) {
        return float2(0, -b);
    }
    const float del = b * b - 4 * c;
    if (del == 0) {
        return float2(-0.5 * b);
    } else if (del > 0) {
        const float sqrt_del = sqrt(del);
        return float2(0.5 * (sqrt_del - b), 0.5 * (-sqrt_del - b));
    }
    return float2(NAN, NAN);
}

const float radial_shading(const float2 point, const float2 start, const float start_radius, const float2 end, const float end_radius, const bool start_spread, const bool end_spread) {
    
    const float2 p0 = point - start;
    const float2 p1 = start - end;
    const float r0 = start_radius;
    const float r1 = end_radius - start_radius;
    
    const float a = p1.x * p1.x + p1.y * p1.y - r1 * r1;
    const float b = 2 * (p0.x * p1.x + p0.y * p1.y - r0 * r1);
    const float c = p0.x * p0.x + p0.y * p0.y - r0 * r0;
    
    if (a == 0) {
        if (b != 0) {
            const float _t = -c / b;
            if (radial_shading_filter(_t, r0, r1, start_spread, end_spread)) {
                return _t;
            }
        }
    } else {
        
        const float2 t2 = degree2roots(b / a, c / a);
        
        if (t2.x == NAN) {
            return NAN;
        }
        
        const float _max = max(t2.x, t2.y);
        const float _min = min(t2.x, t2.y);
        
        if (_max != NAN && radial_shading_filter(_max, r0, r1, start_spread, end_spread)) {
            return _max;
        }
        if (_min != NAN && radial_shading_filter(_min, r0, r1, start_spread, end_spread)) {
            return _min;
        }
    }
    
    return NAN;
}

void _gradient_set_color(const device gradient_stop *stops, const int stop_idx, device float *destination, const int idx) {
    
    const int d_index = idx * countOfComponents;
    gradient_stop stop = stops[stop_idx];
    
    for(int i = 0; i < countOfComponents; ++i) {
        destination[d_index + i] = stop.color[i];
    }
}

void gradient_set_color(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    const int d_index = idx * countOfComponents;
    
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
            
            const float s = (t - lhs.offset) / (rhs.offset - lhs.offset);
            
            for(int i = 0; i < countOfComponents; ++i) {
                const float lhs_c = lhs.color[i];
                const float rhs_c = rhs.color[i];
                destination[d_index + i] = lhs_c * (1 - s) + rhs_c * s;
            }
            
            return;
        }
    }
    
    _gradient_set_color(stops, 0, destination, idx);
}

void _none_start_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    gradient_set_color(0, stops, numOfStops, destination, idx);
    _set_opacity(0, destination, idx);
}

void _pad_start_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    gradient_set_color(0, stops, numOfStops, destination, idx);
}

void _reflect_start_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    const int i = (int)trunc(t);
    const float s = t - (float)i;
    
    gradient_set_color((i & 1) == 0 ? -s : 1 + s, stops, numOfStops, destination, idx);
}

void _repeat_start_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    const int i = (int)trunc(t);
    const float s = t - (float)i;
    
    gradient_set_color(1 + s, stops, numOfStops, destination, idx);
}

void _none_end_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    gradient_set_color(1, stops, numOfStops, destination, idx);
    _set_opacity(0, destination, idx);
}

void _pad_end_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    gradient_set_color(1, stops, numOfStops, destination, idx);
}

void _reflect_end_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    const int i = (int)trunc(t);
    const float s = t - (float)i;
    
    gradient_set_color((i & 1) == 0 ? s : 1 - s, stops, numOfStops, destination, idx);
}

void _repeat_end_spread(const float t, const device gradient_stop *stops, const int numOfStops, device float *destination, const int idx) {
    
    const int i = (int)trunc(t);
    const float s = t - (float)i;
    
    gradient_set_color(s, stops, numOfStops, destination, idx);
}

#define GRADIENTKERNEL(STARTMODE, ENDMODE, STARTSPREAD, ENDSPREAD)                                                      \
void gradient_mapping_##STARTMODE##_##ENDMODE(const float t,                                                            \
                                              const device gradient_stop *stops,                                        \
                                              const int numOfStops,                                                     \
                                              device float *destination,                                                \
                                              const int idx) {                                                          \
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
                                                   device float *destination [[buffer(2)]],                             \
                                                   uint2 id [[thread_position_in_grid]],                                \
                                                   uint2 grid [[threads_per_grid]]) {                                   \
                                                                                                                        \
    const int idx = grid.x * id.y + id.x;                                                                               \
                                                                                                                        \
    const int numOfStops = parameter.numOfStops;                                                                        \
    const float2 start = parameter.start;                                                                               \
    const float2 end = parameter.end;                                                                                   \
                                                                                                                        \
    const float2 point = parameter.transform * float3(id.x, id.y, 1);                                                   \
                                                                                                                        \
    const float t = axial_shading(point, start, end);                                                                   \
    gradient_mapping_##STARTMODE##_##ENDMODE(t, stops, numOfStops, destination, idx);                                   \
}                                                                                                                       \
kernel void radial_gradient_##STARTMODE##_##ENDMODE(const device gradient_parameter &parameter [[buffer(0)]],           \
                                                    const device gradient_stop *stops [[buffer(1)]],                    \
                                                    device float *destination [[buffer(2)]],                            \
                                                    uint2 id [[thread_position_in_grid]],                               \
                                                    uint2 grid [[threads_per_grid]]) {                                  \
                                                                                                                        \
    const int idx = grid.x * id.y + id.x;                                                                               \
                                                                                                                        \
    const int numOfStops = parameter.numOfStops;                                                                        \
    const float2 start = parameter.start;                                                                               \
    const float2 end = parameter.end;                                                                                   \
    const float2 radius = parameter.radius;                                                                             \
                                                                                                                        \
    const float2 point = parameter.transform * float3(id.x, id.y, 1);                                                   \
                                                                                                                        \
    const float t = radial_shading(point, start, radius.x, end, radius.y, STARTSPREAD, ENDSPREAD);                      \
    gradient_mapping_##STARTMODE##_##ENDMODE(t, stops, numOfStops, destination, idx);                                   \
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
