//
//  PDFContextPage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
    
    var commands: [PDFCommand] = []
    fileprivate var currentStyle = PDFContext.CurrentStyle()
    
    fileprivate var resources = PDFContext.PDFResources()
    
    fileprivate var clip: PDFContext.Clip?
    
}

extension PDFContext {
    
    final class Page {
        
        let media: Rect
        let crop: Rect
        let bleed: Rect
        let trim: Rect
        let margin: Rect
        
        var colorSpace: AnyColorSpace
        
        var state: PDFContextState = PDFContextState()
        fileprivate var styles: PDFContextStyles = PDFContextStyles()
        private var graphicStateStack: [GraphicState] = []
        
        private var next: Page?
        private weak var global: Page?
        
        init(media: Rect, crop: Rect, bleed: Rect, trim: Rect, margin: Rect, colorSpace: AnyColorSpace) {
            
            precondition(!media.isNull, "media is null.")
            precondition(!media.isInfinite, "media is infinite.")
            precondition(!crop.isNull, "crop is null.")
            precondition(!crop.isInfinite, "crop is infinite.")
            precondition(!bleed.isNull, "bleed is null.")
            precondition(!bleed.isInfinite, "bleed is infinite.")
            precondition(!trim.isNull, "trim is null.")
            precondition(!trim.isInfinite, "trim is infinite.")
            precondition(!margin.isNull, "margin is null.")
            precondition(!margin.isInfinite, "margin is infinite.")
            
            self.media = media
            self.crop = crop
            self.bleed = bleed
            self.trim = trim
            self.margin = margin
            self.colorSpace = colorSpace
        }
        
        func initialize() {
            
            if state.is_clip {
                self.state.commands.append(.name("DeviceGray"))
                self.state.commands.append(.command("cs"))
                self.state.commands.append(.name("DeviceGray"))
                self.state.commands.append(.command("CS"))
            } else {
                self.state.commands.append(.name("Cs1"))
                self.state.commands.append(.command("cs"))
                self.state.commands.append(.name("Cs1"))
                self.state.commands.append(.command("CS"))
            }
            
            self.state.commands.append(.command("q"))
        }
    }
    
    fileprivate enum Clip {
        case clip(Shape, Shape.WindingRule)
        case mask(PDFName)
    }
    
    fileprivate struct CurrentStyle {
        
        var color: [PDFCommand]? = nil
        var stroke: [PDFCommand]? = nil
        
        var strokeWidth: PDFName? = nil
        var strokeCap: PDFName? = nil
        var strokeJoin: PDFName? = nil
        var miterLimit: PDFName? = nil
        
        var opacity: PDFName? = nil
        var strokeOpacity: PDFName? = nil
        
        var blend: PDFName? = nil
    }
    
    struct PDFResources {
        
        var imageTable: [PDFContext.ImageTableKey: PDFName] = [:]
        
        var extGState: [PDFObject: PDFName] = [:]
        var transparency_layers: [[PDFCommand]: PDFName] = [:]
        var mask: [PDFName: [PDFCommand]] = [:]
        var image: [PDFName: (PDFStream, PDFStream?)] = [:]
        var shading: [AnyHashable: PDFName] = [:]
        var pattern: [PDFName: PDFContext.PDFPattern] = [:]
        
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
    
    struct PDFShading: Hashable {
        
        var type: Int
        
        var deviceGray: Bool
        
        var coords: [Double]
        var function: PDFFunction
        var e0: Bool
        var e1: Bool
    }
    
    struct PDFMeshCoordData: Hashable {
        
        var flag: Int
        var coord: [Point]
    }
    
    struct PDFMeshShading: Hashable {
        
        var type: Int
        
        var deviceGray: Bool
        
        var numberOfComponents: Int
        
        var coord: [PDFMeshCoordData]
        var color: [[[Double]]]
    }
    
    struct PDFPattern {
        
        var type: Int
        var paintType: Int
        
        var tilingType: Int
        
        var bound: Rect
        var xStep: Double
        var yStep: Double
        
        var transform: SDTransform
        
        var resources: PDFResources
        
        var commands: [PDFCommand]
    }
}

extension PDFContext.Page {
    
    private func _mirror(_ rect: Rect) -> Rect {
        let transform = SDTransform.reflectY(media.midY)
        let p0 = Point(x: rect.minX, y: rect.minY) * transform
        let p1 = Point(x: rect.maxX, y: rect.maxY) * transform
        return Rect.bound([p0, p1])
    }
    
    var _mirrored_crop: Rect {
        return _mirror(crop)
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
        self.init(media: context.media, crop: context.crop, bleed: context.bleed, trim: context.trim, margin: context.margin, colorSpace: colorSpace)
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
            context.state.commands.append(contentsOf: color)
            context.state.commands.append(.command("sc"))
        }
        if let stroke = self.stroke {
            context.state.commands.append(contentsOf: stroke)
            context.state.commands.append(.command("SC"))
        }
        if let strokeWidth = self.strokeWidth {
            context.state.commands.append(.name(strokeWidth))
            context.state.commands.append(.command("gs"))
        }
        if let strokeCap = self.strokeCap {
            context.state.commands.append(.name(strokeCap))
            context.state.commands.append(.command("gs"))
        }
        if let strokeJoin = self.strokeJoin {
            context.state.commands.append(.name(strokeJoin))
            context.state.commands.append(.command("gs"))
        }
        if let miterLimit = self.miterLimit {
            context.state.commands.append(.name(miterLimit))
            context.state.commands.append(.command("gs"))
        }
        if let opacity = self.opacity {
            context.state.commands.append(.name(opacity))
            context.state.commands.append(.command("gs"))
        }
        if let strokeOpacity = self.strokeOpacity {
            context.state.commands.append(.name(strokeOpacity))
            context.state.commands.append(.command("gs"))
        }
        if let blend = self.blend {
            context.state.commands.append(.name(blend))
            context.state.commands.append(.command("gs"))
        }
    }
}

