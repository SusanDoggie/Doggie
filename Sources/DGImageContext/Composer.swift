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

import Doggie

protocol DGImageContextComposer : AnyObject {
    
    associatedtype Device
    
    associatedtype Buffer
    
    var device: Device { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    init<Model: ColorModelProtocol>(device: Device, width: Int, height: Int, model: Model.Type) throws
    
    func commit()
    
    func alloc_buffer(_ size: Int) throws -> Buffer
    
    func make_buffer<T>(_ buffer: MappedBuffer<T>) throws -> Buffer
    
    func copy(_ source: Buffer, _ destination: Buffer, _ opacity: Double) throws
    
    func blend(_ source: Buffer, _ destination: Buffer, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws
    
    func shadow(_ source: Buffer, _ destination: Buffer, _ color: [Double], _ offset: Size, _ blur: Double) throws
    
    func draw(_ destination: Buffer, _ shape: Shape, _ color: [Double], _ winding: Shape.WindingRule, _ antialias: Int, _ compositingMode: ColorCompositingMode, _ blendMode: ColorBlendMode) throws
    
    func draw(_ source: Buffer, _ destination: Buffer, _ opacity: Double, _ transform: SDTransform, _ antialias: Int, _ resamplingAlgorithm: ResamplingAlgorithm) throws
    
    func clip(_ source: Buffer, _ destination: Buffer, _ clip: Buffer, _ opacity: Double) throws
    
    func linearGradient(_ destination: Buffer, _ opacity: Double, _ stops: [Double], _ start: Point, _ end: Point, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
    func radialGradient(_ destination: Buffer, _ opacity: Double, _ stops: [Double], _ start: Point, _ startRadius: Double, _ end: Point, _ endRadius: Double, _ startSpread: GradientSpreadMode, _ endSpread: GradientSpreadMode) throws
    
}

extension DGImageContext {
    
    struct Error: Swift.Error, CustomStringConvertible {
        
        var description: String
    }
    
    func render<Composer: DGImageContextComposer>(_ device: Composer.Device, _ : Composer.Type) throws {
        
        guard self._image.cached_image == nil else { return }
        
        let composer = try Composer(device: device, width: width, height: height, model: Model.self)
        
        let texture = Texture<FloatColorPixel<Model>>(width: width, height: height, option: .inMemory)
        try self._image.render(width: width, height: height, global_opacity: 1, composer: composer, output: composer.make_buffer(texture.pixels))
        
        composer.commit()
        
        self._image = TextureLayer(texture)
    }
    
    func image<Composer: DGImageContextComposer>(_ device: Composer.Device, _ : Composer.Type) throws -> Image<FloatColorPixel<Model>> {
        try self.render(device, Composer.self)
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
        
        var cached_image: Texture<FloatColorPixel<Model>>? {
            return nil
        }
        
        func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            guard global_opacity != 0 else { return }
            try composer.copy(composer.make_buffer(source.pixels), output, global_opacity)
        }
    }
    
    class BlendedLayer: Layer {
        
        let source: Layer
        let destination: Layer
        let opacity: Double
        let compositingMode: ColorCompositingMode
        let blendMode: ColorBlendMode
        
        init(source: Layer, destination: Layer, opacity: Double, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
            self.source = source
            self.destination = destination
            self.opacity = opacity
            self.compositingMode = compositingMode
            self.blendMode = blendMode
        }
        
        override var is_empty: Bool {
            return source.is_empty && destination.is_empty
        }
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
            guard global_opacity != 0 else { return }
            
            let opacity = self.opacity * global_opacity
            
            switch (source.is_empty, destination.is_empty) {
            case (true, true): break
            case (true, false): try destination.render(width: width, height: height, global_opacity: 1, composer: composer, output: output)
            case (false, true): try source.render(width: width, height: height, global_opacity: opacity, composer: composer, output: output)
            case (false, false):
                
                let _source = try composer.alloc_buffer(width * height * pixel_size)
                
                try source.render(width: width, height: height, global_opacity: opacity, composer: composer, output: _source)
                try destination.render(width: width, height: height, global_opacity: 1, composer: composer, output: output)
                
                try composer.blend(_source, output, compositingMode, blendMode)
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
            guard global_opacity != 0 else { return }
            
            // FIXME: Need implement
        }
    }
    
    class ShapeLayer: Layer {
        
        let shape: Shape
        let winding: Shape.WindingRule
        let color: FloatColorPixel<Model>
        let antialias: Int
        let compositingMode: ColorCompositingMode
        let blendMode: ColorBlendMode
        
        init(shape: Shape, winding: Shape.WindingRule, color: FloatColorPixel<Model>, antialias: Int, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) {
            self.shape = shape
            self.winding = winding
            self.color = color
            self.antialias = antialias
            self.compositingMode = compositingMode
            self.blendMode = blendMode
        }
        
        override var is_empty: Bool {
            return false
        }
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
            guard global_opacity != 0 else { return }
            
            var color = self.color
            color.opacity *= global_opacity
            
            try composer.draw(output, shape, (0..<color.numberOfComponents).map { color.component($0) }, winding, antialias, compositingMode, blendMode)
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
            guard global_opacity != 0 else { return }
            
            // FIXME: Need implement
        }
    }
    
    class RadialGradientLayer: Layer {
        
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
        
        override func render<Composer: DGImageContextComposer>(width: Int, height: Int, global_opacity: Double, composer: Composer, output: Composer.Buffer) throws {
            
            guard global_opacity != 0 else { return }
            
            // FIXME: Need implement
        }
    }
}
