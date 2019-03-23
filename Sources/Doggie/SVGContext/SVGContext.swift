//
//  SVGContext.swift
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

private struct SVGContextStyles {
    
    static let defaultShadowColor = AnyColor(colorSpace: .default, white: 0.0, opacity: 1.0 / 3.0)
    
    var opacity: Double = 1
    var transform: SDTransform = SDTransform.identity
    
    var shadowColor: AnyColor = SVGContextStyles.defaultShadowColor
    var shadowOffset: Size = Size()
    var shadowBlur: Double = 0
    
    var compositingMode: ColorCompositingMode = .default
    var blendMode: ColorBlendMode = .default
    
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    
    var renderingIntent: RenderingIntent = .default
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm = .default
}

private struct GraphicState {
    
    var clip: SVGContext.Clip?
    
    var styles: SVGContextStyles
    
    init(context: SVGContext) {
        self.clip = context.clip
        self.styles = context.styles
    }
    
    func apply(to context: SVGContext) {
        context.clip = self.clip
        context.styles = self.styles
    }
}

public class SVGContext : DrawableContext {
    
    fileprivate var clip: Clip?
    
    fileprivate var styles: SVGContextStyles
    
    private var next: SVGContext?
    private weak var global: SVGContext?
    
    private var graphicStateStack: [GraphicState] = []
    
    private var elements: [SDXMLElement] = []
    
    private var _defs: [SDXMLElement] = []
    public private(set) var all_names: Set<String> = []
    
    public let viewBox: Rect
    
    public let resolution: Resolution
    
    public init(viewBox: Rect, resolution: Resolution = .default) {
        self.clip = nil
        self.styles = SVGContextStyles()
        self.viewBox = viewBox
        self.resolution = resolution
    }
}

extension SVGContext {
    
    public convenience init(width: Double, height: Double, unit: Resolution.Unit = .point) {
        let _width = unit.convert(length: width, to: .point)
        let _height = unit.convert(length: height, to: .point)
        self.init(viewBox: Rect(x: 0, y: 0, width: _width, height: _height), resolution: Resolution.default.convert(to: unit))
    }
}

extension SVGContext {
    
    private convenience init(copyStates context: SVGContext) {
        self.init(viewBox: context.viewBox, resolution: context.resolution)
        self.styles = context.styles
        self.styles.opacity = 1
        self.styles.shadowColor = SVGContextStyles.defaultShadowColor
        self.styles.shadowOffset = Size()
        self.styles.shadowBlur = 0
        self.styles.compositingMode = .default
        self.styles.blendMode = .default
    }
}

extension SVGContext {
    
    fileprivate enum Clip {
        case clip(String)
        case mask(String)
    }
}

extension SVGContext {
    
    private var current: SVGContext {
        return next ?? self
    }
    
    private var defs: [SDXMLElement] {
        get {
            return global?.defs ?? _defs
        }
        set {
            if let global = self.global {
                global._defs = newValue
            } else {
                self._defs = newValue
            }
        }
    }
    
    private func new_name(_ type: String) -> String {
        
        if let global = self.global {
            return global.new_name(type)
        }
        
        var name = ""
        var counter = 6
        
        let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        repeat {
            let _name = String((0..<counter).map { _ in chars.randomElement()! })
            name = "\(type)_ID_\(_name)"
            counter += 1
        } while all_names.contains(name)
        
        all_names.insert(name)
        
        return name
    }
}

extension SVGContext {
    
    public var opacity: Double {
        get {
            return current.styles.opacity
        }
        set {
            current.styles.opacity = newValue
        }
    }
    
    public var transform: SDTransform {
        get {
            return current.styles.transform
        }
        set {
            current.styles.transform = newValue
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current.styles.shadowColor
        }
        set {
            current.styles.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current.styles.shadowOffset
        }
        set {
            current.styles.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current.styles.shadowBlur
        }
        set {
            current.styles.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current.styles.compositingMode
        }
        set {
            current.styles.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current.styles.blendMode
        }
        set {
            current.styles.blendMode = newValue
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current.styles.resamplingAlgorithm
        }
        set {
            current.styles.resamplingAlgorithm = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current.styles.renderingIntent
        }
        set {
            current.styles.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current.styles.chromaticAdaptationAlgorithm
        }
        set {
            current.styles.chromaticAdaptationAlgorithm = newValue
        }
    }
}

