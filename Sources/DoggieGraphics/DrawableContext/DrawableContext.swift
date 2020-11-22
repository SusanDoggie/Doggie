//
//  DrawableContext.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol DrawableContext: AnyObject {
    
    var opacity: Double { get set }
    
    var transform: SDTransform { get set }
    
    var shadowColor: AnyColor { get set }
    
    var shadowOffset: Size { get set }
    
    var shadowBlur: Double { get set }
    
    var compositingMode: ColorCompositingMode { get set }
    
    var blendMode: ColorBlendMode { get set }
    
    var renderingIntent: RenderingIntent { get set }
    
    var isRasterContext: Bool { get }
    
    func saveGraphicState()
    
    func restoreGraphicState()
    
    func beginTransparencyLayer()
    
    func endTransparencyLayer()
    
    func resetClip()
    
    func concatenate(_ transform: SDTransform)
    
    func clip(shape: Shape, winding: Shape.WindingRule)
    
    func clipToDrawing(body: (DrawableContext) throws -> Void) rethrows
    
    func draw<Image: ImageProtocol>(image: Image, transform: SDTransform)
    
    func draw(image: ImageRep, transform: SDTransform)
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C)
    
    func draw<C: ColorProtocol>(shape: Shape, stroke: Stroke<C>)
    
    func draw<C>(shape: Shape, winding: Shape.WindingRule, color: Gradient<C>)
    
    func draw<C>(shape: Shape, stroke: Stroke<Gradient<C>>)
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
    
    func draw<C>(shape: Shape, winding: Shape.WindingRule, color: MeshGradient<C>)
    
    func draw<C>(shape: Shape, stroke: Stroke<MeshGradient<C>>)
    
    func drawMeshGradient<C>(_ mesh: MeshGradient<C>)
    
    func draw(shape: Shape, winding: Shape.WindingRule, color: Pattern)
    
    func draw(shape: Shape, stroke: Stroke<Pattern>)
    
    func drawPattern(_ pattern: Pattern)
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func concatenate(_ transform: SDTransform) {
        self.transform = transform * self.transform
    }
    
    @inlinable
    @inline(__always)
    public func rotate(_ angle: Double) {
        self.concatenate(SDTransform.rotate(angle))
    }
    
    @inlinable
    @inline(__always)
    public func skewX(_ angle: Double) {
        self.concatenate(SDTransform.skewX(angle))
    }
    
    @inlinable
    @inline(__always)
    public func skewY(_ angle: Double) {
        self.concatenate(SDTransform.skewY(angle))
    }
    
    @inlinable
    @inline(__always)
    public func scale(_ scale: Double) {
        self.concatenate(SDTransform.scale(scale))
    }
    
    @inlinable
    @inline(__always)
    public func scale(x: Double = 1, y: Double = 1) {
        self.concatenate(SDTransform.scale(x: x, y: y))
    }
    
    @inlinable
    @inline(__always)
    public func translate(x: Double = 0, y: Double = 0) {
        self.concatenate(SDTransform.translate(x: x, y: y))
    }
    
    @inlinable
    @inline(__always)
    public func reflectX(_ x: Double = 0) {
        self.concatenate(SDTransform.reflectX(x))
    }
    
    @inlinable
    @inline(__always)
    public func reflectY(_ y: Double = 0) {
        self.concatenate(SDTransform.reflectY(y))
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func clip(rect: Rect) {
        self.clip(shape: Shape(rect: rect), winding: .nonZero)
    }
    
    @inlinable
    @inline(__always)
    public func clip(roundedRect rect: Rect, radius: Radius) {
        self.clip(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero)
    }
    
    @inlinable
    @inline(__always)
    public func clip(ellipseIn rect: Rect) {
        self.clip(shape: Shape(ellipseIn: rect), winding: .nonZero)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(shape: Shape, stroke: Stroke<C>) {
        self.draw(shape: shape.strokePath(stroke), winding: .nonZero, color: stroke.color)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(rect: Rect, color: C) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(roundedRect rect: Rect, radius: Radius, color: C) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(ellipseIn rect: Rect, color: C) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(rect: Rect, stroke: Stroke<C>) {
        self.draw(shape: Shape(rect: rect), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(roundedRect rect: Rect, radius: Radius, stroke: Stroke<C>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(ellipseIn rect: Rect, stroke: Stroke<C>) {
        self.draw(shape: Shape(ellipseIn: rect), stroke: stroke)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw(image: ImageRep, transform: SDTransform) {
        self.draw(image: AnyImage(imageRep: image), transform: transform)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<Image: ImageProtocol>(image: Image, in rect: Rect) {
        
        guard !rect.isEmpty else { return }
        
        let transform = SDTransform.scale(x: rect.width / Double(image.width), y: rect.height / Double(image.height)) * SDTransform.translate(x: rect.minX, y: rect.minY)
        
        self.draw(image: image, transform: transform)
    }
    
    @inlinable
    @inline(__always)
    public func draw(image: ImageRep, in rect: Rect) {
        
        guard !rect.isEmpty else { return }
        
        let transform = SDTransform.scale(x: rect.width / Double(image.width), y: rect.height / Double(image.height)) * SDTransform.translate(x: rect.minX, y: rect.minY)
        
        self.draw(image: image, transform: transform)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, color gradient: Gradient<C>) {
        
        let boundary = shape.originalBoundary
        guard !boundary.isEmpty else { return }
        
        let transform = gradient.transform * SDTransform.scale(x: boundary.width, y: boundary.height) * SDTransform.translate(x: boundary.minX, y: boundary.minY) * shape.transform
        
        self.beginTransparencyLayer()
        
        self.clip(shape: shape, winding: winding)
        
        self.concatenate(transform)
        
        self.opacity = gradient.opacity
        
        switch gradient.type {
        case .linear: self.drawLinearGradient(stops: gradient.stops, start: gradient.start, end: gradient.end, startSpread: gradient.startSpread, endSpread: gradient.endSpread)
        case .radial: self.drawRadialGradient(stops: gradient.stops, start: gradient.start, startRadius: 0, end: gradient.end, endRadius: 0.5, startSpread: gradient.startSpread, endSpread: gradient.endSpread)
        }
        
        self.endTransparencyLayer()
    }
    
    @inlinable
    @inline(__always)
    public func draw<C>(shape: Shape, stroke: Stroke<Gradient<C>>) {
        self.draw(shape: shape.strokePath(stroke), winding: .nonZero, color: stroke.color)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(rect: Rect, color: Gradient<C>) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(roundedRect rect: Rect, radius: Radius, color: Gradient<C>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(ellipseIn rect: Rect, color: Gradient<C>) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(rect: Rect, stroke: Stroke<Gradient<C>>) {
        self.draw(shape: Shape(rect: rect), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(roundedRect rect: Rect, radius: Radius, stroke: Stroke<Gradient<C>>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(ellipseIn rect: Rect, stroke: Stroke<Gradient<C>>) {
        self.draw(shape: Shape(ellipseIn: rect), stroke: stroke)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, color gradient: MeshGradient<C>) {
        
        let boundary = shape.originalBoundary
        guard !boundary.isEmpty else { return }
        
        let transform = gradient.transform * SDTransform.scale(x: boundary.width, y: boundary.height) * SDTransform.translate(x: boundary.minX, y: boundary.minY) * shape.transform
        
        self.beginTransparencyLayer()
        
        self.clip(shape: shape, winding: winding)
        
        self.concatenate(transform)
        
        self.opacity = gradient.opacity
        
        self.drawMeshGradient(gradient)
        
        self.endTransparencyLayer()
    }
    
    @inlinable
    @inline(__always)
    public func draw<C>(shape: Shape, stroke: Stroke<MeshGradient<C>>) {
        self.draw(shape: shape.strokePath(stroke), winding: .nonZero, color: stroke.color)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(rect: Rect, color: MeshGradient<C>) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(roundedRect rect: Rect, radius: Radius, color: MeshGradient<C>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(ellipseIn rect: Rect, color: MeshGradient<C>) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(rect: Rect, stroke: Stroke<MeshGradient<C>>) {
        self.draw(shape: Shape(rect: rect), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(roundedRect rect: Rect, radius: Radius, stroke: Stroke<MeshGradient<C>>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(ellipseIn rect: Rect, stroke: Stroke<MeshGradient<C>>) {
        self.draw(shape: Shape(ellipseIn: rect), stroke: stroke)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw(shape: Shape, winding: Shape.WindingRule, color pattern: Pattern) {
        
        self.beginTransparencyLayer()
        
        self.clip(shape: shape, winding: winding)
        
        self.drawPattern(pattern)
        
        self.endTransparencyLayer()
    }
    
    @inlinable
    @inline(__always)
    public func draw(shape: Shape, stroke: Stroke<Pattern>) {
        self.draw(shape: shape.strokePath(stroke), winding: .nonZero, color: stroke.color)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw(rect: Rect, color: Pattern) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw(roundedRect rect: Rect, radius: Radius, color: Pattern) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw(ellipseIn rect: Rect, color: Pattern) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    @inline(__always)
    public func draw(rect: Rect, stroke: Stroke<Pattern>) {
        self.draw(shape: Shape(rect: rect), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw(roundedRect rect: Rect, radius: Radius, stroke: Stroke<Pattern>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), stroke: stroke)
    }
    @inlinable
    @inline(__always)
    public func draw(ellipseIn rect: Rect, stroke: Stroke<Pattern>) {
        self.draw(shape: Shape(ellipseIn: rect), stroke: stroke)
    }
}
