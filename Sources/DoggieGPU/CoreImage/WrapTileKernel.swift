//
//  WrapTileKernel.swift
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
    
    private class WrapTileKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            return arguments?["source_extent"] as? CGRect ?? outputRect
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let source_region = inputs?[0].region else { return }
            guard let destination = output.metalTexture else { return }
            
            let offset_x = Float(output.region.minX - source_region.minX)
            let offset_y = Float(source_region.maxY - output.region.maxY)
            
            let device = commandBuffer.device
            
            guard let pipeline = self.make_pipeline(device, "wrap_tile") else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(source, index: 0)
            encoder.setTexture(destination, index: 1)
            withUnsafeBytes(of: (offset_x, offset_y)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (destination.width + group_width - 1) / group_width, height: (destination.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    open func wrapTile() -> CIImage {
        
        if extent.isEmpty { return .empty() }
        if extent.isInfinite { return self }
        
        let rendered = try? WrapTileKernel.apply(withExtent: .infinite, inputs: [self], arguments: ["source_extent": self.extent])
        
        return rendered ?? .empty()
    }
}

#endif
