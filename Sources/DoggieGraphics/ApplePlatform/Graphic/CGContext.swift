//
//  CGContext.swift
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

#if canImport(CoreGraphics)

extension CGContext {
    
    open func addPath(_ shape: Shape) {
        self.addPath(shape.cgPath)
    }
    
    open func draw<C>(_ image: Image<C>, in rect: CGRect, byTiling: Bool = false) {
        guard let cgImage = image.cgImage else { return }
        self.draw(cgImage, in: rect, byTiling: byTiling)
    }
    
    open func draw(_ image: AnyImage, in rect: CGRect, byTiling: Bool = false) {
        guard let cgImage = image.cgImage else { return }
        self.draw(cgImage, in: rect, byTiling: byTiling)
    }
    
    open func setFillColor<M>(_ color: Color<M>) {
        guard let cgColor = color.cgColor else { return }
        self.setFillColor(cgColor)
    }
    
    open func setFillColor(_ color: AnyColor) {
        guard let cgColor = color.cgColor else { return }
        self.setFillColor(cgColor)
    }
    
    open func setFillColorSpace<M>(_ colorSpace: ColorSpace<M>) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setFillColorSpace(cgColorSpace)
    }
    
    open func setFillColorSpace(_ colorSpace: AnyColorSpace) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setFillColorSpace(cgColorSpace)
    }
    
    open func setStrokeColor<M>(_ color: Color<M>) {
        guard let cgColor = color.cgColor else { return }
        self.setStrokeColor(cgColor)
    }
    
    open func setStrokeColor(_ color: AnyColor) {
        guard let cgColor = color.cgColor else { return }
        self.setStrokeColor(cgColor)
    }
    
    open func setStrokeColorSpace<M>(_ colorSpace: ColorSpace<M>) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setStrokeColorSpace(cgColorSpace)
    }
    
    open func setStrokeColorSpace(_ colorSpace: AnyColorSpace) {
        guard let cgColorSpace = colorSpace.cgColorSpace else { return }
        self.setStrokeColorSpace(cgColorSpace)
    }
    
    open func beginTransparencyLayer() {
        self.beginTransparencyLayer(auxiliaryInfo: nil)
    }
    
    open func concatenate(_ transform: SDTransform) {
        self.concatenate(CGAffineTransform(transform))
    }
    
    open func clipToDrawing(colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray(), body: (CGContext) throws -> Void) rethrows {
        
        let width = self.width
        let height = self.height
        let transform = self.ctm
        
        guard let maskContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: 0) else { return }
        
        maskContext.setFillColor(gray: 0, alpha: 1)
        maskContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
        maskContext.concatenate(transform)
        
        try body(maskContext)
        
        guard let alphaMask = maskContext.makeImage()?.copy(colorSpace: CGColorSpaceCreateDeviceGray()) else { return }
        
        self.concatenate(transform.inverted())
        self.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: alphaMask)
        self.concatenate(transform)
    }
    
    open func draw<C>(shape: Shape, winding: Shape.WindingRule, colorSpace: AnyColorSpace, gradient: Gradient<C>) {
        
        let boundary = shape.originalBoundary
        guard !boundary.isEmpty else { return }
        
        let transform = gradient.transform * SDTransform.scale(x: boundary.width, y: boundary.height) * SDTransform.translate(x: boundary.minX, y: boundary.minY) * shape.transform
        
        self.beginTransparencyLayer()
        
        self.addPath(shape)
        switch winding {
        case .nonZero: self.clip(using: .winding)
        case .evenOdd: self.clip(using: .evenOdd)
        }
        
        self.concatenate(transform)
        
        var options: CGGradientDrawingOptions = []
        if gradient.startSpread == .pad { options.insert(.drawsBeforeStartLocation) }
        if gradient.endSpread == .pad { options.insert(.drawsAfterEndLocation) }
        
        switch gradient.type {
        case .linear: self.drawLinearGradient(colorSpace: colorSpace, stops: gradient.stops, start: gradient.start, end: gradient.end, options: options)
        case .radial: self.drawRadialGradient(colorSpace: colorSpace, stops: gradient.stops, start: gradient.start, startRadius: 0, end: gradient.end, endRadius: 0.5, options: options)
        }
        
        self.endTransparencyLayer()
    }
    
    open func stroke(shape: Shape, width: Double, cap: Shape.LineCap, join: Shape.LineJoin, colorSpace: AnyColorSpace, gradient: Gradient<AnyColor>) {
        self.draw(shape: shape.strokePath(width: width, cap: cap, join: join), winding: .nonZero, colorSpace: colorSpace, gradient: gradient)
    }
}

protocol CGGradientConvertibleProtocol {
    
    func gradient<C>(stops: [GradientStop<C>]) -> CGGradient?
    
    func shading_function<C>(colorSpace: CGColorSpace, stops: [GradientStop<C>]) -> ((CGFloat, UnsafeMutableBufferPointer<CGFloat>) -> Void)?
}

extension ColorSpace: CGGradientConvertibleProtocol {
    
