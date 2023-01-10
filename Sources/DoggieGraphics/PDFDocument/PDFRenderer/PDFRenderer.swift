//
//  PDFRenderer.swift
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

class PDFRenderer {
    
    private var state: GraphicState = GraphicState()
    private var graphicStateStack: [GraphicState] = []
    private var layerStack: [GraphicState] = []
    
    private let context: DrawableContext
    
    var base_transform: SDTransform = .identity
    
    let alphaMask: Bool
    
    init(context: DrawableContext, alphaMask: Bool = false) {
        self.context = context
        self.alphaMask = alphaMask
    }
}

extension PDFRenderer {
    
    struct PDFPattern {
        
        var paintType: Int
        
        var bound: Rect
        
        var xStep: Double
        var yStep: Double
        
        var transform: SDTransform
        
        var callback: (PDFRenderer) -> Void
        
    }
    
    private struct GraphicState {
        
        var fillColorSpace: PDFColorSpace = .deviceRGB
        var strokeColorSpace: PDFColorSpace = .deviceRGB
        
        var fill: [PDFNumber] = [0, 0, 0]
        var stroke: [PDFNumber] = [0, 0, 0]
        
        var fillPattern: PDFPattern?
        var strokePattern: PDFPattern?
        
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
        return self.colorSpace
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
        return state.strokeColorSpace.create_color(state.stroke, device: context_colorspace)
    }
    
    var fillPattern: PDFPattern? {
        return state.fillPattern
    }
    
