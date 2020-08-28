//
//  SVGDisplacementMapKernel.metal
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

#define svg_displacement_map(XCHANNEL, YCHANNEL, XCHANNELSELECTOR, YCHANNELSELECTOR)                                \
kernel void svg_displacement_map_##XCHANNEL##YCHANNEL(texture2d<half, access::sample> source [[texture(0)]],        \
                                                      texture2d<half, access::read> displacement [[texture(1)]],    \
                                                      texture2d<half, access::write> output [[texture(2)]],         \
                                                      constant packed_float2 &scale [[buffer(3)]],                  \
                                                      uint2 gid [[thread_position_in_grid]]) {                      \
                                                                                                                    \
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }                                    \
                                                                                                                    \
    const half4 d = displacement.read(gid);                                                                         \
                                                                                                                    \
    const float _x = d[XCHANNELSELECTOR] - 0.5;                                                                     \
    const float _y = d[YCHANNELSELECTOR] - 0.5;                                                                     \
                                                                                                                    \
    const float x = (float)gid.x + _x * scale[0];                                                                   \
    const float y = (float)gid.y - _y * scale[1];                                                                   \
                                                                                                                    \
    constexpr sampler input_sampler (coord::pixel, address::clamp_to_zero, filter::linear);                         \
                                                                                                                    \
    const half4 color = source.sample(input_sampler, float2(x, y));                                                 \
                                                                                                                    \
    output.write(color, gid);                                                                                       \
}

svg_displacement_map(R, R, 0, 0)
svg_displacement_map(R, G, 0, 1)
svg_displacement_map(R, B, 0, 2)
svg_displacement_map(R, A, 0, 3)
svg_displacement_map(G, R, 1, 0)
svg_displacement_map(G, G, 1, 1)
svg_displacement_map(G, B, 1, 2)
svg_displacement_map(G, A, 1, 3)
svg_displacement_map(B, R, 2, 0)
svg_displacement_map(B, G, 2, 1)
svg_displacement_map(B, B, 2, 2)
svg_displacement_map(B, A, 2, 3)
svg_displacement_map(A, R, 3, 0)
svg_displacement_map(A, G, 3, 1)
svg_displacement_map(A, B, 3, 2)
svg_displacement_map(A, A, 3, 3)
