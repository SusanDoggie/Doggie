//
//  SVGDisplacementMapKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
        
        static let function_constants: [String: MTLFunctionConstantValues] = {
            
            var function_constants: [String: MTLFunctionConstantValues] = [:]
            
            let selector = [
                ("R", 0),
                ("G", 1),
                ("B", 2),
                ("A", 3)
            ]
            
            for (y_selector, y) in selector {
                for (x_selector, x) in selector {
                    
                    let constants = MTLFunctionConstantValues()
                    
                    withUnsafeBytes(of: Int32(x)) { constants.setConstantValue($0.baseAddress!, type: .int, withName: "X_SELECTOR") }
                    withUnsafeBytes(of: Int32(y)) { constants.setConstantValue($0.baseAddress!, type: .int, withName: "Y_SELECTOR") }
                    
                    function_constants["\(x_selector)\(y_selector)"] = constants
                }
            }
            
            return function_constants
        }()
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard input == 0 else { return outputRect }
            guard let scale = arguments?["scale"] as? Size else { return outputRect }
            let insetX = -ceil(abs(0.5 * scale.width))
            let insetY = -ceil(abs(0.5 * scale.height))
            return outputRect.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetY))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let source_region = inputs?[0].region else { return }
            guard let displacement = inputs?[1].metalTexture else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let scale = arguments?["scale"] as? Size else { return }
            guard let selector = arguments?["selector"] as? String else { return }
            
            let offset_x = Float(output.region.minX - source_region.minX)
            let offset_y = Float(source_region.maxY - output.region.maxY)
            
            guard let function_constant = self.function_constants[selector] else { return }
            guard let pipeline = self.make_pipeline(commandBuffer.device, "svg_displacement_map", function_constant) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(source, index: 0)
            encoder.setTexture(displacement, index: 1)
            encoder.setTexture(output_texture , index: 2)
            withUnsafeBytes(of: (offset_x, offset_y)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            withUnsafeBytes(of: packed_float2(scale)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output_texture.width + group_width - 1) / group_width, height: (output_texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    public func displacementMap(_ displacement: CIImage, _ xChannelSelector: Int, _ yChannelSelector: Int, _ scale: Size) -> CIImage {
        
        let x_selector: String
        let y_selector: String
        
        switch xChannelSelector {
        case 0: x_selector = "R"
        case 1: x_selector = "G"
        case 2: x_selector = "B"
        case 3: x_selector = "A"
        default: return .empty()
        }
        
        switch yChannelSelector {
        case 0: y_selector = "R"
        case 1: y_selector = "G"
        case 2: y_selector = "B"
        case 3: y_selector = "A"
        default: return .empty()
        }
        
        let displacement = displacement.unpremultiplyingAlpha()
        
        var extent = self.extent.intersection(displacement.extent)
        
        if extent.isEmpty { return .empty() }
        
        if !extent.isInfinite {
            extent = extent.insetBy(dx: CGFloat(-ceil(abs(0.5 * scale.width))), dy: CGFloat(-ceil(abs(0.5 * scale.height))))
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try? SVGDisplacementMapKernel.apply(withExtent: _extent, inputs: [self, displacement], arguments: ["scale": scale, "selector": "\(x_selector)\(y_selector)"])
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

#endif
