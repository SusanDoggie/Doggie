//
//  Renderer.swift
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

import Doggie

struct DGRendererEncoderGradientStop<Model : ColorModelProtocol> {
    
    var offset: Double
    var color: FloatColorPixel<Model>
    
    init(offset: Double, color: FloatColorPixel<Model>) {
        self.offset = offset
        self.color = color
    }
}

protocol DGRenderer {
    
    associatedtype Encoder : DGRendererEncoder where Encoder.Renderer == Self
    
    associatedtype Device : AnyObject
    
    associatedtype Model : ColorModelProtocol
    
    var device: Device { get }
    
    init(device: Device) throws
    
    func encoder(width: Int, height: Int) throws -> Encoder
}

protocol DGRendererEncoder {
    
    associatedtype Renderer : DGRenderer where Renderer.Encoder == Self
    
    associatedtype ClipEncoder : DGRendererEncoder where ClipEncoder.Renderer.Model == GrayColorModel, ClipEncoder.Renderer.Device == Renderer.Device
    
    associatedtype Buffer
    
    var renderer: Renderer { get }
    
    var device: Renderer.Device { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    var texture_size: Int { get }
    
    func commit()
    
    func clip_encoder() throws -> ClipEncoder
    
    func alloc_texture() throws -> Buffer
    
    func make_buffer<T>(_ buffer: MappedBuffer<T>) throws -> Buffer
    
    func copy(_ source: Buffer, _ destination: Buffer) throws
    
    func setOpacity(_ destination: Buffer, _ opacity: Double) throws
    
    func blend(_ source: Buffer, _ destination: Buffer, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws
    
    func shadow(_ source: Buffer, _ destination: Buffer, _ color: [Double], _ offset: Size, _ blur: Double) throws
    
    func draw(_ destination: Buffer, _ shape: Shape, _ color: [Double], _ winding: Shape.WindingRule, _ antialias: Int) throws
    
    func draw(_ source: Texture<FloatColorPixel<Renderer.Model>>, _ destination: Buffer, _ transform: SDTransform, _ antialias: Int) throws
    
    func clip(_ destination: Buffer, _ clip: ClipEncoder.Buffer) throws
    
    func linearGradient(_ destination: Buffer, _ stops: [DGRendererEncoderGradientStop<Renderer.Model>], _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
    func radialGradient(_ destination: Buffer, _ stops: [DGRendererEncoderGradientStop<Renderer.Model>], _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
}

extension DGRendererEncoder {
    
    var device: Renderer.Device {
        return renderer.device
    }
    
    private var pixel_size: Int {
        return Renderer.Model.numberOfComponents << 2 + 4
    }
    
    var texture_size: Int {
        return width * height * pixel_size
    }
    
    func clip_encoder() throws -> ClipEncoder {
        let renderer = try DGImageContext<GrayColorModel>.make_renderer(device, ClipEncoder.Renderer.self)
        return try renderer.encoder(width: width, height: height)
    }
}

private let DGImageContextCacheLock = SDLock()
private var DGImageContextCache: [AnyHashable: Any] = [:]

extension DGImageContext {
    
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
    
    func render<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws where Renderer.Model == Model {
        
        guard width != 0 && height != 0 else { return }
        
        guard self._image.cached_image == nil else { return }
        
        let renderer = try DGImageContext.make_renderer(device, Renderer.self)
        let encoder = try renderer.encoder(width: width, height: height)
        
        let texture = Texture<FloatColorPixel<Model>>(width: width, height: height, option: .inMemory)
        var cache: [ObjectIdentifier: Any] = [:]
        try self._image.render(encoder: encoder, cache: &cache, output: encoder.make_buffer(texture.pixels))
        
        encoder.commit()
        
        self._image = TextureLayer(texture)
    }
    
    func image<Renderer: DGRenderer>(_ device: Renderer.Device, _ : Renderer.Type) throws -> Image<FloatColorPixel<Model>> where Renderer.Model == Model {
        
        guard width != 0 && height != 0 else { return Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace) }
        
        try self.render(device, Renderer.self)
        return Image(texture: self._image.cached_image!, resolution: resolution, colorSpace: colorSpace)
    }
}

extension DGImageContext {
    
    class Layer {
        
        var is_empty: Bool {
            return true
        }
        
        var cached_image: Texture<FloatColorPixel<Model>>? {
            return nil
        }
        
        func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any]) throws -> Encoder.Buffer where Encoder.Renderer.Model == Model {
            let buffer = try encoder.alloc_texture()
            try self.render(encoder: encoder, cache: &cache, output: buffer)
            return buffer
        }
        
        func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            
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
        
        override var cached_image: Texture<FloatColorPixel<Model>>? {
            return source
        }
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any]) throws -> Encoder.Buffer where Encoder.Renderer.Model == Model {
            return try encoder.make_buffer(source.pixels)
        }
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            try encoder.copy(encoder.make_buffer(source.pixels), output)
        }
    }
    
    class BlendedLayer: Layer {
        
        let source: Layer
        let destination: Layer
        
        let clip: DGImageContext<GrayColorModel>.Layer?
        
        let shadowColor: FloatColorPixel<Model>
        let shadowOffset: Size
        let shadowBlur: Double
        
        let opacity: Double
        let compositingMode: ColorCompositingMode
        let blendMode: ColorBlendMode
        
        init(source: Layer, destination: Layer, clip: DGImageContext<GrayColorModel>.Layer?, shadowColor: FloatColorPixel<Model>, shadowOffset: Size, shadowBlur: Double, opacity: Double, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
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
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            
            if !destination.is_empty {
                try destination.render(encoder: encoder, cache: &cache, output: output)
            }
            
            if !source.is_empty && opacity != 0 {
                
                let _source = try source.render(encoder: encoder, cache: &cache)
                
                if opacity != 1 {
                    try encoder.setOpacity(_source, opacity)
                }
                
                if let clip = clip, !clip.is_empty {
                    let _clip: Encoder.ClipEncoder.Buffer
                    if let cached = cache[ObjectIdentifier(clip)] as? Encoder.ClipEncoder.Buffer {
                        _clip = cached
                    } else {
                        _clip = try clip.render(encoder: encoder.clip_encoder(), cache: &cache)
                        cache[ObjectIdentifier(clip)] = _clip
                    }
                    try encoder.clip(_source, _clip)
                }
                
                if isShadow {
                    let _shadow = try encoder.alloc_texture()
                    try encoder.shadow(_source, _shadow, (0..<shadowColor.numberOfComponents).map { shadowColor.component($0) }, shadowOffset, shadowBlur)
                    try encoder.blend(_shadow, output, compositingMode, blendMode)
                }
                
                try encoder.blend(_source, output, compositingMode, blendMode)
            }
        }
    }
    
    class ShapeLayer: Layer {
        
        let shape: Shape
        let winding: Shape.WindingRule
        let color: FloatColorPixel<Model>
        let antialias: Int
        
        init(shape: Shape, winding: Shape.WindingRule, color: FloatColorPixel<Model>, antialias: Int) {
            self.shape = shape
            self.winding = winding
            self.color = color
            self.antialias = antialias
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            try encoder.draw(output, shape, (0..<color.numberOfComponents).map { color.component($0) }, winding, antialias)
        }
        
    }
    
    class ImageLayer: Layer {
        
        let source: Texture<FloatColorPixel<Model>>
        let transform: SDTransform
        let antialias: Int
        
        init(source: Texture<FloatColorPixel<Model>>, transform: SDTransform, antialias: Int) {
            self.source = source
            self.transform = transform
            self.antialias = antialias
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            try encoder.draw(source, output, transform, antialias)
        }
    }
    
    class LinearGradientLayer: Layer {
        
        let stops: [DGRendererEncoderGradientStop<Model>]
        let start: Point
        let end: Point
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [DGRendererEncoderGradientStop<Model>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
            self.stops = stops
            self.start = start
            self.end = end
            self.startSpread = startSpread
            self.endSpread = endSpread
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            try encoder.linearGradient(output, stops, start, end, startSpread, endSpread)
        }
    }
    
    class RadialGradientLayer: Layer {
        
        let stops: [DGRendererEncoderGradientStop<Model>]
        let start: Point
        let startRadius: Double
        let end: Point
        let endRadius: Double
        let startSpread: GradientSpreadMode
        let endSpread: GradientSpreadMode
        
        init(stops: [DGRendererEncoderGradientStop<Model>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
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
        
        override func render<Encoder: DGRendererEncoder>(encoder: Encoder, cache: inout [ObjectIdentifier: Any], output: Encoder.Buffer) throws where Encoder.Renderer.Model == Model {
            try encoder.radialGradient(output, stops, start, startRadius, end, endRadius, startSpread, endSpread)
        }
    }
}
