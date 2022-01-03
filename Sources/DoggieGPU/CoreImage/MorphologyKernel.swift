//
//  MorphologyKernel.swift
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

#if canImport(CoreImage) && canImport(MetalPerformanceShaders)

extension CIImage {
    
    @available(macOS 10.13, *)
    private class AreaMinKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard let radius = arguments?["radius"] as? Size else { return outputRect }
            let insetX = -ceil(abs(radius.width))
            let insetY = -ceil(abs(radius.height))
            return outputRect.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetY))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let source_region = inputs?[0].region else { return }
            guard let destination = output.metalTexture else { return }
            guard let radius = arguments?["radius"] as? Size else { return }
            
            let kernelWidth = Int(round(abs(radius.width))) << 1 + 1
            let kernelHeight = Int(round(abs(radius.height))) << 1 + 1
            
            guard let offset_x = Int(exactly: output.region.minX - source_region.minX) else { return }
            guard let offset_y = Int(exactly: source_region.maxY - output.region.maxY) else { return }
            
            let kernel = MPSImageAreaMin(device: commandBuffer.device, kernelWidth: kernelWidth, kernelHeight: kernelHeight)
            kernel.offset.x = offset_x
            kernel.offset.y = offset_y
            
            kernel.encode(commandBuffer: commandBuffer, sourceTexture: source, destinationTexture: destination)
        }
    }
    
    @available(macOS 10.13, *)
    open func areaMin(_ radius: Size) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let areaMin = CIFilter.morphologyRectangleMinimum()
            areaMin.width = Float(abs(radius.width) * 2)
            areaMin.height = Float(abs(radius.height) * 2)
            areaMin.inputImage = self
            
            return areaMin.outputImage ?? .empty()
            
        } else {
            
            let extent = self.extent.insetBy(dx: CGFloat(ceil(abs(radius.width))), dy: CGFloat(ceil(abs(radius.height))))
            
            if extent.isEmpty { return .empty() }
            
            let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
            
            var rendered = try? AreaMinKernel.apply(withExtent: _extent, inputs: [self], arguments: ["radius": radius])
            
            if !extent.isInfinite {
                rendered = rendered?.cropped(to: extent)
            }
            
            return rendered ?? .empty()
        }
    }
}

extension CIImage {
    
    @available(macOS 10.13, *)
    private class AreaMaxKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard let radius = arguments?["radius"] as? Size else { return outputRect }
            let insetX = -ceil(abs(radius.width))
            let insetY = -ceil(abs(radius.height))
            return outputRect.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetY))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let source_region = inputs?[0].region else { return }
            guard let destination = output.metalTexture else { return }
            guard let radius = arguments?["radius"] as? Size else { return }
            
            let kernelWidth = Int(round(abs(radius.width))) << 1 + 1
            let kernelHeight = Int(round(abs(radius.height))) << 1 + 1
            
            guard let offset_x = Int(exactly: output.region.minX - source_region.minX) else { return }
            guard let offset_y = Int(exactly: source_region.maxY - output.region.maxY) else { return }
            
            let kernel = MPSImageAreaMax(device: commandBuffer.device, kernelWidth: kernelWidth, kernelHeight: kernelHeight)
            kernel.offset.x = offset_x
            kernel.offset.y = offset_y
            
            kernel.encode(commandBuffer: commandBuffer, sourceTexture: source, destinationTexture: destination)
        }
    }
    
    @available(macOS 10.13, *)
    open func areaMax(_ radius: Size) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let areaMax = CIFilter.morphologyRectangleMaximum()
            areaMax.width = Float(abs(radius.width) * 2)
            areaMax.height = Float(abs(radius.height) * 2)
            areaMax.inputImage = self
            
            return areaMax.outputImage ?? .empty()
            
        } else {
            
            let extent = self.extent.insetBy(dx: CGFloat(-ceil(abs(radius.width))), dy: CGFloat(-ceil(abs(radius.height))))
            
            let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
            
            var rendered = try? AreaMaxKernel.apply(withExtent: _extent, inputs: [self], arguments: ["radius": radius])
            
            if !extent.isInfinite {
                rendered = rendered?.cropped(to: extent)
            }
            
            return rendered ?? .empty()
        }
    }
}

#endif
