//
//  Composer.swift
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

private let DGImageContextComposerPipelineCacheLock = SDLock()

private var DGImageContextComposerPipelineCache: [NSObject: [Any]] = [:]

struct DGImageContextComposerPipeline<Model: ColorModelProtocol> {
    
    struct BlendMode : Hashable {
        
        var compositing: ColorCompositingMode
        var blending: ColorBlendMode
    }
    
    let set_opacity: MTLComputePipelineState
    
    let stencil_triangle: MTLComputePipelineState
    let stencil_quadratic: MTLComputePipelineState
    let stencil_cubic: MTLComputePipelineState
    
    let blending: [BlendMode: MTLComputePipelineState]
    let fill_nonZero_stencil: [BlendMode: MTLComputePipelineState]
    let fill_evenOdd_stencil: [BlendMode: MTLComputePipelineState]
    
    init(device: MTLDevice, library: () throws -> MTLLibrary) throws {
        
        DGImageContextComposerPipelineCacheLock.lock()
        defer { DGImageContextComposerPipelineCacheLock.unlock() }
        
        if let device = device as? NSObject, let cached = DGImageContextComposerPipelineCache[device]?.first(where: { $0 is DGImageContextComposerPipeline }) as? DGImageContextComposerPipeline {
            self = cached
            return
        }
        
        let library = try library()
        
        self.stencil_triangle = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_triangle")!)
        self.stencil_quadratic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_quadratic")!)
        self.stencil_cubic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_cubic")!)
        
        var _blending: [BlendMode: MTLComputePipelineState] = [:]
        var _fill_nonZero_stencil: [BlendMode: MTLComputePipelineState] = [:]
        var _fill_evenOdd_stencil: [BlendMode: MTLComputePipelineState] = [:]
        
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
        
        for (i, compositing) in allCompositingMode.enumerated() {
            
            constant.setConstantValue([UInt8(i)], type: .uchar, withName: "compositing_mode")
            
            for (j, blending) in allBlendMode.enumerated() {
                
                constant.setConstantValue([UInt8(j)], type: .uchar, withName: "blending_mode")
                
                let key = BlendMode(compositing: compositing, blending: blending)
                _blending[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "blend", constantValues: constant))
                _fill_nonZero_stencil[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_nonZero_stencil", constantValues: constant))
                _fill_evenOdd_stencil[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_evenOdd_stencil", constantValues: constant))
            }
        }
        
        self.blending = _blending
        self.fill_nonZero_stencil = _fill_nonZero_stencil
        self.fill_evenOdd_stencil = _fill_evenOdd_stencil
        
        if let device = device as? NSObject {
            DGImageContextComposerPipelineCache[device, default: []].append(self)
        }
    }
}

extension DGImageContext {
    
    class Composer {
        
        let device: MTLDevice
        
        let pipeline: DGImageContextComposerPipeline<Model>
        
        init(device: MTLDevice) throws {
            self.device = device
            self.pipeline = try DGImageContextComposerPipeline(device: device, library: { try device.makeDefaultLibrary(bundle: Bundle(for: Composer.self)) })
        }
        
        typealias BlendMode = DGImageContextComposerPipeline<Model>.BlendMode
        
        var set_opacity: MTLComputePipelineState {
            return pipeline.set_opacity
        }
        
        var stencil_triangle: MTLComputePipelineState {
            return pipeline.stencil_triangle
        }
        var stencil_quadratic: MTLComputePipelineState {
            return pipeline.stencil_quadratic
        }
        var stencil_cubic: MTLComputePipelineState {
            return pipeline.stencil_cubic
        }
        
        var blending: [BlendMode: MTLComputePipelineState] {
            return pipeline.blending
        }
        var fill_nonZero_stencil: [BlendMode: MTLComputePipelineState] {
            return pipeline.fill_nonZero_stencil
        }
        var fill_evenOdd_stencil: [BlendMode: MTLComputePipelineState] {
            return pipeline.fill_evenOdd_stencil
        }
        
    }
}

extension DGImageContext {
    
