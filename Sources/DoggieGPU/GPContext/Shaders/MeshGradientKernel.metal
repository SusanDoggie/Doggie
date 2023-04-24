//
//  MeshGradientKernel.metal
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

#pragma mark Structs

struct DGMeshGradientColor {
    
    uchar4 c00 [[ attribute(0) ]];
    uchar4 c01 [[ attribute(1) ]];
    uchar4 c10 [[ attribute(2) ]];
    uchar4 c11 [[ attribute(3) ]];
    
};

struct DGMeshGradientControl {
    
    float2 position [[ attribute(4) ]];
    
};

struct DGMeshGradientTransform {
    
    float2 t0 [[ attribute(5) ]];
    float2 t1 [[ attribute(6) ]];
    float2 t2 [[ attribute(7) ]];
    
};

struct DGMeshGradientPatchIn {
    
    DGMeshGradientColor colors;
    patch_control_point<DGMeshGradientControl> controls;
    
    DGMeshGradientTransform transform;
    
};

struct DGMeshGradientFunctionOutIn {
    
    float4 position [[position]];
    half4  color;
    
};

#pragma mark Compute Kernels

kernel void mesh_gradient_tessellation_kernel_quad(constant float& edge_factor [[ buffer(0) ]],
                                                   constant float& inside_factor [[ buffer(1) ]],
                                                   constant int& count [[ buffer(2) ]],
                                                   device MTLQuadTessellationFactorsHalf* factors [[ buffer(3) ]],
                                                   uint pid [[ thread_position_in_grid ]]) {
    if ((int)pid >= count) { return; }
    factors[pid].edgeTessellationFactor[0] = edge_factor;
    factors[pid].edgeTessellationFactor[1] = edge_factor;
    factors[pid].edgeTessellationFactor[2] = edge_factor;
    factors[pid].edgeTessellationFactor[3] = edge_factor;
    factors[pid].insideTessellationFactor[0] = inside_factor;
    factors[pid].insideTessellationFactor[1] = inside_factor;
}

#pragma mark Post-Tessellation Vertex Functions

float2 cubic_bezier(float2 p0, float2 p1, float2 p2, float2 p3, float t) {
    const float t2 = t * t;
    const float _t = 1 - t;
    const float _t2 = _t * _t;
    const float2 a = _t * _t2 * p0;
    const float2 b = 3 * _t2 * t * p1;
    const float2 c = 3 * _t * t2 * p2;
    const float2 d = t * t2 * p3;
    return a + b + c + d;
}

[[ patch(quad, 16) ]]
vertex DGMeshGradientFunctionOutIn mesh_gradient_tessellation_vertex_quad(DGMeshGradientPatchIn patchIn [[ stage_in ]],
                                                                          float2 patchUV [[ position_in_patch ]]) {
    float u = patchUV.x;
    float v = patchUV.y;
    
    const float2 q0 = cubic_bezier(patchIn.controls[0].position, patchIn.controls[1].position, patchIn.controls[2].position, patchIn.controls[3].position, u);
    const float2 q1 = cubic_bezier(patchIn.controls[4].position, patchIn.controls[5].position, patchIn.controls[6].position, patchIn.controls[7].position, u);
    const float2 q2 = cubic_bezier(patchIn.controls[8].position, patchIn.controls[9].position, patchIn.controls[10].position, patchIn.controls[11].position, u);
    const float2 q3 = cubic_bezier(patchIn.controls[12].position, patchIn.controls[13].position, patchIn.controls[14].position, patchIn.controls[15].position, u);
    const float2 point = cubic_bezier(q0, q1, q2, q3, v);
    
    const half4 d0 = mix(((half4)patchIn.colors.c00) / 256, ((half4)patchIn.colors.c01) / 256, u);
    const half4 d1 = mix(((half4)patchIn.colors.c10) / 256, ((half4)patchIn.colors.c11) / 256, u);
    const half4 color = mix(d0, d1, v);
    
    const float3x2 transform = float3x2(patchIn.transform.t0, patchIn.transform.t1, patchIn.transform.t2);
    
    DGMeshGradientFunctionOutIn vertexOut;
    vertexOut.position = float4(transform * float3(point, 1) * 2 - 1, 0.0, 1.0);
    vertexOut.color = color;
    return vertexOut;
}

#pragma mark Fragment Function

fragment half4 mesh_gradient_tessellation_fragment(DGMeshGradientFunctionOutIn fragmentIn [[ stage_in ]]) {
    return fragmentIn.color;
}
