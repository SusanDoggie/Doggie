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
        
        private static let lck = SDLock()
        private static var function_constants: [String: MTLFunctionConstantValues] = [:]
        
        static func make_function_constant(_ orderX: Int, _ orderY: Int) -> MTLFunctionConstantValues {
            
            lck.lock()
            defer { lck.unlock() }
            
            let key = "\(orderX)_\(orderY)"
            
            if let constants = function_constants[key] {
                return constants
            }
            
            let constants = MTLFunctionConstantValues()
            
            withUnsafeBytes(of: Int32(orderX)) { constants.setConstantValue($0.baseAddress!, type: .int, withName: "ORDER_X") }
            withUnsafeBytes(of: Int32(orderY)) { constants.setConstantValue($0.baseAddress!, type: .int, withName: "ORDER_Y") }
            
            function_constants[key] = constants
            
            return constants
        }
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            guard let orderX = arguments?["orderX"] as? Int else { return outputRect }
            guard let orderY = arguments?["orderY"] as? Int else { return outputRect }
            guard let targetX = arguments?["targetX"] as? Int else { return outputRect }
            guard let targetY = arguments?["targetY"] as? Int else { return outputRect }
            guard let preserveAlpha = arguments?["preserveAlpha"] as? Bool else { return outputRect }
            
            guard input == 0 || !preserveAlpha else { return outputRect }
            
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
            guard let source_region = inputs?[0].region else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let matrix = arguments?["matrix"] as? [Float] else { return }
            guard let bias = arguments?["bias"] as? Double else { return }
            guard let orderX = arguments?["orderX"] as? Int else { return }
            guard let orderY = arguments?["orderY"] as? Int else { return }
            guard let preserveAlpha = arguments?["preserveAlpha"] as? Bool else { return }
            guard let unit = arguments?["unit"] as? Size else { return }
            
            let offset_x = Float(output.region.minX - source_region.minX)
            let offset_y = Float(source_region.maxY - output.region.maxY)
            
            let pipeline_name: String
            
            if inputs?.count == 1 {
                pipeline_name = preserveAlpha ? "svg_convolve_none_preserve_alpha" : "svg_convolve_none"
            } else {
                pipeline_name = preserveAlpha ? "svg_convolve_preserve_alpha" : "svg_convolve"
            }
            
            let function_constant = self.make_function_constant(orderX, orderY)
            guard let pipeline = self.make_pipeline(commandBuffer.device, pipeline_name, function_constant) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(input_texture, index: 0)
            encoder.setTexture(output_texture , index: 2)
            matrix.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            withUnsafeBytes(of: Float(bias)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            withUnsafeBytes(of: packed_float2(unit)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
            
            if inputs?.count == 2 {
                encoder.setTexture(inputs?[1].metalTexture , index: 1)
            }
            if pipeline_name == "svg_convolve_none_preserve_alpha" {
                withUnsafeBytes(of: (offset_x, offset_y)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 6) }
            }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output_texture.width + group_width - 1) / group_width, height: (output_texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    open func convolve(_ matrix: [Double], _ bias: Double, _ orderX: Int, _ orderY: Int, _ targetX: Int, _ targetY: Int, _ edgeMode: SVGConvolveMatrixEffect.EdgeMode, _ preserveAlpha: Bool, _ unit: Size = Size(width: 1, height: 1)) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        guard orderX > 0 && orderY > 0 && matrix.count == orderX * orderY else { return .empty() }
        guard 0..<orderX ~= targetX && 0..<orderY ~= targetY else { return .empty() }
        
        let matrix = Array(matrix.chunked(by: orderX).reversed().joined())
        
        var extent = self.extent
        
        if !extent.isInfinite && !preserveAlpha {
            let minX = extent.minX - CGFloat(orderX - targetX - 1) * CGFloat(unit.width)
            let minY = extent.minY - CGFloat(orderY - targetY - 1) * CGFloat(unit.height)
            let width = extent.width + CGFloat(orderX - 1) * CGFloat(unit.width)
            let height = extent.height + CGFloat(orderY - 1) * CGFloat(unit.height)
            extent = CGRect(x: minX, y: minY, width: width, height: height)
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let inputs: [CIImage]
        
        switch edgeMode {
        case .duplicate: inputs = [self.clampedToExtent(), self]
        case .wrap: inputs = [self.wrapTile(), self]
        case .none: inputs = [self]
        }
        
        var rendered = try? SVGConvolveKernel.apply(withExtent: _extent, inputs: inputs, arguments: ["matrix": matrix.map { Float($0) }, "bias": bias, "orderX": orderX, "orderY": orderY, "targetX": targetX, "targetY": targetY, "preserveAlpha": preserveAlpha, "unit": unit])
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

#endif
