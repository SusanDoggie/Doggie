//
//  MetalRenderer.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

#if canImport(Metal)

import Doggie
import Metal

private let MTLCommandQueueCacheLock = SDLock()
private var MTLCommandQueueCache: [NSObject: MTLCommandQueue] = [:]

class MetalRenderer<Model : ColorModelProtocol> : DGRenderer {
    
    let device: MTLDevice
    
    let queue: MTLCommandQueue
    
    let set_opacity: MTLComputePipelineState
    
    let stencil_triangle: MTLComputePipelineState
    let stencil_quadratic: MTLComputePipelineState
    let stencil_cubic: MTLComputePipelineState
    
    let blending: [MetalRendererEncoderBlendMode: MTLComputePipelineState]
    let fill_nonZero_stencil: MTLComputePipelineState
    let fill_evenOdd_stencil: MTLComputePipelineState
    
    required init(device: MTLDevice) throws {
        
        self.device = device
        
        let library = try device.makeDefaultLibrary(bundle: Bundle(for: MetalRenderer.self))
        
        self.stencil_triangle = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_triangle")!)
        self.stencil_quadratic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_quadratic")!)
        self.stencil_cubic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_cubic")!)
        
        let allCompositingMode: [ColorCompositingMode] = [
            .clear,
            .copy,
            .sourceOver,
            .sourceIn,
            .sourceOut,
            .sourceAtop,
            .destinationOver,
            .destinationIn,
            .destinationOut,
            .destinationAtop,
            .xor
        ]
        
        let allBlendMode: [ColorBlendMode] = [
            .normal,
            .multiply,
            .screen,
            .overlay,
            .darken,
            .lighten,
            .colorDodge,
            .colorBurn,
            .softLight,
            .hardLight,
            .difference,
            .exclusion,
            .plusDarker,
            .plusLighter
        ]
        
        let constant = MTLFunctionConstantValues()
        constant.setConstantValue([Int32(Model.numberOfComponents + 1)], type: .int, withName: "countOfComponents")
        
        self.set_opacity = try device.makeComputePipelineState(function: library.makeFunction(name: "set_opacity", constantValues: constant))
        
        constant.setConstantValue([2 as UInt8], type: .uchar, withName: "compositing_mode")
        constant.setConstantValue([0 as UInt8], type: .uchar, withName: "blending_mode")
        
        self.fill_nonZero_stencil = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_nonZero_stencil", constantValues: constant))
        self.fill_evenOdd_stencil = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_evenOdd_stencil", constantValues: constant))
        
        var _blending: [MetalRendererEncoderBlendMode: MTLComputePipelineState] = [:]
        
        for (i, compositing) in allCompositingMode.enumerated() {
            
            constant.setConstantValue([UInt8(i)], type: .uchar, withName: "compositing_mode")
            
            for (j, blending) in allBlendMode.enumerated() {
                
                constant.setConstantValue([UInt8(j)], type: .uchar, withName: "blending_mode")
                
                let key = MetalRendererEncoderBlendMode(compositing: compositing, blending: blending)
                _blending[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "blend", constantValues: constant))
            }
        }
        
        self.blending = _blending
        
        self.queue = try MetalRenderer.make_queue(device: device)
    }
    
    static func make_queue(device: MTLDevice) throws -> MTLCommandQueue {
        
        MTLCommandQueueCacheLock.lock()
        defer { MTLCommandQueueCacheLock.unlock() }
        
        let key = device as! NSObject
        
        if let queue = MTLCommandQueueCache[key] {
            return queue
        }
        
        guard let queue = device.makeCommandQueue() else { throw Error(description: "MTLDevice.makeCommandQueue failed.") }
        MTLCommandQueueCache[key] = queue
        
        return queue
    }
    
    func encoder(width: Int, height: Int) throws -> MetalRendererEncoder<Model> {
        guard let commandBuffer = queue.makeCommandBuffer() else { throw Error(description: "MTLCommandQueue.makeCommandBuffer failed.") }
        return MetalRendererEncoder(width: width, height: height, renderer: self, commandBuffer: commandBuffer)
    }
}

extension MetalRenderer {
    
    struct Error: Swift.Error, CustomStringConvertible {
        
        var description: String
    }
}

extension DGImageContext {
    
    public func render(device: MTLDevice = MTLCreateSystemDefaultDevice()!) throws {
        try self.render(device, MetalRenderer.self)
    }
    
    public func image(device: MTLDevice = MTLCreateSystemDefaultDevice()!) throws -> Image<FloatColorPixel<Model>> {
        return try self.image(device, MetalRenderer.self)
    }
}

#endif
