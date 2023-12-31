//
//  SVGLightingKernel.metal
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

constexpr sampler linear_sampler (coord::pixel, address::clamp_to_edge, filter::linear);

kernel void svg_normal_map(texture2d<float, access::sample> input [[texture(0)]],
                           texture2d<float, access::write> output [[texture(1)]],
                           constant packed_float2 &offset [[buffer(2)]],
                           constant packed_float2 &unit [[buffer(3)]],
                           uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float2 coord = (float2)gid + offset;
    
    const float2 offset_0 = float2(-unit[0], unit[1]);
    const float2 offset_1 = float2(-unit[0], 0);
    const float2 offset_2 = float2(-unit[0], -unit[1]);
    const float2 offset_3 = float2(0, unit[1]);
    const float2 offset_5 = float2(0, -unit[1]);
    const float2 offset_6 = float2(unit[0], unit[1]);
    const float2 offset_7 = float2(unit[0], 0);
    const float2 offset_8 = float2(unit[0], -unit[1]);
    
    float norm_x = -input.sample(linear_sampler, coord + offset_0).a;
    norm_x -= input.sample(linear_sampler, coord + offset_3).a * 2;
    norm_x -= input.sample(linear_sampler, coord + offset_6).a;
    norm_x += input.sample(linear_sampler, coord + offset_2).a;
    norm_x += input.sample(linear_sampler, coord + offset_5).a * 2;
    norm_x += input.sample(linear_sampler, coord + offset_8).a;
    
    float norm_y = -input.sample(linear_sampler, coord + offset_0).a;
    norm_y -= input.sample(linear_sampler, coord + offset_1).a * 2;
    norm_y -= input.sample(linear_sampler, coord + offset_2).a;
    norm_y += input.sample(linear_sampler, coord + offset_6).a;
    norm_y += input.sample(linear_sampler, coord + offset_7).a * 2;
    norm_y += input.sample(linear_sampler, coord + offset_8).a;
    
    const float4 color = float4(norm_x, norm_y, input.sample(linear_sampler, coord).a, 1);
    
    output.write(color, gid);
}

struct DiffuseLightInfo {
    
    packed_float4 color;
    float unit_scale;
    
    float4 lighting(float4 source, float4 color, float3 norm, float3 light) const {
        
        const float diffuse = dot(norm, light);
        
        return float4(source.rgb + diffuse * color.rgb, 1);
    }
};

struct SpecularLightInfo {
    
    packed_float4 color;
    float unit_scale;
    float specularExponent;
    
    float4 lighting(float4 source, float4 color, float3 norm, float3 light) const {
        
        const float3 E = float3(0, 0, 1);
        const float3 H = normalize(light + E);
        
        const float3 _color = pow(dot(norm, H), specularExponent) * color.rgb;
        
#if defined(__HAVE_MAX3__)
        return source + float4(_color, max3(_color.x, _color.y, _color.x));
#else
        return source + float4(_color, max(_color.x, max(_color.y, _color.x)));
#endif
    }
};

struct DistantLightSourceInfo {
    
    float azimuth;
    float elevation;
    
    float3 light(float4 color, float4 norm_map, float2 coord) const {
        return float3(float2(cos(azimuth), sin(azimuth)) * cos(elevation), sin(elevation));
    }
    
    float4 color(float4 color, float3 light) const {
        return color;
    }
    
};

struct PointLightSourceInfo {
    
    packed_float3 position;
    
    float3 light(float4 color, float4 norm_map, float2 coord) const {
        return normalize(position - float3(coord, color.a * norm_map.z));
    }
    
    float4 color(float4 color, float3 light) const {
        return color;
    }
    
};

struct SpotLightSourceInfo {
    
    packed_float3 position;
    packed_float3 direction;
    float specularExponent;
    float limitingConeAngle;
    
    float3 light(float4 color, float4 norm_map, float2 coord) const {
        return normalize(position - float3(coord, color.a * norm_map.z));
    }
    
    float4 color(float4 color, float3 light) const {
        
        const float ls = -dot(light, normalize(direction));
        
        const float limit = max(0.0, cos(limitingConeAngle));
        if (ls > limit) {
            const float power = pow(ls, specularExponent);
            const float blur = min(1.0, (ls - limit) / 0.01);
            color.rgb *= power * blur;
        } else {
            color.rgb = 0;
        }
        
        return color;
    }
    
};

template <typename L, typename S>
float4 svg_lighting(float4 norm_map,
                    float4 source,
                    const L lighting_info,
                    const S light_source_info,
                    uint2 gid) {
    
    const float2 coord = lighting_info.unit_scale * (float2)gid;
    
    const float4 light_color = lighting_info.color;
    
    const float3 norm = normalize(float3(-light_color.a * (float2)norm_map.xy, 1));
    const float3 light = light_source_info.light(light_color, norm_map, coord);
    
    const float4 color = light_source_info.color(light_color, light);
    
    return lighting_info.lighting(source, color, norm, light);
}

kernel void svg_diffuse_distant_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                      texture2d<float, access::write> output [[texture(1)]],
                                      constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                      constant DistantLightSourceInfo &light_source_info [[buffer(3)]],
                                      uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_point_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<float, access::write> output [[texture(1)]],
                                    constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                    constant PointLightSourceInfo &light_source_info [[buffer(3)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_spot_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                   texture2d<float, access::write> output [[texture(1)]],
                                   constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                   constant SpotLightSourceInfo &light_source_info [[buffer(3)]],
                                   uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_specular_distant_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                       texture2d<float, access::write> output [[texture(1)]],
                                       constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                       constant DistantLightSourceInfo &light_source_info [[buffer(3)]],
                                       uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_point_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<float, access::write> output [[texture(1)]],
                                     constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                     constant PointLightSourceInfo &light_source_info [[buffer(3)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_spot_light(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<float, access::write> output [[texture(1)]],
                                    constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                    constant SpotLightSourceInfo &light_source_info [[buffer(3)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_diffuse_distant_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                       texture2d<float, access::read> input [[texture(1)]],
                                       texture2d<float, access::write> output [[texture(2)]],
                                       constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                       constant DistantLightSourceInfo &light_source_info [[buffer(4)]],
                                       uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_point_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<float, access::read> input [[texture(1)]],
                                     texture2d<float, access::write> output [[texture(2)]],
                                     constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                     constant PointLightSourceInfo &light_source_info [[buffer(4)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_spot_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<float, access::read> input [[texture(1)]],
                                    texture2d<float, access::write> output [[texture(2)]],
                                    constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                    constant SpotLightSourceInfo &light_source_info [[buffer(4)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_specular_distant_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                        texture2d<float, access::read> input [[texture(1)]],
                                        texture2d<float, access::write> output [[texture(2)]],
                                        constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                        constant DistantLightSourceInfo &light_source_info [[buffer(4)]],
                                        uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_point_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                      texture2d<float, access::read> input [[texture(1)]],
                                      texture2d<float, access::write> output [[texture(2)]],
                                      constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                      constant PointLightSourceInfo &light_source_info [[buffer(4)]],
                                      uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_spot_light2(texture2d<float, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<float, access::read> input [[texture(1)]],
                                     texture2d<float, access::write> output [[texture(2)]],
                                     constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                     constant SpotLightSourceInfo &light_source_info [[buffer(4)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float4 norm_map = norm_map_texture.read(gid);
    const float4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const float4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
