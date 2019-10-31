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
    
    var effect: SVGEffect = SVGEffect()
    
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
    var objectBound: Shape?
    
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
        self.styles.effect = SVGEffect()
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
            case let (.image(lhs), .image(rhs)): return lhs.isStorageEqual(rhs)
            case let (.data(lhs), .data(rhs)): return lhs.isStorageEqual(rhs)
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
    
    public var effect: SVGEffect {
        get {
            return current_layer.styles.effect
        }
        set {
            current_layer.styles.effect = newValue
        }
    }
}

private func getDataString(_ x: Double ...) -> String {
    return getDataString(x)
}
private func getDataString(_ x: [Double]) -> String {
    return x.map { "\(Decimal($0).rounded(scale: 9))" }.joined(separator: " ")
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
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))pt")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))pt")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))pt")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))pt")
            
        case .pica:
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))pc")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))pc")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))pc")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))pc")
            
        case .meter:
            
            let x = resolution.unit.convert(length: x, to: .centimeter)
            let y = resolution.unit.convert(length: y, to: .centimeter)
            let width = resolution.unit.convert(length: width, to: .centimeter)
            let height = resolution.unit.convert(length: height, to: .centimeter)
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))cm")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))cm")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))cm")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))cm")
            
        case .centimeter:
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))cm")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))cm")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))cm")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))cm")
            
        case .millimeter:
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))mm")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))mm")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))mm")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))mm")
            
        case .inch:
            
            body.setAttribute(for: "x", value: "\(Decimal(x).rounded(scale: 9))in")
            body.setAttribute(for: "y", value: "\(Decimal(y).rounded(scale: 9))in")
            body.setAttribute(for: "width", value: "\(Decimal(width).rounded(scale: 9))in")
            body.setAttribute(for: "height", value: "\(Decimal(height).rounded(scale: 9))in")
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
    
    private func apply_style(_ element: inout SDXMLElement, _ visibleBound: inout Rect, _ objectBound: Shape, _ object_transform: SDTransform) {
        
        var style: [String: String] = self.blendMode == .normal ? [:] : ["isolation": "isolate"]
        
        let _objectBound = objectBound.boundary
        
        if self.effect.output != nil && _objectBound.width != 0 && _objectBound.height != 0 {
            
            let _transform = self.transform.inverse
            var _visibleBound = Rect.bound(visibleBound.points.map { $0 * _transform })
            
            if let filter = self._effect_element("FILTER", self.effect, &_visibleBound, (objectBound * _transform).boundary) {
                
                visibleBound = Rect.bound(_visibleBound.points.map { $0 * transform })
                
                element.setAttribute(for: "transform", value: (object_transform * _transform).attributeStr())
                element = SDXMLElement(name: "g", elements: [element])
                
                element.setAttribute(for: "filter", value: "url(#\(filter))")
                element.setAttribute(for: "transform", value: self.transform.attributeStr())
            }
        }
        
        if self.shadowColor.opacity > 0 && self.shadowBlur > 0 && _objectBound.width != 0 && _objectBound.height != 0 {
            
            if !element.attributes(for: "transform").isEmpty {
                element = SDXMLElement(name: "g", elements: [element])
            }
            
            let gaussian_blur_uuid = UUID()
            let offset_uuid = UUID()
            let flood_uuid = UUID()
            let blend_uuid = UUID()
            
            var effect: SVGEffect = [
                gaussian_blur_uuid: SVGGaussianBlurEffect(source: .sourceAlpha, stdDeviation: 0.5 * self.shadowBlur),
                offset_uuid: SVGOffsetEffect(source: .reference(gaussian_blur_uuid), offset: self.shadowOffset),
                flood_uuid: SVGFloodEffect(color: self.shadowColor),
                blend_uuid: SVGBlendEffect(source: .reference(flood_uuid), source2: .reference(offset_uuid), mode: .in),
            ]
            
            effect.output = SVGMergeEffect(sources: [.reference(blend_uuid), .source])
            
            if let filter = self._effect_element("SHADOW", effect, &visibleBound, _objectBound) {
                element.setAttribute(for: "filter", value: "url(#\(filter))")
            }
        }
        
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
        
        if let clip = self.current_layer.state.clip {
            switch clip {
            case let .clip(id): element.setAttribute(for: "clip-path", value: "url(#\(id))")
            case let .mask(id): element.setAttribute(for: "mask", value: "url(#\(id))")
            }
        }
        
        if style.count != 0 {
            var style: [String] = style.map { "\($0): \($1)" }
            if let _style = element.attributes(for: "style", namespace: "") {
                style = _style.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) } + style
            }
            element.setAttribute(for: "style", value: style.joined(separator: "; "))
        }
    }
    
    private func append(_ newElement: SDXMLElement, _ visibleBound: Rect, _ objectBound: Shape, _ object_transform: SDTransform) {
        guard !self.transform.determinant.almostZero() else { return }
        var newElement = newElement
        var visibleBound = visibleBound
        self.apply_style(&newElement, &visibleBound, objectBound, object_transform)
        self.current_layer.state.elements.append(newElement)
        self.current_layer.state.visibleBound = self.current_layer.state.visibleBound.map { $0.union(visibleBound) } ?? visibleBound
        self.current_layer.state.objectBound = self.current_layer.state.objectBound.map { $0.identity + objectBound.identity } ?? objectBound
    }
    
    private func append(_ newElement: SDXMLElement, _ objectBound: Shape, _ object_transform: SDTransform) {
        self.append(newElement, objectBound.boundary, objectBound, object_transform)
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
                guard let objectBound = next.state.objectBound else { return }
                
                self.append(SDXMLElement(name: "g", elements: next.state.elements), visibleBound, objectBound, .identity)
            }
        }
    }
}

