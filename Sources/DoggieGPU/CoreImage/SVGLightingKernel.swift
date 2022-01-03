//
//  SVGLightingKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

#if canImport(CoreImage)

extension CIImage {
    
    private class SVGLightingKernel: CIImageProcessorKernel {
        
        struct DistantLightInfo {
            
            var azimuth: Float
            var elevation: Float
            
            init(_ light: SVGDistantLight) {
                self.azimuth = Float(light.azimuth)
                self.elevation = Float(light.elevation)
            }
        }
        
        struct PointLightInfo {
            
            var position: packed_float3
            
            init(_ light: SVGPointLight) {
                self.position = packed_float3(light.location)
            }
        }
        
        struct SpotLightInfo {
            
            var position: packed_float3
            var direction: packed_float3
            var specularExponent: Float
            var limitingConeAngle: Float
            
            init(_ light: SVGSpotLight) {
                self.position = packed_float3(light.location)
                self.direction = packed_float3(light.direction - light.location)
                self.specularExponent = Float(light.specularExponent)
                self.limitingConeAngle = Float(light.limitingConeAngle)
            }
        }
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            let unit = arguments?["unit"] as? Size ?? Size(width: 1, height: 1)
            
            let dx = abs(unit.width)
            let dy = abs(unit.height)
            
            return outputRect.insetBy(dx: -CGFloat(ceil(dx)), dy: -CGFloat(ceil(dy)))
        }
        
        override class var outputFormat: CIFormat {
            return .RGBAh
        }
        
        class func encode_normalmap(_ encoder: MTLComputeCommandEncoder, _ input: MTLTexture, _ input_region: CGRect, _ output: MTLTexture, _ output_region: CGRect, _ unit: Size) {
            
            guard let svg_normalmap = self.make_pipeline(encoder.device, "svg_normal_map") else { return }
            
            let offset_x = Float(output_region.minX - input_region.minX)
            let offset_y = Float(input_region.maxY - output_region.maxY)
            
            encoder.setComputePipelineState(svg_normalmap)
            
            encoder.setTexture(input, index: 0)
            encoder.setTexture(output, index: 1)
            withUnsafeBytes(of: (offset_x, offset_y)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            withUnsafeBytes(of: packed_float2(unit)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            
            let group_width = max(1, svg_normalmap.threadExecutionWidth)
            let group_height = max(1, svg_normalmap.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output.width + group_width - 1) / group_width, height: (output.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        }
        
        class func encode_lighting<T>(
            _ encoder: MTLComputeCommandEncoder,
            _ lighting_type: String,
            _ normalmap: MTLTexture,
            _ input: MTLTexture?,
            _ output: MTLTexture,
            _ scale: Double,
            _ output_region: CGRect,
            _ light_info: T, _ light_source: SVGLightSource) {
            
            let group_width: Int
            let group_height: Int
            
            switch light_source {
            case let light_source as SVGDistantLight:
                
                let pipeline_name = input == nil ? "svg_\(lighting_type)_distant_light" : "svg_\(lighting_type)_distant_light2"
                
                guard let distant_lighting = self.make_pipeline(encoder.device, pipeline_name) else { return }
                
                let light_source_info = DistantLightInfo(light_source)
                
                encoder.setComputePipelineState(distant_lighting)
                
                group_width = max(1, distant_lighting.threadExecutionWidth)
                group_height = max(1, distant_lighting.maxTotalThreadsPerThreadgroup / group_width)
                
                withUnsafeBytes(of: light_source_info) { encoder.setBytes($0.baseAddress!, length: $0.count, index: input == nil ? 3 : 4) }
                
            case let light_source as SVGPointLight:
                
                let pipeline_name = input == nil ? "svg_\(lighting_type)_point_light" : "svg_\(lighting_type)_point_light2"
                
                guard let point_lighting = self.make_pipeline(encoder.device, pipeline_name) else { return }
                
                var light_source_info = PointLightInfo(light_source)
                
                light_source_info.position.x -= Float(scale) * Float(output_region.minX)
                light_source_info.position.y -= Float(scale) * Float(output_region.minY)
                
                encoder.setComputePipelineState(point_lighting)
                
                group_width = max(1, point_lighting.threadExecutionWidth)
                group_height = max(1, point_lighting.maxTotalThreadsPerThreadgroup / group_width)
                
                withUnsafeBytes(of: light_source_info) { encoder.setBytes($0.baseAddress!, length: $0.count, index: input == nil ? 3 : 4) }
                
            case let light_source as SVGSpotLight:
                
                let pipeline_name = input == nil ? "svg_\(lighting_type)_spot_light" : "svg_\(lighting_type)_spot_light2"
                
                guard let spot_lighting = self.make_pipeline(encoder.device, pipeline_name) else { return }
                
                var light_source_info = SpotLightInfo(light_source)
                
                light_source_info.position.x -= Float(scale) * Float(output_region.minX)
                light_source_info.position.y -= Float(scale) * Float(output_region.minY)
                
                encoder.setComputePipelineState(spot_lighting)
                
                group_width = max(1, spot_lighting.threadExecutionWidth)
                group_height = max(1, spot_lighting.maxTotalThreadsPerThreadgroup / group_width)
                
                withUnsafeBytes(of: light_source_info) { encoder.setBytes($0.baseAddress!, length: $0.count, index: input == nil ? 3 : 4) }
                
            default: return
            }
            
            if let input = input {
                encoder.setTexture(input, index: 1)
            }
            
            encoder.setTexture(normalmap, index: 0)
            encoder.setTexture(output, index: input == nil ? 1 : 2)
            withUnsafeBytes(of: light_info) { encoder.setBytes($0.baseAddress!, length: $0.count, index: input == nil ? 2 : 3) }
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output.width + group_width - 1) / group_width, height: (output.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        }
    }
}

extension CIImage {
    
