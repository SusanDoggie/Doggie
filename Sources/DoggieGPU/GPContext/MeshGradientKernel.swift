//
//  MeshGradientKernel.swift
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

#if canImport(CoreImage)

private typealias metal_patch_colors_type = (RGBA32ColorPixel, RGBA32ColorPixel, RGBA32ColorPixel, RGBA32ColorPixel)

private typealias metal_patch_controls_type = (simd_float2, simd_float2, simd_float2, simd_float2,
                                               simd_float2, simd_float2, simd_float2, simd_float2,
                                               simd_float2, simd_float2, simd_float2, simd_float2,
                                               simd_float2, simd_float2, simd_float2, simd_float2)

extension CubicBezierPatch where Element == Point {
    
    fileprivate var metal_data: metal_patch_controls_type {
        return (simd_float2(m00), simd_float2(m01), simd_float2(m02), simd_float2(m03),
                simd_float2(m10), simd_float2(m11), simd_float2(m12), simd_float2(m13),
                simd_float2(m20), simd_float2(m21), simd_float2(m22), simd_float2(m23),
                simd_float2(m30), simd_float2(m31), simd_float2(m32), simd_float2(m33))
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func drawMeshGradient<C>(colorSpace: ColorSpace<RGBColorModel>, mesh: MeshGradient<C>) {
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        
        let transform = mesh.transform * self.transform
        let patches = mesh.patches.map { $0 * transform }
        
        guard mesh.colors.count == (mesh.row + 1) * (mesh.column + 1) else { return }
        guard patches.count == mesh.row * mesh.column else { return }
        
        let colors = mesh.colors.map { $0.with(opacity: $0.opacity * mesh.opacity) }.map { RGBA32ColorPixel($0.convert(to: colorSpace, intent: .default)) }
        let gradient = MeshGradientKernel.Gradient(column: mesh.column, row: mesh.row, patches: patches, colors: colors)
        
        let extent = self.extent.inset(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        guard var image = try? MeshGradientKernel.apply(withExtent: CGRect(extent), inputs: nil, arguments: ["gradient": gradient]).premultiplyingAlpha() else { return }
        
        image = image.matchedToWorkingSpace(from: cgColorSpace) ?? image
        
        self.saveGraphicState()
        defer { self.restoreGraphicState() }
        
        self.transform = .identity
        self.draw(image: image, transform: .identity)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
private class MeshGradientKernel: CIImageProcessorKernel {
    
    private static let lck = SDLock()
    private static var pipeline: WeakDictionary<MTLDevice, Pipeline> = WeakDictionary()
    
    private static func make_pipeline(_ device: MTLDevice) -> Pipeline? {
        
        lck.lock()
        defer { lck.unlock() }
        
        if let _pipeline = pipeline[device] {
            
            return _pipeline
            
        } else {
            
            guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else { return nil }
            guard let _pipeline = Pipeline(device: device, library: library) else { return nil }
            
            pipeline[device] = _pipeline
            return _pipeline
        }
    }
    
    override class var outputFormat: CIFormat {
        return .BGRA8
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
        
        guard let commandBuffer = output.metalCommandBuffer else { return }
        guard let texture = output.metalTexture else { return }
        guard let gradient = arguments?["gradient"] as? Gradient else { return }
        
        let transform = SDTransform.translate(x: -output.region.minX, y: -output.region.minY) * SDTransform.scale(x: 1 / output.region.width, y: 1 / output.region.height)
        
        guard let pipeline = self.make_pipeline(commandBuffer.device) else { return }
        guard let buffers = gradient.prepare_buffers(device: commandBuffer.device) else { return }
        
        guard prepare_render(commandBuffer, pipeline, buffers, gradient) else { return }
        guard render(commandBuffer, pipeline, buffers, gradient, transform, texture) else { return }
    }
    
    private class func prepare_render(_ commandBuffer: MTLCommandBuffer, _ pipeline: Pipeline, _ buffers: Buffers, _ gradient: Gradient) -> Bool {
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return false }
        
        encoder.setComputePipelineState(pipeline.tessellation_kernel)
        
        let maxTessellationFactor = commandBuffer.device.maxTessellationFactor
        
        let edge = Float(maxTessellationFactor)
        let inside = Float(maxTessellationFactor)
        let count = Int32(gradient.patches.count)
        
        withUnsafeBytes(of: edge) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 0) }
        withUnsafeBytes(of: inside) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 1) }
        withUnsafeBytes(of: count) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
        encoder.setBuffer(buffers.factors, offset: 0, index: 3)
        
