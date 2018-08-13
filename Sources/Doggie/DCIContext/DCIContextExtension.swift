//
//  DCIContextExtension.swift
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

#if canImport(CoreImage) || canImport(QuartzCore)

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
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

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
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

@available(OSX 10.13, iOS 11.0, tvOS 11.0, *)
extension DCIContext {
    
    @inlinable
    public func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: AnyColor) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color)
    }
    
    @inlinable
    public func draw(rect: Rect, color: AnyColor) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    @inlinable
    public func draw(roundedRect rect: Rect, radius: Radius, color: AnyColor) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    @inlinable
    public func draw(ellipseIn rect: Rect, color: AnyColor) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    @inlinable
    public func stroke(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: AnyColor) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    public func stroke(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: AnyColor) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color)
    }
    @inlinable
    public func stroke(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: AnyColor) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color)
    }
}

#endif
