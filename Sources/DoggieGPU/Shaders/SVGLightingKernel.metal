//
//  SVGLightingKernel.metal
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

struct SVGNormalMapInfo {
    
    packed_float2 offset;
    packed_float2 unit;
    
};

kernel void svg_normal_map(texture2d<half, access::sample> input [[texture(0)]],
                           texture2d<half, access::write> output [[texture(1)]],
                           constant SVGNormalMapInfo &info [[buffer(2)]],
                           uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const float2 coord = (float2)gid + info.offset;
    const float2 unit = info.unit;
    
    const float2 offset_0 = float2(-unit.x, unit.y);
    const float2 offset_1 = float2(-unit.x, 0);
    const float2 offset_2 = float2(-unit.x, -unit.y);
    const float2 offset_3 = float2(0, unit.y);
    const float2 offset_5 = float2(0, -unit.y);
    const float2 offset_6 = float2(unit.x, unit.y);
    const float2 offset_7 = float2(unit.x, 0);
    const float2 offset_8 = float2(unit.x, -unit.y);
    
    constexpr sampler input_sampler (coord::pixel, address::clamp_to_zero, filter::linear);
    
    float norm_x = -input.sample(input_sampler, coord + offset_0).w;
    norm_x -= input.sample(input_sampler, coord + offset_3).w * 2;
    norm_x -= input.sample(input_sampler, coord + offset_6).w;
    norm_x += input.sample(input_sampler, coord + offset_2).w;
    norm_x += input.sample(input_sampler, coord + offset_5).w * 2;
    norm_x += input.sample(input_sampler, coord + offset_8).w;
    
    float norm_y = -input.sample(input_sampler, coord + offset_0).w;
    norm_y -= input.sample(input_sampler, coord + offset_1).w * 2;
    norm_y -= input.sample(input_sampler, coord + offset_2).w;
    norm_y += input.sample(input_sampler, coord + offset_6).w;
    norm_y += input.sample(input_sampler, coord + offset_7).w * 2;
    norm_y += input.sample(input_sampler, coord + offset_8).w;
    
    const half4 color = half4(norm_x, norm_y, input.sample(input_sampler, coord).w, 1);
    
    output.write(color, gid);
}

struct DiffuseLightInfo {
    
    packed_float4 color;
    float unit_scale;
    
    half4 lighting(half4 source, half4 color, float3 surface_unit, float3 light) const {
        
        const float diffuse = dot(surface_unit, light);
        
        return half4(source.xyz + diffuse * color.xyz, 1);
    }
};

struct SpecularLightInfo {
    
    packed_float4 color;
    float unit_scale;
    float specularExponent;
    
    half4 lighting(half4 source, half4 color, float3 surface_unit, float3 light) const {
        
        const float3 E = float3(0, 0, 1);
        const float3 H = normalize(light + E);
        
        const half3 _color = pow(dot(surface_unit, H), specularExponent) * color.xyz;
        
        return source + half4(_color, max(_color.x, max(_color.y, _color.x)));
    }
};

struct DistantLightSourceInfo {
    
    float azimuth;
    float elevation;
    
    float3 surface_unit(float4 color, half4 norm_map) const {
        return normalize(float3(-color.w * norm_map.x, -color.w * norm_map.y, 1));
    }
    
    float3 light(float4 color, half4 norm_map, float2 coord) const {
        return float3(cos(azimuth) * cos(elevation), sin(azimuth) * cos(elevation), sin(elevation));
    }
    
    float4 color(float4 color, float3 light) const {
        return color;
    }
    
};

struct PointLightSourceInfo {
    
    packed_float3 position;
    
    float3 surface_unit(float4 color, half4 norm_map) const {
        return normalize(float3(-color.w * norm_map.x, -color.w * norm_map.y, 1));
    }
    