        let w = pipeline.tessellation_kernel.threadExecutionWidth
        let threadsPerThreadgroup = MTLSize(width: w, height: 1, depth: 1)
        let threadgroupsPerGrid = MTLSize(width: (gradient.patches.count + w - 1) / w, height: 1, depth: 1)
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        encoder.endEncoding()
        
        return true
    }
    
    private class func render(_ commandBuffer: MTLCommandBuffer, _ pipeline: Pipeline, _ buffers: Buffers, _ gradient: Gradient, _ transform: SDTransform, _ texture: MTLTexture) -> Bool {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor()
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return false }
        
        encoder.setRenderPipelineState(pipeline.render_pipeline)
        encoder.setVertexBuffer(buffers.colors, offset: 0, index: 0)
        encoder.setVertexBuffer(buffers.controls, offset: 0, index: 1)
        withUnsafeBytes(of: simd_float3x2(transform)) { encoder.setVertexBytes($0.baseAddress!, length: $0.count, index: 2) }
        
        encoder.setTriangleFillMode(.fill)
        
        encoder.setTessellationFactorBuffer(buffers.factors, offset: 0, instanceStride: 0)
        encoder.drawPatches(numberOfPatchControlPoints: 16,
                            patchStart: 0,
                            patchCount: gradient.patches.count,
                            patchIndexBuffer: nil,
                            patchIndexBufferOffset: 0,
                            instanceCount: 1,
                            baseInstance: 0)
        
        encoder.endEncoding()
        
        return true
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension MeshGradientKernel {
    
    struct Gradient {
        
        var column: Int
        var row: Int
        
        var patches: [CubicBezierPatch<Point>]
        var colors: [RGBA32ColorPixel]
        
        let cache = Cache()
    }
    
    class Cache {
        
        let lck = SDLock()
        
        var buffers = WeakDictionary<MTLDevice, Buffers>()
    }
    
    struct Buffers {
        
        var factors: MTLBuffer
        var colors: MTLBuffer
        var controls: MTLBuffer
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension MeshGradientKernel.Gradient {
    
    fileprivate func prepare_buffers(device: MTLDevice) -> MeshGradientKernel.Buffers? {
        
        cache.lck.lock()
        defer { cache.lck.unlock() }
        
        if cache.buffers[device] == nil {
            
            let patch_colors = self.patch_colors
            let patch_controls = self.patches.map { $0.metal_data }
            
            guard let factors = device.makeBuffer(length: MemoryLayout<MTLQuadTessellationFactorsHalf>.stride * self.patches.count, options: .storageModePrivate) else { return nil }
            guard let colors = device.makeBuffer(bytes: patch_colors, length: MemoryLayout<metal_patch_colors_type>.stride * patch_colors.count) else { return nil }
            guard let controls = device.makeBuffer(bytes: patch_controls, length: MemoryLayout<metal_patch_controls_type>.stride * patch_controls.count) else { return nil }
            
            cache.buffers[device] = MeshGradientKernel.Buffers(factors: factors, colors: colors, controls: controls)
        }
        
        return cache.buffers[device]
    }
    
    fileprivate var patch_colors: [metal_patch_colors_type] {
        
        var result: [metal_patch_colors_type] = []
        var colors = self.colors[...]
        
        while !colors.isEmpty {
            
            let top = result.count < column ? nil : result[result.count - column]
            let left = result.count % column == 0 ? nil : result[result.count - 1]
            
            guard let c00 = top?.2 ?? left?.1 ?? colors.popFirst() else { return result }
            guard let c01 = top?.3 ?? colors.popFirst() else { return result }
            guard let c10 = left?.3 ?? colors.popFirst() else { return result }
            guard let c11 = colors.popFirst() else { return result }
            
            result.append((c00, c01, c10, c11))
        }
        
        return result
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension MeshGradientKernel {
    
    struct Pipeline {
        
        let device: MTLDevice
        let library: MTLLibrary
        
        let tessellation_kernel: MTLComputePipelineState
        let render_pipeline: MTLRenderPipelineState
        
        init?(device: MTLDevice, library: MTLLibrary) {
            
            self.device = device
            self.library = library
            
            guard let _tessellation_kernel = library.makeFunction(name: "mesh_gradient_tessellation_kernel_quad") else { return nil }
            guard let tessellation_kernel = try? device.makeComputePipelineState(function: _tessellation_kernel) else { return nil }
            self.tessellation_kernel = tessellation_kernel
            
            guard let tessellation_vertex_quad = library.makeFunction(name: "mesh_gradient_tessellation_vertex_quad") else { return nil }
            guard let tessellation_fragment = library.makeFunction(name: "mesh_gradient_tessellation_fragment") else { return nil }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].format = .uchar4
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .uchar4
            vertexDescriptor.attributes[1].offset = MemoryLayout<simd_uchar4>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.attributes[2].format = .uchar4
            vertexDescriptor.attributes[2].offset = MemoryLayout<simd_uchar4>.stride * 2
            vertexDescriptor.attributes[2].bufferIndex = 0
            vertexDescriptor.attributes[3].format = .uchar4
            vertexDescriptor.attributes[3].offset = MemoryLayout<simd_uchar4>.stride * 3
            vertexDescriptor.attributes[3].bufferIndex = 0
            vertexDescriptor.attributes[4].format = .float2
            vertexDescriptor.attributes[4].offset = 0
            vertexDescriptor.attributes[4].bufferIndex = 1
            vertexDescriptor.attributes[5].format = .float2
            vertexDescriptor.attributes[5].offset = 0
            vertexDescriptor.attributes[5].bufferIndex = 2
            vertexDescriptor.attributes[6].format = .float2
            vertexDescriptor.attributes[6].offset = MemoryLayout<simd_float2>.stride
            vertexDescriptor.attributes[6].bufferIndex = 2
            vertexDescriptor.attributes[7].format = .float2
            vertexDescriptor.attributes[7].offset = MemoryLayout<simd_float2>.stride * 2
            vertexDescriptor.attributes[7].bufferIndex = 2
            vertexDescriptor.layouts[0].stepFunction = .perPatch
            vertexDescriptor.layouts[0].stride = MemoryLayout<metal_patch_colors_type>.stride
            vertexDescriptor.layouts[1].stepFunction = .perPatchControlPoint
            vertexDescriptor.layouts[1].stride = MemoryLayout<simd_float2>.stride
            vertexDescriptor.layouts[2].stepFunction = .constant
            vertexDescriptor.layouts[2].stepRate = 0
            vertexDescriptor.layouts[2].stride = MemoryLayout<simd_float2>.stride * 3
            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.fragmentFunction = tessellation_fragment
            
            pipelineDescriptor.isTessellationFactorScaleEnabled = false
            pipelineDescriptor.tessellationFactorFormat = .half
            pipelineDescriptor.tessellationControlPointIndexType = .none
            pipelineDescriptor.tessellationFactorStepFunction = .constant
            pipelineDescriptor.tessellationOutputWindingOrder = .clockwise
            pipelineDescriptor.tessellationPartitionMode = .fractionalEven
            pipelineDescriptor.maxTessellationFactor = device.maxTessellationFactor
            
            pipelineDescriptor.vertexFunction = tessellation_vertex_quad
            guard let render_pipeline = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else { return nil }
            self.render_pipeline = render_pipeline
        }
    }
}

#endif
