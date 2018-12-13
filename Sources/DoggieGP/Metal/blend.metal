//
//  blend.metal
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

struct blend_parameter {
    
    const packed_uint2 offset;
    const uint width;
};

const float _multiply(const float destination, const float source) {
    return destination * source;
}

const float _screen(const float destination, const float source) {
    return destination + source - destination * source;
}

const float _overlay(const float destination, const float source) {
    
    if (destination < 0.5) {
        return 2 * destination * source;
    }
    float u = 1 - destination;
    float v = 1 - source;
    return 1 - 2 * u * v;
}

const float _darken(const float destination, const float source) {
    return min(destination, source);
}

const float _lighten(const float destination, const float source) {
    return max(destination, source);
}

const float _colorDodge(const float destination, const float source) {
    return source < 1 ? min(1.0, destination / (1 - source)) : 1;
}

const float _colorBurn(const float destination, const float source) {
    return source > 0 ? 1 - min(1.0, (1 - destination) / source) : 0;
}

const float _softLight(const float destination, const float source) {
    
    float db;
    
    if (destination < 0.25) {
        const float s = 16 * destination - 12;
        const float t = s * destination + 4;
        db = t * destination;
    } else {
        db = sqrt(destination);
    }
    
    const float u = 1 - 2 * source;
    
    if (source < 0.5) {
        return destination - u * destination * (1 - destination);
    }
    return destination - u * (db - destination);
}

const float _hardLight(const float destination, const float source) {
    return _overlay(source, destination);
}

const float _difference(const float destination, const float source) {
    return abs(destination - source);
}

const float _exclusion(const float destination, const float source) {
    return destination + source - 2 * destination * source;
}

const float _plusDarker(const float destination, const float source) {
    return max(0.0, 1 - ((1 - destination) + (1 - source)));
}

const float _plusLighter(const float destination, const float source) {
    return min(1.0, destination + source);
}

const float _copy(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source;
}

const float _sourceOver(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source + destination * (1 - source_alpha);
}

const float _sourceIn(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source * destination_alpha;
}

const float _sourceOut(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source * (1 - destination_alpha);
}

const float _sourceAtop(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source * destination_alpha + destination * (1 - source_alpha);
}

const float _destinationOver(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source * (1 - destination_alpha) + destination;
}

const float _destinationIn(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return destination * source_alpha;
}

const float _destinationOut(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return destination * (1 - source_alpha);
}

const float _destinationAtop(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    return source * (1 - destination_alpha) + destination * source_alpha;
}

const float _exclusiveOr(const float source, const float source_alpha, const float destination, const float destination_alpha) {
    const float _s = source * (1 - destination_alpha);
    const float _d = destination * (1 - source_alpha);
    return _s + _d;
}

void _blend_copy_normal(device float *destination, const device float *source, const int idx) {
    for (int i = 0; i < countOfComponents; ++i) {
        destination[idx + i] = source[idx + i];
    }
}
kernel void blend_copy_normal_clip(const device float *source [[buffer(0)]],
                                     device float *destination [[buffer(1)]],
                                     const device float *clip [[buffer(2)]],
                                     uint2 id [[thread_position_in_grid]],
                                     uint2 grid [[threads_per_grid]]) {
    
    const int idx = id.x + id.y * grid.x;
    const int _idx = idx * countOfComponents;
    
    if (!(clip[_idx + countOfComponents - 1] > 0)) { return; }
    
    _blend_copy_normal(destination, source, _idx);
}

#define BLEND_CLEAR_CLIP_KERNEL(BLENDING)                                                                               \
void _blend_clear_##BLENDING(device float *destination, const device float *source, const int idx) {                    \
    for (int i = 0; i < countOfComponents; ++i) {                                                                       \
        destination[idx + i] = 0;                                                                                       \
    }                                                                                                                   \
}                                                                                                                       \
kernel void blend_clear_##BLENDING##_clip(const device blend_parameter &parameter [[buffer(0)]],                        \
                                          const device float *source [[buffer(1)]],                                     \
                                          device float *destination [[buffer(2)]],                                      \
                                          const device float *clip [[buffer(3)]],                                       \
                                          uint2 id [[thread_position_in_grid]]) {                                       \
                                                                                                                        \
    const int width = parameter.width;                                                                                  \
    const int2 position = int2(id.x + parameter.offset[0], id.y + parameter.offset[1]);                                 \
    const int idx = width * position.y + position.x;                                                                    \
    const int _idx = idx * countOfComponents;                                                                           \
                                                                                                                        \
    if (!(clip[_idx + countOfComponents - 1] > 0)) { return; }                                                          \
                                                                                                                        \
    _blend_clear_##BLENDING(destination, source, _idx);                                                                 \
}

