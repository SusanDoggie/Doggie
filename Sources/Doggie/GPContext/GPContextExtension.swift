//
//  GPContextExtension.swift
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

#if canImport(CoreImage) || canImport(QuartzCore)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func stroke(path: CGPath, width: CGFloat, lineCap: CGLineCap, lineJoin: CGLineJoin, miterLimit: CGFloat, color: CGColor) {
        let path = path.copy(strokingWithWidth: width, lineCap: lineCap, lineJoin: lineJoin, miterLimit: miterLimit)
        self.draw(path: path, rule: .winding, color: color)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw(shape: Shape, winding: Shape.WindingRule, color: CGColor) {
        
        let rule: CGPathFillRule
        switch winding {
        case .nonZero: rule = .winding
        case .evenOdd: rule = .evenOdd
        }
        
        self.draw(path: shape.cgPath, rule: rule, color: color)
    }
    
    public func clip(shape: Shape, winding: Shape.WindingRule) {
        
        let rule: CGPathFillRule
        switch winding {
        case .nonZero: rule = .winding
        case .evenOdd: rule = .evenOdd
        }
        
        self.clip(path: shape.cgPath, rule: rule)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func concatenate(_ transform: SDTransform) {
        self.transform = transform * self.transform
    }
    
    public func rotate(_ angle: Double) {
        self.concatenate(SDTransform.rotate(angle))
    }
    
    public func skewX(_ angle: Double) {
        self.concatenate(SDTransform.skewX(angle))
    }
    
    public func skewY(_ angle: Double) {
        self.concatenate(SDTransform.skewY(angle))
    }
    
    public func scale(_ scale: Double) {
        self.concatenate(SDTransform.scale(scale))
    }
    
    public func scale(x: Double = 1, y: Double = 1) {
        self.concatenate(SDTransform.scale(x: x, y: y))
    }
    
    public func translate(x: Double = 0, y: Double = 0) {
        self.concatenate(SDTransform.translate(x: x, y: y))
    }
    
    public func reflectX(_ x: Double = 0) {
        self.concatenate(SDTransform.reflectX(x))
    }
    
    public func reflectY(_ y: Double = 0) {
        self.concatenate(SDTransform.reflectY(y))
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func clip(rect: Rect) {
        self.clip(shape: Shape(rect: rect), winding: .nonZero)
    }
    
    public func clip(roundedRect rect: Rect, radius: Radius) {
        self.clip(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero)
    }
    
    public func clip(ellipseIn rect: Rect) {
        self.clip(shape: Shape(ellipseIn: rect), winding: .nonZero)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: CGColor) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, color: color)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw(rect: Rect, color: CGColor) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color)
    }
    public func draw(roundedRect rect: Rect, radius: Radius, color: CGColor) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color)
    }
    public func draw(ellipseIn rect: Rect, color: CGColor) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color)
    }
    public func stroke(rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: CGColor) {
        self.stroke(shape: Shape(rect: rect), width: width, cap: cap, join: join, color: color)
    }
    public func stroke(roundedRect rect: Rect, radius: Radius, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: CGColor) {
        self.stroke(shape: Shape(roundedRect: rect, radius: radius), width: width, cap: cap, join: join, color: color)
    }
    public func stroke(ellipseIn rect: Rect, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, color: CGColor) {
        self.stroke(shape: Shape(ellipseIn: rect), width: width, cap: cap, join: join, color: color)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw(image: CGImage, in rect: Rect) {
        let rect = rect.standardized
        let transform = SDTransform.scale(x: rect.width / Double(image.width), y: rect.height / Double(image.height)) * SDTransform.translate(x: rect.minX, y: rect.minY)
        self.draw(image: image, transform: transform)
    }
    
    public func draw(image: CGImage, transform: SDTransform) {
        self.draw(image: CIImage(cgImage: image), transform: transform)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw<C>(_ image: Image<C>, in rect: Rect) {
        guard let image = image.cgImage else { return }
        self.draw(image: image, in: rect)
    }
    
    public func draw(_ image: AnyImage, in rect: Rect) {
        guard let image = image.cgImage else { return }
        self.draw(image: image, in: rect)
    }
    
    public func draw<C>(_ image: Image<C>, transform: SDTransform) {
        guard let image = image.cgImage else { return }
        self.draw(image: image, transform: transform)
    }
    
    public func draw(_ image: AnyImage, transform: SDTransform) {
        guard let image = image.cgImage else { return }
        self.draw(image: image, transform: transform)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func drawLinearGradient(colorSpace: CGColorSpace, gradient: CGGradient, start startPoint: CGPoint, end endPoint: CGPoint, options: CGGradientDrawingOptions) {
        
        self.drawLayer(colorSpace: colorSpace) { context in
            
            context.setBlendMode(.copy)
            
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: options)
        }
    }
    
    public func drawRadialGradient(colorSpace: CGColorSpace, gradient: CGGradient, startCenter: CGPoint, startRadius: CGFloat, endCenter: CGPoint, endRadius: CGFloat, options: CGGradientDrawingOptions) {
        
        self.drawLayer(colorSpace: colorSpace) { context in
            
            context.setBlendMode(.copy)
            
            context.drawRadialGradient(gradient, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: options)
        }
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func drawLinearGradient<C>(colorSpace: ColorSpace<RGBColorModel>, stops: [GradientStop<C>], start: Point, end: Point, options: CGGradientDrawingOptions) {
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        guard let gradient = CGGradientCreate(colorSpace: colorSpace, stops: stops) else { return }
        
        self.drawLinearGradient(colorSpace: cgColorSpace, gradient: gradient, start: CGPoint(start), end: CGPoint(end), options: options)
    }
    
    public func drawRadialGradient<C>(colorSpace: ColorSpace<RGBColorModel>, stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, options: CGGradientDrawingOptions) {
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        guard let gradient = CGGradientCreate(colorSpace: colorSpace, stops: stops) else { return }
        
        self.drawRadialGradient(colorSpace: cgColorSpace, gradient: gradient, startCenter: CGPoint(start), startRadius: CGFloat(startRadius), endCenter: CGPoint(end), endRadius: CGFloat(endRadius), options: options)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension GPContext {
    
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>, colorSpace: ColorSpace<RGBColorModel>) {
        
        self.beginTransparencyLayer()
        
        self.clip(shape: shape, winding: winding)
        
        let boundary = shape.originalBoundary
        let transform = gradient.transform * SDTransform.scale(x: boundary.width, y: boundary.height) * SDTransform.translate(x: boundary.x, y: boundary.y) * shape.transform
        
        self.concatenate(transform)
        
        let options: CGGradientDrawingOptions = [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        
        switch gradient.type {
        case .linear: self.drawLinearGradient(colorSpace: colorSpace, stops: gradient.stops, start: gradient.start, end: gradient.end, options: options)
        case .radial: self.drawRadialGradient(colorSpace: colorSpace, stops: gradient.stops, start: gradient.start, startRadius: 0, end: gradient.end, endRadius: 0.5, options: options)
        }
        
        self.endTransparencyLayer()
    }
}

#endif
