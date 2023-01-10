//
//  ImageContextExtension.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        self.draw(shape: shape, winding: winding, color: color.color, opacity: color.opacity)
    }
    
    @inlinable
    @inline(__always)
    public func draw(shape: Shape, stroke: Stroke<Pixel.Model>, opacity: Double = 1) {
        self.draw(shape: shape.strokePath(stroke), winding: .nonZero, color: stroke.color, opacity: opacity)
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func draw(rect: Rect, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(rect: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    @inline(__always)
    public func draw(roundedRect rect: Rect, radius: Radius, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    @inline(__always)
    public func draw(ellipseIn rect: Rect, color: Pixel.Model, opacity: Double = 1) {
        self.draw(shape: Shape(ellipseIn: rect), winding: .nonZero, color: color, opacity: opacity)
    }
    @inlinable
    @inline(__always)
    public func draw(rect: Rect, stroke: Stroke<Pixel.Model>, opacity: Double = 1) {
        self.draw(shape: Shape(rect: rect), stroke: stroke, opacity: opacity)
    }
    @inlinable
    @inline(__always)
    public func draw(roundedRect rect: Rect, radius: Radius, stroke: Stroke<Pixel.Model>, opacity: Double = 1) {
        self.draw(shape: Shape(roundedRect: rect, radius: radius), stroke: stroke, opacity: opacity)
    }
    @inlinable
    @inline(__always)
    public func draw(ellipseIn rect: Rect, stroke: Stroke<Pixel.Model>, opacity: Double = 1) {
        self.draw(shape: Shape(ellipseIn: rect), stroke: stroke, opacity: opacity)
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(texture: Texture<Float32ColorPixel<Pixel.Model>>(image: image.convert(to: colorSpace, intent: renderingIntent), resamplingAlgorithm: resamplingAlgorithm), transform: transform)
    }
}
