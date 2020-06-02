//
//  PDFContext.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public class PDFContext: DrawableContext {
    
    var pages: [Page] = []
    
    private init(pages: [Page]) {
        self.pages = pages
    }
    
    public init(media: Rect, crop: Rect? = nil, bleed: Rect? = nil, trim: Rect? = nil, margin: Rect? = nil, colorSpace: AnyColorSpace = AnyColorSpace.sRGB) {
        let crop = crop ?? media
        let bleed = bleed ?? crop
        let trim = trim ?? bleed
        let margin = margin ?? trim
        let page = Page(media: media, crop: crop, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace)
        page.initialize()
        self.pages = [page]
    }
}

extension PDFContext {
    
    public convenience init<Model>(media: Rect, crop: Rect? = nil, bleed: Rect? = nil, trim: Rect? = nil, margin: Rect? = nil, colorSpace: ColorSpace<Model>) {
        self.init(media: media, crop: crop, bleed: bleed, trim: trim, margin: margin, colorSpace: AnyColorSpace(colorSpace))
    }
    
    public convenience init(width: Double, height: Double, unit: Resolution.Unit = .point, colorSpace: AnyColorSpace = AnyColorSpace.sRGB) {
        let _width = unit.convert(length: width, to: .point)
        let _height = unit.convert(length: height, to: .point)
        self.init(media: Rect(x: 0, y: 0, width: _width, height: _height), colorSpace: colorSpace)
    }
    
    public convenience init<Model>(width: Double, height: Double, unit: Resolution.Unit = .point, colorSpace: ColorSpace<Model>) {
        let _width = unit.convert(length: width, to: .point)
        let _height = unit.convert(length: height, to: .point)
        self.init(media: Rect(x: 0, y: 0, width: _width, height: _height), colorSpace: AnyColorSpace(colorSpace))
    }
}

extension PDFContext {
    
    var current_page: Page {
        return pages.last!
    }
    
    public func clone() -> PDFContext {
        return PDFContext(pages: pages.map { $0.clone() })
    }
    
    public func nextPage(colorSpace: AnyColorSpace? = nil) {
        self.nextPage(media: current_page.media, crop: current_page.crop, bleed: current_page.bleed, trim: current_page.trim, margin: current_page.margin, colorSpace: colorSpace)
    }
    
    public func nextPage(width: Double, height: Double, unit: Resolution.Unit = .point, colorSpace: AnyColorSpace? = nil) {
        let _width = unit.convert(length: width, to: .point)
        let _height = unit.convert(length: height, to: .point)
        self.nextPage(media: Rect(x: 0, y: 0, width: _width, height: _height), colorSpace: colorSpace)
    }
    
    public func nextPage(media: Rect, crop: Rect? = nil, bleed: Rect? = nil, trim: Rect? = nil, margin: Rect? = nil, colorSpace: AnyColorSpace? = nil) {
        precondition(!current_page.state.is_clip, "Multiple pages is not allowed for clip context.")
        let crop = crop ?? media
        let bleed = bleed ?? crop
        let trim = trim ?? bleed
        let margin = margin ?? trim
        let page = Page(media: media, crop: crop, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace ?? current_page.colorSpace)
        page.initialize()
        self.pages.append(page)
    }
}

extension PDFContext {
    
    public var media: Rect {
        return current_page.media
    }
    public var crop: Rect {
        return current_page.crop
    }
    public var bleed: Rect {
        return current_page.bleed
    }
    public var trim: Rect {
        return current_page.trim
    }
    public var margin: Rect {
        return current_page.margin
    }
}

extension PDFContext {
    
    public var isRasterContext: Bool {
        return false
    }
    
    public var colorSpace: AnyColorSpace {
        return current_page.colorSpace
    }
    
    public var opacity: Double {
        get {
            return current_page.opacity
        }
        set {
            current_page.opacity = newValue
        }
    }
    
    public var transform: SDTransform {
        get {
            return current_page.transform
        }
        set {
            current_page.transform = newValue
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current_page.shadowColor
        }
        set {
            current_page.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current_page.shadowOffset
        }
        set {
            current_page.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current_page.shadowBlur
        }
        set {
            current_page.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current_page.compositingMode
        }
        set {
            current_page.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current_page.blendMode
        }
        set {
            current_page.blendMode = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current_page.renderingIntent
        }
        set {
            current_page.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current_page.chromaticAdaptationAlgorithm
        }
        set {
            current_page.chromaticAdaptationAlgorithm = newValue
        }
    }
}

extension PDFContext {
    
    public func saveGraphicState() {
        current_page.saveGraphicState()
    }
    
    public func restoreGraphicState() {
        current_page.restoreGraphicState()
    }
}

extension PDFContext {
    
    public func beginTransparencyLayer() {
        current_page.beginTransparencyLayer()
    }
    
    public func endTransparencyLayer() {
        current_page.endTransparencyLayer()
    }
}

extension PDFContext {
    
    public func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        current_page.draw(shape: shape, winding: winding, color: color)
    }
}

extension PDFContext {
    
    public enum PropertyKey: CaseIterable {
        
        case compression
        
        case predictor
        
        case deflateLevel
    }
    
    public enum CompressionScheme: CaseIterable {
        
        case none
        
        case runLength
        
        case lzw
        
        case deflate
    }
    
    public enum CompressionPrediction: CaseIterable {
        
        case none
        
        case tiff
        
        case png
    }
    
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform, properties: [PropertyKey: Any]) {
        current_page.draw(image: image, transform: transform, properties: properties)
    }
    
    public func draw<Image: ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(image: image, transform: transform, properties: [:])
    }
}

extension PDFContext {
    
    public func resetClip() {
        current_page.resetClip()
    }
    
    public func clip(shape: Shape, winding: Shape.WindingRule) {
        current_page.clip(shape: shape, winding: winding)
    }
}

extension PDFContext {
    
    public func clipToDrawing(body: (DrawableContext) throws -> Void) rethrows {
        try self.clipToDrawing { (context: PDFContext) in try body(context) }
    }
    
    public func clipToDrawing(colorSpace: ColorSpace<GrayColorModel> = .genericGamma22Gray, body: (PDFContext) throws -> Void) rethrows {
        try current_page.clipToDrawing(colorSpace: colorSpace) { try body(PDFContext(pages: [$0])) }
    }
}

extension PDFContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        current_page.drawLinearGradient(stops: stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        current_page.drawRadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
    }
}

extension PDFContext {
    
    public func drawGradient<C>(_ mesh: MeshGradient<C>) {
        current_page.drawGradient(mesh)
    }
}

extension PDFContext {
    
    public func drawShading(_ shader: PDFFunction) {
        current_page.drawShading(shader)
    }
}
