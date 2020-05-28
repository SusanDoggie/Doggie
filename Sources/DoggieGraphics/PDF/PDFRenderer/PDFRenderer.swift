//
//  PDFRenderer.swift
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

class PDFRenderer {
    
    private var state: GraphicState = GraphicState()
    private var graphicStateStack: [GraphicState] = []
    private var layerStack: [GraphicState] = []
    
    private let context: DrawableContext
    
    let alphaMask: Bool
    
    init(context: DrawableContext, alphaMask: Bool = false) {
        self.context = context
        self.alphaMask = alphaMask
    }
}

extension PDFRenderer {
    
    private struct GraphicState {
        
        var fillColorSpace: PDFColorSpace = .deviceRGB
        var strokeColorSpace: PDFColorSpace = .deviceRGB
        
        var fill: [PDFNumber] = [0, 0, 0]
        var stroke: [PDFNumber] = [0, 0, 0]
        
        var strokeOpacity: Double = 1
        
        var strokeWidth: Double = 1
        var strokeCap: StrokeCap = .butt
        var strokeJoin: StrokeJoin = .miter
        var miterLimit: Double = 4
        
        var dashArray: [Double] = []
        var dashPhase: Double = 0
        
        var clipPath: [(Shape, Shape.WindingRule)] = []
        var mask: (Bool, (PDFRenderer) -> Void)?
        
        var path: Shape = Shape()
    }
    
    enum StrokeCap: CaseIterable {
        case butt
        case round
        case square
    }
    
    enum StrokeJoin: CaseIterable {
        case miter
        case round
        case bevel
    }
}

private protocol PDFRendererContextProtocol {
    
    var _colorspace: AnyColorSpace { get }
}

extension ImageContext: PDFRendererContextProtocol {
    
    fileprivate var _colorspace: AnyColorSpace {
        return AnyColorSpace(self.colorSpace)
    }
}

extension PDFContext: PDFRendererContextProtocol {
    
    fileprivate var _colorspace: AnyColorSpace {
        return AnyColorSpace(self.colorSpace)
    }
}

extension SVGContext: PDFRendererContextProtocol {
    
    fileprivate var _colorspace: AnyColorSpace {
        return .sRGB
    }
}

extension PDFRenderer {
    
    var context_colorspace: AnyColorSpace? {
        return (context as? PDFRendererContextProtocol)?._colorspace
    }
}

extension PDFRenderer {
    
    var fillColorSpace: PDFColorSpace {
        return state.fillColorSpace
    }
    
    var strokeColorSpace: PDFColorSpace {
        return state.strokeColorSpace
    }
    
    var fill: AnyColor? {
        return state.fillColorSpace.create_color(state.fill, device: context_colorspace)
    }
    
    var stroke: AnyColor? {
        return state.strokeColorSpace.create_color(state.stroke, device: context_colorspace)?.with(opacity: state.strokeOpacity)
    }
    
    var path: Shape {
        get {
            return state.path
        }
        set {
            state.path = newValue
        }
    }
    
    func setFillColorSpace(_ colorSpace: PDFColorSpace) {
        if state.fillColorSpace != colorSpace {
            state.fillColorSpace = colorSpace
        }
        if state.fillColorSpace.numberOfComponents != state.fill.count {
            state.fill = Array(repeating: 0, count: state.fillColorSpace.numberOfComponents)
        }
    }
    
    func setStrokeColorSpace(_ colorSpace: PDFColorSpace) {
        if state.strokeColorSpace != colorSpace {
            state.strokeColorSpace = colorSpace
        }
        if state.strokeColorSpace.numberOfComponents != state.stroke.count {
            state.stroke = Array(repeating: 0, count: state.strokeColorSpace.numberOfComponents)
        }
    }
    
    func setFillColor(_ color: [PDFNumber]) {
        if state.fillColorSpace.numberOfComponents == color.count {
            state.fill = color
        }
    }
    
    func setStrokeColor(_ color: [PDFNumber]) {
        if state.strokeColorSpace.numberOfComponents == color.count {
            state.stroke = color
        }
    }
    
    var opacity: Double {
        get {
            return context.opacity
        }
        set {
            context.opacity = newValue
        }
    }
    
