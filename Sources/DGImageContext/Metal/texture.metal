//
//  texture.metal
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

struct Pixel {
    const device float *components;
    Pixel(const device float *components) : components(components) {};
};

struct Texture {
    const device float *buffer;
    uint2 size;
    Texture(const device float *buffer, uint2 size) : buffer(buffer), size(size) {};
    Pixel operator[](uint2 i) { return Pixel(buffer + (i[0] + i[1] * size[0]) * countOfComponents); };
};

struct MutablePixel {
    device float *components;
    MutablePixel(device float *components) : components(components) {};
};

struct MutableTexture {
    device float *buffer;
    uint2 size;
    MutableTexture(device float *buffer, uint2 size) : buffer(buffer), size(size) {};
    MutablePixel operator[](uint2 i) { return MutablePixel(buffer + (i[0] + i[1] * size[0]) * countOfComponents); };
};

float _multiply(float destination, float source) {
    return destination * source;
}

float _screen(float destination, float source) {
    return destination + source - destination * source;
}

float _overlay(float destination, float source) {
    
    if (destination < 0.5) {
        return 2 * destination * source;
    }
    float u = 1 - destination;
    float v = 1 - source;
    return 1 - 2 * u * v;
}

float _darken(float destination, float source) {
    return min(destination, source);
}

float _lighten(float destination, float source) {
    return max(destination, source);
}

float _colorDodge(float destination, float source) {
    return source < 1 ? min(1.0, destination / (1 - source)) : 1;
}

float _colorBurn(float destination, float source) {
    return source > 0 ? 1 - min(1.0, (1 - destination) / source) : 0;
}

float _softLight(float destination, float source) {
    
    float db;
    
    if (destination < 0.25) {
        float s = 16 * destination - 12;
        float t = s * destination + 4;
        db = t * destination;
    } else {
        db = sqrt(destination);
    }
    
    float u = 1 - 2 * source;
    
    if (source < 0.5) {
        return destination - u * destination * (1 - destination);
    }
    return destination - u * (db - destination);
}

float _hardLight(float destination, float source) {
    return _overlay(source, destination);
}

float _difference(float destination, float source) {
    return abs(destination - source);
}

float _exclusion(float destination, float source) {
    return destination + source - 2 * destination * source;
}

float _plusDarker(float destination, float source) {
    return max(0.0, 1 - ((1 - destination) + (1 - source)));
}

float _plusLighter(float destination, float source) {
    return min(1.0, destination + source);
}

float _copy(float source, float source_alpha, float destination, float destination_alpha) {
    return source;
}

float _sourceOver(float source, float source_alpha, float destination, float destination_alpha) {
    return source + destination * (1 - source_alpha);
}

float _sourceIn(float source, float source_alpha, float destination, float destination_alpha) {
    return source * destination_alpha;
}

float _sourceOut(float source, float source_alpha, float destination, float destination_alpha) {
    return source * (1 - destination_alpha);
}

float _sourceAtop(float source, float source_alpha, float destination, float destination_alpha) {
    return source * destination_alpha + destination * (1 - source_alpha);
}

float _destinationOver(float source, float source_alpha, float destination, float destination_alpha) {
    return source * (1 - destination_alpha) + destination;
}

float _destinationIn(float source, float source_alpha, float destination, float destination_alpha) {
    return destination * source_alpha;
}

float _destinationOut(float source, float source_alpha, float destination, float destination_alpha) {
    return destination * (1 - source_alpha);
}

float _destinationAtop(float source, float source_alpha, float destination, float destination_alpha) {
    return source * (1 - destination_alpha) + destination * source_alpha;
}

float _exclusiveOr(float source, float source_alpha, float destination, float destination_alpha) {
    float _s = source * (1 - destination_alpha);
    float _d = destination * (1 - source_alpha);
    return _s + _d;
}

