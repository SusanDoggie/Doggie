//
//  DrawableContext.swift
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

public protocol DrawableContext : AnyObject {
    
    var opacity: Double { get set }
    
    var transform: SDTransform { get set }
    
    var shadowColor: AnyColor { get set }
    
    var shadowOffset: Size { get set }
    
    var shadowBlur: Double { get set }
    
    var compositingMode: ColorCompositingMode { get set }
    
    var blendMode: ColorBlendMode { get set }
    
    var renderingIntent: RenderingIntent { get set }
    
    func saveGraphicState()
    
    func restoreGraphicState()
    
    func beginTransparencyLayer()
    
    func endTransparencyLayer()
    
    func resetClip()
    
    func concatenate(_ transform: SDTransform)
    
    func clip(shape: Shape, winding: Shape.WindingRule)
    
    func drawClip(body: (DrawableContext) throws -> Void) rethrows
    
    func draw<Image: ImageProtocol>(image: Image, transform: SDTransform)
    
    func draw(image: ImageRep, transform: SDTransform)
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C)
    
    func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C)
    
    func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>)
    
    func stroke<C>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>)
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode)
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
    public func stroke<C: ColorProtocol>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color)
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
    public func stroke<C: ColorProtocol>(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    @inline(__always)
    public func stroke<C: ColorProtocol>(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    @inline(__always)
    public func stroke<C: ColorProtocol>(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: C) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color)
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
    public func draw<Image : ImageProtocol>(image: Image, in rect: Rect) {
        let rect = rect.standardized
        let transform = SDTransform.scale(x: rect.width / Double(image.width), y: rect.height / Double(image.height)) * SDTransform.translate(x: rect.minX, y: rect.minY)
        self.draw(image: image, transform: transform)
    }
    
    @inlinable
    @inline(__always)
    public func draw(image: ImageRep, in rect: Rect) {
        let rect = rect.standardized
        let transform = SDTransform.scale(x: rect.width / Double(image.width), y: rect.height / Double(image.height)) * SDTransform.translate(x: rect.minX, y: rect.minY)
        self.draw(image: image, transform: transform)
    }
}

public enum GradientSpreadMode : CaseIterable {
    
    case none
    case pad
    case reflect
    case `repeat`
}

@frozen
public struct GradientStop<Color: ColorProtocol> {
    
    public var offset: Double
    public var color: Color
    
    @inlinable
    @inline(__always)
    public init(offset: Double, color: Color) {
        self.offset = offset
        self.color = color
    }
}

extension GradientStop : Equatable where Color : Equatable {
    
    @inlinable
    @inline(__always)
    public static func ==(lhs: GradientStop, rhs: GradientStop) -> Bool {
        return lhs.offset == rhs.offset && lhs.color == rhs.color
    }
}

extension GradientStop : Hashable where Color : Hashable {
    
    @inlinable
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(offset)
        hasher.combine(color)
    }
}

extension GradientStop where Color == AnyColor {
    
    @inlinable
    @inline(__always)
    public init<M>(_ stop: GradientStop<Doggie.Color<M>>) {
        self.init(offset: stop.offset, color: AnyColor(stop.color))
    }
    
    @inlinable
    @inline(__always)
    public init<M>(offset: Double, color: Doggie.Color<M>) {
        self.init(offset: offset, color: AnyColor(color))
    }
}

extension GradientStop {
    
    @inlinable
    @inline(__always)
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> GradientStop<Doggie.Color<Model>> {
        return GradientStop<Doggie.Color<Model>>(offset: offset, color: color.convert(to: colorSpace, intent: intent))
    }
    
    @inlinable
    @inline(__always)
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> GradientStop<AnyColor> {
        return GradientStop<AnyColor>(offset: offset, color: color.convert(to: colorSpace, intent: intent))
    }
}

public enum GradientType : CaseIterable {
    
    case linear
    case radial
}

@frozen
public struct Gradient<Color: ColorProtocol> {
    
    public var type: GradientType
    
