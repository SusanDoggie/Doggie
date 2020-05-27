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
    
    private var context_colorspace: AnyColorSpace? {
        return (context as? PDFRendererContextProtocol)?._colorspace
    }
    
    private var deviceGray: AnyColorSpace? {
        return context_colorspace.flatMap { $0.base as? ColorSpace<GrayColorModel> }.map { AnyColorSpace($0) }
    }
    
    private var deviceRGB: AnyColorSpace? {
        return context_colorspace.flatMap { $0.base as? ColorSpace<RGBColorModel> }.map { AnyColorSpace($0) }
    }
    
    private var deviceCMYK: AnyColorSpace? {
        return context_colorspace.flatMap { $0.base as? ColorSpace<CMYKColorModel> }.map { AnyColorSpace($0) }
    }
    
    private func convert(_ colorSpace: PDFColorSpace, _ color: [PDFNumber]) -> AnyColor? {
        
        switch colorSpace {
        case .deviceGray:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            if let deviceGray = deviceGray {
                return AnyColor(colorSpace: deviceGray, components: color)
            }
            
            if let deviceRGB = deviceRGB {
                return AnyColor(colorSpace: deviceRGB, components: [color[0], color[0], color[0]])
            }
            
            if let deviceCMYK = deviceCMYK {
                return AnyColor(colorSpace: deviceCMYK, components: [0, 0, 0, 1 - color[0]])
            }
            
            return nil
            
        case .deviceRGB:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            if let deviceRGB = deviceRGB {
                return AnyColor(colorSpace: deviceRGB, components: color)
            }
            
            let rgb = RGBColorModel(red: color[0], green: color[1], blue: color[2])
            
            if let deviceGray = deviceGray {
                let gray = 0.3 * rgb.red + 0.59 * rgb.green + 0.11 * rgb.blue
                return AnyColor(colorSpace: deviceGray, components: [gray])
            }
            
            if let deviceCMYK = deviceCMYK {
                return AnyColor(colorSpace: deviceCMYK, components: CMYKColorModel(rgb))
            }
            
            return nil
            
        case .deviceCMYK:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            if let deviceCMYK = deviceCMYK {
                return AnyColor(colorSpace: deviceCMYK, components: color)
            }
            
            let cmyk = CMYKColorModel(cyan: color[0], magenta: color[1], yellow: color[2], black: color[3])
            
            if let deviceGray = deviceGray {
                let gray = 1 - min(1, 0.3 * cmyk.cyan + 0.59 * cmyk.magenta + 0.11 * cmyk.yellow + cmyk.black)
                return AnyColor(colorSpace: deviceGray, components: [gray])
            }
            
            if let deviceRGB = deviceRGB {
                return AnyColor(colorSpace: deviceRGB, components: RGBColorModel(cmyk))
            }
            
            return nil
            
        case let .indexed(base, table):
            
            guard let index = color[0].int64Value else { return nil }
            
            return 0..<table.count ~= Int(index) ? self.convert(base, table[Int(index)].map { PDFNumber(Double($0) / 255) }) : nil
            
        case let .colorSpace(colorSpace): return AnyColor(colorSpace: colorSpace, components: color.map { $0.doubleValue ?? 0 })
        }
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
        return self.convert(state.fillColorSpace, state.fill)
    }
    
    var stroke: AnyColor? {
        return self.convert(state.strokeColorSpace, state.stroke)?.with(opacity: state.strokeOpacity)
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
    
    var hasMask: Bool {
        return state.mask != nil || !state.clipPath.isEmpty
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
        context.saveGraphicState()
        graphicStateStack.append(state)
    }
    
    func restoreGraphicState() {
        context.restoreGraphicState()
        state = graphicStateStack.popLast() ?? state
    }
    
    func beginTransparencyLayer() {
        layerStack.append(state)
        context.beginTransparencyLayer()
        state = GraphicState()
    }
    
    func endTransparencyLayer() {
        state = layerStack.popLast() ?? state
        context.endTransparencyLayer()
    }
    
    func set_clip_list(_ clipPath: [(Shape, Shape.WindingRule)]) {
        
        switch clipPath.count {
            
        case 0: return
            
        case 1: context.clip(shape: clipPath[0].0 * context.transform.inverse, winding: clipPath[0].1)
            
        default:
            
            let transform = context.transform.inverse
            
            context.drawClip { context in
                
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
            
            self._drawClip(alphaMask: alphaMask, body: mask)
            
        } else {
            
            self.set_clip_list(state.clipPath)
        }
    }
    
    private func _drawClip(alphaMask: Bool, body: @escaping (PDFRenderer) -> Void) {
        
        let clipPath = state.clipPath
        
        context.drawClip { context in
            
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
    
    func drawClip(alphaMask: Bool, body: @escaping (PDFRenderer) -> Void) {
        
        let current_transform = context.transform
        
        state.mask = (alphaMask, { context in
            context.concatenate(current_transform * context.transform.inverse)
            body(context)
        })
        
        self._drawClip(alphaMask: alphaMask, body: body)
    }
    
    func drawImage(image: AnyImage) {
        context.draw(image: image, in: Rect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func createImage(color: PDFBitmap, mask: PDFBitmap?) -> AnyImage? {
        
        switch color.colorSpace {
            
        case .deviceGray:
            
            if let deviceGray = self.deviceGray {
                
                var bitmaps = [color.rawBitmap]
                
                if let mask = mask, mask.width == color.width && mask.height == color.height {
                    bitmaps.append(mask.maskBitmap(color.colorSpace.numberOfComponents))
                }
                
                return AnyImage(width: color.width, height: color.height, colorSpace: deviceGray, bitmaps: bitmaps, premultiplied: false)
            }
            
            if let deviceRGB = self.deviceRGB {
                
            }
            
            if let deviceCMYK = self.deviceCMYK {
                
            }
            
        case .deviceRGB:
            
            if let deviceRGB = self.deviceRGB {
                
                var bitmaps = [color.rawBitmap]
                
                if let mask = mask, mask.width == color.width && mask.height == color.height {
                    bitmaps.append(mask.maskBitmap(color.colorSpace.numberOfComponents))
                }
                
                return AnyImage(width: color.width, height: color.height, colorSpace: deviceRGB, bitmaps: bitmaps, premultiplied: false)
            }
            
            if let deviceGray = self.deviceGray {
                
            }
            
            if let deviceCMYK = self.deviceCMYK {
                
            }
            
        case .deviceCMYK:
            
            if let deviceCMYK = self.deviceCMYK {
                
                var bitmaps = [color.rawBitmap]
                
                if let mask = mask, mask.width == color.width && mask.height == color.height {
                    bitmaps.append(mask.maskBitmap(color.colorSpace.numberOfComponents))
                }
                
                return AnyImage(width: color.width, height: color.height, colorSpace: deviceCMYK, bitmaps: bitmaps, premultiplied: false)
            }
            
            if let deviceGray = self.deviceGray {
                
            }
            
            if let deviceRGB = self.deviceRGB {
                
            }
            
        case let .indexed(base, table):
            
            guard color.bitsPerComponent == 8 else { return nil }
            
            guard let _color = PDFBitmap(width: color.width, height: color.height, bitsPerComponent: 8, colorSpace: base, decodeParms: color.decodeParms, data: Data(color.data.flatMap { table[Int($0)] })) else { return nil }
            
            return self.createImage(color: _color, mask: mask)
            
        case let .colorSpace(colorSpace):
            
            var bitmaps = [color.rawBitmap]
            
            if let mask = mask, mask.width == color.width && mask.height == color.height {
                bitmaps.append(mask.maskBitmap(color.colorSpace.numberOfComponents))
            }
            
            return AnyImage(width: color.width, height: color.height, colorSpace: colorSpace, bitmaps: bitmaps, premultiplied: false)
        }
        
        return nil
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
        
        let colors = stops.map { self.convert(colorSpace, $0.color.map { PDFNumber($0) }) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawLinearGradient(stops: _stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
    }
    
    func drawRadialGradient(function: PDFFunction, colorSpace: PDFColorSpace, start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard let stops = self.make_gradient_stops(function: function) else { return }
        guard stops.allSatisfy({ $0.color.count == colorSpace.numberOfComponents }) else { return }
        
        let colors = stops.map { self.convert(colorSpace, $0.color.map { PDFNumber($0) }) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawRadialGradient(stops: _stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
    }
}