extension SVGContext {
    
    private func create_color<C : ColorProtocol>(_ color: C) -> String {
        
        let color = color.convert(to: ColorSpace.sRGB, intent: renderingIntent)
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        return "rgb(\(red),\(green),\(blue))"
    }
    
    public func draw<C : ColorProtocol>(shape: Shape, winding: Shape.WindingRule, color: C) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
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
        
        self.append(element, shape, .identity)
    }
}

private protocol SVGImageProtocol {
    
    var width: Int { get }
    var height: Int { get }
    
    var imageTableKey: SVGContext.ImageTableKey { get }
    
    func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String?
}

extension ImageRep.MediaType {
    
    fileprivate var media_type_string: String? {
        switch self {
        case .bmp: return "image/bmp"
        case .gif: return "image/gif"
        case .heic: return "image/heic"
        case .heif: return "image/heif"
        case .jpeg: return "image/jpeg"
        case .jpeg2000: return "image/jp2"
        case .png: return "image/png"
        case .tiff: return "image/tiff"
        default: return nil
        }
    }
}

extension Image: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return SVGContext.ImageTableKey(AnyImage(self))
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = storageType.media_type_string else { return nil }
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension AnyImage: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return SVGContext.ImageTableKey(self)
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = storageType.media_type_string else { return nil }
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension ImageRep: SVGImageProtocol {
    
    fileprivate var imageTableKey: SVGContext.ImageTableKey {
        return self.originalData.map { SVGContext.ImageTableKey($0) } ?? SVGContext.ImageTableKey(AnyImage(imageRep: self, fileBacked: true))
    }
    
    fileprivate func base64(using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = self.mediaType?.media_type_string else { return nil }
        guard let data = self.originalData else { return AnyImage(imageRep: self, fileBacked: true).base64(using: storageType, properties: properties) }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension SVGContext {
    
    private func _draw(image: SVGImageProtocol, transform: SDTransform, using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
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
        
        let _bound = Shape(rect: Rect(x: 0, y: 0, width: image.width, height: image.height)) * transform
        self.append(element, _bound, transform)
    }
    
    public func draw<Image : ImageProtocol>(image: Image, transform: SDTransform, using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) {
        let image = image as? SVGImageProtocol ?? image.convert(to: .sRGB, intent: renderingIntent) as Doggie.Image<ARGB32ColorPixel>
        self._draw(image: image, transform: transform, using: storageType, properties: properties)
    }
    
    public func draw<Image : ImageProtocol>(image: Image, transform: SDTransform) {
        self.draw(image: image, transform: transform, using: .png, properties: [:])
    }
    
    public func draw(image: ImageRep, transform: SDTransform, using storageType: ImageRep.MediaType, properties: [ImageRep.PropertyKey : Any]) {
        self._draw(image: image, transform: transform, using: storageType, properties: properties)
    }
    
    public func draw(image: ImageRep, transform: SDTransform) {
        self.draw(image: image, transform: transform, using: .png, properties: [:])
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
                "x1": "\(Decimal(gradient.start.x).rounded(scale: 9))",
                "y1": "\(Decimal(gradient.start.y).rounded(scale: 9))",
                "x2": "\(Decimal(gradient.end.x).rounded(scale: 9))",
                "y2": "\(Decimal(gradient.end.y).rounded(scale: 9))",
                ])
            
            element.setAttribute(for: "gradientTransform", value: gradient.transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: "\(Decimal(stop.offset).rounded(scale: 9))")
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: "\(Decimal(stop.color.opacity).rounded(scale: 9))")
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
                "fx": "\(Decimal(0.5 + magnitude).rounded(scale: 9))",
                "fy": "0.5",
                "cx": "0.5",
                "cy": "0.5",
                ])
            
            let transform = SDTransform.translate(x: -0.5, y: -0.5) * SDTransform.rotate(phase) * SDTransform.translate(x: gradient.end.x, y: gradient.end.y) * gradient.transform
            element.setAttribute(for: "gradientTransform", value: transform.attributeStr())
            
            for stop in gradient.stops {
                var _stop = SDXMLElement(name: "stop")
                _stop.setAttribute(for: "offset", value: "\(Decimal(stop.offset).rounded(scale: 9))")
                _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
                if stop.color.opacity < 1 {
                    _stop.setAttribute(for: "stop-opacity", value: "\(Decimal(stop.color.opacity).rounded(scale: 9))")
                }
                element.append(_stop)
            }
            
            defs.append(element)
        }
        
        return "url(#\(id))"
    }
    
    public func draw<C>(shape: Shape, winding: Shape.WindingRule, gradient: Gradient<C>) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
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
        
        self.append(element, shape, .identity)
    }
}

