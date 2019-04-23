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
        self.clip = context.state.clip
        self.styles = context.styles
    }
    
    func apply(to context: SVGContext) {
        context.state.clip = self.clip
        context.styles = self.styles
    }
}

private struct SVGContextState {
    
    var clip: SVGContext.Clip?
    
    var elements: [SDXMLElement] = []
    
    var visibleBound: Rect?
    
    var defs: [SDXMLElement] = []
    var imageTable: [SVGContext.ImageTableKey: String] = [:]
    
}

public class SVGContext : DrawableContext {
    
    public let viewBox: Rect
    public let resolution: Resolution
    
    fileprivate var state: SVGContextState = SVGContextState()
    fileprivate var styles: SVGContextStyles = SVGContextStyles()
    private var graphicStateStack: [GraphicState] = []
    
    private var next: SVGContext?
    private weak var global: SVGContext?
    
    public init(viewBox: Rect, resolution: Resolution = .default) {
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
    
    fileprivate enum ImageTableKey: Hashable {
        
        case image(AnyImage)
        case data(Data)
        
        init(_ image: AnyImage) {
            self = .image(image)
        }
        
        init(_ data: Data) {
            self = .data(data)
        }
        
        static func ==(lhs: ImageTableKey, rhs: ImageTableKey) -> Bool {
            switch (lhs, rhs) {
            case let (.image(lhs), .image(rhs)): return lhs.isFastEqual(rhs)
            case let (.data(lhs), .data(rhs)): return lhs.isFastEqual(rhs)
            default: return false
            }
        }
    }
}

extension SVGContext {
    
    private var current_layer: SVGContext {
        return next?.current_layer ?? self
    }
    
    private func _clone(global: SVGContext?) -> SVGContext {
        let clone = SVGContext(viewBox: viewBox, resolution: resolution)
        clone.state = self.state
        clone.styles = self.styles
        clone.graphicStateStack = self.graphicStateStack
        clone.next = self.next?._clone(global: global ?? clone)
        clone.global = global
        return clone
    }
    
    public func clone() -> SVGContext {
        return self._clone(global: nil)
    }
    
    public var defs: [SDXMLElement] {
        get {
            return global?.defs ?? state.defs
        }
        set {
            if let global = self.global {
                global.state.defs = newValue
            } else {
                self.state.defs = newValue
            }
        }
    }
    
    public var all_names: Set<String> {
        return Set(defs.compactMap { $0.isNode ? $0.attributes(for: "id", namespace: "") : nil })
    }
    
    public func new_name(_ type: String) -> String {
        
        let all_names = self.all_names
        
        var name = ""
        var counter = 6
        
        let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        repeat {
            let _name = String((0..<counter).map { _ in chars.randomElement()! })
            name = "\(type)_ID_\(_name)"
            counter += 1
        } while all_names.contains(name)
        
        return name
    }
    
    private var imageTable: [ImageTableKey: String] {
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
}

extension SVGContext {
    
    public var opacity: Double {
        get {
            return current_layer.styles.opacity
        }
        set {
            current_layer.styles.opacity = newValue
        }
    }
    
    public var transform: SDTransform {
        get {
            return current_layer.styles.transform
        }
        set {
            current_layer.styles.transform = newValue
        }
    }
    
    public var shadowColor: AnyColor {
        get {
            return current_layer.styles.shadowColor
        }
        set {
            current_layer.styles.shadowColor = newValue
        }
    }
    
    public var shadowOffset: Size {
        get {
            return current_layer.styles.shadowOffset
        }
        set {
            current_layer.styles.shadowOffset = newValue
        }
    }
    
