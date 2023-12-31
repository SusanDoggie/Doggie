//
//  BilateralFilter.metal
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

kernel void bilateral_filter(texture2d<float, access::read> input [[texture(0)]],
                             texture2d<float, access::write> output [[texture(1)]],
                             constant packed_uint2 &offset [[buffer(2)]],
                             constant float *weight_x [[buffer(3)]],
                             constant float *weight_y [[buffer(4)]],
                             constant float &range [[buffer(5)]],
                             uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const int orderX = input.get_width() - output.get_width();
    const int orderY = input.get_height() - output.get_height();
    
    const float c2 = -0.5 / (range * range);
    
    float4 s = 0;
    float t = 0;
    
    const float4 p = input.read(gid + offset);
    
    for (int y = 0; y < orderY; ++y) {
        for (int x = 0; x < orderX; ++x) {
            
            const float4 k = input.read(gid + uint2(x, y));
            const float w = weight_x[x] * weight_y[y] * exp(c2 * distance_squared(p, k));
            
            s += w * k;
            t += w;
        }
    }
    
    output.write(s / t, gid);
}
