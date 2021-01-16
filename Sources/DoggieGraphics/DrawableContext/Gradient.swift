//
//  Gradient.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

public enum GradientSpreadMode: CaseIterable {
    
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

extension GradientStop: Equatable where Color: Equatable {
    
    @inlinable
    @inline(__always)
    public static func ==(lhs: GradientStop, rhs: GradientStop) -> Bool {
        return lhs.offset == rhs.offset && lhs.color == rhs.color
    }
}

extension GradientStop: Hashable where Color: Hashable {
    
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
    public init<M>(_ stop: GradientStop<DoggieGraphics.Color<M>>) {
        self.init(offset: stop.offset, color: AnyColor(stop.color))
    }
    
    @inlinable
    @inline(__always)
    public init<M>(offset: Double, color: DoggieGraphics.Color<M>) {
        self.init(offset: offset, color: AnyColor(color))
    }
}

extension GradientStop {
    
    @inlinable
    @inline(__always)
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> GradientStop<DoggieGraphics.Color<Model>> {
        return GradientStop<DoggieGraphics.Color<Model>>(offset: offset, color: color.convert(to: colorSpace, intent: intent))
    }
    
    @inlinable
    @inline(__always)
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> GradientStop<AnyColor> {
        return GradientStop<AnyColor>(offset: offset, color: color.convert(to: colorSpace, intent: intent))
    }
}

public enum GradientType: CaseIterable {
    
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
    
    public var startSpread: GradientSpreadMode = .pad
    
    public var endSpread: GradientSpreadMode = .pad
    
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
    public init<M>(_ gradient: Gradient<DoggieGraphics.Color<M>>) {
        self.init(type: gradient.type, start: gradient.start, end: gradient.end, stops: gradient.stops.map(GradientStop<AnyColor>.init))
        self.transform = gradient.transform
        self.opacity = gradient.opacity
        self.startSpread = gradient.startSpread
        self.endSpread = gradient.endSpread
    }
}

extension Gradient: Equatable where Color: Equatable {
    
}

extension Gradient: Hashable where Color: Hashable {
    
}

extension Gradient {
    
    @inlinable
    @inline(__always)
    public func convert<Model>(to colorSpace: ColorSpace<Model>, intent: RenderingIntent = .default) -> Gradient<DoggieGraphics.Color<Model>> {
        var result = Gradient<DoggieGraphics.Color<Model>>(type: self.type, start: self.start, end: self.end, stops: self.stops.map { $0.convert(to: colorSpace, intent: intent) })
        result.transform = self.transform
        result.opacity = self.opacity
        result.startSpread = self.startSpread
        result.endSpread = self.endSpread
        return result
    }
    
    @inlinable
    @inline(__always)
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> Gradient<AnyColor> {
        var result = Gradient<AnyColor>(type: self.type, start: self.start, end: self.end, stops: self.stops.map { $0.convert(to: colorSpace, intent: intent) })
        result.transform = self.transform
        result.opacity = self.opacity
        result.startSpread = self.startSpread
        result.endSpread = self.endSpread
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
