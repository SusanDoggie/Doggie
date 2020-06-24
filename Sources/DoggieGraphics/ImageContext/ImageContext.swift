//
//  ImageContext.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
    
    var convolutionAlgorithm: ImageConvolutionAlgorithm = .cooleyTukey
    
    var compositingMode: ColorCompositingMode = .default
    var blendMode: ColorBlendMode = .default
    
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    
    var renderCullingMode: ImageContextRenderCullMode = .none
    var renderDepthCompareMode: ImageContextRenderDepthCompareMode = .always
    
    var renderingIntent: RenderingIntent = .default
    
}

private struct GraphicState {
    
    var clip: MappedBuffer<Float>?
    var depth: MappedBuffer<Float>?
    
    var styles: ImageContextStyles
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    init<Pixel>(context: ImageContext<Pixel>) {
        self.clip = context.state.clip
        self.depth = context.state.depth
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.chromaticAdaptationAlgorithm
    }
    
    func apply<Pixel>(to context: ImageContext<Pixel>) {
        context.state.clip = self.clip
        context.state.depth = self.depth
        context.styles = self.styles
        context.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

@frozen
@usableFromInline
struct ImageContextState {
    
    @usableFromInline
    var clip: MappedBuffer<Float>?
    
    @usableFromInline
    var depth: MappedBuffer<Float>?
    
    @usableFromInline
    var isDirty: Bool = false
    
}

public class ImageContext<Pixel: ColorPixel>: DrawableContext {
    
    @usableFromInline
    var _image: Image<Pixel>
    
    @usableFromInline
    var state: ImageContextState = ImageContextState()
    
    fileprivate var styles: ImageContextStyles = ImageContextStyles()
    private var graphicStateStack: [GraphicState] = []
    
    @usableFromInline
    var next: ImageContext?
    
    public init(image: Image<Pixel>) {
        self._image = image
    }
    
    public init(width: Int, height: Int, resolution: Resolution = .default, colorSpace: ColorSpace<Pixel.Model>, fileBacked: Bool = false) {
        self._image = Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace, fileBacked: fileBacked)
    }
}

extension ImageContext {
    
    @usableFromInline
    convenience init<P>(copyStates context: ImageContext<P>, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: context.width, height: context.height, resolution: context.resolution, colorSpace: colorSpace, fileBacked: context.image.fileBacked)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = ImageContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
        self._image.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension ImageContext {
    
    @usableFromInline
    var current_layer: ImageContext {
        return next?.current_layer ?? self
    }
    
    public func clone() -> ImageContext {
        let clone = ImageContext(image: self._image)
        clone.state = self.state
        clone.styles = self.styles
        clone.graphicStateStack = self.graphicStateStack
        clone.next = self.next?.clone()
        return clone
    }
    
    public var image: Image<Pixel> {
        return _image
    }
}

extension ImageContext {
    
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        let current_layer = self.current_layer
        current_layer.state.isDirty = true
        return try current_layer._image.withUnsafeMutableBufferPointer(body)
    }
    
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        return try current_layer.image.withUnsafeBufferPointer(body)
    }
}

extension ImageContext {
    
    public var clipStencilTexture: StencilTexture<Float> {
        let current_layer = self.current_layer
        let pixels = current_layer.state.clip ?? MappedBuffer(repeating: 1, count: image.width * image.height, fileBacked: image.fileBacked)
        return StencilTexture(width: image.width, height: image.height, resamplingAlgorithm: .default, pixels: pixels)
    }
    
