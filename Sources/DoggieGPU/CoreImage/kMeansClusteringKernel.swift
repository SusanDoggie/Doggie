//
//  kMeansClusteringKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
    
    private class kMeansClusteringKernel: CIImageProcessorKernel {
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            
            switch input {
            case 0: return arguments?["image_extent"] as? CGRect ?? outputRect
            case 1: return arguments?["palette_extent"] as? CGRect ?? outputRect
            default: return outputRect
            }
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input = inputs?[0].metalTexture else { return }
            guard var palette = inputs?[1].metalTexture, palette.width > 0 && palette.height == 1 else { return }
            guard let output = output.metalTexture else { return }
            guard let passes = arguments?["passes"] as? Int else { return }
            
            let device = commandBuffer.device
            
            guard let k_means_clustering_row = self.make_pipeline(device, "k_means_clustering_row") else { return }
            guard let k_means_clustering = self.make_pipeline(device, "k_means_clustering") else { return }
            
            guard let palette_table = device.makeBuffer(length: palette.width * 16 * input.height, options: .storageModePrivate) else { return }
            guard let counter = device.makeBuffer(length: palette.width * 4 * input.height, options: .storageModePrivate) else { return }
            
            for _ in 0..<passes {
                
                do {
                    
                    guard let encoder = commandBuffer.makeBlitCommandEncoder() else { return }
                    
                    encoder.fill(buffer: palette_table, range: 0..<palette_table.length, value: 0)
                    encoder.fill(buffer: counter, range: 0..<counter.length, value: 0)
                    encoder.endEncoding()
                }
                
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
                
                do {
                    
                    encoder.setComputePipelineState(k_means_clustering_row)
                    
                    encoder.setTexture(input, index: 0)
                    encoder.setTexture(palette, index: 1)
                    encoder.setBuffer(palette_table, offset: 0, index: 2)
                    encoder.setBuffer(counter, offset: 0, index: 3)
                    
                    let maxTotalThreadsPerThreadgroup = max(1, k_means_clustering_row.maxTotalThreadsPerThreadgroup)
                    
                    let threadsPerThreadgroup = MTLSize(width: maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
                    let threadgroupsPerGrid = MTLSize(width: (input.height + maxTotalThreadsPerThreadgroup - 1) / maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
                    
                    encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
                }
                
                do {
                    
                    encoder.setComputePipelineState(k_means_clustering)
                    
                    encoder.setBuffer(palette_table, offset: 0, index: 0)
                    encoder.setBuffer(counter, offset: 0, index: 1)
                    encoder.setTexture(output, index: 2)
                    withUnsafeBytes(of: Int32(input.height)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
                    
                    let maxTotalThreadsPerThreadgroup = max(1, k_means_clustering.maxTotalThreadsPerThreadgroup)
                    
                    let threadsPerThreadgroup = MTLSize(width: maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
                    let threadgroupsPerGrid = MTLSize(width: (palette.width + maxTotalThreadsPerThreadgroup - 1) / maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
                    
                    encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
                }
                
                encoder.endEncoding()
                
                palette = output
            }
        }
    }
    
    public func kMeansClustering(palette: CIImage, passes: Int) -> CIImage {
        
        let rendered = try? kMeansClusteringKernel.apply(withExtent: palette.extent, inputs: [self, palette], arguments: ["image_extent": self.extent, "palette_extent": palette.extent, "passes": passes])
        
        return rendered ?? .empty()
    }
    
    public func kMeansClustering<C: Collection>(palette: C, passes: Int) -> CIImage where C.Element: ColorPixel, C.Element.Model == RGBColorModel {
        
        let _palette = CIImage(
            bitmapData: MappedBuffer(palette).map { Float32ColorPixel($0).premultiplied() }.data,
            bytesPerRow: palette.count * 16,
            size: CGSize(width: palette.count, height: 1),
            format: .RGBAf,
            colorSpace: colorSpace)
        
        return kMeansClustering(palette: _palette, passes: passes)
    }
}

#endif
