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

@available(OSX 10.13, iOS 11.0, *)
private let MTLCommandQueueCacheLock = SDLock()

@available(OSX 10.13, iOS 11.0, *)
private var MTLCommandQueueCache: [NSObject: MTLCommandQueue] = [:]

@available(OSX 10.13, iOS 11.0, *)
private let command_encoder_limit = 512

@available(OSX 10.13, iOS 11.0, *)
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

@available(OSX 10.13, iOS 11.0, *)
extension DGImageContext {
    
    public func render() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { throw MetalRenderer<Model>.Error(description: "MTLCreateSystemDefaultDevice failed.") }
        try render(device: device)
    }
    
    public func render(device: MTLDevice) throws {
        try autoreleasepool { try self.render(device, MetalRenderer.self) }
    }
}

@available(OSX 10.13, iOS 11.0, *)
extension MetalRenderer {
    
    struct Error: Swift.Error, CustomStringConvertible {
        
        var description: String
    }
    
    class Encoder : DGRendererEncoder {
        
        let width: Int
        let height: Int
        
        let renderer: MetalRenderer<Model>
        var commandBuffer: MTLCommandBuffer?
        var commandEncoder: MTLCommandEncoder?
        
        var command_counter = 0
        
        var stencil_buffer: MTLBuffer?
        
        init(width: Int, height: Int, renderer: MetalRenderer<Model>, commandBuffer: MTLCommandBuffer) {
            self.width = width
            self.height = height
            self.renderer = renderer
            self.commandBuffer = commandBuffer
        }
        
        deinit {
            self.commit(waitUntilCompleted: false)
        }
    }
}

@available(OSX 10.13, iOS 11.0, *)
extension MetalRenderer.Encoder {
    
    private func check_limit() throws {
        
        guard command_counter >= command_encoder_limit else { return }
        
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilScheduled()
        commandEncoder = nil
        commandBuffer = nil
        command_counter = 0
        
        guard let _commandBuffer = renderer.queue.makeCommandBuffer() else { throw MetalRenderer.Error(description: "MTLCommandQueue.makeCommandBuffer failed.") }
        self.commandBuffer = _commandBuffer
    }
    
    private func makeBlitCommandEncoder() throws -> MTLBlitCommandEncoder {
        
        try self.check_limit()
        
        command_counter += 1
        
        if let encoder = self.commandEncoder as? MTLBlitCommandEncoder {
            return encoder
        } else {
            commandEncoder?.endEncoding()
            commandEncoder = nil
        }
        
        guard let encoder = commandBuffer!.makeBlitCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeBlitCommandEncoder failed.") }
        self.commandEncoder = encoder
        return encoder
    }
    
    private func makeComputeCommandEncoder() throws -> MTLComputeCommandEncoder {
        
        try self.check_limit()
        
        command_counter += 1
        
        if let encoder = self.commandEncoder as? MTLComputeCommandEncoder {
            return encoder
        } else {
            commandEncoder?.endEncoding()
            commandEncoder = nil
        }
        
        guard let encoder = commandBuffer!.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        self.commandEncoder = encoder
        return encoder
    }
}

@available(OSX 10.13, iOS 11.0, *)
extension MetalRenderer.Encoder {
    
    func commit(waitUntilCompleted: Bool) {
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        if waitUntilCompleted {
            commandBuffer?.waitUntilCompleted()
        }
        commandEncoder = nil
        commandBuffer = nil
        command_counter = 0
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
        try self.makeBlitCommandEncoder().fill(buffer: buffer, range: 0..<texture_size, value: 0)
    }
    
    func copy(_ source: MTLBuffer, _ destination: MTLBuffer) throws {
        guard source !== destination else { return }
        try self.makeBlitCommandEncoder().copy(from: source, sourceOffset: 0, to: destination, destinationOffset: 0, size: texture_size)
    }
    