private let dataFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.negativeFormat = "#.#########"
    formatter.positiveFormat = "#.#########"
    return formatter
}()

private func getDataString(_ x: Double ...) -> String {
    return getDataString(x)
}
private func getDataString(_ x: [Double]) -> String {
    return x.map { dataFormatter.string(from: NSNumber(value: $0)) ?? "0" }.map { $0 == "-0" ? "0" : $0 }.joined(separator: " ")
}

extension SDTransform {
    
    fileprivate func attributeStr() -> String? {
        let transformStr = getDataString(a, d, b, e, c, f)
        if transformStr == "1 0 0 1 0 0" {
            return nil
        }
        return "matrix(\(transformStr))"
    }
}

extension SVGContext {
    
    public var document: SDXMLDocument {
        
        var body = SDXMLElement(name: "svg", attributes: [
            "xmlns": "http://www.w3.org/2000/svg",
            "xmlns:xlink": "http://www.w3.org/1999/xlink",
            "xmlns:a": "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/",
            "style": "isolation: isolate;"
            ])
        
        body.setAttribute(for: "viewBox", value: getDataString(viewBox.x, viewBox.y, viewBox.width, viewBox.height))
        
        let x = viewBox.x / resolution.horizontal
        let y = viewBox.y / resolution.vertical
        let width = viewBox.width / resolution.horizontal
        let height = viewBox.height / resolution.vertical
        
        switch resolution.unit {
        case .point:
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")pt")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")pt")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")pt")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")pt")
            
        case .pica:
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")pc")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")pc")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")pc")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")pc")
            
        case .meter:
            
            let x = resolution.unit.convert(length: x, to: .centimeter)
            let y = resolution.unit.convert(length: y, to: .centimeter)
            let width = resolution.unit.convert(length: width, to: .centimeter)
            let height = resolution.unit.convert(length: height, to: .centimeter)
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")cm")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")cm")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")cm")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")cm")
            
        case .centimeter:
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")cm")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")cm")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")cm")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")cm")
            
        case .millimeter:
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")mm")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")mm")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")mm")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")mm")
            
        case .inch:
            
            body.setAttribute(for: "x", value: "\(dataFormatter.string(from: NSNumber(value: x)) ?? "0")in")
            body.setAttribute(for: "y", value: "\(dataFormatter.string(from: NSNumber(value: y)) ?? "0")in")
            body.setAttribute(for: "width", value: "\(dataFormatter.string(from: NSNumber(value: width)) ?? "0")in")
            body.setAttribute(for: "height", value: "\(dataFormatter.string(from: NSNumber(value: height)) ?? "0")in")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        body.append(SDXMLElement(comment: " Created by Doggie SVG Generator; \(dateFormatter.string(from: Date())) "))
        
        if defs.count != 0 {
            body.append(SDXMLElement(name: "defs", elements: defs))
        }
        
        body.append(contentsOf: elements)
        
        return [body]
    }
}

extension SVGContext {
    
    private var currentGraphicState: GraphicState {
        return next?.currentGraphicState ?? GraphicState(context: self)
    }
    
    public func saveGraphicState() {
        graphicStateStack.append(currentGraphicState)
    }
    
    public func restoreGraphicState() {
        if let next = self.next {
            graphicStateStack.popLast()?.apply(to: next)
        } else {
            graphicStateStack.popLast()?.apply(to: self)
        }
    }
}

extension SVGContext {
    
