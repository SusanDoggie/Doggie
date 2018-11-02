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

struct MetalRendererBlendMode : Hashable {
    
    var compositing: ColorCompositingMode
    var blending: ColorBlendMode
}

struct MetalRendererGradientSpreadMode : Hashable {
    
    var start: GradientSpreadMode
    var end: GradientSpreadMode
}

enum DGResamplingAlgorithm {
    
    case none
    case linear
    case cosine
    case cubic
    case hermite
    case mitchell
    case lanczos
    
    init(_ algorithm: ResamplingAlgorithm) {
        switch algorithm {
        case .none: self = .none
        case .linear: self = .linear
        case .cosine: self = .cosine
        case .cubic: self = .cubic
        case .hermite(_, _): self = .hermite
        case .mitchell(_, _): self = .mitchell
        case .lanczos(_): self = .lanczos
        }
    }
}

struct MetalRendererResamplingKey : Hashable {
    
    var algorithm: DGResamplingAlgorithm
    var hWrapping: WrappingMode
    var vWrapping: WrappingMode
}

private let MTLCommandQueueCacheLock = SDLock()
private var MTLCommandQueueCache: [NSObject: MTLCommandQueue] = [:]

class MetalRenderer<Model : ColorModelProtocol> : DGRenderer {
    
    typealias ClipEncoder = MetalRenderer<GrayColorModel>.Encoder
    
    let device: MTLDevice
    
    let queue: MTLCommandQueue
    
    let set_opacity: MTLComputePipelineState
    
    let stencil_triangle: MTLComputePipelineState
    let stencil_quadratic: MTLComputePipelineState
    let stencil_cubic: MTLComputePipelineState
    
    let blending: [MetalRendererBlendMode: MTLComputePipelineState]
    
    let fill_nonZero_stencil: MTLComputePipelineState
    let fill_evenOdd_stencil: MTLComputePipelineState
    
    let clip: MTLComputePipelineState
    
    let axial_gradient: [MetalRendererGradientSpreadMode: MTLComputePipelineState]
    let radial_gradient: [MetalRendererGradientSpreadMode: MTLComputePipelineState]
    
    let resampling: [MetalRendererResamplingKey: MTLComputePipelineState]
    
    required init(device: MTLDevice) throws {
        
        self.device = device
        
        let library = try device.makeDefaultLibrary(bundle: Bundle(for: MetalRenderer.self))
        
        self.stencil_triangle = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_triangle")!)
        self.stencil_quadratic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_quadratic")!)
        self.stencil_cubic = try device.makeComputePipelineState(function: library.makeFunction(name: "stencil_cubic")!)
        
        let constant = MTLFunctionConstantValues()
        constant.setConstantValue([Int32(Model.numberOfComponents + 1)], type: .int, withName: "countOfComponents")
        
        self.set_opacity = try device.makeComputePipelineState(function: library.makeFunction(name: "set_opacity", constantValues: constant))
        self.fill_nonZero_stencil = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_nonZero_stencil", constantValues: constant))
        self.fill_evenOdd_stencil = try device.makeComputePipelineState(function: library.makeFunction(name: "fill_evenOdd_stencil", constantValues: constant))
        self.clip = try device.makeComputePipelineState(function: library.makeFunction(name: "clip", constantValues: constant))
        
        let allCompositingMode: [ColorCompositingMode: String] = [
            .source: "copy",
            .sourceOver: "sourceOver",
            .sourceIn: "sourceIn",
            .sourceOut: "sourceOut",
            .sourceAtop: "sourceAtop",
            .destinationOver: "destinationOver",
            .destinationIn: "destinationIn",
            .destinationOut: "destinationOut",
            .destinationAtop: "destinationAtop",
            .xor: "exclusiveOr"
        ]
        
        let allBlendMode: [ColorBlendMode: String] = [
            .normal: "normal",
            .multiply: "multiply",
            .screen: "screen",
            .overlay: "overlay",
            .darken: "darken",
            .lighten: "lighten",
            .colorDodge: "colorDodge",
            .colorBurn: "colorBurn",
            .softLight: "softLight",
            .hardLight: "hardLight",
            .difference: "difference",
            .exclusion: "exclusion",
            .plusDarker: "plusDarker",
            .plusLighter: "plusLighter"
        ]
        
        var _blending: [MetalRendererBlendMode: MTLComputePipelineState] = [:]
        
        for (compositing, compositing_name) in allCompositingMode {
            for (blending, blending_name) in allBlendMode {
                let key = MetalRendererBlendMode(compositing: compositing, blending: blending)
                _blending[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "blend_\(compositing_name)_\(blending_name)", constantValues: constant))
            }
        }
        
