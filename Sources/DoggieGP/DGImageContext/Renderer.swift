//
//  Renderer.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

import Doggie

struct DGRendererEncoderGradientStop<Model : ColorModelProtocol> {
    
    var offset: Double
    var color: Float64ColorPixel<Model>
    
    init(offset: Double, color: Float64ColorPixel<Model>) {
        self.offset = offset
        self.color = color
    }
}

protocol DGRenderer {
    
    associatedtype Encoder : DGRendererEncoder where Encoder.Renderer == Self
    
    associatedtype ClipEncoder : DGRendererEncoder where ClipEncoder == ClipEncoder.Renderer.ClipEncoder, ClipEncoder.Renderer.Model == GrayColorModel, ClipEncoder.Renderer.Device == Device
    
    associatedtype Device : AnyObject
    
    associatedtype Model : ColorModelProtocol
    
    var device: Device { get }
    
    var maxBufferLength: Int { get }
    
    func prepare() -> Bool
    
    init(device: Device) throws
    
    func encoder(width: Int, height: Int) throws -> Encoder
}

protocol DGRendererEncoder {
    
    associatedtype Renderer : DGRenderer where Renderer.Encoder == Self
    
    associatedtype Buffer
    
    var renderer: Renderer { get }
    
    var device: Renderer.Device { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    var texture_size: Int { get }
    
    func commit(waitUntilCompleted: Bool)
    
    func clip_encoder() throws -> Renderer.ClipEncoder
    
    func alloc_texture() throws -> Buffer
    
    func make_buffer(_ texture: Texture<Float32ColorPixel<Renderer.Model>>) throws -> Buffer
    
    func clear(_ buffer: Buffer) throws
    
    func copy(_ source: Buffer, _ destination: Buffer) throws
    
    func setOpacity(_ destination: Buffer, _ opacity: Double) throws
    
    func blend(_ source: Buffer, _ destination: Buffer, _ stencil: Buffer?, _ stencil_bound: Rect?, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws
    
    func shadow(_ source: Buffer, _ destination: Buffer, _ color: Float32ColorPixel<Renderer.Model>, _ offset: Size, _ blur: Double) throws
    
    func draw(_ destination: Buffer, _ stencil: Buffer?, _ shape: Shape, _ color: Float32ColorPixel<Renderer.Model>, _ winding: Shape.WindingRule, _ antialias: Int) throws
    
    func draw(_ source: Texture<Float32ColorPixel<Renderer.Model>>, _ destination: Buffer, _ transform: SDTransform, _ antialias: Int) throws
    
    func clip(_ destination: Buffer, _ clip: Renderer.ClipEncoder.Buffer) throws
    
    func linearGradient(_ destination: Buffer, _ stops: [DGRendererEncoderGradientStop<Renderer.Model>], _ transform: SDTransform, _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
    func radialGradient(_ destination: Buffer, _ stops: [DGRendererEncoderGradientStop<Renderer.Model>], _ transform: SDTransform, _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
}

extension DGRenderer {
    
    static var pixel_size: Int {
        return Model.numberOfComponents << 2 + 4
    }
}

extension DGRendererEncoder {
    
    var device: Renderer.Device {
        return renderer.device
    }
    
    var texture_size: Int {
        return width * height * Renderer.pixel_size
    }
    
    func clip_encoder() throws -> Renderer.ClipEncoder {
        let renderer = try DGImageContext<GrayColorModel>.make_renderer(device, Renderer.ClipEncoder.Renderer.self)
        return try renderer.encoder(width: width, height: height)
    }
}

private let DGImageContextCacheLock = SDLock()
private var DGImageContextCache: [AnyHashable: Any] = [:]

extension DGImageContext {
    
    public struct Error: Swift.Error, CustomStringConvertible {
        
        public var description: String
        
        init(description: String) {
            self.description = description
        }
    }
    
    private struct CacheKey<Renderer: DGRenderer> : Hashable {
        
        let device: Renderer.Device
        
        init(device: Renderer.Device) {
            self.device = device
        }
        
        static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
            return lhs.device === rhs.device
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(CacheKey.self))
            hasher.combine(ObjectIdentifier(device))
        }
    }
    
    fileprivate static func make_renderer<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws -> Renderer where Renderer.Model == Model {
        
        DGImageContextCacheLock.lock()
        defer { DGImageContextCacheLock.unlock() }
        
        let key = CacheKey<Renderer>(device: device)
        
        if let renderer = DGImageContextCache[key] as? Renderer {
            return renderer
        }
        
        let renderer = try Renderer(device: device)
        DGImageContextCache[key] = renderer
        
        return renderer
    }
    
    func prepare<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) -> Bool where Renderer.Model == Model {
        guard let renderer = try? DGImageContext.make_renderer(device, Renderer.self) else { return false }
        return renderer.prepare()
    }
    
    func render<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws where Renderer.Model == Model {
        
        guard width != 0 && height != 0 else { return }
        
        guard self._image.cached_image == nil else { return }
        
        let renderer = try DGImageContext.make_renderer(device, Renderer.self)
        let encoder = try renderer.encoder(width: width, height: height)
        
        let maxBufferLength = renderer.maxBufferLength
        guard encoder.texture_size <= maxBufferLength else { throw Error(description: "Texture size is limited to \(maxBufferLength / 0x100000) MB.") }
        
        let texture = Texture<Float32ColorPixel<Model>>(width: width, height: height, fileBacked: false)
        let resource = Resource<Renderer.Encoder>()
        
        try self._image.render(encoder: encoder, output: encoder.make_buffer(texture), resource: resource)
        
        encoder.commit(waitUntilCompleted: true)
        
        self._image = TextureLayer(texture)
    }
    
    static func maxPixelsCount<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws -> Int where Renderer.Model == Model {
        let renderer = try DGImageContext.make_renderer(device, Renderer.self)
        return renderer.maxBufferLength / Renderer.pixel_size
    }
    
    func maxAntialiasLevel<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws -> Int where Renderer.Model == Model {
        guard width != 0 && height != 0 else { return 0 }
        let renderer = try DGImageContext.make_renderer(device, Renderer.self)
        return Int(isqrt(UInt(renderer.maxBufferLength / (width * height * 2))))
    }
}

extension DGImageContext {
    
