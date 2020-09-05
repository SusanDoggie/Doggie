//
//  SVGConvolveKernel.swift
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
    
    private class SVGConvolveKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            guard let orderX = arguments?["orderX"] as? Int else { return outputRect }
            guard let orderY = arguments?["orderY"] as? Int else { return outputRect }
            guard let targetX = arguments?["targetX"] as? Int else { return outputRect }
            guard let targetY = arguments?["targetY"] as? Int else { return outputRect }
            
            let unit = arguments?["unit"] as? Size ?? Size(width: 1, height: 1)
            
            let minX = outputRect.minX - CGFloat(targetX) * CGFloat(unit.width)
            let minY = outputRect.minY - CGFloat(targetY) * CGFloat(unit.height)
            let width = outputRect.width + CGFloat(orderX - 1) * CGFloat(unit.width)
            let height = outputRect.height + CGFloat(orderY - 1) * CGFloat(unit.height)
            
            return CGRect(x: minX, y: minY, width: width, height: height)
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input_texture = inputs?[0].metalTexture else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let matrix = arguments?["matrix"] as? [Float] else { return }
            guard let bias = arguments?["bias"] as? Double else { return }
            guard let orderX = arguments?["orderX"] as? Int else { return }
            guard let orderY = arguments?["orderY"] as? Int else { return }
            guard let targetX = arguments?["targetX"] as? Int else { return }
            guard let targetY = arguments?["targetY"] as? Int else { return }
            guard let edgeMode = arguments?["edgeMode"] as? String else { return }
            guard let preserveAlpha = arguments?["preserveAlpha"] as? Bool else { return }
            guard let unit = arguments?["unit"] as? Size else { return }
            
            guard let pipeline = self.make_pipeline(commandBuffer.device, preserveAlpha ? "svg_convolve_\(edgeMode)_preserve_alpha" : "svg_convolve_\(edgeMode)") else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(input_texture, index: 0)
            encoder.setTexture(output_texture , index: 1)
            matrix.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            withUnsafeBytes(of: Float(bias)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            withUnsafeBytes(of: (UInt32(orderX), UInt32(orderY))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            withUnsafeBytes(of: (Float(targetX), Float(targetY))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
            withUnsafeBytes(of: (Float(unit.width), Float(unit.height))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 6) }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output_texture.width + group_width - 1) / group_width, height: (output_texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    open func convolve(_ matrix: [Double], _ bias: Double, _ orderX: Int, _ orderY: Int, _ targetX: Int, _ targetY: Int, _ edgeMode: SVGConvolveMatrixEffect.EdgeMode, _ preserveAlpha: Bool, _ unit: Size = Size(width: 1, height: 1)) throws -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        guard orderX > 0 && orderY > 0 && matrix.count == orderX * orderY else { return .empty() }
        
        let matrix = Array(matrix.chunked(by: orderX).reversed().joined())
        
        var extent = self.extent
        
        if !extent.isInfinite && !preserveAlpha {
            let minX = extent.minX - CGFloat(targetX) * CGFloat(unit.width)
            let minY = extent.minY - CGFloat(targetY) * CGFloat(unit.height)
            let width = extent.width + CGFloat(orderX - 1) * CGFloat(unit.width)
            let height = extent.height + CGFloat(orderY - 1) * CGFloat(unit.height)
            extent = CGRect(x: minX, y: minY, width: width, height: height)
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let edge_mode: String
        
        switch edgeMode {
        case .duplicate: edge_mode = "duplicate"
        case .wrap: edge_mode = "wrap"
        case .none: edge_mode = "none"
        }
        
        var rendered = try SVGConvolveKernel.apply(withExtent: _extent, inputs: [self], arguments: ["matrix": matrix.map { Float($0) }, "bias": bias, "orderX": orderX, "orderY": orderY, "targetX": targetX, "targetY": targetY, "edgeMode": edge_mode, "preserveAlpha": preserveAlpha, "unit": unit])
        
        if !extent.isInfinite {
            rendered = rendered.cropped(to: extent)
        }
        
        return rendered.premultiplyingAlpha()
    }
}

#endif
