//
//  Gradient.swift
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

public enum GradientSpreadMode {
    
    case none
    case pad
    case reflect
    case `repeat`
}

public struct GradientStop<Color: ColorProtocol> {
    
    public var offset: Double
    public var color: Color
    
    @inlinable
    public init(offset: Double, color: Color) {
        self.offset = offset
        self.color = color
    }
}

extension GradientStop : Equatable where Color : Equatable {
    
    @inlinable
    public static func ==(lhs: GradientStop, rhs: GradientStop) -> Bool {
        return lhs.offset == rhs.offset && lhs.color == rhs.color
    }
}

extension GradientStop : Hashable where Color : Hashable {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(offset)
        hasher.combine(color)
    }
}

extension GradientStop where Color == AnyColor {
    
    @inlinable
    public init<M>(offset: Double, color: Doggie.Color<M>) {
        self.init(offset: offset, color: AnyColor(color))
    }
}

public enum GradientType {
    
    case linear
    case radial
}

public struct Gradient<Color: ColorProtocol> {
    
    public var type: GradientType
    
    public var start: Point
    public var end: Point
    
    fileprivate var rawCenter: Point {
        switch type {
        case .linear: return 0.5 * (start + end)
        case .radial: return end
        }
    }
    
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
    
    public var transform : SDTransform = SDTransform.identity
    
    public var opacity: Double = 1
    
    public var stops: [GradientStop<Color>]
    
    public init(type: GradientType, start: Point, end: Point, stops: [GradientStop<Color>]) {
        self.type = type
        self.start = start
        self.end = end
        self.stops = stops
    }
}

extension Gradient {
    
    @inlinable
    public mutating func rotate(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.rotate(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func skewX(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewX(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func skewY(_ angle: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.skewY(angle) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func scale(_ scale: Double) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(scale) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func scale(x: Double = 1, y: Double = 1) {
        let center = self.center
        self.transform *= SDTransform.translate(x: -center.x, y: -center.y) * SDTransform.scale(x: x, y: y) * SDTransform.translate(x: center.x, y: center.y)
    }
    
    @inlinable
    public mutating func translate(x: Double = 0, y: Double = 0) {
        self.transform *= SDTransform.translate(x: x, y: y)
    }
    
    @inlinable
    public mutating func reflectX() {
        self.transform *= SDTransform.reflectX(self.center.x)
    }
    
    @inlinable
    public mutating func reflectY() {
        self.transform *= SDTransform.reflectY(self.center.y)
    }
    
    @inlinable
    public mutating func reflectX(_ x: Double) {
        self.transform *= SDTransform.reflectX(x)
    }
    
    @inlinable
    public mutating func reflectY(_ y: Double) {
        self.transform *= SDTransform.reflectY(y)
    }
}

extension Gradient : Equatable where Color : Equatable {
    
}

extension Gradient : Hashable where Color : Hashable {
    
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
}