extension PDFContext.Page {
    
    var current_layer: PDFContext.Page {
        return next?.current_layer ?? self
    }
    
    private func _clone(global: PDFContext.Page?) -> PDFContext.Page {
        let clone = PDFContext.Page(media: media, crop: crop, bleed: bleed, trim: trim, margin: margin, colorSpace: colorSpace)
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
    
    func finalize() -> [PDFCommand] {
        return state.commands + [.command("Q")]
    }
    
    var resources: PDFContext.PDFResources {
        get {
            return global?.resources ?? state.resources
        }
        set {
            if let global = self.global {
                global.state.resources = newValue
            } else {
                self.state.resources = newValue
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
        
        current_layer.state.commands.append(.command("Q"))
        current_layer.state.commands.append(.command("q"))
        current_layer.state.currentStyle.apply(to: current_layer)
        
        switch current_layer.state.clip {
            
        case let .clip(shape, winding):
            
            self.encode_path(shape: shape, commands: &current_layer.state.commands)
            
            switch winding {
            case .nonZero: current_layer.state.commands.append(.command("W"))
            case .evenOdd: current_layer.state.commands.append(.command("W*"))
            }
            
            current_layer.state.commands.append(.command("n"))
            
        case let .mask(name):
            
            current_layer.state.commands.append(.name(name))
            current_layer.state.commands.append(.command("gs"))
            
        default: break
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
                
                set_blendmode()
                set_opacity(self.opacity)
                
                let commands = next.finalize()
                if resources.transparency_layers[commands] == nil {
                    resources.transparency_layers[commands] = PDFName("Fm\(resources.transparency_layers.count + 1)")
                }
                
                self.state.commands.append(.name(resources.transparency_layers[commands]!))
                self.state.commands.append(.command("Do"))
            }
        }
    }
}

extension PDFContext.Page {
    
    private func encode_path(shape: Shape, commands: inout [PDFCommand]) {
        
        for component in shape.identity {
            
            commands.append(PDFCommand(component.start.x))
            commands.append(PDFCommand(component.start.y))
            commands.append(.command("m"))
            
            var current_point = component.start
            
            for segment in component {
                switch segment {
                case let .line(p1):
                    
                    commands.append(PDFCommand(p1.x))
                    commands.append(PDFCommand(p1.y))
                    commands.append(.command("l"))
                    current_point = p1
                    
                case let .quad(p1, p2):
                    
                    let cubic = QuadBezier(current_point, p1, p2).elevated()
                    
                    if cubic.p1 == current_point {
                        commands.append(PDFCommand(cubic.p2.x))
                        commands.append(PDFCommand(cubic.p2.y))
                        commands.append(PDFCommand(cubic.p3.x))
                        commands.append(PDFCommand(cubic.p3.y))
                        commands.append(.command("v"))
                    } else if cubic.p2 == current_point {
                        commands.append(PDFCommand(cubic.p1.x))
                        commands.append(PDFCommand(cubic.p1.y))
                        commands.append(PDFCommand(cubic.p3.x))
                        commands.append(PDFCommand(cubic.p3.y))
                        commands.append(.command("y"))
                    } else {
                        commands.append(PDFCommand(cubic.p1.x))
                        commands.append(PDFCommand(cubic.p1.y))
                        commands.append(PDFCommand(cubic.p2.x))
                        commands.append(PDFCommand(cubic.p2.y))
                        commands.append(PDFCommand(cubic.p3.x))
                        commands.append(PDFCommand(cubic.p3.y))
                        commands.append(.command("c"))
                    }
                    
                    current_point = p2
                    
                case let .cubic(p1, p2, p3):
                    
                    if p1 == current_point {
                        commands.append(PDFCommand(p2.x))
                        commands.append(PDFCommand(p2.y))
                        commands.append(PDFCommand(p3.x))
                        commands.append(PDFCommand(p3.y))
                        commands.append(.command("v"))
                    } else if p2 == current_point {
                        commands.append(PDFCommand(p1.x))
                        commands.append(PDFCommand(p1.y))
                        commands.append(PDFCommand(p3.x))
                        commands.append(PDFCommand(p3.y))
                        commands.append(.command("y"))
                    } else {
                        commands.append(PDFCommand(p1.x))
                        commands.append(PDFCommand(p1.y))
                        commands.append(PDFCommand(p2.x))
                        commands.append(PDFCommand(p2.y))
                        commands.append(PDFCommand(p3.x))
                        commands.append(PDFCommand(p3.y))
                        commands.append(.command("c"))
                    }
                    
                    current_point = p3
                }
            }
            
            if component.isClosed {
                commands.append(.command("h"))
            }
        }
    }
    
    func set_opacity(_ opacity: Double) {
        
        let gstate: PDFObject = ["ca": PDFObject(opacity)]
        if resources.extGState[gstate] == nil {
            resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
        }
        
        let _opacity = resources.extGState[gstate]!
        if current_layer.state.currentStyle.opacity != _opacity {
            current_layer.state.commands.append(.name(_opacity))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.opacity = _opacity
        }
    }
    
    func set_stroke_opacity(_ opacity: Double) {
        
        let gstate: PDFObject = ["CA": PDFObject(opacity)]
        if resources.extGState[gstate] == nil {
            resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
        }
        
        let _opacity = resources.extGState[gstate]!
        if current_layer.state.currentStyle.strokeOpacity != _opacity {
            current_layer.state.commands.append(.name(_opacity))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.strokeOpacity = _opacity
        }
    }
    
    func set_blendmode() {
        
        let _mode: PDFName
        
        switch self.blendMode {
        case .normal: _mode = "Normal"
        case .multiply: _mode = "Multiply"
        case .screen: _mode = "Screen"
        case .overlay: _mode = "Overlay"
        case .darken: _mode = "Darken"
        case .lighten: _mode = "Lighten"
        case .colorDodge: _mode = "ColorDodge"
        case .colorBurn: _mode = "ColorBurn"
        case .softLight: _mode = "SoftLight"
        case .hardLight: _mode = "HardLight"
        case .difference: _mode = "Difference"
        case .exclusion: _mode = "Exclusion"
        default: _mode = "Normal"
        }
        
        let gstate: PDFObject = ["BM": PDFObject(_mode)]
        if resources.extGState[gstate] == nil {
            resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
        }
        
        let _blend = resources.extGState[gstate]!
        if current_layer.state.currentStyle.blend != _blend {
            current_layer.state.commands.append(.name(_blend))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.blend = _blend
        }
    }
    
    func set_stroke_state<C>(_ stroke: Stroke<C>) {
        
        let _cap: Int
        let _join: Int
        var _limit: Double = 4
        
        switch stroke.cap {
        case .butt: _cap = 0
        case .round: _cap = 1
        case .square: _cap = 2
        }
        switch stroke.join {
        case let .miter(limit):
            _join = 0
            _limit = limit
        case .round: _join = 1
        case .bevel: _join = 2
        }
        
        let _strokeWidth: PDFName = {
            let gstate: PDFObject = ["LW": PDFObject(stroke.width)]
            if resources.extGState[gstate] == nil {
                resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
            }
            return resources.extGState[gstate]!
        }()
        let _strokeCap: PDFName = {
            let gstate: PDFObject = ["LC": PDFObject(_cap)]
            if resources.extGState[gstate] == nil {
                resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
            }
            return resources.extGState[gstate]!
        }()
        let _strokeJoin: PDFName = {
            let gstate: PDFObject = ["LJ": PDFObject(_join)]
            if resources.extGState[gstate] == nil {
                resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
            }
            return resources.extGState[gstate]!
        }()
        let _miterLimit: PDFName = {
            let gstate: PDFObject = ["ML": PDFObject(_limit)]
            if resources.extGState[gstate] == nil {
                resources.extGState[gstate] = PDFName("Gs\(resources.extGState.count + 1)")
            }
            return resources.extGState[gstate]!
        }()
        
        if current_layer.state.currentStyle.strokeWidth != _strokeWidth {
            current_layer.state.commands.append(.name(_strokeWidth))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.strokeWidth = _strokeWidth
        }
        if current_layer.state.currentStyle.strokeCap != _strokeCap {
            current_layer.state.commands.append(.name(_strokeCap))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.strokeCap = _strokeCap
        }
        if current_layer.state.currentStyle.strokeJoin != _strokeJoin {
            current_layer.state.commands.append(.name(_strokeJoin))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.strokeJoin = _strokeJoin
        }
        if current_layer.state.currentStyle.miterLimit != _miterLimit {
            current_layer.state.commands.append(.name(_miterLimit))
            current_layer.state.commands.append(.command("gs"))
            current_layer.state.currentStyle.miterLimit = _miterLimit
        }
    }
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        guard self.transform.invertible else { return }
        
        let shape = shape * _mirrored_transform
        
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        set_blendmode()
        set_opacity(color.opacity * self.opacity)
        
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        let _color = (0..<color.numberOfComponents - 1).map { PDFCommand(color.component($0)) }
        
        if current_layer.state.currentStyle.color != _color {
            current_layer.state.commands.append(contentsOf: _color)
            current_layer.state.commands.append(.command("sc"))
            current_layer.state.currentStyle.color = _color
        }
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        switch winding {
        case .nonZero: current_layer.state.commands.append(.command("f"))
        case .evenOdd: current_layer.state.commands.append(.command("f*"))
        }
    }
    
    func draw<C: ColorProtocol>(shape: Shape, stroke: Stroke<C>) {
        
        guard self.transform.invertible else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        set_blendmode()
        set_stroke_opacity(stroke.color.opacity * self.opacity)
        
        let color = stroke.color.convert(to: colorSpace, intent: renderingIntent)
        let _color = (0..<color.numberOfComponents - 1).map { PDFCommand(color.component($0)) }
        
        if current_layer.state.currentStyle.stroke != _color {
            current_layer.state.commands.append(contentsOf: _color)
            current_layer.state.commands.append(.command("SC"))
            current_layer.state.currentStyle.stroke = _color
        }
        
        set_stroke_state(stroke)
        
        current_layer.state.commands.append(.command("q"))
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        current_layer.state.commands.append(.command("S"))
        
        current_layer.state.commands.append(.command("Q"))
    }
}

extension PDFContext.Page {
    