    public struct Error: Swift.Error, CustomStringConvertible {
        
        public var description: String
    }
    
    public func render() throws {
        
        guard self._image.cached_image == nil else { return }
        
        guard let queue = composer.device.makeCommandQueue(maxCommandBufferCount: self._image.operations_count) else { throw Error(description: "MTLDevice.makeCommandQueue failed.") }
        guard let commandBuffer = queue.makeCommandBuffer() else { throw Error(description: "MTLDevice.makeCommandBuffer failed.") }
        
        let texture = Texture<FloatColorPixel<Model>>(width: width, height: height, option: .inMemory)
        guard let buffer = composer.device.makeBuffer(texture.pixels) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
        
        try self._image.render(width: width, height: height, global_opacity: 1, composer: composer, commandBuffer: commandBuffer, output: buffer)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        self._image = TextureLayer(texture)
    }
    
    public func image() throws -> Image<FloatColorPixel<Model>> {
        try self.render()
        return Image(texture: self._image.cached_image!, resolution: resolution, colorSpace: colorSpace)
    }
}

extension DGImageContext {
    
    static var pixel_size: Int {
        return Model.numberOfComponents << 2 + 4
    }
    
    class Layer {
        
        var is_empty: Bool {
            return true
        }
        
        var operations_count: Int {
            return 0
        }
        
        var cached_image: Texture<FloatColorPixel<Model>>? {
            return nil
        }
        
        func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
        }
    }
    
    class TextureLayer: Layer {
        
        let source: Texture<FloatColorPixel<Model>>
        
        init(_ source: Texture<FloatColorPixel<Model>>) {
            self.source = source
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override var cached_image: Texture<FloatColorPixel<Model>>? {
            return source
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            do {
                guard let buffer = composer.device.makeBuffer(source.pixels) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
                guard let encoder = commandBuffer.makeBlitCommandEncoder() else { throw Error(description: "MTLDevice.makeBlitCommandEncoder failed.") }
                
                encoder.copy(from: buffer, sourceOffset: 0, to: output, destinationOffset: 0, size: width * height * pixel_size)
                encoder.endEncoding()
            }
            
            if global_opacity != 1 {
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
                
                encoder.setComputePipelineState(composer.set_opacity)
                
                encoder.setBytes([Float(global_opacity)], length: 4, index: 0)
                encoder.setBuffer(output, offset: 0, index: 1)
                
                let w = composer.set_opacity.threadExecutionWidth
                let h = composer.set_opacity.maxTotalThreadsPerThreadgroup / w
                let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
                
                encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
                encoder.endEncoding()
            }
        }
    }
    
    class BlendedLayer: Layer {
        
        let mode: Composer.BlendMode
        let source: Layer
        let destination: Layer
        let opacity: Double
        
        init(mode: Composer.BlendMode, source: Layer, destination: Layer, opacity: Double) {
            self.mode = mode
            self.source = source
            self.destination = destination
            self.opacity = opacity
        }
        
        override var is_empty: Bool {
            return source.is_empty && destination.is_empty
        }
        
        override var operations_count: Int {
            let count = source.operations_count + destination.operations_count
            return source.is_empty || destination.is_empty ? count : count + 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            let opacity = self.opacity * global_opacity
            
            switch (source.is_empty, destination.is_empty) {
            case (true, true): break
            case (true, false): try destination.render(width: width, height: height, global_opacity: 1, composer: composer, commandBuffer: commandBuffer, output: output)
            case (false, true): try source.render(width: width, height: height, global_opacity: opacity, composer: composer, commandBuffer: commandBuffer, output: output)
            case (false, false):
                
                guard let _source = composer.device.makeBuffer(length: width * height * pixel_size, options: .storageModePrivate) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
                
                try source.render(width: width, height: height, global_opacity: opacity, composer: composer, commandBuffer: commandBuffer, output: _source)
                try destination.render(width: width, height: height, global_opacity: 1, composer: composer, commandBuffer: commandBuffer, output: output)
                
                let pipeline = composer.blending[mode]!
                
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
                
                encoder.setComputePipelineState(pipeline)
                
                encoder.setBuffer(_source, offset: 0, index: 0)
                encoder.setBuffer(output, offset: 0, index: 1)
                
                let w = pipeline.threadExecutionWidth
                let h = pipeline.maxTotalThreadsPerThreadgroup / w
                let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
                
                encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
                encoder.endEncoding()
            }
        }
    }
    
