//
//  SVGGaussianBlurEffect.swift
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

public struct SVGGaussianBlurEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var stdDeviation: Size
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public init(source: SVGEffect.Source = .source, stdDeviation: Double) {
        self.source = source
        self.stdDeviation = Size(width: stdDeviation, height: stdDeviation)
    }
    
    public init(source: SVGEffect.Source = .source, stdDeviation: Size = Size()) {
        self.source = source
        self.stdDeviation = stdDeviation
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return sources[source]?.inset(dx: -ceil(3 * abs(stdDeviation.width)), dy: -ceil(3 * abs(stdDeviation.height)))
    }
}

extension SVGGaussianBlurEffect {
    
    public var xml_element: SDXMLElement {
        
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