    public var start: Point
    public var end: Point
    
    @inlinable
    @inline(__always)
    var rawCenter: Point {
        switch type {
        case .linear: return 0.5 * (start + end)
        case .radial: return end
        }
    }
    
    @inlinable
    @inline(__always)
    public var center: Point {
        get {
            return rawCenter * transform
        }
        set {
            let _center = center
            if _center != newValue {
                let offset = newValue - rawCenter * transform
                transform *= SDTransform.translate(x: offset.x, y: offset.y)
            }
        }
    }
    
    public var transform: SDTransform = .identity
    
    public var opacity: Double = 1
    
    public var stops: [GradientStop<Color>]
    
    @inlinable
    @inline(__always)
    public init(type: GradientType, start: Point, end: Point, stops: [GradientStop<Color>]) {
        self.type = type
        self.start = start
        self.end = end
        self.stops = stops
    }
}

extension Gradient where Color == AnyColor {
    
    @inlinable
    @inline(__always)
    public init<M>(_ gradient: Gradient<Doggie.Color<M>>) {
        self.init(type: gradient.type, start: gradient.start, end: gradient.end, stops: gradient.stops.map(GradientStop<AnyColor>.init))
        self.transform = gradient.transform
        self.opacity = gradient.opacity
    }
}

extension Gradient {
    
    @inlinable
    @inline(__always)
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> Gradient<Doggie.Color<Model>> {
        var result = Gradient<Doggie.Color<Model>>(type: self.type, start: self.start, end: self.end, stops: self.stops.map { $0.convert(to: colorSpace, intent: intent) })
        result.transform = self.transform
        result.opacity = self.opacity
        return result
    }
    
    @inlinable
    @inline(__always)
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> Gradient<AnyColor> {
        var result = Gradient<AnyColor>(type: self.type, start: self.start, end: self.end, stops: self.stops.map { $0.convert(to: colorSpace, intent: intent) })
        result.transform = self.transform
        result.opacity = self.opacity
        return result
    }
}

extension Gradient {
    
    @inlinable
    @inline(__always)
    public mutating func rotate(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.rotate(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func skewX(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewX(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func skewY(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewY(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func scale(_ scale: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(scale) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func scale(x: Double = 1, y: Double = 1) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(x: x, y: y) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func translate(x: Double = 0, y: Double = 0) {
        self.transform *= SDTransform.translate(x: x, y: y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func reflectX() {
        self.transform *= SDTransform.reflectX(self.center.x)
    }
    
    @inlinable
    @inline(__always)
    public mutating func reflectY() {
        self.transform *= SDTransform.reflectY(self.center.y)
    }
    
    @inlinable
    @inline(__always)
    public mutating func reflectX(_ x: Double) {
        self.transform *= SDTransform.reflectX(x)
    }
    
    @inlinable
    @inline(__always)
    public mutating func reflectY(_ y: Double) {
        self.transform *= SDTransform.reflectY(y)
    }
}

extension Gradient : Equatable where Color : Equatable {
    
}

extension Gradient : Hashable where Color : Hashable {
    
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>) {
        
        self.beginTransparencyLayer()
        
        self.clip(shape: shape, winding: winding)
        
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
    @inline(__always)
    public func stroke<C>(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, gradient: gradient)
    }
}

extension DrawableContext {
    
    @inlinable
    @inline(__always)
    public func draw<C>(rect: Rect, gradient: Gradient<C>) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(roundedRect rect: Rect, radius: Radius, gradient: Gradient<C>) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    @inline(__always)
    public func draw<C>(ellipseIn rect: Rect, gradient: Gradient<C>) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, gradient: gradient)
    }
    @inlinable
    @inline(__always)
    public func stroke<C>(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, gradient: gradient)
    }
    @inlinable
    @inline(__always)
    public func stroke<C>(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, gradient: gradient)
    }
    @inlinable
    @inline(__always)
    public func stroke<C>(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<C>) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, gradient: gradient)
    }
}