    class ShadowLayer: Layer {
        
        let source: Layer
        let color: FloatColorPixel<Model>
        let offset: Size
        let blur: Double
        
        init(source: Layer, color: FloatColorPixel<Model>, offset: Size, blur: Double) {
            self.source = source
            self.color = color
            self.offset = offset
            self.blur = blur
        }
        
        override var is_empty: Bool {
            return source.is_empty
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            // FIXME: Need implement
        }
    }
    
    class ShapeLayer: Layer {
        
        let shape: Shape
        let winding: Shape.WindingRule
        let color: FloatColorPixel<Model>
        let antialias: Int
        let mode: Composer.BlendMode
        
        init(shape: Shape, winding: Shape.WindingRule, color: FloatColorPixel<Model>, antialias: Int, mode: Composer.BlendMode) {
            self.shape = shape
            self.winding = winding
            self.color = color
            self.antialias = antialias
            self.mode = mode
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var operations_count: Int {
            return 2
        }
        
        struct GPPoint {
            
            var x: Float
            var y: Float
            
            init(_ point: Point) {
                self.x = Float(point.x)
                self.y = Float(point.y)
            }
        }
        
        struct GPSize {
            
            var width: Float
            var height: Float
        }
        
        struct GPVector {
            
            var x: Float
            var y: Float
            var z: Float
            
            init(_ point: Vector) {
                self.x = Float(point.x)
                self.y = Float(point.y)
                self.z = Float(point.z)
            }
        }
        
        struct FillStencilParameter {
            
            var offset_x: UInt32
            var offset_y: UInt32
            var width: UInt32
            var antialias: UInt32
            var color: (Float, Float, Float, Float,
            Float, Float, Float, Float,
            Float, Float, Float, Float,
            Float, Float, Float, Float)
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            guard let stencil = composer.device.makeBuffer(length: width * height * antialias * antialias * 2, options: .storageModePrivate) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
            
            var shape = self.shape
            shape.transform = shape.transform * SDTransform.scale(Double(antialias))
            
            guard var bound = try self.stencil(shape: shape, width: width * antialias, height: height * antialias, composer: composer, commandBuffer: commandBuffer, output: stencil) else { return }
            
            var color = self.color
            color.opacity *= global_opacity
            
            bound /= Double(antialias)
            
            let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
            let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
            let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
            let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
            
            let pipeline: MTLComputePipelineState
            
            switch winding {
            case .nonZero: pipeline = composer.fill_nonZero_stencil[mode]!
            case .evenOdd: pipeline = composer.fill_evenOdd_stencil[mode]!
            }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
            
            encoder.setComputePipelineState(pipeline)
            
            let _color0 = 0...Model.numberOfComponents ~= 0 ? Float(color.component(0)) : 0
            let _color1 = 0...Model.numberOfComponents ~= 1 ? Float(color.component(1)) : 0
            let _color2 = 0...Model.numberOfComponents ~= 2 ? Float(color.component(2)) : 0
            let _color3 = 0...Model.numberOfComponents ~= 3 ? Float(color.component(3)) : 0
            let _color4 = 0...Model.numberOfComponents ~= 4 ? Float(color.component(4)) : 0
            let _color5 = 0...Model.numberOfComponents ~= 5 ? Float(color.component(5)) : 0
            let _color6 = 0...Model.numberOfComponents ~= 6 ? Float(color.component(6)) : 0
            let _color7 = 0...Model.numberOfComponents ~= 7 ? Float(color.component(7)) : 0
            let _color8 = 0...Model.numberOfComponents ~= 8 ? Float(color.component(8)) : 0
            let _color9 = 0...Model.numberOfComponents ~= 9 ? Float(color.component(9)) : 0
            let _color10 = 0...Model.numberOfComponents ~= 10 ? Float(color.component(10)) : 0
            let _color11 = 0...Model.numberOfComponents ~= 11 ? Float(color.component(11)) : 0
            let _color12 = 0...Model.numberOfComponents ~= 12 ? Float(color.component(12)) : 0
            let _color13 = 0...Model.numberOfComponents ~= 13 ? Float(color.component(13)) : 0
            let _color14 = 0...Model.numberOfComponents ~= 14 ? Float(color.component(14)) : 0
            let _color15 = 0...Model.numberOfComponents ~= 15 ? Float(color.component(15)) : 0
            
            encoder.setBytes([FillStencilParameter(
                offset_x: UInt32(offset_x),
                offset_y: UInt32(offset_y),
                width: UInt32(width),
                antialias: UInt32(antialias),
                color: (_color0, _color1, _color2, _color3,
                        _color4, _color5, _color6, _color7,
                        _color8, _color9, _color10, _color11,
                        _color12, _color13, _color14, _color15)
                )], length: 80, index: 0)
            
            encoder.setBuffer(stencil, offset: 0, index: 1)
            encoder.setBuffer(output, offset: 0, index: 2)
            
            let w = pipeline.threadExecutionWidth
            let h = pipeline.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        func stencil(shape: Shape, width: Int, height: Int, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws -> Rect? {
            
            let transform = shape.transform
            
            var bound: Rect?
            
            var triangle_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)> = []
            var quadratic_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)> = []
            var cubic_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint, GPVector, GPVector, GPVector)> = []
            
            shape.render { op in
                
                switch op {
                case let .triangle(p0, p1, p2):
                    
                    let q0 = p0 * transform
                    let q1 = p1 * transform
                    let q2 = p2 * transform
                    
                    triangle_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2)))
                    
