//
//  ConvolveKernel.swift
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

#if canImport(CoreImage) && canImport(MetalPerformanceShaders)

extension CIImage {
    
    @available(macOS 10.13, iOS 10.0, tvOS 10.0, *)
    private class ConvolveKernel: CIImageProcessorKernel {
        
        override class func formatForInput(at input: Int32) -> CIFormat {
            return .BGRA8
        }
        
        override class var outputFormat: CIFormat {
            return .BGRA8
        }
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
            guard let orderX = arguments?["orderX"] as? Int else { return outputRect }
            guard let orderY = arguments?["orderY"] as? Int else { return outputRect }
            let inset_x = -(orderX + 1) / 2
            let inset_y = -(orderY + 1) / 2
            return outputRect.insetBy(dx: CGFloat(inset_x), dy: CGFloat(inset_y))
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let input = inputs?.first else { return }
            guard let source = input.metalTexture else { return }
            guard let destination = output.metalTexture else { return }
            guard let orderX = arguments?["orderX"] as? Int, orderX > 0 else { return }
            guard let orderY = arguments?["orderY"] as? Int, orderY > 0 else { return }
            guard let matrix = arguments?["matrix"] as? [Double], orderX * orderY == matrix.count else { return }
            guard let bias = arguments?["bias"] as? Double else { return }
            
            let kernel = MPSImageConvolution(device: commandBuffer.device, kernelWidth: orderX, kernelHeight: orderY, weights: matrix.map { Float($0) })
            kernel.offset.x = Int(output.region.minX - input.region.minX)
            kernel.offset.y = Int(output.region.minY - input.region.minY)
            kernel.bias = Float(bias)
            
            kernel.encode(commandBuffer: commandBuffer, sourceTexture: source, destinationTexture: destination)
        }
    }
    
    @available(macOS 10.13, iOS 10.0, tvOS 10.0, *)
    open func convolve(_ matrix: [Double], _ bias: Double, _ orderX: Int, _ orderY: Int) throws -> CIImage {
        
        if extent.isEmpty { return self }
        
        guard orderX > 0 && orderY > 0 && orderX * orderY == matrix.count else { return self }
        
        if orderX > 1 && orderY > 1, let (horizontal, vertical) = separate_convolution_filter(matrix, orderX, orderY) {
            return try self.convolve(horizontal, 0, orderX, 1).convolve(vertical, bias, 1, orderY)
        }
        
        let matrix = Array(matrix.chunked(by: orderX).lazy.map { $0.reversed() }.joined())
        
        let _orderX = orderX | 1
        let _orderY = orderY | 1
        
        guard _orderX <= 9 && _orderY <= 9 else { return self }
        
        let append_x = _orderX - orderX
        let append_y = _orderY - orderY
        
        var _matrix = Array(matrix.chunked(by: orderX).joined(separator: repeatElement(0, count: append_x)))
        _matrix.append(contentsOf: repeatElement(0, count: append_x + _orderX * append_y))
        
        let inset_x = -(_orderX + 1) / 2
        let inset_y = -(_orderY + 1) / 2
        let extent = self.extent.insetBy(dx: CGFloat(inset_x), dy: CGFloat(inset_y))
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var rendered = try ConvolveKernel.apply(withExtent: _extent, inputs: [self], arguments: ["matrix": _matrix, "bias": bias, "orderX": _orderX, "orderY": _orderY])
        
        if !extent.isInfinite {
            rendered = rendered.cropped(to: extent)
        }
        
        return rendered
    }
}

#endif