    var strokePattern: PDFPattern? {
        return state.strokePattern
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
            state.fillPattern = nil
        }
    }
    
    func setFillPattern(_ pattern: PDFPattern) {
        state.fillPattern = pattern
    }
    
    func setStrokeColor(_ color: [PDFNumber]) {
        if state.strokeColorSpace.numberOfComponents == color.count {
            state.stroke = color
            state.strokePattern = nil
        }
    }
    
    func setStrokePattern(_ pattern: PDFPattern) {
        state.strokePattern = pattern
    }
    
    var should_isolate: Bool {
        return opacity < 1 || !state.clipPath.isEmpty || state.mask != nil
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
    
    func drawImage(image: ImageRep) {
        context.draw(image: image, transform: SDTransform.scale(x: 1 / Double(image.width), y: 1 / Double(image.height)) * SDTransform.reflectY(0.5))
    }
    
    func fillPath(winding: Shape.WindingRule) {
        
        let opacity = context.opacity
        context.opacity = 1
        defer { context.opacity = opacity }
        
        if case .pattern = self.fillColorSpace, let pattern = self.fillPattern {
            
            switch pattern.paintType {
            
            case 1:
                
                var _pattern = Pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) { pattern.callback(PDFRenderer(context: $0, alphaMask: false)) }
                
                _pattern.transform = pattern.transform * base_transform * context.transform.inverse
                _pattern.opacity = opacity
                
                context.draw(shape: state.path, winding: winding, color: _pattern)
                
            case 2:
                
                context.beginTransparencyLayer()
                
                context.clipToDrawing { context in
                    
                    var _pattern = Pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) {
                        
                        let renderer = PDFRenderer(context: $0, alphaMask: false)
                        
                        renderer.setFillColorSpace(.deviceGray)
                        renderer.setFillColor([1])
                        renderer.setStrokeColorSpace(.deviceGray)
                        renderer.setStrokeColor([1])
                        
                        pattern.callback(renderer)
                    }
                    
                    _pattern.transform = pattern.transform * base_transform * context.transform.inverse
                    
                    context.draw(shape: state.path, winding: winding, color: _pattern)
                }
                
                var _fill = alphaMask ? AnyColor.white : fill ?? .black
                _fill.opacity = opacity
                
                context.draw(shape: state.path, winding: winding, color: _fill)
                
                context.endTransparencyLayer()
                
            default: break
            }
            
        } else {
            
            var _fill = alphaMask ? AnyColor.white : fill ?? .black
            _fill.opacity = opacity
            
            context.draw(shape: state.path, winding: winding, color: _fill)
        }
        
        state.path = Shape()
    }
    
    func strokePath() {
        
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
        defer { context.opacity = opacity }
        
        if case .pattern = self.strokeColorSpace, let pattern = self.strokePattern {
            
            switch pattern.paintType {
            
            case 1:
                
                var _pattern = Pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) { pattern.callback(PDFRenderer(context: $0, alphaMask: false)) }
                
                _pattern.transform = pattern.transform * base_transform * context.transform.inverse
                
                var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: _pattern)
                _stroke.color.opacity = state.strokeOpacity
                
                context.draw(shape: state.path, stroke: _stroke)
                
            case 2:
                
                context.beginTransparencyLayer()
                
                context.clipToDrawing { context in
                    
                    var _pattern = Pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) {
                        
                        let renderer = PDFRenderer(context: $0, alphaMask: false)
                        
                        renderer.setFillColorSpace(.deviceGray)
                        renderer.setFillColor([1])
                        renderer.setStrokeColorSpace(.deviceGray)
                        renderer.setStrokeColor([1])
                        
                        pattern.callback(renderer)
                    }
                    
                    _pattern.transform = pattern.transform * base_transform * context.transform.inverse
                    
                    let _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: _pattern)
                    
                    context.draw(shape: state.path, stroke: _stroke)
                }
                
                var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: alphaMask ? AnyColor.white : stroke ?? AnyColor.black)
                _stroke.color.opacity = state.strokeOpacity
                
                context.draw(shape: state.path, stroke: _stroke)
                
                context.endTransparencyLayer()
                
            default: break
            }
            
        } else {
            
            var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: alphaMask ? AnyColor.white : stroke ?? AnyColor.black)
            _stroke.color.opacity = state.strokeOpacity
            
            context.draw(shape: state.path, stroke: _stroke)
        }
        
        state.path = Shape()
    }
    
    func fillStroke(winding: Shape.WindingRule) {
        
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
        
        if case .pattern = self.fillColorSpace, let fillPattern = self.fillPattern {
            
            switch fillPattern.paintType {
            
            case 1:
                
                var _fill = Pattern(bound: fillPattern.bound, xStep: fillPattern.xStep, yStep: fillPattern.yStep) { fillPattern.callback(PDFRenderer(context: $0, alphaMask: false)) }
                
                _fill.transform = fillPattern.transform * base_transform * context.transform.inverse
                _fill.opacity = context.opacity
                
                if case .pattern = self.strokeColorSpace, let strokePattern = self.strokePattern {
                    
                    switch strokePattern.paintType {
                    
                    case 1:
                        
                        let opacity = context.opacity
                        context.opacity = 1
                        defer { context.opacity = opacity }
                        
                        var _stroke_pattern = Pattern(bound: strokePattern.bound, xStep: strokePattern.xStep, yStep: strokePattern.yStep) { strokePattern.callback(PDFRenderer(context: $0, alphaMask: false)) }
                        
                        _stroke_pattern.transform = strokePattern.transform * base_transform * context.transform.inverse
                        
                        var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: _stroke_pattern)
                        _stroke.color.opacity = state.strokeOpacity
                        
                        context.draw(shape: state.path, winding: winding, color: _fill, stroke: _stroke)
                        
                    default:
                        
                        let path = state.path
                        self.fillPath(winding: winding)
                        state.path = path
                        self.strokePath()
                        return
                    }
                    
                } else {
                    
                    let opacity = context.opacity
                    context.opacity = 1
                    defer { context.opacity = opacity }
                    
                    var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: alphaMask ? AnyColor.white : stroke ?? AnyColor.black)
                    _stroke.color.opacity = state.strokeOpacity
                    
                    context.draw(shape: state.path, winding: winding, color: _fill, stroke: _stroke)
                }
                
            default:
                
                let path = state.path
                self.fillPath(winding: winding)
                state.path = path
                self.strokePath()
                return
            }
            
        } else {
            
            var _fill = alphaMask ? AnyColor.white : fill ?? .black
            _fill.opacity = context.opacity
            
            if case .pattern = self.strokeColorSpace, let strokePattern = self.strokePattern {
                
                switch strokePattern.paintType {
                
                case 1:
                    
                    let opacity = context.opacity
                    context.opacity = 1
                    defer { context.opacity = opacity }
                    
                    var _stroke_pattern = Pattern(bound: strokePattern.bound, xStep: strokePattern.xStep, yStep: strokePattern.yStep) { strokePattern.callback(PDFRenderer(context: $0, alphaMask: false)) }
                    
                    _stroke_pattern.transform = strokePattern.transform * base_transform * context.transform.inverse
                    
                    var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: _stroke_pattern)
                    _stroke.color.opacity = state.strokeOpacity
                    
                    context.draw(shape: state.path, winding: winding, color: _fill, stroke: _stroke)
                    
                default:
                    
                    let path = state.path
                    self.fillPath(winding: winding)
                    state.path = path
                    self.strokePath()
                    return
                }
                
            } else {
                
                let opacity = context.opacity
                context.opacity = 1
                defer { context.opacity = opacity }
                
                var _stroke = Stroke(width: state.strokeWidth, cap: cap, join: join, color: alphaMask ? AnyColor.white : stroke ?? AnyColor.black)
                _stroke.color.opacity = state.strokeOpacity
                
                context.draw(shape: state.path, winding: winding, color: _fill, stroke: _stroke)
            }
        }
        
        state.path = Shape()
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
            
            for ((range, encode), function) in zip(zip(ranges, function.encode), function.functions) {
                
                guard let subdomain = function.domain.first else { return nil }
                guard var _stops = self.make_gradient_stops(function: function) else { return nil }
                
                let s = (subdomain.upperBound - subdomain.lowerBound) / (encode.t1 - encode.t0)
                let t = (range.upperBound - range.lowerBound) / (subdomain.upperBound - subdomain.lowerBound)
                
                _stops = _stops.map { PDFGradientStop(offset: ($0.offset - encode.t0) * s + subdomain.lowerBound, color: $0.color) }
                
                let prefix = zip(_stops, _stops.dropFirst()).first { !subdomain.contains($0.offset) && subdomain.contains($1.offset) }
                let suffix = zip(_stops, _stops.dropFirst()).first { subdomain.contains($0.offset) && !subdomain.contains($1.offset) }
                
                _stops = _stops.filter { subdomain.contains($0.offset) }
                
                if let (f0, f1) = prefix {
                    let t = (subdomain.lowerBound - f0.offset) / (f1.offset - f0.offset)
                    let color = zip(f0.color, f1.color).map { LinearInterpolate(t, $0, $1) }
                    _stops.insert(PDFGradientStop(offset: subdomain.lowerBound, color: color), at: 0)
                }
                
                if let (f0, f1) = suffix {
                    let t = (subdomain.upperBound - f0.offset) / (f1.offset - f0.offset)
                    let color = zip(f0.color, f1.color).map { LinearInterpolate(t, $0, $1) }
                    _stops.append(PDFGradientStop(offset: subdomain.upperBound, color: color))
                }
                
                _stops = _stops.map { PDFGradientStop(offset: ($0.offset - subdomain.lowerBound) * t + range.lowerBound, color: $0.color) }
                
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
        
        let colors = stops.map { alphaMask ? AnyColor.white : colorSpace.create_color($0.color.map { PDFNumber($0) }, device: context_colorspace) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawLinearGradient(stops: _stops, start: start, end: end, startSpread: startSpread, endSpread: endSpread)
    }
    
    func drawRadialGradient(function: PDFFunction, colorSpace: PDFColorSpace, start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        guard let stops = self.make_gradient_stops(function: function) else { return }
        guard stops.allSatisfy({ $0.color.count == colorSpace.numberOfComponents }) else { return }
        
        let colors = stops.map { alphaMask ? AnyColor.white : colorSpace.create_color($0.color.map { PDFNumber($0) }, device: context_colorspace) ?? .black }
        
        let _stops = zip(stops, colors).map { GradientStop(offset: $0.offset, color: $1) }
        
        context.drawRadialGradient(stops: _stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread)
    }
    
    struct BitsReader {
        
        var data: Data
        
        var bits: UInt = 0
        var bitsize: UInt = 0
        
        mutating func clear() {
            let size = bitsize & 7
            guard bitsize >= size else { return }
            let remain = bitsize - size
            bits &= (1 << remain) - 1
            bitsize = remain
        }
        
        mutating func next(_ size: Int) -> UInt? {
            
            if bitsize >= size {
                
                let remain = bitsize - UInt(size)
                let code = bits >> remain
                
                bits &= (1 << remain) - 1
                bitsize = remain
                
                return code
            }
            
            while let byte = data.popFirst() {
                
                bits = (bits << 8) | UInt(byte)
                bitsize += 8
                
                guard bitsize >= size else { continue }
                
                let remain = bitsize - UInt(size)
                let code = bits >> remain
                
                bits &= (1 << remain) - 1
                bitsize = remain
                
                return code
            }
            
            return nil
        }
    }
    
    struct PatchData {
        
        var flag: UInt
        
        var _coords: [UInt]
        
        var _colors: [UInt]
        
        var coords: [Double] = []
        
        var colors: [Double] = []
        
        mutating func decode(functions: [PDFFunction], colorSpace: PDFColorSpace, bitsPerCoordinate: Int, bitsPerComponent: Int, decode: [Double]) {
            
            let max_coord = (1 << bitsPerCoordinate) - 1
            let max_color = (1 << bitsPerComponent) - 1
            
            let numberOfComponents = colorSpace.numberOfComponents
            
            func decode_coord(_ coord: ArraySlice<UInt>) -> [Double] {
                let x = Double(coord.first!) / Double(max_coord) * (decode[1] - decode[0]) + decode[0]
                let y = Double(coord.last!) / Double(max_coord) * (decode[3] - decode[2]) + decode[2]
                return [x, y]
            }
            
            switch functions.count {
            
            case 0:
                
                func interpolate(_ x: UInt, _ decode: ArraySlice<Double>) -> Double {
                    return Double(x) / Double(max_color) * (decode.last! - decode.first!) + decode.first!
                }
                
                func decode_color(_ x: ArraySlice<UInt>) -> [Double] {
                    return zip(x, decode.dropFirst(4).chunks(ofCount: 2)).map { interpolate($0, $1) }
                }
                
                self.coords = self._coords.chunks(ofCount: 2).flatMap(decode_coord)
                self.colors = self._colors.chunks(ofCount: numberOfComponents).flatMap(decode_color)
                
            case 1:
                
                func decode_color(_ x: UInt) -> [Double] {
                    return functions[0].eval(Double(x) / Double(max_color) * (decode[5] - decode[4]) + decode[4])
                }
                
                self.coords = self._coords.chunks(ofCount: 2).flatMap(decode_coord)
                self.colors = self._colors.flatMap(decode_color)
                
            default:
                
                func decode_color(_ x: UInt) -> [Double] {
                    let t = Double(x) / Double(max_color) * (decode[5] - decode[4]) + decode[4]
                    return functions.map { $0.eval(t)[0] }
                }
                
                self.coords = self._coords.chunks(ofCount: 2).flatMap(decode_coord)
                self.colors = self._colors.flatMap(decode_color)
            }
        }
    }
    
    func drawMeshGradient(functions: [PDFFunction], colorSpace: PDFColorSpace, isCoonsPatch: Bool, bitsPerCoordinate: Int, bitsPerComponent: Int, bitsPerFlag: Int, decode: [Double], data: Data) {
        
        var reader = BitsReader(data: data)
        var patch_data: [PatchData] = []
        
        let numberOfComponents = functions.count == 0 ? colorSpace.numberOfComponents : 1
        
        while let flag = reader.next(bitsPerFlag) {
            
            var coords: [UInt] = []
            var colors: [UInt] = []
            
            switch flag {
            case 0:
                
                let _count = isCoonsPatch ? 24 : 32
                
                while coords.count < _count {
                    guard let d = reader.next(bitsPerCoordinate) else { return }
                    coords.append(d)
                }
                
                while colors.count < numberOfComponents * 4 {
                    guard let c = reader.next(bitsPerComponent) else { return }
                    colors.append(c)
                }
                
            case 1, 2, 3:
                
                let _count = isCoonsPatch ? 16 : 24
                
                while coords.count < _count{
                    guard let d = reader.next(bitsPerCoordinate) else { return }
                    coords.append(d)
                }
                
                while colors.count < numberOfComponents * 2 {
                    guard let c = reader.next(bitsPerComponent) else { return }
                    colors.append(c)
                }
                
            default: return
            }
            
            patch_data.append(PatchData(flag: flag, _coords: coords, _colors: colors))
            reader.clear()
        }
        
        struct Patch {
            
            var m00: Point
            var m01: Point
            var m02: Point
            var m03: Point
            var m10: Point
            var m13: Point
            var m20: Point
            var m23: Point
            var m30: Point
            var m31: Point
            var m32: Point
            var m33: Point
            
            var m11: Point?
            var m12: Point?
            var m21: Point?
            var m22: Point?
            
            var c0: [Double]
            var c1: [Double]
            var c2: [Double]
            var c3: [Double]
            
        }
        
        func draw_patches(_ patches: [Patch]) {
            
            guard !patches.isEmpty else { return }
            
            var points: [Point] = []
            var colors: [AnyColor] = []
            
            for (i, patch) in patches.enumerated() {
                
                if i == 0 {
                    
                    points.append(patch.m00)
                    points.append(patch.m01)
                    points.append(patch.m02)
                    points.append(patch.m03)
                    points.append(patch.m13)
                    points.append(patch.m23)
                    points.append(patch.m33)
                    points.append(patch.m32)
                    points.append(patch.m31)
                    points.append(patch.m30)
                    points.append(patch.m20)
                    points.append(patch.m10)
                    patch.m11.map { points.append($0) }
                    patch.m12.map { points.append($0) }
                    patch.m21.map { points.append($0) }
                    patch.m22.map { points.append($0) }
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c0.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c1.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c2.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c3.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    
                } else if i & 1 == 0 {
                    
                    points.append(patch.m01)
                    points.append(patch.m02)
                    points.append(patch.m03)
                    points.append(patch.m13)
                    points.append(patch.m23)
                    points.append(patch.m33)
                    points.append(patch.m32)
                    points.append(patch.m31)
                    patch.m11.map { points.append($0) }
                    patch.m12.map { points.append($0) }
                    patch.m21.map { points.append($0) }
                    patch.m22.map { points.append($0) }
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c1.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c3.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    
                } else {
                    
                    points.append(patch.m31)
                    points.append(patch.m32)
                    points.append(patch.m33)
                    points.append(patch.m23)
                    points.append(patch.m13)
                    points.append(patch.m03)
                    points.append(patch.m02)
                    points.append(patch.m01)
                    patch.m21.map { points.append($0) }
                    patch.m22.map { points.append($0) }
                    patch.m11.map { points.append($0) }
                    patch.m12.map { points.append($0) }
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c3.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                    colors.append(alphaMask ? AnyColor.white : colorSpace.create_color(patch.c1.map { PDFNumber($0) }, device: context_colorspace) ?? .black)
                }
            }
            
            if isCoonsPatch {
                context.drawMeshGradient(MeshGradient(type: .coonsPatch, column: patches.count, row: 1, points: points, colors: colors))
            } else {
                context.drawMeshGradient(MeshGradient(type: .tensorProduct, column: patches.count, row: 1, points: points, colors: colors))
            }
        }
        
        var patches: [Patch] = []
        var prev_patch: Patch?
        
        for i in 0..<patch_data.count {
            
            var patch_data = patch_data[i]
            patch_data.decode(functions: functions, colorSpace: colorSpace, bitsPerCoordinate: bitsPerCoordinate, bitsPerComponent: bitsPerComponent, decode: decode)
            
            let points = patch_data.coords.chunks(ofCount: 2).map { Point(x: $0.first!, y: $0.last!) }
            let colors = Array(patch_data.colors.chunks(ofCount: colorSpace.numberOfComponents))
            
            switch patch_data.flag {
            
            case 1:
                
                guard var _prev_patch = prev_patch else { return }
                
                _prev_patch = Patch(
                    m00: _prev_patch.m30, m01: _prev_patch.m20, m02: _prev_patch.m10, m03: _prev_patch.m00,
                    m10: _prev_patch.m31, m13: _prev_patch.m01,
                    m20: _prev_patch.m32, m23: _prev_patch.m02,
                    m30: _prev_patch.m33, m31: _prev_patch.m23, m32: _prev_patch.m13, m33: _prev_patch.m03,
                    m11: _prev_patch.m21, m12: _prev_patch.m11,
                    m21: _prev_patch.m22, m22: _prev_patch.m12,
                    c0: _prev_patch.c2, c1: _prev_patch.c0,
                    c2: _prev_patch.c3, c3: _prev_patch.c1)
                
                prev_patch = _prev_patch
                
                if patches.count == 1 {
                    
                    patches[0] = _prev_patch
                    
                } else if patches.count > 1 {
                    
                    draw_patches(patches)
                    patches = []
                }
                
            case 3:
                
                guard var _prev_patch = prev_patch else { return }
                
                _prev_patch = Patch(
                    m00: _prev_patch.m03, m01: _prev_patch.m13, m02: _prev_patch.m23, m03: _prev_patch.m33,
                    m10: _prev_patch.m02, m13: _prev_patch.m32,
                    m20: _prev_patch.m01, m23: _prev_patch.m31,
                    m30: _prev_patch.m00, m31: _prev_patch.m10, m32: _prev_patch.m20, m33: _prev_patch.m30,
                    m11: _prev_patch.m12, m12: _prev_patch.m22,
                    m21: _prev_patch.m11, m22: _prev_patch.m21,
                    c0: _prev_patch.c1, c1: _prev_patch.c3,
                    c2: _prev_patch.c0, c3: _prev_patch.c2)
                
                prev_patch = _prev_patch
                
                if patches.count == 1 {
                    
                    patches[0] = _prev_patch
                    
                } else if patches.count > 1 {
                    
                    draw_patches(patches)
                    patches = []
                }
                
            default: break
            }
            
            switch patch_data.flag {
            
            case 0:
                
                draw_patches(patches)
                
                let patch = Patch(
                    m00: points[3], m01: points[4], m02: points[5], m03: points[6],
                    m10: points[2], m13: points[7],
                    m20: points[1], m23: points[8],
                    m30: points[0], m31: points[11], m32: points[10], m33: points[9],
                    m11: isCoonsPatch ? nil : points[13], m12: isCoonsPatch ? nil : points[14],
                    m21: isCoonsPatch ? nil : points[12], m22: isCoonsPatch ? nil : points[15],
                    c0: Array(colors[1]), c1: Array(colors[2]),
                    c2: Array(colors[0]), c3: Array(colors[3]))
                
                patches = [patch]
                prev_patch = patch
                
            case 1, 2, 3:
                
                guard let _prev_patch = prev_patch else { return }
                
                let patch = Patch(
                    m00: _prev_patch.m33, m01: points[0], m02: points[1], m03: points[2],
                    m10: _prev_patch.m23, m13: points[3],
                    m20: _prev_patch.m13, m23: points[4],
                    m30: _prev_patch.m03, m31: points[7], m32: points[6], m33: points[5],
                    m11: isCoonsPatch ? nil : points[9], m12: isCoonsPatch ? nil : points[10],
                    m21: isCoonsPatch ? nil : points[8], m22: isCoonsPatch ? nil : points[11],
                    c0: _prev_patch.c3, c1: Array(colors[0]),
                    c2: _prev_patch.c1, c3: Array(colors[1]))
                
                patches.append(patch)
                prev_patch = patch
                
            default: break
            }
        }
        
        draw_patches(patches)
    }
}