                    bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                    
                case let .quadratic(p0, p1, p2):
                    
                    let q0 = p0 * transform
                    let q1 = p1 * transform
                    let q2 = p2 * transform
                    
                    quadratic_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2)))
                    
                    bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                    
                case let .cubic(p0, p1, p2, v0, v1, v2):
                    
                    let q0 = p0 * transform
                    let q1 = p1 * transform
                    let q2 = p2 * transform
                    
                    cubic_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2), GPVector(v0), GPVector(v1), GPVector(v2)))
                    
                    bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                }
            }
            
            guard triangle_render_buffer.count != 0 || quadratic_render_buffer.count != 0 || cubic_render_buffer.count != 0 else { return nil }
            
            let _bound = bound ?? Rect()
            let offset_x = max(0, min(width - 1, Int(floor(_bound.x))))
            let offset_y = max(0, min(height - 1, Int(floor(_bound.y))))
            let _width = min(width - offset_x, Int(ceil(_bound.width + 1)))
            let _height = min(height - offset_y, Int(ceil(_bound.height + 1)))
            
            if triangle_render_buffer.count != 0 {
                
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
                guard let buffer = composer.device.makeBuffer(triangle_render_buffer) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
                
                encoder.setComputePipelineState(composer.stencil_triangle)
                encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(triangle_render_buffer.count)], length: 16, index: 0)
                encoder.setBuffer(buffer, offset: 0, index: 1)
                encoder.setBuffer(output, offset: 0, index: 2)
                
                let w = composer.stencil_triangle.threadExecutionWidth
                let h = composer.stencil_triangle.maxTotalThreadsPerThreadgroup / w
                let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
                
                encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
                encoder.endEncoding()
            }
            
            if quadratic_render_buffer.count != 0 {
                
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
                guard let buffer = composer.device.makeBuffer(quadratic_render_buffer) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
                
                encoder.setComputePipelineState(composer.stencil_quadratic)
                encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(quadratic_render_buffer.count)], length: 16, index: 0)
                encoder.setBuffer(buffer, offset: 0, index: 1)
                encoder.setBuffer(output, offset: 0, index: 2)
                
                let w = composer.stencil_quadratic.threadExecutionWidth
                let h = composer.stencil_quadratic.maxTotalThreadsPerThreadgroup / w
                let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
                
                encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
                encoder.endEncoding()
            }
            
            if cubic_render_buffer.count != 0 {
                
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw Error(description: "MTLDevice.makeComputeCommandEncoder failed.") }
                guard let buffer = composer.device.makeBuffer(cubic_render_buffer) else { throw Error(description: "MTLDevice.makeBuffer failed.") }
                
                encoder.setComputePipelineState(composer.stencil_cubic)
                encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(cubic_render_buffer.count)], length: 16, index: 0)
                encoder.setBuffer(buffer, offset: 0, index: 1)
                encoder.setBuffer(output, offset: 0, index: 2)
                
                let w = composer.stencil_cubic.threadExecutionWidth
                let h = composer.stencil_cubic.maxTotalThreadsPerThreadgroup / w
                let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
                
                encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
                encoder.endEncoding()
            }
            
            return _bound
        }
    }
    
    class ImageLayer: Layer {
        
        let source: MappedBuffer<FloatColorPixel<Model>>
        let transform: SDTransform
        let antialias: Int
        let resamplingAlgorithm: ResamplingAlgorithm
        
        init(source: MappedBuffer<FloatColorPixel<Model>>, transform: SDTransform, antialias: Int, resamplingAlgorithm: ResamplingAlgorithm) {
            self.source = source
            self.transform = transform
            self.antialias = antialias
            self.resamplingAlgorithm = resamplingAlgorithm
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            // FIXME: Need implement
        }
    }
    
    class ClipLayer: Layer {
        
        let source: Layer
        let clip: DGImageContext<GrayColorModel>.Layer
        
        init(source: Layer, clip: DGImageContext<GrayColorModel>.Layer) {
            self.source = source
            self.clip = clip
        }
        
        override var is_empty: Bool {
            return source.is_empty || clip.is_empty
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 && !clip.is_empty else { return }
            
            // FIXME: Need implement
        }
    }
    
    struct _GradientStop {
        
        var offset: Double
        var color: FloatColorPixel<Model>
        
        init(offset: Double, color: FloatColorPixel<Model>) {
            self.offset = offset
            self.color = color
        }
    }
    
    class LinearGradientLayer: Layer {
        
        let stops: [_GradientStop]
        let start: Point
        let end: Point
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [_GradientStop], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
            self.stops = stops
            self.start = start
            self.end = end
            self.startSpread = startSpread
            self.endSpread = endSpread
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            var stops = self.stops
            stops.mutateEach { $0.color.opacity *= global_opacity }
            
            // FIXME: Need implement
        }
    }
    
    class RadialGradient: Layer {
        
        let stops: [_GradientStop]
        let start: Point
        let startRadius: Double
        let end: Point
        let endRadius: Double
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [_GradientStop], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
            self.stops = stops
            self.start = start
            self.startRadius = startRadius
            self.end = end
            self.endRadius = endRadius
            self.startSpread = startSpread
            self.endSpread = endSpread
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var operations_count: Int {
            return 1
        }
        
        override func render(width: Int, height: Int, global_opacity: Double, composer: Composer, commandBuffer: MTLCommandBuffer, output: MTLBuffer) throws {
            
            guard global_opacity != 0 else { return }
            
            var stops = self.stops
            stops.mutateEach { $0.color.opacity *= global_opacity }
            
            // FIXME: Need implement
        }
    }
}

#endif