    float3 light(float4 color, half4 norm_map, float2 coord) const {
        return normalize(position - float3(coord.x, coord.y, color.w * norm_map.z));
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
    
    float3 surface_unit(float4 color, half4 norm_map) const {
        return normalize(float3(-color.w * norm_map.x, -color.w * norm_map.y, 1));
    }
    
    float3 light(float4 color, half4 norm_map, float2 coord) const {
        return normalize(position - float3(coord.x, coord.y, color.w * norm_map.z));
    }
    
    float4 color(float4 color, float3 light) const {
        
        const float ls = -dot(light, normalize(direction));
        
        const float limit = max(0.0, cos(limitingConeAngle));
        if (ls > limit) {
            const float power = pow(ls, specularExponent);
            const float blur = min(1.0, (ls - limit) / 0.01);
            color.xyz *= power * blur;
        } else {
            color.xyz = 0;
        }
        
        return color;
    }
    
};

template <typename L, typename S>
half4 svg_lighting(half4 norm_map,
                   half4 source,
                   const L lighting_info,
                   const S light_source_info,
                   uint2 gid) {
    
    const float2 coord = lighting_info.unit_scale * (float2)gid;
    
    const float4 light_color = lighting_info.color;
    
    const float3 surface_unit = light_source_info.surface_unit(light_color, norm_map);
    const float3 light = light_source_info.light(light_color, norm_map, coord);
    
    const float4 color = light_source_info.color(light_color, light);
    
    return lighting_info.lighting(source, (half4)color, surface_unit, light);
}

kernel void svg_diffuse_distant_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                      texture2d<half, access::write> output [[texture(1)]],
                                      constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                      constant DistantLightSourceInfo &light_source_info [[buffer(3)]],
                                      uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_point_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<half, access::write> output [[texture(1)]],
                                    constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                    constant PointLightSourceInfo &light_source_info [[buffer(3)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_spot_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                   texture2d<half, access::write> output [[texture(1)]],
                                   constant DiffuseLightInfo &lighting_info [[buffer(2)]],
                                   constant SpotLightSourceInfo &light_source_info [[buffer(3)]],
                                   uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_specular_distant_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                       texture2d<half, access::write> output [[texture(1)]],
                                       constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                       constant DistantLightSourceInfo &light_source_info [[buffer(3)]],
                                       uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_point_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<half, access::write> output [[texture(1)]],
                                     constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                     constant PointLightSourceInfo &light_source_info [[buffer(3)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_spot_light(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<half, access::write> output [[texture(1)]],
                                    constant SpecularLightInfo &lighting_info [[buffer(2)]],
                                    constant SpotLightSourceInfo &light_source_info [[buffer(3)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, 0, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_diffuse_distant_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                       texture2d<half, access::read> input [[texture(1)]],
                                       texture2d<half, access::write> output [[texture(2)]],
                                       constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                       constant DistantLightSourceInfo &light_source_info [[buffer(4)]],
                                       uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_point_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<half, access::read> input [[texture(1)]],
                                     texture2d<half, access::write> output [[texture(2)]],
                                     constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                     constant PointLightSourceInfo &light_source_info [[buffer(4)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_diffuse_spot_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                    texture2d<half, access::read> input [[texture(1)]],
                                    texture2d<half, access::write> output [[texture(2)]],
                                    constant DiffuseLightInfo &lighting_info [[buffer(3)]],
                                    constant SpotLightSourceInfo &light_source_info [[buffer(4)]],
                                    uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}

kernel void svg_specular_distant_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                        texture2d<half, access::read> input [[texture(1)]],
                                        texture2d<half, access::write> output [[texture(2)]],
                                        constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                        constant DistantLightSourceInfo &light_source_info [[buffer(4)]],
                                        uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_point_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                      texture2d<half, access::read> input [[texture(1)]],
                                      texture2d<half, access::write> output [[texture(2)]],
                                      constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                      constant PointLightSourceInfo &light_source_info [[buffer(4)]],
                                      uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
kernel void svg_specular_spot_light2(texture2d<half, access::read> norm_map_texture [[texture(0)]],
                                     texture2d<half, access::read> input [[texture(1)]],
                                     texture2d<half, access::write> output [[texture(2)]],
                                     constant SpecularLightInfo &lighting_info [[buffer(3)]],
                                     constant SpotLightSourceInfo &light_source_info [[buffer(4)]],
                                     uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) { return; }
    
    const half4 norm_map = norm_map_texture.read(gid);
    const half4 source = input.read(gid);
    
    const uint2 coord = uint2(gid.x, output.get_height() - gid.y - 1);
    
    const half4 result = svg_lighting(norm_map, source, lighting_info, light_source_info, coord);
    
    output.write(result, gid);
}
