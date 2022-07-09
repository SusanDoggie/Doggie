//
//  BilateralFilter.swift
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
    
    private class BilateralKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard let spatial = arguments?["spatial"] as? Size else { return outputRect }
            let insetX = -ceil(1 * abs(spatial.width))
            let insetY = -ceil(1 * abs(spatial.height))
            return outputRect.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetY))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let source_region = inputs?[0].region else { return }
            guard let destination = output.metalTexture else { return }
            guard let spatial = arguments?["spatial"] as? Size else { return }
            guard let range = arguments?["range"] as? Double else { return }
            
            guard let offset_x = UInt32(exactly: output.region.minX - source_region.minX) else { return }
            guard let offset_y = UInt32(exactly: source_region.maxY - output.region.maxY) else { return }
            
            guard let range_x = Int(exactly: source_region.width - output.region.width) else { return }
            guard let range_y = Int(exactly: source_region.height - output.region.height) else { return }
            
            let c0 = -0.5 / Float(spatial.width * spatial.width);
            let c1 = -0.5 / Float(spatial.height * spatial.height);
            let weight_x = (0..<range_x).map { $0 - Int(offset_x) }.map { exp(c0 * Float($0 * $0)) }
            let weight_y = (0..<range_y).map { $0 - Int(offset_y) }.map { exp(c1 * Float($0 * $0)) }
            
            let device = commandBuffer.device
            
            guard let pipeline = self.make_pipeline(device, "bilateral_filter") else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(source, index: 0)
            encoder.setTexture(destination, index: 1)
            withUnsafeBytes(of: (offset_x, offset_y)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            weight_x.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            weight_y.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            withUnsafeBytes(of: Float(range)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (destination.width + group_width - 1) / group_width, height: (destination.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    public func bilateralFilter(_ spatial: Size, _ range: Double) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        let extent = self.extent.insetBy(dx: CGFloat(-ceil(3 * abs(spatial.width))), dy: CGFloat(-ceil(3 * abs(spatial.height))))
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try? BilateralKernel.apply(withExtent: _extent, inputs: [self.unpremultiplyingAlpha()], arguments: ["spatial": spatial, "range": range]).premultiplyingAlpha()
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

#endif
