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

enum ColorBlendMode : uint8_t {
    
    normal, /* B(cb, cs) = cs */
    
    multiply, /* B(cb, cs) = cb * cs */
    
    screen, /* B(cb, cs) = cb + cs – cb * cs */
    
    overlay, /* B(cb, cs) = cs < 0.5 ? 2 * cb * cs : 1 - 2 * (1 - cb) * (1 - cs) */
    
    darken, /* B(cb, cs) = min(cb, cs) */
    
    lighten, /* B(cb, cs) = max(cb, cs) */
    
    colorDodge, /* B(cb, cs) = cs < 1 ? min(1, cb / (1 – cs)) : 1 */
    
    colorBurn, /* B(cb, cs) = cs > 0 ? 1 – min(1, (1 – cb) / cs) : 0 */
    
    softLight, /* B(cb, cs) = cs < 0.5 ? cb – (1 – 2 * cs) * cb * (1 – cb) : cb + (2 * cs – 1) * (D(cb) – cb) where D(x) = x < 0.25 ? ((16 * x – 12) * x + 4) * x : sqrt(x) */
    
    hardLight, /* B(cb, cs) = Overlay(cs, cb) */
    
    difference, /* B(cb, cs) = abs(cb – cs) */
    
    exclusion, /* B(cb, cs) = cb + cs – 2 * cb * cs */
    
    plusDarker, /* B(cb, cs) = max(0, 1 - ((1 - cb) + (1 - cs))) */
    
    plusLighter /* B(cb, cs) = min(1, cb + cs) */
};

enum ColorCompositingMode : uint8_t {
    
    clear, /* R = 0 */
    
    copy, /* R = S */
    
    sourceOver, /* R = S + D * (1 - Sa) */
    
    sourceIn, /* R = S * Da */
    
    sourceOut, /* R = S * (1 - Da) */
    
    sourceAtop, /* R = S * Da + D * (1 - Sa) */
    
    destinationOver, /* R = S * (1 - Da) + D */
    
    destinationIn, /* R = D * Sa */
    
    destinationOut, /* R = D * (1 - Sa) */
    
    destinationAtop, /* R = S * (1 - Da) + D * Sa */
    
    exclusiveOr /* R = S * (1 - Da) + D * (1 - Sa) */
    
};

float Multiply(float destination, float source) {
    return destination * source;
}

float Screen(float destination, float source) {
    return destination + source - destination * source;
}

float Overlay(float destination, float source) {
    
    if (destination < 0.5) {
        return 2 * destination * source;
    }
    float u = 1 - destination;
    float v = 1 - source;
    return 1 - 2 * u * v;
}

float Darken(float destination, float source) {
    return min(destination, source);
}

float Lighten(float destination, float source) {
    return max(destination, source);
}

float ColorDodge(float destination, float source) {
    return source < 1 ? min(1.0, destination / (1 - source)) : 1;
}

float ColorBurn(float destination, float source) {
    return source > 0 ? 1 - min(1.0, (1 - destination) / source) : 0;
}

