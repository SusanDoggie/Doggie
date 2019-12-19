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
    
    var renderingIntent: RenderingIntent = .default
    
}

private struct GraphicState {
    
    var clip: PDFContext.Clip?
    
    var styles: PDFContextStyles
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm
    
    init(context: PDFContext.Page) {
        self.clip = context.state.clip
        self.styles = context.styles
        self.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
    
    func apply(to context: PDFContext.Page) {
        context.state.clip = self.clip
        context.styles = self.styles
        context.colorSpace.chromaticAdaptationAlgorithm = self.chromaticAdaptationAlgorithm
    }
}

struct PDFContextState {
    
    var is_clip: Bool = false
    
    var commands: String = ""
    fileprivate var currentStyle = PDFContext.CurrentStyle()
    
    fileprivate var imageTable: [PDFContext.ImageTableKey: String] = [:]
    
    fileprivate var extGState: [String: String] = [:]
    fileprivate var transparency_layers: [String: String] = [:]
    fileprivate var mask: [String: String] = [:]
    fileprivate var image: [String: (PDFContext.ImageStream, PDFContext.ImageStream?)] = [:]
    fileprivate var shading: [PDFContext.Shading: String] = [:]
    
    fileprivate var clip: PDFContext.Clip?
    
}

extension PDFContext {
    
    final class Page {
        
        let media: Rect
        let bleed: Rect
        let trim: Rect
        let margin: Rect
        
        var colorSpace: AnyColorSpace
        
        var state: PDFContextState = PDFContextState()
        fileprivate var styles: PDFContextStyles = PDFContextStyles()
        private var graphicStateStack: [GraphicState] = []
        
        private var next: Page?
        private weak var global: Page?
        
        init(media: Rect, bleed: Rect, trim: Rect, margin: Rect, colorSpace: AnyColorSpace) {
            self.media = media
            self.bleed = bleed
            self.trim = trim
            self.margin = margin
            self.colorSpace = colorSpace
        }
        
        func initialize() {
            
            if state.is_clip {
                self.state.commands += "/DeviceGray cs\n"
            } else {
                self.state.commands += "/Cs1 cs\n"
            }
            
            self.state.commands += "q\n"
        }
    }
    
    fileprivate enum Clip {
        case clip(Shape, Shape.WindingRule)
        case mask(String)
    }
    
    fileprivate struct CurrentStyle {
        
        var color: String? = nil
        var opacity: String? = nil
        var blend: String? = nil
    }
    
    struct ImageTableKey: Hashable {
        
        let image: AnyImage
        
        init(_ image: AnyImage) {
            self.image = image
        }
        
        static func ==(lhs: ImageTableKey, rhs: ImageTableKey) -> Bool {
            return lhs.image.isStorageEqual(rhs.image)
        }
    }
    
    struct ImageStream {
        
        var table: [String: String]
        var data: Data
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
        self.state.is_clip = context.state.is_clip
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
            context.state.commands += "\(color) sc\n"
        }
        if let opacity = self.opacity {
            context.state.commands += "/\(opacity) gs\n"
        }
        if let blend = self.blend {
            context.state.commands += "/\(blend) gs\n"
        }
    }
}

extension PDFContext.Page {
    
    var current_layer: PDFContext.Page {
        return next?.current_layer ?? self
    }
    
    private func _clone(global: PDFContext.Page?) -> PDFContext.Page {
        let clone = PDFContext.Page(media: media, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace)
        clone.state = self.state
        clone.styles = self.styles
        clone.graphicStateStack = self.graphicStateStack
        clone.next = self.next?._clone(global: global ?? clone)
        clone.global = global
        return clone
    }
    
    func clone() -> PDFContext.Page {
        return self._clone(global: nil)
    }
    
    func finalize() -> String {
        return state.commands + "Q"
    }
    
