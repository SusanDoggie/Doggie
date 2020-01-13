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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreImage)

extension CIImage {
    
    open func insertingIntermediate(blockSize: Int, maxBlockSize: Int, colorSpace: ColorSpace<RGBColorModel>?, matchToWorkingSpace: Bool = true) throws -> CIImage {
        
        var image = self
        
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            image = image.insertingIntermediate()
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        
        let info = TiledCacheKernel.Info(image: image, blockSize: min(blockSize, maxBlockSize), maxBlockSize: maxBlockSize, colorSpace: colorSpace)
        var rendered = try TiledCacheKernel.apply(withExtent: _extent, inputs: nil, arguments: ["info": info])
        
        if !extent.isInfinite {
            rendered = rendered.clamped(to: extent).cropped(to: extent)
        }
        
        return matchToWorkingSpace ? colorSpace?.cgColorSpace.flatMap { rendered.matchedToWorkingSpace(from: $0) } ?? rendered : rendered
    }
}

private class TiledCacheKernel: CIImageProcessorKernel {
    
    fileprivate struct Info {
        
        let image: CIImage
        let blockSize: Int
        let maxBlockSize: Int
        
        let colorSpace: ColorSpace<RGBColorModel>?
        
        let cache = Cache()
        let pool = CIContextPool()
    }
    
    override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String : Any]?, output: CIImageProcessorOutput) throws {
        guard let info = arguments?["info"] as? Info else { return }
        info.render(to: output.surface, bounds: Rect(output.region))
    }
}

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
    
    func render(to surface: IOSurfaceRef, bounds: Rect) {
        
        guard let renderer = pool.makeContext(colorSpace: colorSpace, outputPremultiplied: true) else { return }
        let workingColorSpace = renderer.workingColorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        if blockSize <= 1 {
            renderer.render(image, to: surface, bounds: CGRect(bounds), colorSpace: workingColorSpace)
            return
        }
        
        guard let texture_renderer = colorSpace == nil ? renderer : pool.makeContext(colorSpace: colorSpace, outputPremultiplied: false) else { return }
        
        guard let minX = Int(exactly: floor(bounds.minX)) else { return }
        guard let minY = Int(exactly: floor(bounds.minY)) else { return }
        guard let maxX = Int(exactly: ceil(bounds.maxX)) else { return }
        guard let maxY = Int(exactly: ceil(bounds.maxY)) else { return }
        
        var need_to_render: [Block] = []
        var blocks: [(Block, CIImage)] = []
        
        let _minX = minX / blockSize * blockSize
        let _minY = minY / blockSize * blockSize
        
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
                    
                    let rendered = texture_renderer.createImage(self.image, from: extent, colorSpace: colorSpace, fileBacked: true)
                    return rendered?.cgImage
                    
                } else {
                    
                    let rendered = texture_renderer.createCGImage(self.image, from: CGRect(extent))
                    return rendered?.fileBacked() ?? rendered
                }
            }
            
            guard let image = _image else { continue }
            
            blocks.append((block, CIImage(cgImage: image)))
            
            for y in stride(from: block.minY, to: block.maxY, by: blockSize) {
                for x in stride(from: block.minX, to: block.maxX, by: blockSize) {
                    
                    let crop_zone = CGRect(x: x - block.minX, y: block.maxY - y - blockSize, width: blockSize, height: blockSize)
                    guard let cropped = image.cropping(to: crop_zone) else { continue }
                    
                    var texture = CIImage(cgImage: cropped)
                    
                    if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
                        texture = texture.insertingIntermediate()
                    }
                    
                    let block = Block(x: x, y: y, width: blockSize, height: blockSize)
                    cache[block] = texture
                }
            }
        }
        
        for (block, image) in blocks {
            
            let _minX = max(0, block.minX - minX)
            let _minY = max(0, block.minY - minY)
            let _maxX = min(maxX - minX, block.maxX - minX)
            let _maxY = min(maxY - minY, block.maxY - minY)
            
            let width = _maxX - _minX
            let height = _maxY - _minY
            
            guard width > 0 && height > 0 else { return }
            
            let bounds = CGRect(x: _minX, y: _minY, width: width, height: height)
            let _image = image.transformed(by: SDTransform.translate(x: Double(block.minX - minX), y: Double(block.minY - minY)))
            
            renderer.render(_image, to: surface, bounds: bounds, colorSpace: workingColorSpace)
        }
    }
}

#endif
