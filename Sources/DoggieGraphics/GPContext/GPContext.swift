//
//  GPContext.swift
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

#if canImport(CoreImage)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
private struct GPContextStyles {
    
    static let defaultShadowColor = CGColor(colorSpace: CGColorSpaceCreateDeviceGray(), components: [0.0 as CGFloat, 1.0 as CGFloat / 3.0])!
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shouldAntialias: Bool = true
    
    var shadowColor: CGColor = GPContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var blendKernel: CIBlendKernel = .sourceOver
    
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
private struct GraphicState {
    
    var clip: CIImage?
    
    var styles: GPContextStyles
    
    init(context: GPContext) {
        self.clip = context.state.clip
        self.styles = context.styles
    }
    
    func apply(to context: GPContext) {
        context.state.clip = self.clip
        context.styles = self.styles
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
private struct GPContextState {
    
    var clip: CIImage?
    
    var isDirty: Bool = false
    
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
public class GPContext {
    
    private var _image: GPContextBase
    
    fileprivate var state: GPContextState = GPContextState()
    
    fileprivate var styles: GPContextStyles = GPContextStyles()
    private var graphicStateStack: [GraphicState] = []
    
    private var next: GPContext?
    
    public init(width: Int, height: Int) {
        self._image = GPContextBase(width: width, height: height, _image: nil)
    }
    
    private init(image: GPContextBase) {
        self._image = image
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    private convenience init(copyStates context: GPContext) {
        self.init(width: context.width, height: context.height)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = GPContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.blendKernel = .sourceOver
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    private static let black: CIImage = {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) { return CIImage.black }
        return CIImage(color: CIColor.black)
    }()
    
    private var current_layer: GPContext {
        return next?.current_layer ?? self
    }
    
    public var extent: Rect {
        return _image.extent
    }
    
    public func clone() -> GPContext {
        let clone = GPContext(image: self._image)
        clone.state = self.state
        clone.styles = self.styles
        clone.graphicStateStack = self.graphicStateStack
        clone.next = self.next?.clone()
        return clone
    }
    
    public var image: CIImage {
        return _image.image.clamped(to: extent).cropped(to: extent)
    }
}

extension CIImage {
    
    fileprivate func _insertingIntermediate() -> CIImage {
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            return self.insertingIntermediate()
        }
        return self
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func clearClipBuffer(with value: Double = 1) {
        switch value {
        case 1: current_layer.state.clip = nil
        case 0: current_layer.state.clip = GPContext.black
        default:
            let color = CIColor(red: CGFloat(value), green: CGFloat(value), blue: CGFloat(value), alpha: 1)
            current_layer.state.clip = CIImage(color: color)
        }
    }
    
    public func resetClip() {
        self.clearClipBuffer(with: 1)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func saveGraphicState() {
        graphicStateStack.append(GraphicState(context: current_layer))
    }
    
    public func restoreGraphicState() {
        graphicStateStack.popLast()?.apply(to: current_layer)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public var width: Int {
        return _image.width
    }
    
    public var height: Int {
        return _image.height
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
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
    
    public var shadowColor: CGColor {
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
    
    public var blendKernel: CIBlendKernel {
        get {
            return current_layer.styles.blendKernel
        }
        set {
            current_layer.styles.blendKernel = newValue
        }
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    private func blend_layer(_ image: GPContextBase) {
        
        var image = image
        
        if let clip = current_layer.state.clip {
            image = image.applyingFilter("CIBlendWithMask", parameters: [kCIInputBackgroundImageKey: CIImage.empty(), kCIInputMaskImageKey: clip])
        }
        
        var blended: GPContextBase
        
        let background_colorSpace = current_layer._image.graphic_stack.first.map { $0.colorSpace.name }
        let foreground_colorSpace = image.graphic_stack.first.map { $0.colorSpace.name }
        let is_colorSpace = background_colorSpace == nil || background_colorSpace == foreground_colorSpace
        let is_normal = blendKernel === CIBlendKernel.sourceOver && image.graphic_stack.allSatisfy { $0.blendMode == .normal }
        
        if is_normal && image._image == nil && is_colorSpace {
            blended = current_layer._image
            blended.graphic_stack.append(contentsOf: image.graphic_stack)
        } else {
            guard let _blended = blendKernel.apply(foreground: image.image, background: current_layer._image.image) else { return }
            blended = GPContextBase(width: width, height: height, _image: _blended)
        }
        
        current_layer._image = blended
        current_layer.state.isDirty = true
    }
    
    private func draw_layer(_ image: GPContextBase) {
        
        guard opacity > 0 else { return }
        
        var image = image
        
        if opacity < 1 {
            let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(opacity)))
            image = image.applyingFilter("CIBlendWithAlphaMask", parameters: [kCIInputBackgroundImageKey: CIImage.empty(), kCIInputMaskImageKey: mask])
        }
        
        self.blend_layer(image)
    }
    
    private func draw_layer(_ image: CIImage) {
        self.draw_layer(GPContextBase(width: width, height: height, _image: image))
    }
    
    private func draw_color_mask(_ mask: CIImage, _ color: CGColor, _ alpha_mask: Bool) {
        
        guard opacity > 0 else { return }
        guard let color = opacity < 1 ? color.copy(alpha: color.alpha * CGFloat(opacity)) : color else { return }
        
        let filter = alpha_mask ? "CIBlendWithAlphaMask" : "CIBlendWithMask"
        
        let _color = CIImage(color: CIColor(cgColor: color))
        let image = _color.applyingFilter(filter, parameters: [kCIInputBackgroundImageKey: CIImage.empty(), kCIInputMaskImageKey: mask])
        
        self.blend_layer(GPContextBase(width: width, height: height, _image: image))
    }
    
    private func draw_shadow(_ image: CIImage, _ alpha_mask: Bool) {
        
        guard shadowColor.alpha > 0 && shadowBlur > 0 && opacity > 0 else { return }
        
        let shadow = image.gaussianBlur(sigma: 0.5 * shadowBlur).transformed(by: .translate(x: shadowOffset.width, y: shadowOffset.height))
        self.draw_color_mask(shadow, shadowColor, alpha_mask)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            
            next.beginTransparencyLayer()
            
        } else {
            
            let width = self.width
            let height = self.height
            
            guard width != 0 && height != 0 else { return }
            
            self.next = GPContext(copyStates: self)
        }
    }
    
    public func endTransparencyLayer() {
        
        guard let next = self.next else { return }
        
        if next.next != nil {
            
            next.endTransparencyLayer()
            
        } else {
            
            let width = self.width
            let height = self.height
            
            self.next = nil
            
            guard width != 0 && height != 0 && next.state.isDirty else { return }
            
            var layer = next._image
            
            if shadowColor.alpha > 0 && shadowBlur > 0 {
                layer = layer.insertingIntermediate()
            }
            
            self.draw_shadow(layer.image, true)
            self.draw_layer(layer)
        }
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw(path: CGPath, rule: CGPathFillRule, color: CGColor) {
        
        guard !path.isEmpty && width != 0 && height != 0 && !self.transform.determinant.almostZero() else { return }
        
        let path = path.transformed(by: self.transform)
        let intersection = path.boundingBoxOfPath.intersection(CGRect(extent))
        
        guard !intersection.isNull else { return }
        
        let is_shadow = shadowColor.alpha > 0 && shadowBlur > 0
        let is_clip = current_layer.state.clip != nil
        
        let is_colorSpace = _image.graphic_stack.first.map { $0.colorSpace.name == color.colorSpace?.name } ?? true
        
        var blendMode: CGBlendMode?
        
        switch blendKernel {
        case .sourceOver: blendMode = .normal
        case .exclusiveOr: blendMode = .xor
        case .multiply: blendMode = .multiply
        case .screen: blendMode = .screen
        case .overlay: blendMode = .overlay
        case .darken: blendMode = .darken
        case .lighten: blendMode = .lighten
        case .colorDodge: blendMode = .colorDodge
        case .colorBurn: blendMode = .colorBurn
        case .softLight: blendMode = .softLight
        case .hardLight: blendMode = .hardLight
        case .difference: blendMode = .difference
        case .exclusion: blendMode = .exclusion
        case .clear: blendMode = .clear
        case .source: blendMode = .copy
        case .sourceIn: blendMode = .sourceIn
        case .sourceOut: blendMode = .sourceOut
        case .sourceAtop: blendMode = .sourceAtop
        case .destinationOver: blendMode = .destinationOver
        case .destinationIn: blendMode = .destinationIn
        case .destinationOut: blendMode = .destinationOut
        case .destinationAtop: blendMode = .destinationAtop
        default: break
        }
        
        if !is_shadow && !is_clip && is_colorSpace, let blendMode = blendMode {
            
            guard opacity > 0 else { return }
            guard let color = opacity < 1 ? color.copy(alpha: color.alpha * CGFloat(opacity)) : color else { return }
            
            current_layer._image.draw(path: path, rule: rule, blendMode: blendMode, color: color, shouldAntialias: shouldAntialias)
            current_layer.state.isDirty = true
            
        } else {
            
            let extent = intersection.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
            guard var mask = try? CGPathProcessorKernel.apply(withExtent: extent, path: path, rule: rule, shouldAntialias: self.shouldAntialias) else { return }
            
            if is_shadow {
                mask = mask._insertingIntermediate()
            }
            
            self.draw_shadow(mask, false)
            self.draw_color_mask(mask, color, false)
        }
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw(image: CIImage, transform: SDTransform) {
        
        let transform = transform * self.transform
        
        guard width != 0 && height != 0 && !transform.determinant.almostZero() else { return }
        
        var image = transform == .identity ? image : image.transformed(by: transform)
        image = image.clamped(to: extent).cropped(to: extent)._insertingIntermediate()
        
        self.draw_shadow(image, true)
        self.draw_layer(image)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func clip(path: CGPath, rule: CGPathFillRule) {
        
        self.clearClipBuffer(with: 0)
        
        guard !path.isEmpty && width != 0 && height != 0 && !self.transform.determinant.almostZero() else { return }
        
        let path = path.transformed(by: self.transform)
        let intersection = path.boundingBoxOfPath.intersection(CGRect(extent))
        
        guard !intersection.isNull else { return }
        
        let extent = intersection.insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        guard let clip = try? CGPathProcessorKernel.apply(withExtent: extent, path: path, rule: rule, shouldAntialias: self.shouldAntialias) else { return }
        
        current_layer.state.clip = clip.composited(over: GPContext.black)._insertingIntermediate()
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func drawClip(body: (GPContext) throws -> Void) rethrows {
        
        let width = self.width
        let height = self.height
        
        guard width != 0 && height != 0 else { return }
        
        let _clip = GPContext(copyStates: current_layer)
        
        try body(_clip)
        
        if _clip.state.isDirty {
            
            let clip = _clip._image.applyingFilter("CIColorMonochrome", parameters: [kCIInputColorKey: CIColor.white])
            
            current_layer.state.clip = clip.composited(over: GPContext.black).image._insertingIntermediate()
            
        } else {
            current_layer.clearClipBuffer(with: 0)
        }
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func drawLayer(colorSpace: CGColorSpace, callback: @escaping (CGContext) throws -> Void) {
        
        let width = self.width
        let height = self.height
        
        guard width != 0 && height != 0 && !self.transform.determinant.almostZero() else { return }
        
        guard colorSpace.model == .rgb else { return }
        
        let extent = self.extent.inset(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
        guard var layer = try? CGContextProcessorKernel.apply(withExtent: CGRect(extent), colorSpace: colorSpace, transform: CGAffineTransform(self.transform), shouldAntialias: self.shouldAntialias, callback: callback) else { return }
        
        if shadowColor.alpha > 0 && shadowBlur > 0 {
            layer = layer._insertingIntermediate()
        }
        
        self.draw_shadow(layer, true)
        self.draw_layer(layer)
    }
}

#endif
