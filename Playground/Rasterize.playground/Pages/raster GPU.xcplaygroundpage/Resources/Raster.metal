
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

int _winding(float2 position, constant RasterOp* operation, const int operation_count);

fragment half4 basic_fragment(float4 position [[position]],
                              constant RasterOp* operation [[ buffer(0) ]],
                              constant int& operation_count [[ buffer(1) ]]) {
    
    int winding = _winding(float2(position[0], position[1]), operation, operation_count);
    
    if ((winding & 1) == 1) {
        return half4(1);
    }
    
    return half4(0);
}

float3 _barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q);

float _cross(const float2 lhs, const float2 rhs);

void swap(thread packed_float2* a, thread packed_float2* b);
void sort(thread packed_float2& a, thread packed_float2& b, thread packed_float2& c);

void swap(thread packed_float2* a, thread packed_float2* b) {
    
    packed_float2 temp = *a;
    *a = *b;
    *b = temp;
}
void sort(thread packed_float2& a, thread packed_float2& b, thread packed_float2& c) {
    if (b[1] < a[1]) { swap(&a, &b); }
    if (c[1] < b[1]) { swap(&b, &c); }
    if (b[1] < a[1]) { swap(&a, &b); }
}

bool inTriangle(float2 position, packed_float2 p0, packed_float2 p1, packed_float2 p2);

bool inTriangle(float2 position, packed_float2 p0, packed_float2 p1, packed_float2 p2) {
    
    packed_float2 q0 = p0, q1 = p1, q2 = p2;
    
    sort(q0, q1, q2);
    
    if (q0[1] < position[1] && position[1] < q2[1]) {
        
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

int _winding(float2 position, constant RasterOp* operation, const int operation_count) {
    
    int winding = 0;
    
    for (int i = 0; i < operation_count; ++i) {
        RasterOp op = operation[i];
        
        if (inTriangle(position, op.p0, op.p1, op.p2)) {
            
            float3 _b = _barycentric(op.p0, op.p1, op.p2, float2(position));
            
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
