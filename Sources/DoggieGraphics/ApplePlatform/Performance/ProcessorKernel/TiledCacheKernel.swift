//
//  TiledCacheKernel.swift
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

extension CIImage {
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func insertingIntermediate(blockSize: Int, maxBlockSize: Int, colorSpace: ColorSpace<RGBColorModel>?, matchToWorkingSpace: Bool = true) throws -> CIImage {
        
        var image = self
        
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            image = image.insertingIntermediate()
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let info = TiledCacheKernel.Info(image: image, blockSize: min(blockSize, maxBlockSize), maxBlockSize: maxBlockSize, colorSpace: colorSpace)
        var rendered = try TiledCacheKernel.apply(withExtent: _extent, inputs: nil, arguments: ["info": info])
        
        if !extent.isInfinite {
            rendered = rendered.cropped(to: extent)
        }
        
        return matchToWorkingSpace ? colorSpace?.cgColorSpace.flatMap { rendered.matchedToWorkingSpace(from: $0) } ?? rendered : rendered
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
private class TiledCacheKernel: CIImageProcessorKernel {
    
    fileprivate struct Info {
        
        var image: CIImage
        var blockSize: Int
        var maxBlockSize: Int
        
        var colorSpace: ColorSpace<RGBColorModel>?
        
        let cache = Cache()
    }
    
    override class var outputFormat: CIFormat {
        return .BGRA8
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
        
        guard let commandBuffer = output.metalCommandBuffer else { return }
        guard let texture = output.metalTexture else { return }
        guard var info = arguments?["info"] as? Info else { return }
        
        let region = output.region
        let bounds = Rect(x: region.minX, y: -region.minY, width: region.width, height: -region.height)
        
        info.image = info.image.transformed(by: SDTransform.reflectY())
        info.render(to: texture, commandBuffer: commandBuffer, bounds: bounds, workingFormat: output.format)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension TiledCacheKernel.Info {
    
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
        
        var table: [Block: (MTLTexture, Int, Int)] = [:]
        
        subscript(block: Block) -> (MTLTexture, Int, Int)? {
            get {
                return lck.synchronized { table[block] }
            }
            set {
                lck.synchronized { table[block] = newValue }
            }
        }
    }
    
    func make_context(commandQueue: MTLCommandQueue, outputPremultiplied: Bool, workingFormat: CIFormat) -> CIContext? {
        
        cache.lck.lock()
        defer { cache.lck.unlock() }
        
        if cache.pool[commandQueue] == nil {
            cache.pool[commandQueue] = CIContextPool(commandQueue: commandQueue)
        }
        
        return cache.pool[commandQueue]?.makeContext(colorSpace: colorSpace, outputPremultiplied: outputPremultiplied, workingFormat: workingFormat)
    }
    
    func render(to output: MTLTexture, commandBuffer: MTLCommandBuffer, bounds: Rect, workingFormat: CIFormat) {
        
        guard let minX = Int(exactly: floor(bounds.minX)) else { return }
        guard let minY = Int(exactly: floor(bounds.minY)) else { return }
        guard let maxX = Int(exactly: ceil(bounds.maxX)) else { return }
        guard let maxY = Int(exactly: ceil(bounds.maxY)) else { return }
        
        guard let renderer = self.make_context(commandQueue: commandBuffer.commandQueue, outputPremultiplied: true, workingFormat: workingFormat) else { return }
        let workingColorSpace = renderer.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        var need_to_render: [Block] = []
        var blocks: [(Block, (MTLTexture, Int, Int))] = []
        
        for y in stride(from: minY / blockSize * blockSize - blockSize, to: maxY, by: blockSize) {
            for x in stride(from: minX / blockSize * blockSize, to: maxX, by: blockSize) {
                
                let block = Block(x: x, y: y, width: blockSize, height: blockSize)
                
                if let texture = cache[block] {
                    blocks.append((block, texture))
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
        
        if !need_to_render.isEmpty {
            
            let textures: [(Block, MTLTexture)] = need_to_render.compactMap { block in
                
                let extent = Rect(x: block.minX, y: block.minY, width: block.width, height: block.height)
                
                let buffer = MappedBuffer<UInt8>(repeating: 0, count: block.width * block.height * 4, fileBacked: true)
                
                let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: .bgra8Unorm,
                    width: block.width,
                    height: block.height,
                    mipmapped: false)
                descriptor.usage = .shaderWrite
                
                guard let texture = commandBuffer.device.makeTexture(buffer, descriptor: descriptor, bytesPerRow: block.width * 4) else { return nil }
                
                renderer.render(image, to: texture, commandBuffer: commandBuffer, bounds: CGRect(extent), colorSpace: workingColorSpace)
                
                #if os(macOS) || targetEnvironment(macCatalyst)
                
                if texture.storageMode == .managed {
                    let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()
                    blitCommandEncoder?.synchronize(resource: texture)
                    blitCommandEncoder?.endEncoding()
                }
                
                #endif
                
                return (block, texture)
            }
            
            for (block, texture) in textures {
                blocks.append((block, (texture, 0, 0)))
            }
            
            commandBuffer.addCompletedHandler { _ in
                
                for (block, texture) in textures {
                    
                    for y in stride(from: block.minY, to: block.maxY, by: self.blockSize) {
                        for x in stride(from: block.minX, to: block.maxX, by: self.blockSize) {
                            
                            let _block = Block(x: x, y: y, width: self.blockSize, height: self.blockSize)
                            self.cache[_block] = (texture, x - block.minX, y - block.minY)
                        }
                    }
                }
            }
        }
        
        if !blocks.isEmpty {
            
            guard let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder() else { return }
            
            for (block, (texture, offset_x, offset_y)) in blocks {
                
                let _minX = max(block.minX, minX)
                let _minY = max(block.minY, minY)
                let _maxX = min(block.maxX, maxX)
                let _maxY = min(block.maxY, maxY)
                
                let width = _maxX - _minX
                let height = _maxY - _minY
                
                guard width > 0 && height > 0 else { continue }
                
                blitCommandEncoder.copy(
                    from: texture,
                    sourceSlice: 0,
                    sourceLevel: 0,
                    sourceOrigin: MTLOrigin(x: offset_x + _minX - block.minX, y: offset_y + _minY - block.minY, z: 0),
                    sourceSize: MTLSize(width: width, height: height, depth: 1),
                    to: output,
                    destinationSlice: 0,
                    destinationLevel: 0,
                    destinationOrigin: MTLOrigin(x: _minX - minX, y: _minY - minY, z: 0)
                )
            }
            
            blitCommandEncoder.endEncoding()
        }
    }
}

#endif