    public var shadowBlur: Double {
        get {
            return current_layer.styles.shadowBlur
        }
        set {
            current_layer.styles.shadowBlur = newValue
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return current_layer.styles.compositingMode
        }
        set {
            current_layer.styles.compositingMode = newValue
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return current_layer.styles.blendMode
        }
        set {
            current_layer.styles.blendMode = newValue
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return current_layer.styles.resamplingAlgorithm
        }
        set {
            current_layer.styles.resamplingAlgorithm = newValue
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return current_layer.styles.renderingIntent
        }
        set {
            current_layer.styles.renderingIntent = newValue
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return current_layer.styles.chromaticAdaptationAlgorithm
        }
        set {
            current_layer.styles.chromaticAdaptationAlgorithm = newValue
        }
    }
}

private func getDataString(_ x: Double ...) -> String {
    return getDataString(x)
}
private func getDataString(_ x: [Double]) -> String {
    return x.map { _decimal_formatter($0) }.joined(separator: " ")
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
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))pt")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))pt")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))pt")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))pt")
            
        case .pica:
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))pc")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))pc")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))pc")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))pc")
            
        case .meter:
            
            let x = resolution.unit.convert(length: x, to: .centimeter)
            let y = resolution.unit.convert(length: y, to: .centimeter)
            let width = resolution.unit.convert(length: width, to: .centimeter)
            let height = resolution.unit.convert(length: height, to: .centimeter)
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))cm")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))cm")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))cm")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))cm")
            
        case .centimeter:
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))cm")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))cm")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))cm")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))cm")
            
        case .millimeter:
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))mm")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))mm")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))mm")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))mm")
            
        case .inch:
            
            body.setAttribute(for: "x", value: "\(_decimal_formatter(x))in")
            body.setAttribute(for: "y", value: "\(_decimal_formatter(y))in")
            body.setAttribute(for: "width", value: "\(_decimal_formatter(width))in")
            body.setAttribute(for: "height", value: "\(_decimal_formatter(height))in")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        body.append(SDXMLElement(comment: " Created by Doggie SVG Generator; \(dateFormatter.string(from: Date())) "))
        
        if defs.count != 0 {
            body.append(SDXMLElement(name: "defs", elements: defs))
        }
        
        body.append(contentsOf: state.elements)
        
        return [body]
    }
}

extension SVGContext {
    
    public func saveGraphicState() {
        graphicStateStack.append(GraphicState(context: current_layer))
    }
    
    public func restoreGraphicState() {
        graphicStateStack.popLast()?.apply(to: current_layer)
    }
}

extension SVGContext {
    
    private func apply_style(_ element: inout SDXMLElement, _ visibleBound: inout Rect, options: StyleOptions) {
        
        var style: [String: String] = self.blendMode == .normal || !options.contains(.isolate) ? [:] : ["isolation": "isolate"]
        
        if let transform = self.transform.attributeStr(), options.contains(.transform) {
            element.setAttribute(for: "transform", value: transform)
        }
        
        if self.opacity < 1 && options.contains(.opacity) {
            element.setAttribute(for: "opacity", value: "\(self.opacity)")
        }
        
        if options.contains(.blendMode) {
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
        }
        
        if options.contains(.clip), let clip = self.current_layer.state.clip {
            switch clip {
            case let .clip(id): element.setAttribute(for: "clip-path", value: "url(#\(id))")
            case let .mask(id): element.setAttribute(for: "mask", value: "url(#\(id))")
            }
        }
        
        if options.contains(.shadow), self.shadowColor.opacity > 0 && self.shadowBlur > 0 {
            
            let id = new_name("SHADOW")
            
            visibleBound = visibleBound.union(visibleBound.inset(dx: -ceil(3 * self.shadowBlur), dy: -ceil(3 * self.shadowBlur)).offset(dx: self.shadowOffset.width, dy: self.shadowOffset.height))
            
            var filter = SDXMLElement(name: "filter", attributes: [
                "id": id,
                "filterUnits": "userSpaceOnUse",
                "x": _decimal_formatter(visibleBound.x),
                "y": _decimal_formatter(visibleBound.y),
                "width": _decimal_formatter(visibleBound.width),
                "height": _decimal_formatter(visibleBound.height),
                ])
            
            let color = self.shadowColor.convert(to: ColorSpace.sRGB, intent: renderingIntent)
            
            let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
            let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
            let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
            
            var shadow = SDXMLElement(name: "feDropShadow", attributes: [
                "dx": _decimal_formatter(self.shadowOffset.width),
                "dy": _decimal_formatter(self.shadowOffset.height),
                "stdDeviation": _decimal_formatter(0.5 * self.shadowBlur),
                "flood-color": "rgb(\(red),\(green),\(blue))",
                ])
            
            if color.opacity < 1 {
                shadow.setAttribute(for: "flood-opacity", value: _decimal_formatter(color.opacity))
            }
            
            filter.append(shadow)
            defs.append(filter)
            
            element.setAttribute(for: "filter", value: "url(#\(id))")
        }
        
        if style.count != 0 {
            var style: [String] = style.map { "\($0): \($1)" }
            if let _style = element.attributes(for: "style", namespace: "") {
                style = _style.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) } + style
            }
            element.setAttribute(for: "style", value: style.joined(separator: "; "))
        }
    }
}