    func draw<Image: ImageProtocol>(image: Image, transform: SDTransform, properties: [PDFContext.PropertyKey : Any]) {
        self._draw(image: image.convert(to: colorSpace, intent: renderingIntent), transform: transform, properties: properties)
    }
}

extension PDFContext.Page {
    
    func resetClip() {
        
        current_layer.state.commands.append(.command("Q"))
        current_layer.state.commands.append(.command("q"))
        current_layer.state.currentStyle.apply(to: current_layer)
        
        current_layer.state.clip = nil
    }
    
    func clip(shape: Shape, winding: Shape.WindingRule) {
        
        guard shape.contains(where: { !$0.isEmpty }) else {
            self.resetClip()
            return
        }
        
        let shape = shape * _mirrored_transform
        
        current_layer.state.commands.append(.command("Q"))
        current_layer.state.commands.append(.command("q"))
        current_layer.state.currentStyle.apply(to: current_layer)
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        
        switch winding {
        case .nonZero: current_layer.state.commands.append(.command("W"))
        case .evenOdd: current_layer.state.commands.append(.command("W*"))
        }
        current_layer.state.commands.append(.command("n"))
        
        current_layer.state.clip = .clip(shape, winding)
    }
}

extension PDFContext.Page {
    
    func clipToDrawing(colorSpace: ColorSpace<GrayColorModel>, body: (PDFContext.Page) throws -> Void) rethrows {
        
        current_layer.state.commands.append(.command("Q"))
        current_layer.state.commands.append(.command("q"))
        current_layer.state.currentStyle.apply(to: current_layer)
        
        let mask = PDFContext.Page(copyStates: current_layer, colorSpace: AnyColorSpace(colorSpace))
        mask.global = global ?? self
        mask.state.is_clip = true
        mask.initialize()
        
        try body(mask)
        
        let name = PDFName("Mk\(resources.mask.count + 1)")
        resources.mask[name] = mask.finalize()
        
        current_layer.state.commands.append(.name(name))
        current_layer.state.commands.append(.command("gs"))
        
        current_layer.state.clip = .mask(name)
    }
}

extension PDFContext.Page {
    