    func setOpacity(_ destination: MTLBuffer, _ opacity: Double) throws {
        
        guard opacity != 1 else { return }
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("set_opacity")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue(Float(opacity), index: 0)
        encoder.setBuffer(destination, offset: 0, index: 1)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func blend(_ source: MTLBuffer, _ destination: MTLBuffer, _ stencil: MTLBuffer?, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws {
        
        switch (compositingMode, blendMode, stencil) {
        case (.destination, _, _): return
        case (.source, .normal, nil): try self.copy(source, destination)
        case (.clear, _, nil): try self.clear(destination)
        default:
            
            let compositing_name: String
            let blending_name: String
            
            switch compositingMode {
            case .clear: compositing_name = "clear"
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
            
            let encoder = try self.makeComputeCommandEncoder()
            
            let pipeline = try renderer.request_pipeline(stencil == nil ? "blend_\(compositing_name)_\(blending_name)" : "blend_\(compositing_name)_\(blending_name)_clip")
            encoder.setComputePipelineState(pipeline)
            
            encoder.setBuffer(source, offset: 0, index: 0)
            encoder.setBuffer(destination, offset: 0, index: 1)
            if let stencil = stencil {
                encoder.setBuffer(stencil, offset: 0, index: 2)
            }
            
            let w = pipeline.threadExecutionWidth
            let h = pipeline.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        }
    }
    
    func shadow(_ source: MTLBuffer, _ destination: MTLBuffer, _ color: FloatColorPixel<Model>, _ offset: Size, _ blur: Double) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("shadow")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue(ShadowParameter(offset: GPSize(offset), blur: Float(blur), color: GPColor(color)), index: 0)
        encoder.setBuffer(source, offset: 0, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func draw(_ destination: MTLBuffer, _ _stencil: MTLBuffer?, _ shape: Shape, _ color: FloatColorPixel<Model>, _ winding: Shape.WindingRule, _ antialias: Int) throws {
        
        let stencil: MTLBuffer
        
        let stencil_size = width * height * antialias * antialias * 2
        
        if let stencil_buffer = self.stencil_buffer, stencil_buffer.length >= stencil_size {
            
            try self.makeBlitCommandEncoder().fill(buffer: stencil_buffer, range: 0..<stencil_size, value: 0)
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
        
        let winding_name: String
        
        switch winding {
        case .nonZero: winding_name = "nonZero"
        case .evenOdd: winding_name = "evenOdd"
        }
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline(_stencil == nil ? "fill_\(winding_name)_stencil" : "fill_\(winding_name)_stencil2")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue(FillStencilParameter(offset_x: UInt32(offset_x), offset_y: UInt32(offset_y), width: UInt32(width), antialias: UInt32(antialias), color: GPColor(color)), index: 0)
        encoder.setBuffer(stencil, offset: 0, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        if let _stencil = _stencil {
            encoder.setBuffer(_stencil, offset: 0, index: 3)
        }
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func draw(_ source: Texture<FloatColorPixel<Model>>, _ destination: MTLBuffer, _ transform: SDTransform, _ antialias: Int) throws {
        
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
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("\(algorithm_name)_interpolate_\(h_wrapping_name)_\(v_wrapping_name)")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue(InterpolateParameter(source, transform, antialias), index: 0)
        encoder.setBuffer(_source, offset: 0, index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
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
    }
    
    private func draw_gradient(_ destination: MTLBuffer, _ type: String, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        
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
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline("\(type)_gradient_\(start_name)_\(end_name)")
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue(GradientParameter(stops.count, transform, start, startRadius, end, endRadius), index: 0)
        encoder.setBuffer(stops.map(_GradientStop.init), index: 1)
        encoder.setBuffer(destination, offset: 0, index: 2)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func linearGradient(_ destination: MTLBuffer, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        try draw_gradient(destination, "axial", stops, transform, start, 0, end, 0, startSpread, endSpread)
    }
    
    func radialGradient(_ destination: MTLBuffer, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        try draw_gradient(destination, "radial", stops, transform, start, startRadius, end, endRadius, startSpread, endSpread)
    }
}

@available(OSX 10.13, iOS 11.0, *)
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
    
    private struct GPColor {
        
        var color: (Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float)
        
        init<Pixel: ColorPixelProtocol>(_ color: Pixel) {
            
            let _color0 = 0..<Pixel.numberOfComponents ~= 0 ? Float(color.component(0)) : 0
            let _color1 = 0..<Pixel.numberOfComponents ~= 1 ? Float(color.component(1)) : 0
            let _color2 = 0..<Pixel.numberOfComponents ~= 2 ? Float(color.component(2)) : 0
            let _color3 = 0..<Pixel.numberOfComponents ~= 3 ? Float(color.component(3)) : 0
            let _color4 = 0..<Pixel.numberOfComponents ~= 4 ? Float(color.component(4)) : 0
            let _color5 = 0..<Pixel.numberOfComponents ~= 5 ? Float(color.component(5)) : 0
            let _color6 = 0..<Pixel.numberOfComponents ~= 6 ? Float(color.component(6)) : 0
            let _color7 = 0..<Pixel.numberOfComponents ~= 7 ? Float(color.component(7)) : 0
            let _color8 = 0..<Pixel.numberOfComponents ~= 8 ? Float(color.component(8)) : 0
            let _color9 = 0..<Pixel.numberOfComponents ~= 9 ? Float(color.component(9)) : 0
            let _color10 = 0..<Pixel.numberOfComponents ~= 10 ? Float(color.component(10)) : 0
            let _color11 = 0..<Pixel.numberOfComponents ~= 11 ? Float(color.component(11)) : 0
            let _color12 = 0..<Pixel.numberOfComponents ~= 12 ? Float(color.component(12)) : 0
            let _color13 = 0..<Pixel.numberOfComponents ~= 13 ? Float(color.component(13)) : 0
            let _color14 = 0..<Pixel.numberOfComponents ~= 14 ? Float(color.component(14)) : 0
            let _color15 = 0..<Pixel.numberOfComponents ~= 15 ? Float(color.component(15)) : 0
            
            self.color = (_color0, _color1, _color2, _color3,
                          _color4, _color5, _color6, _color7,
                          _color8, _color9, _color10, _color11,
                          _color12, _color13, _color14, _color15)
        }
    }
    
    private struct ShadowParameter {
        
        var offset: GPSize
        var blur: Float
        var color: GPColor
    }
    
    private struct FillStencilParameter {
        
        var offset_x: UInt32
        var offset_y: UInt32
        var width: UInt32
        var antialias: UInt32
        var color: GPColor
    }
    
    private struct _GradientStop {
        
        var offset: Float
        var color: GPColor
        
        init(_ stop: DGRendererEncoderGradientStop<Model>) {
            self.offset = Float(stop.offset)
            self.color = GPColor(stop.color)
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

@available(OSX 10.13, iOS 11.0, *)
extension MetalRenderer.Encoder {
    
    private struct Triangle {
        
        var p0: GPPoint
        var p1: GPPoint
        var p2: GPPoint
        
        init(_ p0: GPPoint, _ p1: GPPoint, _ p2: GPPoint) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }
    }
    
    private struct CubicTriangle {
        
        var p0: GPPoint
        var p1: GPPoint
        var p2: GPPoint
        var v0: GPVector
        var v1: GPVector
        var v2: GPVector
        
        init(_ p0: GPPoint, _ p1: GPPoint, _ p2: GPPoint, _ v0: GPVector, _ v1: GPVector, _ v2: GPVector) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
            self.v0 = v0
            self.v1 = v1
            self.v2 = v2
        }
    }
    
    private func scan(_ p0: GPPoint, _ p1: GPPoint, _ y: Float) -> Float {
        let d = p1.y - p0.y
        let _d = 1 / d
        let q = (p1.x - p0.x) * _d
        let r = (p0.x * p1.y - p1.x * p0.y) * _d
        return q * y + r
    }
    
    private func intRange(_ min: Float, _ max: Float, _ bound: Range<Int>) -> Range<Int> {
        
        let _min = min.rounded(.up)
        let _max = max.rounded(.down)
        
        let __min = Int(_min)
        let __max = Int(_max)
        
        guard __min <= __max else { return (__min..<__min).clamped(to: bound) }
        
        return _max == max ? (__min..<__max).clamped(to: bound) : Range(__min...__max).clamped(to: bound)
    }
    
    private func rasterize_bound(width: Int, height: Int, triangle: Triangle) throws -> (Int, Range<Int>)? {
        
        var q0 = triangle.p0
        var q1 = triangle.p1
        var q2 = triangle.p2
        
        sort(&q0, &q1, &q2) { $0.y < $1.y }
        
        let y_range = intRange(q0.y, q2.y, 0..<height)
        guard y_range.count != 0 else { return nil }
        
        let x0 = scan(q0, q2, q1.y)
        let x_range = intRange(0, max(x0, q1.x) - min(x0, q1.x), 0..<width)
        guard x_range.count != 0 else { return nil }
        
        return (x_range.count, y_range)
    }
    
    private func render_stencil<T>(width: Int, pipeline: String, x_length: Int, y_range: Range<Int>, triangle: T, output: MTLBuffer) throws {
        
        let encoder = try self.makeComputeCommandEncoder()
        
        let pipeline = try renderer.request_pipeline(pipeline)
        encoder.setComputePipelineState(pipeline)
        
        encoder.setValue((UInt32(y_range.lowerBound), UInt32(width), triangle), index: 0)
        encoder.setBuffer(output, offset: 0, index: 1)
        
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, x_length), height: min(h, y_range.count), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: x_length, height: y_range.count, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    private func stencil(shape: Shape, width: Int, height: Int, output: MTLBuffer) throws -> Rect? {
        
        let transform = shape.transform
        
        var bound: Rect?
        
        try shape.render { op in
            
            switch op {
            case let .triangle(p0, p1, p2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                let triangle = Triangle(GPPoint(q0), GPPoint(q1), GPPoint(q2))
                
                guard let (x_length, y_range) = try rasterize_bound(width: width, height: height, triangle: triangle) else { return }
                
                try render_stencil(width: width, pipeline: "stencil_triangle", x_length: x_length, y_range: y_range, triangle: triangle, output: output)
                
            case let .quadratic(p0, p1, p2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                let triangle = Triangle(GPPoint(q0), GPPoint(q1), GPPoint(q2))
                
                guard let (x_length, y_range) = try rasterize_bound(width: width, height: height, triangle: triangle) else { return }
                
                try render_stencil(width: width, pipeline: "stencil_quadratic", x_length: x_length, y_range: y_range, triangle: triangle, output: output)
                
            case let .cubic(p0, p1, p2, v0, v1, v2):
                
                let q0 = p0 * transform
                let q1 = p1 * transform
                let q2 = p2 * transform
                
                bound = bound?.union(Rect.bound([q0, q1, q2])) ?? Rect.bound([q0, q1, q2])
                
                guard let (x_length, y_range) = try rasterize_bound(width: width, height: height, triangle: Triangle(GPPoint(q0), GPPoint(q1), GPPoint(q2))) else { return }
                
                let triangle = CubicTriangle(GPPoint(q0), GPPoint(q1), GPPoint(q2), GPVector(v0), GPVector(v1), GPVector(v2))
                try render_stencil(width: width, pipeline: "stencil_cubic", x_length: x_length, y_range: y_range, triangle: triangle, output: output)
            }
        }
        
        return bound
    }
}

#endif
