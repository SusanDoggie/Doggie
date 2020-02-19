//
//  GaussianBlurKernel.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreImage)

extension CIImage {
    
    #if canImport(MetalPerformanceShaders)
    
    @available(macOS 10.13, iOS 10.0, tvOS 10.0, *)
    private class GaussianBlurKernel: CIImageProcessorKernel {
        
        override class func formatForInput(at input: Int32) -> CIFormat {
            return .BGRA8
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard let sigma = arguments?["sigma"] as? Float else { return outputRect }
            return outputRect.insetBy(dx: CGFloat(-ceil(3 * sigma)), dy: CGFloat(-ceil(3 * sigma)))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input = inputs?.first else { return }
            guard let source = input.metalTexture else { return }
            guard let destination = output.metalTexture else { return }
            guard let sigma = arguments?["sigma"] as? Float else { return }
            
            let kernel = MPSImageGaussianBlur(device: commandBuffer.device, sigma: sigma)
            kernel.offset.x = Int(output.region.minX - input.region.minX)
            kernel.offset.y = Int(output.region.minY - input.region.minY)
            
            kernel.encode(commandBuffer: commandBuffer, sourceTexture: source, destinationTexture: destination)
        }
    }
    
    #endif
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func gaussianBlur(sigma: Double) -> CIImage {
        
        #if canImport(MetalPerformanceShaders)
        
        if #available(macOS 10.13, *) {
            
            let inset = -ceil(3 * abs(sigma))
            let extent = self.extent.insetBy(dx: CGFloat(inset), dy: CGFloat(inset))
            let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
            
            if var rendered = try? GaussianBlurKernel.apply(withExtent: _extent, inputs: [self], arguments: ["sigma": Float(abs(sigma))]) {
                
                if !extent.isInfinite {
                    rendered = rendered.cropped(to: extent)
                }
                
                return rendered
            }
        }
        
        #endif
        
        return self.applyingGaussianBlur(sigma: sigma)
    }
}

#endif
