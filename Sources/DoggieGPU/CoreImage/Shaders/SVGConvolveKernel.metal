//
//  SVGConvolveKernel.metal
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
using namespace metal;

constexpr sampler linear_sampler (coord::pixel, address::clamp_to_edge, filter::linear);

constant int ORDER_X [[function_constant(0)]];
constant int ORDER_Y [[function_constant(1)]];

half4 premultiply(half4 c) { return half4(c.rgb * c.a, c.a); }
half4 unpremultiply(half4 c) { return c.a == 0 ? c : half4(c.rgb / c.a, c.a); }

kernel void svg_convolve_none(texture2d<half, access::sample> color [[texture(0)]],
                              texture2d<half, access::write> output [[texture(2)]],
                              constant float *matrix [[buffer(3)]],
                              constant float &bias [[buffer(4)]],
                              constant packed_float2 &unit [[buffer(5)]],
                              uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    half4 sum = 0;
    
    for (int j = 0; j < ORDER_Y; ++j) {
        for (int i = 0; i < ORDER_X; ++i) {
            
            const int kx = ORDER_X - i - 1;
            const int ky = ORDER_Y - j - 1;
            
            const float offset_x = (float)i * unit[0];
            const float offset_y = (float)j * unit[1];
            
            const float2 coord = (float2)gid + float2(offset_x, offset_y);
            
            const half4 sample = color.sample(linear_sampler, coord);
            
            sum += sample * matrix[ky * ORDER_X + kx];
        }
    }
    
    const half _alpha = sum.a + bias;
    
    output.write(half4(sum.rgb + bias * _alpha, _alpha), gid);
}

kernel void svg_convolve_none_preserve_alpha(texture2d<half, access::sample> color [[texture(0)]],
                                             texture2d<half, access::write> output [[texture(2)]],
                                             constant float *matrix [[buffer(3)]],
                                             constant float &bias [[buffer(4)]],
                                             constant packed_float2 &unit [[buffer(5)]],
                                             constant packed_float2 &offset [[buffer(6)]],
                                             uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    half3 sum = 0;
    
    for (int j = 0; j < ORDER_Y; ++j) {
        for (int i = 0; i < ORDER_X; ++i) {
            
            const int kx = ORDER_X - i - 1;
            const int ky = ORDER_Y - j - 1;
            
            const float offset_x = (float)i * unit[0];
            const float offset_y = (float)j * unit[1];
            
            const float2 coord = (float2)gid + float2(offset_x, offset_y);
            
            const half4 sample = color.sample(linear_sampler, coord);
            
            sum += unpremultiply(sample).rgb * matrix[ky * ORDER_X + kx];
        }
    }
    
    const half _alpha = color.sample(linear_sampler, (float2)gid + offset).a;
    
    output.write(premultiply(half4(sum + bias, _alpha)), gid);
}

kernel void svg_convolve(texture2d<half, access::sample> color [[texture(0)]],
                         texture2d<half, access::sample> alpha [[texture(1)]],
                         texture2d<half, access::write> output [[texture(2)]],
                         constant float *matrix [[buffer(3)]],
                         constant float &bias [[buffer(4)]],
                         constant packed_float2 &unit [[buffer(5)]],
                         uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    half4 sum = 0;
    
    for (int j = 0; j < ORDER_Y; ++j) {
        for (int i = 0; i < ORDER_X; ++i) {
            
            const int kx = ORDER_X - i - 1;
            const int ky = ORDER_Y - j - 1;
            
            const float offset_x = (float)i * unit[0];
            const float offset_y = (float)j * unit[1];
            
            const float2 coord = (float2)gid + float2(offset_x, offset_y);
            
            const half4 sample = color.sample(linear_sampler, coord);
            const half4 _alpha = alpha.sample(linear_sampler, coord);
            
            sum += half4(sample.rgb, _alpha.a) * matrix[ky * ORDER_X + kx];
        }
    }
    
    const half _alpha = sum.a + bias;
    
    output.write(half4(sum.rgb + bias * _alpha, _alpha), gid);
}

kernel void svg_convolve_preserve_alpha(texture2d<half, access::sample> color [[texture(0)]],
                                        texture2d<half, access::read> alpha [[texture(1)]],
                                        texture2d<half, access::write> output [[texture(2)]],
                                        constant float *matrix [[buffer(3)]],
                                        constant float &bias [[buffer(4)]],
                                        constant packed_float2 &unit [[buffer(5)]],
                                        uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    half3 sum = 0;
    
    for (int j = 0; j < ORDER_Y; ++j) {
        for (int i = 0; i < ORDER_X; ++i) {
            
            const int kx = ORDER_X - i - 1;
            const int ky = ORDER_Y - j - 1;
            
            const float offset_x = (float)i * unit[0];
            const float offset_y = (float)j * unit[1];
            
            const float2 coord = (float2)gid + float2(offset_x, offset_y);
            
            const half4 sample = color.sample(linear_sampler, coord);
            
            sum += unpremultiply(sample).rgb * matrix[ky * ORDER_X + kx];
        }
    }
    
    const half _alpha = alpha.read(gid).a;
    
    output.write(premultiply(half4(sum + bias, _alpha)), gid);
}