    class Resource<Encoder: DGRendererEncoder> where Encoder.Renderer.Model == Model {
        
        var clip_cache: [ObjectIdentifier: Encoder.Renderer.ClipEncoder.Buffer] = [:]
        var recycle: [Encoder.Buffer] = []
    }

    class Layer {
        
        var is_empty: Bool {
            return true
        }
        
        var cached_image: Texture<Float32ColorPixel<Model>>? {
            return nil
        }
        
        func request_buffer<Encoder>(encoder: Encoder, resource: Resource<Encoder>) throws -> Encoder.Buffer {
            guard let buffer = resource.recycle.popLast() else { return try encoder.alloc_texture() }
            try encoder.clear(buffer)
            return buffer
        }
        
        func render<Encoder>(encoder: Encoder, resource: Resource<Encoder>) throws -> (Encoder.Buffer, Encoder.Buffer?, Rect?, Bool) {
            
            if let shapeLayer = self as? ShapeLayer {
                
                let buffer = try self.request_buffer(encoder: encoder, resource: resource)
                let stencil = try self.request_buffer(encoder: encoder, resource: resource)
                try shapeLayer.render(encoder: encoder, output: buffer, stencil: stencil, resource: resource)
                return (buffer, stencil, shapeLayer.shape.boundary, true)
                
            } else {
                
                let buffer = try self.request_buffer(encoder: encoder, resource: resource)
                try self.render(encoder: encoder, output: buffer, resource: resource)
                return (buffer, nil, nil, true)
            }
        }
        
        func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            
        }
    }
    
    class TextureLayer: Layer {
        
        let source: Texture<Float32ColorPixel<Model>>
        
        init(_ source: Texture<Float32ColorPixel<Model>>) {
            self.source = source
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override var cached_image: Texture<Float32ColorPixel<Model>>? {
            return source
        }
        
        override func render<Encoder>(encoder: Encoder, resource: Resource<Encoder>) throws -> (Encoder.Buffer, Encoder.Buffer?, Rect?, Bool) {
            return (try encoder.make_buffer(source), nil, nil, false)
        }
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.copy(encoder.make_buffer(source), output)
        }
    }
    
    class BlendedLayer: Layer {
        
        let source: Layer
        let destination: Layer
        
        let clip: DGImageContext<GrayColorModel>.Layer?
        
        let shadowColor: Float32ColorPixel<Model>
        let shadowOffset: Size
        let shadowBlur: Double
        
        let opacity: Double
        let compositingMode: ColorCompositingMode
        let blendMode: ColorBlendMode
        
        init(source: Layer, destination: Layer, clip: DGImageContext<GrayColorModel>.Layer?, shadowColor: Float32ColorPixel<Model>, shadowOffset: Size, shadowBlur: Double, opacity: Double, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
            self.source = source
            self.destination = destination
            self.clip = clip
            self.shadowColor = shadowColor
            self.shadowOffset = shadowOffset
            self.shadowBlur = shadowBlur
            self.opacity = opacity
            self.compositingMode = compositingMode
            self.blendMode = blendMode
        }
        
        override var is_empty: Bool {
            return source.is_empty && destination.is_empty
        }
        
        private var isShadow: Bool {
            return shadowColor.opacity > 0 && shadowBlur > 0
        }
        
        private func blend<Encoder: DGRendererEncoder>(encoder: Encoder, source: Encoder.Buffer, output: Encoder.Buffer, stencil: Encoder.Buffer?, stencil_bound: Rect?) throws where Model == Encoder.Renderer.Model {
            switch (compositingMode, blendMode, stencil) {
            case (.copy, .normal, nil): try encoder.copy(source, output)
            case (.clear, _, nil): try encoder.clear(output)
            default: try encoder.blend(source, output, stencil, stencil_bound, compositingMode, blendMode)
            }
        }
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            
            if !destination.is_empty {
                try destination.render(encoder: encoder, output: output, resource: resource)
            }
            
