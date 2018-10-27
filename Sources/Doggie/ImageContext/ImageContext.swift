//
//  ImageContext.swift
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

private struct ImageContextStyles {
    
    static let defaultShadowColor = AnyColor(colorSpace: .default, white: 0.0, opacity: 1.0 / 3.0)
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shouldAntialias: Bool = true
    var antialias: Int = 5
    
    var shadowColor: AnyColor = ImageContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var compositingMode: ColorCompositingMode = .default
    var blendMode: ColorBlendMode = .default
    
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    
    var renderCullingMode: ImageContextRenderCullMode = .none
    var renderDepthCompareMode: ImageContextRenderDepthCompareMode = .always
    var renderingIntent: RenderingIntent = .default
    
}

private struct GraphicState {
    
    var clip: MappedBuffer<Double>?
    var depth: MappedBuffer<Double>?
    
    var styles: ImageContextStyles
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    init<Pixel>(context: ImageContext<Pixel>) {
        self.clip = context.clip
        self.depth = context.depth
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.chromaticAdaptationAlgorithm
    }
    
    func apply<Pixel>(to context: ImageContext<Pixel>) {
        context.clip = self.clip
        context.depth = self.depth
        context.styles = self.styles
        context.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

public class ImageContext<Pixel: ColorPixelProtocol> : TypedDrawableContext {
    
    public private(set) var image: Image<Pixel>
    
    fileprivate var clip: MappedBuffer<Double>?
    fileprivate var depth: MappedBuffer<Double>?
    
    fileprivate var styles: ImageContextStyles = ImageContextStyles()
    
    private var next: ImageContext?
    
    private var isDirty: Bool = false
    
    private var graphicStateStack: [GraphicState] = []
    
    public init(image: Image<Pixel>) {
        self.image = image
    }
    
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, option: MappedBufferOption = .default) {
        self.image = Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
    }
}

extension ImageContext {
    
    private convenience init<P>(copyStates context: ImageContext<P>, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: context.width, height: context.height, colorSpace: colorSpace, option: context.image.option)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = ImageContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
        self.image.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension ImageContext {
    
    private var current: ImageContext {
        return next ?? self
    }
}

extension ImageContext {
    
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        let current = self.current
        current.isDirty = true
        return try current.image.withUnsafeMutableBufferPointer(body)
    }
    
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        return try current.image.withUnsafeBufferPointer(body)
    }
}

extension ImageContext {
    
    public func withUnsafeMutableClipBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        let current = self.current
        
        if current.clip == nil {
            current.clip = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
        }
        
        return try current.clip!.withUnsafeMutableBufferPointer(body)
    }
    
    public func withUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        let current = self.current
        
        if current.clip == nil {
            current.clip = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
        }
        
        return try current.clip!.withUnsafeBufferPointer(body)
    }
    
    @usableFromInline
    func withOptionalUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>?) throws -> R) rethrows -> R {
        return try current.clip?.withUnsafeBufferPointer(body) ?? body(nil)
    }
    
    public func clearClipBuffer(with value: Double = 1) {
        
        if value == 1 {
            
            current.clip = nil
            
        } else if current.clip == nil || value == 0 {
            
            current.clip = MappedBuffer(repeating: value, count: image.width * image.height, option: image.option)
            
        } else {
            
            withUnsafeMutableDepthBufferPointer { buf in
                
                guard var clip = buf.baseAddress else { return }
                
                for _ in 0..<buf.count {
                    clip.pointee = value
                    clip += 1
                }
            }
        }
    }
    
    public func resetClip() {
        self.clearClipBuffer(with: 1)
    }
}

extension ImageContext {
    
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

extension ImageContext {
    
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
            return current.image.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            current.image.colorSpace.chromaticAdaptationAlgorithm = newValue
        }
    }
}

public enum ImageContextRenderCullMode {
    
    case none
    case front
    case back
}

public enum ImageContextRenderDepthCompareMode {
    
