//
//  PDFContext.swift
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

private struct PDFContextStyles {
    
    static let defaultShadowColor = AnyColor(colorSpace: .default, white: 0.0, opacity: 1.0 / 3.0)
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shadowColor: AnyColor = PDFContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var compositingMode: ColorCompositingMode = .default
    var blendMode: ColorBlendMode = .default
    
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    
    var renderingIntent: RenderingIntent = .default
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default
    
}

private struct GraphicState {
    
    var clip: PDFContext.Clip?
    
    var styles: PDFContextStyles
    
    init(context: PDFContext.Page) {
        self.clip = context.clip
        self.styles = context.styles
    }
    
    func apply(to context: PDFContext.Page) {
        context.clip = self.clip
        context.styles = self.styles
    }
}

public class PDFContext : DrawableContext {
    
    var pages: [Page] = []
    
    private init(page: Page) {
        self.pages = [page]
    }
    
    public init(media: Rect, bleed: Rect? = nil, trim: Rect? = nil, margin: Rect? = nil, colorSpace: AnyColorSpace = AnyColorSpace(.sRGB)) {
        let bleed = bleed ?? media
        let trim = trim ?? bleed
        let margin = margin ?? trim
        let page = Page(media: media, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace)
        page.initialize()
        self.pages = [page]
    }
}

extension PDFContext {
    
    fileprivate enum Clip {
        case clip(String)
        case mask(String)
    }
    
    class Page {
        
        let media: Rect
        let bleed: Rect
        let trim: Rect
        let margin: Rect
        
        let colorSpace: AnyColorSpace
        
        var is_clip: Bool = false
        
        var commands: String = ""
        fileprivate var currentStyle = CurrentStyle()
        
        var _extGState: [String: String] = [:]
        var _transparency_layers: [String: String] = [:]
        var _mask: [String: String] = [:]
        var _shading: [PDFShading: String] = [:]
        
        fileprivate var clip: Clip?
        
        fileprivate var styles: PDFContextStyles = PDFContextStyles()
        
        fileprivate var next: Page?
        private weak var global: Page?
        
        fileprivate var graphicStateStack: [GraphicState] = []
        
        fileprivate init(media: Rect, bleed: Rect, trim: Rect, margin: Rect, colorSpace: AnyColorSpace) {
            self.media = media
            self.bleed = bleed
            self.trim = trim
            self.margin = margin
            self.colorSpace = colorSpace
        }
        
        fileprivate func initialize() {
            
            if is_clip {
                self.commands += "/DeviceGray cs\n"
            } else {
                self.commands += "/Cs1 cs\n"
            }
            
            self.commands += "q\n"
        }
    }
}

extension PDFContext.Page {
    
    private func _mirror(_ rect: Rect) -> Rect {
        let transform = SDTransform.reflectY(media.midY)
        let p0 = Point(x: rect.minX, y: rect.minY) * transform
        let p1 = Point(x: rect.maxX, y: rect.maxY) * transform
        return Rect.bound([p0, p1])
    }
    
    var _mirrored_bleed: Rect {
        return _mirror(bleed)
    }
    var _mirrored_trim: Rect {
        return _mirror(trim)
    }
    var _mirrored_margin: Rect {
        return _mirror(margin)
    }
}

extension PDFContext.Page {
    
    fileprivate convenience init(copyStates context: PDFContext.Page, colorSpace: AnyColorSpace) {
        self.init(media: context.media, bleed: context.bleed, trim: context.trim, margin: context.margin, colorSpace: colorSpace)
        self.is_clip = context.is_clip
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = PDFContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
    }
}

extension PDFContext {
    
    var current_page: Page {
        return pages.last!
    }
    
    public func nextPage(colorSpace: AnyColorSpace? = nil) {
        self.nextPage(media: current_page.media, bleed: current_page.bleed, trim: current_page.trim, margin: current_page.margin, colorSpace: colorSpace)
    }
    
    public func nextPage(media: Rect, bleed: Rect? = nil, trim: Rect? = nil, margin: Rect? = nil, colorSpace: AnyColorSpace? = nil) {
        precondition(!current_page.is_clip, "Multiple pages is not allowed for clip context.")
        let bleed = bleed ?? media
        let trim = trim ?? bleed
        let margin = margin ?? trim
        let page = Page(media: media, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace ?? current_page.colorSpace)
        page.initialize()
        self.pages.append(page)
    }
}

