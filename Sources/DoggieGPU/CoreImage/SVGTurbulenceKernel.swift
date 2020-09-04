//
//  SVGTurbulenceKernel.swift
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
    
    public var image: CIImage? {
        return try? ProcessorKernel.apply(withExtent: .infinite, inputs: nil, arguments: ["info": self]).premultiplyingAlpha()
    }
    
    private class ProcessorKernel: CIImageProcessorKernel {
        
        static let cache_lck = SDLock()
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
            guard var info = arguments?["info"] as? SVGTurbulenceKernel else { return }
            
            info.transform = SDTransform.translate(x: output.region.minX, y: output.region.minY) * SDTransform.reflectY(output.region.midY) * info.transform
            
            let device = commandBuffer.device
            guard let buffers = svg_noise_generator(info.seed, device) else { return }
            
            guard let pipeline = self.make_pipeline(device, "svg_turbulence") else { return }
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            struct Info {
                
                var transform: packed_float3x2
                var baseFreq: packed_float2
                var stitchTile: packed_float4
                var numOctaves: Int32
                var fractalSum: Int32
                var isStitchTile: Int32
                var padding: Int32
                
                init(_ info: SVGTurbulenceKernel) {
                    self.transform = packed_float3x2(info.transform)
                    self.baseFreq = packed_float2(info.baseFreq)
                    self.stitchTile = packed_float4(info.stitchTile)
                    self.numOctaves = Int32(info.numOctaves)
                    self.fractalSum = info.type == .fractalNoise ? 1 : 0
                    self.isStitchTile = info.isStitchTile ? 1 : 0
                    self.padding = 0
                }
            }
            
            encoder.setBuffer(buffers.0, offset: 0, index: 0)
            encoder.setBuffer(buffers.1, offset: 0, index: 1)
            withUnsafeBytes(of: Info(info)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
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
