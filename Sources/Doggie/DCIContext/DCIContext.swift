//
//  DCIContext.swift
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

#if canImport(CoreImage)

import CoreImage

#endif

#if canImport(QuartzCore)

import QuartzCore

#endif

#if canImport(CoreImage) || canImport(QuartzCore)

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
private struct DCIContextStyles {
    
    static let defaultShadowColor = AnyColor(colorSpace: .default, white: 0.0, opacity: 1.0 / 3.0)
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shadowColor: AnyColor = DCIContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var blendMode: CGBlendMode = .normal
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
private struct GraphicState {
    
    var styles: DCIContextStyles
    var clip: CIImage?
    
    init(context: DCIContext) {
        self.styles = context.styles
        self.clip = context.clip
    }
    
    func apply(to context: DCIContext) {
        context.styles = self.styles
        context.clip = self.clip
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
public class DCIContext {
    
    public private(set) var image: CIImage
    
    public let width: Int
    public let height: Int
    
    fileprivate var clip: CIImage?
    
    fileprivate var styles: DCIContextStyles = DCIContextStyles()
    
    private var next: DCIContext?
    
    private var graphicStateStack: [GraphicState] = []
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.image = CIImage(color: .clear).cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    private convenience init(copyStates context: DCIContext) {
        self.init(width: context.width, height: context.height)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = DCIContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    private var current: DCIContext {
        return next ?? self
    }
    
    private var bound: CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func clearClipBuffer(with value: Double = 1) {
        current.clip = value == 1 ? nil : CIImage(color: CIColor(cgColor: AnyColor(white: value).cgColor!)).cropped(to: bound)
    }
    
    public func resetClip() {
        self.clearClipBuffer(with: 1)
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
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

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
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
    
    public var blendMode: CGBlendMode {
        get {
            return current.styles.blendMode
        }
        set {
            current.styles.blendMode = newValue
        }
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    private static let ciContext = CIContext()
    
    public var cgImage: CGImage? {
        return DCIContext.ciContext.createCGImage(image, from: bound)
    }
}

@available(OSX 10.14, iOS 12.0, tvOS 12.0, *)
extension DCIContext {
    
    public func insertingIntermediate() {
        current.image = current.image.insertingIntermediate()
    }
    
    public func insertingIntermediate(cache: Bool) {
        current.image = current.image.insertingIntermediate(cache: cache)
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    private var isShadow: Bool {
        return shadowColor.opacity > 0 && shadowBlur > 0
    }
    
    private func create_shadow(_ image: CIImage) -> CIImage? {
        guard isShadow, let color = shadowColor.cgColor else { return nil }
        var shadow = CIImage(color: CIColor(cgColor: color))
        shadow = shadow.applyingFilter("CIBlendWithAlphaMask", parameters: ["inputBackgroundImage": CIImage.empty(), "inputMaskImage": image])
        shadow = shadow.cropped(to: bound)
        shadow = shadow.applyingGaussianBlur(sigma: 0.5 * shadowBlur)
        shadow = shadow.transformed(by: CGAffineTransform(translationX: CGFloat(shadowOffset.width), y: CGFloat(shadowOffset.height)))
        return shadow
    }
    
    private func blend(_ source: CIImage) {
        
        var source = source.cropped(to: bound)
        
        if let clip = current.clip {
            source = source.applyingFilter("CIBlendWithMask", parameters: ["inputBackgroundImage": CIImage.empty(), "inputMaskImage": clip])
            source = source.cropped(to: bound)
        }
        
        if let shadow = create_shadow(source) {
            current._blend(shadow)
        }
        
        current._blend(source)
    }
    
    private func _blend(_ source: CIImage) {
        
        var source = source
        
        let opacity = self.opacity
        if opacity < 1 {
            source = source.applyingFilter("CIBlendWithMask", parameters: ["inputBackgroundImage": CIImage.empty(), "inputMaskImage": CIImage(color: CIColor(cgColor: AnyColor(white: opacity).cgColor!))])
        }
        
        switch blendMode {
        case .normal: self.image = CIBlendKernel.sourceOver.apply(foreground: source, background: image)!.cropped(to: bound)
        case .multiply: self.image = CIBlendKernel.multiply.apply(foreground: source, background: image)!.cropped(to: bound)
        case .screen: self.image = CIBlendKernel.screen.apply(foreground: source, background: image)!.cropped(to: bound)
        case .overlay: self.image = CIBlendKernel.overlay.apply(foreground: source, background: image)!.cropped(to: bound)
        case .darken: self.image = CIBlendKernel.darken.apply(foreground: source, background: image)!.cropped(to: bound)
        case .lighten: self.image = CIBlendKernel.lighten.apply(foreground: source, background: image)!.cropped(to: bound)
        case .colorDodge: self.image = CIBlendKernel.colorDodge.apply(foreground: source, background: image)!.cropped(to: bound)
        case .colorBurn: self.image = CIBlendKernel.colorBurn.apply(foreground: source, background: image)!.cropped(to: bound)
        case .softLight: self.image = CIBlendKernel.softLight.apply(foreground: source, background: image)!.cropped(to: bound)
        case .hardLight: self.image = CIBlendKernel.hardLight.apply(foreground: source, background: image)!.cropped(to: bound)
        case .difference: self.image = CIBlendKernel.difference.apply(foreground: source, background: image)!.cropped(to: bound)
        case .exclusion: self.image = CIBlendKernel.exclusion.apply(foreground: source, background: image)!.cropped(to: bound)
        case .hue: self.image = CIBlendKernel.hue.apply(foreground: source, background: image)!.cropped(to: bound)
        case .saturation: self.image = CIBlendKernel.saturation.apply(foreground: source, background: image)!.cropped(to: bound)
        case .color: self.image = CIBlendKernel.color.apply(foreground: source, background: image)!.cropped(to: bound)
        case .luminosity: self.image = CIBlendKernel.luminosity.apply(foreground: source, background: image)!.cropped(to: bound)
        case .clear: self.image = CIBlendKernel.clear.apply(foreground: source, background: image)!.cropped(to: bound)
        case .sourceIn: self.image = CIBlendKernel.sourceIn.apply(foreground: source, background: image)!.cropped(to: bound)
        case .sourceOut: self.image = CIBlendKernel.sourceOut.apply(foreground: source, background: image)!.cropped(to: bound)
        case .sourceAtop: self.image = CIBlendKernel.sourceAtop.apply(foreground: source, background: image)!.cropped(to: bound)
        case .destinationOver: self.image = CIBlendKernel.destinationOver.apply(foreground: source, background: image)!.cropped(to: bound)
        case .destinationIn: self.image = CIBlendKernel.destinationIn.apply(foreground: source, background: image)!.cropped(to: bound)
        case .destinationOut: self.image = CIBlendKernel.destinationOut.apply(foreground: source, background: image)!.cropped(to: bound)
        case .destinationAtop: self.image = CIBlendKernel.destinationAtop.apply(foreground: source, background: image)!.cropped(to: bound)
        default: self.image = CIBlendKernel.sourceOver.apply(foreground: source, background: image)!.cropped(to: bound)
        }
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func draw(image: CGImage, transform: SDTransform) {
        self.draw(image: CIImage(cgImage: image), transform: transform)
    }
    
    public func draw(image: CIImage, transform: SDTransform) {
        self.blend(image.transformed(by: CGAffineTransform(transform * self.transform)))
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            let width = self.width
            let height = self.height
            
            if width == 0 || height == 0 {
                return
            }
            
            self.next = DCIContext(copyStates: self)
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
                
                self.blend(next.image)
            }
        }
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func setClip(image: CGImage, transform: SDTransform) {
        self.setClip(image: CIImage(cgImage: image), transform: transform)
    }
    
    public func setClip(image: CIImage, transform: SDTransform) {
        current.clip = image.transformed(by: CGAffineTransform(transform * self.transform)).composited(over: CIImage(color: .black)).cropped(to: bound)
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, *) {
            current.clip = current.clip?.insertingIntermediate()
        }
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        
        guard let image = CGImage.create(width: width, height: height, command: { context in
            context.concatenate(self.transform)
            context.setFillColor(AnyColor.white)
            context.addPath(shape)
            switch winding {
            case .nonZero: context.fillPath(using: .winding)
            case .evenOdd: context.fillPath(using: .evenOdd)
            }
        }) else { return }
        
        current.clip = CIImage(cgImage: image).composited(over: CIImage(color: .black)).cropped(to: bound)
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, *) {
            current.clip = current.clip?.insertingIntermediate()
        }
    }
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    public func draw(shape: Shape, winding: Shape.WindingRule, color: AnyColor) {
        
        guard let image = CGImage.create(width: width, height: height, command: { context in
            context.concatenate(self.transform)
            context.setFillColor(color)
            context.addPath(shape)
            switch winding {
            case .nonZero: context.fillPath(using: .winding)
            case .evenOdd: context.fillPath(using: .evenOdd)
            }
        }) else { return }
        
        self.blend(CIImage(cgImage: image))
    }
}

#endif