extension PDFContext.Page {
    
    fileprivate struct CurrentStyle {
        
        var color: String? = nil
        var opacity: String? = nil
    }
    
    fileprivate var current_layer: PDFContext.Page {
        return next?.current_layer ?? self
    }
    
    func finalize() -> String {
        return commands + "Q"
    }
    
    var extGState: [String: String] {
        get {
            return global?.extGState ?? _extGState
        }
        set {
            if let global = self.global {
                global._extGState = newValue
            } else {
                self._extGState = newValue
            }
        }
    }
    var transparency_layers: [String: String] {
        get {
            return global?.transparency_layers ?? _transparency_layers
        }
        set {
            if let global = self.global {
                global._transparency_layers = newValue
            } else {
                self._transparency_layers = newValue
            }
        }
    }
    var mask: [String: String] {
        get {
            return global?.mask ?? _mask
        }
        set {
            if let global = self.global {
                global._mask = newValue
            } else {
                self._mask = newValue
            }
        }
    }
    var shading: [PDFShading: String] {
        get {
            return global?.shading ?? _shading
        }
        set {
            if let global = self.global {
                global._shading = newValue
            } else {
                self._shading = newValue
            }
        }
    }
}

extension PDFContext.Page.CurrentStyle {
    
    func apply(to context: PDFContext.Page) {
        
        if let color = self.color {
            context.commands += "\(color) sc\n"
        }
        if let opacity = self.opacity {
            context.commands += "/\(opacity) gs\n"
        }
    }
}

extension PDFContext {
    
    public var media: Rect {
        return current_page.media
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
    
    public var colorSpace: AnyColorSpace {
        return current_page.colorSpace
    }
    
    public var opacity: Double {
        get {
            return current_page.current_layer.styles.opacity
        }
        set {
            current_page.current_layer.styles.opacity = newValue
        }
    }
    
    fileprivate var _mirrored_transform: SDTransform {
        return self.transform * .reflectY(media.midY)
    }
    
    public var transform: SDTransform {
        get {
            return current_page.current_layer.styles.transform
        }
        set {
            current_page.current_layer.styles.transform = newValue
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current_page.current_layer.styles.shadowColor
        }
        set {
            current_page.current_layer.styles.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current_page.current_layer.styles.shadowOffset
        }
        set {
            current_page.current_layer.styles.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current_page.current_layer.styles.shadowBlur
        }
        set {
            current_page.current_layer.styles.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current_page.current_layer.styles.compositingMode
        }
        set {
            current_page.current_layer.styles.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current_page.current_layer.styles.blendMode
        }
        set {
            current_page.current_layer.styles.blendMode = newValue
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current_page.current_layer.styles.resamplingAlgorithm
        }
        set {
            current_page.current_layer.styles.resamplingAlgorithm = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current_page.current_layer.styles.renderingIntent
        }
        set {
            current_page.current_layer.styles.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current_page.current_layer.styles.chromaticAdaptationAlgorithm
        }
        set {
            current_page.current_layer.styles.chromaticAdaptationAlgorithm = newValue
        }
    }
}

extension PDFContext {
    
    public func saveGraphicState() {
        current_page.graphicStateStack.append(GraphicState(context: current_page.current_layer))
    }
    
    public func restoreGraphicState() {
        current_page.graphicStateStack.popLast()?.apply(to: current_page.current_layer)
    }
}

extension PDFContext.Page {
    
    fileprivate func _beginTransparencyLayer() {
        if let next = self.next {
            next._beginTransparencyLayer()
        } else {
            self.next = PDFContext.Page(copyStates: self, colorSpace: colorSpace)
            self.next?.global = global ?? self
            self.next?.initialize()
        }
    }
    
    fileprivate func _endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next._endTransparencyLayer()
                
            } else {
                
                self.next = nil
                
                let name = "Fm\(self.transparency_layers.count + 1)"
                self.transparency_layers[name] = next.finalize()
                
                self.commands += "/\(name) Do\n"
            }
        }
    }
}

extension PDFContext {
    
    public func beginTransparencyLayer() {
        current_page._beginTransparencyLayer()
    }
    
