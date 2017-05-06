
#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
    
    return float4(vertex_array[vid], 1.0);
}

struct RasterOp {
    int type;
    packed_float2 p0, p1, p2;
    packed_float3 v0, v1, v2;
};

int _winding(float2 position, const device RasterOp* operation, const int operation_count);

fragment half4 basic_fragment(float4 position [[position]],
                              const device RasterOp* operation [[ buffer(0) ]],
                              const device int* operation_count [[ buffer(1) ]]) {
    
    int winding = _winding(float2(position[0], position[1]), operation, *operation_count);
    
    if ((winding & 1) == 1) {
        return half4(1);
    }
    
    return half4(0);
}

float3 _barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q);

float _cross(const float2 lhs, const float2 rhs);

int _winding(float2 position, const device RasterOp* operation, const int operation_count) {
    
    int winding = 0;
    
    for (int i = 0; i < operation_count; ++i) {
        RasterOp op = operation[i];
        
        float3 _b = _barycentric(op.p0, op.p1, op.p2, position);
        
        if (_b[0] > 0 && _b[0] < 1 && _b[1] > 0 && _b[1] < 1 && _b[2] > 0 && _b[2] < 1) {
            
            switch (op.type) {
                case 0: {
                    
                    float d = _cross(op.p1 - op.p0, op.p2 - op.p0);
                    winding += d < 0 ? -1 : 1;
                    
                    break;
                }
                case 1: {
                    float2 v = _b[0] * float2(0, 0) + _b[1] * float2(0.5, 0) + _b[2] * float2(1, 1);
                    
                    if (v[0] * v[0] - v[1] < 0) {
                        
                        float d = _cross(op.p1 - op.p0, op.p2 - op.p0);
                        winding += d < 0 ? -1 : 1;
                    }
                    break;
                }
                case 2: {
                    float3 v = _b[0] * op.v0 + _b[1] * op.v1 + _b[2] * op.v2;
                    
                    if (v[0] * v[0] * v[0] - v[1] * v[2] < 0) {
                        
                        float d = _cross(op.p1 - op.p0, op.p2 - op.p0);
                        winding += d < 0 ? -1 : 1;
                    }
                    break;
                }
                default: break;
            }
        }
    }
    
    return winding;
}

float3 _barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q) {
    
    float det = (p1[1] - p2[1]) * (p0[0] - p2[0]) + (p2[0] - p1[0]) * (p0[1] - p2[1]);
    
    float s = ((p1[1] - p2[1]) * (q[0] - p2[0]) + (p2[0] - p1[0]) * (q[1] - p2[1])) / det;
    float t = ((p2[1] - p0[1]) * (q[0] - p2[0]) + (p0[0] - p2[0]) * (q[1] - p2[1])) / det;
    
    return float3(s, t, 1 - s - t);
}

float _cross(const float2 lhs, const float2 rhs) {
    return lhs[0] * rhs[1] - lhs[1] * rhs[0];
}
