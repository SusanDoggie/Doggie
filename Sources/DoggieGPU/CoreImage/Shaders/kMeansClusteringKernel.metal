//
//  kMeansClusteringKernel.metal
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

kernel void k_means_clustering_row(texture2d<float, access::read> image [[texture(0)]],
                                   texture2d<float, access::read> palette [[texture(1)]],
                                   device float4 *table [[buffer(2)]],
                                   device int *counter [[buffer(3)]],
                                   uint gid [[thread_position_in_grid]]) {
    
    int palette_length = palette.get_width();
    
    if (gid >= image.get_height()) { return; }
    
    int width = image.get_width();
    
    device float4 *_table = table + gid * palette_length;
    device int *_counter = counter + gid * palette_length;
    
    for (int x = 0; x < width; ++x) {
        
        float4 color = image.read(uint2(x, gid));
        
        int i = 0;
        float d = 0;
        
        for (int j = 0; j < palette_length; ++j) {
            
            float _d = distance(color, palette.read(uint2(j, 0)));
            
            if (j == 0 || _d < d) {
                i = j;
                d = _d;
            }
        }
        
        _table[i] += color;
        _counter[i] += 1;
    }
}

kernel void k_means_clustering(constant float4 *table [[buffer(0)]],
                               constant int *counter [[buffer(1)]],
                               texture2d<float, access::write> palette [[texture(2)]],
                               constant int &table_size [[buffer(3)]],
                               uint gid [[thread_position_in_grid]]) {
    
    int palette_length = palette.get_width();
    
    if (gid >= (uint)palette_length) { return; }
    
    float4 color = 0;
    int count = 0;
    
    for (int i = 0; i < table_size; ++i) {
        
        int idx = i * palette_length + gid;
        if (counter[idx] > 0) {
            color += table[idx];
            count += counter[idx];
        }
    }
    
    if (count > 0) {
        palette.write(color / count, uint2(gid, 0));
    }
}
