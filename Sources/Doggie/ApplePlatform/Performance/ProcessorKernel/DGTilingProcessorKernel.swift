//
//  DGTilingProcessorKernel.swift
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

#if canImport(CoreImage) && canImport(Metal)

extension CIImage {
    
    @available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
    open func tiling(blockSize: Int, colorSpace: ColorSpace<RGBColorModel>?, matchToWorkingSpace: Bool = true) throws -> CIImage {
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let info = DGTilingProcessorKernel.Info(image: self, blockSize: blockSize, colorSpace: colorSpace)
        var rendered = try DGTilingProcessorKernel.apply(withExtent: _extent, inputs: nil, arguments: ["info": info])
        
        if !extent.isInfinite {
            rendered = rendered.clamped(to: extent).cropped(to: extent)
        }
        
        return matchToWorkingSpace ? colorSpace?.cgColorSpace.flatMap { rendered.matchedToWorkingSpace(from: $0) } ?? rendered : rendered
    }
}

@available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
private class DGTilingProcessorKernel: CIImageProcessorKernel {
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String : Any]?, output: CIImageProcessorOutput) throws {
        
        guard let commandBuffer = output.metalCommandBuffer else { return }
        guard let texture = output.metalTexture else { return }
        guard let info = arguments?["info"] as? Info else { return }
        
        guard let renderer = info.make_context(commandQueue: commandBuffer.commandQueue, outputPremultiplied: true) else { return }
        let colorSpace = renderer.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        guard let minX = Int(exactly: floor(output.region.minX)) else { return }
        guard let minY = Int(exactly: floor(output.region.minY)) else { return }
        guard let maxX = Int(exactly: ceil(output.region.maxX)) else { return }
        guard let maxY = Int(exactly: ceil(output.region.maxY)) else { return }
        
        var image = info.image.transformed(by: SDTransform.reflectY(output.region.midY))
        
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            image = image.insertingIntermediate()
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: texture.pixelFormat,
            width: min(maxX - minX, info.blockSize),
            height: min(maxY - minY, info.blockSize),
            mipmapped: false)
        descriptor.storageMode = .private
        descriptor.usage = .shaderWrite
        
        guard let buffer = commandBuffer.device.makeTexture(descriptor: descriptor) else { return }
        
        for y in stride(from: minY, to: maxY, by: info.blockSize) {
            for x in stride(from: minX, to: maxX, by: info.blockSize) {
                
                let _minX = max(0, x - minX)
                let _minY = max(0, y - minY)
                let _maxX = min(texture.width, x + buffer.width - minX)
                let _maxY = min(texture.height, y + buffer.height - minY)
                
                let width = _maxX - _minX
                let height = _maxY - _minY
                
                guard width > 0 && height > 0 else { continue }
                
                let block = CGRect(x: x, y: y, width: width, height: height)
                renderer.render(image, to: buffer, commandBuffer: commandBuffer, bounds: block, colorSpace: colorSpace)
                
                let sourceOrigin = MTLOrigin(x: 0, y: 0, z: 0)
                let sourceSize = MTLSize(width: width, height: height, depth: 1)
                
                let destinationOrigin = MTLOrigin(x: _minX, y: _minY, z: 0)
                
                guard let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else { continue }
                
                blitCommandEncoder.copy(
                    from: buffer,
                    sourceSlice: 0,
                    sourceLevel: 0,
                    sourceOrigin: sourceOrigin,
                    sourceSize: sourceSize,
                    to: texture,
                    destinationSlice: 0,
                    destinationLevel: 0,
                    destinationOrigin: destinationOrigin
                )
                
                blitCommandEncoder.endEncoding()
            }
        }
    }
}

@available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
extension DGTilingProcessorKernel {
    
    struct Info {
        
        let image: CIImage
        let blockSize: Int
        
        let colorSpace: ColorSpace<RGBColorModel>?
        
        let cache = Cache()
    }
    
    class Cache {
        
        let lck = SDLock()
        
        var pool = WeakDictionary<MTLCommandQueue, CIContextPool>()
    }
}

@available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
extension DGTilingProcessorKernel.Info {
    
    func make_context(commandQueue: MTLCommandQueue, outputPremultiplied: Bool) -> CIContext? {
        
        cache.lck.lock()
        defer { cache.lck.unlock() }
        
        if cache.pool[commandQueue] == nil {
            cache.pool[commandQueue] = CIContextPool(commandQueue: commandQueue)
        }
        
        return cache.pool[commandQueue]?.makeContext(colorSpace: colorSpace, outputPremultiplied: outputPremultiplied)
    }
}

#endif
