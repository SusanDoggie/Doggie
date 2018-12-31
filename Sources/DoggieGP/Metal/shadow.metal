//
//  shadow.metal
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

#define M_PI 3.1415926535897932384626433832795028841971693993751058

constant int countOfComponents [[function_constant(0)]];

struct shadow_parameter {
    
    const packed_float2 offset;
    const float blur;
    const float color[16];
};

const float _linear_interpolate_none_none(const device float *source, const float2 point, const int i, const uint2 size);

kernel void shadow(const device shadow_parameter &parameter [[buffer(0)]],
                   const device float *source [[buffer(1)]],
                   device float *destination [[buffer(2)]],
                   uint2 id [[thread_position_in_grid]],
                   uint2 grid [[threads_per_grid]]) {
    
    const uint2 size = grid;
    const int2 position = (int2)id;
    const int idx = grid.x * id.y + id.x;
    
    const float2 offset = parameter.offset;
    const float blur = 0.5 * parameter.blur;
    const float _blur = 2 * blur * blur;
    const int opacity_idx = countOfComponents - 1;
    
    const int s = ((int)ceil(6 * blur)) >> 1;
    
    float _shadow = 0;
    float sum = 0;
    
    for (int j = -s; j <= s; ++j) {
        for (int i = -s; i <= s; ++i) {
            
            const float2 point = float2((float)position.x + (float)i - offset.x, (float)position.y + (float)j - offset.y);
            const float d = length_squared(float2(i, j));
            const float k = exp(-d / _blur) / (M_PI * _blur);
            
            _shadow += _linear_interpolate_none_none(source, point, opacity_idx, size) * k;
            sum += k;
        }
    }
    
    for (int i = 0; i < opacity_idx; ++i) {
        destination[idx * countOfComponents + i] = parameter.color[i];
    }
    
    destination[idx * countOfComponents + opacity_idx] = parameter.color[opacity_idx] * _shadow / sum;
}