    private func apply_style(_ element: inout SDXMLElement) {
        
        var style: [String: String] = self.blendMode == .normal ? [:] : ["isolation": "isolate"]
        
        if self.opacity < 1 {
            element.setAttribute(for: "opacity", value: "\(self.opacity)")
        }
        
        switch self.blendMode {
        case .normal: break
        case .multiply:
            style["mix-blend-mode"] = "multiply"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "multiply")
        case .screen:
            style["mix-blend-mode"] = "screen"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "screen")
        case .overlay:
            style["mix-blend-mode"] = "overlay"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "overlay")
        case .darken:
            style["mix-blend-mode"] = "darken"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "darken")
        case .lighten:
            style["mix-blend-mode"] = "lighten"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "lighten")
        case .colorDodge:
            style["mix-blend-mode"] = "color-dodge"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "colorDodge")
        case .colorBurn:
            style["mix-blend-mode"] = "color-burn"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "colorBurn")
        case .softLight:
            style["mix-blend-mode"] = "soft-light"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "softLight")
        case .hardLight:
            style["mix-blend-mode"] = "hard-light"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "hardLight")
        case .difference:
            style["mix-blend-mode"] = "difference"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "difference")
        case .exclusion:
            style["mix-blend-mode"] = "exclusion"
            element.setAttribute(for: "adobe-blending-mode", namespace: "http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/", value: "exclusion")
        default: break
        }
        
        if style.count != 0 {
            element.setAttribute(for: "style", value: style.map { "\($0): \($1)" }.joined(separator: "; "))
        }
        
        if let clip = self.current.clip {
            
            switch clip {
            case let .clip(id): element.setAttribute(for: "clip-path", value: "url(#\(id))")
            case let .mask(id): element.setAttribute(for: "mask", value: "url(#\(id))")
            }
        }
    }
}

extension SVGContext {
    
    public func append(_ newElement: SDXMLElement) {
        self.current.elements.append(newElement)
    }
    
    public func append<S : Sequence>(contentsOf newElements: S) where S.Element == SDXMLElement {
        self.current.elements.append(contentsOf: newElements)
    }
}

extension SVGContext {
    
    public func beginTransparencyLayer() {
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            self.next = SVGContext(copyStates: self)
            self.next?.global = self
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                self.next = nil
                
                guard next.elements.count != 0 else { return }
                
                var element = SDXMLElement(name: "g", elements: next.elements)
                
                self.apply_style(&element)
                
                self.append(element)
            }
        }
    }
}

extension SVGContext {
    
    private func create_color<C : ColorProtocol>(_ color: C) -> String {
        
        var color = color.convert(to: ColorSpace.sRGB, intent: renderingIntent)
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        return "rgb(\(red),\(green),\(blue))"
    }
    
    public func draw<C : ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        let shape = shape * self.transform
        var element = SDXMLElement(name: "path", attributes: ["d": shape.identity.encode()])
        
        self.apply_style(&element)
        
        switch winding {
        case .nonZero: element.setAttribute(for: "fill-rule", value: "nonzero")
        case .evenOdd: element.setAttribute(for: "fill-rule", value: "evenodd")
        }
        
        element.setAttribute(for: "fill", value: create_color(color))
        
        if color.opacity < 1 {
            element.setAttribute(for: "fill-opacity", value: "\(color.opacity)")
        }
        
        self.append(element)
    }
}

private protocol SVGImageProtocol {
    
    var base64: String? { get }
}

extension Image: SVGImageProtocol {
    
    fileprivate var base64: String? {
        guard let base64 = self.pngRepresentation()?.base64EncodedString() else { return nil }
        return "data:image/png;base64," + base64
    }
}

extension AnyImage: SVGImageProtocol {
    
    fileprivate var base64: String? {
        guard let base64 = self.pngRepresentation()?.base64EncodedString() else { return nil }
        return "data:image/png;base64," + base64
    }
}

extension SVGContext {
    
    public func draw<Image>(image: Image, transform: SDTransform) where Image : ImageProtocol {
        
        let base64: String
        
        if let image = image as? SVGImageProtocol {
            
            guard let _base64 = image.base64 else { return }
            base64 = _base64
            
        } else {
            
            let _image = image.convert(to: .sRGB, intent: renderingIntent) as Doggie.Image<ARGB32ColorPixel>
            guard let _base64 = _image.pngRepresentation()?.base64EncodedString() else { return }
            base64 = "data:image/png;base64," + _base64
        }
        
        var element = SDXMLElement(name: "image", attributes: [
            "width": "\(image.width)",
            "height": "\(image.height)",
            "xlink:href": base64,
            ])
        
        let transform = transform * self.transform
        element.setAttribute(for: "transform", value: transform.attributeStr())
        
        self.apply_style(&element)
        
        self.append(element)
    }
}