    public func withUnsafeMutableClipBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Float>) throws -> R) rethrows -> R {
        
        let current_layer = self.current_layer
        
        var clip = current_layer.state.clip ?? MappedBuffer(repeating: 1, count: image.width * image.height, fileBacked: image.fileBacked)
        
        current_layer.state.clip = nil
        
        let result = try clip.withUnsafeMutableBufferPointer(body)
        
        current_layer.state.clip = clip
        
        return result
    }
    
    public func withUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<Float>?) throws -> R) rethrows -> R {
        return try current_layer.state.clip?.withUnsafeBufferPointer(body) ?? body(nil)
    }
    
    @inlinable
    @inline(__always)
    public func clearClipBuffer(with value: Double = 1) {
        
        if value == 1 {
            
            current_layer.state.clip = nil
            
        } else if current_layer.state.clip == nil || value == 0 {
            
            current_layer.state.clip = MappedBuffer(repeating: Float(value), count: image.width * image.height, fileBacked: image.fileBacked)
            
        } else {
            
            let value = Float(value)
            
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
    
    public func saveGraphicState() {
        graphicStateStack.append(GraphicState(context: current_layer))
    }
    
    public func restoreGraphicState() {
        graphicStateStack.popLast()?.apply(to: current_layer)
    }
}

public enum ImageConvolutionAlgorithm: CaseIterable {
    
    case direct
    case cooleyTukey
}

extension ImageContext {
    
    public var isRasterContext: Bool {
        return true
    }
    
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
    
    public var convolutionAlgorithm: ImageConvolutionAlgorithm {
        get {
            return current_layer.styles.convolutionAlgorithm
        }
        set {
            current_layer.styles.convolutionAlgorithm = newValue
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
            return current_layer.image.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            current_layer._image.colorSpace.chromaticAdaptationAlgorithm = newValue
        }
    }
}

public enum ImageContextRenderCullMode: CaseIterable {
    
    case none
    case front
    case back
}

public enum ImageContextRenderDepthCompareMode: CaseIterable {
    
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
    
    public var depthStencilTexture: StencilTexture<Float> {
        let current_layer = self.current_layer
        let pixels = current_layer.state.depth ?? MappedBuffer(repeating: 1, count: image.width * image.height, fileBacked: image.fileBacked)
        return StencilTexture(width: image.width, height: image.height, resamplingAlgorithm: .default, pixels: pixels)
    }
    
    public func withUnsafeMutableDepthBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Float>) throws -> R) rethrows -> R {
        
        let current_layer = self.current_layer
        
        var depth = current_layer.state.depth ?? MappedBuffer(repeating: 1, count: image.width * image.height, fileBacked: image.fileBacked)
        
        current_layer.state.depth = nil
        
        let result = try depth.withUnsafeMutableBufferPointer(body)
        
        current_layer.state.depth = depth
        
        return result
    }
    
    public func withUnsafeDepthBufferPointer<R>(_ body: (UnsafeBufferPointer<Float>?) throws -> R) rethrows -> R {
        return try current_layer.state.depth?.withUnsafeBufferPointer(body) ?? body(nil)
    }
}

extension ImageContext {
    
    public var renderCullingMode: ImageContextRenderCullMode {
        get {
            return current_layer.styles.renderCullingMode
        }
        set {
            current_layer.styles.renderCullingMode = newValue
        }
    }
    
    public var renderDepthCompareMode: ImageContextRenderDepthCompareMode {
        get {
            return current_layer.styles.renderDepthCompareMode
        }
        set {
            current_layer.styles.renderDepthCompareMode = newValue
        }
    }
    
    @inlinable
    @inline(__always)
    public func clearRenderDepthBuffer(with value: Double = 1) {
        
        if value == 1 {
            
            current_layer.state.depth = nil
            
        } else if current_layer.state.depth == nil || value == 0 {
            
            current_layer.state.depth = MappedBuffer(repeating: Float(value), count: image.width * image.height, fileBacked: image.fileBacked)
            
        } else {
            
            let value = Float(value)
            
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
        return current_layer.image.colorSpace
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
            
            guard width != 0 && height != 0 else { return }
            
            self.next = ImageContext(copyStates: self, colorSpace: colorSpace)
        }
    }
    
    @inlinable
    @inline(__always)
    public func endTransparencyLayer() {
        
        guard let next = self.next else { return }
        
        if next.next != nil {
            
            next.endTransparencyLayer()
            
        } else {
            
            let width = self.width
            let height = self.height
            
            self.next = nil
            
            guard width != 0 && height != 0 && next.state.isDirty else { return }
            
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

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func clipToDrawing(body: (DrawableContext) throws -> Void) rethrows {
        try self.clipToDrawing { (context: ImageContext<Float32ColorPixel<GrayColorModel>>) in try body(context) }
    }
    
    @inlinable
    @inline(__always)
    public func clipToDrawing<P>(colorSpace: ColorSpace<GrayColorModel> = .genericGamma22Gray, body: (ImageContext<P>) throws -> Void) rethrows where P.Model == GrayColorModel {
        
        let width = self.width
        let height = self.height
        
        guard width != 0 && height != 0 else { return }
        
        let _clip = ImageContext<P>(copyStates: current_layer, colorSpace: colorSpace)
        
        try body(_clip)
        
        if _clip.state.isDirty {
            current_layer.state.clip = _clip.image.pixels.map { Float($0.color.white * $0.opacity) }
        } else {
            current_layer.clearClipBuffer(with: 0)
        }
    }
}