    private func create_gradient_function<C>(stops: [GradientStop<C>]) -> PDFFunction {
        
        var stops = stops.map { $0.convert(to: colorSpace, intent: renderingIntent) }
        
        if let stop = stops.first, stop.offset > 0 {
            stops.insert(GradientStop(offset: 0, color: stop.color), at: 0)
        }
        if let stop = stops.last, stop.offset < 1 {
            stops.append(GradientStop(offset: 1, color: stop.color))
        }
        
        var functions: [PDFFunction] = []
        var bounds: [Double] = []
        var encode: [PDFFunction.Encode] = []
        
        for (lhs, rhs) in zip(stops, stops.dropFirst()) {
            
            let c0 = (0..<colorSpace.numberOfComponents).map { lhs.color.component($0) }
            let c1 = (0..<colorSpace.numberOfComponents).map { rhs.color.component($0) }
            
            functions.append(PDFFunction(c0: c0, c1: c1))
            bounds.append(rhs.offset)
            encode.append(PDFFunction.Encode(0, 1))
        }
        
        return PDFFunction(functions: functions, bounds: Array(bounds.dropLast()), encode: encode)
    }
    
    private func create_gradient_opacity_function<C>(stops: [GradientStop<C>]) -> PDFFunction {
        
        var stops = stops
        
        if let stop = stops.first, stop.offset > 0 {
            stops.insert(GradientStop(offset: 0, color: stop.color), at: 0)
        }
        if let stop = stops.last, stop.offset < 1 {
            stops.append(GradientStop(offset: 1, color: stop.color))
        }
        
        var functions: [PDFFunction] = []
        var bounds: [Double] = []
        var encode: [PDFFunction.Encode] = []
        
        for (lhs, rhs) in zip(stops, stops.dropFirst()) {
            functions.append(PDFFunction(c0: [lhs.color.opacity], c1: [rhs.color.opacity]))
            bounds.append(rhs.offset)
            encode.append(PDFFunction.Encode(0, 1))
        }
        
        return PDFFunction(functions: functions, bounds: Array(bounds.dropLast()), encode: encode)
    }
    
    private func _draw_gradient(_ color: AnyHashable, _ mask: AnyHashable?) {
        
        let transform = _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        set_blendmode()
        set_opacity(self.opacity)
        
        current_layer.state.commands.append(.command("q"))
        
        if let mask = mask {
            
            if resources.shading[mask] == nil {
                resources.shading[mask] = PDFName("Sh\(resources.shading.count + 1)")
            }
            
            var mask_commands: [PDFCommand] = [.name("DeviceGray"), .command("cs")]
            
            switch current_layer.state.clip {
                
            case let .clip(shape, winding):
                
                self.encode_path(shape: shape, commands: &mask_commands)
                
                switch winding {
                case .nonZero: mask_commands.append(.command("W"))
                case .evenOdd: mask_commands.append(.command("W*"))
                }
                
                mask_commands.append(.command("n"))
                
            case let .mask(name):
                
                mask_commands.append(.name(name))
                mask_commands.append(.command("gs"))
                
            default: break
            }
            
            mask_commands.append(contentsOf: _transform.map { PDFCommand($0) })
            mask_commands.append(.command("cm"))
            
            mask_commands.append(.name(resources.shading[mask]!))
            mask_commands.append(.command("sh"))
            
            let name = PDFName("Mk\(resources.mask.count + 1)")
            resources.mask[name] = mask_commands
            
            current_layer.state.commands.append(.name(name))
            current_layer.state.commands.append(.command("gs"))
        }
        
        if resources.shading[color] == nil {
            resources.shading[color] = PDFName("Sh\(resources.shading.count + 1)")
        }
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        
        current_layer.state.commands.append(.name(resources.shading[color]!))
        current_layer.state.commands.append(.command("sh"))
        current_layer.state.commands.append(.command("Q"))
    }
    