    var imageTable: [PDFContext.ImageTableKey: String] {
        get {
            return global?.imageTable ?? state.imageTable
        }
        set {
            if let global = self.global {
                global.state.imageTable = newValue
            } else {
                self.state.imageTable = newValue
            }
        }
    }
    
    var extGState: [String: String] {
        get {
            return global?.extGState ?? state.extGState
        }
        set {
            if let global = self.global {
                global.state.extGState = newValue
            } else {
                self.state.extGState = newValue
            }
        }
    }
    var transparency_layers: [String: String] {
        get {
            return global?.transparency_layers ?? state.transparency_layers
        }
        set {
            if let global = self.global {
                global.state.transparency_layers = newValue
            } else {
                self.state.transparency_layers = newValue
            }
        }
    }
    var mask: [String: String] {
        get {
            return global?.mask ?? state.mask
        }
        set {
            if let global = self.global {
                global.state.mask = newValue
            } else {
                self.state.mask = newValue
            }
        }
    }
    var image: [String: (PDFContext.ImageStream, PDFContext.ImageStream?)] {
        get {
            return global?.image ?? state.image
        }
        set {
            if let global = self.global {
                global.state.image = newValue
            } else {
                self.state.image = newValue
            }
        }
    }
    var shading: [PDFContext.Shading: String] {
        get {
            return global?.shading ?? state.shading
        }
        set {
            if let global = self.global {
                global.state.shading = newValue
            } else {
                self.state.shading = newValue
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
    
    var _mirrored_transform: SDTransform {
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
        
        current_layer.state.commands += "Q q\n"
        current_layer.state.currentStyle.apply(to: current_layer)
        
        if let clip = current_layer.state.clip {
            
            switch clip {
            case let .clip(shape, winding):
                self.encode_path(shape: shape, commands: &current_layer.state.commands)
                switch winding {
                case .nonZero: current_layer.state.commands += "W n\n"
                case .evenOdd: current_layer.state.commands += "W* n\n"
                }
            case let .mask(name): current_layer.state.commands += "/\(name) gs\n"
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
                
                let commands = next.finalize()
                if transparency_layers[commands] == nil {
                    transparency_layers[commands] = "Fm\(transparency_layers.count + 1)"
                }
                
                let _layer = transparency_layers[commands]!
                self.state.commands += "/\(_layer) Do\n"
            }
        }
    }
}

extension PDFContext.Page {
    
    private func encode_path(shape: Shape, commands: inout String) {
        
        for component in shape.identity {
            
            commands += "\(Decimal(component.start.x).rounded(scale: 9)) \(Decimal(component.start.y).rounded(scale: 9)) m\n"
            
            var current_point = component.start
            
            for segment in component {
                switch segment {
                case let .line(p1):
                    
                    commands += "\(Decimal(p1.x).rounded(scale: 9)) \(Decimal(p1.y).rounded(scale: 9)) l\n"
                    current_point = p1
                    
                case let .quad(p1, p2):
                    
                    let cubic = QuadBezier(current_point, p1, p2).elevated()
                    
                    if cubic.p1 == current_point {
                        commands += "\(Decimal(cubic.p2.x).rounded(scale: 9)) \(Decimal(cubic.p2.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(cubic.p3.x).rounded(scale: 9)) \(Decimal(cubic.p3.y).rounded(scale: 9)) v\n"
                    } else if cubic.p2 == current_point {
                        commands += "\(Decimal(cubic.p1.x).rounded(scale: 9)) \(Decimal(cubic.p1.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(cubic.p3.x).rounded(scale: 9)) \(Decimal(cubic.p3.y).rounded(scale: 9)) y\n"
                    } else {
                        commands += "\(Decimal(cubic.p1.x).rounded(scale: 9)) \(Decimal(cubic.p1.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(cubic.p2.x).rounded(scale: 9)) \(Decimal(cubic.p2.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(cubic.p3.x).rounded(scale: 9)) \(Decimal(cubic.p3.y).rounded(scale: 9)) c\n"
                    }
                    
                    current_point = p2
                    
                case let .cubic(p1, p2, p3):
                    
                    if p1 == current_point {
                        commands += "\(Decimal(p2.x).rounded(scale: 9)) \(Decimal(p2.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(p3.x).rounded(scale: 9)) \(Decimal(p3.y).rounded(scale: 9)) v\n"
                    } else if p2 == current_point {
                        commands += "\(Decimal(p1.x).rounded(scale: 9)) \(Decimal(p1.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(p3.x).rounded(scale: 9)) \(Decimal(p3.y).rounded(scale: 9)) y\n"
                    } else {
                        commands += "\(Decimal(p1.x).rounded(scale: 9)) \(Decimal(p1.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(p2.x).rounded(scale: 9)) \(Decimal(p2.y).rounded(scale: 9))\n"
                        commands += "\(Decimal(p3.x).rounded(scale: 9)) \(Decimal(p3.y).rounded(scale: 9)) c\n"
                    }
                    
                    current_point = p3
                }
            }
            
            if component.isClosed {
                commands += "h\n"
            }
        }
    }
    
    func set_opacity(_ opacity: Double) {
        
        let gstate = "/ca \(Decimal(opacity).rounded(scale: 9))"
        if extGState[gstate] == nil {
            extGState[gstate] = "Gs\(extGState.count + 1)"
        }
        
        let _opacity = extGState[gstate]!
        if current_layer.state.currentStyle.opacity != _opacity {
            current_layer.state.commands += "/\(_opacity) gs\n"
            current_layer.state.currentStyle.opacity = _opacity
        }
    }
    
    func set_blendmode() {
        
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
        if current_layer.state.currentStyle.blend != _blend {
            current_layer.state.commands += "/\(_blend) gs\n"
            current_layer.state.currentStyle.blend = _blend
        }
    }
    
    func draw<C : ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        guard shape.contains(where: { !$0.isEmpty }) else { return }
        
        let shape = shape * _mirrored_transform
        
        set_blendmode()
        set_opacity(color.opacity * self.opacity)
        
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        let _color = (0..<color.numberOfComponents - 1).lazy.map { "\(Decimal(color.component($0)).rounded(scale: 9))" }.joined(separator: " ")
        
        if current_layer.state.currentStyle.color != _color {
            current_layer.state.commands += "\(_color) sc\n"
            current_layer.state.currentStyle.color = _color
        }
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        switch winding {
        case .nonZero: current_layer.state.commands += "f\n"
        case .evenOdd: current_layer.state.commands += "f*\n"
        }
    }
}

extension PDFContext.Page {
    
    func draw<Image : ImageProtocol>(image: Image, transform: SDTransform, properties: [PDFContext.PropertyKey : Any]) {
        self._draw(image: image.convert(to: colorSpace, intent: renderingIntent), transform: transform, properties: properties)
    }
}

extension PDFContext.Page {
    
    func resetClip() {
        
        current_layer.state.commands += "Q q\n"
        current_layer.state.currentStyle.apply(to: current_layer)
        
        current_layer.state.clip = nil
    }
    
    func clip(shape: Shape, winding: Shape.WindingRule) {
        
        guard shape.reduce(0, { $0 + $1.count }) != 0 else {
            self.resetClip()
            return
        }
        
        let shape = shape * _mirrored_transform
        
        current_layer.state.commands += "Q q\n"
        current_layer.state.currentStyle.apply(to: current_layer)
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        switch winding {
        case .nonZero: current_layer.state.commands += "W n\n"
        case .evenOdd: current_layer.state.commands += "W* n\n"
        }
        
        current_layer.state.clip = .clip(shape, winding)
    }
}

extension PDFContext.Page {
    
    func drawClip(colorSpace: ColorSpace<GrayColorModel>, body: (PDFContext.Page) throws -> Void) rethrows {
        
        current_layer.state.commands += "Q q\n"
        current_layer.state.currentStyle.apply(to: current_layer)
        
        let mask = PDFContext.Page(copyStates: current_layer, colorSpace: AnyColorSpace(colorSpace))
        mask.global = global ?? self
        mask.state.is_clip = true
        mask.initialize()
        
        try body(mask)
        
        let name = "Mk\(self.mask.count + 1)"
        current_layer.mask[name] = mask.finalize()
        
        current_layer.state.commands += "/\(name) gs\n"
        
        current_layer.state.clip = .mask(name)
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
            "\(Decimal(transform.a).rounded(scale: 9))",
            "\(Decimal(transform.d).rounded(scale: 9))",
            "\(Decimal(transform.b).rounded(scale: 9))",
            "\(Decimal(transform.e).rounded(scale: 9))",
            "\(Decimal(transform.c).rounded(scale: 9))",
            "\(Decimal(transform.f).rounded(scale: 9))",
        ]
        
        current_layer.state.commands += "q\n"
        
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
            
            if let clip = current_layer.state.clip {
                
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
            
            current_layer.state.commands += "/\(name) gs\n"
        }
        
        set_blendmode()
        set_opacity(self.opacity)
        
        let shading = PDFContext.Shading(
            type: 2,
            deviceGray: state.is_clip,
            coords: [start.x, start.y, end.x, end.y],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if self.shading[shading] == nil {
            self.shading[shading] = "Sh\(self.shading.count + 1)"
        }
        
        current_layer.state.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = self.shading[shading]!
        current_layer.state.commands += "/\(_shading) sh\n"
        current_layer.state.commands += "Q\n"
    }
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { $0.1 }
        guard stops.count >= 2 else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            "\(Decimal(transform.a).rounded(scale: 9))",
            "\(Decimal(transform.d).rounded(scale: 9))",
            "\(Decimal(transform.b).rounded(scale: 9))",
            "\(Decimal(transform.e).rounded(scale: 9))",
            "\(Decimal(transform.c).rounded(scale: 9))",
            "\(Decimal(transform.f).rounded(scale: 9))",
        ]
        
        current_layer.state.commands += "q\n"
        
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
            
            if let clip = current_layer.state.clip {
                
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
            
            current_layer.state.commands += "/\(name) gs\n"
        }
        
        set_blendmode()
        set_opacity(self.opacity)
        
        let shading = PDFContext.Shading(
            type: 3,
            deviceGray: state.is_clip,
            coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if self.shading[shading] == nil {
            self.shading[shading] = "Sh\(self.shading.count + 1)"
        }
        
        current_layer.state.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = self.shading[shading]!
        current_layer.state.commands += "/\(_shading) sh\n"
        current_layer.state.commands += "Q\n"
    }
}

extension PDFContext.Page {
    
    func drawShading(_ shader: PDFContext.Function) {
        
        let transform = _mirrored_transform
        let _transform = [
            "\(Decimal(transform.a).rounded(scale: 9))",
            "\(Decimal(transform.d).rounded(scale: 9))",
            "\(Decimal(transform.b).rounded(scale: 9))",
            "\(Decimal(transform.e).rounded(scale: 9))",
            "\(Decimal(transform.c).rounded(scale: 9))",
            "\(Decimal(transform.f).rounded(scale: 9))",
        ]
        
        current_layer.state.commands += "q\n"
        
        set_blendmode()
        set_opacity(self.opacity)
        
        let shading = PDFContext.Shading(
            type: 1,
            deviceGray: state.is_clip,
            coords: [],
            function: shader,
            e0: false,
            e1: false
        )
        
        if self.shading[shading] == nil {
            self.shading[shading] = "Sh\(self.shading.count + 1)"
        }
        
        current_layer.state.commands += "\(_transform.joined(separator: " ")) cm\n"
        
        let _shading = self.shading[shading]!
        current_layer.state.commands += "/\(_shading) sh\n"
        current_layer.state.commands += "Q\n"
    }
}
