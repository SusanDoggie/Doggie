//
//  SVGImageEffect.swift
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

public struct SVGImageEffect : SVGEffectElement {
    
    public var region: Rect?
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    private let _image: SVGImageProtocol
    
    public let storageType: MediaType
    
    public let properties: [ImageRep.PropertyKey : Any]
    
    public var sources: [SVGEffect.Source] {
        return []
    }
    
    public init(viewBox: Rect, callback: @escaping (DrawableContext) -> Void) {
        self._image = SVGImageProvider(viewBox: viewBox, callback: callback)
        self.storageType = .svg
        self.properties = [:]
    }
    
    public init(image: ImageRep, using storageType: MediaType = .png, properties: [ImageRep.PropertyKey : Any] = [:]) {
        self._image = image
        self.storageType = storageType
        self.properties = properties
    }
    
    public init<Image : ImageProtocol>(image: Image, using storageType: MediaType = .png, properties: [ImageRep.PropertyKey : Any] = [:]) {
        self._image = image as? SVGImageProtocol ?? image.convert(to: .sRGB, intent: .default) as Doggie.Image<ARGB32ColorPixel>
        self.storageType = storageType
        self.properties = properties
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return nil
    }
}

extension SVGImageEffect {
    
    public var image: Any? {
        return _image is SVGImageProvider ? nil : _image
    }
    
    public var viewBox: Rect? {
        guard let provider = _image as? SVGImageProvider else { return nil }
        return provider.viewBox
    }
    
    public func render(to context: DrawableContext) {
        guard let provider = _image as? SVGImageProvider else { return }
        provider.callback(context)
    }
}

extension SVGImageEffect {
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feImage", attributes: ["preserveAspectRatio": "none"])
        
        if let encoded = _image.url_data(using: storageType, properties: properties) {
            filter.setAttribute(for: "href", namespace: "http://www.w3.org/1999/xlink", value: encoded)
        }
        
        return filter
    }
}
