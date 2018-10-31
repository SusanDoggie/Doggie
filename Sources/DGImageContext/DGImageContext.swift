//
//  DGImageContext.swift
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

private struct DGImageContextStyles {
    
    static let defaultShadowColor = AnyColor(colorSpace: .default, white: 0.0, opacity: 1.0 / 3.0)
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shouldAntialias: Bool = true
    var antialias: Int = 5
    
    var shadowColor: AnyColor = DGImageContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var compositingMode: ColorCompositingMode = .default
    var blendMode: ColorBlendMode = .default
    
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    
    var renderingIntent: RenderingIntent = .default
    
}

private struct GraphicState {
    
    var clip: DGImageContext<GrayColorModel>.Layer?
    
    var styles: DGImageContextStyles
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    init<Pixel>(context: DGImageContext<Pixel>) {
        self.clip = context.clip
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.chromaticAdaptationAlgorithm
    }
    
    func apply<Pixel>(to context: DGImageContext<Pixel>) {
        context.clip = self.clip
        context.styles = self.styles
        context.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

public class DGImageContext<Model: ColorModelProtocol> : TypedDrawableContext {
    
    typealias ClipComposer = DGImageContext<GrayColorModel>.Composer
    
    let composer: Composer
    let clip_composer: ClipComposer
    
    public let width: Int
    public let height: Int
    public let resolution: Resolution
    public fileprivate(set) var colorSpace: ColorSpace<Model>
    
    var clip: DGImageContext<GrayColorModel>.Layer?
    var _image: Layer = Layer()
    
    fileprivate var styles: DGImageContextStyles = DGImageContextStyles()
    
    private var next: DGImageContext?
    
    private var graphicStateStack: [GraphicState] = []
    
    private init(composer: Composer, clip_composer: ClipComposer, width: Int, height: Int, resolution: Resolution, colorSpace: ColorSpace<Model>) {
        self.composer = composer
        self.clip_composer = clip_composer
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
    }
    
    public init(device: MTLDevice = MTLCreateSystemDefaultDevice()!, image: Image<FloatColorPixel<Model>>) throws {
        self.composer = try Composer(device: device)
        self.clip_composer = try composer as? ClipComposer ?? ClipComposer(device: device)
        self._image = TextureLayer(Texture(image: image))
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
    }
    
    public init(device: MTLDevice = MTLCreateSystemDefaultDevice()!, width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Model>) throws {
        self.composer = try Composer(device: device)
        self.clip_composer = try composer as? ClipComposer ?? ClipComposer(device: device)
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
    }
}

extension DGImageContext {
    
    private convenience init<M>(copyStates context: DGImageContext<M>, composer: Composer, colorSpace: ColorSpace<Model>) {
        self.init(composer: composer,
                  clip_composer: context.clip_composer,
                  width: context.width,
                  height: context.height,
                  resolution: context.resolution,
                  colorSpace: colorSpace)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = DGImageContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
        self.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension DGImageContext {
    
    private var current: DGImageContext {
        return next ?? self
    }
}

extension DGImageContext {
    
    public func clearClipBuffer(with value: Double = 1) {
        if value == 1 {
            current.clip = nil
        } else if value == 0 {
            current.clip = DGImageContext<GrayColorModel>.Layer()
        } else {
            let _clip = Texture(width: width, height: height, pixel: FloatColorPixel(white: value), option: .inMemory)
            current.clip = DGImageContext<GrayColorModel>.TextureLayer(_clip)
        }
    }
    
    public func resetClip() {
        self.clearClipBuffer(with: 1)
    }
}

extension DGImageContext {
    
    private var currentGraphicState: GraphicState {
        return next?.currentGraphicState ?? GraphicState(context: self)
    }
    
    public func saveGraphicState() {
        graphicStateStack.append(currentGraphicState)
    }
    
    public func restoreGraphicState() {
        if let next = self.next {
            graphicStateStack.popLast()?.apply(to: next)
        } else {
            graphicStateStack.popLast()?.apply(to: self)
        }
    }
}

extension DGImageContext {
    
    public var opacity: Double {
        get {
            return current.styles.opacity
        }
        set {
            current.styles.opacity = newValue
        }
    }
    
    public var transform: SDTransform {
        get {
            return current.styles.transform
        }
        set {
            current.styles.transform = newValue
        }
    }
    
    public var shouldAntialias: Bool {
        get {
            return current.styles.shouldAntialias
        }
        set {
            current.styles.shouldAntialias = newValue
        }
    }
    public var antialias: Int {
        get {
            return current.styles.antialias
        }
        set {
            current.styles.antialias = max(1, newValue)
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current.styles.shadowColor
        }
        set {
            current.styles.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current.styles.shadowOffset
        }
        set {
            current.styles.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current.styles.shadowBlur
        }
        set {
            current.styles.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current.styles.compositingMode
        }
        set {
            current.styles.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current.styles.blendMode
        }
        set {
            current.styles.blendMode = newValue
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current.styles.resamplingAlgorithm
        }
        set {
            current.styles.resamplingAlgorithm = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current.styles.renderingIntent
        }
        set {
            current.styles.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            current.colorSpace.chromaticAdaptationAlgorithm = newValue
        }
    }
}

extension DGImageContext {
    
    private var isShadow: Bool {
        return shadowColor.opacity > 0 && shadowBlur > 0
    }
    
    private var _blendMode: Composer.BlendMode {
        return Composer.BlendMode(compositing: compositingMode, blending: blendMode)
    }
    
    private func draw_shadow(_ source: Layer) {
        
        guard isShadow && !source.is_empty else { return }
        
        let shadowColor = FloatColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        let shadowOffset = self.shadowOffset
        let shadowBlur = self.shadowBlur
        
        let blur = ShadowLayer(source: source, color: shadowColor, offset: shadowOffset, blur: shadowBlur)
        self._image = BlendedLayer(mode: _blendMode, source: blur, destination: self._image, opacity: opacity)
    }
    
    private func draw_layer(_ source: Layer) {
        
        guard width != 0 && height != 0 else { return }
        
        var layer = source
        
        guard !layer.is_empty else { return }
        
        if let clip = self.clip {
            layer = ClipLayer(source: layer, clip: clip)
        }
        
        self.draw_shadow(layer)
        self._image = BlendedLayer(mode: _blendMode, source: layer, destination: self._image, opacity: opacity)
    }
}

extension DGImageContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            let width = self.width
            let height = self.height
            
            if width == 0 || height == 0 {
                return
            }
            
            self.next = DGImageContext(copyStates: self, composer: composer, colorSpace: colorSpace)
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                self.next = nil
                
                self.draw_layer(next._image)
            }
        }
    }
}