extension SVGContext {
    
    public struct StyleOptions: OptionSet, Hashable {
        
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let isolate           = StyleOptions(rawValue: 1 << 0)
        public static let transform         = StyleOptions(rawValue: 1 << 1)
        public static let opacity           = StyleOptions(rawValue: 1 << 2)
        public static let blendMode         = StyleOptions(rawValue: 1 << 3)
        public static let compositingMode   = StyleOptions(rawValue: 1 << 4)
        public static let shadow            = StyleOptions(rawValue: 1 << 5)
        public static let clip              = StyleOptions(rawValue: 1 << 6)
        
        public static let all: StyleOptions = [.allWithoutTransform, .transform]
        public static let allWithoutTransform: StyleOptions = [.isolate, .opacity, .blendMode, .compositingMode, .shadow, .clip]
    }
    
    private func append(_ newElement: SDXMLElement, _ visibleBound: Rect, options: StyleOptions) {
        var newElement = newElement
        var visibleBound = visibleBound
        self.apply_style(&newElement, &visibleBound, options: options)
        self.current_layer.state.elements.append(newElement)
        self.current_layer.state.visibleBound = self.current_layer.state.visibleBound.map { $0.union(visibleBound) } ?? visibleBound
    }
    
    public func append(_ newElement: SDXMLElement, options: StyleOptions = []) {
        self.append(newElement, self.viewBox, options: options)
    }
    
    public func append<S : Sequence>(contentsOf newElements: S, options: StyleOptions = []) where S.Element == SDXMLElement {
        for newElement in newElements {
            self.append(newElement, options: options)
        }
    }
}

extension SVGContext {
    
    public func beginTransparencyLayer() {
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            self.next = SVGContext(copyStates: self)
            self.next?.global = global ?? self
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                self.next = nil
                
                guard next.state.elements.count != 0 else { return }
                guard let visibleBound = next.state.visibleBound else { return }
                
                self.append(SDXMLElement(name: "g", elements: next.state.elements), visibleBound, options: .allWithoutTransform)
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
        
        switch winding {
        case .nonZero: element.setAttribute(for: "fill-rule", value: "nonzero")
        case .evenOdd: element.setAttribute(for: "fill-rule", value: "evenodd")
        }
        
        element.setAttribute(for: "fill", value: create_color(color))
        
        if color.opacity < 1 {
            element.setAttribute(for: "fill-opacity", value: "\(color.opacity)")
        }
        
        self.append(element, shape.boundary, options: .allWithoutTransform)
    }
}

private protocol SVGImageProtocol {
    
    var width: Int { get }
    var height: Int { get }
    
    var imageTableKey: SVGContext.ImageTableKey { get }
    
    func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String?
}

extension ImageRep.MediaType {
    
    fileprivate var svg_base64_string: String {
        switch self {
        case .bmp: return "image/bmp"
        case .gif: return "image/gif"
        case .jpeg: return "image/jpeg"
        case .jpeg2000: return "image/jp2"
        case .png: return "image/png"
        case .tiff: return "image/tiff"
        }
    }
}

extension Image: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return SVGContext.ImageTableKey(AnyImage(self))
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(storageType.svg_base64_string);base64," + data.base64EncodedString()
    }
}

extension AnyImage: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return SVGContext.ImageTableKey(self)
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(storageType.svg_base64_string);base64," + data.base64EncodedString()
    }
}