    public func endTransparencyLayer() {
        current_page._endTransparencyLayer()
    }
}

extension PDFContext {
    
    private func encode_path(shape: Shape) {
        
        let context = current_page.current_layer
        
        let shape = shape * _mirrored_transform
        
        for component in shape.identity {
            
            context.commands += "\(_decimal_round(component.start.x)) \(_decimal_round(component.start.y)) m\n"
            
            var current_point = component.start
            
            for segment in component {
                switch segment {
                case let .line(p1):
                    
                    context.commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y)) l\n"
                    current_point = p1
                    
                case let .quad(p1, p2):
                    
                    let cubic = QuadBezier(current_point, p1, p2).elevated()
                    
                    if cubic.p1 == current_point {
                        context.commands += "\(_decimal_round(cubic.p2.x)) \(_decimal_round(cubic.p2.y))\n"
                        context.commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) v\n"
                    } else if cubic.p2 == current_point {
                        context.commands += "\(_decimal_round(cubic.p1.x)) \(_decimal_round(cubic.p1.y))\n"
                        context.commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) y\n"
                    } else {
                        context.commands += "\(_decimal_round(cubic.p1.x)) \(_decimal_round(cubic.p1.y))\n"
                        context.commands += "\(_decimal_round(cubic.p2.x)) \(_decimal_round(cubic.p2.y))\n"
                        context.commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) c\n"
                    }
                    
                    current_point = p2
                    
                case let .cubic(p1, p2, p3):
                    
                    if p1 == current_point {
                        context.commands += "\(_decimal_round(p2.x)) \(_decimal_round(p2.y))\n"
                        context.commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) v\n"
                    } else if p2 == current_point {
                        context.commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y))\n"
                        context.commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) y\n"
                    } else {
                        context.commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y))\n"
                        context.commands += "\(_decimal_round(p2.x)) \(_decimal_round(p2.y))\n"
                        context.commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) c\n"
                    }
                    
                    current_point = p3
                }
            }
            
            if component.isClosed {
                context.commands += "h\n"
            }
        }
    }
    
    private func set_opacity(_ opacity: Double) {
        
        let context = current_page.current_layer
        
        let gstate = "/ca \(_decimal_round(opacity))"
        if current_page.extGState[gstate] == nil {
            current_page.extGState[gstate] = "Gs\(current_page.extGState.count + 1)"
        }
        
        let _opacity = current_page.extGState[gstate]!
        if context.currentStyle.opacity != _opacity {
            context.commands += "/\(_opacity) gs\n"
            context.currentStyle.opacity = _opacity
        }
    }
    
    public func draw<C : ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        let context = current_page.current_layer
        
        set_opacity(color.opacity * self.opacity)
        
        let color = color.convert(to: current_page.colorSpace, intent: renderingIntent)
        let _color = (0..<color.numberOfComponents - 1).lazy.map { "\(_decimal_round(color.component($0)))" }.joined(separator: " ")
        
        if context.currentStyle.color != _color {
            context.commands += "\(_color) sc\n"
            context.currentStyle.color = _color
        }
        
        self.encode_path(shape: shape)
        switch winding {
        case .nonZero: context.commands += "f\n"
        case .evenOdd: context.commands += "f*\n"
        }
    }
}

extension PDFContext {
    
    public func draw<Image : ImageProtocol>(image: Image, transform: SDTransform) {
        
    }
}

extension PDFContext {
    
    public func resetClip() {
        
        let context = current_page.current_layer
        
        context.commands += "Q q\n"
        context.currentStyle.apply(to: context)
    }
    
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        
        let context = current_page.current_layer
        
        context.commands += "Q q\n"
        context.currentStyle.apply(to: context)
        
        self.encode_path(shape: shape)
        switch winding {
        case .nonZero: context.commands += "W n\n"
        case .evenOdd: context.commands += "W* n\n"
        }
    }
}

extension PDFContext.Page {
    