#define BLEND_NORMAL_KERNEL(COMPOSITING)                                                                                \
void _blend_##COMPOSITING##_normal(device float *destination, const device float *source, const int idx) {              \
                                                                                                                        \
    const float d_alpha = destination[idx + countOfComponents - 1];                                                     \
    const float s_alpha = source[idx + countOfComponents - 1];                                                          \
                                                                                                                        \
    const float r_alpha = _##COMPOSITING(s_alpha, s_alpha, d_alpha, d_alpha);                                           \
                                                                                                                        \
    if (r_alpha > 0) {                                                                                                  \
                                                                                                                        \
        const float s = s_alpha / r_alpha;                                                                              \
        const float d = d_alpha / r_alpha;                                                                              \
                                                                                                                        \
        for (int i = 0; i < countOfComponents - 1; ++i) {                                                               \
            const float _source = source[idx + i];                                                                      \
            const float _destination = destination[idx + i];                                                            \
            destination[idx + i] = _##COMPOSITING(s * _source, s_alpha, d * _destination, d_alpha);                     \
        }                                                                                                               \
                                                                                                                        \
        destination[idx + countOfComponents - 1] = r_alpha;                                                             \
                                                                                                                        \
    } else {                                                                                                            \
        for (int i = 0; i < countOfComponents; ++i) {                                                                   \
            destination[idx + i] = 0;                                                                                   \
        }                                                                                                               \
    }                                                                                                                   \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_normal(const device float *source [[buffer(0)]],                                      \
                                         device float *destination [[buffer(1)]],                                       \
                                         uint2 id [[thread_position_in_grid]],                                          \
                                         uint2 grid [[threads_per_grid]]) {                                             \
                                                                                                                        \
    const int idx = id.x + id.y * grid.x;                                                                               \
    _blend_##COMPOSITING##_normal(destination, source, idx * countOfComponents);                                        \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_normal_clip(const device blend_parameter &parameter [[buffer(0)]],                    \
                                              const device float *source [[buffer(1)]],                                 \
                                              device float *destination [[buffer(2)]],                                  \
                                              const device float *clip [[buffer(3)]],                                   \
                                              uint2 id [[thread_position_in_grid]]) {                                   \
                                                                                                                        \
    const int width = parameter.width;                                                                                  \
    const int2 position = int2(id.x + parameter.offset[0], id.y + parameter.offset[1]);                                 \
    const int idx = width * position.y + position.x;                                                                    \
    const int _idx = idx * countOfComponents;                                                                           \
                                                                                                                        \
    if (!(clip[_idx + countOfComponents - 1] > 0)) { return; }                                                          \
                                                                                                                        \
    _blend_##COMPOSITING##_normal(destination, source, _idx);                                                           \
}

#define BLEND_KERNEL(COMPOSITING, BLENDING)                                                                             \
void _blend_##COMPOSITING##_##BLENDING(device float *destination, const device float *source, const int idx) {          \
                                                                                                                        \
    const float d_alpha = destination[idx + countOfComponents - 1];                                                     \
    const float s_alpha = source[idx + countOfComponents - 1];                                                          \
                                                                                                                        \
    const float r_alpha = _##COMPOSITING(s_alpha, s_alpha, d_alpha, d_alpha);                                           \
                                                                                                                        \
    if (r_alpha > 0) {                                                                                                  \
                                                                                                                        \
        const float s = s_alpha / r_alpha;                                                                              \
        const float d = d_alpha / r_alpha;                                                                              \
                                                                                                                        \
        for (int i = 0; i < countOfComponents - 1; ++i) {                                                               \
            const float _source = source[idx + i];                                                                      \
            const float _destination = destination[idx + i];                                                            \
            const float _blended = (1 - d_alpha) * _source + d_alpha * _##BLENDING(_destination, _source);              \
            destination[idx + i] = _##COMPOSITING(s * _blended, s_alpha, d * _destination, d_alpha);                    \
        }                                                                                                               \
                                                                                                                        \
        destination[idx + countOfComponents - 1] = r_alpha;                                                             \
                                                                                                                        \
    } else {                                                                                                            \
        for (int i = 0; i < countOfComponents; ++i) {                                                                   \
            destination[idx + i] = 0;                                                                                   \
        }                                                                                                               \
    }                                                                                                                   \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_##BLENDING(const device float *source [[buffer(0)]],                                  \
                                             device float *destination [[buffer(1)]],                                   \
                                             uint2 id [[thread_position_in_grid]],                                      \
                                             uint2 grid [[threads_per_grid]]) {                                         \
                                                                                                                        \
    const int idx = id.x + id.y * grid.x;                                                                               \
    _blend_##COMPOSITING##_##BLENDING(destination, source, idx * countOfComponents);                                    \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_##BLENDING##_clip(const device blend_parameter &parameter [[buffer(0)]],              \
                                                    const device float *source [[buffer(1)]],                           \
                                                    device float *destination [[buffer(2)]],                            \
                                                    const device float *clip [[buffer(3)]],                             \
                                                    uint2 id [[thread_position_in_grid]]) {                             \
                                                                                                                        \
    const int width = parameter.width;                                                                                  \
    const int2 position = int2(id.x + parameter.offset[0], id.y + parameter.offset[1]);                                 \
    const int idx = width * position.y + position.x;                                                                    \
    const int _idx = idx * countOfComponents;                                                                           \
                                                                                                                        \
    if (!(clip[_idx + countOfComponents - 1] > 0)) { return; }                                                          \
                                                                                                                        \
    _blend_##COMPOSITING##_##BLENDING(destination, source, _idx);                                                       \
}