    public struct SVGDiffuseLighting {
        
        public var surfaceScale: Double
        public var diffuseConstant: Double
        
        public var color: RGBColorModel
        
        public var light: [SVGLightSource]
        
        public init(surfaceScale: Double = 1, diffuseConstant: Double = 1, color: RGBColorModel = .white, light: [SVGLightSource] = []) {
            self.surfaceScale = surfaceScale
            self.diffuseConstant = diffuseConstant
            self.color = color
            self.light = light
        }
    }
    
    private class SVGDiffuseLightingKernel: SVGLightingKernel {
        
        struct DiffuseLightInfo {
            
            var color: packed_float4
            var unit_scale: Float
            
            init(_ light: SVGDiffuseLighting, _ unit_scale: Double) {
                self.color = packed_float4(
                    Float(light.color.red * light.diffuseConstant),
                    Float(light.color.green * light.diffuseConstant),
                    Float(light.color.blue * light.diffuseConstant),
                    Float(light.surfaceScale)
                )
                self.unit_scale = Float(unit_scale)
            }
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input_texture = inputs?[0].metalTexture else { return }
            guard let input_region = inputs?[0].region else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let lighting = arguments?["lighting"] as? SVGDiffuseLighting else { return }
            guard let unit = arguments?["unit"] as? Size else { return }
            guard let scale = arguments?["scale"] as? Double else { return }
            
            let texture_descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: output_texture.pixelFormat,
                width: output_texture.width,
                height: output_texture.height,
                mipmapped: false)
            texture_descriptor.usage = [.shaderRead, .shaderWrite]
            texture_descriptor.storageMode = .private
            
            guard let normalmap = commandBuffer.device.makeTexture(descriptor: texture_descriptor) else { return }
            guard var texture1 = commandBuffer.device.makeTexture(descriptor: texture_descriptor) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            self.encode_normalmap(encoder, input_texture, input_region, normalmap, output.region, unit)
            
            let light_info = DiffuseLightInfo(lighting, scale)
            
            var texture2 = output_texture
            
            if lighting.light.count & 1 == 0 {
                swap(&texture1, &texture2)
            }
            
            for (i, light_source) in lighting.light.enumerated() {
                
                self.encode_lighting(encoder, "diffuse", normalmap, i == 0 ? nil : texture1, texture2, scale, output.region, light_info, light_source)
            }
            
            encoder.endEncoding()
        }
    }
    
    open func diffuseLighting(_ lighting: SVGDiffuseLighting, _ unit: Size = Size(width: 1, height: 1), _ scale: Double = 1) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try? SVGDiffuseLightingKernel.apply(withExtent: _extent, inputs: [self], arguments: ["lighting": lighting, "unit": unit, "scale": scale]).premultiplyingAlpha()
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

extension CIImage {
    
    public struct SVGSpecularLighting {
        
        public var surfaceScale: Double
        public var specularConstant: Double
        public var specularExponent: Double
        
        public var color: RGBColorModel
        
        public var light: [SVGLightSource]
        
        public init(surfaceScale: Double = 1, specularConstant: Double = 1, specularExponent: Double = 1, color: RGBColorModel = .white, light: [SVGLightSource] = []) {
            self.surfaceScale = surfaceScale
            self.specularConstant = specularConstant
            self.specularExponent = specularExponent
            self.color = color
            self.light = light
        }
    }
    
    private class SVGSpecularLightingKernel: SVGLightingKernel {
        
        struct SpecularLightInfo {
            
            var color: packed_float4
            var unit_scale: Float
            var specularExponent: Float
            
            init(_ light: SVGSpecularLighting, _ unit_scale: Double) {
                self.color = packed_float4(
                    Float(light.color.red * light.specularConstant),
                    Float(light.color.green * light.specularConstant),
                    Float(light.color.blue * light.specularConstant),
                    Float(light.surfaceScale)
                )
                self.specularExponent = Float(light.specularExponent)
                self.unit_scale = Float(unit_scale)
            }
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input_texture = inputs?[0].metalTexture else { return }
            guard let input_region = inputs?[0].region else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let lighting = arguments?["lighting"] as? SVGSpecularLighting else { return }
            guard let unit = arguments?["unit"] as? Size else { return }
            guard let scale = arguments?["scale"] as? Double else { return }
            
            let texture_descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: output_texture.pixelFormat,
                width: output_texture.width,
                height: output_texture.height,
                mipmapped: false)
            texture_descriptor.usage = [.shaderRead, .shaderWrite]
            texture_descriptor.storageMode = .private
            
            guard let normalmap = commandBuffer.device.makeTexture(descriptor: texture_descriptor) else { return }
            guard var texture1 = commandBuffer.device.makeTexture(descriptor: texture_descriptor) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            self.encode_normalmap(encoder, input_texture, input_region, normalmap, output.region, unit)
            
            let light_info = SpecularLightInfo(lighting, scale)
            
            var texture2 = output_texture
            
            if lighting.light.count & 1 == 0 {
                swap(&texture1, &texture2)
            }
            
            for (i, light_source) in lighting.light.enumerated() {
                
                self.encode_lighting(encoder, "specular", normalmap, i == 0 ? nil : texture1, texture2, scale, output.region, light_info, light_source)
            }
            
            encoder.endEncoding()
        }
    }
    
    open func specularLighting(_ lighting: SVGSpecularLighting, _ unit: Size = Size(width: 1, height: 1), _ scale: Double = 1) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try? SVGSpecularLightingKernel.apply(withExtent: _extent, inputs: [self], arguments: ["lighting": lighting, "unit": unit, "scale": scale]).premultiplyingAlpha()
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

#endif
