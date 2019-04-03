//
//  PDFContextPage.swift
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
    
}

private struct GraphicState {
    
    var clip: PDFContext.Clip?
    
    var styles: PDFContextStyles
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    init(context: PDFContext.Page) {
        self.clip = context.clip
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
    
    func apply(to context: PDFContext.Page) {
        context.clip = self.clip
        context.styles = self.styles
        context.colorSpace.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

extension PDFContext {
    
    fileprivate enum Clip {
        case clip(Shape, Shape.WindingRule)
        case mask(String)
    }
    
    fileprivate struct CurrentStyle {
        
        var color: String? = nil
        var opacity: String? = nil
        var blend: String? = nil
    }
    
    class Page {
        
        let media: Rect
        let bleed: Rect
        let trim: Rect
        let margin: Rect
        
        var colorSpace: AnyColorSpace
        
        var is_clip: Bool = false
        
        var commands: String = ""
        private var currentStyle = CurrentStyle()
        
        var _extGState: [String: String] = [:]
        var _transparency_layers: [String: String] = [:]
        var _mask: [String: String] = [:]
        var _shading: [PDFContext.Shading: String] = [:]
        
        fileprivate var clip: Clip?
        
        fileprivate var styles: PDFContextStyles = PDFContextStyles()
        
        private var next: Page?
        private weak var global: Page?
        
        private var graphicStateStack: [GraphicState] = []
        
        init(media: Rect, bleed: Rect, trim: Rect, margin: Rect, colorSpace: AnyColorSpace) {
            self.media = media
            self.bleed = bleed
            self.trim = trim
            self.margin = margin
            self.colorSpace = colorSpace
        }
        
        func initialize() {
            
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
    
    private convenience init(copyStates context: PDFContext.Page, colorSpace: AnyColorSpace) {
        self.init(media: context.media, bleed: context.bleed, trim: context.trim, margin: context.margin, colorSpace: colorSpace)
        self.is_clip = context.is_clip
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = PDFContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
        self.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension PDFContext.CurrentStyle {
    
    func apply(to context: PDFContext.Page) {
        
        if let color = self.color {
            context.commands += "\(color) sc\n"
        }
        if let opacity = self.opacity {
            context.commands += "/\(opacity) gs\n"
        }
        if let blend = self.blend {
            context.commands += "/\(blend) gs\n"
        }
    }
}

extension PDFContext.Page {
    
    private var current_layer: PDFContext.Page {
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
    var shading: [PDFContext.Shading: String] {
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

extension PDFContext.Page {
    
    var opacity: Double {
        get {
            return current_layer.styles.opacity
        }
        set {
            current_layer.styles.opacity = newValue
        }
    }
    
    private var _mirrored_transform: SDTransform {
        return self.transform * .reflectY(media.midY)
    }
    
    var transform: SDTransform {
        get {
            return current_layer.styles.transform
        }
        set {
            current_layer.styles.transform = newValue
        }
    }
    
    var shadowColor: AnyColor {
        get {
            return current_layer.styles.shadowColor
        }
        set {
            current_layer.styles.shadowColor = newValue
        }
    }
    
    var shadowOffset: Size {
        get {
            return current_layer.styles.shadowOffset
        }
        set {
            current_layer.styles.shadowOffset = newValue
        }
    }
    
    var shadowBlur: Double {
        get {
            return current_layer.styles.shadowBlur
        }
        set {
            current_layer.styles.shadowBlur = newValue
        }
    }
    
    var compositingMode: ColorCompositingMode {
        get {
            return current_layer.styles.compositingMode
        }
        set {
            current_layer.styles.compositingMode = newValue
        }
    }
    
    var blendMode: ColorBlendMode {
        get {
            return current_layer.styles.blendMode
        }
        set {
            current_layer.styles.blendMode = newValue
        }
    }
    
    var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current_layer.styles.resamplingAlgorithm
        }
        set {
            current_layer.styles.resamplingAlgorithm = newValue
        }
    }
    
    var renderingIntent: RenderingIntent {
        get {
            return current_layer.styles.renderingIntent
        }
        set {
            current_layer.styles.renderingIntent = newValue
        }
    }
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current_layer.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            current_layer.colorSpace.chromaticAdaptationAlgorithm = newValue
        }
    }
}

extension PDFContext.Page {
    
    func saveGraphicState() {
        graphicStateStack.append(GraphicState(context: current_layer))
    }
    
    func restoreGraphicState() {
        
        graphicStateStack.popLast()?.apply(to: current_layer)
        
        current_layer.commands += "Q q\n"
        current_layer.currentStyle.apply(to: current_layer)
        
        if let clip = current_layer.clip {
            
            switch clip {
            case let .clip(shape, winding):
                self.encode_path(shape: shape, commands: &current_layer.commands)
                switch winding {
                case .nonZero: current_layer.commands += "W n\n"
                case .evenOdd: current_layer.commands += "W* n\n"
                }
            case let .mask(name): current_layer.commands += "/\(name) gs\n"
            }
        }
    }
}

extension PDFContext.Page {
    
    func beginTransparencyLayer() {
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            self.next = PDFContext.Page(copyStates: self, colorSpace: colorSpace)
            self.next?.global = global ?? self
            self.next?.initialize()
        }
    }
    
    func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                self.next = nil
                
                let name = "Fm\(self.transparency_layers.count + 1)"
                self.transparency_layers[name] = next.finalize()
                
                self.commands += "/\(name) Do\n"
            }
        }
    }
}

extension PDFContext.Page {
    
    private func encode_path(shape: Shape, commands: inout String) {
        
        for component in shape.identity {
            
            commands += "\(_decimal_round(component.start.x)) \(_decimal_round(component.start.y)) m\n"
            
            var current_point = component.start
            
            for segment in component {
                switch segment {
                case let .line(p1):
                    
                    commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y)) l\n"
                    current_point = p1
                    
                case let .quad(p1, p2):
                    
                    let cubic = QuadBezier(current_point, p1, p2).elevated()
                    
                    if cubic.p1 == current_point {
                        commands += "\(_decimal_round(cubic.p2.x)) \(_decimal_round(cubic.p2.y))\n"
                        commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) v\n"
                    } else if cubic.p2 == current_point {
                        commands += "\(_decimal_round(cubic.p1.x)) \(_decimal_round(cubic.p1.y))\n"
                        commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) y\n"
                    } else {
                        commands += "\(_decimal_round(cubic.p1.x)) \(_decimal_round(cubic.p1.y))\n"
                        commands += "\(_decimal_round(cubic.p2.x)) \(_decimal_round(cubic.p2.y))\n"
                        commands += "\(_decimal_round(cubic.p3.x)) \(_decimal_round(cubic.p3.y)) c\n"
                    }
                    
                    current_point = p2
                    
                case let .cubic(p1, p2, p3):
                    
                    if p1 == current_point {
                        commands += "\(_decimal_round(p2.x)) \(_decimal_round(p2.y))\n"
                        commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) v\n"
                    } else if p2 == current_point {
                        commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y))\n"
                        commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) y\n"
                    } else {
                        commands += "\(_decimal_round(p1.x)) \(_decimal_round(p1.y))\n"
                        commands += "\(_decimal_round(p2.x)) \(_decimal_round(p2.y))\n"
                        commands += "\(_decimal_round(p3.x)) \(_decimal_round(p3.y)) c\n"
                    }
                    
                    current_point = p3
                }
            }
            
            if component.isClosed {
                commands += "h\n"
            }
        }
    }
    
    private func set_opacity(_ opacity: Double) {
        
        let gstate = "/ca \(_decimal_round(opacity))"
        if extGState[gstate] == nil {
            extGState[gstate] = "Gs\(extGState.count + 1)"
        }
        
        let _opacity = extGState[gstate]!
        if current_layer.currentStyle.opacity != _opacity {
            current_layer.commands += "/\(_opacity) gs\n"
            current_layer.currentStyle.opacity = _opacity
        }
    }
    
    private func set_blendmode() {
        
        let _mode: String
        
        switch self.blendMode {
        case .normal: _mode = "/Normal"
        case .multiply: _mode = "/Multiply"
        case .screen: _mode = "/Screen"
        case .overlay: _mode = "/Overlay"
        case .darken: _mode = "/Darken"
        case .lighten: _mode = "/Lighten"
        case .colorDodge: _mode = "/ColorDodge"
        case .colorBurn: _mode = "/ColorBurn"
        case .softLight: _mode = "/SoftLight"
        case .hardLight: _mode = "/HardLight"
        case .difference: _mode = "/Difference"
        case .exclusion: _mode = "/Exclusion"
        default: _mode = "/Normal"
        }
        
        let gstate = "/BM \(_mode)"
        if extGState[gstate] == nil {
            extGState[gstate] = "Gs\(extGState.count + 1)"
        }
        
        let _blend = extGState[gstate]!
        if current_layer.currentStyle.blend != _blend {
            current_layer.commands += "/\(_blend) gs\n"
            current_layer.currentStyle.blend = _blend
        }
    }
    
    func draw<C : ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let shape = shape * _mirrored_transform
        
        set_blendmode()
        set_opacity(color.opacity * self.opacity)
        
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        let _color = (0..<color.numberOfComponents - 1).lazy.map { "\(_decimal_round(color.component($0)))" }.joined(separator: " ")
        
        if current_layer.currentStyle.color != _color {
            current_layer.commands += "\(_color) sc\n"
            current_layer.currentStyle.color = _color
        }
        
        self.encode_path(shape: shape, commands: &current_layer.commands)
        switch winding {
        case .nonZero: current_layer.commands += "f\n"
        case .evenOdd: current_layer.commands += "f*\n"
        }
    }
}