BLEND_CLEAR_CLIP_KERNEL(normal)
BLEND_CLEAR_CLIP_KERNEL(multiply)
BLEND_CLEAR_CLIP_KERNEL(screen)
BLEND_CLEAR_CLIP_KERNEL(overlay)
BLEND_CLEAR_CLIP_KERNEL(darken)
BLEND_CLEAR_CLIP_KERNEL(lighten)
BLEND_CLEAR_CLIP_KERNEL(colorDodge)
BLEND_CLEAR_CLIP_KERNEL(colorBurn)
BLEND_CLEAR_CLIP_KERNEL(softLight)
BLEND_CLEAR_CLIP_KERNEL(hardLight)
BLEND_CLEAR_CLIP_KERNEL(difference)
BLEND_CLEAR_CLIP_KERNEL(exclusion)
BLEND_CLEAR_CLIP_KERNEL(plusDarker)
BLEND_CLEAR_CLIP_KERNEL(plusLighter)

BLEND_NORMAL_KERNEL(sourceOver)
BLEND_NORMAL_KERNEL(sourceIn)
BLEND_NORMAL_KERNEL(sourceOut)
BLEND_NORMAL_KERNEL(sourceAtop)
BLEND_NORMAL_KERNEL(destinationOver)
BLEND_NORMAL_KERNEL(destinationIn)
BLEND_NORMAL_KERNEL(destinationOut)
BLEND_NORMAL_KERNEL(destinationAtop)
BLEND_NORMAL_KERNEL(exclusiveOr)

BLEND_KERNEL(copy, multiply)
BLEND_KERNEL(sourceOver, multiply)
BLEND_KERNEL(sourceIn, multiply)
BLEND_KERNEL(sourceOut, multiply)
BLEND_KERNEL(sourceAtop, multiply)
BLEND_KERNEL(destinationOver, multiply)
BLEND_KERNEL(destinationIn, multiply)
BLEND_KERNEL(destinationOut, multiply)
BLEND_KERNEL(destinationAtop, multiply)
BLEND_KERNEL(exclusiveOr, multiply)

BLEND_KERNEL(copy, screen)
BLEND_KERNEL(sourceOver, screen)
BLEND_KERNEL(sourceIn, screen)
BLEND_KERNEL(sourceOut, screen)
BLEND_KERNEL(sourceAtop, screen)
BLEND_KERNEL(destinationOver, screen)
BLEND_KERNEL(destinationIn, screen)
BLEND_KERNEL(destinationOut, screen)
BLEND_KERNEL(destinationAtop, screen)
BLEND_KERNEL(exclusiveOr, screen)

BLEND_KERNEL(copy, overlay)
BLEND_KERNEL(sourceOver, overlay)
BLEND_KERNEL(sourceIn, overlay)
BLEND_KERNEL(sourceOut, overlay)
BLEND_KERNEL(sourceAtop, overlay)
BLEND_KERNEL(destinationOver, overlay)
BLEND_KERNEL(destinationIn, overlay)
BLEND_KERNEL(destinationOut, overlay)
BLEND_KERNEL(destinationAtop, overlay)
BLEND_KERNEL(exclusiveOr, overlay)

BLEND_KERNEL(copy, darken)
BLEND_KERNEL(sourceOver, darken)
BLEND_KERNEL(sourceIn, darken)
BLEND_KERNEL(sourceOut, darken)
BLEND_KERNEL(sourceAtop, darken)
BLEND_KERNEL(destinationOver, darken)
BLEND_KERNEL(destinationIn, darken)
BLEND_KERNEL(destinationOut, darken)
BLEND_KERNEL(destinationAtop, darken)
BLEND_KERNEL(exclusiveOr, darken)

BLEND_KERNEL(copy, lighten)
BLEND_KERNEL(sourceOver, lighten)
BLEND_KERNEL(sourceIn, lighten)
BLEND_KERNEL(sourceOut, lighten)
BLEND_KERNEL(sourceAtop, lighten)
BLEND_KERNEL(destinationOver, lighten)
BLEND_KERNEL(destinationIn, lighten)
BLEND_KERNEL(destinationOut, lighten)
BLEND_KERNEL(destinationAtop, lighten)
BLEND_KERNEL(exclusiveOr, lighten)