    case always
    case never
    case equal
    case notEqual
    case less
    case lessEqual
    case greater
    case greaterEqual
}

extension ImageContext {
    
    public func withUnsafeMutableDepthBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        let current = self.current
        
        if current.depth == nil {
            current.depth = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
        }
        
        return try current.depth!.withUnsafeMutableBufferPointer(body)
    }
    
    public func withUnsafeDepthBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        let current = self.current
        
        if current.depth == nil {
            current.depth = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
        }
        
        return try current.depth!.withUnsafeBufferPointer(body)
    }
}

extension ImageContext {
    
    public var renderCullingMode: ImageContextRenderCullMode {
        get {
            return current.styles.renderCullingMode
        }
        set {
            current.styles.renderCullingMode = newValue
        }
    }
    
    public var renderDepthCompareMode: ImageContextRenderDepthCompareMode {
        get {
            return current.styles.renderDepthCompareMode
        }
        set {
            current.styles.renderDepthCompareMode = newValue
        }
    }
    
    public func clearRenderDepthBuffer(with value: Double = 1) {
        
        if value == 1 {
            
            current.depth = nil
            
        } else if current.depth == nil || value == 0 {
            
            current.depth = MappedBuffer(repeating: value, count: image.width * image.height, option: image.option)
            
        } else {
            
            withUnsafeMutableDepthBufferPointer { buf in
                
                guard var depth = buf.baseAddress else { return }
                
                for _ in 0..<buf.count {
                    depth.pointee = value
                    depth += 1
                }
            }
        }
    }
    
    public func resetRenderDepth() {
        self.clearRenderDepthBuffer(with: 1)
    }
}

extension ImageContext {
    
    public var colorSpace: ColorSpace<Pixel.Model> {
        return current.image.colorSpace
    }
    
    public var width: Int {
        return image.width
    }
    
    public var height: Int {
        return image.height
    }
    
    public var resolution: Resolution {
        return image.resolution
    }
}

extension ImageContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            let width = self.width
            let height = self.height
            
            if width == 0 || height == 0 {
                return
            }
            
            self.next = ImageContext(copyStates: self, colorSpace: colorSpace)
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                let width = self.width
                let height = self.height
                
                self.next = nil
                
                if width == 0 || height == 0 {
                    return
                }
                
                guard next.isDirty else { return }
                
                if isShadow {
                    
                    self._drawWithShadow(texture: Texture(image: next.image))
                    
                } else {
                    
                    next.image.withUnsafeBufferPointer { source in
                        
                        guard var source = source.baseAddress else { return }
                        
                        self._withUnsafePixelBlender { blender in
                            
                            var blender = blender
                            
                            for _ in 0..<width * height {
                                blender.draw { source.pointee }
                                blender += 1
                                source += 1
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ImageContext {
    
    public func drawClip<P>(body: (ImageContext<P>) throws -> Void) rethrows where P.Model == GrayColorModel {
        try self.drawClip(colorSpace: ColorSpace.calibratedGray(from: colorSpace, gamma: 2.2), body: body)
    }
    
    public func drawClip<P>(colorSpace: ColorSpace<GrayColorModel>, body: (ImageContext<P>) throws -> Void) rethrows where P.Model == GrayColorModel {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        let width = self.width
        let height = self.height
        
        if width == 0 || height == 0 {
            return
        }
        
        let _clip = ImageContext<P>(copyStates: self, colorSpace: colorSpace)
        
        try body(_clip)
        
        if _clip.isDirty {
            self.clip = _clip.image.pixels.map { $0.color.white * $0.opacity }
        } else {
            self.clearClipBuffer(with: 0)
        }
    }
}

extension ImageContext {
    
    public func setClip<P>(texture: Texture<P>, transform: SDTransform) where P.Model == GrayColorModel {
        self.drawClip { (context: ImageContext<ColorPixel<GrayColorModel>>) in context.draw(texture: texture, transform: transform) }
    }
}