extension SVGContext {
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        guard startSpread == endSpread else { return }
        self.drawLinearGradient(stops: stops, start: start, end: end, spreadMethod: startSpread)
    }
    
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, spreadMethod: GradientSpreadMode) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
        let id = new_name("GRADIENT")
        
        var element = SDXMLElement(name: "linearGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "x1": "\(Decimal(start.x).rounded(scale: 9))",
            "y1": "\(Decimal(start.y).rounded(scale: 9))",
            "x2": "\(Decimal(end.x).rounded(scale: 9))",
            "y2": "\(Decimal(end.y).rounded(scale: 9))",
            ])
        
        switch spreadMethod {
        case .reflect: element.setAttribute(for: "spreadMethod", value: "reflect")
        case .repeat: element.setAttribute(for: "spreadMethod", value: "repeat")
        default: break
        }
        
        element.setAttribute(for: "gradientTransform", value: self.transform.attributeStr())
        
        for (_, stop) in stops.indexed().sorted(by: { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }) {
            var _stop = SDXMLElement(name: "stop")
            _stop.setAttribute(for: "offset", value: "\(Decimal(stop.offset).rounded(scale: 9))")
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: "\(Decimal(stop.color.opacity).rounded(scale: 9))")
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        let rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": "\(Decimal(viewBox.x).rounded(scale: 9))",
            "y": "\(Decimal(viewBox.y).rounded(scale: 9))",
            "width": "\(Decimal(viewBox.width).rounded(scale: 9))",
            "height": "\(Decimal(viewBox.height).rounded(scale: 9))",
            ])
        
        self.append(rect, Shape(rect: self.viewBox), .identity)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        guard startSpread == endSpread else { return }
        self.drawRadialGradient(stops: stops, start: start, startRadius: startRadius, end: end, endRadius: endRadius, spreadMethod: startSpread)
    }
    
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, spreadMethod: GradientSpreadMode) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
        let id = new_name("GRADIENT")
        
        let magnitude = (start - end).magnitude
        let phase = (start - end).phase
        
        var element = SDXMLElement(name: "radialGradient", attributes: [
            "id": id,
            "gradientUnits": "userSpaceOnUse",
            "fx": "\(Decimal(0.5 + magnitude).rounded(scale: 9))",
            "fy": "0.5",
            "cx": "0.5",
            "cy": "0.5",
            "fr": "\(Decimal(startRadius).rounded(scale: 9))",
            "r": "\(Decimal(endRadius).rounded(scale: 9))",
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
            _stop.setAttribute(for: "offset", value: "\(Decimal(stop.offset).rounded(scale: 9))")
            _stop.setAttribute(for: "stop-color", value: create_color(stop.color))
            if stop.color.opacity < 1 {
                _stop.setAttribute(for: "stop-opacity", value: "\(Decimal(stop.color.opacity).rounded(scale: 9))")
            }
            element.append(_stop)
        }
        
        defs.append(element)
        
        let rect = SDXMLElement(name: "rect", attributes: [
            "fill": "url(#\(id))",
            "x": "\(Decimal(viewBox.x).rounded(scale: 9))",
            "y": "\(Decimal(viewBox.y).rounded(scale: 9))",
            "width": "\(Decimal(viewBox.width).rounded(scale: 9))",
            "height": "\(Decimal(viewBox.height).rounded(scale: 9))",
            ])
        
        self.append(rect, Shape(rect: self.viewBox), .identity)
    }
}