    fileprivate func _drawClip(colorSpace: ColorSpace<GrayColorModel>, body: (PDFContext.Page) throws -> Void) rethrows {
        
        if let next = self.next {
            try next._drawClip(colorSpace: colorSpace, body: body)
            return
        }
        
        self.commands += "Q q\n"
        self.currentStyle.apply(to: self)
        
        let mask = PDFContext.Page(copyStates: self, colorSpace: AnyColorSpace(colorSpace))
        mask.global = global ?? self
        mask.is_clip = true
        mask.initialize()
        
        try body(mask)
        
        let name = "Mk\(self.mask.count + 1)"
        self.mask[name] = mask.finalize()
        
        self.commands += "/\(name) gs\n"
    }
}

extension PDFContext {
    
    public func drawClip(body: (PDFContext) throws -> Void) rethrows {
        try self.drawClip(colorSpace: .genericGamma22Gray, body: body)
    }
    
    public func drawClip(colorSpace: ColorSpace<GrayColorModel>, body: (PDFContext) throws -> Void) rethrows {
        try current_page._drawClip(colorSpace: colorSpace) { try body(PDFContext(page: $0)) }
    }
}

extension PDFContext {
    
    public func setClip<Image>(image: Image, transform: SDTransform) where Image : ImageProtocol {
        self.drawClip { context in context.draw(image: image, transform: transform) }
    }
    
    public func setClip<P>(texture: Texture<P>, transform: SDTransform) where P : ColorPixelProtocol, P.Model == GrayColorModel {
        let image = Image(texture: texture, colorSpace: .genericGamma22Gray)
        self.setClip(image: image, transform: transform)
    }
}

extension PDFContext {
    
    private func create_function<C>(stops: [GradientStop<C>]) -> PDFFunction? {
        
        guard stops.count >= 2 else { return nil }
        
        let colorSpace = current_page.colorSpace
        var stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { $0.1.convert(to: colorSpace, intent: renderingIntent) }
        
        if let stop = stops.first, stop.offset > 0 {
            stops.insert(GradientStop(offset: 0, color: stop.color), at: 0)
        }
        if let stop = stops.last, stop.offset < 1 {
            stops.append(GradientStop(offset: 1, color: stop.color))
        }
        
        var functions: [PDFFunction] = []
        var bounds: [Double] = []
        var encode: [Double] = []
        
        for (lhs, rhs) in zip(stops, stops.dropFirst()) {
            
            let c0 = (0..<colorSpace.numberOfComponents).map { lhs.color.component($0) }
            let c1 = (0..<colorSpace.numberOfComponents).map { rhs.color.component($0) }
            
            functions.append(PDFFunction(c0: c0, c1: c1))
            bounds.append(rhs.offset)
            encode.append(0)
            encode.append(1)
        }
        
        return PDFFunction(functions: functions, bounds: Array(bounds.dropLast()), encode: encode)
    }
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        guard let function = create_function(stops: stops) else { return }
        
        let shading = PDFShading(
            type: 2,
            coords: [start.x, start.y, end.x, end.y],
            function: function,
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        let context = current_page.current_layer
        
        if context.shading[shading] == nil {
            context.shading[shading] = "Sh\(context.shading.count + 1)"
        }
        
        context.commands += "q\n"
        
        let transform = _mirrored_transform
        let _transform = [
            "\(_decimal_round(transform.a))",
            "\(_decimal_round(transform.b))",
            "\(_decimal_round(transform.d))",
            "\(_decimal_round(transform.e))",
            "\(_decimal_round(transform.c))",
            "\(_decimal_round(transform.f))",
        ]
        context.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = context.shading[shading]!
        context.commands += "/\(_shading) sh\n"
        context.commands += "Q\n"
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        
        guard let function = create_function(stops: stops) else { return }
        
        let shading = PDFShading(
            type: 3,
            coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
            function: function,
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        let context = current_page.current_layer
        
        if context.shading[shading] == nil {
            context.shading[shading] = "Sh\(context.shading.count + 1)"
        }
        
        context.commands += "q\n"
        
        let transform = _mirrored_transform
        let _transform = [
            "\(_decimal_round(transform.a))",
            "\(_decimal_round(transform.b))",
            "\(_decimal_round(transform.d))",
            "\(_decimal_round(transform.e))",
            "\(_decimal_round(transform.c))",
            "\(_decimal_round(transform.f))",
        ]
        context.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = context.shading[shading]!
        context.commands += "/\(_shading) sh\n"
        context.commands += "Q\n"
    }
}
