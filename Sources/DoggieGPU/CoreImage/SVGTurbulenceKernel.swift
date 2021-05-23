//
//  SVGTurbulenceKernel.swift
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

public struct SVGTurbulenceKernel {
    
    public var type: SVGTurbulenceType
    public var seed: Int
    public var transform: SDTransform
    public var baseFreq: Size
    public var stitchTile: Rect
    public var numOctaves: Int
    public var isStitchTile: Bool
    
    public init(type: SVGTurbulenceType,
                seed: Int,
                transform: SDTransform,
                baseFreq: Size,
                stitchTile: Rect,
                numOctaves: Int,
                isStitchTile: Bool) {
        
        self.type = type
        self.seed = seed
        self.transform = transform
        self.baseFreq = baseFreq
        self.stitchTile = stitchTile
        self.numOctaves = numOctaves
        self.isStitchTile = isStitchTile
    }
}

extension SVGTurbulenceKernel {
    
    public func image(withExtent extent: CGRect = .infinite) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try? ProcessorKernel.apply(withExtent: _extent, inputs: nil, arguments: ["info": self]).premultiplyingAlpha()
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
    
    private class ProcessorKernel: CIImageProcessorKernel {
        
        private static let lck = NSLock()
        private static var function_constants: [SVGTurbulenceType: [Bool: [Int: MTLFunctionConstantValues]]] = [:]
        
        static func make_function_constant(_ type: SVGTurbulenceType, _ isStitchTile: Bool, _ numOctaves: Int) -> MTLFunctionConstantValues {
            
            lck.lock()
            defer { lck.unlock() }
            
            if let constants = function_constants[type]?[isStitchTile]?[numOctaves] {
                return constants
            }
            
            let constants = MTLFunctionConstantValues()
            
            withUnsafeBytes(of: type == .fractalNoise) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "IS_FRACTAL_NOISE") }
            withUnsafeBytes(of: isStitchTile) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "IS_STITCH_TILE") }
            withUnsafeBytes(of: Int32(numOctaves)) { constants.setConstantValue($0.baseAddress!, type: .int, withName: "NUM_OCTAVES") }
            
            function_constants[type, default: [:]][isStitchTile, default: [:]][numOctaves] = constants
            
            return constants
        }
        
        static let cache_lck = NSLock()
        static var cache: [SVGNoiseGeneratorBuffer] = []
        
        static func svg_noise_generator(_ seed: Int, _ device: MTLDevice) -> (MTLBuffer, MTLBuffer)? {
            
            cache_lck.lock()
            defer { cache_lck.unlock() }
            
            if let index = cache.firstIndex(where: { $0.seed == seed && $0.device === device }) {
                
                let noise = cache.remove(at: index)
                cache.append(noise)
                
                return (noise.uLatticeSelector, noise.fGradient)
                
            } else {
                
                guard let noise = SVGNoiseGeneratorBuffer(seed, device) else { return nil }
                cache.append(noise)
                
                while cache.count > 10 {
                    cache.removeFirst()
                }
                
                return (noise.uLatticeSelector, noise.fGradient)
            }
        }
        
        struct SVGNoiseGeneratorBuffer {
            
            let seed: Int
            let device: MTLDevice
            
            let uLatticeSelector: MTLBuffer
            let fGradient: MTLBuffer
            
            init?(_ seed: Int, _ device: MTLDevice) {
                
                self.seed = seed
                self.device = device
                
                let noise = SVGNoiseGenerator(seed)
                let uLatticeSelector = noise.uLatticeSelector.map { Int32($0) }
                let fGradient = noise.fGradient.map { (Float($0.x), Float($0.y)) }
                
                guard let _uLatticeSelector = uLatticeSelector.withUnsafeBytes({ device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }) else { return nil }
                guard let _fGradient = fGradient.withUnsafeBytes({ device.makeBuffer(bytes: $0.baseAddress!, length: $0.count) }) else { return nil }
                
                self.uLatticeSelector = _uLatticeSelector
                self.fGradient = _fGradient
            }
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let texture = output.metalTexture else { return }
            guard let info = arguments?["info"] as? SVGTurbulenceKernel else { return }
            
            let transform = SDTransform.translate(x: output.region.minX, y: output.region.minY) * SDTransform.reflectY(output.region.midY) * info.transform.inverse
            
            let device = commandBuffer.device
            guard let buffers = svg_noise_generator(info.seed, device) else { return }
            
            let function_constant = self.make_function_constant(info.type, info.isStitchTile, info.numOctaves)
            guard let pipeline = self.make_pipeline(device, "svg_turbulence", function_constant) else { return }
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            struct Info {
                
                var transform: simd_float3x2
                var baseFreq: packed_float2
                var stitchTile: packed_float4
                
            }
            
            let _info = Info(
                transform: simd_float3x2(transform),
                baseFreq: packed_float2(info.baseFreq),
                stitchTile: packed_float4(info.stitchTile)
            )
            
            encoder.setBuffer(buffers.0, offset: 0, index: 0)
            encoder.setBuffer(buffers.1, offset: 0, index: 1)
            withUnsafeBytes(of: _info) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            encoder.setTexture(texture, index: 3)
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (texture.width + group_width - 1) / group_width, height: (texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
}

#endif