extension SVGContext {
    
    private func _effect_element(_ type: String, _ effect: SVGEffect, _ visibleBound: inout Rect, _ objectBound: Rect) -> String? {
        
        guard let output = effect.output as? SVGEffectSerializable else { return nil }
        
        let id = new_name(type)
        var _filter = SDXMLElement(name: "filter", attributes: ["id": id])
        
        visibleBound = effect.visibleBound(visibleBound).union(visibleBound)
        
        if objectBound.width != 0 && objectBound.height != 0 {
            
            let x = 100 * (visibleBound.x - objectBound.x) / objectBound.width
            let y = 100 * (visibleBound.y - objectBound.y) / objectBound.height
            let width = 100 * visibleBound.width / objectBound.width
            let height = 100 * visibleBound.height / objectBound.height
            
            let _x = floor(x)
            let _y = floor(y)
            let _width = _x == x ? ceil(width) : ceil(width + 1)
            let _height = _y == y ? ceil(height) : ceil(height + 1)
            
            _filter.setAttribute(for: "filterUnits", value: "objectBoundingBox")
            _filter.setAttribute(for: "primitiveUnits", value: "userSpaceOnUse")
            _filter.setAttribute(for: "x", value: "\(Decimal(_x).rounded(scale: 9))" + "%")
            _filter.setAttribute(for: "y", value: "\(Decimal(_y).rounded(scale: 9))" + "%")
            _filter.setAttribute(for: "width", value: "\(Decimal(_width).rounded(scale: 9))" + "%")
            _filter.setAttribute(for: "height", value: "\(Decimal(_height).rounded(scale: 9))" + "%")
        }
        
        effect.enumerate { uuid, primitive in
            
            if let _primitive = primitive as? SVGEffectSerializable, var element = _primitive.toXMLElement() {
                
                element.setAttribute(for: "result", value: uuid.uuidString)
                
                if let region = primitive.region {
                    element.setAttribute(for: "x", value: "\(Decimal(region.x).rounded(scale: 9))")
                    element.setAttribute(for: "y", value: "\(Decimal(region.y).rounded(scale: 9))")
                    element.setAttribute(for: "width", value: "\(Decimal(region.width).rounded(scale: 9))")
                    element.setAttribute(for: "height", value: "\(Decimal(region.height).rounded(scale: 9))")
                }
                
                _filter.append(element)
            }
        }
        
        if let element = output.toXMLElement() {
            _filter.append(element)
        }
        
        defs.append(_filter)
        
        return id
    }
}

