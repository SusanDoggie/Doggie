//
//  maths.metal
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

float cross(float2 a, float2 b) {
    return a[0] * b[1] - a[1] * b[0];
}

float3 Barycentric(float2 p0, float2 p1, float2 p2, float2 q) {
    
    float det = (p1[1] - p2[1]) * (p0[0] - p2[0]) + (p2[0] - p1[0]) * (p0[1] - p2[1]);
    
    float s = ((p1[1] - p2[1]) * (q[0] - p2[0]) + (p2[0] - p1[0]) * (q[1] - p2[1])) / det;
    float t = ((p2[1] - p0[1]) * (q[0] - p2[0]) + (p0[0] - p2[0]) * (q[1] - p2[1])) / det;
    
    return float3(s, t, 1 - s - t);
}

void swap(thread float2 *a, thread float2 *b) {
    float2 temp = *a;
    *a = *b;
    *b = temp;
}

void sort(thread float2 *a, thread float2 *b, thread float2 *c) {
    if ((*b)[1] < (*a)[1]) { swap(a, b); }
    if ((*c)[1] < (*b)[1]) { swap(b, c); }
    if ((*b)[1] < (*a)[1]) { swap(a, b); }
}

bool inTriangle(float2 p0, float2 p1, float2 p2, float2 position) {
    
    float2 q0 = p0;
    float2 q1 = p1;
    float2 q2 = p2;
    
    sort(&q0, &q1, &q2);
    
    if (q0[1] <= position[1] && position[1] < q2[1]) {
        
        float t1 = (position[1] - q0[1]) / (q2[1] - q0[1]);
        float x1 = q0[0] + t1 * (q2[0] - q0[0]);
        
        float t2;
        float x2;
        
        if (position[1] < q1[1]) {
            t2 = (position[1] - q0[1]) / (q1[1] - q0[1]);
            x2 = q0[0] + t2 * (q1[0] - q0[0]);
        } else {
            t2 = (position[1] - q1[1]) / (q2[1] - q1[1]);
            x2 = q1[0] + t2 * (q2[0] - q1[0]);
        }
        
        float mid_t = (q1[1] - q0[1]) / (q2[1] - q0[1]);
        float mid_x = q0[0] + mid_t * (q2[0] - q0[0]);
        
        if (mid_x < q1[0]) {
            return x1 <= position[0] && position[0] < x2;
        } else {
            return x2 <= position[0] && position[0] < x1;
        }
    }
    
    return false;
}