extension ImageRep: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return self.originalData.map { SVGContext.ImageTableKey($0) } ?? SVGContext.ImageTableKey(AnyImage(imageRep: self, fileBacked: true))
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = self.mediaType, let data = self.originalData else { return AnyImage(imageRep: self, fileBacked: true).base64(using: storageType, properties: properties) }
        return "data:\(mediaType.svg_base64_string);base64," + data.base64EncodedString()
    }
}

extension SVGContext {
    
    private func _draw(image: SVGImageProtocol, transform: SDTransform, using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) {
        
        self.beginTransparencyLayer()
        defer { self.endTransparencyLayer() }
        
        let key = image.imageTableKey
        
        let id: String
        
        if let _id = imageTable[key] {
            
            id = _id
            
        } else {
            
            id = new_name("IMAGE")
            
            var _image = SDXMLElement(name: "image", attributes: [
                "id": id,
                "width": "\(image.width)",
                "height": "\(image.height)",
                ])
            
            guard let base64 = image.base64(using: storageType, properties: properties) else { return }
            _image.setAttribute(for: "href", namespace: "http://www.w3.org/1999/xlink", value: base64)
            
            defs.append(_image)
            
            imageTable[key] = id
        }
        
        var element = SDXMLElement(name: "use")
        
        element.setAttribute(for: "href", namespace: "http://www.w3.org/1999/xlink", value: "#\(id)")
        
        let transform = transform * self.transform
        element.setAttribute(for: "transform", value: transform.attributeStr())
        
        let _bound = Rect.bound(Rect(x: 0, y: 0, width: image.width, height: image.height).points.map { $0 * transform })
        self.append(element, _bound, options: .allWithoutTransform)
    }
    
    public func draw<Image : ImageProtocol>(image: Image, transform: SDTransform, using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) {
        let image = image as? SVGImageProtocol ?? image.convert(to: .sRGB, intent: renderingIntent) as Doggie.Image<ARGB32ColorPixel>
        self._draw(image: image, transform: transform, using: storageType, properties: properties)
    }
    
    public func draw<Image : ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(image: image, transform: transform, using: .png, properties: [:])
    }
    
    public func draw(image: ImageRep, transform: SDTransform, using storageType: ImageRep.MediaType = .png, properties: [ImageRep.PropertyKey : Any] = [:]) {
        self._draw(image: image, transform: transform, using: storageType, properties: properties)
    }
}

extension SVGContext {
    
    public func resetClip() {
        current_layer.state.clip = nil
    }
    
    public func clip(shape: Shape, winding: Shape.WindingRule) {
        
        guard shape.reduce(0, { $0 + $1.count }) != 0 else {
            current_layer.state.clip = nil
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
        
        current_layer.state.clip = .clip(id)
    }
    
    public func drawClip(body: (DrawableContext) throws -> Void) rethrows {
        try self.drawClip { (context: SVGContext) in try body(context) }
    }
    
    public func drawClip(body: (SVGContext) throws -> Void) rethrows {
        
        let mask_context = SVGContext(copyStates: current_layer)
        mask_context.global = global ?? self
        
        try body(mask_context)
        
        let id = new_name("MASK")
        
        let mask = SDXMLElement(name: "mask", attributes: ["id": id], elements: mask_context.state.elements)
        
        defs.append(mask)
        
        current_layer.state.clip = .mask(id)
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
                "x1": _decimal_formatter(gradient.start.x),
                "y1": _decimal_formatter(gradient.start.y),
                "x2": _decimal_formatter(gradient.end.x),
                "y2": _decimal_formatter(gradient.end.y),
                ])
            
