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
    
    public init(context: SVGContext) {
        self._image = context
        self.storageType = .svg
        self.properties = [:]
    }
    
    public init(image: ImageRep, using storageType: MediaType = .png, properties: [ImageRep.PropertyKey : Any] = [:]) {
        self._image = image
        self.storageType = storageType
        self.properties = properties
    }
    
    public init<Image : ImageProtocol>(image: Image, using storageType: MediaType = .png, properties: [ImageRep.PropertyKey : Any] = [:]) {
        self._image = image as? SVGImageProtocol ?? image.convert(to: .sRGB, intent: renderingIntent) as Doggie.Image<ARGB32ColorPixel>
        self.storageType = storageType
        self.properties = properties
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return nil
    }
}

extension SVGImageEffect {
    
    public var image: Any {
        return _image
    }
}

extension SVGImageEffect {
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feImage")
        
        if let encoded = _image.url_data(using: storageType, properties: properties) {
            filter.setAttribute(for: "href", namespace: "http://www.w3.org/1999/xlink", value: encoded)
        }
        
        return filter
    }
}
