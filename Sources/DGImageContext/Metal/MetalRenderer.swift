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

private let command_encoder_limit = 16
private let stencil_buffer_limit = 32

class MetalRenderer<Model : ColorModelProtocol> : DGRenderer {
    
    typealias ClipEncoder = MetalRenderer<GrayColorModel>.Encoder
    
    let device: MTLDevice
    let library: MTLLibrary
    let queue: MTLCommandQueue
    
    let lck = SDLock()
    var _pipeline: [String: MTLComputePipelineState] = [:]
    
    required init(device: MTLDevice) throws {
        self.device = device
        self.library = try device.makeDefaultLibrary(bundle: Bundle(for: MetalRenderer.self))
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
    
    func request_pipeline(_ name: String) throws -> MTLComputePipelineState {
        
        lck.lock()
        defer { lck.unlock() }
        
        if let pipeline = _pipeline[name] {
            return pipeline
        }
        
        let constant = MTLFunctionConstantValues()
        constant.setConstantValue([Int32(Model.numberOfComponents + 1)], type: .int, withName: "countOfComponents")
        
        let pipeline = try device.makeComputePipelineState(function: library.makeFunction(name: name, constantValues: constant))
        _pipeline[name] = pipeline
        
        return pipeline
    }
    
    func encoder(width: Int, height: Int) throws -> Encoder {
        guard let commandBuffer = queue.makeCommandBuffer() else { throw Error(description: "MTLCommandQueue.makeCommandBuffer failed.") }
        return Encoder(width: width, height: height, renderer: self, commandBuffer: commandBuffer)
    }
}

extension DGImageContext {
    
    public func render() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { throw MetalRenderer<Model>.Error(description: "MTLCreateSystemDefaultDevice failed.") }
        try render(device: device)
    }
    
    public func render(device: MTLDevice) throws {
        try autoreleasepool { try self.render(device, MetalRenderer.self) }
    }
}

extension MetalRenderer {
    
    struct Error: Swift.Error, CustomStringConvertible {
        
        var description: String
    }
    
    class Encoder : DGRendererEncoder {
        
        let width: Int
        let height: Int
        
        let renderer: MetalRenderer<Model>
        var commandBuffer: MTLCommandBuffer
        
        var command_counter = 0
        var committed = false
        
        var stencil_buffer: MTLBuffer?
        
        init(width: Int, height: Int, renderer: MetalRenderer<Model>, commandBuffer: MTLCommandBuffer) {
            self.width = width
            self.height = height
            self.renderer = renderer
            self.commandBuffer = commandBuffer
        }
    }
}

extension MetalRenderer.Encoder {
    
    private func makeBlitCommandEncoder() throws -> MTLBlitCommandEncoder {
        
        if command_counter >= command_encoder_limit {
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            guard let _commandBuffer = renderer.queue.makeCommandBuffer() else { throw MetalRenderer.Error(description: "MTLCommandQueue.makeCommandBuffer failed.") }
            self.commandBuffer = _commandBuffer
            command_counter = 0
        }
        
        command_counter += 1
        
        guard let encoder = commandBuffer.makeBlitCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeBlitCommandEncoder failed.") }
        return encoder
    }
    
    private func makeComputeCommandEncoder() throws -> MTLComputeCommandEncoder {
        
        if command_counter >= command_encoder_limit {
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            guard let _commandBuffer = renderer.queue.makeCommandBuffer() else { throw MetalRenderer.Error(description: "MTLCommandQueue.makeCommandBuffer failed.") }
            self.commandBuffer = _commandBuffer
            command_counter = 0
        }
        
        command_counter += 1
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        return encoder
    }
}

extension MetalRenderer.Encoder {
    
    func commit() {
        commandBuffer.commit()
    }
    
    func waitUntilCompleted() {
        commandBuffer.waitUntilCompleted()
    }
    
    func alloc_texture() throws -> MTLBuffer {
        guard let buffer = device.makeBuffer(length: texture_size, options: .storageModePrivate) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        return buffer
    }
    
