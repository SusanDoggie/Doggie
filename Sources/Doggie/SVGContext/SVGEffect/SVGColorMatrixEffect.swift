//
//  SVGColorMatrixEffect.swift
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

public struct SVGColorMatrixEffect : SVGEffectElement {
    
    public var region: Rect?
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var red: (Double, Double, Double, Double, Double)
    public var green: (Double, Double, Double, Double, Double)
    public var blue: (Double, Double, Double, Double, Double)
    public var alpha: (Double, Double, Double, Double, Double)
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public init(source: SVGEffect.Source = .source,
                red: (Double, Double, Double, Double, Double),
                green: (Double, Double, Double, Double, Double),
                blue: (Double, Double, Double, Double, Double),
                alpha: (Double, Double, Double, Double, Double)) {
        self.source = source
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return sources[source]
    }
}

extension SVGColorMatrixEffect {
    
    public init() {
        self.init(red: (1, 0, 0, 0, 0), green: (0, 1, 0, 0, 0), blue: (0, 0, 1, 0, 0), alpha: (0, 0, 0, 1, 0))
    }
}

extension SVGColorMatrixEffect {
    
    public var xml_element: SDXMLElement {
        
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