    func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard self.transform.invertible else { return }
        
        let stops = stops.sorted()
        guard stops.count >= 2 else { return }
        
        let color = PDFContext.PDFShading(
            type: 2,
            deviceGray: state.is_clip,
            coords: [start.x, start.y, end.x, end.y],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if stops.contains(where: { !$0.color.isOpaque }) {
            
            let mask = PDFContext.PDFShading(
                type: 2,
                deviceGray: true,
                coords: [start.x, start.y, end.x, end.y],
                function: create_gradient_opacity_function(stops: stops),
                e0: startSpread == .pad,
                e1: endSpread == .pad
            )
            
            self._draw_gradient(color, mask)
            
        } else {
            
            self._draw_gradient(color, nil)
        }
    }
    
    func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard self.transform.invertible else { return }
        
        let stops = stops.sorted()
        guard stops.count >= 2 else { return }
        
        let color = PDFContext.PDFShading(
            type: 3,
            deviceGray: state.is_clip,
            coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
            function: create_gradient_function(stops: stops),
            e0: startSpread == .pad,
            e1: endSpread == .pad
        )
        
        if stops.contains(where: { !$0.color.isOpaque }) {
            
            let mask = PDFContext.PDFShading(
                type: 3,
                deviceGray: true,
                coords: [start.x, start.y, startRadius, end.x, end.y, endRadius],
                function: create_gradient_opacity_function(stops: stops),
                e0: startSpread == .pad,
                e1: endSpread == .pad
            )
            
            self._draw_gradient(color, mask)
            
        } else {
            
            self._draw_gradient(color, nil)
        }
    }
}

extension PDFContext.Page {
    
    enum PatchDirection {
        
        case none
        case right
        case left
        case down
    }
    
    public func drawMeshGradient<C>(_ mesh: MeshGradient<C>) {
        
        guard self.transform.invertible && mesh.transform.invertible else { return }
        
        let mesh = mesh.convert(to: colorSpace, intent: renderingIntent)
        
        var patch_coord_data: [PDFContext.PDFMeshCoordData] = []
        var patch_color_data: [[[Double]]] = []
        var patch_opacity_data: [[[Double]]] = []
        
        let type: Int
        
        switch mesh.type {
        case .coonsPatch: type = 6
        case .tensorProduct: type = 7
        }
        
        func encode(_ flag: Int, _ direction: PatchDirection, _ evenOdd: Int, _ patch: CubicBezierPatch<Point>, _ c0: AnyColor, _ c1: AnyColor, _ c2: AnyColor, _ c3: AnyColor) {
            
            let _c0 = (0..<colorSpace.numberOfComponents).map { c0.component($0) }
            let _c1 = (0..<colorSpace.numberOfComponents).map { c1.component($0) }
            let _c2 = (0..<colorSpace.numberOfComponents).map { c2.component($0) }
            let _c3 = (0..<colorSpace.numberOfComponents).map { c3.component($0) }
            
            switch (direction, evenOdd) {
                
            case (.none, _):
                
                var coord_data = [
                    patch.m30, patch.m20, patch.m10, patch.m00,
                    patch.m01, patch.m02, patch.m03,
                    patch.m13, patch.m23, patch.m33,
                    patch.m32, patch.m31,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m21)
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m22)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c2, _c0, _c1, _c3])
                patch_opacity_data.append([[c2.opacity * mesh.opacity], [c0.opacity * mesh.opacity], [c1.opacity * mesh.opacity], [c3.opacity * mesh.opacity]])
                
            case (.right, 0):
                