    func make_buffer<T>(_ buffer: MappedBuffer<T>) throws -> MTLBuffer {
        guard let buffer = device.makeBuffer(buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        return buffer
    }
    
    func clear(_ buffer: Buffer) throws {
        
        let encoder = try self.makeBlitCommandEncoder()
        
        encoder.fill(buffer: buffer, range: 0..<texture_size, value: 0)
        encoder.endEncoding()
    }
    
    func copy(_ source: MTLBuffer, _ destination: MTLBuffer) throws {
        
        guard source !== destination else { return }
        
        let encoder = try self.makeBlitCommandEncoder()
        
        encoder.copy(from: source, sourceOffset: 0, to: destination, destinationOffset: 0, size: texture_size)
        encoder.endEncoding()
    }
    
    func setOpacity(_ destination: MTLBuffer, _ opacity: Double) throws {
        
        guard opacity != 1 else { return }
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("set_opacity")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([Float(opacity)], length: 4, index: 0)
        encoder.setBuffer(destination, offset: 0, index: 1)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func blend(_ source: MTLBuffer, _ destination: MTLBuffer, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws {
        
        switch (compositingMode, blendMode) {
        case (.destination, _): return
        case (.source, .normal):
            
            let encoder = try self.makeBlitCommandEncoder()
            
            encoder.copy(from: source, sourceOffset: 0, to: destination, destinationOffset: 0, size: texture_size)
            encoder.endEncoding()
            
        case (.clear, _):
            
            let encoder = try self.makeBlitCommandEncoder()
            
            encoder.fill(buffer: destination, range: 0..<texture_size, value: 0)
            encoder.endEncoding()
            
        default:
            
            let encoder = try self.makeComputeCommandEncoder()
            
            let compositing_name: String
            let blending_name: String
            
            switch compositingMode {
            case .source: compositing_name = "copy"
            case .sourceOver: compositing_name = "sourceOver"
            case .sourceIn: compositing_name = "sourceIn"
            case .sourceOut: compositing_name = "sourceOut"
            case .sourceAtop: compositing_name = "sourceAtop"
            case .destinationOver: compositing_name = "destinationOver"
            case .destinationIn: compositing_name = "destinationIn"
            case .destinationOut: compositing_name = "destinationOut"
            case .destinationAtop: compositing_name = "destinationAtop"
            case .xor: compositing_name = "exclusiveOr"
            default: compositing_name = ""
            }
            
            switch blendMode {
            case .normal: blending_name = "normal"
            case .multiply: blending_name = "multiply"
            case .screen: blending_name = "screen"
            case .overlay: blending_name = "overlay"
            case .darken: blending_name = "darken"
            case .lighten: blending_name = "lighten"
            case .colorDodge: blending_name = "colorDodge"
            case .colorBurn: blending_name = "colorBurn"
            case .softLight: blending_name = "softLight"
            case .hardLight: blending_name = "hardLight"
            case .difference: blending_name = "difference"
            case .exclusion: blending_name = "exclusion"
            case .plusDarker: blending_name = "plusDarker"
            case .plusLighter: blending_name = "plusLighter"
            }
            
            let pipeline = try renderer.request_pipeline("blend_\(compositing_name)_\(blending_name)")
            encoder.setComputePipelineState(pipeline)
            
            encoder.setBuffer(source, offset: 0, index: 0)
            encoder.setBuffer(destination, offset: 0, index: 1)
            
            let w = pipeline.threadExecutionWidth
            let h = pipeline.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    func shadow(_ source: MTLBuffer, _ destination: MTLBuffer, _ color: [Double], _ offset: Size, _ blur: Double) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("shadow")
        encoder.setComputePipelineState(pipeline)
        
        let _color0 = 0..<color.count ~= 0 ? Float(color[0]) : 0
        let _color1 = 0..<color.count ~= 1 ? Float(color[1]) : 0
        let _color2 = 0..<color.count ~= 2 ? Float(color[2]) : 0
        let _color3 = 0..<color.count ~= 3 ? Float(color[3]) : 0
        let _color4 = 0..<color.count ~= 4 ? Float(color[4]) : 0
        let _color5 = 0..<color.count ~= 5 ? Float(color[5]) : 0
        let _color6 = 0..<color.count ~= 6 ? Float(color[6]) : 0
        let _color7 = 0..<color.count ~= 7 ? Float(color[7]) : 0
        let _color8 = 0..<color.count ~= 8 ? Float(color[8]) : 0
        let _color9 = 0..<color.count ~= 9 ? Float(color[9]) : 0
        let _color10 = 0..<color.count ~= 10 ? Float(color[10]) : 0
        let _color11 = 0..<color.count ~= 11 ? Float(color[11]) : 0
        let _color12 = 0..<color.count ~= 12 ? Float(color[12]) : 0
        let _color13 = 0..<color.count ~= 13 ? Float(color[13]) : 0
        let _color14 = 0..<color.count ~= 14 ? Float(color[14]) : 0
        let _color15 = 0..<color.count ~= 15 ? Float(color[15]) : 0
        
        encoder.setBytes([ShadowParameter(
            offset: GPSize(offset),
            blur: Float(blur),
            color: (_color0, _color1, _color2, _color3,
                    _color4, _color5, _color6, _color7,
                    _color8, _color9, _color10, _color11,
                    _color12, _color13, _color14, _color15))], length: 76, index: 0)
        encoder.setBuffer(source, offset: 0, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func draw(_ destination: MTLBuffer, _ shape: Shape, _ color: [Double], _ winding: Shape.WindingRule, _ antialias: Int) throws {
        
        let stencil: MTLBuffer
        
        let stencil_size = width * height * antialias * antialias * 2
        
        if let stencil_buffer = self.stencil_buffer, stencil_buffer.length >= stencil_size {
            
            let encoder = try self.makeBlitCommandEncoder()
            
            encoder.fill(buffer: stencil_buffer, range: 0..<stencil_size, value: 0)
            encoder.endEncoding()
            
            stencil = stencil_buffer
            
        } else {
            
            guard let _stencil = device.makeBuffer(length: stencil_size, options: .storageModePrivate) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
            
            self.stencil_buffer = _stencil
            stencil = _stencil
        }
        
        var shape = shape
        shape.transform = shape.transform * SDTransform.scale(Double(antialias))
        
        guard var bound = try self.stencil(shape: shape, width: width * antialias, height: height * antialias, output: stencil) else { return }
        
        bound /= Double(antialias)
        
        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
        
        let pipeline: MTLComputePipelineState
        
        switch winding {
        case .nonZero: pipeline = try renderer.request_pipeline("fill_nonZero_stencil")
        case .evenOdd: pipeline = try renderer.request_pipeline("fill_evenOdd_stencil")
        }
        
        let encoder = try self.makeComputeCommandEncoder()
        
        encoder.setComputePipelineState(pipeline)
        
        let _color0 = 0..<color.count ~= 0 ? Float(color[0]) : 0
        let _color1 = 0..<color.count ~= 1 ? Float(color[1]) : 0
        let _color2 = 0..<color.count ~= 2 ? Float(color[2]) : 0
        let _color3 = 0..<color.count ~= 3 ? Float(color[3]) : 0
        let _color4 = 0..<color.count ~= 4 ? Float(color[4]) : 0
        let _color5 = 0..<color.count ~= 5 ? Float(color[5]) : 0
        let _color6 = 0..<color.count ~= 6 ? Float(color[6]) : 0
        let _color7 = 0..<color.count ~= 7 ? Float(color[7]) : 0
        let _color8 = 0..<color.count ~= 8 ? Float(color[8]) : 0
        let _color9 = 0..<color.count ~= 9 ? Float(color[9]) : 0
        let _color10 = 0..<color.count ~= 10 ? Float(color[10]) : 0
        let _color11 = 0..<color.count ~= 11 ? Float(color[11]) : 0
        let _color12 = 0..<color.count ~= 12 ? Float(color[12]) : 0
        let _color13 = 0..<color.count ~= 13 ? Float(color[13]) : 0
        let _color14 = 0..<color.count ~= 14 ? Float(color[14]) : 0
        let _color15 = 0..<color.count ~= 15 ? Float(color[15]) : 0
        
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
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func draw(_ source: Texture<FloatColorPixel<Model>>, _ destination: MTLBuffer, _ transform: SDTransform, _ antialias: Int) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        guard let _source = device.makeBuffer(source.pixels) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
        let algorithm_name: String
        let h_wrapping_name: String
        let v_wrapping_name: String
        
        switch source.resamplingAlgorithm {
        case .none: algorithm_name = "none"
        case .linear: algorithm_name = "linear"
        case .cosine: algorithm_name = "cosine"
        case .cubic: algorithm_name = "cubic"
        case .hermite: algorithm_name = "hermite"
        case .mitchell: algorithm_name = "mitchell"
        case .lanczos: algorithm_name = "lanczos"
        }
        
        switch source.horizontalWrappingMode {
        case .none: h_wrapping_name = "none"
        case .clamp: h_wrapping_name = "clamp"
        case .repeat: h_wrapping_name = "repeat"
        case .mirror: h_wrapping_name = "mirror"
        }
        
        switch source.verticalWrappingMode {
        case .none: v_wrapping_name = "none"
        case .clamp: v_wrapping_name = "clamp"
        case .repeat: v_wrapping_name = "repeat"
        case .mirror: v_wrapping_name = "mirror"
        }
        
        let pipeline = try renderer.request_pipeline("\(algorithm_name)_interpolate_\(h_wrapping_name)_\(v_wrapping_name)")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([InterpolateParameter(source, transform, antialias)], length: 48, index: 0)
        encoder.setBuffer(_source, offset: 0, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func clip(_ destination: MTLBuffer, _ clip: MTLBuffer) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("clip")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBuffer(clip, offset: 0, index: 0)
        encoder.setBuffer(destination, offset: 0, index: 1)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func linearGradient(_ destination: MTLBuffer, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let start_name: String
        let end_name: String
        
        switch startSpread {
        case .none: start_name = "none"
        case .pad: start_name = "pad"
        case .reflect: start_name = "reflect"
        case .repeat: start_name = "repeat"
        }
        
        switch endSpread {
        case .none: end_name = "none"
        case .pad: end_name = "pad"
        case .reflect: end_name = "reflect"
        case .repeat: end_name = "repeat"
        }
        
        let pipeline = try renderer.request_pipeline("axial_gradient_\(start_name)_\(end_name)")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([GradientParameter(stops.count, transform, start, 0, end, 0)], length: 56, index: 0)
        encoder.setBytes(stops.map(_GradientStop.init), length: 68 * stops.count, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func radialGradient(_ destination: MTLBuffer, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let start_name: String
        let end_name: String
        
        switch startSpread {
        case .none: start_name = "none"
        case .pad: start_name = "pad"
        case .reflect: start_name = "reflect"
        case .repeat: start_name = "repeat"
        }
        
        switch endSpread {
        case .none: end_name = "none"
        case .pad: end_name = "pad"
        case .reflect: end_name = "reflect"
        case .repeat: end_name = "repeat"
        }
        
        let pipeline = try renderer.request_pipeline("radial_gradient_\(start_name)_\(end_name)")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([GradientParameter(stops.count, transform, start, startRadius, end, endRadius)], length: 56, index: 0)
        encoder.setBytes(stops.map(_GradientStop.init), length: 68 * stops.count, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
}

extension MetalRenderer.Encoder {
    
    private struct GPPoint {
        
        var x: Float
        var y: Float
        
        init(_ point: Point) {
            self.x = Float(point.x)
            self.y = Float(point.y)
        }
    }
    
    private struct GPSize {
        
        var width: Float
        var height: Float
        
        init(width: Float, height: Float) {
            self.width = width
            self.height = height
        }
        
        init(_ size: Size) {
            self.width = Float(size.width)
            self.height = Float(size.height)
        }
    }
    
    private struct GPVector {
        
        var x: Float
        var y: Float
        var z: Float
        
        init(_ point: Vector) {
            self.x = Float(point.x)
            self.y = Float(point.y)
            self.z = Float(point.z)
        }
    }
    
    private struct GPTransform {
        
        var transform: (Float, Float, Float, Float, Float, Float)
        
        init(_ transform: SDTransform) {
            self.transform = (Float(transform.a), Float(transform.d), Float(transform.b), Float(transform.e), Float(transform.c), Float(transform.f))
        }
    }
    
    private struct ShadowParameter {
        
        var offset: GPSize
        var blur: Float
        var color: (Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float)
    }
    
    private struct FillStencilParameter {
        
        var offset_x: UInt32
        var offset_y: UInt32
        var width: UInt32
        var antialias: UInt32
        var color: (Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float)
    }
    
    private struct _GradientStop {
        
        var offset: Float
        var color: (Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float)
        
        init(_ stop: DGRendererEncoderGradientStop<Model>) {
            
            let _color0 = 0...Model.numberOfComponents ~= 0 ? Float(stop.color.component(0)) : 0
            let _color1 = 0...Model.numberOfComponents ~= 1 ? Float(stop.color.component(1)) : 0
            let _color2 = 0...Model.numberOfComponents ~= 2 ? Float(stop.color.component(2)) : 0
            let _color3 = 0...Model.numberOfComponents ~= 3 ? Float(stop.color.component(3)) : 0
            let _color4 = 0...Model.numberOfComponents ~= 4 ? Float(stop.color.component(4)) : 0
            let _color5 = 0...Model.numberOfComponents ~= 5 ? Float(stop.color.component(5)) : 0
            let _color6 = 0...Model.numberOfComponents ~= 6 ? Float(stop.color.component(6)) : 0
            let _color7 = 0...Model.numberOfComponents ~= 7 ? Float(stop.color.component(7)) : 0
            let _color8 = 0...Model.numberOfComponents ~= 8 ? Float(stop.color.component(8)) : 0
            let _color9 = 0...Model.numberOfComponents ~= 9 ? Float(stop.color.component(9)) : 0
            let _color10 = 0...Model.numberOfComponents ~= 10 ? Float(stop.color.component(10)) : 0
            let _color11 = 0...Model.numberOfComponents ~= 11 ? Float(stop.color.component(11)) : 0
            let _color12 = 0...Model.numberOfComponents ~= 12 ? Float(stop.color.component(12)) : 0
            let _color13 = 0...Model.numberOfComponents ~= 13 ? Float(stop.color.component(13)) : 0
            let _color14 = 0...Model.numberOfComponents ~= 14 ? Float(stop.color.component(14)) : 0
            let _color15 = 0...Model.numberOfComponents ~= 15 ? Float(stop.color.component(15)) : 0
            
            self.offset = Float(stop.offset)
            self.color = (_color0, _color1, _color2, _color3,
                          _color4, _color5, _color6, _color7,
                          _color8, _color9, _color10, _color11,
                          _color12, _color13, _color14, _color15)
            
        }
    }
    
    private struct GradientParameter {
        
        var transform: GPTransform
        var start: GPPoint
        var end: GPPoint
        var radius: GPSize
        var numOfStops: UInt32
        var padding: UInt32
        
        init(_ numOfStops: Int, _ transform: SDTransform, _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double) {
            self.transform = GPTransform(transform)
            self.start = GPPoint(start)
            self.end = GPPoint(end)
            self.radius = GPSize(width: Float(startRadius), height: Float(endRadius))
            self.numOfStops = UInt32(numOfStops)
            self.padding = 0
        }
    }
    
    private struct InterpolateParameter {
        
        var transform: GPTransform
        var source_size: (UInt32, UInt32)
        var a: (Float, Float)
        var b: UInt32
        var antialias: UInt32
        
        init(_ source: Texture<FloatColorPixel<Model>>, _ transform: SDTransform, _ antialias: Int) {
            self.transform = GPTransform(transform)
            self.source_size = (UInt32(source.width), UInt32(source.height))
            self.antialias = UInt32(antialias)
            switch source.resamplingAlgorithm {
            case let .hermite(s, t):
                self.a = (Float(s), Float(t))
                self.b = 0
            case let .mitchell(s, t):
                self.a = (Float(s), Float(t))
                self.b = 0
            case let .lanczos(s):
                self.a = (0, 0)
                self.b = UInt32(s)
            default:
                self.a = (0, 0)
                self.b = 0
            }
        }
    }
}

extension MetalRenderer.Encoder {
    
    private func render_triangle(width: Int, height: Int, bound: Rect, buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)>, output: MTLBuffer) throws {
        
        guard buffer.count != 0 else { return }
        
        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
        
        let encoder = try self.makeComputeCommandEncoder()
        guard let _buffer = device.makeBuffer(buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
        let pipeline = try renderer.request_pipeline("stencil_triangle")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(buffer.count)], length: 16, index: 0)
        encoder.setBuffer(_buffer, offset: 0, index: 1)
        encoder.setBuffer(output, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    private func render_quadratic(width: Int, height: Int, bound: Rect, buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)>, output: MTLBuffer) throws {
        
        guard buffer.count != 0 else { return }
        
        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
        
        let encoder = try self.makeComputeCommandEncoder()
        guard let _buffer = device.makeBuffer(buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
        let pipeline = try renderer.request_pipeline("stencil_quadratic")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(buffer.count)], length: 16, index: 0)
        encoder.setBuffer(_buffer, offset: 0, index: 1)
        encoder.setBuffer(output, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    private func render_cubic(width: Int, height: Int, bound: Rect, buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint, GPVector, GPVector, GPVector)>, output: MTLBuffer) throws {
        
        guard buffer.count != 0 else { return }
        
        let offset_x = max(0, min(width - 1, Int(floor(bound.x))))
        let offset_y = max(0, min(height - 1, Int(floor(bound.y))))
        let _width = min(width - offset_x, Int(ceil(bound.width + 1)))
        let _height = min(height - offset_y, Int(ceil(bound.height + 1)))
        
        let encoder = try self.makeComputeCommandEncoder()
        guard let _buffer = device.makeBuffer(buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
        let pipeline = try renderer.request_pipeline("stencil_cubic")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(buffer.count)], length: 16, index: 0)
        encoder.setBuffer(_buffer, offset: 0, index: 1)
        encoder.setBuffer(output, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    private func stencil(shape: Shape, width: Int, height: Int, output: MTLBuffer) throws -> Rect? {
        
        let transform = shape.transform
        
        var triangle_bound: Rect?
        var quadratic_bound: Rect?
        var cubic_bound: Rect?
        
        var triangle_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)> = []
        var quadratic_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint)> = []
        var cubic_render_buffer: MappedBuffer<(GPPoint, GPPoint, GPPoint, GPVector, GPVector, GPVector)> = []
        
        try shape.render { op in
            
            switch op {
            case let .triangle(p0, p1, p2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                triangle_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2)))
                triangle_bound = triangle_bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                if triangle_render_buffer.count >= stencil_buffer_limit {
                    try render_triangle(width: width, height: height, bound: triangle_bound ?? Rect(), buffer: triangle_render_buffer, output: output)
                    triangle_render_buffer = []
                }
                
            case let .quadratic(p0, p1, p2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                quadratic_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2)))
                quadratic_bound = quadratic_bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                if quadratic_render_buffer.count >= stencil_buffer_limit {
                    try render_quadratic(width: width, height: height, bound: quadratic_bound ?? Rect(), buffer: quadratic_render_buffer, output: output)
                    quadratic_render_buffer = []
                }
                
            case let .cubic(p0, p1, p2, v0, v1, v2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                cubic_render_buffer.append((GPPoint(q0), GPPoint(q1), GPPoint(q2), GPVector(v0), GPVector(v1), GPVector(v2)))
                cubic_bound = cubic_bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                if cubic_render_buffer.count >= stencil_buffer_limit {
                    try render_cubic(width: width, height: height, bound: cubic_bound ?? Rect(), buffer: cubic_render_buffer, output: output)
                    cubic_render_buffer = []
                }
            }
        }
        
        try render_triangle(width: width, height: height, bound: triangle_bound ?? Rect(), buffer: triangle_render_buffer, output: output)
        try render_quadratic(width: width, height: height, bound: quadratic_bound ?? Rect(), buffer: quadratic_render_buffer, output: output)
        try render_cubic(width: width, height: height, bound: cubic_bound ?? Rect(), buffer: cubic_render_buffer, output: output)
        
        var _bound: Rect?
        
        if let triangle_bound = triangle_bound {
            _bound = _bound?.union(triangle_bound) ?? triangle_bound
        }
        if let quadratic_bound = quadratic_bound {
            _bound = _bound?.union(quadratic_bound) ?? quadratic_bound
        }
        if let cubic_bound = cubic_bound {
            _bound = _bound?.union(cubic_bound) ?? cubic_bound
        }
        
        return _bound
    }
}

#endif