private protocol SVGEffectSerializable {
    
    func toXMLElement() -> SDXMLElement?
}

extension SVGFloodEffect : SVGEffectSerializable {
    
    private func create_color<C : ColorProtocol>(_ color: C) -> String {
        
        let color = color.convert(to: ColorSpace.sRGB, intent: .default)
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        return "rgb(\(red),\(green),\(blue))"
    }
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feFlood", attributes: ["flood-color": create_color(color)])
        
        if self.color.opacity < 1 {
            filter.setAttribute(for: "flood-opacity", value: "\(Decimal(self.color.opacity).rounded(scale: 9))")
        }
        
        return filter
    }
}

extension SVGBlendEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter: SDXMLElement
        
        switch mode {
        case .normal: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "normal"])
            
        case .in: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "in"])
        case .out: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "out"])
        case .atop: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "atop"])
        case .xor: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "xor"])
            
        case .multiply: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "multiply"])
        case .screen: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "screen"])
        case .overlay: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "overlay"])
        case .darken: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "darken"])
        case .lighten: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "lighten"])
        case .colorDodge: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color-dodge"])
        case .colorBurn: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color-burn"])
        case .softLight: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "soft-light"])
        case .hardLight: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "hard-light"])
        case .difference: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "difference"])
        case .exclusion: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "exclusion"])
            
        case .hue: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "hue"])
        case .saturation: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "saturation"])
        case .color: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color"])
        case .luminosity: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "luminosity"])
            
        case let .arithmetic(k1, k2, k3, k4):
            filter = SDXMLElement(name: "feComposite", attributes: ["operator": "arithmetic"])
            filter.setAttribute(for: "k1", value: "\(Decimal(k1).rounded(scale: 9))")
            filter.setAttribute(for: "k2", value: "\(Decimal(k2).rounded(scale: 9))")
            filter.setAttribute(for: "k3", value: "\(Decimal(k3).rounded(scale: 9))")
            filter.setAttribute(for: "k4", value: "\(Decimal(k4).rounded(scale: 9))")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        switch self.source2 {
        case .source: filter.setAttribute(for: "in2", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in2", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in2", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGMergeEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feMerge")
        
        for source in self.sources {
            var node = SDXMLElement(name: "feMergeNode")
            switch source {
            case .source: node.setAttribute(for: "in", value: "SourceGraphic")
            case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
            case let .reference(uuid): node.setAttribute(for: "in", value: uuid.uuidString)
            }
            filter.append(node)
        }
        
        return filter
    }
}

extension SVGColorMatrixEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        let matrix = [
            red.0, red.1, red.2, red.3, red.4,
            green.0, green.1, green.2, green.3, green.4,
            blue.0, blue.1, blue.2, blue.3, blue.4,
            alpha.0, alpha.1, alpha.2, alpha.3, alpha.4,
            ].map { "\(Decimal($0).rounded(scale: 9))" }
        
        var filter = SDXMLElement(name: "feColorMatrix", attributes: ["type": "matrix", "values": matrix.joined(separator: " ")])
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGComponentTransfer.TransferFunction {
    
    fileprivate func toXMLElement(_ node: String) -> SDXMLElement {
        
        switch self {
        case .identity: return SDXMLElement(name: node, attributes: ["type": "identity"])
            
        case let .table(values):
            
            let _values = values.map { "\(Decimal($0).rounded(scale: 9))" }.joined(separator: " ")
            
            return SDXMLElement(name: node, attributes: ["type": "table", "tableValues": _values])
            
        case let .discrete(values):
            
            let _values = values.map { "\(Decimal($0).rounded(scale: 9))" }.joined(separator: " ")
            
            return SDXMLElement(name: node, attributes: ["type": "discrete", "tableValues": _values])
            
        case let .gamma(amplitude, exponent, offset):
            
            var element = SDXMLElement(name: node)
            
            if exponent == 1 {
                element.setAttribute(for: "type", value: "linear")
                element.setAttribute(for: "slope", value: "\(Decimal(amplitude).rounded(scale: 9))")
                element.setAttribute(for: "intercept", value: "\(Decimal(offset).rounded(scale: 9))")
            } else {
                element.setAttribute(for: "type", value: "gamma")
                element.setAttribute(for: "amplitude", value: "\(Decimal(amplitude).rounded(scale: 9))")
                element.setAttribute(for: "exponent", value: "\(Decimal(exponent).rounded(scale: 9))")
                element.setAttribute(for: "offset", value: "\(Decimal(offset).rounded(scale: 9))")
            }
            
            return element
        }
    }
}