                var coord_data = [
                    patch.m01, patch.m02, patch.m03,
                    patch.m13, patch.m23, patch.m33,
                    patch.m32, patch.m31,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m21)
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m22)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c1, _c3])
                patch_opacity_data.append([[c1.opacity * mesh.opacity], [c3.opacity * mesh.opacity]])
                
            case (.right, 1):
                
                var coord_data = [
                    patch.m31, patch.m32, patch.m33,
                    patch.m23, patch.m13, patch.m03,
                    patch.m02, patch.m01,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m21)
                    coord_data.append(patch.m22)
                    coord_data.append(patch.m12)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c3, _c1])
                patch_opacity_data.append([[c3.opacity * mesh.opacity], [c1.opacity * mesh.opacity]])
                
            case (.left, 0):
                
                var coord_data = [
                    patch.m32, patch.m31, patch.m30,
                    patch.m20, patch.m10, patch.m00,
                    patch.m01, patch.m02,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m22)
                    coord_data.append(patch.m21)
                    coord_data.append(patch.m11)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c2, _c0])
                patch_opacity_data.append([[c2.opacity * mesh.opacity], [c0.opacity * mesh.opacity]])
                
            case (.left, 1):
                
                var coord_data = [
                    patch.m02, patch.m01, patch.m00,
                    patch.m10, patch.m20, patch.m30,
                    patch.m31, patch.m32,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m22)
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m21)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c0, _c2])
                patch_opacity_data.append([[c0.opacity * mesh.opacity], [c2.opacity * mesh.opacity]])
                
            case (.down, 0):
                
                var coord_data = [
                    patch.m13, patch.m23, patch.m33,
                    patch.m32, patch.m31, patch.m30,
                    patch.m20, patch.m10,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m22)
                    coord_data.append(patch.m21)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c3, _c2])
                patch_opacity_data.append([[c3.opacity * mesh.opacity], [c2.opacity * mesh.opacity]])
                
            case (.down, 1):
                
                var coord_data = [
                    patch.m10, patch.m20, patch.m30,
                    patch.m31, patch.m32, patch.m33,
                    patch.m23, patch.m13,
                ]
                
                switch mesh.type {
                case .coonsPatch: break
                case .tensorProduct:
                    coord_data.append(patch.m12)
                    coord_data.append(patch.m11)
                    coord_data.append(patch.m21)
                    coord_data.append(patch.m22)
                }
                
                patch_coord_data.append(PDFContext.PDFMeshCoordData(flag: flag, coord: coord_data))
                
                patch_color_data.append([_c2, _c3])
                patch_opacity_data.append([[c2.opacity * mesh.opacity], [c3.opacity * mesh.opacity]])
                
            default: break
            }
        }
        
        let patches = mesh.patches.map { $0 * mesh.transform }
        let colors = mesh.patch_colors
        
        guard patches.count == mesh.row * mesh.column else { return }
        guard colors.count == mesh.row * mesh.column else { return }
        
        if mesh.column == 1 {
            
            for y in 0..<mesh.row {
                
                let patch = patches[y]
                let color = colors[y]
                
                switch y {
                case 0: encode(0, .none, y & 1, patch, color.0, color.1, color.2, color.3)
                case 1: encode(3, .down, y & 1, patch, color.0, color.1, color.2, color.3)
                default: encode(2, .down, y & 1, patch, color.0, color.1, color.2, color.3)
                }
            }
            
        } else {
            
            for y in 0..<mesh.row {
                
                if y & 1 == 0 {
                    
                    for x in 0..<mesh.column {
                        
                        let patch = patches[y * mesh.column + x]
                        let color = colors[y * mesh.column + x]
                        
                        if x == 0 && y == 0 {
                            encode(0, .none, x & 1, patch, color.0, color.1, color.2, color.3)
                        } else if x == 0 {
                            encode(3, .down, x & 1, patch, color.0, color.1, color.2, color.3)
                        } else if x == 1 && y != 0 {
                            encode(1, .right, x & 1, patch, color.0, color.1, color.2, color.3)
                        } else {
                            encode(2, .right, x & 1, patch, color.0, color.1, color.2, color.3)
                        }
                    }
                    
                } else {
                    
                    for x in (0..<mesh.column).reversed() {
                        
                        let patch = patches[y * mesh.column + x]
                        let color = colors[y * mesh.column + x]
                        
                        if x + 1 == mesh.column {
                            encode(x & 1 == 0 ? 3 : 1, .down, ~x & 1, patch, color.0, color.1, color.2, color.3)
                        } else if x + 2 == mesh.column {
                            encode(x & 1 == 0 ? 3 : 1, .left, ~x & 1, patch, color.0, color.1, color.2, color.3)
                        } else {
                            encode(2, .left, ~x & 1, patch, color.0, color.1, color.2, color.3)
                        }
                    }
                }
            }
        }
        
        let color = PDFContext.PDFMeshShading(
            type: type,
            deviceGray: false,
            numberOfComponents: colorSpace.numberOfComponents,
            coord: patch_coord_data,
            color: patch_color_data
        )
        
        if patch_opacity_data.contains(where: { $0.contains { $0[0] < 1 } }) {
            
            let mask = PDFContext.PDFMeshShading(
                type: type,
                deviceGray: true,
                numberOfComponents: 1,
                coord: patch_coord_data,
                color: patch_opacity_data
            )
            
            self._draw_gradient(color, mask)
            
        } else {
            
            self._draw_gradient(color, nil)
        }
    }
}

extension PDFContext.Page {
    
    private func _draw_pattern(_ pattern: Pattern, _ shape: Shape, _ winding: Shape.WindingRule, _ disable_clip: Bool) {
        
        if disable_clip {
            
            current_layer.state.commands.append(.command("Q"))
            current_layer.state.commands.append(.command("q"))
            current_layer.state.currentStyle.apply(to: current_layer)
            
            set_blendmode()
            set_opacity(pattern.opacity * self.opacity)
            
        } else {
            
            set_blendmode()
            set_opacity(pattern.opacity * self.opacity)
            
            current_layer.state.commands.append(.command("q"))
        }
        
        let pattern_context = PDFContext.Page(media: pattern.bound, crop: pattern.bound, bleed: pattern.bound, trim: pattern.bound, margin: pattern.bound, colorSpace: colorSpace)
        pattern_context.initialize()
        
        pattern.callback(PDFContext(pages: [pattern_context]))
        
        let name = PDFName("P\(resources.pattern.count + 1)")
        resources.pattern[name] = PDFContext.PDFPattern(
            type: 1,
            paintType: 1,
            tilingType: 3,
            bound: pattern.bound,
            xStep: pattern.xStep,
            yStep: pattern.yStep,
            transform: .reflectY(pattern.bound.midY) * pattern.transform * _mirrored_transform,
            resources: pattern_context.resources,
            commands: pattern_context.finalize()
        )
        
        current_layer.state.commands.append(.name("Pattern"))
        current_layer.state.commands.append(.command("cs"))
        current_layer.state.commands.append(.name(name))
        current_layer.state.commands.append(.command("scn"))
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        switch winding {
        case .nonZero: current_layer.state.commands.append(.command("f"))
        case .evenOdd: current_layer.state.commands.append(.command("f*"))
        }
        
        if disable_clip {
            
            current_layer.state.commands.append(.command("Q"))
            current_layer.state.commands.append(.command("q"))
            current_layer.state.currentStyle.apply(to: current_layer)
            
            switch current_layer.state.clip {
            
            case let .clip(shape, winding):
                
                self.encode_path(shape: shape, commands: &current_layer.state.commands)
                
                switch winding {
                case .nonZero: current_layer.state.commands.append(.command("W"))
                case .evenOdd: current_layer.state.commands.append(.command("W*"))
                }
                
                current_layer.state.commands.append(.command("n"))
                
            case let .mask(name):
                
                current_layer.state.commands.append(.name(name))
                current_layer.state.commands.append(.command("gs"))
                
            default: break
            }
            
        } else {
            
            current_layer.state.commands.append(.command("Q"))
        }
    }
    
