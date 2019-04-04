//
//  DGImageContext.swift
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
        self.clip = context.state.clip
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.chromaticAdaptationAlgorithm
    }
    
    func apply<Pixel>(to context: DGImageContext<Pixel>) {
        context.state.clip = self.clip
        context.styles = self.styles
        context.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

struct DGImageContextState<Model: ColorModelProtocol> {
    
    var clip: DGImageContext<GrayColorModel>.Layer?
    
    var image: DGImageContext<Model>.Layer = DGImageContext<Model>.Layer()
    
}

public class DGImageContext<Model: ColorModelProtocol> : DrawableContext {
    
    public let width: Int
    public let height: Int
    public let resolution: Resolution
    public fileprivate(set) var colorSpace: ColorSpace<Model>
    
    var state: DGImageContextState<Model> = DGImageContextState<Model>()
    fileprivate var styles: DGImageContextStyles = DGImageContextStyles()
    private var graphicStateStack: [GraphicState] = []
    
    private var next: DGImageContext?
    
    public init(image: Image<Float32ColorPixel<Model>>) {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        self.state.image = TextureLayer(Texture(image: image))
    }
    
    public init(width: Int, height: Int, resolution: Resolution = .default, colorSpace: ColorSpace<Model>) {
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
    }
}

extension DGImageContext {
    
    private convenience init<M>(copyStates context: DGImageContext<M>, colorSpace: ColorSpace<Model>) {
        self.init(width: context.width, height: context.height, resolution: context.resolution, colorSpace: colorSpace)
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
    
    public var image: Image<Float32ColorPixel<Model>> {
        guard width != 0 && height != 0 else { return Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace) }
        guard let texture = self.state.image.cached_image else { return Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace) }
        return Image(texture: texture, resolution: resolution, colorSpace: colorSpace)
    }
}

extension DGImageContext {
    
    private var current_layer: DGImageContext {
        return next?.current_layer ?? self
    }
    
    public func clone() -> DGImageContext {
        let clone = DGImageContext(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
        clone.state = self.state
        clone.styles = self.styles
        clone.graphicStateStack = self.graphicStateStack
        clone.next = self.next?.clone()
        return clone
    }
}

extension DGImageContext {
    
    public func clearClipBuffer(with value: Double = 1) {
        if value == 1 {
            current_layer.state.clip = nil
        } else if value == 0 {
            current_layer.state.clip = DGImageContext<GrayColorModel>.Layer()
        } else {
            let _clip = Texture(width: width, height: height, pixel: Float32ColorPixel(white: value), fileBacked: false)
            current_layer.state.clip = DGImageContext<GrayColorModel>.TextureLayer(_clip)
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
            return current_layer.styles.opacity
        }
        set {
            current_layer.styles.opacity = newValue
        }
    }
    
    public var transform: SDTransform {
        get {
            return current_layer.styles.transform
        }
        set {
            current_layer.styles.transform = newValue
        }
    }
    
    public var shouldAntialias: Bool {
        get {
            return current_layer.styles.shouldAntialias
        }
        set {
            current_layer.styles.shouldAntialias = newValue
        }
    }
    public var antialias: Int {
        get {
            return current_layer.styles.antialias
        }
        set {
            current_layer.styles.antialias = max(1, newValue)
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current_layer.styles.shadowColor
        }
        set {
            current_layer.styles.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current_layer.styles.shadowOffset
        }
        set {
            current_layer.styles.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current_layer.styles.shadowBlur
        }
        set {
            current_layer.styles.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current_layer.styles.compositingMode
        }
        set {
            current_layer.styles.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current_layer.styles.blendMode
        }
        set {
            current_layer.styles.blendMode = newValue
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current_layer.styles.resamplingAlgorithm
        }
        set {
            current_layer.styles.resamplingAlgorithm = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current_layer.styles.renderingIntent
        }
        set {
            current_layer.styles.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current_layer.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            current_layer.colorSpace.chromaticAdaptationAlgorithm = newValue
        }
    }
}

extension DGImageContext {
    