            if !source.is_empty && opacity != 0 {
                
                let (_source, _stencil, _stencil_bound, _source_recyclable) = try source.render(encoder: encoder, resource: resource)
                
                if opacity != 1 {
                    try encoder.setOpacity(_source, opacity)
                }
                
                if let clip = clip {
                    
                    guard !clip.is_empty else { return }
                    
                    let _clip: Encoder.Renderer.ClipEncoder.Buffer
                    
                    if let cached = resource.clip_cache[ObjectIdentifier(clip)] {
                        
                        _clip = cached
                        
                    } else if let clip_encoder = encoder as? Encoder.Renderer.ClipEncoder {
                        
                        let clip_resource = DGImageContext<GrayColorModel>.Resource<Encoder.Renderer.ClipEncoder>()
                        clip_resource.recycle = resource.recycle as? [Encoder.Renderer.ClipEncoder.Buffer] ?? []
                        
                        _clip = try clip.render(encoder: clip_encoder, resource: clip_resource).0
                        
                        resource.clip_cache[ObjectIdentifier(clip)] = _clip
                        resource.clip_cache.merge(clip_resource.clip_cache) { (lhs, _) in lhs }
                        resource.recycle = clip_resource.recycle as? [Encoder.Buffer] ?? resource.recycle
                        
                    } else {
                        
                        let clip_resource = DGImageContext<GrayColorModel>.Resource<Encoder.Renderer.ClipEncoder>()
                        let clip_encoder = try encoder.clip_encoder()
                        
                        _clip = try clip.render(encoder: clip_encoder, resource: clip_resource).0
                        
                        clip_encoder.commit(waitUntilCompleted: false)
                        
                        resource.clip_cache[ObjectIdentifier(clip)] = _clip
                        resource.clip_cache.merge(clip_resource.clip_cache) { (lhs, _) in lhs }
                    }
                    
                    try encoder.clip(_source, _clip)
                    if let _stencil = _stencil {
                        try encoder.clip(_stencil, _clip)
                    }
                }
                
                if isShadow {
                    let _shadow = try self.request_buffer(encoder: encoder, resource: resource)
                    try encoder.shadow(_source, _shadow, shadowColor, shadowOffset, shadowBlur)
                    try self.blend(encoder: encoder, source: _shadow, output: output, stencil: _shadow, stencil_bound: nil)
                    resource.recycle.append(_shadow)
                }
                
                if let _stencil_bound = _stencil_bound {
                    if _stencil_bound.isIntersect(Rect(x: 0, y: 0, width: encoder.width, height: encoder.height)) {
                        try self.blend(encoder: encoder, source: _source, output: output, stencil: _stencil, stencil_bound: _stencil_bound)
                    }
                } else {
                    try self.blend(encoder: encoder, source: _source, output: output, stencil: _stencil, stencil_bound: nil)
                }
                
                if _source_recyclable {
                    resource.recycle.append(_source)
                    if let _stencil = _stencil {
                        resource.recycle.append(_stencil)
                    }
                }
            }
        }
    }
    
    class ShapeLayer: Layer {
        
        let shape: Shape
        let winding: Shape.WindingRule
        let color: Float32ColorPixel<Model>
        let antialias: Int
        
        init(shape: Shape, winding: Shape.WindingRule, color: Float32ColorPixel<Model>, antialias: Int) {
            self.shape = shape
            self.winding = winding
            self.color = color
            self.antialias = antialias
        }
        
        override var is_empty: Bool {
            return false
        }
        
        func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, stencil: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.draw(output, stencil, shape, color, winding, antialias)
        }
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.draw(output, nil, shape, color, winding, antialias)
        }
    }
    
    class ImageLayer: Layer {
        
        let source: Texture<Float32ColorPixel<Model>>
        let transform: SDTransform
        let antialias: Int
        
        init(source: Texture<Float32ColorPixel<Model>>, transform: SDTransform, antialias: Int) {
            self.source = source
            self.transform = transform
            self.antialias = antialias
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.draw(source, output, transform, antialias)
        }
    }
    
    class LinearGradientLayer: Layer {
        
        let stops: [DGRendererEncoderGradientStop<Model>]
        let transform: SDTransform
        let start: Point
        let end: Point
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [DGRendererEncoderGradientStop<Model>], transform: SDTransform, start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
            self.stops = stops
            self.transform = transform
            self.start = start
            self.end = end
            self.startSpread = startSpread
            self.endSpread = endSpread
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.linearGradient(output, stops, transform, start, end, startSpread, endSpread)
        }
    }
    
    class RadialGradientLayer: Layer {
        
        let stops: [DGRendererEncoderGradientStop<Model>]
        let transform: SDTransform
        let start: Point
        let startRadius: Double
        let end: Point
        let endRadius: Double
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [DGRendererEncoderGradientStop<Model>], transform: SDTransform, start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
            self.stops = stops
            self.transform = transform
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
        
        override func render<Encoder>(encoder: Encoder, output: Encoder.Buffer, resource: Resource<Encoder>) throws {
            try encoder.radialGradient(output, stops, transform, start, startRadius, end, endRadius, startSpread, endSpread)
        }
    }
}
