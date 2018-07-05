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
    
    associatedtype ColorSpace
    
    var colorSpace: ColorSpace { get }
    
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
    
    func setClip(shape: Shape, winding: Shape.WindingRule)
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C)
    
    func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C)
    
    func draw<Image: ImageProtocol>(image: Image, transform: SDTransform)
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
}

public protocol TypedDrawableContext: DrawableContext where ColorSpace == Doggie.ColorSpace<Pixel.Model> {
    
    associatedtype Pixel: ColorPixelProtocol
    
    var renderingIntent: RenderingIntent { get set }
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get set }
    
    func draw(shape: Shape, winding: Shape.WindingRule, color: Pixel.Model, opacity: Double)
    
    func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Pixel.Model, opacity: Double)
    
    func draw<P>(texture: Texture<P>, transform: SDTransform) where P.Model == Pixel.Model
}

extension DrawableContext {
    
    @inlinable
    public func rotate(_ angle: Double) {
        self.transform *= SDTransform.rotate(angle)
    }
    
    @inlinable
    public func skewX(_ angle: Double) {
        self.transform *= SDTransform.skewX(angle)
    }
    
    @inlinable
    public func skewY(_ angle: Double) {
        self.transform *= SDTransform.skewY(angle)
    }
    
    @inlinable
    public func scale(_ scale: Double) {
        self.transform *= SDTransform.scale(scale)
    }
    
    @inlinable
    public func scale(x: Double = 1, y: Double = 1) {
        self.transform *= SDTransform.scale(x: x, y: y)
    }
    
    @inlinable
    public func translate(x: Double = 0, y: Double = 0) {
        self.transform *= SDTransform.translate(x: x, y: y)
    }
    
    @inlinable
    public func reflectX(_ x: Double = 0) {
        self.transform *= SDTransform.reflectX(x)
    }
    
    @inlinable
    public func reflectY(_ y: Double = 0) {
        self.transform *= SDTransform.reflectY(y)
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

extension TypedDrawableContext {
    
    @inlinable
    public func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        self.draw(shape: shape, winding: winding, color: color.color, opacity: color.opacity)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color, opacity: opacity)
    }
    
    @inlinable
    public func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        self.stroke(shape: shape, width: width, cap: cap, join: join, color: color.color, opacity: color.opacity)
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
    public func draw(rect: Rect, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func draw(roundedRect rect: Rect, radius: Radius, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func draw(ellipseIn rect: Rect, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Pixel.Model, opacity: Double = 1) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Pixel.Model, opacity: Double = 1) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
    @inlinable
    public func stroke(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: Pixel.Model, opacity: Double = 1) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color, opacity: opacity)
    }
}

extension TypedDrawableContext {
    
    @inlinable
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(texture: Texture<ColorPixel<Pixel.Model>>(image: image.convert(to: colorSpace, intent: renderingIntent), resamplingAlgorithm: resamplingAlgorithm), transform: transform)
    }
}