        self.blending = _blending
        
        let allGradientSpreadMode: [GradientSpreadMode: String] = [
            .none: "none",
            .pad: "pad",
            .reflect: "reflect",
            .repeat: "repeat"
        ]
        
        var _axial_gradient: [MetalRendererGradientSpreadMode: MTLComputePipelineState] = [:]
        var _radial_gradient: [MetalRendererGradientSpreadMode: MTLComputePipelineState] = [:]
        
        for (end, end_name) in allGradientSpreadMode {
            for (start, start_name) in allGradientSpreadMode {
                let key = MetalRendererGradientSpreadMode(start: start, end: end)
                _axial_gradient[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "axial_gradient_\(start_name)_\(end_name)", constantValues: constant))
                _radial_gradient[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "radial_gradient_\(start_name)_\(end_name)", constantValues: constant))
            }
        }
        
        self.axial_gradient = _axial_gradient
        self.radial_gradient = _radial_gradient
        
        let allResamplingAlgorithm: [DGResamplingAlgorithm: String] = [
            .none: "none",
            .linear: "linear",
            .cosine: "cosine",
            .cubic: "cubic",
            .hermite: "hermite",
            .mitchell: "mitchell",
            .lanczos: "lanczos"
        ]
        
        let allWrappingMode: [WrappingMode: String] = [
            .none: "none",
            .clamp: "clamp",
            .repeat: "repeat",
            .mirror: "mirror"
        ]
        
        var _resampling: [MetalRendererResamplingKey: MTLComputePipelineState] = [:]
        
        for (algorithm, algorithm_name) in allResamplingAlgorithm {
            for (h_wrapping, h_wrapping_name) in allWrappingMode {
                for (v_wrapping, v_wrapping_name) in allWrappingMode {
                    let key = MetalRendererResamplingKey(algorithm: algorithm, hWrapping: h_wrapping, vWrapping: v_wrapping)
                    _resampling[key] = try device.makeComputePipelineState(function: library.makeFunction(name: "\(algorithm_name)_interpolate_\(h_wrapping_name)_\(v_wrapping_name)", constantValues: constant))
                }
            }
        }
        
        self.resampling = _resampling
        
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
        let commandBuffer: MTLCommandBuffer
        
        init(width: Int, height: Int, renderer: MetalRenderer<Model>, commandBuffer: MTLCommandBuffer) {
            self.width = width
            self.height = height
            self.renderer = renderer
            self.commandBuffer = commandBuffer
        }
    }
}

extension MetalRenderer.Encoder {
    
    func commit() {
        commandBuffer.commit()
    }
    
