//
//  PalettizeKernel.swift
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
    
    private class PalettizeKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            if input == 1, let palette_extent = arguments?["palette_extent"] as? CGRect {
                return palette_extent
            }
            
            return outputRect
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input = inputs?[0].metalTexture else { return }
            guard let palette = inputs?[1].metalTexture, palette.width > 0 && palette.height == 1 else { return }
            guard let output = output.metalTexture else { return }
            
            let device = commandBuffer.device
            
            guard let pipeline = self.make_pipeline(device, "palettize") else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(input, index: 0)
            encoder.setTexture(palette, index: 1)
            encoder.setTexture(output, index: 2)
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output.width + group_width - 1) / group_width, height: (output.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    public func palettize(palette: CIImage) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        let rendered = try? PalettizeKernel.apply(withExtent: self.extent, inputs: [self, palette], arguments: ["palette_extent": palette.extent])
        
        return rendered ?? .empty()
    }
    
    public func palettize<C: Collection>(palette: C) -> CIImage where C.Element: ColorPixel, C.Element.Model == RGBColorModel {
        
        if extent.isEmpty { return .empty() }
        
        let _palette = CIImage(
            bitmapData: MappedBuffer(palette).map { Float32ColorPixel($0).premultiplied() }.data,
            bytesPerRow: palette.count * 16,
            size: CGSize(width: palette.count, height: 1),
            format: .RGBAf,
            colorSpace: colorSpace)
        
        return palettize(palette: _palette)
    }
}

#endif
