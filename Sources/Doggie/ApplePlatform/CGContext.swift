//
//  CGContext.swift
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

#if canImport(CoreGraphics)

extension CGContext {
    
    public func addPath(_ shape: Shape) {
        self.addPath(shape.cgPath)
    }
    
    public func draw<C>(_ image: Image<C>, in rect: CGRect, byTiling: Bool = false) {
        guard let cgImage = image.cgImage else { return }
        self.draw(cgImage, in: rect, byTiling: byTiling)
    }
    
    public func draw(_ image: AnyImage, in rect: CGRect, byTiling: Bool = false) {
        guard let cgImage = image.cgImage else { return }
        self.draw(cgImage, in: rect, byTiling: byTiling)
    }
    
    public func setFillColor<M>(_ color: Color<M>) {
        guard let cgColor = color.cgColor else { return }
        self.setFillColor(cgColor)
    }
    
    public func setFillColor(_ color: AnyColor) {
        guard let cgColor = color.cgColor else { return }
        self.setFillColor(cgColor)
    }
    
    public func setFillColorSpace<M>(_ colorSpace: ColorSpace<M>) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setFillColorSpace(cgColorSpace)
    }
    
    public func setFillColorSpace(_ colorSpace: AnyColorSpace) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setFillColorSpace(cgColorSpace)
    }
    
    public func setStrokeColor<M>(_ color: Color<M>) {
        guard let cgColor = color.cgColor else { return }
        self.setStrokeColor(cgColor)
    }
    
    public func setStrokeColor(_ color: AnyColor) {
        guard let cgColor = color.cgColor else { return }
        self.setStrokeColor(cgColor)
    }
    
    public func setStrokeColorSpace<M>(_ colorSpace: ColorSpace<M>) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setStrokeColorSpace(cgColorSpace)
    }
    
    public func setStrokeColorSpace(_ colorSpace: AnyColorSpace) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setStrokeColorSpace(cgColorSpace)
    }
    
    public func beginTransparencyLayer() {
        self.beginTransparencyLayer(auxiliaryInfo: nil)
    }
    
    public func concatenate(_ transform: SDTransform) {
        self.concatenate(CGAffineTransform(transform))
    }
    
    public func drawClip(colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray(), body: (CGContext) throws -> Void) rethrows {
        try CGContextClipToDrawing(self, colorSpace: colorSpace, command: body)
    }
    
    public func draw(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<AnyColor>, colorSpace: AnyColorSpace) {
        
        self.beginTransparencyLayer()
        
        self.addPath(shape)
        switch winding {
        case .nonZero: self.clip(using: .winding)
        case .evenOdd: self.clip(using: .evenOdd)
        }
        
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
    
    public func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, gradient: Gradient<AnyColor>, colorSpace: AnyColorSpace) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, gradient: gradient, colorSpace: colorSpace)
    }
    
    public func drawLinearGradient(colorSpace: AnyColorSpace, stops: [GradientStop<AnyColor>], start: Point, end: Point, options: CGGradientDrawingOptions) {
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        let stops = stops.map { GradientStop(offset: $0.offset, color: $0.color.convert(to: colorSpace)) }
        
        let range = 0...colorSpace.numberOfComponents
        guard let gradient = CGGradient(colorSpace: cgColorSpace, colorComponents: stops.flatMap { stop in range.lazy.map { CGFloat(stop.color.component($0)) } }, locations: stops.map { CGFloat($0.offset) }, count: stops.count) else { return }
        
        self.drawLinearGradient(gradient, start: CGPoint(start), end: CGPoint(end), options: options)
    }
    
    public func drawRadialGradient(colorSpace: AnyColorSpace, stops: [GradientStop<AnyColor>], start: Point, startRadius: Double, end: Point, endRadius: Double, options: CGGradientDrawingOptions) {
        
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        let stops = stops.map { GradientStop(offset: $0.offset, color: $0.color.convert(to: colorSpace)) }
        
        let range = 0...colorSpace.numberOfComponents
        guard let gradient = CGGradient(colorSpace: cgColorSpace, colorComponents: stops.flatMap { stop in range.lazy.map { CGFloat(stop.color.component($0)) } }, locations: stops.map { CGFloat($0.offset) }, count: stops.count) else { return }
        
        self.drawRadialGradient(gradient, startCenter: CGPoint(start), startRadius: CGFloat(startRadius), endCenter: CGPoint(end), endRadius: CGFloat(endRadius), options: options)
    }
}

fileprivate final class CGPatternCallbackContainer {
    
    static var CGPatternCallbackList = [UInt: CGPatternCallbackContainer]()
    
    let callback: (CGContext) -> Void
    
    let callbacks_struct: UnsafeMutablePointer<CGPatternCallbacks>
    
    init(callback: @escaping (CGContext) -> Void) {
        
        self.callback = callback
        self.callbacks_struct = UnsafeMutablePointer.allocate(capacity: 1)
        
        let id = UInt(bitPattern: ObjectIdentifier(self))
        CGPatternCallbackContainer.CGPatternCallbackList[id] = self
        
        self.callbacks_struct.initialize(to: CGPatternCallbacks(version: 0, drawPattern: {
            let id = unsafeBitCast($0, to: UInt.self)
            CGPatternCallbackContainer.CGPatternCallbackList[id]?.callback($1)
        }, releaseInfo: {
            let id = unsafeBitCast($0, to: UInt.self)
            CGPatternCallbackContainer.CGPatternCallbackList[id] = nil
        }))
    }
    
    deinit {
        self.callbacks_struct.deinitialize(count: 1)
        self.callbacks_struct.deallocate()
    }
}

public func CGPatternCreate(_ bounds: CGRect, _ matrix: CGAffineTransform, _ xStep: CGFloat, _ yStep: CGFloat, _ tiling: CGPatternTiling, _ isColored: Bool, _ callback: @escaping (CGContext) -> Void) -> CGPattern? {
    let callbackContainer = CGPatternCallbackContainer(callback: callback)
    let id = UInt(bitPattern: ObjectIdentifier(callbackContainer))
    return CGPattern(info: UnsafeMutableRawPointer(bitPattern: id), bounds: bounds, matrix: matrix, xStep: xStep, yStep: yStep, tiling: tiling, isColored: isColored, callbacks: callbackContainer.callbacks_struct)
}

public func CGContextClipToDrawing(_ context : CGContext, colorSpace space: CGColorSpace = CGColorSpaceCreateDeviceGray(), command: (CGContext) throws -> Void) rethrows {
    
    let width = context.width
    let height = context.height
    let transform = context.ctm
    
    guard let maskContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: space, bitmapInfo: 0) else { return }
    
    maskContext.setFillColor(gray: 0, alpha: 1)
    maskContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
    maskContext.concatenate(transform)
    
    try command(maskContext)
    
    guard let alphaMask = maskContext.makeImage()?.copy(colorSpace: CGColorSpaceCreateDeviceGray()) else { return }
    
    context.concatenate(transform.inverted())
    context.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: alphaMask)
    context.concatenate(transform)
}

#endif