    func gradient<C>(stops: [GradientStop<C>]) -> CGGradient? {
        switch self {
        case is ColorSpace<GrayColorModel>: return CGGradientCreate(colorSpace: self, stops: stops)
        case is ColorSpace<RGBColorModel>: return CGGradientCreate(colorSpace: self, stops: stops)
        case is ColorSpace<CMYKColorModel>: return CGGradientCreate(colorSpace: self, stops: stops)
        default: return nil
        }
    }
    
    func shading_function<C>(colorSpace: CGColorSpace, stops: [GradientStop<C>]) -> ((CGFloat, UnsafeMutableBufferPointer<CGFloat>) -> Void)? {
        
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { (Float($0.1.offset), Float32ColorPixel($0.1.color.convert(to: self, intent: .default))) }
        
        let interpolate: (Float) -> Color<Model>
        
        if stops.count == 1 {
            
            let color = stops[0].1
            interpolate = { _ in Color(colorSpace: self, color: color) }
            
        } else {
            
            let first = stops.first!
            let last = stops.last!
            
            interpolate = { t in
                
                if t <= first.0 {
                    return Color(colorSpace: self, color: first.1)
                }
                if t >= last.0 {
                    return Color(colorSpace: self, color: last.1)
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.0 != rhs.0 && t >= lhs.0 && t <= rhs.0 {
                    
                    let s = (t - lhs.0) / (rhs.0 - lhs.0)
                    return Color(colorSpace: self, color: lhs.1 * (1 - s) + rhs.1 * s)
                }
                
                return Color(colorSpace: self, color: first.1)
            }
        }
        
        if let colorSpace = AnyColorSpace(cgColorSpace: colorSpace) {
            
            let numberOfComponents = colorSpace.numberOfComponents
            
            return { t, color in
                
                let c = interpolate(Float(t)).convert(to: colorSpace)
                
                for i in 0...numberOfComponents {
                    color[i] = CGFloat(c.component(i))
                }
            }
        }
        
        if interpolate(0).cgColor != nil {
            
            let numberOfComponents = colorSpace.numberOfComponents
            
            return { t, color in
                
                guard let c = interpolate(Float(t)).cgColor else { return }
                guard let components = c.converted(to: colorSpace, intent: .defaultIntent, options: nil)?.components else { return }
                
                for i in 0...numberOfComponents {
                    color[i] = components[i]
                }
            }
        }
        
        return nil
    }
}

extension CGContext {
    
    open func drawLinearGradient<C>(colorSpace: AnyColorSpace, stops: [GradientStop<C>], start: Point, end: Point, options: CGGradientDrawingOptions) {
        
        guard let _colorSpace = colorSpace.base as? CGGradientConvertibleProtocol else { return }
        guard !stops.isEmpty else { return }
        
        if let gradient = _colorSpace.gradient(stops: stops) {
            
            self.drawLinearGradient(gradient, start: CGPoint(start), end: CGPoint(end), options: options)
            
            return
        }
        
        let cgColorSpace: CGColorSpace
        
        switch colorSpace.base {
        case is ColorSpace<GrayColorModel>: cgColorSpace = CGColorSpaceCreateDeviceGray()
        case is ColorSpace<RGBColorModel>: cgColorSpace = CGColorSpaceCreateDeviceRGB()
        case is ColorSpace<CMYKColorModel>: cgColorSpace = CGColorSpaceCreateDeviceCMYK()
        default: cgColorSpace = CGColorSpaceCreateDeviceRGB()
        }
        
        guard let function = _colorSpace.shading_function(colorSpace: cgColorSpace, stops: stops) else { return }
        
        self.drawLinearGradient(colorSpace: cgColorSpace, start: CGPoint(start), end: CGPoint(end), options: options, callbacks: function)
    }
    
    open func drawRadialGradient<C>(colorSpace: AnyColorSpace, stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, options: CGGradientDrawingOptions) {
        
        guard let _colorSpace = colorSpace.base as? CGGradientConvertibleProtocol else { return }
        guard !stops.isEmpty else { return }
        
        if let gradient = _colorSpace.gradient(stops: stops) {
            
            self.drawRadialGradient(gradient, startCenter: CGPoint(start), startRadius: CGFloat(startRadius), endCenter: CGPoint(end), endRadius: CGFloat(endRadius), options: options)
            
            return
        }
        
        let cgColorSpace: CGColorSpace
        
        switch colorSpace.base {
        case is ColorSpace<GrayColorModel>: cgColorSpace = CGColorSpaceCreateDeviceGray()
        case is ColorSpace<RGBColorModel>: cgColorSpace = CGColorSpaceCreateDeviceRGB()
        case is ColorSpace<CMYKColorModel>: cgColorSpace = CGColorSpaceCreateDeviceCMYK()
        default: cgColorSpace = CGColorSpaceCreateDeviceRGB()
        }
        
        guard let function = _colorSpace.shading_function(colorSpace: cgColorSpace, stops: stops) else { return }
        
        self.drawRadialGradient(colorSpace: cgColorSpace, start: CGPoint(start), startRadius: CGFloat(startRadius), end: CGPoint(end), endRadius: CGFloat(endRadius), options: options, callbacks: function)
    }
}

#endif