    var strokeOpacity: Double {
        get {
            return state.strokeOpacity
        }
        set {
            state.strokeOpacity = newValue
        }
    }
    
    var compositingMode: ColorCompositingMode {
        get {
            return context.compositingMode
        }
        set {
            context.compositingMode = newValue
        }
    }
    
    var blendMode: ColorBlendMode {
        get {
            return context.blendMode
        }
        set {
            context.blendMode = newValue
        }
    }
    
    var renderingIntent: RenderingIntent {
        get {
            return context.renderingIntent
        }
        set {
            context.renderingIntent = newValue
        }
    }
    
    var strokeWidth: Double {
        get {
            return state.strokeWidth
        }
        set {
            state.strokeWidth = newValue
        }
    }
    var strokeCap: StrokeCap {
        get {
            return state.strokeCap
        }
        set {
            state.strokeCap = newValue
        }
    }
    var strokeJoin: StrokeJoin {
        get {
            return state.strokeJoin
        }
        set {
            state.strokeJoin = newValue
        }
    }
    var miterLimit: Double {
        get {
            return state.miterLimit
        }
        set {
            state.miterLimit = newValue
        }
    }
    
    var dashArray: [Double] {
        get {
            return state.dashArray
        }
        set {
            state.dashArray = newValue
        }
    }
    var dashPhase: Double {
        get {
            return state.dashPhase
        }
        set {
            state.dashPhase = newValue
        }
    }
    
    var transform: SDTransform {
        return context.transform
    }
    
    func concatenate(_ transform: SDTransform) {
        context.concatenate(transform)
    }
    
    func saveGraphicState() {
        graphicStateStack.append(state)
        context.saveGraphicState()
    }
    
    func restoreGraphicState() {
        guard let state = graphicStateStack.popLast() else { return }
        self.state = state
        context.restoreGraphicState()
    }
    
    func beginTransparencyLayer() {
        layerStack.append(state)
        context.beginTransparencyLayer()
        state = GraphicState()
    }
    
    func endTransparencyLayer() {
        guard let state = layerStack.popLast() else { return }
        self.state = state
        context.endTransparencyLayer()
    }
    
    func makeBalance() {
        while !graphicStateStack.isEmpty {
            self.restoreGraphicState()
        }
        while !layerStack.isEmpty {
            self.endTransparencyLayer()
        }
    }
    
    func set_clip_list(_ clipPath: [(Shape, Shape.WindingRule)]) {
        
        switch clipPath.count {
            
        case 0: return
            
        case 1: context.clip(shape: clipPath[0].0 * context.transform.inverse, winding: clipPath[0].1)
            
        default:
            
            let transform = context.transform.inverse
            
            context.clipToDrawing { context in
                
                context.concatenate(transform)
                
                for (path, winding) in clipPath.dropLast() {
                    context.clip(shape: path, winding: winding)
                    context.beginTransparencyLayer()
                }
                
                let last = clipPath.last!
                context.draw(shape: last.0, winding: last.1, color: AnyColor.white)
                
                for _ in 0..<clipPath.count - 1 {
                    context.endTransparencyLayer()
                }
            }
        }
    }
    
    func resetMask() {
        
        state.mask = nil
        
        if state.clipPath.isEmpty {
            
            context.resetClip()
            
        } else {
            
            self.set_clip_list(state.clipPath)
        }
    }
    
    func clip(winding: Shape.WindingRule) {
        
        state.clipPath.append((state.path * context.transform, winding))
        
        if let (alphaMask, mask) = state.mask {
            
            self._clipToDrawing(alphaMask: alphaMask, body: mask)
            
        } else {
            
            self.set_clip_list(state.clipPath)
        }
    }
    
    private func _clipToDrawing(alphaMask: Bool, body: @escaping (PDFRenderer) -> Void) {
        
        let clipPath = state.clipPath
        
        context.clipToDrawing { context in
            
            let renderer = PDFRenderer(context: context, alphaMask: alphaMask)
            
            if !clipPath.isEmpty {
                renderer.set_clip_list(clipPath)
                renderer.beginTransparencyLayer()
            }
            
            body(renderer)
            
            if !clipPath.isEmpty {
                renderer.endTransparencyLayer()
            }
        }
    }
    
