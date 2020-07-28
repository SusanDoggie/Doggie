//
//  CIKernelProcessor.swift
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

#if canImport(CoreImage) && canImport(Metal)

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension CIKernel {
    
    open func process(extent: CGRect, roiCallback callback: @escaping CIKernelROICallback = { _, rect in rect }, arguments: [Any], colorSpace: ColorSpace<RGBColorModel>? = nil, matchToWorkingSpace: Bool = true) -> CIImage? {
        
        return try? self._process(extent: extent, roiCallback: callback, arguments: arguments, colorSpace: colorSpace, matchToWorkingSpace: matchToWorkingSpace) {
            
            self.apply(extent: $0, roiCallback: callback, arguments: $1)
        }
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension CIWarpKernel {
    
    open func process(extent: CGRect, roiCallback callback: @escaping CIKernelROICallback = { _, rect in rect }, image: CIImage, arguments: [Any], colorSpace: ColorSpace<RGBColorModel>? = nil, matchToWorkingSpace: Bool = true) -> CIImage? {
        
        return try? self._process(extent: extent, roiCallback: callback, arguments: [image] + arguments, colorSpace: colorSpace, matchToWorkingSpace: matchToWorkingSpace) {
            
            self.apply(extent: $0, roiCallback: callback, image: $1[0] as! CIImage, arguments: Array($1.dropFirst()))
        }
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension CIColorKernel {
    
    open func process(extent: CGRect, arguments: [Any], colorSpace: ColorSpace<RGBColorModel>? = nil, matchToWorkingSpace: Bool = true) -> CIImage? {
        
        return try? self._process(extent: extent, roiCallback: { _, rect in rect }, arguments: arguments, colorSpace: colorSpace, matchToWorkingSpace: matchToWorkingSpace) {
            
            self.apply(extent: $0, arguments: $1)
        }
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension CIKernel {
    
    fileprivate func _process(extent: CGRect, roiCallback: @escaping CIKernelROICallback, arguments: [Any], colorSpace: ColorSpace<RGBColorModel>?, matchToWorkingSpace: Bool, kernel: @escaping (CGRect, [Any]) -> CIImage?) throws -> CIImage {
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        var inputs: [CIImage] = []
        var arguments = arguments
        
        for i in 0..<arguments.count {
            if let input = arguments[i] as? CIImage {
                arguments[i] = CIKernelProcessor.Input(index: inputs.count)
                inputs.append(input)
            }
        }
        
        let info = CIKernelProcessor.Info(kernel: kernel, roiCallback: { roiCallback($0, $1).integral }, arguments: arguments, colorSpace: colorSpace)
        var rendered = try CIKernelProcessor.apply(withExtent: _extent, inputs: inputs, arguments: ["info": info])
        
        if !extent.isInfinite {
            rendered = rendered.cropped(to: extent)
        }
        
        return matchToWorkingSpace ? colorSpace?.cgColorSpace.flatMap { rendered.matchedToWorkingSpace(from: $0) } ?? rendered : rendered
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
private class CIKernelProcessor: CIImageProcessorKernel {
    
    struct Info {
        
        let kernel: (CGRect, [Any]) -> CIImage?
        let roiCallback: CIKernelROICallback
        let arguments: [Any]
        
        var colorSpace: ColorSpace<RGBColorModel>?
        
        let cache = Cache()
    }
    
    struct Input {
        
        var index: Int
    }
    
    class Cache {
        
        let lck = SDLock()
        
        var pool = WeakDictionary<MTLCommandQueue, CIContextPool>()
    }
    
    override class var synchronizeInputs: Bool {
        return false
    }
    
    override class func roi(forInput input: Int32, arguments: [String: Any]?, outputRect: CGRect) -> CGRect {
        guard let info = arguments?["info"] as? Info else { return outputRect }
        return info.roiCallback(input, outputRect)
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
        
        guard let commandBuffer = output.metalCommandBuffer else { return }
        guard let texture = output.metalTexture else { return }
        guard let info = arguments?["info"] as? Info else { return }
        
        guard let minX = Int(exactly: floor(output.region.minX)) else { return }
        guard let minY = Int(exactly: floor(output.region.minY)) else { return }
        guard let maxX = Int(exactly: ceil(output.region.maxX)) else { return }
        guard let maxY = Int(exactly: ceil(output.region.maxY)) else { return }
        
        guard let renderer = info.make_context(commandQueue: commandBuffer.commandQueue, workingFormat: output.format) else { return }
        let workingColorSpace = renderer.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        var arguments = info.arguments
        
        for i in 0..<arguments.count {
            guard let _input = arguments[i] as? Input else { continue }
            guard let input = inputs?[_input.index] else { return }
            guard let texture = input.metalTexture else { return }
            guard let image = CIImage(mtlTexture: texture, options: nil) else { return }
            arguments[i] = image.transformed(by: SDTransform.translate(x: input.region.minX, y: input.region.minY) * SDTransform.reflectY(input.region.midY))
        }
        
        guard let rendered = info.kernel(output.region, arguments) else { return }
        
        let bounds = CGRect(x: 0, y: 0, width: maxX - minX, height: maxY - minY)
        let _image = rendered.transformed(by: SDTransform.reflectY(output.region.midY) * SDTransform.translate(x: -minX, y: -minY))
        
        renderer.render(_image, to: texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: workingColorSpace)
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension CIKernelProcessor.Info {
    
    func make_context(commandQueue: MTLCommandQueue, workingFormat: CIFormat) -> CIContext? {
        
        cache.lck.lock()
        defer { cache.lck.unlock() }
        
        if cache.pool[commandQueue] == nil {
            cache.pool[commandQueue] = CIContextPool(commandQueue: commandQueue)
        }
        
        return cache.pool[commandQueue]?.makeContext(colorSpace: colorSpace, outputPremultiplied: true, workingFormat: workingFormat)
    }
}

#endif
