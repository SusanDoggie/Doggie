//
//  SVGTurbulenceKernel.metal
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

#include <metal_stdlib>
using namespace metal;

constant bool IS_FRACTAL_NOISE [[function_constant(0)]];
constant bool IS_STITCH_TILE [[function_constant(1)]];
constant int NUM_OCTAVES [[function_constant(2)]];

struct TurbulenceInfo {
    
    float3x2 transform;
    packed_float2 baseFreq;
    packed_float4 stitchTile;
    
};

float s_curve(float t) {
    return t * t * (3.0 - 2.0 * t);
}

float lerp(float t, float a, float b) {
    return a + t * (b - a);
}

float noise2(constant int *uLatticeSelector,
             constant packed_float2 *fGradient,
             float2 point,
             int4 stitch) {
    
    int bx0, bx1, by0, by1, b00, b10, b01, b11;
    float rx0, rx1, ry0, ry1, sx, sy, a, b, t, u, v;
    float2 q;
    
    t = point.x + 4096;
    bx0 = (int)t;
    bx1 = bx0 + 1;
    rx0 = t - (int)t;
    rx1 = rx0 - 1.0;
    t = point.y + 4096;
    by0 = (int)t;
    by1 = by0 + 1;
    ry0 = t - (int)t;
    ry1 = ry0 - 1.0;
    
    if (IS_STITCH_TILE) {
        if (bx0 >= stitch[0]) {
            bx0 -= stitch[2];
        }
        if (bx1 >= stitch[0]) {
            bx1 -= stitch[2];
        }
        if (by0 >= stitch[1]) {
            by0 -= stitch[3];
        }
        if (by1 >= stitch[1]) {
            by1 -= stitch[3];
        }
    }
    
    bx0 &= 0xFF;
    bx1 &= 0xFF;
    by0 &= 0xFF;
    by1 &= 0xFF;
    
    int i = uLatticeSelector[bx0];
    int j = uLatticeSelector[bx1];
    b00 = uLatticeSelector[i + by0];
    b10 = uLatticeSelector[j + by0];
    b01 = uLatticeSelector[i + by1];
    b11 = uLatticeSelector[j + by1];
    sx = s_curve(rx0);
    sy = s_curve(ry0);
    
    q = fGradient[b00];
    u = rx0 * q[0] + ry0 * q[1];
    q = fGradient[b10];
    v = rx1 * q[0] + ry0 * q[1];
    a = lerp(sx, u, v);
    q = fGradient[b01];
    u = rx0 * q[0] + ry1 * q[1];
    q = fGradient[b11];
    v = rx1 * q[0] + ry1 * q[1];
    b = lerp(sx, u, v);
    
    return lerp(sy, a, b);
}

float _turbulence(constant int *uLatticeSelector,
                  constant packed_float2 *fGradient,
                  int channel,
                  float2 point,
                  TurbulenceInfo info) {
    
    int4 stitch;
    
    if (IS_STITCH_TILE) {
        
        if (info.baseFreq[0] != 0.0) {
            float fLoFreq = floor(info.stitchTile[2] * info.baseFreq[0]) / info.stitchTile[2];
            float fHiFreq = ceil(info.stitchTile[2] * info.baseFreq[0]) / info.stitchTile[2];
            if (info.baseFreq[0] / fLoFreq < fHiFreq / info.baseFreq[0]) {
                info.baseFreq[0] = fLoFreq;
            } else {
                info.baseFreq[0] = fHiFreq;
            }
        }
        if (info.baseFreq[1] != 0.0) {
            float fLoFreq = floor(info.stitchTile[3] * info.baseFreq[1]) / info.stitchTile[3];
            float fHiFreq = ceil(info.stitchTile[3] * info.baseFreq[1]) / info.stitchTile[3];
            if (info.baseFreq[1] / fLoFreq < fHiFreq / info.baseFreq[1]) {
                info.baseFreq[1] = fLoFreq;
            } else {
                info.baseFreq[1] = fHiFreq;
            }
        }
        
        stitch[2] = info.stitchTile[2] * info.baseFreq[0] + 0.5;
        stitch[0] = (info.stitchTile[0] * info.baseFreq[0] + 4096 + (float)stitch[2]);
        stitch[3] = info.stitchTile[3] * info.baseFreq[1] + 0.5;
        stitch[1] = (info.stitchTile[1] * info.baseFreq[1] + 4096 + (float)stitch[3]);
    }
    
    float fSum = 0.0;
    float ratio = 1.0;
    point.x *= info.baseFreq[0];
    point.y *= info.baseFreq[1];
    
    int BSize = 0x100;
    int _BSize = BSize + BSize + 2;
    
    fGradient += channel * _BSize;
    
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        
        if (IS_FRACTAL_NOISE) {
            fSum += noise2(uLatticeSelector, fGradient, point, stitch) / ratio;
        } else {
            fSum += fabs(noise2(uLatticeSelector, fGradient, point, stitch)) / ratio;
        }
        
        point.x *= 2;
        point.y *= 2;
        ratio *= 2;
        
        if (IS_STITCH_TILE) {
            stitch[2] *= 2;
            stitch[0] = 2 * stitch[0] - 0x1000;
            stitch[3] *= 2;
            stitch[1] = 2 * stitch[1] - 0x1000;
        }
    }
    
    return fSum;
}

kernel void svg_turbulence(constant int *uLatticeSelector [[buffer(0)]],
                           constant packed_float2 *fGradient [[buffer(1)]],
                           constant TurbulenceInfo &info [[buffer(2)]],
                           texture2d<float, access::write> output [[texture(3)]],
                           uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    float4 color;
    float2 point = info.transform * float3(gid.x, gid.y, 1);
    
    if (IS_FRACTAL_NOISE) {
        color[0] = _turbulence(uLatticeSelector, fGradient, 0, point, info) * 0.5 + 0.5;
        color[1] = _turbulence(uLatticeSelector, fGradient, 1, point, info) * 0.5 + 0.5;
        color[2] = _turbulence(uLatticeSelector, fGradient, 2, point, info) * 0.5 + 0.5;
        color[3] = _turbulence(uLatticeSelector, fGradient, 3, point, info) * 0.5 + 0.5;
    } else {
        color[0] = _turbulence(uLatticeSelector, fGradient, 0, point, info);
        color[1] = _turbulence(uLatticeSelector, fGradient, 1, point, info);
        color[2] = _turbulence(uLatticeSelector, fGradient, 2, point, info);
        color[3] = _turbulence(uLatticeSelector, fGradient, 3, point, info);
    }
    
    output.write(color, gid);
}
