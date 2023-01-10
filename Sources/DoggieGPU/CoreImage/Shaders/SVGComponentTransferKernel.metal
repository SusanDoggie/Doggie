//
//  SVGComponentTransferKernel.metal
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

constant bool has_red_channel_table [[function_constant(0)]];
constant bool has_green_channel_table [[function_constant(1)]];
constant bool has_blue_channel_table [[function_constant(2)]];
constant bool has_alpha_channel_table [[function_constant(3)]];

constant bool is_red_channel_discrete [[function_constant(4)]];
constant bool is_green_channel_discrete [[function_constant(5)]];
constant bool is_blue_channel_discrete [[function_constant(6)]];
constant bool is_alpha_channel_discrete [[function_constant(7)]];

constant bool has_red_channel_gamma [[function_constant(8)]];
constant bool has_green_channel_gamma [[function_constant(9)]];
constant bool has_blue_channel_gamma [[function_constant(10)]];
constant bool has_alpha_channel_gamma [[function_constant(11)]];

float table_lookup(float c, int table_size, constant float *table) {
    
    const int n = table_size - 1;
    
    const float _c = clamp(c, 0.0, 1.0) * (float)n;
    const int k = (int)trunc(_c);
    
    if (k < n) {
        return mix(table[k], table[k + 1], fract(_c));
    } else {
        return table[n];
    }
}

float discrete_table_lookup(float c, int table_size, constant float *table) {
    
    const int n = table_size - 1;
    
    const float _c = clamp(c, 0.0, 1.0) * (float)n;
    const int k = (int)trunc(_c);
    
    if (k < n) {
        return table[k];
    } else {
        return table[n];
    }
}

float gamma_transfer(float c, float amplitude, float exponent, float offset) {
    return amplitude * pow(c, exponent) + offset;
}

kernel void svg_component_transfer(texture2d<float, access::read> input [[texture(0)]],
                                   texture2d<float, access::write> output [[texture(1)]],
                                   constant int &red_channel_table_size [[buffer(2), function_constant(has_red_channel_table)]],
                                   constant int &green_channel_table_size [[buffer(3), function_constant(has_green_channel_table)]],
                                   constant int &blue_channel_table_size [[buffer(4), function_constant(has_blue_channel_table)]],
                                   constant int &alpha_channel_table_size [[buffer(5), function_constant(has_alpha_channel_table)]],
                                   constant float *red_channel_table [[buffer(6), function_constant(has_red_channel_table)]],
                                   constant float *green_channel_table [[buffer(7), function_constant(has_green_channel_table)]],
                                   constant float *blue_channel_table [[buffer(8), function_constant(has_blue_channel_table)]],
                                   constant float *alpha_channel_table [[buffer(9), function_constant(has_alpha_channel_table)]],
                                   constant packed_float3 &red_channel_gamma [[buffer(2), function_constant(has_red_channel_gamma)]],
                                   constant packed_float3 &green_channel_gamma [[buffer(3), function_constant(has_green_channel_gamma)]],
                                   constant packed_float3 &blue_channel_gamma [[buffer(4), function_constant(has_blue_channel_gamma)]],
                                   constant packed_float3 &alpha_channel_gamma [[buffer(5), function_constant(has_alpha_channel_gamma)]],
                                   uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    float4 color = input.read(gid);
    
    if (has_red_channel_table) {
        if (is_red_channel_discrete) {
            color.r = discrete_table_lookup(color.r, red_channel_table_size, red_channel_table);
        } else {
            color.r = table_lookup(color.r, red_channel_table_size, red_channel_table);
        }
    } else if (has_red_channel_gamma) {
        color.r = gamma_transfer(color.r, red_channel_gamma[0], red_channel_gamma[1], red_channel_gamma[2]);
    }
    
    if (has_green_channel_table) {
        if (is_green_channel_discrete) {
            color.g = discrete_table_lookup(color.g, green_channel_table_size, green_channel_table);
        } else {
            color.g = table_lookup(color.g, green_channel_table_size, green_channel_table);
        }
    } else if (has_green_channel_gamma) {
        color.g = gamma_transfer(color.g, green_channel_gamma[0], green_channel_gamma[1], green_channel_gamma[2]);
    }
    
    if (has_blue_channel_table) {
        if (is_blue_channel_discrete) {
            color.b = discrete_table_lookup(color.b, blue_channel_table_size, blue_channel_table);
        } else {
            color.b = table_lookup(color.b, blue_channel_table_size, blue_channel_table);
        }
    } else if (has_blue_channel_gamma) {
        color.b = gamma_transfer(color.b, blue_channel_gamma[0], blue_channel_gamma[1], blue_channel_gamma[2]);
    }
    
    if (has_alpha_channel_table) {
        if (is_alpha_channel_discrete) {
            color.a = discrete_table_lookup(color.a, alpha_channel_table_size, alpha_channel_table);
        } else {
            color.a = table_lookup(color.a, alpha_channel_table_size, alpha_channel_table);
        }
    } else if (has_alpha_channel_gamma) {
        color.a = gamma_transfer(color.a, alpha_channel_gamma[0], alpha_channel_gamma[1], alpha_channel_gamma[2]);
    }
    
    output.write(color, gid);
}