    func draw(shape: Shape, winding: Shape.WindingRule, color pattern: Pattern) {
        
        guard self.transform.invertible else { return }
        
        let shape = shape * _mirrored_transform
        
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        guard !pattern.bound.width.almostZero() && !pattern.bound.height.almostZero() && !pattern.xStep.almostZero() && !pattern.yStep.almostZero() else { return }
        guard !pattern.bound.isEmpty && pattern.xStep.isFinite && pattern.yStep.isFinite else { return }
        guard pattern.transform.invertible else { return }
        
        self._draw_pattern(pattern, shape, winding, false)
    }
    
    func drawPattern(_ pattern: Pattern) {
        
        guard self.transform.invertible else { return }
        
        guard !pattern.bound.width.almostZero() && !pattern.bound.height.almostZero() && !pattern.xStep.almostZero() && !pattern.yStep.almostZero() else { return }
        guard !pattern.bound.isEmpty && pattern.xStep.isFinite && pattern.yStep.isFinite else { return }
        guard pattern.transform.invertible else { return }
        
        if case let .clip(shape, winding) = current_layer.state.clip {
            
            self._draw_pattern(pattern, shape, winding, true)
            
        } else {
            
            self._draw_pattern(pattern, Shape(rect: self.media), .nonZero, false)
        }
    }
}

extension PDFContext.Page {
    
    func draw(shape: Shape, stroke: Stroke<Pattern>) {
        
        guard self.transform.invertible else { return }
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        guard !stroke.color.bound.width.almostZero() && !stroke.color.bound.height.almostZero() && !stroke.color.xStep.almostZero() && !stroke.color.yStep.almostZero() else { return }
        guard !stroke.color.bound.isEmpty && stroke.color.xStep.isFinite && stroke.color.yStep.isFinite else { return }
        guard stroke.color.transform.invertible else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        set_blendmode()
        set_stroke_state(stroke)
        
        current_layer.state.commands.append(.command("q"))
        
        let pattern = stroke.color
        
        set_stroke_opacity(pattern.opacity * self.opacity)
        
        let pattern_context = PDFContext.Page(media: pattern.bound, crop: pattern.bound, bleed: pattern.bound, trim: pattern.bound, margin: pattern.bound, colorSpace: colorSpace)
        pattern_context.initialize()
        
        pattern.callback(PDFContext(pages: [pattern_context]))
        
        let name = PDFName("P\(resources.pattern.count + 1)")
        resources.pattern[name] = PDFContext.PDFPattern(
            type: 1,
            paintType: 1,
            tilingType: 3,
            bound: pattern.bound,
            xStep: pattern.xStep,
            yStep: pattern.yStep,
            transform: .reflectY(pattern.bound.midY) * pattern.transform * _mirrored_transform,
            resources: pattern_context.resources,
            commands: pattern_context.finalize()
        )
        
        current_layer.state.commands.append(.name("Pattern"))
        current_layer.state.commands.append(.command("CS"))
        current_layer.state.commands.append(.name(name))
        current_layer.state.commands.append(.command("SCN"))
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        current_layer.state.commands.append(.command("S"))
        
        current_layer.state.commands.append(.command("Q"))
    }
}

extension PDFContext.Page {
    