extension SVGContext {
    
    public func resetClip() {
        current.clip = nil
    }
    
    public func setClip(shape: Shape, winding: Shape.WindingRule) {
        
        guard shape.count != 0 else {
            current.clip = nil
            return
        }
        
        let id = new_name("CLIP")
        
        let clipRule: String
        
        switch winding {
        case .nonZero: clipRule = "nonzero"
        case .evenOdd: clipRule = "evenodd"
        }
        
        let shape = shape * self.transform
        let clipPath = SDXMLElement(name: "clipPath", attributes: ["id": id], elements: [SDXMLElement(name: "path", attributes: ["d": shape.identity.encode(), "clip-rule": clipRule])])
        
        defs.append(clipPath)
        
        current.clip = .clip(id)
    }
    
    public func drawClip(body: (SVGContext) throws -> Void) rethrows {
        
        let mask_context = SVGContext(copyStates: self)
        mask_context.global = self
        
        try body(mask_context)
        
        let id = new_name("MASK")
        
        let mask = SDXMLElement(name: "mask", attributes: ["id": id], elements: mask_context.elements)
        
        defs.append(mask)
        
        current.clip = .mask(id)
    }
}

extension SVGContext {
    
    public func setClip<Image>(image: Image, transform: SDTransform) where Image : ImageProtocol {
        self.drawClip { context in context.draw(image: image, transform: transform) }
    }
    
    public func setClip<P>(texture: Texture<P>, transform: SDTransform) where P : ColorPixelProtocol, P.Model == GrayColorModel {
        let image = Image(texture: texture, colorSpace: .genericGamma22Gray)
        self.setClip(image: image, transform: transform)
    }
}

extension SVGContext {
    
    private func create_gradient<C>(_ gradient: Gradient<C>) -> String {
        
        let id = new_name("GRADIENT")
        
        switch gradient.type {
        case .linear:
            
            var element = SDXMLElement(name: "linearGradient", attributes: [
                "id": id,
                "gradientUnits": "objectBoundingBox",
                "x1": dataFormatter.string(from: NSNumber(value: gradient.start.x)) ?? "0",
                "y1": dataFormatter.string(from: NSNumber(value: gradient.start.y)) ?? "0",
                "x2": dataFormatter.string(from: NSNumber(value: gradient.end.x)) ?? "0",
                "y2": dataFormatter.string(from: NSNumber(value: gradient.end.y)) ?? "0",
                ])
            
            element.setAttribute(for: "gradientTransform", value: gradient.transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: dataFormatter.string(from: NSNumber(value: stop.offset)) ?? "0")
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: dataFormatter.string(from: NSNumber(value: stop.color.opacity)) ?? "0")
                }
                element.append(_stop)
            }
            
            defs.append(element)
            
        case .radial:
            
            let magnitude = (gradient.start - gradient.end).magnitude
            let phase = (gradient.start - gradient.end).phase
            
            var element = SDXMLElement(name: "radialGradient", attributes: [
                "id": id,
                "gradientUnits": "objectBoundingBox",
                "fx": dataFormatter.string(from: NSNumber(value: 0.5 + magnitude)) ?? "0.5",
                "fy": "0.5",
                "cx": "0.5",
                "cy": "0.5",
                ])
            
            let transform = SDTransform.translate(x: -0.5, y: -0.5) * SDTransform.rotate(phase) * SDTransform.translate(x: gradient.end.x, y: gradient.end.y) * gradient.transform
            element.setAttribute(for: "gradientTransform", value: transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: dataFormatter.string(from: NSNumber(value: stop.offset)) ?? "0")
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: dataFormatter.string(from: NSNumber(value: stop.color.opacity)) ?? "0")
                }
                element.append(_stop)
            }
            
            defs.append(element)
        }
        
        return "url(#\(id))"
    }
    
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>) {
        
        let shape = shape * self.transform
        var element = SDXMLElement(name: "path", attributes: ["d": shape.identity.encode()])
        
        self.apply_style(&element)
        
        switch winding {
        case .nonZero: element.setAttribute(for: "fill-rule", value: "nonzero")
        case .evenOdd: element.setAttribute(for: "fill-rule", value: "evenodd")
        }
        
        element.setAttribute(for: "fill", value: create_gradient(gradient))
        
        if gradient.opacity < 1 {
            element.setAttribute(for: "fill-opacity", value: "\(gradient.opacity)")
        }
        
        self.append(element)
    }
}

