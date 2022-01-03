//
//  SVGColorMatrixEffect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

public struct SVGColorMatrixEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
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
    
    public init(_ saturate: SVGSaturateEffect) {
        
        let s = saturate.saturate
        
        self.init(source: saturate.source,
                  red:   (0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0),
                  green: (0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0),
                  blue:  (0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0),
                  alpha: (0, 0, 0, 1, 0))
    }
    
    public init(_ hueRotate: SVGHueRotateEffect) {
        
        let _sin = sin(hueRotate.angle)
        let _cos = cos(hueRotate.angle)
        
        self.init(source: hueRotate.source,
                  red:   (0.213 + _cos * 0.787 - _sin * 0.213, 0.715 - _cos * 0.715 - _sin * 0.715, 0.072 - _cos * 0.072 + _sin * 0.928, 0, 0),
                  green: (0.213 - _cos * 0.213 + _sin * 0.143, 0.715 + _cos * 0.285 + _sin * 0.140, 0.072 - _cos * 0.072 - _sin * 0.283, 0, 0),
                  blue:  (0.213 - _cos * 0.213 - _sin * 0.787, 0.715 - _cos * 0.715 + _sin * 0.715, 0.072 + _cos * 0.928 + _sin * 0.072, 0, 0),
                  alpha: (0, 0, 0, 1, 0))
    }
    
    public init(_ luminanceToAlpha: SVGLuminanceToAlphaEffect) {
        
        self.init(source: luminanceToAlpha.source,
                  red: (0, 0, 0, 0, 0),
                  green: (0, 0, 0, 0, 0),
                  blue: (0, 0, 0, 0, 0),
                  alpha: (0.2125, 0.7154, 0.0721, 0, 0))
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