    func waitUntilScheduled() {
        commandBuffer.waitUntilScheduled()
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
    
    func copy(_ source: MTLBuffer, _ destination: MTLBuffer) throws {
        
        guard source !== destination else { return }
        
        guard let encoder = commandBuffer.makeBlitCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeBlitCommandEncoder failed.") }
        
        encoder.copy(from: source, sourceOffset: 0, to: destination, destinationOffset: 0, size: texture_size)
        encoder.endEncoding()
    }
    
    func setOpacity(_ destination: MTLBuffer, _ opacity: Double) throws {
        
        guard opacity != 1 else { return }
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
        encoder.setComputePipelineState(renderer.set_opacity)
        
        encoder.setBytes([Float(opacity)], length: 4, index: 0)
        encoder.setBuffer(destination, offset: 0, index: 1)
        
        let w = renderer.set_opacity.threadExecutionWidth
        let h = renderer.set_opacity.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func blend(_ source: MTLBuffer, _ destination: MTLBuffer, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws {
        
        switch (compositingMode, blendMode) {
        case (.destination, _): return
        case (.source, .normal):
            
            guard let encoder = commandBuffer.makeBlitCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeBlitCommandEncoder failed.") }
            
            encoder.copy(from: source, sourceOffset: 0, to: destination, destinationOffset: 0, size: texture_size)
            encoder.endEncoding()
            
        case (.clear, _):
            
            guard let encoder = commandBuffer.makeBlitCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeBlitCommandEncoder failed.") }
            
            encoder.fill(buffer: destination, range: 0..<texture_size, value: 0)
            encoder.endEncoding()
            
        default:
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
            
            let pipeline = renderer.blending[MetalRendererBlendMode(compositing: compositingMode, blending: blendMode)]!
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
        
    }
    
    func draw(_ destination: MTLBuffer, _ shape: Shape, _ color: [Double], _ winding: Shape.WindingRule, _ antialias: Int) throws {
        
        guard let stencil = device.makeBuffer(length: width * height * antialias * antialias * 2, options: .storageModePrivate) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
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
        case .nonZero: pipeline = renderer.fill_nonZero_stencil
        case .evenOdd: pipeline = renderer.fill_evenOdd_stencil
        }
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
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
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
        guard let _source = device.makeBuffer(source.pixels) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
        
        let pipeline = renderer.resampling[MetalRendererResamplingKey(algorithm: DGResamplingAlgorithm(source.resamplingAlgorithm),
                                                                      hWrapping: source.horizontalWrappingMode,
                                                                      vWrapping: source.verticalWrappingMode)]!
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
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
        encoder.setComputePipelineState(renderer.clip)
        
        encoder.setBuffer(clip, offset: 0, index: 0)
        encoder.setBuffer(destination, offset: 0, index: 1)
        
        let w = renderer.clip.threadExecutionWidth
        let h = renderer.clip.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: min(w, width), height: min(h, height), depth: 1)
        
        encoder.dispatchThreads(MTLSize(width: width, height: height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
    }
    
    func linearGradient(_ destination: MTLBuffer, _ stops: [DGRendererEncoderGradientStop<Model>], _ transform: SDTransform, _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws {
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
        let pipeline = renderer.axial_gradient[MetalRendererGradientSpreadMode(start: startSpread, end: endSpread)]!
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
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
        
        let pipeline = renderer.radial_gradient[MetalRendererGradientSpreadMode(start: startSpread, end: endSpread)]!
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
    
    private func stencil(shape: Shape, width: Int, height: Int, output: MTLBuffer) throws -> Rect? {
        
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
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
            guard let buffer = device.makeBuffer(triangle_render_buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
            
            encoder.setComputePipelineState(renderer.stencil_triangle)
            encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(triangle_render_buffer.count)], length: 16, index: 0)
            encoder.setBuffer(buffer, offset: 0, index: 1)
            encoder.setBuffer(output, offset: 0, index: 2)
            
            let w = renderer.stencil_triangle.threadExecutionWidth
            let h = renderer.stencil_triangle.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        if quadratic_render_buffer.count != 0 {
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
            guard let buffer = device.makeBuffer(quadratic_render_buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
            
            encoder.setComputePipelineState(renderer.stencil_quadratic)
            encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(quadratic_render_buffer.count)], length: 16, index: 0)
            encoder.setBuffer(buffer, offset: 0, index: 1)
            encoder.setBuffer(output, offset: 0, index: 2)
            
            let w = renderer.stencil_quadratic.threadExecutionWidth
            let h = renderer.stencil_quadratic.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        if cubic_render_buffer.count != 0 {
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalRenderer.Error(description: "MTLCommandBuffer.makeComputeCommandEncoder failed.") }
            guard let buffer = device.makeBuffer(cubic_render_buffer) else { throw MetalRenderer.Error(description: "MTLDevice.makeBuffer failed.") }
            
            encoder.setComputePipelineState(renderer.stencil_cubic)
            encoder.setBytes([UInt32(offset_x), UInt32(offset_y), UInt32(width), UInt32(cubic_render_buffer.count)], length: 16, index: 0)
            encoder.setBuffer(buffer, offset: 0, index: 1)
            encoder.setBuffer(output, offset: 0, index: 2)
            
            let w = renderer.stencil_cubic.threadExecutionWidth
            let h = renderer.stencil_cubic.maxTotalThreadsPerThreadgroup / w
            let threadsPerThreadgroup = MTLSize(width: min(w, _width), height: min(h, _height), depth: 1)
            
            encoder.dispatchThreads(MTLSize(width: _width, height: _height, depth: 1), threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
        
        return _bound
    }
}

#endif