BLEND_KERNEL(copy, colorDodge)
BLEND_KERNEL(sourceOver, colorDodge)
BLEND_KERNEL(sourceIn, colorDodge)
BLEND_KERNEL(sourceOut, colorDodge)
BLEND_KERNEL(sourceAtop, colorDodge)
BLEND_KERNEL(destinationOver, colorDodge)
BLEND_KERNEL(destinationIn, colorDodge)
BLEND_KERNEL(destinationOut, colorDodge)
BLEND_KERNEL(destinationAtop, colorDodge)
BLEND_KERNEL(exclusiveOr, colorDodge)

BLEND_KERNEL(copy, colorBurn)
BLEND_KERNEL(sourceOver, colorBurn)
BLEND_KERNEL(sourceIn, colorBurn)
BLEND_KERNEL(sourceOut, colorBurn)
BLEND_KERNEL(sourceAtop, colorBurn)
BLEND_KERNEL(destinationOver, colorBurn)
BLEND_KERNEL(destinationIn, colorBurn)
BLEND_KERNEL(destinationOut, colorBurn)
BLEND_KERNEL(destinationAtop, colorBurn)
BLEND_KERNEL(exclusiveOr, colorBurn)

BLEND_KERNEL(copy, softLight)
BLEND_KERNEL(sourceOver, softLight)
BLEND_KERNEL(sourceIn, softLight)
BLEND_KERNEL(sourceOut, softLight)
BLEND_KERNEL(sourceAtop, softLight)
BLEND_KERNEL(destinationOver, softLight)
BLEND_KERNEL(destinationIn, softLight)
BLEND_KERNEL(destinationOut, softLight)
BLEND_KERNEL(destinationAtop, softLight)
BLEND_KERNEL(exclusiveOr, softLight)

BLEND_KERNEL(copy, hardLight)
BLEND_KERNEL(sourceOver, hardLight)
BLEND_KERNEL(sourceIn, hardLight)
BLEND_KERNEL(sourceOut, hardLight)
BLEND_KERNEL(sourceAtop, hardLight)
BLEND_KERNEL(destinationOver, hardLight)
BLEND_KERNEL(destinationIn, hardLight)
BLEND_KERNEL(destinationOut, hardLight)
BLEND_KERNEL(destinationAtop, hardLight)
BLEND_KERNEL(exclusiveOr, hardLight)

BLEND_KERNEL(copy, difference)
BLEND_KERNEL(sourceOver, difference)
BLEND_KERNEL(sourceIn, difference)
BLEND_KERNEL(sourceOut, difference)
BLEND_KERNEL(sourceAtop, difference)
BLEND_KERNEL(destinationOver, difference)
BLEND_KERNEL(destinationIn, difference)
BLEND_KERNEL(destinationOut, difference)
BLEND_KERNEL(destinationAtop, difference)
BLEND_KERNEL(exclusiveOr, difference)

BLEND_KERNEL(copy, exclusion)
BLEND_KERNEL(sourceOver, exclusion)
BLEND_KERNEL(sourceIn, exclusion)
BLEND_KERNEL(sourceOut, exclusion)
BLEND_KERNEL(sourceAtop, exclusion)
BLEND_KERNEL(destinationOver, exclusion)
BLEND_KERNEL(destinationIn, exclusion)
BLEND_KERNEL(destinationOut, exclusion)
BLEND_KERNEL(destinationAtop, exclusion)
BLEND_KERNEL(exclusiveOr, exclusion)

BLEND_KERNEL(copy, plusDarker)
BLEND_KERNEL(sourceOver, plusDarker)
BLEND_KERNEL(sourceIn, plusDarker)
BLEND_KERNEL(sourceOut, plusDarker)
BLEND_KERNEL(sourceAtop, plusDarker)
BLEND_KERNEL(destinationOver, plusDarker)
BLEND_KERNEL(destinationIn, plusDarker)
BLEND_KERNEL(destinationOut, plusDarker)
BLEND_KERNEL(destinationAtop, plusDarker)
BLEND_KERNEL(exclusiveOr, plusDarker)

BLEND_KERNEL(copy, plusLighter)
BLEND_KERNEL(sourceOver, plusLighter)
BLEND_KERNEL(sourceIn, plusLighter)
BLEND_KERNEL(sourceOut, plusLighter)
BLEND_KERNEL(sourceAtop, plusLighter)
BLEND_KERNEL(destinationOver, plusLighter)
BLEND_KERNEL(destinationIn, plusLighter)
BLEND_KERNEL(destinationOut, plusLighter)
BLEND_KERNEL(destinationAtop, plusLighter)
BLEND_KERNEL(exclusiveOr, plusLighter)