extension DGImageContext {
    
    public func draw(shape: Shape, winding: Shape.WindingRule, color: Model, opacity: Double = 1) {
        
        var shape = shape
        shape.transform *= self.transform
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        if width == 0 || height == 0 || shape.transform.determinant.almostZero() {
            return
        }
        
        let _shape = ShapeLayer(shape: shape, winding: winding, color: FloatColorPixel(color: color, opacity: opacity), antialias: shouldAntialias ? antialias : 1, mode: _blendMode)
        
        self.draw_layer(_shape)
    }
}

extension DGImageContext {
    
    public func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Model {
        
        let transform = transform * self.transform
        
        if width == 0 || height == 0 || texture.width == 0 || texture.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let image = ImageLayer(source: Texture(texture: texture).pixels, transform: transform, antialias: shouldAntialias ? antialias : 1, resamplingAlgorithm: resamplingAlgorithm)
        
        self.draw_layer(image)
    }
}

extension DGImageContext {
    
    public func drawClip(body: (DGImageContext<GrayColorModel>) throws -> Void) rethrows {
        try self.drawClip(colorSpace: ColorSpace.calibratedGray(from: colorSpace, gamma: 2.2), body: body)
    }
    
    public func drawClip(colorSpace: ColorSpace<GrayColorModel>, body: (DGImageContext<GrayColorModel>) throws -> Void) rethrows {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        let width = self.width
        let height = self.height
        
        if width == 0 || height == 0 {
            return
        }
        
        let _clip = DGImageContext<GrayColorModel>(copyStates: self, composer: clip_composer, colorSpace: colorSpace)
        
        try body(_clip)
        
        if !_clip._image.is_empty {
            self.clip = _clip._image
        } else {
            self.clearClipBuffer(with: 0)
        }
    }
}

extension DGImageContext {
    
    public func setClip<P>(texture: Texture<P>, transform: SDTransform) where P.Model == GrayColorModel {
        self.drawClip { (context: DGImageContext<GrayColorModel>) in context.draw(texture: texture, transform: transform) }
    }
}

extension DGImageContext {
    
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        self.drawClip { (context: DGImageContext<GrayColorModel>) in context.draw(shape: shape, winding: winding, color: .white) }
    }
}

extension DGImageContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        guard stops.count != 0 else { return }
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { _GradientStop(offset: $0.1.offset, color: FloatColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        let gradient = LinearGradientLayer(stops: stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
        
        self.draw_layer(gradient)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        guard stops.count != 0 else { return }
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { _GradientStop(offset: $0.1.offset, color: FloatColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        let gradient = RadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
        
        self.draw_layer(gradient)
    }
}

#endif