extension SVGComponentTransfer : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feComponentTransfer", elements: [
            red.toXMLElement("feFuncR"),
            green.toXMLElement("feFuncG"),
            blue.toXMLElement("feFuncB"),
            alpha.toXMLElement("feFuncA"),
            ])
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGConvolveMatrixEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        let matrix = self.matrix.map { "\(Decimal($0).rounded(scale: 9))" }
        var filter = SDXMLElement(name: "feConvolveMatrix", attributes: ["kernelMatrix": matrix.joined(separator: " "), "order": orderX == orderY ? "\(orderX)" : "\(orderX) \(orderY)"])
        
        if bias != 0 {
            filter.setAttribute(for: "bias", value: "\(Decimal(bias).rounded(scale: 9))")
        }
        
        filter.setAttribute(for: "preserveAlpha", value: "\(preserveAlpha)")
        
        switch edgeMode {
        case .duplicate: filter.setAttribute(for: "edgeMode", value: "duplicate")
        case .wrap: filter.setAttribute(for: "edgeMode", value: "wrap")
        case .none: filter.setAttribute(for: "edgeMode", value: "none")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGTurbulenceEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feTurbulence", attributes: [
            "stitchTiles": stitchTiles ? "stitch" : "noStitch",
            "seed": "\(seed)",
            "numOctaves": "\(numOctaves)",
            ])
        
        switch self.type {
        case .turbulence: filter.setAttribute(for: "type", value: "turbulence")
        case .fractalNoise: filter.setAttribute(for: "type", value: "fractalNoise")
        }
        
        if baseFrequency.width == baseFrequency.height {
            filter.setAttribute(for: "baseFrequency", value: "\(Decimal(baseFrequency.width).rounded(scale: 9))")
        } else {
            filter.setAttribute(for: "baseFrequency", value: "\(Decimal(baseFrequency.width).rounded(scale: 9)) \(Decimal(baseFrequency.height).rounded(scale: 9))")
        }
        
        return filter
    }
}

