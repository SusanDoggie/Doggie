//
//  SVGDisplacementMapKernel.swift
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

extension CIImage {
    
    private class SVGDisplacementMapKernel: CIImageProcessorKernel {
        
        struct Selector: Hashable {
            
            var x: Int
            var y: Int
        }
        
        static let pipeline_constants: [Selector: MTLFunctionConstantValues] = {
            
            var pipeline_constants: [Selector: MTLFunctionConstantValues] = [:]
            
            for y in 0...3 {
                for x in 0...3 {
                    let constants = MTLFunctionConstantValues()
                    withUnsafePointer(to: Int32(x)) { constants.setConstantValue($0, type: .int, index: 0) }
                    withUnsafePointer(to: Int32(y)) { constants.setConstantValue($0, type: .int, index: 1) }
                    pipeline_constants[Selector(x: x, y: y)] = constants
                }
            }
            
            return pipeline_constants
        }()
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            guard input != 0 else { return outputRect }
            guard let scale = arguments?["scale"] as? Size else { return outputRect }
            
            let scale_x = CGFloat(abs(scale.width))
            let scale_y = CGFloat(abs(scale.height))
            
            return outputRect.insetBy(dx: -0.5 * scale_x, dy: -0.5 * scale_y)
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let displacement = inputs?[1].metalTexture else { return }
            guard let displacement_region = inputs?[1].region else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let scale = arguments?["scale"] as? Size else { return }
            guard let selector = arguments?["selector"] as? Selector else { return }
            
            guard let constants = pipeline_constants[selector] else { return }
            guard let pipeline = self.make_pipeline(commandBuffer.device, "svg_displacement_map", constants) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            let offset_x = output.region.minX - displacement_region.minX
            let offset_y = output.region.minY - displacement_region.minY
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(source, index: 0)
            encoder.setTexture(displacement, index: 1)
            encoder.setTexture(output_texture , index: 2)
            withUnsafeBytes(of: (Float(scale.width), Float(scale.height))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            withUnsafeBytes(of: (Float(offset_x), Float(offset_y))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output_texture .width + group_width - 1) / group_width, height: (output_texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func displacementMap(_ displacement: CIImage, _ xChannelSelector: Int, _ yChannelSelector: Int, _ scale: Size) -> CIImage? {
        
        guard 0...3 ~= xChannelSelector && 0...3 ~= yChannelSelector else { return nil }
        
        var extent = self.extent
        
        if extent.isEmpty { return .empty() }
        
        if !extent.isInfinite {
            extent = extent.insetBy(dx: CGFloat(-ceil(abs(0.5 * scale.width))), dy: CGFloat(-ceil(abs(0.5 * scale.height))))
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let selector = SVGDisplacementMapKernel.Selector(x: xChannelSelector, y: yChannelSelector)
        
        var rendered = try? SVGDisplacementMapKernel.apply(withExtent: _extent, inputs: [self, displacement], arguments: ["selector": selector, "scale": scale])
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered
    }
}

#endif
