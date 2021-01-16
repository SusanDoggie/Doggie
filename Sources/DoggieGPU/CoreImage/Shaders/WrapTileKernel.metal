//
//  WrapTileKernel.metal
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

constexpr sampler linear_sampler (address::repeat, filter::linear);

kernel void wrap_tile(texture2d<float, access::sample> input [[texture(0)]],
                      texture2d<float, access::write> output [[texture(1)]],
                      constant packed_float2 &offset [[buffer(2)]],
                      uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    float2 coord = (float2)gid + offset;
    coord.x /= (float)input.get_width();
    coord.y /= (float)input.get_height();
    
    const float4 color = input.sample(linear_sampler, coord);
    
    output.write(color, gid);
}
