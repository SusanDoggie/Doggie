//
//  SVGImageEffect.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public struct SVGImageEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var viewBox: Rect
    
    public var callback: (DrawableContext) -> Void
    
    public var sources: [SVGEffect.Source] {
        return []
    }
    
    public init(viewBox: Rect, callback: @escaping (DrawableContext) -> Void) {
        
        precondition(!viewBox.isNull, "viewBox is null.")
        precondition(!viewBox.isInfinite, "viewBox is infinite.")
        
        self.viewBox = viewBox
        self.callback = callback
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return nil
    }
}

extension SVGImageEffect {
    
    private static let allowedCharacters = CharacterSet(charactersIn: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ().!~*'-_")
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feImage", attributes: ["preserveAspectRatio": "none"])
        
        let context = SVGContext(viewBox: viewBox)
        self.callback(context)
        
        let data = context.document.xml(prettyPrinted: false)
        guard let encoded = data.addingPercentEncoding(withAllowedCharacters: SVGImageEffect.allowedCharacters) else { return filter }
        filter.setAttribute(for: "href", namespace: "http://www.w3.org/1999/xlink", value: "data:image/svg+xml;charset=utf-8," + encoded)
        
        return filter
    }
}