float SoftLight(float destination, float source) {
    
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

float HardLight(float destination, float source) {
    return Overlay(source, destination);
}

float Difference(float destination, float source) {
    return abs(destination - source);
}

float Exclusion(float destination, float source) {
    return destination + source - 2 * destination * source;
}

float PlusDarker(float destination, float source) {
    return max(0.0, 1 - ((1 - destination) + (1 - source)));
}

float PlusLighter(float destination, float source) {
    return min(1.0, destination + source);
}

template<int N>
struct Pixel {
    
    float components[N + 1];
    
public:
    
    Pixel() {};
    
    const float getOpacity() const;
    void setOpacity(float opacity);
    
    Pixel blended(Pixel source, ColorCompositingMode compositingMode, ColorBlendMode blendMode) const;
};

template<int N>
const float Pixel<N>::getOpacity() const {
    return components[N];
}

template<int N>
void Pixel<N>::setOpacity(float opacity) {
    components[N] = opacity;
}

float _blending(float source, float destination, ColorBlendMode blendMode) {
    
    switch (blendMode) {
        case normal: return source;
        case multiply: return Multiply(destination, source);
        case screen: return Screen(destination, source);
        case overlay: return Overlay(destination, source);
        case darken: return Darken(destination, source);
        case lighten: return Lighten(destination, source);
        case colorDodge: return ColorDodge(destination, source);
        case colorBurn: return ColorBurn(destination, source);
        case softLight: return SoftLight(destination, source);
        case hardLight: return HardLight(destination, source);
        case difference: return Difference(destination, source);
        case exclusion: return Exclusion(destination, source);
        case plusDarker: return PlusDarker(destination, source);
        case plusLighter: return PlusLighter(destination, source);
    }
}

float _compositing(ColorCompositingMode mode, float source, float source_alpha, float destination, float destination_alpha) {
    
    switch (mode) {
        case clear: return 0;
        case copy: return source;
        case sourceOver: return source + destination * (1 - source_alpha);
        case sourceIn: return source * destination_alpha;
        case sourceOut: return source * (1 - destination_alpha);
        case sourceAtop: return source * destination_alpha + destination * (1 - source_alpha);
        case destinationOver: return source * (1 - destination_alpha) + destination;
        case destinationIn: return destination * source_alpha;
        case destinationOut: return destination * (1 - source_alpha);
        case destinationAtop: return source * (1 - destination_alpha) + destination * source_alpha;
        case exclusiveOr:
            float _s = source * (1 - destination_alpha);
            float _d = destination * (1 - source_alpha);
            return _s + _d;
    }
}

template<int N>
Pixel<N> Pixel<N>::blended(Pixel<N> source, ColorCompositingMode compositingMode, ColorBlendMode blendMode) const {
    
    float d_alpha = this->getOpacity();
    float s_alpha = source.getOpacity();
    
    float r_alpha = _compositing(compositingMode, s_alpha, s_alpha, d_alpha, d_alpha);
    
    if (r_alpha > 0) {
        
        float s = s_alpha / r_alpha;
        float d = d_alpha / r_alpha;
        
        auto blended = *this;
        
        for (int i = 0; i < N; ++i) {
            float _source = source.components[i];
            float _destination = this->components[i];
            float _blended = _blending(_source, _destination, blendMode);
            _blended = (1 - d_alpha) * _source + d_alpha * _blended;
            blended.components[i] = _compositing(compositingMode, s * _blended, s_alpha, d * _destination, d_alpha);
        }
        
        blended.setOpacity(r_alpha);
        return blended;
        
    } else {
        return Pixel();
    }
}

constant int countOfComponents [[function_constant(0)]];
constant uint8_t compositing_mode [[function_constant(1)]];
constant uint8_t blending_mode [[function_constant(2)]];

template<int N>
void __blend(const device float *source, int s_idx, float opacity,
             device float *destination, int d_idx) {
    
    Pixel<N> _source = ((const device Pixel<N>*)source)[s_idx];
    Pixel<N> _destination = ((const device Pixel<N>*)destination)[d_idx];
    auto _out = (device Pixel<N>*)destination;
    
    _source.setOpacity(_source.getOpacity() * opacity);
    _out[d_idx] = _destination.blended(_source, (ColorCompositingMode)compositing_mode, (ColorBlendMode)blending_mode);
}

void _blend(const device float *source, int s_idx, float opacity,
            device float *destination, int d_idx) {
    
    switch (countOfComponents) {
        case 2:
            __blend<1>(source, s_idx, opacity, destination, d_idx);
            break;
        case 3:
            __blend<2>(source, s_idx, opacity, destination, d_idx);
            break;
        case 4:
            __blend<3>(source, s_idx, opacity, destination, d_idx);
            break;
        case 5:
            __blend<4>(source, s_idx, opacity, destination, d_idx);
            break;
        case 6:
            __blend<5>(source, s_idx, opacity, destination, d_idx);
            break;
        case 7:
            __blend<6>(source, s_idx, opacity, destination, d_idx);
            break;
        case 8:
            __blend<7>(source, s_idx, opacity, destination, d_idx);
            break;
        case 9:
            __blend<8>(source, s_idx, opacity, destination, d_idx);
            break;
        case 10:
            __blend<9>(source, s_idx, opacity, destination, d_idx);
            break;
        case 11:
            __blend<10>(source, s_idx, opacity, destination, d_idx);
            break;
        case 12:
            __blend<11>(source, s_idx, opacity, destination, d_idx);
            break;
        case 13:
            __blend<12>(source, s_idx, opacity, destination, d_idx);
            break;
        case 14:
            __blend<13>(source, s_idx, opacity, destination, d_idx);
            break;
        case 15:
            __blend<14>(source, s_idx, opacity, destination, d_idx);
            break;
        case 16:
            __blend<15>(source, s_idx, opacity, destination, d_idx);
            break;
    }
}

kernel void blend(const device float *source [[buffer(0)]],
                  device float *destination [[buffer(1)]],
                  uint2 id [[thread_position_in_grid]],
                  uint2 grid [[threads_per_grid]]) {
    
    const int idx = grid[0] * id[1] + id[0];
    _blend(source, idx, 1, destination, idx);
}
