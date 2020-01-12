//
//  DGCacheProcessorKernel.swift
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
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func insertingIntermediate(blockSize: Int, maxBlockSize: Int, colorSpace: ColorSpace<RGBColorModel>?, matchToWorkingSpace: Bool = true) throws -> CIImage {
        
        var image = self
        
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            image = image.insertingIntermediate()
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let info = DGCacheProcessorKernel.Info(image: image, blockSize: min(blockSize, maxBlockSize), maxBlockSize: maxBlockSize, colorSpace: colorSpace)
        var rendered = try DGCacheProcessorKernel.apply(withExtent: _extent, inputs: nil, arguments: ["info": info])
        
        if !extent.isInfinite {
            rendered = rendered.clamped(to: extent).cropped(to: extent)
        }
        
        return matchToWorkingSpace ? colorSpace?.cgColorSpace.flatMap { rendered.matchedToWorkingSpace(from: $0) } ?? rendered : rendered
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
private class DGCacheProcessorKernel: CIImageProcessorKernel {
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String : Any]?, output: CIImageProcessorOutput) throws {
        
        guard let commandBuffer = output.metalCommandBuffer else { return }
        guard let texture = output.metalTexture else { return }
        guard var info = arguments?["info"] as? Info else { return }
        
        let region = output.region
        let bounds = Rect(x: region.minX, y: -region.minY, width: region.width, height: -region.height)
        
        info.image = info.image.transformed(by: SDTransform.reflectY())
        info.render(to: texture, commandBuffer: commandBuffer, bounds: bounds)
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension DGCacheProcessorKernel {
    
    fileprivate struct Info {
        
        var image: CIImage
        let blockSize: Int
        let maxBlockSize: Int
        
        let colorSpace: ColorSpace<RGBColorModel>?
        
        let cache = Cache()
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
extension DGCacheProcessorKernel.Info {
    
    struct Block: Hashable {
        
        var minX: Int
        var minY: Int
        var maxX: Int
        var maxY: Int
        
        init(x: Int, y: Int, width: Int, height: Int) {
            self.minX = x
            self.minY = y
            self.maxX = x + width
            self.maxY = y + height
        }
        
        init(minX: Int, minY: Int, maxX: Int, maxY: Int) {
            self.minX = minX
            self.minY = minY
            self.maxX = maxX
            self.maxY = maxY
        }
        
        var width: Int {
            return maxX - minX
        }
        
        var height: Int {
            return maxY - minY
        }
    }
    
    class Cache {
        
        let lck = SDLock()
        
        var pool = WeakDictionary<MTLCommandQueue, CIContextPool>()
        
        var table: [Block: CIImage] = [:]
        
        subscript(block: Block) -> CIImage? {
            get {
                return lck.synchronized { table[block] }
            }
            set {
                lck.synchronized { table[block] = newValue }
            }
        }
    }
    
    func make_context(commandQueue: MTLCommandQueue, outputPremultiplied: Bool) -> CIContext? {
        
        cache.lck.lock()
        defer { cache.lck.unlock() }
        
        if cache.pool[commandQueue] == nil {
            cache.pool[commandQueue] = CIContextPool(commandQueue: commandQueue)
        }
        
        return cache.pool[commandQueue]?.makeContext(colorSpace: colorSpace, outputPremultiplied: outputPremultiplied)
    }
    
    func render(to texture: MTLTexture, commandBuffer: MTLCommandBuffer, bounds: Rect) {
        
        guard let renderer = self.make_context(commandQueue: commandBuffer.commandQueue, outputPremultiplied: colorSpace == nil) else { return }
        guard let texture_renderer = colorSpace == nil ? renderer : self.make_context(commandQueue: commandBuffer.commandQueue, outputPremultiplied: true) else { return }
        let workingColorSpace = texture_renderer.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        guard let minX = Int(exactly: floor(bounds.minX)) else { return }
        guard let minY = Int(exactly: floor(bounds.minY)) else { return }
        guard let maxX = Int(exactly: ceil(bounds.maxX)) else { return }
        guard let maxY = Int(exactly: ceil(bounds.maxY)) else { return }
        
        var need_to_render: [Block] = []
        var blocks: [(Block, CIImage)] = []
        
        let _minX = minX / blockSize * blockSize
        let _minY = minY / blockSize * blockSize - blockSize
        
        for y in stride(from: _minY, to: maxY, by: blockSize) {
            for x in stride(from: _minX, to: maxX, by: blockSize) {
                
                let block = Block(x: x, y: y, width: blockSize, height: blockSize)
                
                if let image = cache[block] {
                    blocks.append((block, image))
                } else {
                    need_to_render.append(block)
                }
            }
        }
        
        do {
            var _need_to_render: [Block] = need_to_render.reversed()
            need_to_render = []
            while let block = _need_to_render.popLast() {
                
                if let index = need_to_render.firstIndex(where: { $0.maxX == block.minX && $0.minY == block.minY && $0.maxY == block.maxY }), block.maxX - need_to_render[index].minX <= maxBlockSize {
                    
                    let block2 = need_to_render.remove(at: index)
                    need_to_render.append(Block(minX: block2.minX, minY: block.minY, maxX: block.maxX, maxY: block.maxY))
                    
                } else {
                    need_to_render.append(block)
                }
            }
        }
        
        do {
            var _need_to_render: [Block] = need_to_render.reversed()
            need_to_render = []
            while let block = _need_to_render.popLast() {
                
                if let index = need_to_render.firstIndex(where: { $0.maxY == block.minY && $0.minX == block.minX && $0.maxX == block.maxX }), block.maxY - need_to_render[index].minY <= maxBlockSize {
                    
                    let block2 = need_to_render.remove(at: index)
                    need_to_render.append(Block(minX: block.minX, minY: block2.minY, maxX: block.maxX, maxY: block.maxY))
                    
                } else {
                    need_to_render.append(block)
                }
            }
        }
        
        for block in need_to_render {
            
            let _image: CGImage? = autoreleasepool {
                
                let extent = Rect(x: block.minX, y: block.minY, width: block.width, height: block.height)
                
                if let colorSpace = colorSpace {
                    
                    let rendered = renderer.createImage(self.image, from: extent, colorSpace: colorSpace, fileBacked: true)
                    return rendered?.cgImage
                    
                } else {
                    
                    let rendered = renderer.createCGImage(self.image, from: CGRect(extent))
                    return rendered?.fileBacked() ?? rendered
                }
            }
            
            guard let image = _image else { continue }
            
            let translate = SDTransform.translate(x: Double(block.minX), y: Double(block.minY))
            blocks.append((block, CIImage(cgImage: image).transformed(by: translate)))
            
            for y in stride(from: block.minY, to: block.maxY, by: blockSize) {
                for x in stride(from: block.minX, to: block.maxX, by: blockSize) {
                    
                    let crop_zone = CGRect(x: x - block.minX, y: block.maxY - y - blockSize, width: blockSize, height: blockSize)
                    guard let cropped = image.cropping(to: crop_zone) else { continue }
                    
                    let translate = SDTransform.translate(x: Double(x), y: Double(y))
                    var texture = CIImage(cgImage: cropped).transformed(by: translate)
                    
                    if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
                        texture = texture.insertingIntermediate()
                    }
                    
                    let block = Block(x: x, y: y, width: blockSize, height: blockSize)
                    cache[block] = texture
                }
            }
        }
        
        guard let max_width = blocks.lazy.map({ $0.0.width }).max() else { return }
        guard let max_height = blocks.lazy.map({ $0.0.height }).max() else { return }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: texture.pixelFormat,
            width: max_width,
            height: max_height,
            mipmapped: false)
        descriptor.storageMode = .private
        descriptor.usage = .shaderWrite
        
        guard let buffer = commandBuffer.device.makeTexture(descriptor: descriptor) else { return }
        
        for (block, image) in blocks {
            
            let _minX = max(0, block.minX - minX)
            let _minY = max(0, block.minY - minY)
            let _maxX = min(texture.width, block.maxX - minX)
            let _maxY = min(texture.height, block.maxY - minY)
            
            let width = _maxX - _minX
            let height = _maxY - _minY
            
            guard width > 0 && height > 0 else { return }
            
            let block = CGRect(x: _minX + minX, y: _minY + minY, width: width, height: height)
            texture_renderer.render(image, to: buffer, commandBuffer: commandBuffer, bounds: block, colorSpace: workingColorSpace)
            
            let sourceOrigin = MTLOrigin(x: 0, y: 0, z: 0)
            let sourceSize = MTLSize(width: width, height: height, depth: 1)
            
            let destinationOrigin = MTLOrigin(x: _minX, y: _minY, z: 0)
            
            guard let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
            
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

#endif