extension SVGGaussianBlurEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feGaussianBlur")
        
        if stdDeviation.width == stdDeviation.height {
            filter.setAttribute(for: "stdDeviation", value: "\(Decimal(stdDeviation.width).rounded(scale: 9))")
        } else {
            filter.setAttribute(for: "stdDeviation", value: "\(Decimal(stdDeviation.width).rounded(scale: 9)) \(Decimal(stdDeviation.height).rounded(scale: 9))")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGOffsetEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feOffset", attributes: [
            "dx": "\(Decimal(offset.width).rounded(scale: 9))",
            "dy": "\(Decimal(offset.height).rounded(scale: 9))",
            ])
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGDisplacementMapEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feDisplacementMap", attributes: ["scale": "\(Decimal(scale).rounded(scale: 9))"])
        
        switch xChannelSelector {
        case 0: filter.setAttribute(for: "xChannelSelector", value: "R")
        case 1: filter.setAttribute(for: "xChannelSelector", value: "G")
        case 2: filter.setAttribute(for: "xChannelSelector", value: "B")
        case 3: filter.setAttribute(for: "xChannelSelector", value: "A")
        default: break
        }
        switch yChannelSelector {
        case 0: filter.setAttribute(for: "yChannelSelector", value: "R")
        case 1: filter.setAttribute(for: "yChannelSelector", value: "G")
        case 2: filter.setAttribute(for: "yChannelSelector", value: "B")
        case 3: filter.setAttribute(for: "yChannelSelector", value: "A")
        default: break
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        switch self.displacement {
        case .source: filter.setAttribute(for: "in2", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in2", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in2", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGMorphologyEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feMorphology")
        
        if radius.width == radius.height {
            filter.setAttribute(for: "radius", value: "\(Decimal(radius.width).rounded(scale: 9))")
        } else {
            filter.setAttribute(for: "radius", value: "\(Decimal(radius.width).rounded(scale: 9)) \(Decimal(radius.height).rounded(scale: 9))")
        }
        
        switch mode {
        case .erode: filter.setAttribute(for: "operator", value: "erode")
        case .dilate: filter.setAttribute(for: "operator", value: "dilate")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

extension SVGTileEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        var filter = SDXMLElement(name: "feTile")
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}

private protocol SVGLightSourceSerializable {
    
    func toXMLElement() -> SDXMLElement
}

extension SVGPointLight : SVGLightSourceSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement {
        
        return SDXMLElement(name: "fePointLight", attributes: [
            "x": "\(Decimal(location.x).rounded(scale: 9))",
            "y": "\(Decimal(location.y).rounded(scale: 9))",
            "z": "\(Decimal(location.z).rounded(scale: 9))",
            ])
    }
}

extension SVGSpotLight : SVGLightSourceSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement {
        
        return SDXMLElement(name: "feSpotLight", attributes: [
            "x": "\(Decimal(location.x).rounded(scale: 9))",
            "y": "\(Decimal(location.y).rounded(scale: 9))",
            "z": "\(Decimal(location.z).rounded(scale: 9))",
            "pointsAtX": "\(Decimal(direction.x).rounded(scale: 9))",
            "pointsAtY": "\(Decimal(direction.y).rounded(scale: 9))",
            "pointsAtZ": "\(Decimal(direction.z).rounded(scale: 9))",
            "specularExponent": "\(Decimal(specularExponent).rounded(scale: 9))",
            "limitingConeAngle": "\(Decimal(limitingConeAngle * 180 / .pi).rounded(scale: 9))",
            ])
    }
}

extension SVGDistantLight : SVGLightSourceSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement {
        
        return SDXMLElement(name: "feDistantLight", attributes: [
            "azimuth": "\(Decimal(azimuth * 180 / .pi).rounded(scale: 9))",
            "elevation": "\(Decimal(elevation * 180 / .pi).rounded(scale: 9))",
            ])
    }
}

extension SVGDiffuseLightingEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        var element = SDXMLElement(name: "feDiffuseLighting", attributes: [
            "surfaceScale": "\(Decimal(surfaceScale).rounded(scale: 9))",
            "diffuseConstant": "\(Decimal(diffuseConstant).rounded(scale: 9))",
            "lighting-color": "rgb(\(red),\(green),\(blue))"
            ])
        
        for light in self.light {
            if let light = light as? SVGLightSourceSerializable {
                element.append(light.toXMLElement())
            }
        }
        
        switch self.source {
        case .source: element.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: element.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): element.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return element
    }
}

extension SVGSpecularLightingEffect : SVGEffectSerializable {
    
    fileprivate func toXMLElement() -> SDXMLElement? {
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        var element = SDXMLElement(name: "feSpecularLighting", attributes: [
            "surfaceScale": "\(Decimal(surfaceScale).rounded(scale: 9))",
            "specularConstant": "\(Decimal(specularConstant).rounded(scale: 9))",
            "specularExponent": "\(Decimal(specularExponent).rounded(scale: 9))",
            "lighting-color": "rgb(\(red),\(green),\(blue))"
            ])
        
        for light in self.light {
            if let light = light as? SVGLightSourceSerializable {
                element.append(light.toXMLElement())
            }
        }
        
        switch self.source {
        case .source: element.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: element.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): element.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return element
    }
}
