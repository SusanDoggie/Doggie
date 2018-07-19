//
//  DrawableContext.swift
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

public protocol DrawableContext : AnyObject {
    
    var opacity: Double { get set }
    
    var transform: SDTransform { get set }
    
    var shadowColor: AnyColor { get set }
    
    var shadowOffset: Size { get set }
    
    var shadowBlur: Double { get set }
    
    var compositingMode: ColorCompositingMode { get set }
    
    var blendMode: ColorBlendMode { get set }
    
    var resamplingAlgorithm: ResamplingAlgorithm { get set }
    
    func saveGraphicState()
    
    func restoreGraphicState()
    
    func beginTransparencyLayer()
    
    func endTransparencyLayer()
    
    func resetClip()
    
    func concatenate(_ transform: SDTransform)
    
    func setClip(shape: Shape, winding: Shape.WindingRule)
    
    func setClip<Image: ImageProtocol>(image: Image, transform: SDTransform)
    
    func draw<Image: ImageProtocol>(image: Image, transform: SDTransform)
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C)
    
    func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C)
    
    func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>)
    
    func stroke<C>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>)
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
}

public protocol TypedDrawableContext: DrawableContext {
    
    associatedtype Model: ColorModelProtocol
    
    var colorSpace: ColorSpace<Model> { get }
    
    var renderingIntent: RenderingIntent { get set }
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get set }
    
    func setClip<P>(texture: Texture<P>, transform: SDTransform) where P.Model == GrayColorModel
    
    func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Model
    
    func draw(shape: Shape, winding: Shape.WindingRule, color: Model, opacity: Double)
    
    func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Model, opacity: Double)
}

extension DrawableContext {
    
    @inlinable
    public func concatenate(_ transform: SDTransform) {
        self.transform = transform * self.transform
    }
    
    @inlinable
    public func rotate(_ angle: Double) {
        self.concatenate(SDTransform.rotate(angle))
    }
    
    @inlinable
    public func skewX(_ angle: Double) {
        self.concatenate(SDTransform.skewX(angle))
    }
    
    @inlinable
    public func skewY(_ angle: Double) {
        self.concatenate(SDTransform.skewY(angle))
    }
    
    @inlinable
    public func scale(_ scale: Double) {
        self.concatenate(SDTransform.scale(scale))
    }
    
    @inlinable
    public func scale(x: Double = 1, y: Double = 1) {
        self.concatenate(SDTransform.scale(x: x, y: y))
    }
    
    @inlinable
    public func translate(x: Double = 0, y: Double = 0) {
        self.concatenate(SDTransform.translate(x: x, y: y))
    }
    
    @inlinable
    public func reflectX(_ x: Double = 0) {
        self.concatenate(SDTransform.reflectX(x))
    }
    
    @inlinable
    public func reflectY(_ y: Double = 0) {
        self.concatenate(SDTransform.reflectY(y))
    }
}

extension DrawableContext {
    
    @inlinable
    public func setClip(rect: Rect) {
        self.setClip(shape: Shape(rect: rect), winding: .nonZero)
    }
    
    @inlinable
    public func setClip(roundedRect rect: Rect, radius: Radius) {
        self.setClip(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero)
    }
    
    @inlinable
    public func setClip(ellipseIn rect: Rect) {
        self.setClip(shape: Shape(ellipseIn: rect), winding: .nonZero)
    }
}

extension DrawableContext {
    
    @inlinable
    public func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        self.draw(shape: shape, winding: winding, color: color.color, opacity: color.opacity)
    }
    
    @inlinable
    public func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Model, opacity: Double = 1) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color, opacity: opacity)
    }
}

extension DrawableContext {
    
    @inlinable
    public func draw<C: ColorProtocol>(rect: Rect, color: C) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    public func draw<C: ColorProtocol>(roundedRect rect: Rect, radius: Radius, color: C) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    public func draw<C: ColorProtocol>(ellipseIn rect: Rect, color: C) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    public func stroke<C: ColorProtocol>(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    public func stroke<C: ColorProtocol>(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    public func stroke<C: ColorProtocol>(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func draw(rect: Rect, color: Model, opacity: Double = 1) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func draw(roundedRect rect: Rect, radius: Radius, color: Model, opacity: Double = 1) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func draw(ellipseIn rect: Rect, color: Model, opacity: Double = 1) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Model, opacity: Double = 1) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Model, opacity: Double = 1) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Model, opacity: Double = 1) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func setClip<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.setClip(texture: Texture<ColorPixel<GrayColorModel>>(image: image.convert(to: ColorSpace.calibratedGray(from: colorSpace, gamma: 2.2), intent: renderingIntent), resamplingAlgorithm: resamplingAlgorithm), transform: transform)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(texture: Texture<ColorPixel<Model>>(image: image.convert(to: colorSpace, intent: renderingIntent), resamplingAlgorithm: resamplingAlgorithm), transform: transform)
    }
}

extension DrawableContext {
    
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>) {
        
        self.beginTransparencyLayer()
        
        self.setClip(shape: shape, winding: winding)
        
        let boundary = shape.originalBoundary
        let transform = gradient.transform * SDTransform.scale(x: boundary.width, y: boundary.height) * SDTransform.translate(x: boundary.x, y: boundary.y) * shape.transform
        
        self.concatenate(transform)
        
        switch gradient.type {
        case .linear: self.drawLinearGradient(stops: gradient.stops, start: gradient.start, end: gradient.end, startSpread: .pad, endSpread: .pad)
        case .radial: self.drawRadialGradient(stops: gradient.stops, start: gradient.start, startRadius: 0, end: gradient.end, endRadius: 0.5, startSpread: .pad, endSpread: .pad)
        }
        
        self.endTransparencyLayer()
    }
    
    @inlinable
    public func stroke<C>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, gradient: gradient)
    }
}

extension DrawableContext {
    
    @inlinable
    public func draw<C>(rect: Rect, gradient: Gradient<C>) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    public func draw<C>(roundedRect rect: Rect, radius: Radius, gradient: Gradient<C>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    public func draw<C>(ellipseIn rect: Rect, gradient: Gradient<C>) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    public func stroke<C>(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, gradient: gradient)
    }
    @inlinable
    public func stroke<C>(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, gradient: gradient)
    }
    @inlinable
    public func stroke<C>(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, gradient: gradient)
    }
}