    func clipToDrawing(alphaMask: Bool, body: @escaping (PDFRenderer) -> Void) {
        
        let current_transform = context.transform
        
        state.mask = (alphaMask, { context in
            context.concatenate(current_transform * context.transform.inverse)
            body(context)
        })
        
        self._clipToDrawing(alphaMask: alphaMask, body: body)
    }
    
    func drawImage(image: AnyImage) {
        context.draw(image: image, transform: SDTransform.scale(x: 1 / Double(image.width), y: 1 / Double(image.height)) * SDTransform.reflectY(0.5))
    }
    
    func draw(winding: Shape.WindingRule) {
        
        if alphaMask {
            
            context.draw(shape: state.path, winding: winding, color: AnyColor.white)
            
        } else {
            
            context.draw(shape: state.path, winding: winding, color: fill ?? .black)
        }
        
        state.path = Shape()
    }
    
    func drawStroke() {
        
        let cap: Shape.LineCap
        switch state.strokeCap {
        case .butt: cap = .butt
        case .round: cap = .round
        case .square: cap = .square
        }
        
        let join: Shape.LineJoin
        switch state.strokeJoin {
        case .miter: join = .miter(limit: state.miterLimit)
        case .round: join = .round
        case .bevel: join = .bevel
        }
        
        let opacity = context.opacity
        context.opacity = 1
        
        if alphaMask {
            
            context.stroke(shape: state.path, width: state.strokeWidth, cap: cap, join: join, color: AnyColor.white.with(opacity: state.strokeOpacity))
            
        } else {
            
            context.stroke(shape: state.path, width: state.strokeWidth, cap: cap, join: join, color: stroke ?? AnyColor.black.with(opacity: state.strokeOpacity))
        }
        
        state.path = Shape()
        
        context.opacity = opacity
    }
    
    private struct PDFGradientStop: Hashable {
        
        public var offset: Double
        public var color: [Double]
        
        public init(offset: Double, color: [Double]) {
            self.offset = offset
            self.color = color
        }
    }
    
    private func make_gradient_stops(function: PDFFunction) -> [PDFGradientStop]? {
        
        switch function.type {
            
        case 2:
            
            guard let domain = function.domain.first else { return nil }
            
            return [
                PDFGradientStop(offset: domain.lowerBound, color: function.c0),
                PDFGradientStop(offset: domain.upperBound, color: function.c1),
            ]
            
        case 3:
            
            guard let domain = function.domain.first else { return nil }
            
            let ranges = zip([domain.lowerBound] + function.bounds, function.bounds + [domain.upperBound]).map { $0...$1 }
            
            var stops: [PDFGradientStop] = []
            
            for (range, function) in zip(ranges, function.functions) {
                
                guard let subdomain = function.domain.first else { return nil }
                guard var _stops = self.make_gradient_stops(function: function) else { return nil }
                
                let s = (range.upperBound - range.lowerBound) / (subdomain.upperBound - subdomain.lowerBound)
                
                _stops = _stops.map { PDFGradientStop(offset: ($0.offset - subdomain.lowerBound) * s + range.lowerBound, color: $0.color) }
                
                if stops.last == _stops.first {
                    stops.append(contentsOf: _stops.dropFirst())
                } else {
                    stops.append(contentsOf: _stops)
                }
            }
            
            return stops
            
        default: return nil
        }
    }
    
    func drawLinearGradient(function: PDFFunction, colorSpace: PDFColorSpace, start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard let stops = self.make_gradient_stops(function: function) else { return }
        guard stops.allSatisfy({ $0.color.count == colorSpace.numberOfComponents }) else { return }
        
        let colors = stops.map { colorSpace.create_color($0.color.map { PDFNumber($0) }, device: context_colorspace) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawLinearGradient(stops: _stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
    }
    
    func drawRadialGradient(function: PDFFunction, colorSpace: PDFColorSpace, start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard let stops = self.make_gradient_stops(function: function) else { return }
        guard stops.allSatisfy({ $0.color.count == colorSpace.numberOfComponents }) else { return }
        
        let colors = stops.map { colorSpace.create_color($0.color.map { PDFNumber($0) }, device: context_colorspace) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawRadialGradient(stops: _stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
    }
}