            element.setAttribute(for: "gradientTransform", value: gradient.transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: _decimal_formatter(stop.offset))
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: _decimal_formatter(stop.color.opacity))
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
                "fx": _decimal_formatter(0.5 + magnitude),
                "fy": "0.5",
                "cx": "0.5",
                "cy": "0.5",
                ])
            
            let transform = SDTransform.translate(x: -0.5, y: -0.5) * SDTransform.rotate(phase) * SDTransform.translate(x: gradient.end.x, y: gradient.end.y) * gradient.transform
            element.setAttribute(for: "gradientTransform", value: transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: _decimal_formatter(stop.offset))
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: _decimal_formatter(stop.color.opacity))
                }
                element.append(_stop)
            }
            
            defs.append(element)
        }
        
        return "url(#\(id))"
    }
    
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>) {
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let shape = shape * self.transform
        var element = SDXMLElement(name: "path", attributes: ["d": shape.identity.encode()])
        
        switch winding {
        case .nonZero: element.setAttribute(for: "fill-rule", value: "nonzero")
        case .evenOdd: element.setAttribute(for: "fill-rule", value: "evenodd")
        }
        
        element.setAttribute(for: "fill", value: create_gradient(gradient))
        
        if gradient.opacity < 1 {
            element.setAttribute(for: "fill-opacity", value: "\(gradient.opacity)")
        }
        
        self.append(element, shape.boundary, options: .allWithoutTransform)
    }
}

extension SVGContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        guard startSpread == endSpread else { return }
        self.drawLinearGradient(stops: stops, start: start, end: end, spreadMethod: startSpread)
    }
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, spreadMethod: GradientSpreadMode) {
        
        let id = new_name("GRADIENT")
        
        var element = SDXMLElement(name: "linearGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "x1": _decimal_formatter(start.x),
            "y1": _decimal_formatter(start.y),
            "x2": _decimal_formatter(end.x),
            "y2": _decimal_formatter(end.y),
            ])
        
        switch spreadMethod {
        case .reflect: element.setAttribute(for: "spreadMethod", value: "reflect")
        case .repeat: element.setAttribute(for: "spreadMethod", value: "repeat")
        default: break
        }
        
        element.setAttribute(for: "gradientTransform", value: self.transform.attributeStr())
        
        for (_, stop) in stops.indexed().sorted(by: { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }) {
            var _stop = SDXMLElement(name: "stop")
            _stop.setAttribute(for: "offset", value: _decimal_formatter(stop.offset))
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: _decimal_formatter(stop.color.opacity))
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        let rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": _decimal_formatter(viewBox.x),
            "y": _decimal_formatter(viewBox.y),
            "width": _decimal_formatter(viewBox.width),
            "height": _decimal_formatter(viewBox.height),
            ])
        
        self.append(rect, self.viewBox, options: .allWithoutTransform)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        guard startSpread == endSpread else { return }
        self.drawRadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, spreadMethod: startSpread)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, spreadMethod: GradientSpreadMode) {
        
        let id = new_name("GRADIENT")
        
        let magnitude = (start - end).magnitude
        let phase = (start - end).phase
        
        var element = SDXMLElement(name: "radialGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "fx": _decimal_formatter(0.5 + magnitude),
            "fy": "0.5",
            "cx": "0.5",
            "cy": "0.5",
            "fr": _decimal_formatter(startRadius),
            "r": _decimal_formatter(endRadius),
            ])
        
        switch spreadMethod {
        case .reflect: element.setAttribute(for: "spreadMethod", value: "reflect")
        case .repeat: element.setAttribute(for: "spreadMethod", value: "repeat")
        default: break
        }
        
        let transform = SDTransform.translate(x: -0.5, y: -0.5) * SDTransform.rotate(phase) * SDTransform.translate(x: end.x, y: end.y) * self.transform
        element.setAttribute(for: "gradientTransform", value: transform.attributeStr())
        
        for (_, stop) in stops.indexed().sorted(by: { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }) {
            var _stop = SDXMLElement(name: "stop")
            _stop.setAttribute(for: "offset", value: _decimal_formatter(stop.offset))
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: _decimal_formatter(stop.color.opacity))
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        let rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": _decimal_formatter(viewBox.x),
            "y": _decimal_formatter(viewBox.y),
            "width": _decimal_formatter(viewBox.width),
            "height": _decimal_formatter(viewBox.height),
            ])
        
        self.append(rect, self.viewBox, options: .allWithoutTransform)
    }
}