    private func draw_layer(_ source: Layer) {
        
        guard width != 0 && height != 0 else { return }
        
        guard !source.is_empty && (state.clip?.is_empty != true) else { return }
        
        let shadowColor = Float32ColorPixel(self.shadowColor.convert(to: colorSpace, intent: renderingIntent))
        
        self.state.image = BlendedLayer(source: source,
                                   destination: self.state.image,
                                   clip: state.clip,
                                   shadowColor: shadowColor,
                                   shadowOffset: shadowOffset,
                                   shadowBlur: shadowBlur,
                                   opacity: opacity,
                                   compositingMode: compositingMode,
                                   blendMode: blendMode)
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
            
            self.next = DGImageContext(copyStates: self, colorSpace: colorSpace)
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                self.next = nil
                self.draw_layer(next.state.image)
            }
        }
    }
}

extension DGImageContext {
    
    public func draw(shape: Shape, winding: Shape.WindingRule, color: Model, opacity: Double = 1) {
        
        if let next = self.next {
            next.draw(shape: shape, winding: winding, color: color, opacity: opacity)
            return
        }
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let shape = shape * self.transform
        
        if width == 0 || height == 0 || shape.transform.determinant.almostZero() {
            return
        }
        
        let _shape = ShapeLayer(shape: shape, winding: winding, color: Float32ColorPixel(color: color, opacity: opacity), antialias: shouldAntialias ? antialias : 1)
        
        self.draw_layer(_shape)
    }
}

extension DGImageContext {
    
    public func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Model {
        
        if let next = self.next {
            next.draw(texture: texture, transform: transform)
            return
        }
        
        let transform = transform * self.transform
        
        if width == 0 || height == 0 || texture.width == 0 || texture.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let image = ImageLayer(source: Texture(texture: texture), transform: transform.inverse, antialias: shouldAntialias ? antialias : 1)
        
        self.draw_layer(image)
    }
}

extension DGImageContext {
    
    public func drawClip(body: (DrawableContext) throws -> Void) rethrows {
        try self.drawClip { (context: DGImageContext<GrayColorModel>) in try body(context) }
    }
    
    public func drawClip(colorSpace: ColorSpace<GrayColorModel> = .genericGamma22Gray, body: (DGImageContext<GrayColorModel>) throws -> Void) rethrows {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        let width = self.width
        let height = self.height
        
        if width == 0 || height == 0 {
            return
        }
        
        let _clip = DGImageContext<GrayColorModel>(copyStates: self, colorSpace: colorSpace)
        
        try body(_clip)
        
        if !_clip.state.image.is_empty {
            self.state.clip = _clip.state.image
        } else {
            self.clearClipBuffer(with: 0)
        }
    }
}

extension DGImageContext {
    
    public func clip(shape: Shape, winding: Shape.WindingRule) {
        self.drawClip { (context: DGImageContext<GrayColorModel>) in context.draw(shape: shape, winding: winding, color: .white) }
    }
}

extension DGImageContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        if let next = self.next {
            next.drawLinearGradient(stops: stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
            return
        }
        
        guard stops.count != 0 && !self.transform.determinant.almostZero() else { return }
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { DGRendererEncoderGradientStop(offset: $0.1.offset, color: Float64ColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        let gradient = LinearGradientLayer(stops: stops, transform: transform.inverse, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
        
        self.draw_layer(gradient)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        if let next = self.next {
            next.drawRadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
            return
        }
        
        guard stops.count != 0 && !self.transform.determinant.almostZero() else { return }
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { DGRendererEncoderGradientStop(offset: $0.1.offset, color: Float64ColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        let gradient = RadialGradientLayer(stops: stops, transform: transform.inverse, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
        
        self.draw_layer(gradient)
    }
}
