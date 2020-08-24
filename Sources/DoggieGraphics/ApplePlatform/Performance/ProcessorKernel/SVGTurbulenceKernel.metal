//
//  SVGTurbulence.metal
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
#include <metal_math>
using namespace metal;

struct StitchInfo {
    
    int width;
    int height;
    int wrapX;
    int wrapY;
};

struct TurbulenceInfo {
    
    float3x2 transform;
    packed_float2 baseFreq;
    packed_float4 stitchTile;
    int numOctaves;
    int fractalSum;
    int isStitchTile;
    int padding;
    
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
             bool isStitchTile,
             StitchInfo stitch) {
    
    int bx0, bx1, by0, by1, b00, b10, b01, b11;
    float rx0, rx1, ry0, ry1, sx, sy, a, b, t, u, v;
    float2 q;
    
    t = point[0] + 4096;
    bx0 = (int)t;
    bx1 = bx0 + 1;
    rx0 = t - (int)t;
    rx1 = rx0 - 1.0;
    t = point[1] + 4096;
    by0 = (int)t;
    by1 = by0 + 1;
    ry0 = t - (int)t;
    ry1 = ry0 - 1.0;
    
    if (isStitchTile) {
        if (bx0 >= stitch.wrapX) {
            bx0 -= stitch.width;
        }
        if (bx1 >= stitch.wrapX) {
            bx1 -= stitch.width;
        }
        if (by0 >= stitch.wrapY) {
            by0 -= stitch.height;
        }
        if (by1 >= stitch.wrapY) {
            by1 -= stitch.height;
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
    
    StitchInfo stitch;
    
    if (info.isStitchTile) {
        
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
        
        stitch.width = info.stitchTile[2] * info.baseFreq[0] + 0.5;
        stitch.wrapX = (info.stitchTile[0] * info.baseFreq[0] + 4096 + (float)stitch.width);
        stitch.height = info.stitchTile[3] * info.baseFreq[1] + 0.5;
        stitch.wrapY = (info.stitchTile[1] * info.baseFreq[1] + 4096 + (float)stitch.height);
    }
    
    float fSum = 0.0;
    float ratio = 1.0;
    point[0] *= info.baseFreq[0];
    point[1] *= info.baseFreq[1];
    
    int BSize = 0x100;
    int _BSize = BSize + BSize + 2;
    
    fGradient += channel * _BSize;
    
    for (int i = 0; i < info.numOctaves; ++i) {
        
        if (info.fractalSum) {
            fSum += noise2(uLatticeSelector, fGradient, point, info.isStitchTile, stitch) / ratio;
        } else {
            fSum += fabs(noise2(uLatticeSelector, fGradient, point, info.isStitchTile, stitch)) / ratio;
        }
        
        point[0] *= 2;
        point[1] *= 2;
        ratio *= 2;
        
        if (info.isStitchTile) {
            stitch.width *= 2;
            stitch.wrapX = 2 * stitch.wrapX - 0x1000;
            stitch.height *= 2;
            stitch.wrapY = 2 * stitch.wrapY - 0x1000;
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
    float2 point = info.transform * float3(gid[0], gid[1], 1);
    
    if (info.fractalSum) {
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