extension PDFContext.Page {
    
    func draw<Image : ImageProtocol>(image: Image, transform: SDTransform) {
        
    }
}

extension PDFContext.Page {
    
    func resetClip() {
        
        current_layer.commands += "Q q\n"
        current_layer.currentStyle.apply(to: current_layer)
        
        current_layer.clip = nil
    }
    
    func clip(shape: Shape, winding: Shape.WindingRule) {
        
        guard shape.reduce(0, { $0 + $1.count }) != 0 else {
            self.resetClip()
            return
        }
        
        let shape = shape * _mirrored_transform
        
        current_layer.commands += "Q q\n"
        current_layer.currentStyle.apply(to: current_layer)
        
        self.encode_path(shape: shape, commands: &current_layer.commands)
        switch winding {
        case .nonZero: current_layer.commands += "W n\n"
        case .evenOdd: current_layer.commands += "W* n\n"
        }
        
        current_layer.clip = .clip(shape, winding)
    }
}

extension PDFContext.Page {
    
    func drawClip(colorSpace: ColorSpace<GrayColorModel>, body: (PDFContext.Page) throws -> Void) rethrows {
        
        current_layer.commands += "Q q\n"
        current_layer.currentStyle.apply(to: current_layer)
        
        let mask = PDFContext.Page(copyStates: current_layer, colorSpace: AnyColorSpace(colorSpace))
        mask.global = global ?? self
        mask.is_clip = true
        mask.initialize()
        
        try body(mask)
        
        let name = "Mk\(self.mask.count + 1)"
        current_layer.mask[name] = mask.finalize()
        
        current_layer.commands += "/\(name) gs\n"
        
        current_layer.clip = .mask(name)
    }
}