extension SVGContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        guard startSpread == endSpread else { return }
        self.drawLinearGradient(stops: stops, start: start, end: end, spreadMethod: startSpread)
    }
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, spreadMethod: GradientSpreadMode) where C : ColorProtocol {
        
        let id = new_name("GRADIENT")
        
        var element = SDXMLElement(name: "linearGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "x1": dataFormatter.string(from: NSNumber(value: start.x)) ?? "0",
            "y1": dataFormatter.string(from: NSNumber(value: start.y)) ?? "0",
            "x2": dataFormatter.string(from: NSNumber(value: end.x)) ?? "0",
            "y2": dataFormatter.string(from: NSNumber(value: end.y)) ?? "0",
            ])
        
        switch spreadMethod {
        case .reflect: element.setAttribute(for: "spreadMethod", value: "reflect")
        case .repeat: element.setAttribute(for: "spreadMethod", value: "repeat")
        default: break
        }
        
        element.setAttribute(for: "gradientTransform", value: self.transform.attributeStr())
        
        for stop in stops {
            var _stop = SDXMLElement(name: "stop")
            _stop.setAttribute(for: "offset", value: dataFormatter.string(from: NSNumber(value: stop.offset)) ?? "0")
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: dataFormatter.string(from: NSNumber(value: stop.color.opacity)) ?? "0")
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        var rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": dataFormatter.string(from: NSNumber(value: viewBox.x)) ?? "0",
            "y": dataFormatter.string(from: NSNumber(value: viewBox.y)) ?? "0",
            "width": dataFormatter.string(from: NSNumber(value: viewBox.width)) ?? "0",
            "height": dataFormatter.string(from: NSNumber(value: viewBox.height)) ?? "0",
            ])
        
        self.apply_style(&rect)
        
        self.append(rect)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorProtocol {
        guard startSpread == endSpread else { return }
        self.drawRadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, spreadMethod: startSpread)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, spreadMethod: GradientSpreadMode) where C : ColorProtocol {
        
        let id = new_name("GRADIENT")
        
        let magnitude = (start - end).magnitude
        let phase = (start - end).phase
        
        var element = SDXMLElement(name: "radialGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "fx": dataFormatter.string(from: NSNumber(value: 0.5 + magnitude)) ?? "0.5",
            "fy": "0.5",
            "cx": "0.5",
            "cy": "0.5",
            "fr": dataFormatter.string(from: NSNumber(value: startRadius)) ?? "0",
            "r": dataFormatter.string(from: NSNumber(value: endRadius)) ?? "1",
            ])
        
        switch spreadMethod {
        case .reflect: element.setAttribute(for: "spreadMethod", value: "reflect")
        case .repeat: element.setAttribute(for: "spreadMethod", value: "repeat")
        default: break
        }
        
        let transform = SDTransform.translate(x: -0.5, y: -0.5) * SDTransform.rotate(phase) * SDTransform.translate(x: end.x, y: end.y) * self.transform
        element.setAttribute(for: "gradientTransform", value: transform.attributeStr())
        
        for stop in stops {
            var _stop = SDXMLElement(name: "stop")
            _stop.setAttribute(for: "offset", value: dataFormatter.string(from: NSNumber(value: stop.offset)) ?? "0")
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: dataFormatter.string(from: NSNumber(value: stop.color.opacity)) ?? "0")
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        var rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": dataFormatter.string(from: NSNumber(value: viewBox.x)) ?? "0",
            "y": dataFormatter.string(from: NSNumber(value: viewBox.y)) ?? "0",
            "width": dataFormatter.string(from: NSNumber(value: viewBox.width)) ?? "0",
            "height": dataFormatter.string(from: NSNumber(value: viewBox.height)) ?? "0",
            ])
        
        self.apply_style(&rect)
        
        self.append(rect)
    }
}