#define BLEND_NORMAL_KERNEL(COMPOSITING) \
void _blend_##COMPOSITING##_normal(MutablePixel destination, Pixel source) {                                            \
                                                                                                                        \
    float d_alpha = destination.components[countOfComponents - 1];                                                      \
    float s_alpha = source.components[countOfComponents - 1];                                                           \
                                                                                                                        \
    float r_alpha = _##COMPOSITING(s_alpha, s_alpha, d_alpha, d_alpha);                                                 \
                                                                                                                        \
    if (r_alpha > 0) {                                                                                                  \
                                                                                                                        \
        float s = s_alpha / r_alpha;                                                                                    \
        float d = d_alpha / r_alpha;                                                                                    \
                                                                                                                        \
        for (int i = 0; i < countOfComponents - 1; ++i) {                                                               \
            float _source = source.components[i];                                                                       \
            float _destination = destination.components[i];                                                             \
            destination.components[i] = _##COMPOSITING(s * _source, s_alpha, d * _destination, d_alpha);                \
        }                                                                                                               \
                                                                                                                        \
        destination.components[countOfComponents - 1] = r_alpha;                                                        \
                                                                                                                        \
    } else {                                                                                                            \
        for (int i = 0; i < countOfComponents; ++i) {                                                                   \
            destination.components[i] = 0;                                                                              \
        }                                                                                                               \
    }                                                                                                                   \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_normal(const device float *source [[buffer(0)]],                                      \
                                         device float *destination [[buffer(1)]],                                       \
                                         uint2 id [[thread_position_in_grid]],                                          \
                                         uint2 grid [[threads_per_grid]]) {                                             \
                                                                                                                        \
    MutableTexture _destination = MutableTexture(destination, grid);                                                    \
    Texture _source = Texture(source, grid);                                                                            \
                                                                                                                        \
    _blend_##COMPOSITING##_normal(_destination[id], _source[id]);                                                       \
                                                                                                                        \
}

#define BLEND_KERNEL(COMPOSITING, BLENDING) \
void _blend_##COMPOSITING##_##BLENDING(MutablePixel destination, Pixel source) {                                        \
                                                                                                                        \
    float d_alpha = destination.components[countOfComponents - 1];                                                      \
    float s_alpha = source.components[countOfComponents - 1];                                                           \
                                                                                                                        \
    float r_alpha = _##COMPOSITING(s_alpha, s_alpha, d_alpha, d_alpha);                                                 \
                                                                                                                        \
    if (r_alpha > 0) {                                                                                                  \
                                                                                                                        \
        float s = s_alpha / r_alpha;                                                                                    \
        float d = d_alpha / r_alpha;                                                                                    \
                                                                                                                        \
        for (int i = 0; i < countOfComponents - 2; ++i) {                                                               \
            float _source = source.components[i];                                                                       \
            float _destination = destination.components[i];                                                             \
            float _blended = _##BLENDING(_destination, _source);                                                        \
            _blended = (1 - d_alpha) * _source + d_alpha * _blended;                                                    \
            destination.components[i] = _##COMPOSITING(s * _blended, s_alpha, d * _destination, d_alpha);               \
        }                                                                                                               \
                                                                                                                        \
        destination.components[countOfComponents - 1] = r_alpha;                                                        \
                                                                                                                        \
    } else {                                                                                                            \
        for (int i = 0; i < countOfComponents; ++i) {                                                                   \
            destination.components[i] = 0;                                                                              \
        }                                                                                                               \
    }                                                                                                                   \
}                                                                                                                       \
kernel void blend_##COMPOSITING##_##BLENDING(const device float *source [[buffer(0)]],                                  \
                                             device float *destination [[buffer(1)]],                                   \
                                             uint2 id [[thread_position_in_grid]],                                      \
                                             uint2 grid [[threads_per_grid]]) {                                         \
                                                                                                                        \
    MutableTexture _destination = MutableTexture(destination, grid);                                                    \
    Texture _source = Texture(source, grid);                                                                            \
                                                                                                                        \
    _blend_##COMPOSITING##_##BLENDING(_destination[id], _source[id]);                                                   \
                                                                                                                        \
}

BLEND_NORMAL_KERNEL(copy)
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
