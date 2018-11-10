//
//  fill_stencil.metal
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

struct fill_stencil_parameter {
    
    const packed_uint2 offset;
    const uint width;
    const uint antialias;
    const float color[16];
};

kernel void fill_nonZero_stencil(const device fill_stencil_parameter &parameter [[buffer(0)]],
                                 const device int16_t *stencil [[buffer(1)]],
                                 device float *destination [[buffer(2)]],
                                 uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id.x + parameter.offset[0], id.y + parameter.offset[1]);
    const int idx = width * position.y + position.x;
    const int opacity_idx = countOfComponents - 1;
    
    const int stencil_width = width * antialias;
    const int2 stencil_position = position * antialias;
    
    int counter = 0;
    
    for (int i = 0; i < antialias; ++i) {
        for (int j = 0; j < antialias; ++j) {
            
            int stencil_index = stencil_width * (stencil_position.y + i) + (stencil_position.x + j);
            
            if (stencil[stencil_index] != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < opacity_idx; ++i) {
        destination[idx * countOfComponents + i] = parameter.color[i];
    }
    
    destination[idx * countOfComponents + opacity_idx] = parameter.color[opacity_idx] * (float)counter / (float)(antialias * antialias);
}

kernel void fill_evenOdd_stencil(const device fill_stencil_parameter &parameter [[buffer(0)]],
                                 const device int16_t *stencil [[buffer(1)]],
                                 device float *destination [[buffer(2)]],
                                 uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id.x + parameter.offset[0], id.y + parameter.offset[1]);
    const int idx = width * position.y + position.x;
    const int opacity_idx = countOfComponents - 1;
    
    const int stencil_width = width * antialias;
    const int2 stencil_position = position * antialias;
    
    int counter = 0;
    
    for (int i = 0; i < antialias; ++i) {
        for (int j = 0; j < antialias; ++j) {
            
            int stencil_index = stencil_width * (stencil_position.y + i) + (stencil_position.x + j);
            
            if ((stencil[stencil_index] & 1) != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < opacity_idx; ++i) {
        destination[idx * countOfComponents + i] = parameter.color[i];
    }
    
    destination[idx * countOfComponents + opacity_idx] = parameter.color[opacity_idx] * (float)counter / (float)(antialias * antialias);
}