extension PDFContext.Page {
    
    private func create_gradient_function<C>(stops: [GradientStop<C>]) -> PDFContext.Function {
        
        var stops = stops.map { $0.convert(to: colorSpace, intent: renderingIntent) }
        
        if let stop = stops.first, stop.offset > 0 {
            stops.insert(GradientStop(offset: 0, color: stop.color), at: 0)
        }
        if let stop = stops.last, stop.offset < 1 {
            stops.append(GradientStop(offset: 1, color: stop.color))
        }
        
        var functions: [PDFContext.Function] = []
        var bounds: [Double] = []
        var encode: [Double] = []
        
        for (lhs, rhs) in zip(stops, stops.dropFirst()) {
            
            let c0 = (0..<colorSpace.numberOfComponents).map { lhs.color.component($0) }
            let c1 = (0..<colorSpace.numberOfComponents).map { rhs.color.component($0) }
            
            functions.append(PDFContext.Function(c0: c0, c1: c1))
            bounds.append(rhs.offset)
            encode.append(0)
            encode.append(1)
        }
        
        return PDFContext.Function(functions: functions, bounds: Array(bounds.dropLast()), encode: encode)
    }
    
    private func create_gradient_opacity_function<C>(stops: [GradientStop<C>]) -> PDFContext.Function {
        
        var stops = stops
        
        if let stop = stops.first, stop.offset > 0 {
            stops.insert(GradientStop(offset: 0, color: stop.color), at: 0)
        }
        if let stop = stops.last, stop.offset < 1 {
            stops.append(GradientStop(offset: 1, color: stop.color))
        }
        
        var functions: [PDFContext.Function] = []
        var bounds: [Double] = []
        var encode: [Double] = []
        
        for (lhs, rhs) in zip(stops, stops.dropFirst()) {
            functions.append(PDFContext.Function(c0: [lhs.color.opacity], c1: [rhs.color.opacity]))
            bounds.append(rhs.offset)
            encode.append(0)
            encode.append(1)
        }
        
        return PDFContext.Function(functions: functions, bounds: Array(bounds.dropLast()), encode: encode)
    }
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { $0.1 }
        guard stops.count >= 2 else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            "\(_decimal_round(transform.a))",
            "\(_decimal_round(transform.d))",
            "\(_decimal_round(transform.b))",
            "\(_decimal_round(transform.e))",
            "\(_decimal_round(transform.c))",
            "\(_decimal_round(transform.f))",
        ]
        
        current_layer.commands += "q\n"
        
        if stops.contains(where: { !$0.color.isOpaque }) {
            
            let shading = PDFContext.Shading(
                type: 2,
                deviceGray: true,
                coords: [start.x, start.y, end.x, end.y],
                function: create_gradient_opacity_function(stops: stops),
                e0: startSpread == .pad,
                e1: endSpread == .pad
            )
            
            if self.shading[shading] == nil {
                self.shading[shading] = "Sh\(self.shading.count + 1)"
            }
            
            var mask_commands = "/DeviceGray cs\n"
            
            if let clip = current_layer.clip {
                
                switch clip {
                case let .clip(shape, winding):
                    self.encode_path(shape: shape, commands: &mask_commands)
                    switch winding {
                    case .nonZero: mask_commands += "W n\n"
                    case .evenOdd: mask_commands += "W* n\n"
                    }
                case let .mask(name): mask_commands += "/\(name) gs\n"
                }
            }
            
            mask_commands += "\(_transform.joined(separator: " ")) cm\n"
            
            let _shading = self.shading[shading]!
            mask_commands += "/\(_shading) sh\n"
            
            let name = "Mk\(mask.count + 1)"
            mask[name] = mask_commands
            
            current_layer.commands += "/\(name) gs\n"
        }
        
        set_blendmode()
        set_opacity(self.opacity)
        
        let shading = PDFContext.Shading(
            type: 2,
            deviceGray: is_clip,
            coords: [start.x, start.y, end.x, end.y],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if self.shading[shading] == nil {
            self.shading[shading] = "Sh\(self.shading.count + 1)"
        }
        
        current_layer.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = self.shading[shading]!
        current_layer.commands += "/\(_shading) sh\n"
        current_layer.commands += "Q\n"
    }
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { $0.1 }
        guard stops.count >= 2 else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            "\(_decimal_round(transform.a))",
            "\(_decimal_round(transform.d))",
            "\(_decimal_round(transform.b))",
            "\(_decimal_round(transform.e))",
            "\(_decimal_round(transform.c))",
            "\(_decimal_round(transform.f))",
        ]
        
        current_layer.commands += "q\n"
        
        if stops.contains(where: { !$0.color.isOpaque }) {
            
            let shading = PDFContext.Shading(
                type: 3,
                deviceGray: true,
                coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
                function: create_gradient_opacity_function(stops: stops),
                e0: startSpread == .pad,
                e1: endSpread == .pad
            )
            
            if self.shading[shading] == nil {
                self.shading[shading] = "Sh\(self.shading.count + 1)"
            }
            
            var mask_commands = "/DeviceGray cs\n"
            
            if let clip = current_layer.clip {
                
                switch clip {
                case let .clip(shape, winding):
                    self.encode_path(shape: shape, commands: &mask_commands)
                    switch winding {
                    case .nonZero: mask_commands += "W n\n"
                    case .evenOdd: mask_commands += "W* n\n"
                    }
                case let .mask(name): mask_commands += "/\(name) gs\n"
                }
            }
            
            mask_commands += "\(_transform.joined(separator: " ")) cm\n"
            
            let _shading = self.shading[shading]!
            mask_commands += "/\(_shading) sh\n"
            
            let name = "Mk\(mask.count + 1)"
            mask[name] = mask_commands
            
            current_layer.commands += "/\(name) gs\n"
        }
        
        set_blendmode()
        set_opacity(self.opacity)
        
        let shading = PDFContext.Shading(
            type: 3,
            deviceGray: is_clip,
            coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if self.shading[shading] == nil {
            self.shading[shading] = "Sh\(self.shading.count + 1)"
        }
        
        current_layer.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = self.shading[shading]!
        current_layer.commands += "/\(_shading) sh\n"
        current_layer.commands += "Q\n"
    }
}