    private func _draw<C1, C2>(_ color: C1, _ stroke: Stroke<C2>, _ shape: Shape, _ winding: Shape.WindingRule) {
        
        let transform = _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        set_blendmode()
        set_stroke_state(stroke)
        
        var fill_pattern: PDFName?
        var stroke_pattern: PDFName?
        
        switch color {
        
        case let color as AnyColor:
            
            set_opacity(color.opacity * self.opacity)
            
            let _color = (0..<color.numberOfComponents - 1).map { PDFCommand(color.component($0)) }
            
            if current_layer.state.currentStyle.color != _color {
                current_layer.state.commands.append(contentsOf: _color)
                current_layer.state.commands.append(.command("sc"))
                current_layer.state.currentStyle.color = _color
            }
            
        case let pattern as Pattern:
            
            set_opacity(pattern.opacity * self.opacity)
            
            let pattern_context = PDFContext.Page(media: pattern.bound, crop: pattern.bound, bleed: pattern.bound, trim: pattern.bound, margin: pattern.bound, colorSpace: colorSpace)
            pattern_context.initialize()
            
            pattern.callback(PDFContext(pages: [pattern_context]))
            
            let name = PDFName("P\(resources.pattern.count + 1)")
            resources.pattern[name] = PDFContext.PDFPattern(
                type: 1,
                paintType: 1,
                tilingType: 3,
                bound: pattern.bound,
                xStep: pattern.xStep,
                yStep: pattern.yStep,
                transform: .reflectY(pattern.bound.midY) * pattern.transform * _mirrored_transform,
                resources: pattern_context.resources,
                commands: pattern_context.finalize()
            )
            
            fill_pattern = name
            
        default: break
        }
        
        switch stroke.color {
        
        case let color as AnyColor:
            
            set_stroke_opacity(color.opacity * self.opacity)
            
            let _color = (0..<color.numberOfComponents - 1).map { PDFCommand(color.component($0)) }
            
            if current_layer.state.currentStyle.stroke != _color {
                current_layer.state.commands.append(contentsOf: _color)
                current_layer.state.commands.append(.command("SC"))
                current_layer.state.currentStyle.stroke = _color
            }
            
        case let pattern as Pattern:
            
            set_stroke_opacity(pattern.opacity * self.opacity)
            
            let pattern_context = PDFContext.Page(media: pattern.bound, crop: pattern.bound, bleed: pattern.bound, trim: pattern.bound, margin: pattern.bound, colorSpace: colorSpace)
            pattern_context.initialize()
            
            pattern.callback(PDFContext(pages: [pattern_context]))
            
            let name = PDFName("P\(resources.pattern.count + 1)")
            resources.pattern[name] = PDFContext.PDFPattern(
                type: 1,
                paintType: 1,
                tilingType: 3,
                bound: pattern.bound,
                xStep: pattern.xStep,
                yStep: pattern.yStep,
                transform: .reflectY(pattern.bound.midY) * pattern.transform * _mirrored_transform,
                resources: pattern_context.resources,
                commands: pattern_context.finalize()
            )
            
            stroke_pattern = name
            
        default: break
        }
        
        current_layer.state.commands.append(.command("q"))
        
        if let name = fill_pattern {
            current_layer.state.commands.append(.name("Pattern"))
            current_layer.state.commands.append(.command("cs"))
            current_layer.state.commands.append(.name(name))
            current_layer.state.commands.append(.command("scn"))
        }
        if let name = stroke_pattern {
            current_layer.state.commands.append(.name("Pattern"))
            current_layer.state.commands.append(.command("CS"))
            current_layer.state.commands.append(.name(name))
            current_layer.state.commands.append(.command("SCN"))
        }
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        
        self.encode_path(shape: shape, commands: &current_layer.state.commands)
        switch winding {
        case .nonZero: current_layer.state.commands.append(.command("B"))
        case .evenOdd: current_layer.state.commands.append(.command("B*"))
        }
        
        current_layer.state.commands.append(.command("Q"))
    }
    
    func draw<C1: ColorProtocol, C2: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C1, stroke: Stroke<C2>) {
        
        guard self.transform.invertible else { return }
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        let stroke = Stroke(width: stroke.width, cap: stroke.cap, join: stroke.join, color: stroke.color.convert(to: colorSpace, intent: renderingIntent))
        self._draw(color, stroke, shape, winding)
    }
    
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color pattern: Pattern, stroke: Stroke<C>) {
        
        guard self.transform.invertible else { return }
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        guard !pattern.bound.width.almostZero() && !pattern.bound.height.almostZero() && !pattern.xStep.almostZero() && !pattern.yStep.almostZero() else { return }
        guard !pattern.bound.isEmpty && pattern.xStep.isFinite && pattern.yStep.isFinite else { return }
        guard pattern.transform.invertible else { return }
        
        let stroke = Stroke(width: stroke.width, cap: stroke.cap, join: stroke.join, color: stroke.color.convert(to: colorSpace, intent: renderingIntent))
        self._draw(pattern, stroke, shape, winding)
    }
    func draw<C: ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C, stroke: Stroke<Pattern>) {
        
        guard self.transform.invertible else { return }
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        let color = color.convert(to: colorSpace, intent: renderingIntent)
        self._draw(color, stroke, shape, winding)
    }
    func draw(shape: Shape, winding: Shape.WindingRule, color: Pattern, stroke: Stroke<Pattern>) {
        
        guard self.transform.invertible else { return }
        guard shape.contains(where: { !$0.isEmpty }) && shape.transform.invertible else { return }
        
        guard !color.bound.width.almostZero() && !color.bound.height.almostZero() && !color.xStep.almostZero() && !color.yStep.almostZero() else { return }
        guard !color.bound.isEmpty && color.xStep.isFinite && color.yStep.isFinite else { return }
        guard color.transform.invertible else { return }
        
        guard !stroke.color.bound.width.almostZero() && !stroke.color.bound.height.almostZero() && !stroke.color.xStep.almostZero() && !stroke.color.yStep.almostZero() else { return }
        guard !stroke.color.bound.isEmpty && stroke.color.xStep.isFinite && stroke.color.yStep.isFinite else { return }
        guard stroke.color.transform.invertible else { return }
        
        self._draw(color, stroke, shape, winding)
    }
}

extension PDFContext.Page {
    
    func drawShading(_ shader: PDFFunction) {
        
        guard self.transform.invertible else { return }
        
        let transform = _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        set_blendmode()
        set_opacity(self.opacity)
        
        current_layer.state.commands.append(.command("q"))
        
        let shading = PDFContext.PDFShading(
            type: 1,
            deviceGray: state.is_clip,
            coords: [],
            function: shader,
            e0: false,
            e1: false
        )
        
        if resources.shading[shading] == nil {
            resources.shading[shading] = PDFName("Sh\(resources.shading.count + 1)")
        }
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        
        current_layer.state.commands.append(.name(resources.shading[shading]!))
        current_layer.state.commands.append(.command("sh"))
        current_layer.state.commands.append(.command("Q"))
    }
}
